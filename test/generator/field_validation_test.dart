import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/field_validation.dart';
import 'package:qrscanner/parsers/text_encoding.dart';

void main() {
  group('cleanGeneratorPhone (GEN-7)', () {
    test('strips spaces, dashes and brackets', () {
      expect(cleanGeneratorPhone('+1 (202) 555-0102'), '+12025550102');
    });

    test('a leading + survives; one anywhere else does not', () {
      expect(cleanGeneratorPhone('+44 20 7946 0958'), '+442079460958');
      expect(cleanGeneratorPhone('020 7946+0958'), '02079460958');
    });

    test('plain digits need no cleaning', () {
      expect(cleanGeneratorPhone('12025550102'), '12025550102');
    });

    test('leading and trailing whitespace is trimmed first', () {
      expect(cleanGeneratorPhone('  +1 555 0102  '), '+15550102');
    });
  });

  group('isValidGeneratorPhone (GEN-7)', () {
    test('3 to 15 digits, with or without a leading +, is valid', () {
      expect(isValidGeneratorPhone('123'), isTrue);
      expect(isValidGeneratorPhone('+123'), isTrue);
      expect(isValidGeneratorPhone('123456789012345'), isTrue);
    });

    test('fewer than 3 digits is invalid', () {
      expect(isValidGeneratorPhone('12'), isFalse);
      expect(isValidGeneratorPhone(''), isFalse);
    });

    test('more than 15 digits is invalid', () {
      expect(isValidGeneratorPhone('1234567890123456'), isFalse);
    });

    test('punctuation does not count toward the digit limits', () {
      expect(isValidGeneratorPhone('+1 (202) 555-0102'), isTrue);
    });
  });

  group('isValidGeneratorEmail (GEN-8)', () {
    test('a plain address is valid', () {
      expect(isValidGeneratorEmail('a@example.com'), isTrue);
    });

    test('no @ is invalid', () {
      expect(isValidGeneratorEmail('example.com'), isFalse);
    });

    test('no domain dot is invalid', () {
      expect(isValidGeneratorEmail('a@example'), isFalse);
    });

    test('whitespace anywhere is invalid', () {
      expect(isValidGeneratorEmail('a b@example.com'), isFalse);
    });

    test('surrounding whitespace is trimmed first', () {
      expect(isValidGeneratorEmail('  a@example.com  '), isTrue);
    });
  });

  group('escapeGeneratorField (GEN-5, GEN-6)', () {
    test('escapes backslash, semicolon, comma, colon and double quote', () {
      expect(escapeGeneratorField(r'a\b;c,d:e"f'), r'a\\b\;c\,d\:e\"f');
    });

    test('leaves everything else, Arabic and emoji included, untouched', () {
      expect(escapeGeneratorField('مرحبا 😀 hello'), 'مرحبا 😀 hello');
    });

    test('every escaped character round-trips through the parser\'s own '
        'unescaping', () {
      const String original = r'a\b;c,d:e"f plain text مرحبا 😀';
      final String escaped = escapeGeneratorField(original);
      expect(unescapeBackslashes(escaped), original);
    });

    test('one field survives being split out of a WIFI/MECARD-shaped '
        'record', () {
      const String ssid = r'Net;Name,With:Punctuation"\And\More';
      final List<EscapedField> fields = parseEscapedFields(
        'S:${escapeGeneratorField(ssid)}',
      );
      expect(fields, hasLength(1));
      expect(fields.single.key, 'S');
      expect(fields.single.value, ssid);
    });
  });
}
