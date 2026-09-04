import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// Key holding this phone's display name. Cached in SharedPreferences so the
/// SMS background isolate can read it without touching platform channels —
/// plugin calls are unreliable in a fresh isolate, and a transaction must
/// never fail to record just because we couldn't name the device.
const String kDeviceNameKey = 'device_display_name';

/// Names the phone a transaction was recorded on.
///
/// Several devices can be signed into one account, and each reads its OWN
/// SMS inbox into that shared account. Without this, a transaction created
/// on another phone appears with no explanation — which is exactly what
/// happened during testing and looked like a parser bug. Tagging doesn't
/// prevent it; it makes it identifiable, so a foreign entry can be
/// recognised and deleted.
class DeviceIdentityService {
  /// Resolve and cache the device name. Call once at startup, from the main
  /// isolate, where platform channels work.
  static Future<void> ensureResolved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getString(kDeviceNameKey) ?? '').isNotEmpty) return;

      final name = await _readDeviceName();
      await prefs.setString(kDeviceNameKey, name);
    } catch (e) {
      if (kDebugMode) debugPrint('FinWise: could not resolve device name: $e');
      // Non-fatal — transactions simply go untagged.
    }
  }

  /// The cached name, or null when it couldn't be determined. Safe to call
  /// from any isolate: it only reads SharedPreferences.
  static Future<String?> currentName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final name = prefs.getString(kDeviceNameKey);
      return (name == null || name.isEmpty) ? null : name;
    } catch (_) {
      return null;
    }
  }

  /// Let the user rename their device, so "SM-A057F" can become "My phone".
  static Future<void> rename(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kDeviceNameKey, trimmed);
  }

  static Future<String> _readDeviceName() async {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      // Prefer the marketing name ("Galaxy A05s") over the model code
      // ("SM-A057F") — the point is that the user recognises which phone
      // this is at a glance.
      final label = android.model.trim();
      final brand = android.brand.trim();
      if (label.isEmpty) return brand.isEmpty ? 'Android phone' : brand;
      if (brand.isEmpty || label.toLowerCase().startsWith(brand.toLowerCase())) {
        return label;
      }
      return '$brand $label';
    }

    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      final name = ios.name.trim();
      return name.isEmpty ? 'iPhone' : name;
    }

    return 'This device';
  }
}
