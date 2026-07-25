import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_user_profile_service.dart';

/// Holds the user's *expected income* as a planning target — NOT as money in
/// their balance. Real income comes from actual transactions; this figure is
/// only used to analyse (savings rate, "vs your usual income", budgets).
///
/// It's editable anytime in Settings, because income changes month to month.
/// Stored in the same prefs keys the app already used (`user_income`,
/// `income_frequency`) so existing screens keep working, and synced to the
/// Firestore profile.
class IncomeProvider with ChangeNotifier {
  static const _incomeKey = 'user_income';
  static const _frequencyKey = 'income_frequency';

  double? _amount; // amount as entered, in the chosen frequency
  String _frequency = 'Monthly';
  bool _loaded = false;

  double? get amount => _amount;
  String get frequency => _frequency;
  bool get isSet => _amount != null && _amount! > 0;

  /// Income normalized to a monthly figure, for consistent analysis.
  double get monthlyIncome {
    final a = _amount ?? 0;
    switch (_frequency) {
      case 'Daily':
        return a * 30;
      case 'Weekly':
        return a * 4.33;
      case 'Yearly':
        return a / 12;
      case 'Monthly':
      default:
        return a;
    }
  }

  IncomeProvider() {
    _load();
    FirebaseAuth.instance.authStateChanges().listen((_) => _load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_incomeKey);
      _amount = (raw != null && raw.trim().isNotEmpty)
          ? double.tryParse(raw.trim())
          : null;
      final freq = prefs.getString(_frequencyKey);
      if (freq != null &&
          ['Daily', 'Weekly', 'Monthly', 'Yearly'].contains(freq)) {
        _frequency = freq;
      }
    } catch (_) {
      // keep defaults
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  bool get isLoaded => _loaded;

  Future<void> setIncome(double? amount, String frequency) async {
    _amount = amount;
    _frequency = frequency;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (amount != null && amount > 0) {
        await prefs.setString(_incomeKey, amount.toStringAsFixed(0));
      } else {
        await prefs.remove(_incomeKey);
      }
      await prefs.setString(_frequencyKey, frequency);
    } catch (_) {}

    // Sync to Firestore profile (best-effort).
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreUserProfileService().updateProfile(
          uid: user.uid,
          email: user.email,
          income: amount,
          incomeFrequency: frequency,
        );
      }
    } catch (_) {}
  }
}
