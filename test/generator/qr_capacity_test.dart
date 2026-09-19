import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/qr_capacity.dart';

void main() {
  group('capacity at error correction M (GEN-12)', () {
    test('version 1 holds 14 bytes, the published table value', () {
      expect(qrMaxByteCapacityAtErrorCorrectionM(1), 14);
    });

    test('version 9 (the last 8-bit count indicator version) holds 180', () {
      // ISO/IEC 18004 table 7: 182 data codewords, less the mode and 8-bit
      // count indicator.
      expect(qrMaxByteCapacityAtErrorCorrectionM(9), 180);
    });

    test('version 10 (the first 16-bit count indicator version) holds 213', () {
      // 216 data codewords, less the mode and 16-bit count indicator.
      expect(qrMaxByteCapacityAtErrorCorrectionM(10), 213);
    });

    test('version 40 holds 2331 bytes, the published table value', () {
      expect(qrMaxByteCapacityAtErrorCorrectionM(40), 2331);
    });

    test("qrMaxCapacityBytes is version 40's own capacity", () {
      expect(qrMaxCapacityBytes, 2331);
    });

    test('a version outside 1-40 throws', () {
      expect(() => qrMaxByteCapacityAtErrorCorrectionM(0), throwsRangeError);
      expect(() => qrMaxByteCapacityAtErrorCorrectionM(41), throwsRangeError);
    });
  });

  group('the version a byte length needs', () {
    test('1 byte needs version 1', () {
      expect(qrVersionForByteLength(1), 1);
    });

    test("exactly version 1's capacity still fits version 1", () {
      expect(qrVersionForByteLength(14), 1);
    });

    test("one byte over version 1's capacity needs version 2", () {
      expect(qrVersionForByteLength(15), 2);
    });

    test("exactly version 9's capacity fits version 9, not 10", () {
      expect(qrVersionForByteLength(180), 9);
    });

    test("one byte over version 9's capacity needs version 10", () {
      expect(qrVersionForByteLength(181), 10);
    });

    test('the maximum capacity fits version 40', () {
      expect(qrVersionForByteLength(2331), 40);
    });

    test('over the maximum capacity still returns version 40', () {
      // GEN-12 blocks content this large before asking; this stays total.
      expect(qrVersionForByteLength(9999), 40);
    });

    test('zero bytes still needs a version to render', () {
      expect(qrVersionForByteLength(0), 1);
    });
  });

  group('module count', () {
    test('version 1 is 21 x 21 modules', () {
      expect(qrModuleCountForVersion(1), 21);
    });

    test('version 40 is 177 x 177 modules', () {
      expect(qrModuleCountForVersion(40), 177);
    });

    test('grows by 4 modules per version', () {
      for (int version = 1; version < 40; version++) {
        expect(
          qrModuleCountForVersion(version + 1) -
              qrModuleCountForVersion(version),
          4,
        );
      }
    });

    test('qrModuleCountForByteLength composes version and module count', () {
      expect(qrModuleCountForByteLength(1), qrModuleCountForVersion(1));
      expect(qrModuleCountForByteLength(2331), qrModuleCountForVersion(40));
    });
  });
}
