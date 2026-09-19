import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/qr_capacity.dart';
import 'package:qrscanner/generator/qr_renderer.dart';

/// The whole-pixel module size [renderQrPng] must have chosen for
/// [moduleCount] modules, worked out the same way it does (spike S13): the
/// most whole pixels-per-module that still fit the code plus its quiet zone
/// inside [qrImageSize].
int _expectedPixelsPerModule(int moduleCount) {
  final int totalModules = moduleCount + qrQuietZoneModules * 2;
  return (qrImageSize ~/ totalModules).clamp(1, qrImageSize);
}

/// Where module (0, 0) of the code itself starts, in pixels from the image's
/// own top-left corner: past the centring margin and the quiet zone.
int _expectedCodeOffset(int moduleCount, int pixelsPerModule) {
  final int totalModules = moduleCount + qrQuietZoneModules * 2;
  final int contentSize = totalModules * pixelsPerModule;
  final int margin = qrImageSize - contentSize;
  return margin ~/ 2 + qrQuietZoneModules * pixelsPerModule;
}

/// Decodes [png] to raw, unpremultiplied RGBA, so a test can sample and
/// count individual pixels rather than trust another PNG decoder.
Future<ByteData> _rawRgbaOf(Uint8List png) async {
  final ui.Codec codec = await ui.instantiateImageCodec(png);
  final ui.FrameInfo frame = await codec.getNextFrame();
  try {
    final ByteData? bytes = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    expect(bytes, isNotNull, reason: 'the renderer produced a decodable PNG');
    return bytes!;
  } finally {
    frame.image.dispose();
    codec.dispose();
  }
}

/// Whether the pixel at module ([moduleX], [moduleY]) — sampled at its
/// centre, so a rounding edge never lands on a neighbouring module — is
/// black.
bool _isModuleBlack(
  ByteData rgba, {
  required int moduleX,
  required int moduleY,
  required int codeOffset,
  required int pixelsPerModule,
}) {
  final int x = codeOffset + moduleX * pixelsPerModule + pixelsPerModule ~/ 2;
  final int y = codeOffset + moduleY * pixelsPerModule + pixelsPerModule ~/ 2;
  final int byteOffset = (y * qrImageSize + x) * 4;
  // Opaque black is (0, 0, 0, 255); opaque white is (255, 255, 255, 255):
  // the red channel alone tells the two apart (STY-1: black on white only).
  return rgba.getUint8(byteOffset) == 0;
}

