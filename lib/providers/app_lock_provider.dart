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
  static const _failedAttemptsKey = 'app_lock_failed_attempts';
  static const _lockoutUntilKey = 'app_lock_lockout_until';

  /// Wrong guesses allowed before a cooldown starts. Five are permitted; the
  /// sixth wrong PIN begins the 30-second wait.
  static const int freeAttempts = 5;

  /// Escalating cooldowns. Someone guessing at random needs ~5,000 tries for
  /// a 4-digit PIN, so even the first 30s penalty makes brute force useless.
  static const List<int> _cooldownSeconds = [30, 60, 120, 300];

  final LocalAuthentication _auth = LocalAuthentication();

  bool _isEnabled = false;
  bool _biometricEnabled = false;
  bool _isLocked = false;
  bool _loaded = false;
  /// Grace period before re-locking after the app is backgrounded.
  ///
  /// Defaults to 1 minute, NOT 0. With 0 the app re-locked on any momentary
  /// pause — the notification shade, a system dialog, a two-second glance at
  /// another app — so users were typing their PIN constantly and the lock
  /// became an obstacle rather than protection. A minute still locks when the
  /// phone is put down or the app is genuinely left, which is the threat this
  /// guards against. Users who want instant locking can still choose 0.
  int _timeoutMinutes = 1;
  DateTime? _backgroundedAt;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  bool get isEnabled => _isEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get isLocked => _isLocked;
  bool get isLoaded => _loaded;
  int get timeoutMinutes => _timeoutMinutes;
  int get failedAttempts => _failedAttempts;

  /// True while the user must wait before trying another PIN.
  bool get isInCooldown =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  /// Seconds left on the current cooldown (0 when not cooling down).
  int get cooldownSecondsLeft {
    if (_lockoutUntil == null) return 0;
    final left = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  /// Wrong guesses remaining before the next cooldown kicks in.
  int get attemptsRemaining {
    final left = freeAttempts - _failedAttempts;
    return left > 0 ? left : 0;
  }

  AppLockProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;
      _biometricEnabled = prefs.getBool(_biometricKey) ?? false;
      _timeoutMinutes = prefs.getInt(_timeoutKey) ?? 1;
      // Failed attempts and any active cooldown are PERSISTED, otherwise
      // force-quitting the app would reset the counter and defeat the limit.
      _failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
      final until = prefs.getInt(_lockoutUntilKey);
      if (until != null) {
        final when = DateTime.fromMillisecondsSinceEpoch(until);
        if (DateTime.now().isBefore(when)) _lockoutUntil = when;
      }
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

  /// Check a PIN and track failed attempts. Returns false while a cooldown
  /// is active, without even testing the PIN.
  Future<bool> verifyPin(String pin) async {
    if (isInCooldown) return false;

    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_pinSaltKey);
    final stored = prefs.getString(_pinHashKey);
    if (salt == null || stored == null) return false;

    final ok = _hash(pin, salt) == stored;
    if (ok) {
      await _resetAttempts(prefs);
    } else {
      await _recordFailure(prefs);
    }
    return ok;
  }

  Future<void> _recordFailure(SharedPreferences prefs) async {
    _failedAttempts++;
    await prefs.setInt(_failedAttemptsKey, _failedAttempts);

    if (_failedAttempts > freeAttempts) {
      // Pick an escalating penalty, capped at the longest one.
      final index = (_failedAttempts - freeAttempts - 1)
          .clamp(0, _cooldownSeconds.length - 1);
      final seconds = _cooldownSeconds[index];
      _lockoutUntil = DateTime.now().add(Duration(seconds: seconds));
      await prefs.setInt(
          _lockoutUntilKey, _lockoutUntil!.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  Future<void> _resetAttempts(SharedPreferences prefs) async {
    _failedAttempts = 0;
    _lockoutUntil = null;
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lockoutUntilKey);
    notifyListeners();
  }

  /// Clear a finished cooldown so the UI updates when the timer runs out.
  Future<void> refreshCooldown() async {
    if (_lockoutUntil != null && DateTime.now().isAfter(_lockoutUntil!)) {
      final prefs = await SharedPreferences.getInstance();
      _lockoutUntil = null;
      await prefs.remove(_lockoutUntilKey);
      notifyListeners();
    }
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

  /// Set while the app deliberately shows a system UI (permission prompts,
  /// the biometric sheet, a settings screen). Android reports these as the
  /// app leaving the foreground, but the user never actually left — locking
  /// them out mid-flow makes the app look broken.
  bool _suppressLock = false;

  /// Wrap any action that hands control to a system dialog.
  Future<T> withoutLocking<T>(Future<T> Function() action) async {
    _suppressLock = true;
    try {
      return await action();
    } finally {
      // Stay suppressed briefly after returning, so the resume event that
      // follows the dialog is ignored too.
      Future.delayed(const Duration(milliseconds: 1200), () {
        _suppressLock = false;
      });
    }
  }

  /// Called when the app goes to the background — start the timeout clock.
  void onPaused() {
    if (!_isEnabled || _suppressLock) return;
    _backgroundedAt = DateTime.now();
  }

  /// Called when the app returns. Re-locks if the configured grace period
  /// has elapsed (0 minutes = always lock).
  void onResumed() {
    if (!_isEnabled || _isLocked || _suppressLock) return;
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
