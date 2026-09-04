import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_lock_provider.dart';
import '../screens/lock/pin_screen.dart';
import '../theme/app_theme.dart';

/// One-time invitation to turn on the app lock.
///
/// Deliberately a gentle prompt rather than a forced step: making security
/// mandatory at sign-up adds friction and people abandon onboarding, while
/// burying it in Settings means nobody discovers it. So it's offered once,
/// dismissible, and never shown again — it stays available in Settings.
class AppLockPrompt {
  static const _shownKey = 'app_lock_prompt_shown';

  /// Show the prompt if the lock isn't already on and we haven't asked before.
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shownKey) ?? false) return;

    if (!context.mounted) return;
    final lock = context.read<AppLockProvider>();

    // The provider loads its saved state asynchronously, and this runs
    // moments after launch — so isLoaded was usually still false here and the
    // prompt silently never appeared. Wait briefly for it to settle instead
    // of giving up on the first frame.
    for (var i = 0; i < 20 && !lock.isLoaded; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!context.mounted) return;
    }

    if (!lock.isLoaded || lock.isEnabled) return;

    // Mark as asked straight away, so it never appears twice even if the
    // user dismisses by tapping outside.
    await prefs.setBool(_shownKey, true);

    if (!context.mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  size: 30, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 18),
            const Text(
              'Protect your finances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add a PIN so only you can open FinWise. Signing in keeps you '
              'logged in, so without a lock anyone holding your phone could '
              'see your balance and transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Set up PIN'),
          ),
        ],
      ),
    );

    if (enable != true || !context.mounted) return;

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PinScreen(mode: PinMode.setup)),
    );

    if (created == true && context.mounted) {
      final lock = context.read<AppLockProvider>();
      if (await lock.canUseBiometrics()) {
        await lock.setBiometricEnabled(true);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App lock is on')),
        );
      }
    }
  }
}
