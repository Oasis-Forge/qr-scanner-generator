import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/device/mlkit_image_decoder.dart';
import 'package:qrscanner/services/image_decoder.dart';

/// The scanner plugin's method channel, answered here instead of ML Kit.
const MethodChannel _scannerChannel = MethodChannel(
  'dev.steenbakker.mobile_scanner/scanner/method',
);

/// The plugin's raw format values for the SCAN-9 set, in `scan9Formats` order.
const List<int> _scan9RawFormats = <int>[
  256, // QR
  16, // Data Matrix
  2048, // PDF417
  4096, // Aztec
  1, // Code 128
  2, // Code 39
  4, // Code 93
  8, // Codabar
  128, // ITF
  32, // EAN-13
  64, // EAN-8
  512, // UPC-A
  1024, // UPC-E
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;

  void answerWith(Future<Object?> Function(MethodCall call) answer) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_scannerChannel, (MethodCall call) {
          calls.add(call);
          return answer(call);
        });
  }

  setUp(() {
    calls = <MethodCall>[];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_scannerChannel, null);
  });

  test('lists every SCAN-9 code in a photo and drops a Micro QR code (SCAN-13, SCAN-9)', () async {
    answerWith(
      (MethodCall call) async => <String, Object?>{
        'name': 'barcode',
        'data': <Map<String, Object?>>[
          <String, Object?>{'format': 256, 'rawValue': 'https://example.com'},
          <String, Object?>{'format': 16384, 'rawValue': 'MICRO'},
          <String, Object?>{'format': 32, 'rawValue': '5901234123457'},
        ],
      },
    );

    final ImageDecodeResult result = await MlkitImageDecoder().decodeFile(
      '/photos/two-codes.png',
    );

    expect(result.hasSeveralCodes, isTrue);
    expect(result.detections, const <CodeDetection>[
      CodeDetection(payload: 'https://example.com', symbology: 'qr'),
      CodeDetection(payload: '5901234123457', symbology: 'ean13'),
    ]);
    // ML Kit was asked for the photo at that path, in SCAN-9's formats only.
    expect(calls.single.method, 'analyzeImage');
    expect(calls.single.arguments, <String, Object?>{
      'filePath': '/photos/two-codes.png',
      'formats': _scan9RawFormats,
    });
  });

  test('a photo with no code is "No code found" (SCAN-11)', () async {
    answerWith(
      (MethodCall call) async => <String, Object?>{
        'name': 'barcode',
        'data': <Object?>[],
      },
    );

    final ImageDecodeResult result = await MlkitImageDecoder().decodeFile(
      '/photos/cat.jpg',
    );

    expect(result.foundCode, isFalse);
    expect(result.detections, isEmpty);
  });

  test('a photo holding only formats outside SCAN-9 is "No code found" (SCAN-9, SCAN-11)', () async {
    answerWith(
      (MethodCall call) async => <String, Object?>{
        'name': 'barcode',
        'data': <Map<String, Object?>>[
          <String, Object?>{'format': 32768, 'rawValue': '0101234567890128'},
        ],
      },
    );

    final ImageDecodeResult result = await MlkitImageDecoder().decodeFile(
      '/photos/databar.png',
    );

    expect(result.foundCode, isFalse);
  });

  test(
    'a file ML Kit cannot open is "No code found", never an error (SCAN-11)',
    () async {
      answerWith(
        (MethodCall call) async => throw PlatformException(
          code: 'MOBILE_SCANNER_BARCODE_ERROR',
          message: 'No valid image.',
        ),
      );

      final ImageDecodeResult result = await MlkitImageDecoder().decodeFile(
        '/does/not/exist.png',
      );

      expect(result.foundCode, isFalse);
    },
  );

  test(
    'a call that answers nothing at all is "No code found" (SCAN-11)',
    () async {
      answerWith((MethodCall call) async => null);

      final ImageDecodeResult result = await MlkitImageDecoder().decodeFile(
        '/photos/empty.png',
      );

      expect(result.foundCode, isFalse);
    },
  );
}
