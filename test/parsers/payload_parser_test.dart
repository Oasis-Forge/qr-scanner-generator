import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/payload_classifier.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/parsers/payload_parser.dart';

/// Parses [text] as a QR code by default, matching the [Symbology] most
/// samples in `payload_classifier_test.dart` use.
ParsedPayload _parse(
  String text, {
  Symbology symbology = Symbology.qr,
  bool isBinary = false,
  Uint8List? bytes,
}) =>
    parsePayload(text, symbology: symbology, isBinary: isBinary, bytes: bytes);

void main() {
  group('Link (LINK-1)', () {
    test('an http or https URL', () {
      expect(_parse('https://example.com'), const Link('https://example.com'));
    });

    test('a blocked scheme is still a Link (LINK-5)', () {
      expect(_parse('javascript:alert(1)'), const Link('javascript:alert(1)'));
    });

    test('agrees with classifyPayload', () {
      expect(_parse('https://example.com').type, ParsedType.url);
    });
  });

  group('Wifi (RES-4)', () {
    test('the basic fields', () {
      final ParsedPayload result = _parse('WIFI:T:WPA;S:Home;P:secret;;');
      expect(
        result,
        const Wifi(
          ssid: 'Home',
          security: WifiSecurity.wpa,
          password: 'secret',
        ),
      );
    });

    test(
      'escaped fields: \\; \\, \\: \\" and \\\\ in the ssid and password',
      () {
        final ParsedPayload result = _parse(
          r'WIFI:T:WPA;S:My\;Net\,work;P:p\:a\"ss\\word;;',
        );
        expect(
          result,
          const Wifi(
            ssid: 'My;Net,work',
            security: WifiSecurity.wpa,
            password: r'p:a"ss\word',
          ),
        );
      },
    );

    test('an open network with no password shows no password row', () {
      final ParsedPayload result = _parse('WIFI:S:Guest;T:nopass;;');
      expect(
        result,
        const Wifi(ssid: 'Guest', security: WifiSecurity.none, password: null),
      );
    });

    test('an explicit empty P: field is also no password', () {
      final ParsedPayload result = _parse('WIFI:T:nopass;S:Guest;P:;;');
      expect((result as Wifi).password, isNull);
    });

    test('WEP (RES-4 warns Android cannot join it from an app)', () {
      final ParsedPayload result = _parse('WIFI:T:WEP;S:OldRouter;P:12345;;');
      expect(
        result,
        const Wifi(
          ssid: 'OldRouter',
          security: WifiSecurity.wep,
          password: '12345',
        ),
      );
    });

    test('WPA2 and WPA3', () {
      expect(
        (_parse('WIFI:T:WPA2;S:A;P:x;;') as Wifi).security,
        WifiSecurity.wpa2,
      );
      expect(
        (_parse('WIFI:T:WPA3;S:A;P:x;;') as Wifi).security,
        WifiSecurity.wpa3,
      );
    });

    test('H:true is a hidden network', () {
      expect(
        (_parse('WIFI:T:WPA;S:Home;P:secret;H:true;;') as Wifi).hidden,
        isTrue,
      );
      expect((_parse('WIFI:T:WPA;S:Home;P:secret;;') as Wifi).hidden, isFalse);
    });

    test('lower case wifi: still parses the same fields', () {
      expect(
        _parse('wifi:S:Cafe;T:nopass;;'),
        const Wifi(ssid: 'Cafe', security: WifiSecurity.none),
      );
    });

    test('the header alone still builds a Wifi, matching classifyPayload', () {
      final ParsedPayload result = _parse('WIFI:');
      expect(result, isA<Wifi>());
      expect((result as Wifi).ssid, isEmpty);
      expect(result.type, classifyPayload('WIFI:', symbology: Symbology.qr));
    });
  });

  group('Contact: vCard (RES-6)', () {
    test('vCard 3.0 with several TELs and a leading +', () {
      final ParsedPayload result = _parse(
        'BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'FN:Ada Lovelace\n'
        'TEL;TYPE=CELL:+15551234567\n'
        'TEL;TYPE=HOME,VOICE:+15559876543\n'
        'EMAIL:ada@example.com\n'
        'ORG:Analytical Engines\n'
        'END:VCARD',
      );
      expect(
        result,
        const Contact(
          name: 'Ada Lovelace',
          phones: <String>['+15551234567', '+15559876543'],
          emails: <String>['ada@example.com'],
          organisation: 'Analytical Engines',
        ),
      );
    });

    test('vCard 2.1 with CRLF line endings and no FN falls back to N', () {
      final ParsedPayload result = _parse(
        'BEGIN:VCARD\r\nN:Lovelace;Ada;;;\r\nEND:VCARD',
      );
      expect((result as Contact).name, 'Lovelace Ada');
    });

    test('a vCard 4.0 tel: URI value is kept exactly as encoded', () {
      final ParsedPayload result = _parse(
        'BEGIN:VCARD\nVERSION:4.0\nFN:Ada\nTEL;VALUE=uri:tel:+15551234567\nEND:VCARD',
      );
      expect((result as Contact).phones, <String>['tel:+15551234567']);
    });

    test('the header alone still builds an empty Contact', () {
      final ParsedPayload result = _parse('BEGIN:VCARD\nEND:VCARD');
      expect(
        result,
        const Contact(name: null, phones: <String>[], emails: <String>[]),
      );
    });
  });

  group('Contact: MECARD (RES-6)', () {
    test('name, phone, email and organisation', () {
      final ParsedPayload result = _parse(
        'MECARD:N:Lovelace,Ada;TEL:+441234567890;EMAIL:ada@example.com;'
        'ORG:Engine Co;;',
      );
      expect(
        result,
        const Contact(
          name: 'Lovelace,Ada',
          phones: <String>['+441234567890'],
          emails: <String>['ada@example.com'],
          organisation: 'Engine Co',
        ),
      );
    });
  });

  group('CalendarEvent (RES-6, DATE-3)', () {
    test('a folded SUMMARY line is unfolded before it is read', () {
      final ParsedPayload result = _parse(
        'BEGIN:VEVENT\n'
        'SUMMARY:Long \n'
        ' title here\n'
        'DTSTART:20261113T090000\n'
        'END:VEVENT',
      );
      expect((result as CalendarEvent).title, 'Long title here');
    });

    test('an all-day event (VALUE=DATE)', () {
      final ParsedPayload result = _parse(
        'BEGIN:VEVENT\n'
        'SUMMARY:Conference\n'
        'DTSTART;VALUE=DATE:20261225\n'
        'DTEND;VALUE=DATE:20261226\n'
        'END:VEVENT',
      );
      expect(
        result,
        const CalendarEvent(
          title: 'Conference',
          start: '20261225',
          end: '20261226',
          allDay: true,
        ),
      );
    });

    test('a TZID-qualified event keeps the zone and the local time', () {
      final ParsedPayload result = _parse(
        'BEGIN:VEVENT\n'
        'SUMMARY:Standup\n'
        'DTSTART;TZID=Europe/London:20261113T090000\n'
        'DTEND;TZID=Europe/London:20261113T093000\n'
        'END:VEVENT',
      );
      expect(
        result,
        const CalendarEvent(
          title: 'Standup',
          start: '20261113T090000',
          startTzid: 'Europe/London',
          end: '20261113T093000',
          endTzid: 'Europe/London',
        ),
      );
    });

    test('a UTC DTSTART keeps its trailing Z (DATE-3)', () {
      final ParsedPayload result = _parse(
        'BEGIN:VEVENT\nSUMMARY:Launch\nDTSTART:20261113T090000Z\nEND:VEVENT',
      );
      expect((result as CalendarEvent).start, '20261113T090000Z');
    });

    test('LOCATION and DESCRIPTION are unescaped', () {
      final ParsedPayload result = _parse(
        'BEGIN:VEVENT\n'
        'SUMMARY:Party\n'
        '${r'LOCATION:Home\, sweet home'}\n'
        '${r'DESCRIPTION:Bring cake\, and\; a gift'}\n'
        'END:VEVENT',
      );
      final CalendarEvent event = result as CalendarEvent;
      expect(event.location, 'Home, sweet home');
      expect(event.notes, 'Bring cake, and; a gift');
    });

    test('the first VEVENT inside a VCALENDAR', () {
      final ParsedPayload result = _parse(
        'BEGIN:VCALENDAR\n'
        'VERSION:2.0\n'
        'BEGIN:VEVENT\n'
        'SUMMARY:Party\n'
        'DTSTART:20261120T180000\n'
        'END:VEVENT\n'
        'END:VCALENDAR',
      );
      expect((result as CalendarEvent).title, 'Party');
      expect(result.start, '20261120T180000');
    });

    test('a VCALENDAR with no VEVENT still builds an empty CalendarEvent', () {
      final ParsedPayload result = _parse(
        'BEGIN:VCALENDAR\nVERSION:2.0\nEND:VCALENDAR',
      );
      expect(result, isA<CalendarEvent>());
      expect((result as CalendarEvent).title, isEmpty);
    });
  });

  group('Phone (RES-7)', () {
    test('tel: keeps a leading +', () {
      expect(_parse('tel:+15551234567'), const Phone('+15551234567'));
    });
  });

  group('Sms (RES-7)', () {
    test('SMSTO:number:message', () {
      expect(
        _parse('SMSTO:+15551234567:Running late'),
        const Sms(number: '+15551234567', message: 'Running late'),
      );
    });

    test('SMSTO:number with no message', () {
      expect(_parse('SMSTO:+15551234567'), const Sms(number: '+15551234567'));
    });

    test('sms:number?body= is percent-decoded', () {
      expect(
        _parse('sms:+15551234567?body=Hi%20there'),
        const Sms(number: '+15551234567', message: 'Hi there'),
      );
    });

    test('MMSTO: and mms: parse the same way', () {
      expect(
        _parse('MMSTO:+15551234567:Photo'),
        const Sms(number: '+15551234567', message: 'Photo'),
      );
      expect(
        _parse('mms:+15551234567?body=See%20this'),
        const Sms(number: '+15551234567', message: 'See this'),
      );
    });
  });

  group('Email (RES-7)', () {
    test('mailto: with a percent-encoded subject and body', () {
      expect(
        _parse(
          'mailto:someone@example.com?subject=Hello%20World&body=See%20you',
        ),
        const Email(
          to: 'someone@example.com',
          subject: 'Hello World',
          body: 'See you',
        ),
      );
    });

    test('mailto: with no query', () {
      expect(
        _parse('mailto:someone@example.com'),
        const Email(to: 'someone@example.com'),
      );
    });

    test('MATMSG:', () {
      expect(
        _parse('MATMSG:TO:someone@example.com;SUB:Hi;BODY:Hello;;'),
        const Email(to: 'someone@example.com', subject: 'Hi', body: 'Hello'),
      );
    });

    test('a bare address', () {
      expect(
        _parse('someone@example.com'),
        const Email(to: 'someone@example.com'),
      );
    });
  });

  group('Location: geo: (RES-8)', () {
    test('latitude and longitude', () {
      final ParsedPayload result = _parse('geo:37.786971,-122.399677');
      expect(
        result,
        const Location(latitude: 37.786971, longitude: -122.399677),
      );
    });

    test('a q= label, decoded', () {
      final ParsedPayload result = _parse(
        'geo:0,0?q=37.786971,-122.399677(Ferry Building)',
      );
      expect((result as Location).label, 'Ferry Building');
    });
  });

  group('Product (RES-9)', () {
    test('EAN-13 with a good check digit', () {
      expect(
        parsePayload(
          '4006381333931',
          symbology: Symbology.ean13,
          isBinary: false,
        ),
        const Product(code: '4006381333931', format: ProductCodeFormat.ean13),
      );
    });

    test('EAN-13 with a bad check digit is not a product', () {
      final ParsedPayload result = parsePayload(
        '5901234123458',
        symbology: Symbology.ean13,
        isBinary: false,
      );
      expect(result, const PlainText('5901234123458'));
      expect(
        result.type,
        classifyPayload('5901234123458', symbology: Symbology.ean13),
      );
    });

    test('UPC-A', () {
      expect(
        parsePayload(
          '036000291452',
          symbology: Symbology.upcA,
          isBinary: false,
        ),
        const Product(code: '036000291452', format: ProductCodeFormat.upcA),
      );
    });

    test('ISBN: an EAN-13 starting 978', () {
      expect(
        parsePayload(
          '9780306406157',
          symbology: Symbology.ean13,
          isBinary: false,
        ),
        const Product(code: '9780306406157', format: ProductCodeFormat.isbn),
      );
    });
  });

  group('PlainText', () {
    test('anything that fits no other type', () {
      expect(_parse('Hello, world'), const PlainText('Hello, world'));
    });
  });

  group('Unknown (RES-13)', () {
    test('binary bytes: not valid UTF-8, carries the byte count', () {
      final Uint8List bytes = Uint8List.fromList(<int>[0xFF, 0xFE, 0x00, 0x01]);
      final ParsedPayload result = _parse('��', isBinary: true, bytes: bytes);
      expect(result, isA<Unknown>());
      final Unknown unknown = result as Unknown;
      expect(unknown.isBinary, isTrue);
      expect(unknown.byteCount, 4);
    });

    test('an empty payload', () {
      final ParsedPayload result = _parse('');
      expect(result, const Unknown(text: '', isBinary: false, byteCount: 0));
    });

    test('a blank (whitespace-only) payload is also Unknown', () {
      final ParsedPayload result = _parse('   \n\t');
      expect(result, isA<Unknown>());
      expect((result as Unknown).isBinary, isFalse);
    });
  });

  group('parsePayload(...).type always equals classifyPayload(...)', () {
    const List<(String, Symbology)> samples = <(String, Symbology)>[
      ('https://example.com', Symbology.qr),
      ('javascript:alert(1)', Symbology.qr),
      ('ftp://example.com/file.txt', Symbology.qr),
      ('example.com', Symbology.qr),
      ('WIFI:T:WPA;S:Home;P:secret;;', Symbology.qr),
      ('WIFI:', Symbology.qr),
      ('BEGIN:VCARD\nFN:Ada\nEND:VCARD', Symbology.qr),
      ('MECARD:N:Lovelace,Ada;TEL:+441234;;', Symbology.qr),
      (
        'BEGIN:VEVENT\nSUMMARY:Launch\nDTSTART:20261113T090000\nEND:VEVENT',
        Symbology.qr,
      ),
      ('tel:+15551234567', Symbology.qr),
      ('tel:', Symbology.qr),
      ('SMSTO:+15551234567:Running late', Symbology.qr),
      ('SMSTO:', Symbology.qr),
      ('mailto:someone@example.com?subject=Hi', Symbology.qr),
      ('mailto:', Symbology.qr),
      ('MATMSG:TO:someone@example.com;SUB:Hi;BODY:Hello;;', Symbology.qr),
      ('someone@example.com', Symbology.qr),
      ('someone@localhost', Symbology.qr),
      ('geo:37.786971,-122.399677', Symbology.qr),
      ('geo:', Symbology.qr),
      ('Hello, world', Symbology.qr),
      ('', Symbology.qr),
      ('   \n\t', Symbology.qr),
      ('4006381333931', Symbology.ean13),
      ('5901234123458', Symbology.ean13),
      ('5901234123457', Symbology.ean8),
      ('5901234123457', Symbology.upcA),
      ('5901234123457', Symbology.upcE),
      ('5901234123457', Symbology.code128),
      ('9780306406157', Symbology.ean13),
    ];

    for (final (String payload, Symbology symbology) in samples) {
      test('for ${symbology.id} "$payload"', () {
        expect(
          parsePayload(payload, symbology: symbology, isBinary: false).type,
          classifyPayload(payload, symbology: symbology),
        );
      });
    }

    test('and for a binary payload', () {
      expect(
        parsePayload('�', symbology: Symbology.qr, isBinary: true).type,
        classifyPayload('�', symbology: Symbology.qr, isBinary: true),
      );
    });
  });
}
