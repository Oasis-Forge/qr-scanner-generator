import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/parsers/product_parser.dart';

void main() {
  group('isValidProductCode (RES-9)', () {
    test('a right-length EAN-13 with a good check digit is valid', () {
      expect(isValidProductCode('5901234123457', Symbology.ean13), isTrue);
      expect(isValidProductCode('4006381333931', Symbology.ean13), isTrue);
    });

    test('a right-length EAN-13 with a bad check digit is not valid', () {
      expect(isValidProductCode('5901234123458', Symbology.ean13), isFalse);
    });

    test('UPC-A: a good and a bad check digit', () {
      expect(isValidProductCode('036000291452', Symbology.upcA), isTrue);
      expect(isValidProductCode('036000291453', Symbology.upcA), isFalse);
    });

    test('EAN-8: a good and a bad check digit', () {
      expect(isValidProductCode('96385074', Symbology.ean8), isTrue);
      expect(isValidProductCode('96385075', Symbology.ean8), isFalse);
    });

    test(
      'ISBN digits (978/979) are EAN-13 check digits, no different rule',
      () {
        expect(isValidProductCode('9780306406157', Symbology.ean13), isTrue);
      },
    );

    test('a length that does not match the symbology is trusted as-is', () {
      // Same digits as the EAN-13 case above, but under a symbology whose
      // own length (8 or 12) they don't match: never checked, so still a
      // product. (payload_classifier_test.dart's own product test relies on
      // this for ean8/upcA/upcE with a 13-digit payload.)
      expect(isValidProductCode('5901234123457', Symbology.ean8), isTrue);
      expect(isValidProductCode('5901234123457', Symbology.upcA), isTrue);
    });

    test('UPC-E is always trusted: this build does not expand it', () {
      expect(isValidProductCode('01234565', Symbology.upcE), isTrue);
      expect(isValidProductCode('00000000', Symbology.upcE), isTrue);
    });

    test('non-digit text of the right length is trusted as-is', () {
      expect(isValidProductCode('590123412345X', Symbology.ean13), isTrue);
    });

    test('a non-product symbology is trusted (never called in practice)', () {
      expect(isValidProductCode('5901234123458', Symbology.qr), isTrue);
    });
  });

  group('buildProduct', () {
    test('names the format matching the symbology', () {
      expect(
        buildProduct('4006381333931', Symbology.ean13).format,
        ProductCodeFormat.ean13,
      );
      expect(
        buildProduct('96385074', Symbology.ean8).format,
        ProductCodeFormat.ean8,
      );
      expect(
        buildProduct('036000291452', Symbology.upcA).format,
        ProductCodeFormat.upcA,
      );
      expect(
        buildProduct('01234565', Symbology.upcE).format,
        ProductCodeFormat.upcE,
      );
    });

    test('an EAN-13 starting 978 or 979 is ISBN', () {
      expect(
        buildProduct('9780306406157', Symbology.ean13).format,
        ProductCodeFormat.isbn,
      );
      expect(
        buildProduct('9790306406156', Symbology.ean13).format,
        ProductCodeFormat.isbn,
      );
    });

    test('an EAN-13 not starting 978/979 is plain EAN-13', () {
      expect(
        buildProduct('4006381333931', Symbology.ean13).format,
        ProductCodeFormat.ean13,
      );
    });

    test('keeps the code exactly as scanned', () {
      expect(
        buildProduct('4006381333931', Symbology.ean13).code,
        '4006381333931',
      );
    });
  });
}
