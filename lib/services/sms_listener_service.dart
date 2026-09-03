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

/// When a transaction was last successfully recorded from an SMS.
///
/// This is the app's health signal. Detection depends on regex matching
/// wording the provider controls and can change without notice, on a
/// permission Android can revoke, and on a background service OEM battery
/// managers like to kill — and ALL of those fail silently. Every figure in
/// the app is derived from the transaction list, so silent failure doesn't
/// show an error, it shows a confidently wrong balance. Recording when
/// detection last worked is what makes that failure visible.
const String kLastDetectionAtKey = 'sms_last_detection_at';

/// When the SMS inbox was last successfully scanned, regardless of whether
/// anything financial was found. Distinguishes "running fine, you just
/// haven't spent anything" from "not running at all".
const String kLastScanAtKey = 'sms_last_scan_at';

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
    // Keep the provider's exact wording so the user can check what was
    // actually read — the list shows a summary, the detail view the original.
    smsBody: parsed.messageBody,
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
    // MUST reload before reading the toggle. This runs in several isolates
    // (background SMS handler, foreground service, UI), and each holds its
    // OWN in-memory snapshot of SharedPreferences taken when it started.
    // Turning auto-detect off in Settings writes from the UI isolate only —
    // without this reload the background isolates keep their stale `true`
    // and carry on recording, which looked exactly like the switch doing
    // nothing.
    await prefs.reload();
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

    var transaction = _buildTransaction(parsed);
    built = transaction;

    // Catch repeats and both-sides-of-one-transfer before storing anything.
    final outcome = await _classifyAgainstRecent(prefs, transaction);
    if (outcome == _PairOutcome.duplicate || outcome == _PairOutcome.transferPair) {
      // Either a repeat of a message we already have, or the second half of a
      // movement between the user's own accounts (the first half has been
      // rewritten as a Transfer). Nothing more to record.
      return;
    }
    if (outcome == _PairOutcome.transferEcho) {
      // Mobile Money re-announcing a transfer already on record. Keep it in
      // history for a full paper trail, but as a second neutral leg — never
      // as income/expense, so it can't inflate the totals.
      transaction = transaction.copyWith(
        type: TransactionType.transfer,
        description: 'Transfer confirmation: ${transaction.description}',
      );
      built = transaction;
    }

    // 2. Per-item slot (race-free).
    await prefs.setString(
      '$kDetectedSmsTxPrefix${transaction.id}',
      json.encode(transaction.toJson()),
    );

    // A transfer moves money between the user's own accounts, so it is not a
    // loss — but any FEE charged on it genuinely is. Record that separately
    // as a real expense so the balance stays accurate.
    if (parsed.type == TransactionType.transfer && (parsed.fee ?? 0) > 0) {
      final feeTx = Transaction(
        id: '${transaction.id}_fee',
        type: TransactionType.expense,
        category: Category.fees,
        amount: parsed.fee!,
        description: 'Transfer fee',
        date: transaction.date,
        account: parsed.account,
        isAutoDetected: true,
      );
      await prefs.setString(
        '$kDetectedSmsTxPrefix${feeTx.id}',
        json.encode(feeTx.toJson()),
      );
    }

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

    // 5. Health signal — proof the whole pipeline worked end to end.
    await prefs.setInt(
        kLastDetectionAtKey, DateTime.now().millisecondsSinceEpoch);
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

/// How close together two messages must be to describe the same real event.
const Duration _pairWindow = Duration(minutes: 5);

/// Tighter window for suppressing a stray receive/payment message that
/// follows a transfer that's ALREADY been recorded. Mobile Money sometimes
/// fires a second, contradictory SMS about one transfer between the user's
/// own accounts (many of the user's accounts share the same registered
/// name, so a transfer often shows up first, then a "received"/"paid" SMS
/// about the very same money seconds later). Kept short and separate from
/// the general 5-minute pairing window so it only catches genuine near-
/// instant follow-ups, not unrelated transactions that happen to match.
const Duration _transferNoiseWindow = Duration(minutes: 1);

enum _PairOutcome {
  /// Nothing similar nearby — record normally.
  none,

  /// The same message arrived twice — ignore this one.
  duplicate,

  /// Two halves of one movement between the user's own accounts. The earlier
  /// entry has been converted to a Transfer; ignore this one.
  transferPair,

  /// A transfer was already recorded, and this message is Mobile Money
  /// re-announcing that same movement (e.g. MoCash "sent" followed by MoMo
  /// "received" seconds later). Still worth a line in history for a full
  /// paper trail, but must be saved as a second, neutral Transfer leg —
  /// never as income or expense, or it would double-count.
  transferEcho,
}

