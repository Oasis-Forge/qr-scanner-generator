import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart' as bc;

import 'qr_capacity.dart';

/// STY-1's PNG size: 1024 x 1024 (SAVE-2).
const int qrImageSize = 1024;

/// STY-1's quiet zone, in modules, on every side of the code.
const int qrQuietZoneModules = 4;

/// What [renderQrPng] drew.
class QrRenderResult {
  const QrRenderResult({
    required this.png,
    required this.moduleCount,
    required this.pixelsPerModule,
  });

  /// The rendered code: a 1024 x 1024 PNG, black modules on white, with no
  /// anti-aliasing (STY-1, SAVE-2).
  final Uint8List png;

  /// The QR symbol's side length in modules (`qr_capacity.dart`).
  final int moduleCount;

  /// The whole number of pixels each module was drawn at (spike S13).
  final int pixelsPerModule;
}

/// STY-1: draws [payload] as a plain black-on-white QR code at error
/// correction M, 1024 x 1024 px, with a 4-module quiet zone.
///
/// Spike S13: `barcode_image` (the `barcode` package's own PNG helper)
/// widens every bar by 1 px, so this instead takes the `barcode` package's
/// own [bc.BarcodeBar] elements — at a width and height that are an exact,
/// whole multiple of the module count, so every bar comes out an integer
/// number of pixels wide — and paints them onto a `dart:ui` canvas itself,
/// with anti-aliasing off. The module size is chosen so the code plus its
/// quiet zone either fills the full 1024 px exactly or sits centred with a
/// whole-pixel margin; never a fractional one.
///
/// Throws whatever the `barcode` package throws (a [bc.BarcodeException],
/// in practice) if [payload] does not fit a QR symbol at all. GEN-12 blocks
/// Create before content ever gets this large, so in normal use this always
/// succeeds; [GeneratorState.create] still catches it, matching STY-5's
/// "clear state on ... failure".
Future<QrRenderResult> renderQrPng(String payload) async {
  final int byteLength = utf8.encode(payload).length;
  final int moduleCount = qrModuleCountForByteLength(byteLength);
  final int totalModules = moduleCount + qrQuietZoneModules * 2;
  final int pixelsPerModule = (qrImageSize ~/ totalModules).clamp(
    1,
    qrImageSize,
  );
  final int contentSize = totalModules * pixelsPerModule;
  final int margin = qrImageSize - contentSize;
  final double codeOffset = (margin ~/ 2 + qrQuietZoneModules * pixelsPerModule)
      .toDouble();
  final double codeSidePx = (moduleCount * pixelsPerModule).toDouble();
  final double imageSidePx = qrImageSize.toDouble();
  final ui.Rect imageRect = ui.Rect.fromLTWH(0, 0, imageSidePx, imageSidePx);

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder, imageRect);

  final ui.Paint background = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..isAntiAlias = false
    ..style = ui.PaintingStyle.fill;
  canvas.drawRect(imageRect, background);

  final ui.Paint foreground = ui.Paint()
    ..color = const ui.Color(0xFF000000)
    ..isAntiAlias = false
    ..style = ui.PaintingStyle.fill;
  final bc.Barcode qr = bc.Barcode.qrCode(
    errorCorrectLevel: bc.BarcodeQRCorrectionLevel.medium,
  );
  for (final bc.BarcodeElement element in qr.make(
    payload,
    width: codeSidePx,
    height: codeSidePx,
  )) {
    if (element is bc.BarcodeBar && element.black) {
      canvas.drawRect(
        ui.Rect.fromLTWH(
          codeOffset + element.left,
          codeOffset + element.top,
          element.width,
          element.height,
        ),
        foreground,
      );
    }
  }

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(qrImageSize, qrImageSize);
  try {
    const ui.ImageByteFormat imageByteFormat = ui.ImageByteFormat.png;
    final ByteData? bytes = await image.toByteData(format: imageByteFormat);
    if (bytes == null) {
      throw StateError('Could not encode the rendered QR code as a PNG.');
    }
    return QrRenderResult(
      png: bytes.buffer.asUint8List(),
      moduleCount: moduleCount,
      pixelsPerModule: pixelsPerModule,
    );
  } finally {
    image.dispose();
    picture.dispose();
  }
}
