import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../helpers/fake_stores.dart';

/// The hand-offs the state made, without the availability probe it runs when
/// it opens (RES-14), so a test can assert on exactly what a tap handed off.
List<String> _handOffs(NoopSystemIntents intents) => intents.calls
    .where((String call) => !call.startsWith('canHandle:'))
    .toList();

void main() {
  group('payload (RES-3, RES-4 to RES-13)', () {
    test('the parsed payload always agrees with the stored parsedType', () {
      final ResultState state = _stateFor(
        'WIFI:T:WPA;S:Home;P:secret;;',
        parsedType: ParsedType.wifi,
      );
      expect(state.payload, isA<Wifi>());
      expect(state.payload.type, ParsedType.wifi);
    });

    test('a typed link (no format) still parses as a Link', () {
      final ResultState state = _stateFor(
        'https://example.com',
        parsedType: ParsedType.url,
        symbology: Symbology.unknown,
      );
      expect(state.payload, isA<Link>());
    });
  });

  group('RES-14: availability, asked once and only for the type at hand', () {
    test('Wi-Fi asks canHandle(wifiSettings) and nothing else', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      _stateFor(
        'WIFI:T:WPA;S:Home;P:secret;;',
        parsedType: ParsedType.wifi,
        systemIntents: intents,
        linkOpener: linkOpener,
      );
      await pumpEventQueue();

      expect(intents.calls, <String>['canHandle: wifiSettings']);
      expect(linkOpener.calls, isEmpty);
    });

    test(
      'a link asks nothing at all (RES-2): no primary hand-off yet',
      () async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final NoopLinkOpener linkOpener = NoopLinkOpener();
        _stateFor(
          'https://example.com',
          systemIntents: intents,
          linkOpener: linkOpener,
        );
        await pumpEventQueue();

        expect(intents.calls, isEmpty);
        expect(linkOpener.calls, isEmpty);
      },
    );

    test('a product asks canOpenWebLinks, not SystemIntents', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      _stateFor(
        '4006381333931',
        parsedType: ParsedType.product,
        symbology: Symbology.ean13,
        systemIntents: intents,
        linkOpener: linkOpener,
      );
      await pumpEventQueue();

      expect(intents.calls, isEmpty);
      expect(linkOpener.calls, <String>['canOpenWebLinks']);
    });

    test(
      'canX starts true and flips to false once the check answers no',
      () async {
        final ResultState state = _stateFor(
          'tel:+15551234567',
          parsedType: ParsedType.phone,
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.dial},
          ),
        );
        expect(state.canDial, isTrue);

        await pumpEventQueue();

        expect(state.canDial, isFalse);
      },
    );

    test(
      'a contact result reports availability through canAddToContacts',
      () async {
        final ResultState state = _stateFor(
          'BEGIN:VCARD\nVERSION:3.0\nFN:Ada\nEND:VCARD',
          parsedType: ParsedType.contact,
        );
        await pumpEventQueue();
        expect(state.canAddToContacts, isTrue);
      },
    );
  });

  group('RES-1: copy and share', () {
    test('copy sends the exact decoded text and reports ok', () async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: clipboard,
      );

      final ResultIoOutcome outcome = await state.copy();

      expect(outcome, ResultIoOutcome.ok);
      expect(clipboard.calls, <String>['copyText: https://example.com']);
    });

    test('a clipboard that refuses reports failed', () async {
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: _ThrowingClipboardService(),
      );

      expect(await state.copy(), ResultIoOutcome.failed);
    });

    test('share sends the exact decoded text and reports ok', () async {
      final NoopShareService share = NoopShareService();
      final ResultState state = _stateFor('https://example.com', share: share);

      expect(await state.share(), ResultIoOutcome.ok);
      expect(share.calls, <String>['shareText: https://example.com']);
    });

    test('a share sheet that refuses reports failed', () async {
      final ResultState state = _stateFor(
        'https://example.com',
        share: _ThrowingShareService(),
      );

      expect(await state.share(), ResultIoOutcome.failed);
    });
  });

  group('RES-4, DATA-5: the Wi-Fi password', () {
    test(
      'copyWifiPassword copies only the password, never the payload',
      () async {
        final NoopClipboardService clipboard = NoopClipboardService();
        final ResultState state = _stateFor(
          'WIFI:T:WPA;S:Home;P:s3cret;;',
          parsedType: ParsedType.wifi,
          clipboard: clipboard,
        );

        final ResultIoOutcome outcome = await state.copyWifiPassword();

        expect(outcome, ResultIoOutcome.ok);
        expect(clipboard.calls, <String>['copyText: s3cret']);
      },
    );

    test('an open network has no password to copy', () async {
      final ResultState state = _stateFor(
        'WIFI:T:nopass;S:Cafe;;',
        parsedType: ParsedType.wifi,
      );

      expect(await state.copyWifiPassword(), ResultIoOutcome.failed);
    });

    test('the reveal toggle starts masked and flips on demand, notifying', () {
      final ResultState state = _stateFor(
        'WIFI:T:WPA;S:Home;P:s3cret;;',
        parsedType: ParsedType.wifi,
      );
      var notified = 0;
      state.addListener(() => notified++);

      expect(state.isWifiPasswordRevealed, isFalse);
      state.toggleWifiPasswordRevealed();
      expect(state.isWifiPasswordRevealed, isTrue);
      expect(notified, 1);
      state.toggleWifiPasswordRevealed();
      expect(state.isWifiPasswordRevealed, isFalse);
    });
  });

  group('SET-3, RES-2: copy on scan moved from the screen', () {
    test('copies once the entrance finishes, when the setting is on', () async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: clipboard,
        copyOnScan: true,
      );

      expect(clipboard.calls, isEmpty);
      await state.notifyEntranceFinished();

      expect(clipboard.calls, <String>['copyText: https://example.com']);
    });

    test('does nothing a second time, so it never copies twice', () async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: clipboard,
        copyOnScan: true,
      );

      await state.notifyEntranceFinished();
      await state.notifyEntranceFinished();

      expect(clipboard.calls, hasLength(1));
    });

    test('does nothing while the setting is off', () async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: clipboard,
        copyOnScan: false,
      );

      await state.notifyEntranceFinished();

      expect(clipboard.calls, isEmpty);
    });

    test('does nothing for a record reopened from History', () async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = _stateFor(
        'https://example.com',
        clipboard: clipboard,
        copyOnScan: true,
        isReopened: true,
      );

      await state.notifyEntranceFinished();

      expect(clipboard.calls, isEmpty);
    });
  });

  group('RES-6: Add to contacts, exactly as encoded', () {
    test('hands every field to insertContact, a leading + kept', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'BEGIN:VCARD\nVERSION:3.0\nFN:Ada Lovelace\nTEL:+15551234567\n'
        'EMAIL:ada@example.com\nORG:Analytical Engines\nEND:VCARD',
        parsedType: ParsedType.contact,
        systemIntents: intents,
      );

      final SystemHandOffOutcome outcome = await state.addToContacts();

      expect(outcome, SystemHandOffOutcome.handedOff);
      expect(
        intents.calls,
        contains(
          'insertContact: Ada Lovelace (phones: '
          '+15551234567; emails: ada@example.com; org: Analytical Engines)',
        ),
      );
    });

    test('a vCard 4.0 tel: URI reaches the contacts app as the bare '
        'number, + kept, while the screen shows it as encoded', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'BEGIN:VCARD\nVERSION:4.0\nFN:Grace Hopper\n'
        'TEL;VALUE=uri;TYPE=cell:tel:+15557654321\nEND:VCARD',
        parsedType: ParsedType.contact,
        systemIntents: intents,
      );

      await state.addToContacts();

      expect((state.payload as Contact).phones, <String>['tel:+15557654321']);
      expect(
        _handOffs(intents).single,
        startsWith('insertContact: Grace Hopper (phones: +15557654321;'),
      );
    });
  });

  group('RES-6, DATE-3: Add to calendar', () {
    test(
      'a floating time is handed off in the zone at hand, unshifted',
      () async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = _stateFor(
          'BEGIN:VEVENT\nSUMMARY:Standup\nDTSTART:20261016T090000\n'
          'DTEND:20261016T093000\nEND:VEVENT',
          parsedType: ParsedType.event,
          systemIntents: intents,
        );

        await state.addToCalendar();

        final DateTime expectedStart = DateTime(2026, 10, 16, 9);
        final DateTime expectedEnd = DateTime(2026, 10, 16, 9, 30);
        expect(_handOffs(intents), <String>[
          'insertCalendarEvent: Standup '
              '(${expectedStart.toIso8601String()} to '
              '${expectedEnd.toIso8601String()}; allDay: false)',
        ]);
      },
    );

    test(
      'a UTC time is handed off unshifted, whatever the device zone',
      () async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = _stateFor(
          'BEGIN:VEVENT\nSUMMARY:Launch\nDTSTART:20261016T090000Z\nEND:VEVENT',
          parsedType: ParsedType.event,
          systemIntents: intents,
        );

        await state.addToCalendar();

        expect(
          _handOffs(intents).single,
          contains(DateTime.utc(2026, 10, 16, 9).toIso8601String()),
        );
      },
    );

    test('a TZID-qualified time is read as its own numbers, never the '
        "device's zone", () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'BEGIN:VEVENT\nSUMMARY:Meetup\n'
        'DTSTART;TZID=Europe/London:20261016T090000\nEND:VEVENT',
        parsedType: ParsedType.event,
        systemIntents: intents,
      );

      await state.addToCalendar();

      // Never the device's own local-time reading of the same numbers,
      // which on a UTC test host would coincide with the UTC reading; the
      // contract this checks is "never shifted", not "always this value".
      expect(
        _handOffs(intents).single,
        contains(DateTime.utc(2026, 10, 16, 9).toIso8601String()),
      );
    });

    test(
      'an all-day event is midnight UTC, with the all-day flag set',
      () async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = _stateFor(
          'BEGIN:VEVENT\nSUMMARY:Conference\nDTSTART;VALUE=DATE:20261016\n'
          'END:VEVENT',
          parsedType: ParsedType.event,
          systemIntents: intents,
        );

        await state.addToCalendar();

        expect(
          _handOffs(intents).single,
          contains(DateTime.utc(2026, 10, 16).toIso8601String()),
        );
        expect(_handOffs(intents).single, contains('allDay: true'));
      },
    );

    test('an event with no DTEND hands off no end at all', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'BEGIN:VEVENT\nSUMMARY:Reminder\nDTSTART:20261016T090000\nEND:VEVENT',
        parsedType: ParsedType.event,
        systemIntents: intents,
      );

      await state.addToCalendar();

      expect(_handOffs(intents).single, endsWith(' to ; allDay: false)'));
    });
  });

  group('RES-7: phone, SMS and email hand-offs', () {
    test('dial hands the number exactly as encoded, + kept', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'tel:+15551234567',
        parsedType: ParsedType.phone,
        systemIntents: intents,
      );

      await state.dial();

      expect(_handOffs(intents), <String>['dial: +15551234567']);
    });

    test('composeSms hands the number and the message', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'SMSTO:+15551234567:On my way',
        parsedType: ParsedType.sms,
        systemIntents: intents,
      );

      await state.composeSms();

      expect(_handOffs(intents), <String>[
        'composeSms: +15551234567 (message: On my way)',
      ]);
    });

    test('composeEmail hands the recipient, subject and body', () async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = _stateFor(
        'mailto:ada@example.com?subject=Hi&body=Hello',
        parsedType: ParsedType.email,
        systemIntents: intents,
      );

      await state.composeEmail();

      expect(_handOffs(intents), <String>[
        'composeEmail: ada@example.com (subject: Hi)',
      ]);
    });
  });

  group('RES-9, SET-4: Search the web', () {
    test('Google is the default search engine', () async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = _stateFor(
        '4006381333931',
        parsedType: ParsedType.product,
        symbology: Symbology.ean13,
        linkOpener: linkOpener,
      );

      await state.searchTheWeb();

      expect(linkOpener.openedUrls.single.host, 'www.google.com');
      expect(
        linkOpener.openedUrls.single.queryParameters['q'],
        '4006381333931',
      );
    });

    test('a different engine builds a different search URL', () async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = _stateFor(
        '4006381333931',
        parsedType: ParsedType.product,
        symbology: Symbology.ean13,
        linkOpener: linkOpener,
        searchEngine: SearchEngine.duckDuckGo,
      );

      await state.searchTheWeb();

      expect(linkOpener.openedUrls.single.host, 'duckduckgo.com');
    });
  });
}

