import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/state/ads_state.dart';
import 'package:qrscanner/state/interstitial_session.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/success_counts.dart';

class _FakeKeyValueStore implements KeyValueStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<int?> getInt(String key) async => int.tryParse(values[key] ?? '');

  @override
  Future<void> setInt(String key, int value) => setString(key, '$value');

  @override
  Future<bool?> getBool(String key) async => switch (values[key]) {
    '1' => true,
    '0' => false,
    _ => null,
  };

  @override
  Future<void> setBool(String key, {required bool value}) =>
      setString(key, value ? '1' : '0');

  @override
  Future<int> increment(String key, {int by = 1}) async {
    final int next = (int.tryParse(values[key] ?? '') ?? 0) + by;
    await setString(key, '$next');
    return next;
  }

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<Map<String, String>> all() async => Map<String, String>.of(values);
}

void main() {
  late NoopAdsService ads;
  late NoopConsentService consent;
  late SuccessCounts successCounts;
  late ProState proState;
  late InterstitialSession interstitialSession;
  late AdsState adsState;

  /// Builds [adsState] from fresh fakes. [owned] and [afterFirstSuccess] seed
  /// [proState] and [successCounts] so a test only names the gate it cares
  /// about; [consent] is built by the caller, since every test exercises a
  /// different consent state.
  Future<void> build({
    required ConsentStatus consentStatus,
    bool personalizedAllowed = false,
    bool owned = false,
    bool afterFirstSuccess = true,
    bool interstitialLoads = false,
  }) async {
    ads = NoopAdsService(interstitialLoads: interstitialLoads);
    consent = NoopConsentService(
      seededStatus: consentStatus,
      personalizedAllowed: personalizedAllowed,
    );
    await consent.refresh();
    successCounts = SuccessCounts(_FakeKeyValueStore());
    await successCounts.load();
    if (afterFirstSuccess) {
      await successCounts.recordSuccessfulScan();
    }
    proState = ProState(
      billing: NoopBillingService(
        owned: owned ? <String>{ProState.removeAdsProductId} : <String>{},
      ),
      store: _FakeKeyValueStore(),
      successCounts: successCounts,
    );
    await proState.load();
    await proState.startupCheck;
    interstitialSession = InterstitialSession();
    adsState = AdsState(
      ads: ads,
      consent: consent,
      successCounts: successCounts,
      proState: proState,
      interstitialSession: interstitialSession,
    );
  }

  tearDown(() {
    successCounts.dispose();
    proState.dispose();
  });

  group('isAllowed (ADS-1, ADS-5, ADS-6, ADS-7)', () {
    test('a slot outside the three ADS-1 names is never allowed', () async {
      await build(consentStatus: ConsentStatus.notNeeded);

      expect(adsState.isAllowed('a_result_screen'), isFalse);
      expect(AdSlots.all, <String>{
        AdSlots.history,
        AdSlots.settings,
        AdSlots.createTypePicker,
      });
    });

    test('not allowed before the install\'s first success (ADS-6)', () async {
      await build(
        consentStatus: ConsentStatus.notNeeded,
        afterFirstSuccess: false,
      );

      expect(adsState.isAllowed(AdSlots.settings), isFalse);
    });

    test('allowed once the first success has happened', () async {
      await build(consentStatus: ConsentStatus.notNeeded);

      expect(adsState.isAllowed(AdSlots.settings), isTrue);
    });

    test('never allowed for a Pro owner (ADS-7)', () async {
      await build(consentStatus: ConsentStatus.notNeeded, owned: true);

      expect(adsState.isAllowed(AdSlots.settings), isFalse);
      expect(adsState.isAllowed(AdSlots.history), isFalse);
      expect(adsState.isAllowed(AdSlots.createTypePicker), isFalse);
    });

    test('not allowed while consent is unresolved (ADS-5)', () async {
      await build(consentStatus: ConsentStatus.unresolved);

      expect(adsState.isAllowed(AdSlots.settings), isFalse);
    });

    test('not allowed when consent could not be resolved, e.g. offline '
        '(ADS-5)', () async {
      await build(consentStatus: ConsentStatus.unavailable);

      expect(adsState.isAllowed(AdSlots.settings), isFalse);
    });

    test('allowed once consent resolved, refused or granted (ADS-5)', () async {
      await build(
        consentStatus: ConsentStatus.obtained,
        personalizedAllowed: false,
      );
      expect(adsState.isAllowed(AdSlots.settings), isTrue);

      await build(
        consentStatus: ConsentStatus.obtained,
        personalizedAllowed: true,
      );
      expect(adsState.isAllowed(AdSlots.settings), isTrue);
    });
  });

  group('reservedHeight (ADS-4)', () {
    test('asks the ad service, without requesting a banner', () async {
      await build(consentStatus: ConsentStatus.notNeeded);

      final double height = await adsState.reservedHeight(widthDp: 360);

      expect(height, ads.reservedHeight);
      expect(ads.requestedSlots, isEmpty);
    });
  });

  group('ensureLoaded', () {
    test('requests nothing for a slot that is not allowed', () async {
      await build(consentStatus: ConsentStatus.unresolved);

      final bool loaded = await adsState.ensureLoaded(
        AdSlots.settings,
        widthDp: 360,
      );

      expect(loaded, isFalse);
      expect(ads.requestedSlots, isEmpty);
      expect(consent.calls, isNot(contains('showFormIfRequired')));
    });

    test('requests a non-personalised banner once refused (ADS-5)', () async {
      await build(
        consentStatus: ConsentStatus.obtained,
        personalizedAllowed: false,
      );

      await adsState.ensureLoaded(AdSlots.settings, widthDp: 360);

      expect(ads.requestedSlots, <String>[AdSlots.settings]);
      expect(
        ads.calls,
        contains(
          'loadBanner: ${AdSlots.settings} (360.0 dp, personalized: false)',
        ),
      );
    });

    test('requests a personalised banner once granted (ADS-5)', () async {
      await build(
        consentStatus: ConsentStatus.obtained,
        personalizedAllowed: true,
      );

      await adsState.ensureLoaded(AdSlots.settings, widthDp: 360);

      expect(
        ads.calls,
        contains(
          'loadBanner: ${AdSlots.settings} (360.0 dp, personalized: true)',
        ),
      );
    });

    test('resolves a required consent form before requesting a banner, only '
        'once ADS-6 is already met (PRIV-1)', () async {
      await build(consentStatus: ConsentStatus.formRequired);

      await adsState.ensureLoaded(AdSlots.settings, widthDp: 360);

      expect(consent.calls, contains('showFormIfRequired'));
      expect(ads.requestedSlots, <String>[AdSlots.settings]);
    });

    test(
      'never shows the consent form before the first success (PRIV-1)',
      () async {
        await build(
          consentStatus: ConsentStatus.formRequired,
          afterFirstSuccess: false,
        );

        final bool loaded = await adsState.ensureLoaded(
          AdSlots.settings,
          widthDp: 360,
        );

        expect(loaded, isFalse);
        expect(consent.calls, isNot(contains('showFormIfRequired')));
      },
    );
  });

  group('the consent form (PRIV-1, ADS-5, ADS-7)', () {
    test(
      'an eligible slot waits on the form rather than being refused',
      () async {
        await build(consentStatus: ConsentStatus.formRequired);

        expect(adsState.isAllowed(AdSlots.history), isFalse);
        expect(adsState.awaitsConsentForm(AdSlots.history), isTrue);
      },
    );

    test('a Pro owner is never shown the form (ADS-7)', () async {
      await build(consentStatus: ConsentStatus.formRequired, owned: true);

      expect(adsState.awaitsConsentForm(AdSlots.history), isFalse);
      expect(await adsState.resolveConsent(AdSlots.history), isFalse);
      expect(consent.calls, isNot(contains('showFormIfRequired')));
    });

    test('a form answered without allowing ads requests nothing', () async {
      await build(consentStatus: ConsentStatus.formRequired);
      final _UnansweredConsentService unanswered = _UnansweredConsentService();
      await unanswered.refresh();
      adsState = AdsState(
        ads: ads,
        consent: unanswered,
        successCounts: successCounts,
        proState: proState,
      );

      final bool loaded = await adsState.ensureLoaded(
        AdSlots.history,
        widthDp: 360,
      );

      expect(loaded, isFalse);
      expect(unanswered.calls, contains('showFormIfRequired'));
      expect(ads.requestedSlots, isEmpty);
    });
  });

  group('bannerFor and disposeSlot', () {
    test('proxy straight to the ads service', () async {
      await build(consentStatus: ConsentStatus.notNeeded);

      expect(adsState.bannerFor(AdSlots.settings), isNull);
      await adsState.disposeSlot(AdSlots.settings);

      expect(ads.calls, contains('disposeBanner: ${AdSlots.settings}'));
    });
  });

  group('the interstitial (ADS-9)', () {
    test('is shown when every other ad rule already allows an ad', () async {
      await build(
        consentStatus: ConsentStatus.notNeeded,
        interstitialLoads: true,
      );

      expect(adsState.interstitialAllowed, isTrue);
      expect(await adsState.maybeShowInterstitial(), isTrue);
      expect(ads.calls, contains('showInterstitial'));
      expect(interstitialSession.shown, isTrue);
    });

    test('only once for each time the app is opened', () async {
      await build(
        consentStatus: ConsentStatus.notNeeded,
        interstitialLoads: true,
      );
      expect(await adsState.maybeShowInterstitial(), isTrue);

      expect(adsState.interstitialAllowed, isFalse);
      expect(await adsState.maybeShowInterstitial(), isFalse);
      expect(
        ads.calls.where((String call) => call == 'showInterstitial').length,
        1,
      );
    });

    test('ADS-6: none before the install\'s first success, and none is even '
        'requested', () async {
      await build(
        consentStatus: ConsentStatus.notNeeded,
        interstitialLoads: true,
        afterFirstSuccess: false,
      );

      expect(adsState.interstitialAllowed, isFalse);
      expect(await adsState.maybeShowInterstitial(), isFalse);
      expect(ads.calls, isEmpty);
    });

    test(
      'ADS-7: a Pro owner gets none, and none is requested for them',
      () async {
        await build(
          consentStatus: ConsentStatus.notNeeded,
          interstitialLoads: true,
          owned: true,
        );

        expect(adsState.interstitialAllowed, isFalse);
        expect(await adsState.maybeShowInterstitial(), isFalse);
        expect(ads.calls, isEmpty);
      },
    );

    test('ADS-5, PRIV-1: consent waiting on its form allows no interstitial, '
        'and the form is never shown for one', () async {
      await build(
        consentStatus: ConsentStatus.formRequired,
        interstitialLoads: true,
      );

      expect(await adsState.maybeShowInterstitial(), isFalse);
      expect(ads.calls, isEmpty);
      expect(consent.calls, isNot(contains('showFormIfRequired')));
    });

    test('an ad that never arrives leaves the session its one', () async {
      await build(consentStatus: ConsentStatus.notNeeded);

      expect(await adsState.maybeShowInterstitial(), isFalse);
      expect(interstitialSession.shown, isFalse);
      // Still allowed: nobody saw anything, so nothing was spent.
      expect(adsState.interstitialAllowed, isTrue);
    });
  });
}

/// A region that needs the form, where the form closes without allowing ads.
class _UnansweredConsentService extends NoopConsentService {
  _UnansweredConsentService() : super(seededStatus: ConsentStatus.formRequired);

  @override
  Future<ConsentStatus> showFormIfRequired() async {
    calls.add('showFormIfRequired');
    return status;
  }
}
