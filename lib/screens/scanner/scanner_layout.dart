import 'dart:ui';

import '../../core/theme/app_theme.dart';

/// The sizes the scanner and the screens it opens are laid out with.
abstract final class ScannerLayout {
  /// The height of the one real action on a screen: "Allow camera" (RUN-1),
  /// "Try another photo" (SCAN-11), "Scan" on typed entry (SCAN-12).
  ///
  /// 1.4 times [AppTheme.minTapTargetSize], the height every smaller control is
  /// held at, so the real action is always the largest button (RES-1, and the
  /// product principle in `CLAUDE.md`).
  static const double primaryActionHeight = AppTheme.minTapTargetSize * 1.4;

  /// The target's side as a share of the viewfinder's shorter side (SCAN-4).
  static const double targetFraction = 0.7;

  /// The square target in a viewfinder of [size], centred, in the
  /// viewfinder's own coordinates, which are the preview's (SCAN-4). It is
  /// both what the user sees and the scan window the camera is limited to.
  static Rect targetFor(Size size) {
    final double side = size.shortestSide * targetFraction;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
  }
}
