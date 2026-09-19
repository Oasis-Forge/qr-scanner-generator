import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qrscanner/core/services/device/admob_ads_service.dart';

void main() {
  group('heightFromAdaptiveSize (ADS-4)', () {
    test('reports the adaptive size\'s own height when one was found', () {
      final AnchoredAdaptiveBannerAdSize size = AnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        width: 360,
        height: 78,
      );
      expect(heightFromAdaptiveSize(size), 78.0);
    });

    test('falls back to the standard banner height when the platform could '
        'not compute one, so a slot never collapses to zero', () {
      expect(heightFromAdaptiveSize(null), 50.0);
    });

    test('a custom fallback is honoured too', () {
      expect(heightFromAdaptiveSize(null, fallbackHeight: 90), 90.0);
    });
  });

  group('buildBannerAdRequest (ADS-5)', () {
    test('personalized true requests no non-personalised restriction', () {
      final AdRequest request = buildBannerAdRequest(personalized: true);
      expect(request.nonPersonalizedAds, isFalse);
    });

    test('personalized false sets AdMob\'s own non-personalised flag', () {
      final AdRequest request = buildBannerAdRequest(personalized: false);
      expect(request.nonPersonalizedAds, isTrue);
    });
  });

  group('AdmobAdsService (ADS-2)', () {
    test('never requests anything but a banner: the ad unit id is the '
        'only one this service knows about', () {
      final AdmobAdsService service = AdmobAdsService();
      expect(service.adUnitId, testAdaptiveBannerAdUnitId);
    });

    test('bannerFor reports nothing for a slot that was never loaded, so a '
        'screen reserving space with bannerHeight never renders a half '
        'built platform view (ADS-4)', () {
      final AdmobAdsService service = AdmobAdsService();
      expect(service.bannerFor('settings'), isNull);
    });
  });
}
