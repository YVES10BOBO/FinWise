import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_lock_provider.dart';
import '../services/sms_listener_service.dart';
import '../services/foreground_service_handler.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

/// Settings toggle for the SMS auto-detection Beta feature.
/// Off by default. Turning it on triggers the Android SMS permission
/// prompt — nothing is read until the user grants it.
class SmsAutoDetectTile extends StatefulWidget {
  const SmsAutoDetectTile({super.key});

  @override
  State<SmsAutoDetectTile> createState() => _SmsAutoDetectTileState();
}

class _SmsAutoDetectTileState extends State<SmsAutoDetectTile> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool(kSmsAutoDetectEnabledKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (value) {
      // Suppress the auto-lock across the permission prompt. Android reports
      // the app as backgrounded while a system dialog is up, which the lock
      // read as "the user left" — so granting SMS permission instantly threw
      // up the PIN screen and looked exactly like the app closing and
      // restarting. Same guard the first-run flow already uses.
      final lock = context.read<AppLockProvider>();
      final granted = await lock.withoutLocking(
        () => SmsListenerService.requestPermissionAndEnable(),
      );
      if (!mounted) return;
      if (!granted) {
        // Android stops showing the permission dialog once it has been
        // refused twice — the request then returns "denied" instantly and
        // the toggle looks broken. In that state the ONLY way to grant it is
        // the system settings page, so say so and offer to open it.
        final permanentlyDenied =
            await Permission.sms.status.isPermanentlyDenied;
        if (!mounted) return;

        if (permanentlyDenied) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.l10n.smsBlocked),
              content: Text(
                context.l10n.smsBlockedBody,
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.notNow),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: Text(context.l10n.openSettings),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.smsNotGrantedOff,
              ),
            ),
          );
        }
        return;
      }
      setState(() => _enabled = true);
    } else {
      await SmsListenerService.disable();
      if (!mounted) return;
      setState(() => _enabled = false);
    }
  }

  /// Optional: send the user to the system screen where FinWise can be marked
  /// "Unrestricted". This LEAVES the app, so it is only ever triggered by an
  /// explicit tap — never automatically during onboarding.
  Future<void> _openBatterySettings() async {
    await ForegroundServiceHandler.requestBatteryExemption();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return Column(
      children: [
        _buildToggle(context),
        // Shown even when the toggle is OFF: if Android has blocked the SMS
        // permission, switching on silently does nothing, and without this
        // there is no way to find out why or how to fix it.
        FutureBuilder<PermissionStatus>(
          future: Permission.sms.status,
          builder: (context, snapshot) {
            final status = snapshot.data;
            if (status == null || status.isGranted) {
              return _enabled ? _buildHealth(context) : const SizedBox.shrink();
            }
            return _StatusTile(
              icon: Icons.lock_outline,
              color: AppTheme.expenseColor,
              title: context.l10n.smsNotGranted,
              message: status.isPermanentlyDenied
                  ? context.l10n.smsBlockedSwitch
                  : context.l10n.smsNeedsPermission,
              actionLabel:
                  status.isPermanentlyDenied ? context.l10n.openPhoneSettings : null,
              onAction: status.isPermanentlyDenied ? openAppSettings : null,
            );
          },
        ),
      ],
    );
  }

  /// Detection fails silently — no crash, no error, just a balance that
  /// quietly stops being true. This makes that visible.
  Widget _buildHealth(BuildContext context) {
    return FutureBuilder<SmsDetectionHealth>(
      future: SmsListenerService.health(),
      builder: (context, snapshot) {
        final health = snapshot.data;
        if (health == null) return const SizedBox.shrink();

        // Scanning has stopped — usually a revoked SMS permission or a
        // background service the OS killed. Both fail silently.
        if (health.isBroken) {
          return _StatusTile(
            icon: Icons.error_outline,
            color: AppTheme.expenseColor,
            title: context.l10n.autoDetectStopped,
            message:
                context.l10n.autoDetectStoppedBody,
            actionLabel: health.batteryOptimized ? context.l10n.fixBattery : null,
            onAction: health.batteryOptimized ? _openBatterySettings : null,
          );
        }

        if (health.isQuiet) {
          return _StatusTile(
            icon: Icons.warning_amber_outlined,
            color: AppTheme.accentDark,
            title: context.l10n.nothingDetected,
            message:
                context.l10n.lastDetectedCheck(_ago(health.lastDetection!)),
            actionLabel:
                health.batteryOptimized ? context.l10n.fixBattery : null,
            onAction: health.batteryOptimized ? _openBatterySettings : null,
          );
        }

        // Healthy — say so plainly. Knowing it IS working is as useful as
        // knowing it isn't.
        final detail = health.lastDetection != null
            ? context.l10n.lastDetected(_ago(health.lastDetection!))
            : health.isScanningRecently
                ? context.l10n.watchingNothingYet
                : context.l10n.waitingFirst;

        return Column(
          children: [
            _StatusTile(
              icon: Icons.check_circle_outline,
              color: AppTheme.incomeColor,
              title: context.l10n.autoDetectWorking,
              message: detail,
            ),
            if (health.batteryOptimized)
              _StatusTile(
                icon: Icons.battery_saver,
                color: AppTheme.accentDark,
                title: context.l10n.improveBackground,
                message:
                    context.l10n.improveBackgroundBody,
                actionLabel: context.l10n.openPhoneSettings,
                onAction: _openBatterySettings,
              ),
          ],
        );
      },
    );
  }

  /// "3 days ago" / "2 hours ago" — vague on purpose; precision isn't the
  /// point, noticing the gap is.
  String _ago(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 60) return context.l10n.minAgo(diff.inMinutes);
    if (diff.inHours < 24) {
      return context.l10n.hoursAgo(diff.inHours);
    }
    return context.l10n.daysAgo(diff.inDays);
  }

  Widget _buildToggle(BuildContext context) {
    return SwitchListTile(
      title: Text(context.l10n.autoDetectTitle),
      subtitle: Text(
        context.l10n.autoDetectSub,
        style: TextStyle(fontSize: 12),
      ),
      value: _enabled,
      onChanged: _onChanged,
      secondary: const Icon(Icons.sms_outlined),
    );
  }
}

/// One line of status about the detection pipeline, with an optional fix.
class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 8),
                    // A real button, not bare text: it gets a ripple, a
                    // border and a proper touch target, so it's obvious this
                    // is something you tap.
                    OutlinedButton.icon(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
