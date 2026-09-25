import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/screens/ads/ad_banner_slot.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/ads_state.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';
import '../settings/settings_scope.dart';

void main() {
  /// Everything a test needs to drive one [AdBannerSlot] in isolation: the ad
  /// service it can inspect, and a [SuccessCounts] the test controls.
  ({NoopAdsService ads, SuccessCounts successCounts, AppServices services})
  harness({
    ConsentStatus consentStatus = ConsentStatus.notNeeded,
    bool owned = false,
    double reservedHeight = 50,
  }) {
    final NoopAdsService ads = NoopAdsService(reservedHeight: reservedHeight);
    final NoopConsentService consent = NoopConsentService(
      seededStatus: consentStatus,
    );
    final SuccessCounts successCounts = SuccessCounts(FakeKeyValueStore());
    final AppServices services = AppServices.fakes().copyWith(
      ads: ads,
      consent: consent,
      billing: NoopBillingService(
        owned: owned ? <String>{ProState.removeAdsProductId} : <String>{},
      ),
    );
    return (ads: ads, successCounts: successCounts, services: services);
  }

  testWidgets(
    'reserves space and requests a banner from the install\'s first launch, '
    'before any scan or create (ADS-1, ADS-6 dropped 26 September 2026)',
    (WidgetTester tester) async {
      final h = harness(reservedHeight: 74);
      await h.successCounts.load();

      await pumpApp(
        tester,
        const SettingsScope(child: AdBannerSlot(slot: AdSlots.settings)),
        services: h.services,
        successCounts: h.successCounts,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
      expect(h.ads.requestedSlots, <String>[AdSlots.settings]);
    },
  );

  testWidgets('reserves no space for a Pro owner (ADS-7)', (
    WidgetTester tester,
  ) async {
    final h = harness(owned: true);
    await h.successCounts.load();
    await h.successCounts.recordSuccessfulScan();

    // An owner's cached ownership, read before the first frame the way the
    // app's entry point reads it (PRO-7).
    final ProState pro = ProState(
      billing: h.services.billing,
      store: FakeKeyValueStore(<String, String>{ProState.ownedKey: '1'}),
      successCounts: h.successCounts,
    );
    await pro.load();
    addTearDown(pro.dispose);

    await pumpApp(
      tester,
      SettingsScope(
        proState: pro,
        child: const AdBannerSlot(slot: AdSlots.settings),
      ),
      services: h.services,
      successCounts: h.successCounts,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsNothing);
    expect(h.ads.calls, isEmpty);
  });

  testWidgets('reserves no space while consent has not resolved (ADS-5)', (
    WidgetTester tester,
  ) async {
    final h = harness(consentStatus: ConsentStatus.unresolved);
    await h.successCounts.load();
    await h.successCounts.recordSuccessfulScan();

    await pumpApp(
      tester,
      const SettingsScope(child: AdBannerSlot(slot: AdSlots.settings)),
      services: h.services,
      successCounts: h.successCounts,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsNothing);
    expect(h.ads.calls, isEmpty);
  });

  testWidgets(
    "reserves the ad service's own height once allowed, behind a divider "
    '(ADS-1, ADS-3, ADS-4)',
    (WidgetTester tester) async {
      final h = harness(reservedHeight: 74);
      await h.successCounts.load();
      await h.successCounts.recordSuccessfulScan();

      await pumpApp(
        tester,
        const SettingsScope(child: AdBannerSlot(slot: AdSlots.settings)),
        services: h.services,
        successCounts: h.successCounts,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is SizedBox && widget.height == 74,
        ),
        findsOneWidget,
      );
      expect(h.ads.requestedSlots, <String>[AdSlots.settings]);
    },
  );

  testWidgets(
    'the reserved height never changes once set, so nothing placed after it '
    'moves (ADS-4)',
    (WidgetTester tester) async {
      final h = harness(reservedHeight: 74);
      await h.successCounts.load();
      await h.successCounts.recordSuccessfulScan();

      await pumpApp(
        tester,
        const SettingsScope(
          child: Column(
            children: <Widget>[
              AdBannerSlot(slot: AdSlots.settings),
              Text('marker below the slot'),
            ],
          ),
        ),
        services: h.services,
        successCounts: h.successCounts,
      );
      await tester.pumpAndSettle();
      final double settledOffset = tester
          .getTopLeft(find.text('marker below the slot'))
          .dy;

      // Nothing about the slot's decision changed, so re-pumping must not
      // move what comes after it.
      await tester.pump();
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('marker below the slot')).dy,
        settledOffset,
      );
    },
  );

  testWidgets('a slot outside ADS-1 is never allowed, even otherwise '
      'eligible', (WidgetTester tester) async {
    final h = harness();
    await h.successCounts.load();
    await h.successCounts.recordSuccessfulScan();

    await pumpApp(
      tester,
      const SettingsScope(child: AdBannerSlot(slot: 'a_result_screen')),
      services: h.services,
      successCounts: h.successCounts,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsNothing);
    expect(h.ads.calls, isEmpty);
  });

  testWidgets('where the region needs it, shows the consent form first, then '
      'reserves the space and loads (PRIV-1, ADS-4)', (
    WidgetTester tester,
  ) async {
    final h = harness(consentStatus: ConsentStatus.formRequired);
    await h.successCounts.load();
    await h.successCounts.recordSuccessfulScan();

    await pumpApp(
      tester,
      const SettingsScope(child: AdBannerSlot(slot: AdSlots.history)),
      services: h.services,
      successCounts: h.successCounts,
    );
    await tester.pumpAndSettle();

    final NoopConsentService consent = h.services.consent as NoopConsentService;
    expect(
      consent.calls,
      containsAllInOrder(<String>['refresh', 'showFormIfRequired']),
    );
    expect(find.byType(Divider), findsOneWidget);
    expect(h.ads.calls.last, startsWith('loadBanner: history'));
  });
}
