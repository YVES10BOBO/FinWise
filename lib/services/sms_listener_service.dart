import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';
import '../models/transaction.dart';
import '../navigation_key.dart';
import '../providers/transaction_provider.dart';
import 'categorization_service.dart';
import 'firestore_transaction_service.dart';
import 'foreground_service_handler.dart';
import 'sms_transaction_parser.dart';
import 'transaction_notifier.dart';

/// Whether the user has auto-detection on. Default ON — it "just works"
/// without hunting for a toggle; only stays off if explicitly turned off.
const String kSmsAutoDetectEnabledKey = 'sms_auto_detect_enabled';

/// When true, show extra diagnostic notifications (e.g. a MoMo-looking SMS
/// that couldn't be parsed, or a recording error). On while we stabilise the
/// feature; can be turned off later from Settings.
const String kSmsDebugKey = 'sms_auto_detect_debug';

/// Timestamp (ms since epoch) of the newest SMS the foreground inbox poll has
/// already handled, so it only processes genuinely new messages.
const String kLastPolledSmsDateKey = 'sms_last_polled_date';

/// Build a Transaction from a parsed SMS. Same in every isolate so the id is
/// identical for one message → foreground and background never double-count.
Transaction _buildTransaction(ParsedSmsTransaction parsed) {
  return Transaction(
    // Prefer the provider's own transaction id (bulletproof de-dup: the same
    // real SMS always yields the same id, on any path, in any session). Fall
    // back to time+amount+text only if the SMS had no reference number.
    id: parsed.txId != null
        ? 'momo_${parsed.txId}'
        : '${parsed.detectedAt.millisecondsSinceEpoch}_${parsed.amount.toStringAsFixed(0)}_${parsed.description.hashCode}',
    type: parsed.type,
    category: CategorizationService.categorizeTransaction(
      // Scan the whole SMS text (merchant/biller names live here), not just
      // the short "From/To <name>" description.
      parsed.messageBody,
      parsed.amount,
      type: parsed.type,
    ),
    amount: parsed.amount,
    description: parsed.description,
    date: parsed.detectedAt,
    account: parsed.account,
    isAutoDetected: true,
  );
}

/// Resolve the logged-in user's uid from ANY isolate. A fresh background
/// isolate must init Firebase itself and may need a moment for the persisted
/// auth session to restore, so we wait briefly before falling back to guest.
Future<String?> _resolveUid() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    return null;
  }

  final current = FirebaseAuth.instance.currentUser?.uid;
  if (current != null) return current;

  try {
    final user = await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((u) => u != null)
        .timeout(const Duration(seconds: 3));
    return user?.uid;
  } catch (_) {
    return null;
  }
}

/// THE one and only recording path — used by both the foreground and the
/// background handler, so behaviour can never diverge between them.
///
///  1. Parse. If it isn't a Mobile Money message, stop quietly.
///  2. Save to a per-item key (`detected_sms_tx_<id>`) — race-free even when
///     several SMS arrive together — which the open app drains into the list.
///  3. Sync to Firestore when logged in (idempotent, offline-safe).
///  4. Show a "Money received/sent" notification.
///
/// NOTE: message contents are never logged. Printing SMS bodies to logcat
/// would expose the user's financial messages to any app able to read logs.
Future<void> _processSms(String sender, String body, {DateTime? receivedAt}) async {
  Transaction? built;
  try {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    if (!enabled) return;
    // Diagnostic notifications are OFF by default — they were a development
    // aid and would be noise for real users.
    final debug = prefs.getBool(kSmsDebugKey) ?? false;

    final looksMomo = SmsTransactionParser.looksLikeMomoMessage(sender, body);
    // Use the SMS's own timestamp (when available) so the id is identical no
    // matter which path saw the message (foreground poll, foreground
    // callback, or background isolate) → never double-recorded.
    final parsed = SmsTransactionParser.parse(sender, body, receivedAt: receivedAt);
    if (parsed == null) {
      // Only warn if it looked financial — avoids nagging on personal SMS.
      if (debug && looksMomo) {
        await TransactionNotifier.showError(
          'MoMo SMS not read',
          'Looked like a transaction but the amount/format wasn\'t recognised.',
        );
      }
      return;
    }

    final transaction = _buildTransaction(parsed);
    built = transaction;

    // 2. Per-item slot (race-free).
    await prefs.setString(
      '$kDetectedSmsTxPrefix${transaction.id}',
      json.encode(transaction.toJson()),
    );

    // 3. Cloud sync when logged in.
    final uid = await _resolveUid();
    if (uid != null) {
      try {
        await FirestoreTransactionService().upsertTransaction(uid, transaction);
      } catch (_) {
        // Offline/permission — the per-item slot still has it; syncs later.
      }
    }

    // 4. Success confirmation.
    await TransactionNotifier.showDetected(transaction);
  } catch (e) {
    // Only in debug builds, and never with message contents.
    if (kDebugMode) debugPrint('FinWise: SMS processing failed: $e');
    // Tell the user only if something was actually detected but couldn't be
    // saved — a silent loss of a real transaction would be worse.
    if (built != null) {
      await TransactionNotifier.showError(
        'Transaction not saved',
        'Could not record "${built.description}". Please add it manually.',
      );
    }
  }
}