/// Words that describe the transaction rather than name the other party.
/// Descriptions now carry the provider's full sentence ("Your payment of 400
/// RWF to David was completed"), so pairing the two halves of one transfer
/// means reducing both sides to just the name — otherwise "…transferred to
/// Marie…" and "You have received … from Marie…" would never match.
const Set<String> _descriptionStopWords = {
  'transfer', 'transferred', 'transfers', 'confirmation', 'between',
  'accounts', 'account', 'payment', 'payments', 'paid', 'pay',
  'received', 'receive', 'sent', 'send', 'sending', 'completed', 'complete',
  'successful', 'successfully', 'you', 'your', 'yours', 'have', 'has', 'was',
  'were', 'is', 'are', 'been', 'be', 'the', 'a', 'an', 'of', 'to', 'from',
  'at', 'on', 'in', 'for', 'and', 'with', 'incl', 'fee', 'fees', 'balance',
  'mobile', 'money', 'wallet', 'bank', 'new', 'now', 'ref',
  // Kinyarwanda equivalents
  'umaze', 'kohereza', 'wakiriye', 'wishyuye', 'wohereje', 'watanze',
  'wahawe', 'amafaranga', 'kuva', 'kuri', 'konti', 'yawe', 'ifiteho',
  // Currency tokens — they'd otherwise survive the letters-only filter.
  'rwf', 'frw', 'kes', 'ksh', 'kshs', 'ugx', 'ush', 'tzs', 'tsh', 'ngn',
  'ghs', 'ghc', 'zar', 'xaf', 'fcfa', 'cfa', 'usd', 'eur', 'gbp', 'cad',
  'inr',
};

/// Strip a description down to the counterparty name for comparison, e.g.
/// both "Your payment of 400 RWF to David was completed" and "You have
/// received 400 RWF from David" reduce to "david".
String _counterpartyKey(String description) {
  var s = description.toLowerCase();
  s = s.replaceAll(RegExp(r'\(.*?\)'), ' '); // bracketed extras
  s = s.replaceAll(RegExp(r'[^a-z ]'), ' '); // digits, punctuation
  final words = s
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !_descriptionStopWords.contains(w));
  return words.join(' ').trim();
}

/// Decide whether [candidate] duplicates, or pairs with, something recorded
/// moments ago.
///
/// Mobile Money reports ONE movement between the user's own accounts as TWO
/// messages — "2000 transferred to X" from the sending account and "received
/// 2000 from X" on the receiving one. Matching on amount + counterparty +
/// time means we don't need to know the user's name, works for company names,
/// and works across MTN, Airtel and banks alike.
Future<_PairOutcome> _classifyAgainstRecent(
    SharedPreferences prefs, Transaction candidate) async {
  final candidateKey = _counterpartyKey(candidate.description);

  bool isNear(Transaction other) =>
      other.date.difference(candidate.date).abs() <= _pairWindow;

  bool sameParty(Transaction other) {
    final k = _counterpartyKey(other.description);
    if (k.isEmpty || candidateKey.isEmpty) return true; // can't tell — be safe
    return k == candidateKey || k.contains(candidateKey) || candidateKey.contains(k);
  }

  // ---- 1. Pending slots (detected, not yet drained into the list) --------
  for (final key in prefs.getKeys()) {
    if (!key.startsWith(kDetectedSmsTxPrefix)) continue;
    final raw = prefs.getString(key);
    if (raw == null) continue;
    try {
      final other = Transaction.fromJson(json.decode(raw));
      if (other.id == candidate.id) return _PairOutcome.duplicate;
      if (other.amount != candidate.amount) continue;
      if (!sameParty(other)) continue;

      // The earlier message was ALREADY recorded as a transfer, and this one
      // arrived moments later claiming the same money was received or paid.
      // That's Mobile Money re-announcing the same transfer, not a new
      // transaction — leave the transfer entry untouched and save this one
      // as a second, neutral leg (see transferEcho).
      if (other.type == TransactionType.transfer &&
          candidate.type != TransactionType.transfer &&
          other.date.difference(candidate.date).abs() <= _transferNoiseWindow) {
        return _PairOutcome.transferEcho;
      }

      if (!isNear(other)) continue;
      if (other.type == candidate.type) return _PairOutcome.duplicate;

      // Opposite directions, same money, same moment → self-transfer.
      // Rewrite the earlier entry as a Transfer and drop this one.
      final asTransfer = other.copyWith(
        type: TransactionType.transfer,
        description: 'Transfer between accounts',
      );
      await prefs.setString(key, json.encode(asTransfer.toJson()));
      return _PairOutcome.transferPair;
    } catch (_) {}
  }

  // ---- 2. Already-saved transactions ------------------------------------
  for (final key in prefs.getKeys()) {
    if (!key.startsWith('transactions_')) continue;
    final raw = prefs.getString(key);
    if (raw == null) continue;
    try {
      final list = json.decode(raw) as List<dynamic>;
      // Only the newest entries can fall inside the time window.
      for (var i = 0; i < list.length && i < 25; i++) {
        final other = Transaction.fromJson(list[i] as Map<String, dynamic>);
        if (other.id == candidate.id) return _PairOutcome.duplicate;
        if (other.amount != candidate.amount) continue;
        if (!sameParty(other)) continue;

        // Same reasoning as the pending-slots check above: a transfer
        // already on record, followed within a minute by a same-amount,
        // same-party receive/payment message, is Mobile Money re-announcing
        // that transfer — save it as a second, neutral leg (transferEcho)
        // rather than a real income/expense.
        if (other.type == TransactionType.transfer &&
            candidate.type != TransactionType.transfer &&
            other.date.difference(candidate.date).abs() <= _transferNoiseWindow) {
          return _PairOutcome.transferEcho;
        }

        if (!isNear(other)) continue;
        if (other.type == candidate.type) return _PairOutcome.duplicate;

        list[i] = other
            .copyWith(
              type: TransactionType.transfer,
              description: 'Transfer between accounts',
            )
            .toJson();
        await prefs.setString(key, json.encode(list));
        return _PairOutcome.transferPair;
      }
    } catch (_) {}
  }

  return _PairOutcome.none;
}

