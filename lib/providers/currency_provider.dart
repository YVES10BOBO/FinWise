import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';
import '../services/firestore_user_profile_service.dart';

/// Tracks the user's chosen currency and formats amounts consistently
/// across the whole app (dashboard, transactions, budgets, goals, exports).
class CurrencyProvider with ChangeNotifier {
  AppCurrency _currency = AppCurrency.rwf;
  bool _isLoading = true;
  final FirestoreUserProfileService _profileService =
      FirestoreUserProfileService();

  AppCurrency get currency => _currency;
  bool get isLoading => _isLoading;
  String get symbol => _currency.symbol;
  String get code => _currency.code;

  CurrencyProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('currency_code');

      if (savedCode != null) {
        _currency = AppCurrency.fromCode(savedCode);
      } else {
        // No local preference yet — check if this user already has one
        // saved in Firestore (e.g. logging in on a new device).
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final profile = await _profileService.getProfile(user.uid);
          final remoteCode = profile?['currencyCode'] as String?;
          if (remoteCode != null) {
            _currency = AppCurrency.fromCode(remoteCode);
            await prefs.setString('currency_code', _currency.code);
          }
        }
      }
    } catch (_) {
      // Fall back to RWF default.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrency(AppCurrency newCurrency) async {
    _currency = newCurrency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency_code', newCurrency.code);
    } catch (_) {
      // Ignore local cache failure — Firestore save below still matters.
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _profileService.updateProfile(
          uid: user.uid,
          currencyCode: newCurrency.code,
        );
      } catch (_) {
        // Offline or permission issue — local preference is already saved.
      }
    }
  }

  /// Format an amount using the user's chosen currency, e.g. "12,500 RWF"
  /// or "$45.00" depending on symbol placement conventions.
  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: _currency.decimalDigits,
    );
    final numberPart = formatter.format(amount).trim();

    // A handful of currencies conventionally show the symbol before the
    // number with no space (e.g. $45.00), the rest read better after.
    const prefixSymbols = {'\$', '£', '€', '₦', '₹', 'C\$', 'GH₵'};
    if (prefixSymbols.contains(_currency.symbol)) {
      return '${_currency.symbol}$numberPart';
    }
    return '$numberPart ${_currency.symbol}';
  }

  /// Format without decimals regardless of currency (handy for compact UI).
  String formatCompact(double amount) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final numberPart = formatter.format(amount).trim();
    const prefixSymbols = {'\$', '£', '€', '₦', '₹', 'C\$', 'GH₵'};
    if (prefixSymbols.contains(_currency.symbol)) {
      return '${_currency.symbol}$numberPart';
    }
    return '$numberPart ${_currency.symbol}';
  }
}
