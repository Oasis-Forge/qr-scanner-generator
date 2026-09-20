// The mark has to survive being shrunk to a launcher tile (ICON-5). These
// tests assert the shapes rather than the pixels, so they hold on CI's Linux
// as well as the Windows the icons are drawn on.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/app_icon_painter.dart';

/// The rendered mark, with a reader for one pixel.
class _Rendered {
  const _Rendered(this.pixels, this.width);

  final ByteData pixels;
  final int width;

  Color at(double x, double y) {
    final int offset = (y.round() * width + x.round()) * 4;
    return Color.fromARGB(
      pixels.getUint8(offset + 3),
      pixels.getUint8(offset),
      pixels.getUint8(offset + 1),
      pixels.getUint8(offset + 2),
    );
  }
}

/// Nothing drawn: what the adaptive layers leave for the launcher to fill.
const Color _transparent = Color(0x00000000);

/// Paints [painter] onto a transparent square of [pixels] a side.
Future<_Rendered> _render(
  WidgetTester tester,
  int pixels,
  AppIconPainter painter,
) async {
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

  late final ByteData data;
  await tester.runAsync(() async {
    final RenderRepaintBoundary render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await render.toImage();
    data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  });
  return _Rendered(data, pixels);
}

void main() {
  // The tile sizes a launcher actually draws: the smallest one, a mid-density
  // one, and the Play listing's working size.
  const List<int> tileSizes = <int>[48, 72, 192];

  // A launcher shows only the inner 72 dp of the 108 dp canvas, so a tile of
  // N px is the canvas drawn at N × 108/72. Testing the canvas at N px
  // instead would shrink the mark by a third more than any launcher ever
  // does.
  const double canvasOverVisible = 108 / 72;

  group('the mark stays legible when it is shrunk (ICON-5)', () {
    for (final int tile in tileSizes) {
      testWidgets('on a $tile px tile the ring, gap and centre stay distinct', (
        WidgetTester tester,
      ) async {
        addTearDown(tester.view.reset);
        final int pixels = (tile * canvasOverVisible).round();
        final _Rendered icon = await _render(
          tester,
          pixels,
          const AppIconPainter(scale: adaptiveMarkScale),
        );

        final double centre = pixels / 2;
        final double module = pixels * adaptiveMarkScale / finderModules;

        // Measured out from the middle of the mark, in modules: the centre
        // block, the gap inside the ring, the ring, and the chassis beyond
        // it. Each sample sits in the middle of its band, clear of the
        // antialiased edges.
        const Map<String, (double, Color)> bands = <String, (double, Color)>{
          'centre block': (0, iconSignal),
          'gap': (2, _transparent),
          'ring': (3, iconSignal),
          'outside the mark': (4, _transparent),
        };

        for (final MapEntry<String, (double, Color)> band in bands.entries) {
          final (double modules, Color expected) = band.value;
          final double offset = modules * module;
          // Both axes, so a mark that stopped being square would fail.
          expect(
            icon.at(centre + offset, centre),
            expected,
            reason: '${band.key}, right of centre, on a $tile px tile',
          );
          expect(
            icon.at(centre, centre + offset),
            expected,
            reason: '${band.key}, below centre, on a $tile px tile',
          );
        }
      });
    }
  });

  testWidgets('the themed-icon layer is the mark alone, for the system to '
      'tint (ICON-4)', (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    const int pixels = 192;
    final _Rendered icon = await _render(
      tester,
      pixels,
      const AppIconPainter(scale: adaptiveMarkScale, monochrome: true),
    );

    const double centre = pixels / 2;
    const double module = pixels * adaptiveMarkScale / finderModules;

    expect(icon.at(centre, centre), iconMonochrome, reason: 'the centre block');
    expect(
      icon.at(centre + 3 * module, centre),
      iconMonochrome,
      reason: 'the ring',
    );
    // Nothing behind it: a background here would tint into a solid blob.
    expect(
      icon.at(centre + 2 * module, centre),
      _transparent,
      reason: 'the gap inside the ring',
    );
    expect(icon.at(1, 1), _transparent, reason: 'the corner of the layer');
  });

  testWidgets('the adaptive background layer is the chassis, edge to edge '
      '(ICON-3)', (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    const int pixels = 192;
    final _Rendered icon = await _render(
      tester,
      pixels,
      const AppIconPainter(scale: 1, background: true, glyph: false),
    );

    // Every mask has to land on the chassis, and the mark belongs to the
    // foreground layer alone.
    expect(icon.at(0, 0), iconChassis, reason: 'the corner');
    expect(
      icon.at(pixels - 1, pixels - 1),
      iconChassis,
      reason: 'the opposite corner',
    );
    expect(
      icon.at(pixels / 2, pixels / 2),
      iconChassis,
      reason: 'the middle, where the mark must not be',
    );
  });

  test('the mark is the app\'s own two colours (ICON-2)', () {
    // Spelled out, not read back from the painter: asserting iconSignal
    // against iconSignal would let the palette drift silently. These are the
    // signal and chassis in lib/core/theme/app_theme.dart.
    expect(iconSignal, const Color(0xFFC9F24D));
    expect(iconChassis, const Color(0xFF0E0D0B));
  });

  testWidgets('the icon Android ships matches the painter (ICON-1)', (
    WidgetTester tester,
  ) async {
    // The chain is painter → assets/icon → flutter_launcher_icons → res/.
    // Every step is run by hand, so any of them can be skipped and leave a
    // stale icon in the APK while every other test still passes. This reads
    // what actually ships.
    addTearDown(tester.view.reset);
    final File shipped = File(
      'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png',
    );
    expect(
      shipped.existsSync(),
      isTrue,
      reason: 'run `dart run flutter_launcher_icons`',
    );

    late final _Rendered icon;
    await tester.runAsync(() async {
      final ui.Codec codec = await ui.instantiateImageCodec(
        shipped.readAsBytesSync(),
      );
      final ui.Image image = (await codec.getNextFrame()).image;
      final ByteData data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      icon = _Rendered(data, image.width);
    });

    final double centre = icon.width / 2;
    final double module = icon.width * adaptiveMarkScale / finderModules;

    // Same bands as the painter's own test, read off the shipped file.
    expect(icon.at(centre, centre), iconSignal, reason: 'the centre block');
    expect(
      icon.at(centre + 2 * module, centre),
      _transparent,
      reason: 'the gap inside the ring',
    );
    expect(
      icon.at(centre + 3 * module, centre),
      iconSignal,
      reason: 'the ring',
    );
    expect(
      icon.at(centre + 4 * module, centre),
      _transparent,
      reason: 'beyond the mark — a stale icon drawn at the old size fails here',
    );
  });

  test('the ring is thicker than ICON-5 floor of 4 dp', () {
    // The adaptive canvas is 108 dp, and the ring is one module thick.
    const double moduleInDp = 108 * adaptiveMarkScale / finderModules;
    expect(moduleInDp, greaterThanOrEqualTo(4));
  });

  test('no round mask can clip the mark\'s corners (ICON-3)', () {
    // The safe zone is a CIRCLE 66 dp across, so a square mark has to fit it
    // by its diagonal, not its width. A 66 dp-wide square reaches
    // 33·sqrt(2) = 46.7 dp from the centre — outside both the 33 dp safe
    // circle and the 36 dp a launcher actually shows — and a circular or
    // squircle mask severs all four corners of the ring.
    const double halfWidthInDp = 108 * adaptiveMarkScale / 2;
    const double cornerFromCentre = halfWidthInDp * math.sqrt2;

    expect(
      cornerFromCentre,
      lessThanOrEqualTo(33),
      reason: 'a corner of the mark falls outside the 66 dp safe circle',
    );
    expect(
      cornerFromCentre,
      lessThanOrEqualTo(36),
      reason: 'a corner of the mark falls outside the 72 dp a launcher shows',
    );
  });

  test('the mark leaves the chassis visible around it (ICON-2, ICON-3)', () {
    // The safe zone is the most a mark may be, not the size to draw at.
    expect(adaptiveMarkScale, lessThanOrEqualTo(adaptiveSafeZoneScale));

    // A launcher shows the inner 72 dp of the 108 dp canvas. Drawn at the
    // 66 dp ceiling the mark would be 92% of that, the chassis would be
    // masked away, and the icon would read as a signal-coloured tile — which
    // ICON-2 says it is not. Two thirds of the visible circle leaves the
    // chassis as the ground on every mask.
    const double shareOfVisible = adaptiveMarkScale * 108 / 72;
    expect(
      shareOfVisible,
      lessThanOrEqualTo(0.7),
      reason: 'the mark swallows the chassis',
    );
    expect(
      shareOfVisible,
      greaterThanOrEqualTo(0.45),
      reason: 'the mark is lost in the tile',
    );
  });
}
