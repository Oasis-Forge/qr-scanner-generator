import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/payload_classifier.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/state/scan_outcome.dart';

void main() {
  group('ScanChoice, a row of the several-codes list (SCAN-13)', () {
    test('DATA-5: a Wi-Fi row never shows the password', () {
      final ScanChoice row = ScanChoice.of(
        const CodeDetection(
          payload: 'WIFI:T:WPA;S:TestNet;P:secret123;;',
          symbology: 'qr',
        ),
      );

      expect(row.parsedType, ParsedType.wifi);
      expect(row.preview, isNot(contains('secret123')));
      expect(row.preview, contains('S:TestNet'));
      expect(row.preview, contains(maskedSecret));
      // Only the row is masked: the code itself still carries the password,
      // so picking the row opens the real content (RES-3).
      expect(row.detection.payload, contains('secret123'));
    });

    test('shows the first 40 characters of a long link, marked as cut', () {
      final ScanChoice row = ScanChoice.of(
        const CodeDetection(
          payload: 'https://example.com/a/very/long/path/that/keeps/going',
          symbology: 'qr',
        ),
      );

      expect(row.preview, 'https://example.com/a/very/long/path/tha');
      expect(row.preview.length, ScanChoice.previewLength);
      expect(row.isPreviewTruncated, isTrue);
    });
  });
}
