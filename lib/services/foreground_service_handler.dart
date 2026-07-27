import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'sms_listener_service.dart';

/// Keeps FinWise's Android process alive (via a required, visible
/// notification) while SMS auto-detect is on. This doesn't do the SMS
/// reading itself — that's still handled by the `telephony` package — it
/// just makes the whole app process a much lower target for Android/OEM
/// battery managers to kill, which is what actually causes background SMS
/// detection to be missed on phones like Samsung's.
///
/// The notification is required by Android for any foreground service —
/// it cannot be hidden. It says "FinWise is monitoring for Mobile Money
/// transactions" so it's always clear to the user why it's there.

/// Top-level callback required by flutter_foreground_task — must stay a
/// top-level (or static) function, not a class method.
@pragma('vm:entry-point')
void smsMonitorServiceCallback() {
  FlutterForegroundTask.setTaskHandler(_SmsMonitorTaskHandler());
}

/// Minimal task handler. It doesn't need to do periodic work itself —
/// `telephony`'s own SMS receiver does the actual detection — this only
/// needs to exist so the OS treats FinWise's process as an active
/// foreground service instead of a killable background app.
class _SmsMonitorTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Runs in the foreground-service isolate, which Android keeps alive even
    // when FinWise is backgrounded or the screen is off. Poll the SMS inbox
    // here so Mobile Money messages are detected and recorded in near real
    // time regardless of app state — instead of only when the user reopens
    // the app. De-dup (by the SMS's transaction id) means overlap with the
    // in-app poll can never double-record. Fire-and-forget; errors are
    // swallowed inside pollInboxForNew.
    SmsListenerService.pollInboxForNew();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

class ForegroundServiceHandler {
  /// Call once at app startup, before starting/stopping the service.
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'finwise_sms_monitor',
        channelName: 'Mobile Money monitoring',
        channelDescription:
            'Shown while FinWise is watching for Mobile Money SMS to auto-track your transactions.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // Poll the inbox every 15s from the always-alive service isolate so
        // background detection is near real time, not "whenever the app is
        // reopened". Needs the wake lock so the timer still fires with the
        // screen off.
        eventAction: ForegroundTaskEventAction.repeat(15000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Notification permission only — an ordinary in-app dialog on Android 13+.
  /// Safe to call during startup.
  ///
  /// Battery-optimization exemption is deliberately NOT requested here: it
  /// launches a system settings screen, which throws the user out of the app
  /// mid-onboarding and looks like a crash. It's offered separately from
  /// Settings instead — see [requestBatteryExemption].
  static Future<void> requestPermissions() async {
    try {
      final notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
        // Give Android time to deliver the result and resume the activity
        // before anything else runs.
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FinWise: notification permission request failed: $e');
      }
    }
  }

  /// True when Android won't throttle the app in the background.
  static Future<bool> get isBatteryOptimized async {
    if (!Platform.isAndroid) return false;
    return !(await FlutterForegroundTask.isIgnoringBatteryOptimizations);
  }

  /// Opens the system screen where the user can mark FinWise "Unrestricted".
  /// Only call this from an explicit user action — it leaves the app.
  static Future<void> requestBatteryExemption() async {
    if (!Platform.isAndroid) return;
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations) return;
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  /// Start the monitoring service.
  ///
  /// Never throws. Starting a foreground service immediately after a
  /// permission dialog is dismissed can fail (Android is mid-transition, or
  /// the notification permission state hasn't propagated yet) — and an
  /// uncaught error here took the whole app down on first run. A short settle
  /// delay plus swallowing failures keeps the app alive; detection still works
  /// through the in-app poll even if the service didn't start.
  static Future<void> start() async {
    try {
      // Let any permission dialog finish dismissing before Android is asked
      // to promote us to a foreground service.
      await Future.delayed(const Duration(milliseconds: 400));

      if (await FlutterForegroundTask.isRunningService) return;

      await FlutterForegroundTask.startService(
        serviceId: 257,
        notificationTitle: 'FinWise is monitoring for transactions',
        notificationText:
            'Mobile Money SMS auto-detect is on. Tap to open FinWise.',
        callback: smsMonitorServiceCallback,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FinWise: foreground service failed to start: $e');
      }
      // Non-fatal — the app keeps working without it.
    }
  }

  static Future<ServiceRequestResult> stop() {
    return FlutterForegroundTask.stopService();
  }

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;
}
