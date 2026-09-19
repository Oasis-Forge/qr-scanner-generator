import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/services/device/android_system_intents.dart';
import 'package:qrscanner/services/system_intents.dart';

void main() {
  group('intent building (pure, no device needed)', () {
    test('dialIntent: ACTION_DIAL on tel:, the number exactly as encoded '
        '(RES-7)', () {
      final AndroidIntent intent = dialIntent('+15551234567');

      expect(intent.action, 'android.intent.action.DIAL');
      expect(intent.data, 'tel:+15551234567');
      expect(intent.arguments, isNull);
    });

    test('composeSmsIntent: ACTION_SENDTO on smsto:, the message in '
        'sms_body (RES-7)', () {
      final AndroidIntent intent = composeSmsIntent(
        phoneNumber: '+15551234567',
        message: 'On my way',
      );

      expect(intent.action, 'android.intent.action.SENDTO');
      expect(intent.data, 'smsto:+15551234567');
      expect(intent.arguments, <String, dynamic>{'sms_body': 'On my way'});
    });

    test('composeSmsIntent with no message carries no extras', () {
      final AndroidIntent intent = composeSmsIntent(
        phoneNumber: '+15551234567',
      );

      expect(intent.arguments, isNull);
    });

    test('composeEmailIntent: ACTION_SENDTO on mailto:, subject and body in '
        "Intent's own extras (RES-7)", () {
      final AndroidIntent intent = composeEmailIntent(
        to: <String>['ada@example.com'],
        subject: 'Hi',
        body: 'Hello',
      );

      expect(intent.action, 'android.intent.action.SENDTO');
      expect(intent.data, 'mailto:ada@example.com');
      expect(intent.arguments, <String, dynamic>{
        'android.intent.extra.SUBJECT': 'Hi',
        'android.intent.extra.TEXT': 'Hello',
      });
    });

    test('composeEmailIntent joins several recipients with a comma', () {
      final AndroidIntent intent = composeEmailIntent(
        to: <String>['ada@example.com', 'grace@example.com'],
      );

      expect(intent.data, 'mailto:ada@example.com,grace@example.com');
      expect(intent.arguments, <String, dynamic>{});
    });

    test('insertContactIntent: ACTION_INSERT on the contact mime type, with '
        "the Insert contract's own extras (RES-6)", () {
      final AndroidIntent intent = insertContactIntent(
        const ContactDraft(
          name: 'Ada Lovelace',
          phoneNumbers: <String>['+15551234567'],
          emails: <String>['ada@example.com'],
          organisation: 'Analytical Engines',
        ),
      );

      expect(intent.action, 'android.intent.action.INSERT');
      expect(intent.type, 'vnd.android.cursor.dir/contact');
      expect(intent.arguments, <String, dynamic>{
        'name': 'Ada Lovelace',
        'phone': '+15551234567',
        'email': 'ada@example.com',
        'company': 'Analytical Engines',
      });
    });

    test('insertContactIntent fills the secondary and tertiary phone and '
        'email extras in order', () {
      final AndroidIntent intent = insertContactIntent(
        const ContactDraft(
          name: 'Group',
          phoneNumbers: <String>['1', '2', '3', '4'],
          emails: <String>['a@x.com', 'b@x.com'],
        ),
      );

      expect(intent.arguments, <String, dynamic>{
        'name': 'Group',
        'phone': '1',
        'secondary_phone': '2',
        'tertiary_phone': '3',
        'email': 'a@x.com',
        'secondary_email': 'b@x.com',
      });
    });

    test('insertContactIntent with nothing but a name carries only it', () {
      final AndroidIntent intent = insertContactIntent(
        const ContactDraft(name: ''),
      );

      expect(intent.arguments, <String, dynamic>{});
    });

    test('insertCalendarEventIntent: ACTION_INSERT on the events URI, '
        'the start and end already millis (RES-6, DATE-3)', () {
      final DateTime start = DateTime.utc(2026, 10, 16, 9);
      final DateTime end = DateTime.utc(2026, 10, 16, 9, 30);
      final AndroidIntent intent = insertCalendarEventIntent(
        CalendarEventDraft(
          title: 'Standup',
          start: start,
          end: end,
          location: 'Room 1',
          notes: 'Bring the roadmap',
        ),
      );

      expect(intent.action, 'android.intent.action.INSERT');
      // The events URI, not a bare mime type: Google Calendar opens its
      // prefilled form only for the URI (RES-6).
      expect(intent.data, 'content://com.android.calendar/events');
      expect(intent.type, isNull);
      expect(intent.arguments, <String, dynamic>{
        'title': 'Standup',
        'beginTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
        'allDay': false,
        'eventLocation': 'Room 1',
        'description': 'Bring the roadmap',
      });
    });

    test('insertCalendarEventIntent with no end carries no endTime, and an '
        'all-day event carries the flag', () {
      final DateTime start = DateTime.utc(2026, 10, 16);
      final AndroidIntent intent = insertCalendarEventIntent(
        CalendarEventDraft(title: 'Conference', start: start, allDay: true),
      );

      expect(intent.arguments, <String, dynamic>{
        'title': 'Conference',
        'beginTime': start.millisecondsSinceEpoch,
        'allDay': true,
      });
    });

    test('openWifiSettingsIntent: the settings action alone, no data, no '
        'extras (RES-4)', () {
      final AndroidIntent intent = openWifiSettingsIntent();

      expect(intent.action, 'android.settings.WIFI_SETTINGS');
      expect(intent.data, isNull);
      expect(intent.arguments, isNull);
    });

    test('showLocationIntent: ACTION_VIEW on a geo: URI (RES-8)', () {
      final AndroidIntent intent = showLocationIntent(
        latitude: 51.5,
        longitude: -0.12,
      );

      expect(intent.action, 'android.intent.action.VIEW');
      expect(intent.data, 'geo:51.5,-0.12');
    });

    test('showLocationIntent with a label follows the q=lat,lon(label) '
        'convention', () {
      final AndroidIntent intent = showLocationIntent(
        latitude: 51.5,
        longitude: -0.12,
        label: 'Big Ben',
      );

      expect(intent.data, 'geo:51.5,-0.12?q=51.5,-0.12(Big%20Ben)');
    });

    test('probeIntentFor builds a resolvable placeholder for every '
        'hand-off (RES-14)', () {
      expect(
        probeIntentFor(SystemHandOff.insertContact).type,
        'vnd.android.cursor.dir/contact',
      );
      expect(
        probeIntentFor(SystemHandOff.insertCalendarEvent).type,
        'vnd.android.cursor.dir/event',
      );
      expect(
        probeIntentFor(SystemHandOff.dial).action,
        'android.intent.action.DIAL',
      );
      expect(probeIntentFor(SystemHandOff.sms).data, 'smsto:');
      expect(probeIntentFor(SystemHandOff.email).data, 'mailto:');
      expect(
        probeIntentFor(SystemHandOff.wifiSettings).action,
        'android.settings.WIFI_SETTINGS',
      );
      expect(
        probeIntentFor(SystemHandOff.location).action,
        'android.intent.action.VIEW',
      );
    });
  });

  group('AndroidSystemIntents off Android (this test host)', () {
    // `AndroidIntent.canResolveActivity` answers false on any platform that
    // isn't Android (its own `LocalPlatform().isAndroid` check), which is
    // every machine `flutter test` runs these on. That is exactly what lets
    // this be checked without a device: every hand-off resolves to
    // `noHandler` rather than throwing, and never reaches `launch`.
    const AndroidSystemIntents intents = AndroidSystemIntents();

    test('canHandle reports false for every hand-off', () async {
      for (final SystemHandOff handOff in SystemHandOff.values) {
        expect(await intents.canHandle(handOff), isFalse);
      }
    });

    test(
      'every hand-off method reports noHandler instead of throwing',
      () async {
        expect(
          await intents.openWifiSettings(),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.dial('+15551234567'),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.composeSms(phoneNumber: '+15551234567'),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.composeEmail(to: <String>['a@x.com']),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.insertContact(const ContactDraft(name: 'Ada')),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.insertCalendarEvent(
            CalendarEventDraft(title: 'Standup', start: DateTime.now()),
          ),
          SystemHandOffOutcome.noHandler,
        );
        expect(
          await intents.showLocation(latitude: 0, longitude: 0),
          SystemHandOffOutcome.noHandler,
        );
      },
    );
  });
}
