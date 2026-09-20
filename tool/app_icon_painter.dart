// The app's mark, drawn in code so every icon, adaptive layer and splash
// image comes from one source (ICON-1). `render_app_icons_test.dart` paints
// it into `assets/icon/`; `test/icon/app_icon_test.dart` checks it stays
// legible at launcher sizes (ICON-5).
import 'package:flutter/rendering.dart';

/// The chassis the mark sits on (ICON-2), matching `AppColors` in
/// `lib/core/theme/app_theme.dart`.
const Color iconChassis = Color(0xFF0E0D0B);

/// The signal colour the mark is drawn in (ICON-2).
const Color iconSignal = Color(0xFFC9F24D);

/// What Android's themed icons are drawn in before the system tints them
/// (ICON-4).
const Color iconMonochrome = Color(0xFFFFFFFF);

/// The largest a mark may be on an adaptive layer without a launcher mask
/// clipping it: the inner 66 dp of the 108 dp canvas (ICON-3). It is a
/// ceiling, not a size to draw at.
const double adaptiveSafeZoneScale = 66 / 108;

/// The mark's share of an adaptive layer, 44 dp of the 108 dp canvas.
///
/// A launcher only ever shows the inner 72 dp, so a mark drawn at the 66 dp
/// ceiling would fill 92% of what anyone sees and the chassis would be masked
/// away — the icon would read as a signal-coloured tile, which is the one
/// thing ICON-2 says it is not. At 44 dp the mark is 61% of the visible
/// circle and the chassis stays the icon's ground.
const double adaptiveMarkScale = 44 / 108;

/// A QR finder pattern is seven modules across: a one-module ring, a
/// one-module gap, and a three-module centre.
const int finderModules = 7;

/// The corner square of a QR code's finder pattern: the thing a scanner looks
/// for first, and the app's mark (ICON-2).
///
/// Everything is laid out from the canvas's shorter side, so the same painter
/// draws a 48 px check and a 1024 px icon.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({
    required this.scale,
    this.background = false,
    this.monochrome = false,
    this.glyph = true,
  });

  /// The mark's width as a share of the canvas.
  final double scale;

  /// Fills the canvas with the chassis first, for the layers that can't be
  /// transparent.
  final bool background;

  /// Draws the mark in one flat colour for Android's themed icons, which tint
  /// whatever they are given (ICON-4).
  final bool monochrome;

  /// False for the adaptive background layer, which is the chassis alone.
  final bool glyph;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      canvas.drawRect(Offset.zero & size, Paint()..color = iconChassis);
    }
    if (!glyph) {
      return;
    }

    final double side = size.shortestSide * scale;
    final double module = side / finderModules;
    final Offset centre = size.center(Offset.zero);
    final Paint paint = Paint()
      ..color = monochrome ? iconMonochrome : iconSignal;

    // The ring, one module thick. Stroking the rect inset by half a module
    // puts the stroke's outer edge on the mark's own edge.
    canvas.drawRect(
      Rect.fromCenter(
        center: centre,
        width: side,
        height: side,
      ).deflate(module / 2),
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = module,
    );

    // The centre, three modules square, leaving a one-module gap inside the
    // ring.
    canvas.drawRect(
      Rect.fromCenter(center: centre, width: module * 3, height: module * 3),
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(AppIconPainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.background != background ||
      oldDelegate.monochrome != monochrome ||
      oldDelegate.glyph != glyph;
}
