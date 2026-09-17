import 'package:qrscanner/services/camera_scanner.dart';

/// What one decode pass over a still image found.
///
/// An empty result is "No code found", which the screen answers with one hint
/// and "Try another photo" / "Type a code" (SCAN-11). Two or more codes are all
/// returned, so the app lists them instead of guessing (SCAN-13).
class ImageDecodeResult {
  const ImageDecodeResult(this.detections);

  /// Nothing decoded: "No code found" (SCAN-11).
  const ImageDecodeResult.noCodeFound() : detections = const <CodeDetection>[];

  final List<CodeDetection> detections;

  /// Whether the image held at least one readable code (DATA-8: only a code
  /// that reaches a result screen counts as a successful scan).
  bool get foundCode => detections.isNotEmpty;

  /// Whether the pass found two or more codes, so they have to be listed
  /// (SCAN-13).
  bool get hasSeveralCodes => detections.length > 1;
}

/// Decoding codes out of a still image: a picked photo (SCAN-11) or a shared one
/// (ENTRY-2).
///
/// The image itself is never stored, only what it decoded to (DATA-3).
abstract class ImageDecoder {
  /// Decodes every code in the image at [path].
  ///
  /// A file that is missing, unreadable or holds no code comes back as
  /// [ImageDecodeResult.noCodeFound]; this never throws, because "No code found"
  /// is an answer the screen shows, not an error (SCAN-11).
  Future<ImageDecodeResult> decodeFile(String path);
}

/// An [ImageDecoder] that reads no file.
///
/// It records every path in [calls] and reports [result], "No code found" by
/// default, so SCAN-11's empty state is what a test sees unless it seeds a
/// detection.
class NoopImageDecoder implements ImageDecoder {
  NoopImageDecoder({this.result = const ImageDecodeResult.noCodeFound()});

  /// Every call made, in order, such as `'decodeFile: /photos/a.png'`.
  final List<String> calls = <String>[];

  /// What [decodeFile] reports for any path.
  final ImageDecodeResult result;

  @override
  Future<ImageDecodeResult> decodeFile(String path) async {
    calls.add('decodeFile: $path');
    return result;
  }
}
