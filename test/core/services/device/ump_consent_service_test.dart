import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ump;
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/services/device/ump_consent_service.dart';

void main() {
  group('mapConsentStatus (PRIV-1)', () {
    test('notRequired means the region needs no message', () {
      expect(
        mapConsentStatus(ump.ConsentStatus.notRequired),
        ConsentStatus.notNeeded,
      );
    });

    test('obtained means the user answered the required message', () {
      expect(
        mapConsentStatus(ump.ConsentStatus.obtained),
        ConsentStatus.obtained,
      );
    });

    test('required means a message is owed but not yet shown', () {
      expect(
        mapConsentStatus(ump.ConsentStatus.required),
        ConsentStatus.formRequired,
      );
    });

    test('unknown means nothing is resolved yet', () {
      expect(
        mapConsentStatus(ump.ConsentStatus.unknown),
        ConsentStatus.unresolved,
      );
    });
  });

  group('mapPrivacyOptionsRequired (PRIV-2)', () {
    test('required shows the Settings row', () {
      expect(
        mapPrivacyOptionsRequired(ump.PrivacyOptionsRequirementStatus.required),
        isTrue,
      );
    });

    test('notRequired and unknown both hide it', () {
      expect(
        mapPrivacyOptionsRequired(
          ump.PrivacyOptionsRequirementStatus.notRequired,
        ),
        isFalse,
      );
      expect(
        mapPrivacyOptionsRequired(ump.PrivacyOptionsRequirementStatus.unknown),
        isFalse,
      );
    });
  });

  group('personalizedAdsAllowedFor (ADS-5)', () {
    test('a region UMP says needs no message defaults to personalised', () {
      expect(personalizedAdsAllowedFor(ConsentStatus.notNeeded), isTrue);
    });

    test('every other status, including an answered form, stays '
        'non-personalised: UMP\'s "obtained" only means the message was '
        'answered, not what was chosen inside it', () {
      expect(personalizedAdsAllowedFor(ConsentStatus.obtained), isFalse);
      expect(personalizedAdsAllowedFor(ConsentStatus.formRequired), isFalse);
      expect(personalizedAdsAllowedFor(ConsentStatus.unresolved), isFalse);
      expect(personalizedAdsAllowedFor(ConsentStatus.unavailable), isFalse);
    });
  });

  group('UmpConsentService starting state', () {
    test('starts unresolved with no ad request allowed, like a session '
        'that has never called refresh (ADS-5)', () {
      final UmpConsentService service = UmpConsentService();
      expect(service.status, ConsentStatus.unresolved);
      expect(service.canRequestAds, isFalse);
      expect(service.personalizedAdsAllowed, isFalse);
      expect(service.privacyOptionsRequired, isFalse);
    });
  });
}