void main() {
  group('STY-1: a 1024 x 1024 PNG', () {
    test('is exactly 1024 x 1024 regardless of content length', () async {
      final QrRenderResult short = await renderQrPng('hi');
      final QrRenderResult long = await renderQrPng('x' * 500);
      for (final Uint8List png in <Uint8List>[short.png, long.png]) {
        final ui.Codec codec = await ui.instantiateImageCodec(png);
        final ui.FrameInfo frame = await codec.getNextFrame();
        expect(frame.image.width, qrImageSize);
        expect(frame.image.height, qrImageSize);
        frame.image.dispose();
        codec.dispose();
      }
    });

    test(
      'reports the module count and pixel size it actually drew at',
      () async {
        final QrRenderResult result = await renderQrPng('https://example.com');
        expect(result.moduleCount, qrModuleCountForByteLength(19));
        expect(
          result.pixelsPerModule,
          _expectedPixelsPerModule(result.moduleCount),
        );
      },
    );
  });

  group('spike S13: integer module widths, no anti-aliasing', () {
    test(
      'every pixel is pure black or pure white, never a blended grey',
      () async {
        final QrRenderResult result = await renderQrPng(
          'https://example.com/a/somewhat/longer/path?with=a-query',
        );
        final ByteData rgba = await _rawRgbaOf(result.png);
        for (int i = 0; i < rgba.lengthInBytes; i += 4) {
          final int r = rgba.getUint8(i);
          final int g = rgba.getUint8(i + 1);
          final int b = rgba.getUint8(i + 2);
          final int a = rgba.getUint8(i + 3);
          final bool pureBlack = r == 0 && g == 0 && b == 0;
          final bool pureWhite = r == 255 && g == 255 && b == 255;
          expect(
            pureBlack || pureWhite,
            isTrue,
            reason: 'pixel at byte $i is ($r, $g, $b), not pure black/white',
          );
          expect(a, 255);
        }
      },
    );
  });

  group('the quiet zone (STY-1)', () {
    test('the image border, well outside the code, is white', () async {
      final QrRenderResult result = await renderQrPng('https://example.com');
      final ByteData rgba = await _rawRgbaOf(result.png);
      expect(rgba.getUint8(0), 255); // the very first pixel, (0, 0)
      const int lastPixelOffset = (qrImageSize * qrImageSize - 1) * 4;
      expect(rgba.getUint8(lastPixelOffset), 255); // the very last pixel
    });
  });

  group('the finder patterns (ISO/IEC 18004): a known, fixed layout', () {
    test(
      'the top-left finder pattern matches the standard 7 x 7 shape',
      () async {
        const String payload = 'A';
        final QrRenderResult result = await renderQrPng(payload);
        final ByteData rgba = await _rawRgbaOf(result.png);
        final int codeOffset = _expectedCodeOffset(
          result.moduleCount,
          result.pixelsPerModule,
        );

        // ISO/IEC 18004 fig. 5: a solid outer ring, a white ring, a solid 3x3
        // centre. True where the finder pattern's own module is black.
        bool specSaysBlack(int row, int col) {
          if (row == 0 || row == 6 || col == 0 || col == 6) {
            return true;
          }
          return row >= 2 && row <= 4 && col >= 2 && col <= 4;
        }

        for (int row = 0; row < 7; row++) {
          for (int col = 0; col < 7; col++) {
            final bool isBlack = _isModuleBlack(
              rgba,
              moduleX: col,
              moduleY: row,
              codeOffset: codeOffset,
              pixelsPerModule: result.pixelsPerModule,
            );
            expect(
              isBlack,
              specSaysBlack(row, col),
              reason: 'finder pattern module (row $row, col $col)',
            );
          }
        }
      },
    );

    test(
      'module (0, 0) sits right after the quiet zone, not the margin',
      () async {
        final QrRenderResult result = await renderQrPng('A');
        final ByteData rgba = await _rawRgbaOf(result.png);
        final int codeOffset = _expectedCodeOffset(
          result.moduleCount,
          result.pixelsPerModule,
        );
        // The pixel just inside the quiet zone (one module before the code)
        // must be white; the finder pattern's own corner module must be
        // black. Together they pin down exactly where the quiet zone ends.
        final int quietZoneX = codeOffset - result.pixelsPerModule ~/ 2;
        expect(rgba.getUint8((codeOffset * qrImageSize + quietZoneX) * 4), 255);
        expect(
          _isModuleBlack(
            rgba,
            moduleX: 0,
            moduleY: 0,
            codeOffset: codeOffset,
            pixelsPerModule: result.pixelsPerModule,
          ),
          isTrue,
        );
      },
    );
  });

  group('failure (STY-5)', () {
    test('content over the maximum capacity throws rather than corrupting '
        'the image', () async {
      final String tooLong = 'x' * (qrMaxCapacityBytes + 1);
      await expectLater(renderQrPng(tooLong), throwsA(isA<Object>()));
    });
  });

  group('the drawn grid matches qr_capacity.dart at every version boundary '
      '(GEN-12, spike S13)', () {
    // Both sides of the v1/v2 and v9/v10 boundaries, and the largest code.
    for (final int bytes in <int>[14, 15, 180, 181, qrMaxCapacityBytes]) {
      test('$bytes bytes', () async {
        final QrRenderResult result = await renderQrPng('x' * bytes);
        expect(result.moduleCount, qrModuleCountForByteLength(bytes));
        final ByteData rgba = await _rawRgbaOf(result.png);
        final int n = result.moduleCount;
        final int ppm = result.pixelsPerModule;
        final int offset = _expectedCodeOffset(n, ppm);
        bool black(int x, int y) => _isModuleBlack(
          rgba,
          moduleX: x,
          moduleY: y,
          codeOffset: offset,
          pixelsPerModule: ppm,
        );

        // The three finder patterns' outer corners sit exactly on the grid's
        // corners, their separators are white, and the quiet zone starts
        // right after the last module: a different real version would move
        // all of these.
        expect(black(n - 1, 0), isTrue, reason: 'top-right finder corner');
        expect(black(n - 7, 0), isTrue, reason: 'top-right finder, left edge');
        expect(black(n - 8, 0), isFalse, reason: 'top-right separator');
        expect(black(0, n - 1), isTrue, reason: 'bottom-left finder corner');
        expect(black(0, n - 8), isFalse, reason: 'bottom-left separator');
        expect(black(n, 0), isFalse, reason: 'quiet zone after the code');
        expect(black(0, n), isFalse, reason: 'quiet zone below the code');
      });
    }
  });
}
