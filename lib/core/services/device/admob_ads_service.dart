import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads_service.dart';

/// Google's public TEST adaptive-banner ad unit id.
///
/// One of Google's own [sample ad units](https://developers.google.com/admob/android/test-ads#sample_ad_units),
/// for every build that must never request a real ad: the app's entry point
/// passes its own unit only to a release build.
const String testAdaptiveBannerAdUnitId =
    'ca-app-pub-3940256099942544/9214589741';

/// The dp height to reserve for [size] (ADS-4).
///
/// [size] is `null` when the platform couldn't compute an adaptive size yet,
/// for example off Android or before Play Services answers; [fallbackHeight]
/// (the standard banner height) is reserved instead, so the slot never
/// collapses to zero while that's being worked out.
double heightFromAdaptiveSize(AdSize? size, {double fallbackHeight = 50}) =>
    size == null ? fallbackHeight : size.height.toDouble();

/// The ad request for a banner, from whether it may be personalised (ADS-5).
///
/// [personalized] false sets AdMob's own `nonPersonalizedAds` flag, the
/// documented way to ask for a non-personalised request
/// (https://support.google.com/admob/answer/7676680).
AdRequest buildBannerAdRequest({required bool personalized}) =>
    AdRequest(nonPersonalizedAds: !personalized);

/// Adaptive banner ads through `google_mobile_ads` (ADS-2).
///
/// Only [BannerAd] and [AdSize]'s anchored-adaptive sizing are used anywhere
/// in this file: no interstitial, app-open, rewarded or native ad type is
/// imported, referenced or requested, on purpose (ADS-2). [bannerHeight] asks
/// the SDK for the height a banner at [widthDp] will take without loading
/// anything, so a caller can reserve the space first (ADS-4); [loadBanner]
/// then requests the ad itself, and [bannerFor] hands back a widget only once
/// it has actually loaded, so a still-loading or failed slot never mounts a
/// half-built platform view.
///
/// Built only by the app's entry point.
class AdmobAdsService implements AdsService {
  AdmobAdsService({this.adUnitId = testAdaptiveBannerAdUnitId});

  /// The banner ad unit requested for every slot.
  final String adUnitId;

  /// The banner that finished loading for each slot, keyed by [loadBanner]'s
  /// `slot`. A slot only appears here once its [onAdLoaded] listener has
  /// fired for the banner currently tracked for it (never for one a newer
  /// [loadBanner] call already superseded).
  final Map<String, BannerAd> _loadedBanners = <String, BannerAd>{};

  /// The banner in flight for each slot, loaded or not: what [disposeBanner]
  /// frees, and what a load callback checks itself against to ignore a stale
  /// callback from a request [loadBanner] has since replaced.
  final Map<String, BannerAd> _pendingBanners = <String, BannerAd>{};

  /// The SDK's one start-up, shared by every caller.
  Future<void>? _started;

  /// Starts the Mobile Ads SDK once, however often it is called.
  ///
  /// [loadBanner] calls this itself, so the SDK first starts when a banner is
  /// actually requested: after the first success (ADS-6), with consent
  /// resolved (ADS-5), and never for a Pro owner (ADS-7). The app's entry
  /// point does not start it.
  @override
  Future<void> initialize() =>
      _started ??= MobileAds.instance.initialize().then((_) {});

  @override
  Future<double> bannerHeight({required double widthDp}) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthDp.round());
    return heightFromAdaptiveSize(size);
  }

  @override
  Future<bool> loadBanner({
    required String slot,
    required double widthDp,
    required bool personalized,
  }) async {
    await disposeBanner(slot);
    try {
      await initialize();
    } on Object {
      // Let the next request try again.
      _started = null;
      return false;
    }
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthDp.round());
    final Completer<bool> loaded = Completer<bool>();
    final BannerAd banner = BannerAd(
      adUnitId: adUnitId,
      size: size ?? AdSize.banner,
      request: buildBannerAdRequest(personalized: personalized),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (identical(_pendingBanners[slot], ad)) {
            _pendingBanners.remove(slot);
            _loadedBanners[slot] = ad as BannerAd;
          } else {
            unawaited(ad.dispose());
          }
          if (!loaded.isCompleted) {
            loaded.complete(true);
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (identical(_pendingBanners[slot], ad)) {
            _pendingBanners.remove(slot);
          }
          unawaited(ad.dispose());
          if (!loaded.isCompleted) {
            loaded.complete(false);
          }
        },
      ),
    );
    _pendingBanners[slot] = banner;
    await banner.load();
    return loaded.future;
  }

  @override
  Widget? bannerFor(String slot) {
    final BannerAd? banner = _loadedBanners[slot];
    return banner == null ? null : AdWidget(ad: banner);
  }

  @override
  Future<void> disposeBanner(String slot) async {
    final BannerAd? pending = _pendingBanners.remove(slot);
    final BannerAd? loaded = _loadedBanners.remove(slot);
    await pending?.dispose();
    await loaded?.dispose();
  }
}
