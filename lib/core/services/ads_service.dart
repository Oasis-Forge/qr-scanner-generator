import 'package:flutter/widgets.dart';

/// Adaptive banner ads.
///
/// Banners are the only ad format in this interface on purpose: no interstitial,
/// app-open, rewarded or native ad may ship (ADS-2), so none of them can be
/// asked for here. The caller decides where a banner may appear (ADS-1), holds
/// its height before it loads (ADS-4), requests none until consent is resolved
/// (ADS-5), none before the first successful scan or create (ADS-6), and none at
/// all for a Pro owner (ADS-7).
abstract class AdsService {
  /// Prepares the ad SDK. Requests no ad by itself.
  Future<void> initialize();

  /// The height in dp an adaptive banner will take at [widthDp].
  ///
  /// Asked before any request, so the space is reserved and a loading, failing
  /// or refreshing ad never moves a control (ADS-4).
  Future<double> bannerHeight({required double widthDp});

  /// Requests a banner for [slot] and reports whether one is ready to show.
  ///
  /// [slot] names the placement; ADS-1 allows only the History list, the top of
  /// Settings and the Create type picker. [personalized] comes from the consent
  /// state: where consent is refused, only non-personalised ads are requested
  /// (ADS-5).
  Future<bool> loadBanner({
    required String slot,
    required double widthDp,
    required bool personalized,
  });

  /// The loaded banner for [slot], or `null` while none is ready. The caller
  /// keeps the reserved height either way (ADS-4).
  Widget? bannerFor(String slot);

  /// Releases [slot]'s banner.
  Future<void> disposeBanner(String slot);
}

/// An [AdsService] that requests no ad and shows none.
///
/// [loadBanner] always reports that nothing is ready and [bannerFor] is always
/// `null`, so a test screen stays ad-free; [calls] records what the app asked
/// for, including whether the request would have been personalised (ADS-5), and
/// [requestedSlots] lists the placements a banner was requested for (ADS-1).
class NoopAdsService implements AdsService {
  NoopAdsService({this.reservedHeight = 50});

  /// Every call the app decides to make, in order, such as
  /// `'loadBanner: history (360.0 dp, personalized: false)'`.
  ///
  /// [bannerFor] is deliberately left out: a screen reads it on every frame, so
  /// recording it would make this list grow with the number of rebuilds instead
  /// of with what the app asked for.
  final List<String> calls = <String>[];

  /// One entry per [loadBanner] call, in order: the slot each banner was
  /// requested for.
  ///
  /// This is what a test asserts against to check a placement was asked for
  /// once, and that nothing asked outside ADS-1's three screens.
  final List<String> requestedSlots = <String>[];

  /// The height [bannerHeight] reports, without asking any SDK.
  final double reservedHeight;

  @override
  Future<void> initialize() async {
    calls.add('initialize');
  }

  @override
  Future<double> bannerHeight({required double widthDp}) async {
    calls.add('bannerHeight: $widthDp');
    return reservedHeight;
  }

  @override
  Future<bool> loadBanner({
    required String slot,
    required double widthDp,
    required bool personalized,
  }) async {
    calls.add('loadBanner: $slot ($widthDp dp, personalized: $personalized)');
    requestedSlots.add(slot);
    return false;
  }

  /// Always `null`, and records nothing: a screen reads this on every frame,
  /// and a fake that counted frames would tell a test nothing about what the
  /// app asked for. What was asked is in [calls] and [requestedSlots].
  @override
  Widget? bannerFor(String slot) => null;

  @override
  Future<void> disposeBanner(String slot) async {
    calls.add('disposeBanner: $slot');
  }
}
