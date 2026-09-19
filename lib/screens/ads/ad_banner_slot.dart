import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_services.dart';
import '../../state/ads_state.dart';
import '../../state/pro_state.dart';
import '../../state/success_counts.dart';

/// A fixed, non-scrolling banner placement for one of [AdSlots.all] (ADS-1).
///
/// Reserves its height before any ad loads (ADS-4) and sits behind a divider
/// with 16 dp of its own padding above and below, clear of the content and of
/// whatever the screen places after it — the app's own bottom navigation bar,
/// for the three screens ADS-1 names (ADS-3).
///
/// **Decision, since ADS-3/ADS-4 don't say which:** this slot takes space only
/// while a banner *may* load for it. Before the install's first success
/// (ADS-6) and for a Pro owner (ADS-7), it renders nothing and reserves
/// nothing — an empty gap that can never fill, especially one that would
/// follow a paying Pro owner around forever, is not what "reserve the height"
/// is asking for; that rule is about not letting a loading, failing or
/// refreshing *eligible* ad move a control, not about pre-committing space to
/// an ad that will never be requested at all.
///
/// The ad's own content may stay left to right even in Arabic; this widget
/// applies no mirroring inside it (ADS-8).
///
/// Presentational only (`CLAUDE.md`): the decision lives in [AdsState], built
/// fresh from [AppServices], [SuccessCounts] and [ProState] on every build, so
/// it always reads the latest count and the latest ownership rather than a
/// snapshot from when this slot first mounted.
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({required this.slot, super.key});

  /// One of [AdSlots.all].
  final String slot;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  /// Cached in [didChangeDependencies], since [dispose] can no longer read an
  /// `InheritedWidget` from `context` by the time it runs.
  AppServices? _services;

  double? _reservedHeight;
  bool _requestedLoad = false;

  /// Whether this slot already asked for consent to be read (ADS-5).
  bool _refreshedConsent = false;

  /// Whether the consent form was answered in a way that allows no ads, so
  /// this slot holds no space for the rest of its life.
  bool _declined = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = context.read<AppServices>();
  }

  /// Reads consent once when the start-up refresh (PRIV-1) hasn't answered
  /// yet, then decides again.
  Future<void> _refreshConsent(AdsState adsState) async {
    _refreshedConsent = true;
    await adsState.refreshConsent();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    final AppServices? services = _services;
    if (services != null && _requestedLoad) {
      unawaited(services.ads.disposeBanner(widget.slot));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SuccessCounts successCounts = context.watch<SuccessCounts>();
    final ProState proState = context.watch<ProState>();
    final AppServices services = context.read<AppServices>();
    final AdsState adsState = AdsState(
      ads: services.ads,
      consent: services.consent,
      successCounts: successCounts,
      proState: proState,
    );

    if (adsState.consentUnresolved && !_refreshedConsent) {
      unawaited(_refreshConsent(adsState));
    }
    final bool mayShow =
        !_declined &&
        (adsState.isAllowed(widget.slot) ||
            adsState.awaitsConsentForm(widget.slot));
    if (!mayShow) {
      if (_requestedLoad) {
        // Became disallowed after already having asked for a banner — most
        // likely a Pro purchase that just completed (ADS-7). Release it, so a
        // later, still-eligible slot starts clean.
        unawaited(services.ads.disposeBanner(widget.slot));
        _requestedLoad = false;
        _reservedHeight = null;
      }
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double widthDp = constraints.maxWidth;
        final double? reservedHeight = _reservedHeight;
        if (reservedHeight == null) {
          unawaited(_reserveAndLoad(adsState, widthDp));
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Divider(height: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: widthDp,
              height: reservedHeight,
              child: adsState.bannerFor(widget.slot) ?? const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Asks for the height first (ADS-4), then requests the banner — never the
  /// other way around, so the reserved box is on screen before there is
  /// anything to hold.
  Future<void> _reserveAndLoad(AdsState adsState, double widthDp) async {
    if (_requestedLoad) {
      return;
    }
    _requestedLoad = true;
    // The consent form first, where one is required (PRIV-1): nothing is
    // reserved for a user who then allows no ads.
    if (!await adsState.resolveConsent(widget.slot)) {
      if (mounted) {
        setState(() => _declined = true);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final double height = await adsState.reservedHeight(widthDp: widthDp);
    if (!mounted) {
      return;
    }
    setState(() => _reservedHeight = height);
    await adsState.ensureLoaded(widget.slot, widthDp: widthDp);
    if (!mounted) {
      return;
    }
    // The banner itself, once loaded, is read fresh by the next build.
    setState(() {});
  }
}
