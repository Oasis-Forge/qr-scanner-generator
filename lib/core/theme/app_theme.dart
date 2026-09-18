import 'package:flutter/material.dart';

/// The app's light and dark themes (SET-1).
///
/// Three ways in, all pure functions of their arguments: [light] and [dark]
/// with no argument build Material 3 themes from [seedColor], the app's own
/// colour; passing the [ColorScheme] the device offers builds the same themes
/// from the phone's palette instead, which is the dynamic colour SET-1 asks for
/// "where the phone supports it". A scheme of the wrong brightness is ignored
/// rather than trusted, so the dark theme can never come back light.
///
/// Reusable core (`CLAUDE.md`): this file imports nothing from the app and no
/// plugin. Reading the device's palette is `dynamic_color`'s job and happens in
/// the app's entry point, which hands the schemes in here; that keeps the theme
/// testable on any machine and keeps the plugin out of `lib/core/`.
/// `dynamic_color` stays on 1.9.0: 2.x returns schemes `ThemeData` rejects.
abstract final class AppTheme {
  /// The app's own colour, used wherever the device offers no palette (SET-1).
  static const Color seedColor = Color(0xFF3F51B5);

  /// The smallest a tappable control may be, in logical pixels (A11Y-2).
  ///
  /// It lives with the theme because every screen's controls are measured
  /// against it, and a widget test asserts it.
  static const double minTapTargetSize = 48;

  /// The light theme: the device's light scheme when it has one, else the seed
  /// (SET-1).
  static ThemeData light({ColorScheme? dynamicScheme}) =>
      themeFor(brightness: Brightness.light, dynamicScheme: dynamicScheme);

  /// The dark theme: the device's dark scheme when it has one, else the seed
  /// (SET-1).
  static ThemeData dark({ColorScheme? dynamicScheme}) =>
      themeFor(brightness: Brightness.dark, dynamicScheme: dynamicScheme);

  /// The theme for one [brightness]. [light] and [dark] are the two calls the
  /// app makes; this is the builder behind them.
  static ThemeData themeFor({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    return ThemeData(
      colorScheme: colorSchemeFor(
        brightness: brightness,
        dynamicScheme: dynamicScheme,
      ),
      useMaterial3: true,
    );
  }

  /// The colours one half of the theme is built from.
  ///
  /// [dynamicScheme] is used only when the device gave us one *and* it matches
  /// [brightness]: a device that reports only a light palette must not end up
  /// painting the dark theme with light colours.
  static ColorScheme colorSchemeFor({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    if (dynamicScheme != null && dynamicScheme.brightness == brightness) {
      return dynamicScheme;
    }
    return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  }
}