/// A snapshot of whether auto-detection is actually working.
///
/// Deliberately reports the *causes* separately (off, no permission, being
/// battery-throttled, nothing found in a long time) because each has a
/// different fix, and telling the user "it's not working" without telling
/// them why is barely better than staying silent.
class SmsDetectionHealth {
  final bool enabled;
  final bool permissionGranted;
  final DateTime? lastDetection;
  final DateTime? lastScan;
  final bool batteryOptimized;

  const SmsDetectionHealth({
    required this.enabled,
    required this.permissionGranted,
    required this.lastDetection,
    required this.lastScan,
    required this.batteryOptimized,
  });

  /// Detection has been silent long enough to be worth questioning. Two
  /// weeks is deliberately generous: a genuinely quiet fortnight is possible,
  /// and crying wolf would train users to ignore the warning.
  static const Duration quietThreshold = Duration(days: 14);

  bool get isQuiet {
    if (!enabled || !permissionGranted) return false;
    final last = lastDetection;
    if (last == null) return false; // never detected yet — not a fault
    return DateTime.now().difference(last) > quietThreshold;
  }

  /// True when something is definitely wrong rather than merely quiet.
  bool get isBroken => enabled && !permissionGranted;

  /// Whether the pipeline is confirmed alive, even if no money moved.
  bool get isScanningRecently {
    final scan = lastScan;
    if (scan == null) return false;
    return DateTime.now().difference(scan) < const Duration(hours: 24);
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

    // Start from NOW, never from wherever the poller left off previously.
    // A user who turns auto-detect off and records by hand for a fortnight
    // would otherwise have that whole backlog replayed on re-enabling —
    // duplicating everything they already entered manually. Messages that
    // arrived while the feature was deliberately off are not ours to record.
    await prefs.setInt(
        kLastPolledSmsDateKey, DateTime.now().millisecondsSinceEpoch);

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
  ///
  /// Deliberately does NOT ask for notification permission here — that's
  /// already asked once during onboarding (`requestPermissionAndEnable`).
  /// Asking again here made users see "Allow notifications" twice: once
  /// during setup, once on first reaching the main screen.
  static Future<void> ensureAutoDetectRunning() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    if (!enabled) return;

    final granted = await _telephony.requestSmsPermissions ?? false;
    if (!granted) return;

    await prefs.setBool(kSmsAutoDetectEnabledKey, true);
    _listen();
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

    // The scan itself succeeded — record that even when there was nothing
    // financial to find, so "quiet" can be told apart from "broken".
    await prefs.setInt(kLastScanAtKey, DateTime.now().millisecondsSinceEpoch);

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

  /// How the app is doing at actually detecting transactions — see
  /// [kLastDetectionAtKey] for why this exists.
  static Future<SmsDetectionHealth> health() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
    final permitted = await _telephony.requestSmsPermissions ?? false;

    DateTime? at(String key) {
      final ms = prefs.getInt(key);
      return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    }

    return SmsDetectionHealth(
      enabled: enabled,
      permissionGranted: permitted,
      lastDetection: at(kLastDetectionAtKey),
      lastScan: at(kLastScanAtKey),
      batteryOptimized: await ForegroundServiceHandler.isBatteryOptimized,
    );
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
