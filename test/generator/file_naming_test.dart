import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/file_naming.dart';
import 'package:qrscanner/generator/generator_form.dart';
import 'package:qrscanner/models/record_enums.dart';

void main() {
  final DateTime at = DateTime(2026, 10, 16, 10, 15, 0);

  group('SAVE-4: <type>-<name>-<YYYYMMDD-HHmmss>.png', () {
    test('a type with no name field uses the type alone, matching the '
        "rule's own example", () {
      final String name = generatorFileName(
        type: ParsedType.phone,
        form: const PhoneForm(number: '+12025550102'),
        at: at,
      );
      expect(name, 'phone-20261016-101500.png');
    });

    test('text, email and SMS also use the type alone', () {
      expect(
        generatorFileName(
          type: ParsedType.text,
          form: const TextForm(text: 'hello'),
          at: at,
        ),
        'text-20261016-101500.png',
      );
      expect(
        generatorFileName(
          type: ParsedType.email,
          form: const EmailForm(to: 'a@example.com'),
          at: at,
        ),
        'email-20261016-101500.png',
      );
      expect(
        generatorFileName(
          type: ParsedType.sms,
          form: const SmsForm(number: '+12025550102', message: 'hi'),
          at: at,
        ),
        'sms-20261016-101500.png',
      );
    });

    test('a URL is named by its host', () {
      final String name = generatorFileName(
        type: ParsedType.url,
        form: const UrlForm(rawInput: 'example.com/path'),
        at: at,
      );
      expect(name, 'url-example-com-20261016-101500.png');
    });

    test('a Wi-Fi network is named by its SSID, never its password', () {
      final String name = generatorFileName(
        type: ParsedType.wifi,
        form: const WifiForm(ssid: 'Home Network', password: 'super-secret'),
        at: at,
      );
      expect(name, 'wifi-Home-Network-20261016-101500.png');
      expect(name, isNot(contains('secret')));
    });

    test('a contact is named by its name, never its phone or email', () {
      final String name = generatorFileName(
        type: ParsedType.contact,
        form: const ContactForm(
          name: 'Ada Lovelace',
          phone: '+12025550102',
          email: 'ada@example.com',
        ),
        at: at,
      );
      expect(name, 'contact-Ada-Lovelace-20261016-101500.png');
      expect(name, isNot(contains('2025550102')));
      expect(name, isNot(contains('example')));
    });
  });

  group('ASCII only, non-ASCII dropped', () {
    test(
      'an all-Arabic SSID sanitises to nothing, so the type alone is used',
      () {
        final String name = generatorFileName(
          type: ParsedType.wifi,
          form: const WifiForm(ssid: 'شبكة المنزل'),
          at: at,
        );
        expect(name, 'wifi-20261016-101500.png');
      },
    );

    test('emoji are dropped but ASCII letters around them survive', () {
      final String name = generatorFileName(
        type: ParsedType.wifi,
        form: const WifiForm(ssid: 'Cafe 😀 Wifi'),
        at: at,
      );
      expect(name, 'wifi-Cafe-Wifi-20261016-101500.png');
    });

    test('every character of the result is ASCII', () {
      final String name = generatorFileName(
        type: ParsedType.contact,
        form: const ContactForm(name: 'Ahmed أحمد Özkan'),
        at: at,
      );
      expect(name.codeUnits.every((int unit) => unit < 128), isTrue);
    });
  });

  group('at most 60 characters', () {
    test('a very long name is truncated, not the type or the timestamp', () {
      final String longName = 'a' * 100;
      final String name = generatorFileName(
        type: ParsedType.contact,
        form: ContactForm(name: longName),
        at: at,
      );
      expect(name.length, lessThanOrEqualTo(60));
      expect(name, startsWith('contact-'));
      expect(name, endsWith('-20261016-101500.png'));
    });

    test('the timestamp is always present in full', () {
      final String name = generatorFileName(
        type: ParsedType.contact,
        form: ContactForm(name: 'b' * 100),
        at: at,
      );
      expect(name, contains('20261016-101500'));
    });
  });

  group('the timestamp itself', () {
    test('uses local time and pads every component to two digits', () {
      final DateTime early = DateTime(2026, 1, 2, 3, 4, 5);
      final String name = generatorFileName(
        type: ParsedType.phone,
        form: const PhoneForm(number: '123'),
        at: early,
      );
      expect(name, 'phone-20260102-030405.png');
    });
  });
}
