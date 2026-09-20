// Draws the launcher icon, its adaptive layers and the splash images into
// assets/icon/ (ICON-1). After changing `app_icon_painter.dart`, run:
//   flutter test tool/render_app_icons_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
// It lives outside test/ so the regular test run doesn't rewrite the assets.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_icon_painter.dart';

void main() {
  // File name → (square size in pixels, painter).
  const Map<String, (int, AppIconPainter)> outputs =
      <String, (int, AppIconPainter)>{
        // The square icon for launchers that don't use adaptive layers. It is
        // masked to a shape, so the mark sits well inside it.
        'icon.png': (1024, AppIconPainter(scale: 0.55, background: true)),
        // Android's adaptive layers: the chassis alone, the mark alone, and
        // the mark again for themed icons. The generator adds no inset of its
        // own, so `adaptiveMarkScale` is the drawn size exactly.
        'icon_background.png': (
          1024,
          AppIconPainter(scale: 1, background: true, glyph: false),
        ),
        'icon_foreground.png': (1024, AppIconPainter(scale: adaptiveMarkScale)),
        'icon_monochrome.png': (
          1024,
          AppIconPainter(scale: adaptiveMarkScale, monochrome: true),
        ),
        // The splash mark, on the chassis the yaml sets (ICON-6). Nothing
        // masks this one, so it is drawn at its own size.
        'splash.png': (768, AppIconPainter(scale: 0.6)),
        // Android 12 masks the splash icon to a circle two thirds across, so
        // the mark is kept well inside that, as on the launcher layers.
        'splash_android12.png': (1152, AppIconPainter(scale: 0.42)),
      };

  testWidgets('renders the app icon and splash images', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);
    Directory('assets/icon').createSync(recursive: true);

    for (final MapEntry<String, (int, AppIconPainter)> entry
        in outputs.entries) {
      final (int pixels, AppIconPainter painter) = entry.value;
      final Size size = Size.square(pixels.toDouble());
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      final GlobalKey boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomPaint(painter: painter, size: size),
        ),
      );

      await tester.runAsync(() async {
        final RenderRepaintBoundary render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final ui.Image image = await render.toImage();
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        File('assets/icon/${entry.key}')
            .writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  });
}
