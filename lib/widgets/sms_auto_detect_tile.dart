import 'package:flutter/material.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'SMS permission was not granted. You can enable it later from your phone\'s app settings.',
            ),
          ),
        );
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
        if (_enabled)
          FutureBuilder<bool>(
            future: ForegroundServiceHandler.isBatteryOptimized,
            builder: (context, snapshot) {
              // Only surface this when Android is actually throttling us.
              if (snapshot.data != true) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.battery_saver,
                    color: AppTheme.accentDark),
                title: const Text('Improve background detection'),
                subtitle: const Text(
                  'Android may delay detection to save battery. Tap to mark '
                  'FinWise as "Unrestricted" — this opens phone settings.',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: _openBatterySettings,
              );
            },
          ),
      ],
    );
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
