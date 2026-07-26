import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_lock_provider.dart';
import '../screens/lock/pin_screen.dart';
import '../theme/app_theme.dart';

/// Settings controls for the app lock: enable/disable, biometric unlock,
/// auto-lock timing, and changing the PIN.
class AppLockTile extends StatelessWidget {
  const AppLockTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLockProvider>(
      builder: (context, lock, _) {
        if (!lock.isLoaded) return const SizedBox.shrink();

        return Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline,
                  color: AppTheme.primaryColor),
              title: const Text('App lock'),
              subtitle: Text(
                lock.isEnabled
                    ? 'FinWise asks for your PIN when opened'
                    : 'Require a PIN to open FinWise',
                style: const TextStyle(fontSize: 12),
              ),
              value: lock.isEnabled,
              onChanged: (value) => value
                  ? _enable(context)
                  : _disable(context, lock),
            ),
            if (lock.isEnabled) ...[
              FutureBuilder<bool>(
                future: lock.canUseBiometrics(),
                builder: (context, snapshot) {
                  final available = snapshot.data ?? false;
                  return SwitchListTile(
                    secondary: const Icon(Icons.fingerprint,
                        color: AppTheme.primaryColor),
                    title: const Text('Unlock with fingerprint'),
                    subtitle: Text(
                      available
                          ? 'Use your fingerprint or face instead of the PIN'
                          : 'No fingerprint or face set up on this phone',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: lock.biometricEnabled && available,
                    onChanged: available
                        ? (v) => lock.setBiometricEnabled(v)
                        : null,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined,
                    color: AppTheme.primaryColor),
                title: const Text('Lock after'),
                subtitle: Text(
                  lock.timeoutMinutes == 0
                      ? 'Immediately when you leave the app'
                      : 'After ${lock.timeoutMinutes} minute${lock.timeoutMinutes == 1 ? '' : 's'} away',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: DropdownButton<int>(
                  value: lock.timeoutMinutes,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Instant')),
                    DropdownMenuItem(value: 1, child: Text('1 min')),
                    DropdownMenuItem(value: 5, child: Text('5 min')),
                    DropdownMenuItem(value: 15, child: Text('15 min')),
                  ],
                  onChanged: (v) {
                    if (v != null) lock.setTimeout(v);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.password_outlined,
                    color: AppTheme.primaryColor),
                title: const Text('Change PIN'),
                subtitle: const Text('Set a new 4-digit PIN',
                    style: TextStyle(fontSize: 12)),
                onTap: () => _changePin(context),
              ),
              ListTile(
                leading: const Icon(Icons.lock_clock_outlined,
                    color: AppTheme.primaryColor),
                title: const Text('Lock now'),
                subtitle: const Text('Immediately require the PIN',
                    style: TextStyle(fontSize: 12)),
                onTap: () => lock.lockNow(),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _enable(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PinScreen(mode: PinMode.setup)),
    );
    if (result == true && context.mounted) {
      final lock = context.read<AppLockProvider>();
      // Offer biometrics straight away if the phone supports it.
      if (await lock.canUseBiometrics() && context.mounted) {
        final useBio = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Use fingerprint?'),
            content: const Text(
              'Unlock FinWise with your fingerprint or face instead of typing '
              'the PIN each time. Your PIN still works as a backup.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Not now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );
        if (useBio == true) await lock.setBiometricEnabled(true);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App lock is on')),
        );
      }
    }
  }

  Future<void> _disable(BuildContext context, AppLockProvider lock) async {
    // Require the current PIN before turning protection off.
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.verify,
          title: 'Turn off app lock',
        ),
      ),
    );
    if (ok == true) {
      await lock.disableLock();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App lock turned off')),
        );
      }
    }
  }

  Future<void> _changePin(BuildContext context) async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.verify,
          title: 'Enter current PIN',
        ),
      ),
    );
    if (verified == true && context.mounted) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const PinScreen(
            mode: PinMode.setup,
            title: 'Set a new PIN',
          ),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN updated')),
        );
      }
    }
  }
}