/// A [ResultState] over [text], every dependency defaulting to a fresh
/// no-op fake so a test overrides only what it is about.
ResultState _stateFor(
  String text, {
  ParsedType parsedType = ParsedType.url,
  Symbology symbology = Symbology.qr,
  bool copyOnScan = false,
  bool isReopened = false,
  SearchEngine searchEngine = SearchEngine.google,
  ClipboardService? clipboard,
  ShareService? share,
  SystemIntents? systemIntents,
  LinkOpener? linkOpener,
}) => ResultState(
  outcome: ScanOutcome(
    record: aScanRecord(
      payloadText: text,
      parsedType: parsedType,
      symbology: symbology,
    ),
    parsedType: parsedType,
    symbology: symbology,
    source: RecordSource.camera,
    isSaved: true,
  ),
  isReopened: isReopened,
  copyOnScan: copyOnScan,
  searchEngine: searchEngine,
  clipboard: clipboard ?? NoopClipboardService(),
  share: share ?? NoopShareService(),
  systemIntents: systemIntents ?? NoopSystemIntents(),
  linkOpener: linkOpener ?? NoopLinkOpener(),
);

/// A [ClipboardService] that always refuses, for the `.failed` path.
class _ThrowingClipboardService implements ClipboardService {
  @override
  Future<void> copyText(String text) => throw StateError('clipboard refused');

  @override
  Future<String?> readText() async => null;
}

/// A [ShareService] that always refuses, for the `.failed` path.
class _ThrowingShareService implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) =>
      throw StateError('share sheet refused');

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  }) => throw StateError('share sheet refused');

  @override
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) => throw StateError('share sheet refused');
}
