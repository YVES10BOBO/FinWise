import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_lock_provider.dart';
import '../screens/lock/pin_screen.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

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
              title: Text(context.l10n.appLock),
              subtitle: Text(
                lock.isEnabled
                    ? context.l10n.appLockOnSub
                    : context.l10n.appLockOffSub,
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
                    title: Text(context.l10n.unlockFingerprint),
                    subtitle: Text(
                      available
                          ? context.l10n.fingerprintSub
                          : context.l10n.noFingerprint,
                      style: TextStyle(fontSize: 12),
                    ),
                    value: lock.biometricEnabled && available,
                    onChanged: available
                        ? (v) => lock.setBiometricEnabled(v)
                        : null,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.timer_outlined,
                    color: AppTheme.primaryColor),
                title: Text(context.l10n.lockAfter),
                subtitle: Text(
                  lock.timeoutMinutes == 0
                      ? context.l10n.lockImmediately
                      : context.l10n.lockAfterMinutes(lock.timeoutMinutes),
                  style: TextStyle(fontSize: 12),
                ),
                trailing: DropdownButton<int>(
                  value: lock.timeoutMinutes,
                  underline: SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 0, child: Text(context.l10n.instant)),
                    DropdownMenuItem(value: 1, child: Text(context.l10n.minShort(1))),
                    DropdownMenuItem(value: 5, child: Text(context.l10n.minShort(5))),
                    DropdownMenuItem(value: 15, child: Text(context.l10n.minShort(15))),
                  ],
                  onChanged: (v) {
                    if (v != null) lock.setTimeout(v);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.password_outlined,
                    color: AppTheme.primaryColor),
                title: Text(context.l10n.changePin),
                subtitle: Text(context.l10n.changePinSub,
                    style: TextStyle(fontSize: 12)),
                onTap: () => _changePin(context),
              ),
              ListTile(
                leading: const Icon(Icons.lock_clock_outlined,
                    color: AppTheme.primaryColor),
                title: Text(context.l10n.lockNow),
                subtitle: Text(context.l10n.lockNowSub,
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
            title: Text(context.l10n.useFingerprintQ),
            content: Text(
              context.l10n.useFingerprintBody,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.notNow),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.enable),
              ),
            ],
          ),
        );
        if (useBio == true) await lock.setBiometricEnabled(true);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.appLockOn)),
        );
      }
    }
  }

  Future<void> _disable(BuildContext context, AppLockProvider lock) async {
    // Require the current PIN before turning protection off.
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PinScreen(
          mode: PinMode.verify,
          title: context.l10n.turnOffLock,
        ),
      ),
    );
    if (ok == true) {
      await lock.disableLock();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.lockTurnedOff)),
        );
      }
    }
  }

  Future<void> _changePin(BuildContext context) async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PinScreen(
          mode: PinMode.verify,
          title: context.l10n.enterCurrentPinTitle,
        ),
      ),
    );
    if (verified == true && context.mounted) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PinScreen(
            mode: PinMode.setup,
            title: context.l10n.setNewPin,
          ),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.pinUpdated)),
        );
      }
    }
  }
}
