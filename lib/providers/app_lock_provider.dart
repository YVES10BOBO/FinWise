import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-level lock for FinWise.
///
/// This is deliberately separate from Firebase sign-in. Firebase answers
/// "which account is this?" once and then keeps you signed in — which means
/// anyone holding an already-unlocked phone can open the app and read every
/// balance and transaction. This lock answers "is the person holding the
/// phone right now actually you?", every time the app is opened.
///
/// Security notes:
/// • The PIN is never stored in plain text — only a salted SHA-256 hash.
/// • Biometric data NEVER reaches the app. Android verifies the user in
///   secure hardware and returns only true/false.
class AppLockProvider with ChangeNotifier {
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _enabledKey = 'app_lock_enabled';
  static const _biometricKey = 'app_lock_biometric';
  static const _timeoutKey = 'app_lock_timeout_minutes';

  final LocalAuthentication _auth = LocalAuthentication();

  bool _isEnabled = false;
  bool _biometricEnabled = false;
  bool _isLocked = false;
  bool _loaded = false;
  int _timeoutMinutes = 0; // 0 = lock immediately on leaving
  DateTime? _backgroundedAt;

  bool get isEnabled => _isEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get isLocked => _isLocked;
  bool get isLoaded => _loaded;
  int get timeoutMinutes => _timeoutMinutes;

  AppLockProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;
      _biometricEnabled = prefs.getBool(_biometricKey) ?? false;
      _timeoutMinutes = prefs.getInt(_timeoutKey) ?? 0;
      // Start locked whenever the feature is on — a cold start must always
      // require verification.
      _isLocked = _isEnabled;
    } catch (_) {
      // Fail open rather than trapping the user out of their own data.
      _isEnabled = false;
      _isLocked = false;
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  // ---- Device capability ------------------------------------------------

  /// True when the phone has fingerprint/face set up and usable.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported || !canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---- PIN --------------------------------------------------------------

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt::$pin')).toString();

  String _newSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Turn the lock on with a new PIN.
  Future<void> setPin(String pin) async {
    final salt = _newSalt();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinSaltKey, salt);
    await prefs.setString(_pinHashKey, _hash(pin, salt));
    await prefs.setBool(_enabledKey, true);

    _isEnabled = true;
    _isLocked = false; // just set it — they're clearly present
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_pinSaltKey);
    final stored = prefs.getString(_pinHashKey);
    if (salt == null || stored == null) return false;
    return _hash(pin, salt) == stored;
  }

  /// Disable the lock entirely (requires the current PIN at the UI layer).
  Future<void> disableLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await prefs.remove(_pinSaltKey);
    await prefs.setBool(_enabledKey, false);
    await prefs.setBool(_biometricKey, false);

    _isEnabled = false;
    _biometricEnabled = false;
    _isLocked = false;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
    _biometricEnabled = value;
    notifyListeners();
  }

  Future<void> setTimeout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, minutes);
    _timeoutMinutes = minutes;
    notifyListeners();
  }

  // ---- Biometric prompt --------------------------------------------------

  /// Ask Android to verify the user. Returns true only on success.
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock FinWise to view your finances',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Biometric auth failed: $e');
      return false;
    }
  }

  // ---- Lock lifecycle ----------------------------------------------------

  void unlock() {
    _isLocked = false;
    _backgroundedAt = null;
    notifyListeners();
  }

  /// Called when the app goes to the background — start the timeout clock.
  void onPaused() {
    if (!_isEnabled) return;
    _backgroundedAt = DateTime.now();
  }

  /// Called when the app returns. Re-locks if the configured grace period
  /// has elapsed (0 minutes = always lock).
  void onResumed() {
    if (!_isEnabled || _isLocked) return;
    final since = _backgroundedAt;
    if (since == null) return;

    final away = DateTime.now().difference(since);
    if (away.inMinutes >= _timeoutMinutes) {
      _isLocked = true;
      notifyListeners();
    }
    _backgroundedAt = null;
  }

  /// Lock right now (used by the "Lock now" action in Settings).
  void lockNow() {
    if (!_isEnabled) return;
    _isLocked = true;
    notifyListeners();
  }
}
