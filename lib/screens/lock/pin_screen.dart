import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/app_lock_provider.dart';
import '../../theme/app_theme.dart';

enum PinMode {
  /// Choose a new PIN (then confirm it).
  setup,

  /// Enter the existing PIN to unlock the app.
  unlock,

  /// Enter the existing PIN to authorise a change (e.g. turning the lock off).
  verify,
}

/// PIN keypad used for setting, confirming, and entering the app lock PIN.
class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? title;

  /// Called with the PIN once it is accepted. For [PinMode.unlock] the screen
  /// closes itself; for the others the caller decides what happens next.
  final void Function(String pin)? onSuccess;

  const PinScreen({
    super.key,
    required this.mode,
    this.title,
    this.onSuccess,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const int _pinLength = 4;

  String _entry = '';
  String? _firstEntry; // setup: the PIN awaiting confirmation
  String? _error;
  bool _busy = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinMode.unlock) {
      // Offer biometrics immediately so the common case is one touch.
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
    }
    // Ticks once a second so the "try again in Xs" countdown stays live.
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final lock = context.read<AppLockProvider>();
      if (lock.isInCooldown) {
        setState(() {}); // redraw the countdown
      } else if (lock.cooldownSecondsLeft == 0) {
        lock.refreshCooldown();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    final lock = context.read<AppLockProvider>();
    if (!lock.biometricEnabled) return;
    if (!await lock.canUseBiometrics()) return;

    // The biometric sheet is system UI — don't let it re-trigger the lock.
    final ok = await lock.withoutLocking(lock.authenticateWithBiometrics);
    if (ok && mounted) {
      lock.unlock();
    }
  }

  void _onDigit(String d) {
    if (_busy || _entry.length >= _pinLength) return;
    // Ignore input entirely while cooling down.
    if (context.read<AppLockProvider>().isInCooldown) return;
    HapticFeedback.selectionClick();
    setState(() {
      _entry += d;
      _error = null;
    });
    if (_entry.length == _pinLength) _submit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final lock = context.read<AppLockProvider>();
    final entered = _entry;

    // Small pause so the last dot is visible before the screen reacts.
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    switch (widget.mode) {
      case PinMode.setup:
        if (_firstEntry == null) {
          setState(() {
            _firstEntry = entered;
            _entry = '';
            _busy = false;
          });
        } else if (_firstEntry == entered) {
          await lock.setPin(entered);
          if (!mounted) return;
          widget.onSuccess?.call(entered);
          if (mounted) Navigator.of(context).pop(true);
        } else {
          _fail('PINs did not match. Start again.');
          setState(() => _firstEntry = null);
        }
        break;

      case PinMode.unlock:
      case PinMode.verify:
        final ok = await lock.verifyPin(entered);
        if (!mounted) return;
        if (ok) {
          if (widget.mode == PinMode.unlock) {
            lock.unlock();
          } else {
            widget.onSuccess?.call(entered);
            Navigator.of(context).pop(true);
          }
        } else if (lock.isInCooldown) {
          _fail('Too many attempts. Please wait.');
        } else {
          final left = lock.attemptsRemaining;
          _fail(left <= 2
              ? 'Incorrect PIN. $left ${left == 1 ? 'try' : 'tries'} left before a wait.'
              : 'Incorrect PIN. Try again.');
        }
        break;
    }
  }

  void _fail(String message) {
    HapticFeedback.vibrate();
    setState(() {
      _entry = '';
      _error = message;
      _busy = false;
    });
  }

  String get _heading {
    if (widget.title != null) return widget.title!;
    switch (widget.mode) {
      case PinMode.setup:
        return _firstEntry == null ? 'Create a PIN' : 'Confirm your PIN';
      case PinMode.unlock:
        return 'Enter your PIN';
      case PinMode.verify:
        return 'Confirm it\'s you';
    }
  }

  String get _sub {
    switch (widget.mode) {
      case PinMode.setup:
        return _firstEntry == null
            ? 'You\'ll use this to open FinWise'
            : 'Enter the same 4 digits again';
      case PinMode.unlock:
        return 'Your finances are locked';
      case PinMode.verify:
        return 'Enter your current PIN to continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = context.watch<AppLockProvider>();
    final cooling = lock.isInCooldown;
    // Fingerprint stays available during a cooldown: it can't be brute-forced,
    // so blocking it would only punish the real owner while doing nothing for
    // security. Only PIN typing is rate-limited.
    final showBiometricButton =
        widget.mode == PinMode.unlock && lock.biometricEnabled;

    return PopScope(
      // Don't let the user swipe past the unlock screen.
      canPop: widget.mode != PinMode.unlock,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.mode != PinMode.unlock)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                )
              else
                const SizedBox(height: 48),

              const Spacer(flex: 1),

              // Lock badge
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline,
                    size: 34, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 22),
              Text(
                _heading,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _sub,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 28),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _entry.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: _error != null
                            ? AppTheme.expenseColor
                            : (filled
                                ? AppTheme.primaryColor
                                : Colors.grey[400]!),
                        width: 1.6,
                      ),
                    ),
                  );
                }),
              ),

              // Single plain error line — same style whether it's a wrong
              // PIN or the wait countdown.
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    cooling
                        ? 'Too many attempts. Try again in ${_formatCountdown(lock.cooldownSecondsLeft)}'
                        : (_error ?? ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.expenseColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Digits dim and stop responding while cooling down; the
                    // fingerprint key stays fully active below.
                    Opacity(
                      opacity: cooling ? 0.35 : 1,
                      child: Column(
                        children: [
                          for (final row in const [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                          ])
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: row.map(_digitKey).toList(),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        showBiometricButton
                            ? _iconKey(Icons.fingerprint, _tryBiometrics)
                            : const SizedBox(width: 72, height: 72),
                        Opacity(
                          opacity: cooling ? 0.35 : 1,
                          child: _digitKey('0'),
                        ),
                        Opacity(
                          opacity: cooling ? 0.35 : 1,
                          child: _iconKey(
                              Icons.backspace_outlined, _onBackspace),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Forgot PIN — only on the unlock screen.
              if (widget.mode == PinMode.unlock)
                TextButton(
                  onPressed: () => _forgotPin(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                  ),
                  child: const Text(
                    'Forgot PIN?',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                )
              else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// The only safe reset: prove you own the account. Signing out clears the
  /// lock, and signing back in needs the Firebase email + password (which can
  /// itself be recovered by email). Your data is untouched — it syncs back.
  Future<void> _forgotPin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot your PIN?'),
        content: const Text(
          'To reset it, sign in again with your email and password.\n\n'
          'You will be signed out and the app lock removed. Your transactions '
          'and goals are safe — they sync back as soon as you sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.expenseColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out & reset'),
          ),
        ],
      ),
    );

    // Check the passed-in context, not just State.mounted — they can differ.
    if (confirmed != true || !context.mounted) return;

    final lock = context.read<AppLockProvider>();
    await lock.disableLock();
    await FirebaseAuth.instance.signOut();
    lock.unlock();
  }

  /// "45s" or "2:05" for longer waits.
  String _formatCountdown(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _digitKey(String d) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onDigit(d),
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 26, color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}
