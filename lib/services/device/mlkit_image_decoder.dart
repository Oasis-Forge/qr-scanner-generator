import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/device/mobile_scanner_camera.dart';
import 'package:qrscanner/services/image_decoder.dart';

/// The real [ImageDecoder]: bundled ML Kit reading a photo from its file path
/// (SCAN-11, ENTRY-2).
///
/// It runs `analyzeImage` on a plugin controller that is never started, so no
/// camera opens and no permission is needed; spike S2 found that works, and
/// that PNG, JPEG, a light-on-dark code and a code inside a screenshot all
/// decode on API 37.
///
/// Every code the photo holds comes back, in SCAN-9's formats only and mapped
/// the way the live camera maps them, so two or more are listed rather than
/// one picked (SCAN-13). The photo itself is never kept (DATA-3).
class MlkitImageDecoder implements ImageDecoder {
  /// Never started: `analyzeImage` needs no camera session (spike S2).
  final ms.MobileScannerController _analyzer = ms.MobileScannerController(
    autoStart: false,
    formats: scan9Formats,
  );

  @override
  Future<ImageDecodeResult> decodeFile(String path) async {
    final ms.BarcodeCapture? capture;
    try {
      capture = await _analyzer.analyzeImage(path, formats: scan9Formats);
    } on Exception {
      // A missing or unreadable file, or one ML Kit can't open, is the same
      // answer as a photo with no code: "No code found" (SCAN-11).
      return const ImageDecodeResult.noCodeFound();
    } on UnsupportedError {
      return const ImageDecodeResult.noCodeFound();
    }
    if (capture == null) {
      return const ImageDecodeResult.noCodeFound();
    }
    final List<CodeDetection> detections = detectionsFromCapture(capture);
    return detections.isEmpty
        ? const ImageDecodeResult.noCodeFound()
        : ImageDecodeResult(detections);
  }
}
