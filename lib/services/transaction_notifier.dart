import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../providers/locale_provider.dart';

/// Shows a heads-up notification each time a Mobile Money transaction is
/// auto-detected — so the user gets a visible "Money received / Money sent"
/// confirmation even when FinWise is closed or in the background.
///
/// Works from any isolate (the SMS background handler included): it lazily
/// initializes the plugin on first use, so it doesn't depend on the main
/// app having started.
class TransactionNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String _channelId = 'finwise_transactions';

  /// Channel name/description follow the app language (Android shows them
  /// in the phone's notification settings).
  static AndroidNotificationDetails _details(AppLocalizations l) =>
      AndroidNotificationDetails(
        _channelId,
        l.notifChannelName,
        channelDescription: l.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Post a notification describing [tx]. Never throws — a failed
  /// notification must not stop the transaction from being recorded.
  static Future<void> showDetected(Transaction tx) async {
    try {
      await _ensureInitialized();

      final prefs = await SharedPreferences.getInstance();
      final currency = AppCurrency.fromCode(prefs.getString('currency_code'));
      final pattern =
          currency.decimalDigits > 0 ? '#,##0.${'0' * currency.decimalDigits}' : '#,###';
      final formatted = NumberFormat(pattern).format(tx.amount);

      final l = await savedAppLocalizations();
      final isIncome = tx.type == TransactionType.income;
      final sign = isIncome ? '+' : '-';
      final title = isIncome ? l.notifMoneyReceived : l.notifMoneySent;
      final body =
          '$sign${currency.symbol}$formatted — ${displayDescriptionFor(l, tx.description)}';

      final details = NotificationDetails(android: _details(l));

      // Unique per transaction so several alerts stack instead of replacing.
      await _plugin.show(tx.id.hashCode, title, body, details);
    } catch (_) {
      // Ignore — recording the transaction is what matters.
    }
  }

  /// Diagnostic / error notification (e.g. "MoMo SMS not read", or a caught
  /// recording error). Makes silent failures visible so issues are traceable.
  static Future<void> showError(String title, String body) async {
    try {
      await _ensureInitialized();
      final details =
          NotificationDetails(android: _details(await savedAppLocalizations()));
      // Time-based id so diagnostics stack rather than overwrite each other.
      final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // Ignore.
    }
  }
}
