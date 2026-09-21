import 'package:flutter/widgets.dart';

import '../core/services/ads_service.dart';
import '../core/services/consent_service.dart';
import 'interstitial_session.dart';
import 'pro_state.dart';
import 'success_counts.dart';

/// The three placements ADS-1 allows a banner on, and nowhere else.
///
/// A screen that wants a banner passes one of these to [AdsState]; there is no
/// other way to name a slot, so a screen outside this list simply cannot ask
/// for one.
abstract final class AdSlots {
  /// The History list (ADS-1).
  static const String history = 'history';

  /// The top level of Settings, never a sub-page such as Privacy options or
  /// Feedback (ADS-1).
  static const String settings = 'settings';

  /// The Create type picker (ADS-1).
  static const String createTypePicker = 'create_type_picker';

  /// Every slot ADS-1 allows, for [AdsState.isAllowed]'s own check and for a
  /// test that wants to assert nothing outside it was ever requested.
  static const Set<String> all = <String>{history, settings, createTypePicker};
}

/// Decides, for one of [AdSlots.all], whether a banner may load right now, and
/// carries the request through an [AdsService] once it may (ADS-1, ADS-5,
/// ADS-6, ADS-7).
///
/// Stateless on purpose: every decision is read fresh from [SuccessCounts],
/// [ProState] and the [ConsentService] each time, so a screen that watches
/// those two `ChangeNotifier`s (both already provided app-wide) rebuilds this
/// with them and always decides from the latest count and the latest
/// ownership, never a snapshot taken when the screen first opened. The screen
/// itself keeps whatever load has already happened (a loaded banner, a
/// reserved height) as its own local state, since that is about one screen's
/// widget tree, not about the decision.
class AdsState {
  AdsState({
    required AdsService ads,
    required ConsentService consent,
    required SuccessCounts successCounts,
    required ProState proState,
    InterstitialSession? interstitialSession,
  }) : _ads = ads,
       _consent = consent,
       _successCounts = successCounts,
       _proState = proState,
       _session = interstitialSession;

  final AdsService _ads;
  final ConsentService _consent;
  final SuccessCounts _successCounts;
  final ProState _proState;

  /// The session's one interstitial (ADS-9), or `null` for a caller that only
  /// deals in banners — every banner screen builds this class, and none of
  /// them needs to know an interstitial exists.
  final InterstitialSession? _session;

  /// Whether [slot] may show a banner right now.
  ///
  /// False for anything outside [AdSlots.all] (ADS-1), before the install's
  /// first successful scan or create (ADS-6), for a Pro owner (ADS-7), and
  /// while consent for this session doesn't allow requesting ads at all
  /// (ADS-5). A caller that finds this false shows nothing and reserves no
  /// height: an ad that will not be requested has no space to hold.
  bool isAllowed(String slot) => _isEligible(slot) && _consent.canRequestAds;

  /// Whether [slot] is waiting only on the consent form: everything else
  /// allows a banner, and the consent SDK says this user must answer its
  /// form first (PRIV-1). [ensureLoaded] shows it.
  bool awaitsConsentForm(String slot) =>
      _isEligible(slot) && _consent.status == ConsentStatus.formRequired;

  /// Whether consent for this session hasn't been read yet. A slot asks
  /// [refreshConsent] once and decides again (ADS-5).
  bool get consentUnresolved => _consent.status == ConsentStatus.unresolved;

  /// Reads consent for this session, silently (PRIV-1).
  Future<void> refreshConsent() => _consent.refresh();

  /// Everything but consent: an ADS-1 slot, after the first success, and not
  /// a Pro owner.
  bool _isEligible(String slot) =>
      AdSlots.all.contains(slot) &&
      _successCounts.hasFirstSuccess &&
      !_proState.isOwned;

  /// The height to reserve for a banner at [widthDp], asked before any load so
  /// a loading, failing or refreshing ad never moves a control (ADS-4).
  ///
  /// Only meaningful once [isAllowed] is true; a caller that reserves this
  /// height for a slot that isn't allowed would hold empty space no ad will
  /// ever fill.
  Future<double> reservedHeight({required double widthDp}) =>
      _ads.bannerHeight(widthDp: widthDp);

  /// Shows the consent form when [slot] is waiting on it (PRIV-1), then
  /// answers [isAllowed].
  ///
  /// The form is reached only here, and only for an eligible slot, which is
  /// what ties it to "an ad screen (ADS-1) is about to request an ad once
  /// ADS-6 is met" and keeps it off first launch.
  Future<bool> resolveConsent(String slot) async {
    if (awaitsConsentForm(slot)) {
      await _consent.showFormIfRequired();
    }
    return isAllowed(slot);
  }

  /// Resolves any pending consent form, then requests a banner for [slot] at
  /// [widthDp]. Returns `false` without asking [AdsService] for anything
  /// when [slot] is not allowed, including when answering the form left
  /// consent in a state [isAllowed] doesn't allow.
  Future<bool> ensureLoaded(String slot, {required double widthDp}) async {
    if (!await resolveConsent(slot)) {
      return false;
    }
    return _ads.loadBanner(
      slot: slot,
      widthDp: widthDp,
      personalized: _consent.personalizedAdsAllowed,
    );
  }

  /// The banner loaded for [slot], or `null` while none is ready (ADS-4).
  Widget? bannerFor(String slot) => _ads.bannerFor(slot);

  /// Releases [slot]'s banner, e.g. when the screen showing it leaves.
  Future<void> disposeSlot(String slot) => _ads.disposeBanner(slot);

  /// Whether ADS-9's interstitial may be shown at this moment.
  ///
  /// Everything a banner must satisfy applies unchanged — after the install's
  /// first success (ADS-6), never for a Pro owner (ADS-7), and only once
  /// consent for this session already allows ads (ADS-5) — plus the session's
  /// one not yet spent (ADS-9).
  ///
  /// Unlike a banner, this never shows the consent form. PRIV-1 ties that form
  /// to an ADS-1 screen about to request an ad, and no interstitial is on one;
  /// unresolved consent simply means no interstitial.
  bool get interstitialAllowed {
    final InterstitialSession? session = _session;
    return session != null &&
        !session.shown &&
        _successCounts.hasFirstSuccess &&
        !_proState.isOwned &&
        _consent.canRequestAds;
  }

  /// Requests ADS-9's interstitial and shows it, reporting whether one was
  /// actually shown.
  ///
  /// Spends the session's one only when an ad reached the screen: a request
  /// that found no ad leaves it for later in the same session, since nobody
  /// saw anything. Every outcome is silent — the save or share this follows
  /// has already succeeded and already said so, and an ad that never arrived
  /// is not something to report.
  Future<bool> maybeShowInterstitial() async {
    if (!interstitialAllowed) {
      return false;
    }
    final bool ready = await _ads.loadInterstitial(
      personalized: _consent.personalizedAdsAllowed,
    );
    if (!ready || !await _ads.showInterstitial()) {
      return false;
    }
    _session!.markShown();
    return true;
  }
}
