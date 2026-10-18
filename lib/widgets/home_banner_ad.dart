import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/l10n_helpers.dart';
import '../services/ad_consent_service.dart';
import '../theme/app_theme.dart';

/// One clearly labelled, non-blocking banner at the end of the Home feed.
class HomeBannerAd extends StatelessWidget {
  const HomeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdConsentService.adsAllowed,
      builder: (context, allowed, _) {
        if (!allowed ||
            kIsWeb ||
            defaultTargetPlatform != TargetPlatform.android) {
          return const SizedBox.shrink();
        }
        return const _LoadedHomeBannerAd();
      },
    );
  }
}

class _LoadedHomeBannerAd extends StatefulWidget {
  const _LoadedHomeBannerAd();

  @override
  State<_LoadedHomeBannerAd> createState() => _LoadedHomeBannerAdState();
}

class _LoadedHomeBannerAdState extends State<_LoadedHomeBannerAd> {
  static const _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _releaseBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-4250217374753571/4648083132',
  );

  BannerAd? _banner;
  bool _loaded = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_loading && _banner == null) {
          _loading = true;
          _loadBanner((constraints.maxWidth - 24).truncate());
        }

        final banner = _banner;
        if (!_loaded || banner == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.adLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: banner.size.width.toDouble(),
                height: banner.size.height.toDouble(),
                child: AdWidget(ad: banner),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadBanner(int width) async {
    final unitId = kDebugMode ? _testBannerId : _releaseBannerId;
    if (unitId.isEmpty || width <= 0) return;

    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      );
      if (!mounted || size == null) return;

      final banner = BannerAd(
        adUnitId: unitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        }, onAdFailedToLoad: (ad, error) {
          debugPrint('Home banner failed to load: $error');
          ad.dispose();
          if (identical(_banner, ad)) _banner = null;
          _loading = false;
        }),
      );
      _banner = banner;
      await banner.load();
    } catch (error) {
      debugPrint('Home banner setup failed: $error');
      _banner?.dispose();
      _banner = null;
      _loading = false;
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }
}
