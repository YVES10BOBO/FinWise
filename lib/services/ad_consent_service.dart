import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Owns AdMob consent state so no ad request can happen before UMP allows it.
class AdConsentService {
  AdConsentService._();

  static final ValueNotifier<bool> adsAllowed = ValueNotifier(false);
  static final ValueNotifier<bool> privacyOptionsRequired =
      ValueNotifier(false);
  static Future<void>? _initialization;
  static Future<void>? _adsSdkInitialization;

  static Future<void> initialize() => _initialization ??= _initializeOnce();

  static Future<void> _initializeOnce() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final completed = Completer<void>();

      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => unawaited(_finishConsentUpdate(completed, showForm: true)),
        (error) {
          debugPrint('Ad consent info update failed: ${error.message}');
          unawaited(_finishConsentUpdate(completed, showForm: false));
        },
      );

      await completed.future;
    } catch (error, stackTrace) {
      debugPrint('Ad consent setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _refreshConsentState();
    }
  }

  static Future<void> _finishConsentUpdate(
    Completer<void> completed, {
    required bool showForm,
  }) async {
    try {
      if (showForm) {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) {
            debugPrint('Ad consent form failed: ${error.message}');
          }
        });
      }
      await _refreshConsentState();
    } catch (error, stackTrace) {
      debugPrint('Ad consent form setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _refreshConsentState();
    } finally {
      if (!completed.isCompleted) completed.complete();
    }
  }

  static Future<void> _refreshConsentState() async {
    try {
      final canRequestAds = await ConsentInformation.instance.canRequestAds();
      if (canRequestAds) {
        _adsSdkInitialization ??= MobileAds.instance.initialize().then((_) {});
        await _adsSdkInitialization;
      }
      adsAllowed.value = canRequestAds;
      privacyOptionsRequired.value = await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      debugPrint('Could not read ad consent state: $error');
    }
  }

  static Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          debugPrint('Ad privacy options failed: ${error.message}');
        }
      });
      await _refreshConsentState();
    } catch (error) {
      debugPrint('Could not show ad privacy options: $error');
    }
  }
}
