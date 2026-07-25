import 'package:flutter/material.dart';
import '../services/sms_listener_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return SwitchListTile(
      title: const Text('Auto-detect Mobile Money transactions'),
      subtitle: const Text(
        'Beta — reads MoMo/Airtel SMS on this device and saves transactions '
        'straight to your balance and history automatically. Nothing leaves '
        'your phone. Shows a persistent notification while on, so Android '
        'keeps watching for SMS even when you\'re in another app.',
      ),
      value: _enabled,
      onChanged: _onChanged,
      secondary: const Icon(Icons.sms_outlined),
    );
  }
}
