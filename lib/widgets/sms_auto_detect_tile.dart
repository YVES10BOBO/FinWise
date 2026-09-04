import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sms_listener_service.dart';
import '../services/foreground_service_handler.dart';
import '../theme/app_theme.dart';

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
      final granted = await SmsListenerService.requestPermissionAndEnable();
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
              title: const Text('SMS permission is blocked'),
              content: const Text(
                'Android has stopped asking because the permission was '
                'declined before. To turn auto-detect on, allow SMS for '
                'FinWise in your phone settings:\n\n'
                'Permissions → SMS → Allow',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Not now'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: const Text('Open settings'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'SMS permission was not granted, so auto-detect stays off.',
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
              title: 'SMS permission not granted',
              message: status.isPermanentlyDenied
                  ? 'Android has blocked this permission because it was '
                      'declined before, so the switch above can\'t turn it on. '
                      'Allow SMS for FinWise in phone settings, then come back.'
                  : 'Auto-detect needs permission to read Mobile Money '
                      'messages. Turn the switch on to grant it.',
              actionLabel:
                  status.isPermanentlyDenied ? 'Open phone settings' : null,
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
            title: 'Auto-detect has stopped working',
            message:
                'Messages haven\'t been checked in over a day. Turn the switch '
                'off and on again to re-grant SMS permission, and make sure '
                'FinWise isn\'t battery-restricted.',
            actionLabel: health.batteryOptimized ? 'Fix battery settings' : null,
            onAction: health.batteryOptimized ? _openBatterySettings : null,
          );
        }

        if (health.isQuiet) {
          return _StatusTile(
            icon: Icons.warning_amber_outlined,
            color: AppTheme.accentDark,
            title: 'Nothing detected in a while',
            message:
                'Last transaction detected ${_ago(health.lastDetection!)}. '
                'If you have used Mobile Money since then, check that FinWise '
                'still has SMS permission and is not battery-restricted.',
            actionLabel:
                health.batteryOptimized ? 'Fix battery settings' : null,
            onAction: health.batteryOptimized ? _openBatterySettings : null,
          );
        }

        // Healthy — say so plainly. Knowing it IS working is as useful as
        // knowing it isn't.
        final detail = health.lastDetection != null
            ? 'Last transaction detected ${_ago(health.lastDetection!)}.'
            : health.isScanningRecently
                ? 'Watching for Mobile Money messages. Nothing detected yet.'
                : 'Waiting for the first Mobile Money message.';

        return Column(
          children: [
            _StatusTile(
              icon: Icons.check_circle_outline,
              color: AppTheme.incomeColor,
              title: 'Auto-detect is working',
              message: detail,
            ),
            if (health.batteryOptimized)
              _StatusTile(
                icon: Icons.battery_saver,
                color: AppTheme.accentDark,
                title: 'Improve background detection',
                message:
                    'Android may delay detection to save battery. Mark FinWise '
                    'as "Unrestricted" so messages are picked up promptly.',
                actionLabel: 'Open phone settings',
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
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  Widget _buildToggle(BuildContext context) {
    return SwitchListTile(
      title: const Text('Auto-detect Mobile Money transactions'),
      subtitle: const Text(
        'Reads MoMo and bank SMS on this device and records transactions '
        'automatically. Message content never leaves your phone. A permanent '
        'notification is shown while this is on, so Android keeps detecting '
        'even when you\'re in another app.',
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
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onAction,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.open_in_new, size: 13, color: color),
                        ],
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
