import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/payload_classifier.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/parsers/payload_parser.dart';

/// The type a QR code carrying [payload] classifies as.
ParsedType _qr(String payload) =>
    classifyPayload(payload, symbology: Symbology.qr);

void main() {
  group('classifyPayload', () {
    group('links (LINK-1)', () {
      test('an http or https URL with a host is a link', () {
        expect(_qr('https://example.com'), ParsedType.url);
        expect(_qr('http://example.com/path?q=1#top'), ParsedType.url);
      });

      test('an upper-case URL, as QR alphanumeric mode encodes it, is a link '
          '(LINK-1)', () {
        expect(_qr('HTTPS://EXAMPLE.COM/A'), ParsedType.url);
      });

      test('userinfo and IP hosts stay links, never text (LINK-1)', () {
        expect(_qr('https://user@192.168.0.1/login'), ParsedType.url);
        expect(_qr('http://google.com@10.0.0.1'), ParsedType.url);
        expect(_qr('https://[2001:db8::1]/'), ParsedType.url);
      });

      test('a blocked scheme is still a link, so its result can say it is '
          'blocked (LINK-1, LINK-5)', () {
        expect(_qr('javascript:alert(1)'), ParsedType.url);
        expect(_qr('JavaScript:alert(1)'), ParsedType.url);
        expect(_qr('data:text/plain;base64,SGVsbG8='), ParsedType.url);
        expect(_qr('file:///sdcard/secret.txt'), ParsedType.url);
        expect(_qr('intent://scan/#Intent;scheme=zxing;end'), ParsedType.url);
        expect(_qr('content://com.example.provider/item/1'), ParsedType.url);
        // Every case is blocked, not just a lower-case prefix match.
        expect(_qr('DATA:text/plain,hi'), ParsedType.url);
        expect(_qr('File:///sdcard/secret.txt'), ParsedType.url);
        expect(_qr('INTENT://scan/#Intent;scheme=zxing;end'), ParsedType.url);
        expect(_qr('Content://com.example.provider/item/1'), ParsedType.url);
      });

      test('a non-default port does not change the type; it is still a link '
          '(LINK-1; the port itself is a LINK-3 check)', () {
        expect(_qr('http://example.com:8080/'), ParsedType.url);
        expect(_qr('https://example.com:8443/'), ParsedType.url);
      });

      test(
        'another scheme, a bare domain or a link inside a sentence is text',
        () {
          expect(_qr('ftp://example.com/file.txt'), ParsedType.text);
          expect(_qr('market://details?id=com.example'), ParsedType.text);
          expect(_qr('example.com'), ParsedType.text);
          expect(_qr('Visit https://example.com today'), ParsedType.text);
        },
      );

      test(
        'a Play Store link is a link, so every link check runs (RES-11)',
        () {
          expect(
            _qr('https://play.google.com/store/apps/details?id=com.example'),
            ParsedType.url,
          );
        },
      );

      test('surrounding whitespace does not change the type', () {
        expect(_qr('  https://example.com\n'), ParsedType.url);
      });
    });

    test('Wi-Fi: a WIFI: header, in any case (RES-4)', () {
      expect(_qr('WIFI:T:WPA;S:Home;P:secret;;'), ParsedType.wifi);
      expect(_qr('wifi:S:Cafe;T:nopass;;'), ParsedType.wifi);
    });

    test('phone: tel: with a number (RES-7)', () {
      expect(_qr('tel:+15551234567'), ParsedType.phone);
      expect(_qr('TEL:0123'), ParsedType.phone);
      expect(_qr('tel:'), ParsedType.text);
    });

    test('email: mailto:, MATMSG: or a bare address (RES-7)', () {
      expect(_qr('mailto:someone@example.com'), ParsedType.email);
      expect(_qr('MAILTO:someone@example.com?subject=Hi'), ParsedType.email);
      expect(
        _qr('MATMSG:TO:someone@example.com;SUB:Hi;BODY:Hello;;'),
        ParsedType.email,
      );
      expect(_qr('someone@example.com'), ParsedType.email);
      expect(_qr('first.last+tag@mail.example.co.uk'), ParsedType.email);
    });

    test(
      'an address with no domain dot, or with a scheme, is not an email',
      () {
        expect(_qr('someone@localhost'), ParsedType.text);
        expect(_qr('https://someone@example.com'), ParsedType.url);
        expect(_qr('mailto:'), ParsedType.text);
      },
    );

    test('SMS: SMSTO:, sms:, MMSTO: and mms: (RES-7)', () {
      expect(_qr('SMSTO:+15551234567:Running late'), ParsedType.sms);
      expect(_qr('smsto:+15551234567'), ParsedType.sms);
      expect(_qr('sms:+15551234567?body=Hi'), ParsedType.sms);
      expect(_qr('MMSTO:+15551234567:Photo'), ParsedType.sms);
      expect(_qr('mms:+15551234567'), ParsedType.sms);
      expect(_qr('SMSTO:'), ParsedType.text);
    });

    test('location: geo: (RES-8)', () {
      expect(_qr('geo:37.786971,-122.399677'), ParsedType.geo);
      expect(_qr('GEO:0,0?q=Cafe'), ParsedType.geo);
      expect(_qr('geo:'), ParsedType.text);
    });

    test('contact: BEGIN:VCARD or MECARD: (RES-6)', () {
      expect(
        _qr('BEGIN:VCARD\nVERSION:3.0\nFN:Ada Lovelace\nEND:VCARD'),
        ParsedType.contact,
      );
      expect(_qr('begin:vcard\r\nfn:Ada\r\nend:vcard'), ParsedType.contact);
      expect(_qr('MECARD:N:Lovelace,Ada;TEL:+441234;;'), ParsedType.contact);
    });

    test('a byte-order mark or leading blank line before a header is ignored '
        '(RES-6)', () {
      expect(_qr('﻿BEGIN:VCARD\nFN:Ada\nEND:VCARD'), ParsedType.contact);
      expect(
        _qr('\n  BEGIN:VEVENT\nSUMMARY:Party\nEND:VEVENT'),
        ParsedType.event,
      );
    });

    test('event: BEGIN:VEVENT or BEGIN:VCALENDAR (RES-6)', () {
      expect(
        _qr(
          'BEGIN:VEVENT\nSUMMARY:Launch\nDTSTART:20261113T090000\nEND:VEVENT',
        ),
        ParsedType.event,
      );
      expect(
        _qr(
          'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nEND:VEVENT\n'
          'END:VCALENDAR',
        ),
        ParsedType.event,
      );
    });

    test('product: any EAN or UPC code (RES-9)', () {
      for (final Symbology format in <Symbology>[
        Symbology.ean13,
        Symbology.ean8,
        Symbology.upcA,
        Symbology.upcE,
      ]) {
        expect(
          classifyPayload('5901234123457', symbology: format),
          ParsedType.product,
          reason: format.id,
        );
      }
    });

    test('a product symbology with the right digit count but a wrong check '
        'digit is not a product (RES-9, shared with parsePayload via '
        'isValidProductCode)', () {
      // '5901234123457' is a valid EAN-13 (used above); flipping its last
      // digit breaks the check digit.
      expect(
        classifyPayload('5901234123458', symbology: Symbology.ean13),
        ParsedType.text,
      );
      // A valid UPC-A with its check digit flipped.
      expect(
        classifyPayload('036000291453', symbology: Symbology.upcA),
        ParsedType.text,
      );
    });

    test('a product symbology whose digit count does not match the format is '
        'still trusted, check digit unchecked (RES-9)', () {
      // Same 13-digit payload as the loop above, under formats whose own
      // length (8 or 12) it doesn't match: still a product, since the
      // check digit is only verified when the length lines up.
      expect(
        classifyPayload('5901234123457', symbology: Symbology.ean8),
        ParsedType.product,
      );
      expect(
        classifyPayload('5901234123457', symbology: Symbology.upcA),
        ParsedType.product,
      );
    });

    test('the same digits in a QR code or Code 128 are text (RES-9)', () {
      expect(_qr('5901234123457'), ParsedType.text);
      expect(
        classifyPayload('5901234123457', symbology: Symbology.code128),
        ParsedType.text,
      );
    });

    test('a link in a 1D code is still a link (LINK-1)', () {
      expect(
        classifyPayload('https://example.com', symbology: Symbology.code128),
        ParsedType.url,
      );
    });

    test('text: anything that fits no other type', () {
      expect(_qr('Hello, world'), ParsedType.text);
      expect(_qr('Note: meeting at 5'), ParsedType.text);
    });

    test('unknown: an empty or blank payload (RES-13)', () {
      expect(_qr(''), ParsedType.unknown);
      expect(_qr('   \n\t'), ParsedType.unknown);
      expect(
        classifyPayload('', symbology: Symbology.ean13),
        ParsedType.unknown,
      );
    });

    test(
      'unknown: a binary payload, whatever its text looks like (RES-13)',
      () {
        expect(
          classifyPayload(
            'https://example.com',
            symbology: Symbology.qr,
            isBinary: true,
          ),
          ParsedType.unknown,
        );
      },
    );
  });

  group('symbologyFromDecoderName', () {
    test("maps each of the scanner's format names (SCAN-9)", () {
      const Map<String, Symbology> expected = <String, Symbology>{
        'qrCode': Symbology.qr,
        'dataMatrix': Symbology.dataMatrix,
        'pdf417': Symbology.pdf417,
        'aztec': Symbology.aztec,
        'code128': Symbology.code128,
        'code39': Symbology.code39,
        'code93': Symbology.code93,
        'codabar': Symbology.codabar,
        'itf': Symbology.itf,
        'itf14': Symbology.itf,
        'itf2of5': Symbology.itf,
        'ean13': Symbology.ean13,
        'ean8': Symbology.ean8,
        'upcA': Symbology.upcA,
        'upcE': Symbology.upcE,
      };
      expected.forEach((String name, Symbology format) {
        expect(symbologyFromDecoderName(name), format, reason: name);
      });
    });

    test('reads the stored ids too (DATA-1)', () {
      for (final Symbology format in Symbology.values) {
        expect(symbologyFromDecoderName(format.id), format, reason: format.id);
      }
    });

    test('a format SCAN-9 does not promise, or no known format, is unknown '
        '(SCAN-9)', () {
      expect(symbologyFromDecoderName('microQrCode'), Symbology.unknown);
      expect(symbologyFromDecoderName('maxiCode'), Symbology.unknown);
      expect(symbologyFromDecoderName('dataBarExpanded'), Symbology.unknown);
      expect(symbologyFromDecoderName('all'), Symbology.unknown);
      expect(symbologyFromDecoderName(''), Symbology.unknown);
    });
  });

  group('typedSymbologyOf', () {
    test('a barcode number with a valid check digit is that barcode '
        '(SCAN-12, RES-9)', () {
      expect(typedSymbologyOf('5901234123457'), Symbology.ean13);
      expect(typedSymbologyOf('036000291452'), Symbology.upcA);
      expect(typedSymbologyOf('96385074'), Symbology.ean8);
      expect(typedSymbologyOf(' 5901234123457 '), Symbology.ean13);
    });

    test('a wrong check digit, another length or any text is unknown '
        '(SCAN-12)', () {
      expect(typedSymbologyOf('5901234123458'), Symbology.unknown);
      expect(typedSymbologyOf('12345'), Symbology.unknown);
      expect(typedSymbologyOf('590-1234-12345-7'), Symbology.unknown);
      expect(typedSymbologyOf('https://example.com'), Symbology.unknown);
      expect(typedSymbologyOf(''), Symbology.unknown);
    });
  });

  group('sensitiveFieldsOf', () {
    test('a Wi-Fi record flags its password (DATA-5, HIS-7)', () {
      expect(sensitiveFieldsOf(ParsedType.wifi), <String>[
        SensitiveFieldKeys.wifiPassword,
      ]);
    });

    test('no other type flags anything (DATA-5)', () {
      for (final ParsedType type in ParsedType.values) {
        if (type == ParsedType.wifi) {
          continue;
        }
        expect(sensitiveFieldsOf(type), isEmpty, reason: type.id);
      }
    });
  });

  test('isProductSymbology names exactly the retail codes (RES-9)', () {
    expect(Symbology.values.where(isProductSymbology).toSet(), <Symbology>{
      Symbology.ean13,
      Symbology.ean8,
      Symbology.upcA,
      Symbology.upcE,
    });
  });

  group('maskSensitive (DATA-5, SCAN-13)', () {
    test('hides a Wi-Fi password and keeps the rest', () {
      expect(
        maskSensitive('WIFI:T:WPA;S:TestNet;P:secret123;;', ParsedType.wifi),
        'WIFI:T:WPA;S:TestNet;P:$maskedSecret;;',
      );
    });

    test('hides the password wherever the field sits, even first', () {
      expect(
        maskSensitive('WIFI:P:hunter2;S:Home;T:WPA;;', ParsedType.wifi),
        'WIFI:P:$maskedSecret;S:Home;T:WPA;;',
      );
    });

    test('treats an escaped semicolon as part of the password', () {
      expect(
        maskSensitive(r'WIFI:S:Cafe;P:pa\;ss;;', ParsedType.wifi),
        'WIFI:S:Cafe;P:$maskedSecret;;',
      );
    });

    test('leaves an open network with no password as it is', () {
      expect(
        maskSensitive('WIFI:T:nopass;S:Guest;P:;;', ParsedType.wifi),
        'WIFI:T:nopass;S:Guest;P:;;',
      );
    });

    test('never touches a payload of another type', () {
      const String link = 'https://example.com/?P:secret;x';
      expect(maskSensitive(link, ParsedType.url), link);
    });
  });

  group('agrees with parsePayload (lib/parsers/payload_parser.dart)', () {
    test('the full parser never names a different type than this classifier '
        'does, for every kind this file exercises', () {
      const List<(String, Symbology)> samples = <(String, Symbology)>[
        ('https://example.com', Symbology.qr),
        // LINK-1: userinfo, IP hosts (v4 and bracketed v6) and a
        // non-default port, none of which change the type.
        ('https://user@example.com', Symbology.qr),
        ('http://192.168.1.1:8080/x', Symbology.qr),
        ('https://[2001:db8::1]/', Symbology.qr),
        // LINK-5: every blocked scheme, both cases.
        ('javascript:alert(1)', Symbology.qr),
        ('JavaScript:alert(1)', Symbology.qr),
        ('data:text/plain;base64,SGVsbG8=', Symbology.qr),
        ('file:///sdcard/secret.txt', Symbology.qr),
        ('intent://scan/#Intent;scheme=zxing;end', Symbology.qr),
        ('content://com.example.provider/item/1', Symbology.qr),
        ('WIFI:T:WPA;S:Home;P:secret;;', Symbology.qr),
        ('BEGIN:VCARD\nFN:Ada\nEND:VCARD', Symbology.qr),
        ('MECARD:N:Lovelace,Ada;TEL:+441234;;', Symbology.qr),
        (
          'BEGIN:VEVENT\nSUMMARY:Launch\nDTSTART:20261113T090000\nEND:VEVENT',
          Symbology.qr,
        ),
        ('tel:+15551234567', Symbology.qr),
        ('SMSTO:+15551234567:Running late', Symbology.qr),
        ('mailto:someone@example.com?subject=Hi', Symbology.qr),
        ('MATMSG:TO:someone@example.com;SUB:Hi;BODY:Hello;;', Symbology.qr),
        ('someone@example.com', Symbology.qr),
        ('geo:37.786971,-122.399677', Symbology.qr),
        ('Hello, world', Symbology.qr),
        ('', Symbology.qr),
        // The check-digit gate both share (isValidProductCode):
        ('5901234123457', Symbology.ean13),
        ('5901234123458', Symbology.ean13),
        ('5901234123457', Symbology.ean8),
      ];
      for (final (String payload, Symbology symbology) in samples) {
        expect(
          parsePayload(payload, symbology: symbology, isBinary: false).type,
          classifyPayload(payload, symbology: symbology),
          reason: '$symbology "$payload"',
        );
      }
    });
  });
}