/// Background handler — required by `telephony`. Runs in its own isolate when
/// an SMS arrives while FinWise isn't in the foreground. Records directly.
@pragma('vm:entry-point')
Future<void> smsBackgroundMessageHandler(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _processSms(
    message.address ?? '',
    message.body ?? '',
    receivedAt: message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : null,
  );
}

class SmsListenerService {
  static final Telephony _telephony = Telephony.instance;

  /// Guards against registering the telephony listener more than once.
  /// Registering twice can stop new-message callbacks from firing — which is
  /// exactly the kind of silent breakage we want to avoid.
  static bool _listening = false;

  /// Called from the Settings toggle. Asks for SMS permission, enables the
  /// feature, and starts the listener + monitoring service.
  static Future<bool> requestPermissionAndEnable() async {
    final granted = await _telephony.requestSmsPermissions ?? false;
    if (!granted) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kSmsAutoDetectEnabledKey, true);
    _listen();

    await ForegroundServiceHandler.requestPermissions();
    await ForegroundServiceHandler.start();
    return true;
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kSmsAutoDetectEnabledKey, false);
    await ForegroundServiceHandler.stop();
  }

  /// App-startup entry: start listening only if permission is ALREADY
  /// granted (never prompts here — there's no Activity attached yet).
  static Future<void> startIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    if (!enabled) return;

    // isSmsCapablePhone-independent: just check current permission state
    // without prompting, by seeing if listening can begin.
    final hasPermission = await _telephony.requestSmsPermissions ?? false;
    if (!hasPermission) return;

    _listen();
    await ForegroundServiceHandler.start();
  }

  /// Called once the main screen is shown (there's an Activity, so the
  /// permission dialog can appear). On by default → asks the first time,
  /// then starts everything. Safe to call every launch; the guard makes the
  /// listener registration a no-op if it's already running.
  static Future<void> ensureAutoDetectRunning() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    if (!enabled) return;

    final granted = await _telephony.requestSmsPermissions ?? false;
    if (!granted) return;

    await prefs.setBool(kSmsAutoDetectEnabledKey, true);
    _listen();
    await ForegroundServiceHandler.requestPermissions();
    await ForegroundServiceHandler.start();
  }

  /// Reliable FOREGROUND detection: while the app is open, actively read the
  /// SMS inbox for anything newer than the last one we handled and process
  /// it. This does NOT rely on the plugin's foreground `onNewMessage`
  /// callback, which doesn't fire on some devices (yours included) — reading
  /// the inbox directly always works as long as READ_SMS is granted.
  static Future<void> pollInboxForNew() async {
    final prefs = await SharedPreferences.getInstance();
    // Two pollers share this: the in-app 3s timer and the foreground-service
    // 15s timer (different isolates). reload() lets each see the other's
    // progress so they don't redo work; de-dup covers any remaining overlap.
    await prefs.reload();
    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    if (!enabled) return;

    // First run: only look at the last few minutes so we don't replay the
    // whole inbox history the very first time.
    final lastDate = prefs.getInt(kLastPolledSmsDateKey) ??
        DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch;

    List<SmsMessage> messages;
    try {
      messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.DATE).greaterThan('$lastDate'),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FinWise: inbox poll failed: $e');
      return;
    }

    if (messages.isEmpty) return;

    var newest = lastDate;
    // Oldest first so they land in chronological order.
    for (final m in messages.reversed) {
      final d = m.date ?? 0;
      if (d <= lastDate) continue;
      await _processSms(
        m.address ?? '',
        m.body ?? '',
        receivedAt: DateTime.fromMillisecondsSinceEpoch(d),
      );
      if (d > newest) newest = d;
    }
    await prefs.setInt(kLastPolledSmsDateKey, newest);
  }

  static void _listen() {
    // Registering the listener twice can stop callbacks firing altogether.
    if (_listening) return;
    _listening = true;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        // App is (usually) in the foreground here. Record via the same single
        // path as the background, then immediately drain the new item into
        // the live list so it shows on the balance right away.
        await _processSms(
          message.address ?? '',
          message.body ?? '',
          receivedAt: message.date != null
              ? DateTime.fromMillisecondsSinceEpoch(message.date!)
              : null,
        );
        // Read the navigator context AFTER the await, so it reflects the
        // widget tree as it is now rather than before processing started.
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          await Provider.of<TransactionProvider>(context, listen: false)
              .refreshFromCache();
        }
      },
      onBackgroundMessage: smsBackgroundMessageHandler,
      listenInBackground: true,
    );
  }
}
