import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/theme/app_theme.dart';

/// The app's own colour, spelled out here instead of read from [AppTheme], so a
/// change to the seed fails these tests rather than moving along with them.
const Color indigoSeed = Color(0xFF3F51B5);

/// A palette that is nothing like the app's seed, standing in for the one
/// Android reads off the user's wallpaper.
const Color wallpaperSeed = Color(0xFF00695C);

/// The ratio WCAG AA asks of body and UI text (A11Y-5).
const double minTextContrastRatio = 4.5;

/// One sRGB channel, gamma-decoded the way WCAG 2.1 defines it.
double _linearize(double channel) => channel <= 0.03928
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

/// The relative luminance of [color], by the WCAG 2.1 definition.
double relativeLuminance(Color color) =>
    0.2126 * _linearize(color.r) +
    0.7152 * _linearize(color.g) +
    0.0722 * _linearize(color.b);

/// The contrast ratio between [foreground] and [background]: WCAG 2.1's
/// `(lighter + 0.05) / (darker + 0.05)`, computed here so the check does not
/// lean on the framework it is checking (A11Y-5).
double contrastRatio(Color foreground, Color background) {
  final double one = relativeLuminance(foreground);
  final double other = relativeLuminance(background);
  return (math.max(one, other) + 0.05) / (math.min(one, other) + 0.05);
}

void main() {
  group('AppTheme', () {
    test('SET-1: the app paints from its own indigo seed when the device '
        'offers no palette', () {
      // Pinned, so a changed seed is a failing test and not a silent redesign.
      expect(AppTheme.seedColor, indigoSeed);

      final ColorScheme light = AppTheme.colorSchemeFor(
        brightness: Brightness.light,
      );
      final ColorScheme fromIndigo = ColorScheme.fromSeed(
        seedColor: indigoSeed,
      );

      expect(light.brightness, Brightness.light);
      expect(light.primary, fromIndigo.primary);
      expect(light.surface, fromIndigo.surface);
      expect(light.onPrimary, fromIndigo.onPrimary);
      // Material 3 paints with a tone of the seed, never the raw seed, and
      // hands a screen fully opaque colours.
      expect(light.primary, isNot(indigoSeed));
      expect(light.primary.a, 1.0);
      expect(light.surface.a, 1.0);
    });

    test('SET-1: light and dark are two different schemes, not one painted '
        'twice', () {
      final ThemeData light = AppTheme.light();
      final ThemeData dark = AppTheme.dark();

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.colorScheme.primary, isNot(dark.colorScheme.primary));
      // Told apart by looking, not only by the brightness flag: the light
      // theme's background is the pale one and its text the dark one.
      expect(
        relativeLuminance(light.colorScheme.surface),
        greaterThan(relativeLuminance(dark.colorScheme.surface)),
      );
      expect(
        relativeLuminance(light.colorScheme.onSurface),
        lessThan(relativeLuminance(dark.colorScheme.onSurface)),
      );
    });

    test('SET-1: a matching dynamic scheme is used as it stands, not '
        're-seeded', () {
      final ColorScheme wallpaper = ColorScheme.fromSeed(
        seedColor: wallpaperSeed,
      );
      final ThemeData theme = AppTheme.light(dynamicScheme: wallpaper);

      expect(
        AppTheme.colorSchemeFor(
          brightness: Brightness.light,
          dynamicScheme: wallpaper,
        ),
        same(wallpaper),
        reason: 'the device palette is passed through, not rebuilt from it',
      );
      expect(theme.colorScheme.primary, wallpaper.primary);
      expect(theme.colorScheme.secondary, wallpaper.secondary);
      expect(theme.colorScheme.surface, wallpaper.surface);
      expect(theme.colorScheme.error, wallpaper.error);
      expect(
        theme.colorScheme.primary,
        isNot(AppTheme.light().colorScheme.primary),
        reason: 'the wallpaper palette must actually replace the seeded one',
      );
    });

    test('SET-1: the dark half takes the dark palette the device offers', () {
      final ColorScheme wallpaperDark = ColorScheme.fromSeed(
        seedColor: wallpaperSeed,
        brightness: Brightness.dark,
      );
      final ThemeData theme = AppTheme.dark(dynamicScheme: wallpaperDark);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, wallpaperDark.primary);
      expect(theme.colorScheme.surface, wallpaperDark.surface);
    });

    test('SET-1: a palette of the wrong brightness is ignored, so the dark '
        'theme never comes back light', () {
      final ColorScheme lightWallpaper = ColorScheme.fromSeed(
        seedColor: wallpaperSeed,
      );
      final ThemeData dark = AppTheme.dark(dynamicScheme: lightWallpaper);
      final ColorScheme seededDark = ColorScheme.fromSeed(
        seedColor: indigoSeed,
        brightness: Brightness.dark,
      );

      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, seededDark.primary);
      expect(dark.colorScheme.surface, seededDark.surface);
      expect(dark.colorScheme.surface, isNot(lightWallpaper.surface));
      // And what it paints really is dark, whatever the device handed over.
      expect(relativeLuminance(dark.colorScheme.surface), lessThan(0.1));
    });

    test('SET-1: a dark palette offered to the light theme is ignored too', () {
      final ColorScheme darkWallpaper = ColorScheme.fromSeed(
        seedColor: wallpaperSeed,
        brightness: Brightness.dark,
      );
      final ThemeData light = AppTheme.light(dynamicScheme: darkWallpaper);
      final ColorScheme seededLight = ColorScheme.fromSeed(
        seedColor: indigoSeed,
      );

      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.surface, seededLight.surface);
      expect(relativeLuminance(light.colorScheme.surface), greaterThan(0.5));
    });

    test('A11Y-5: text clears WCAG AA contrast in both themes', () {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light(),
        AppTheme.dark(),
      ]) {
        final ColorScheme scheme = theme.colorScheme;
        final String half = scheme.brightness.name;

        final double bodyText = contrastRatio(scheme.onSurface, scheme.surface);
        expect(
          bodyText,
          greaterThanOrEqualTo(minTextContrastRatio),
          reason:
              'body text on the $half background is only '
              '${bodyText.toStringAsFixed(2)}:1',
        );

        final double buttonLabel = contrastRatio(
          scheme.onPrimary,
          scheme.primary,
        );
        expect(
          buttonLabel,
          greaterThanOrEqualTo(minTextContrastRatio),
          reason:
              'the label on the primary button in the $half theme is only '
              '${buttonLabel.toStringAsFixed(2)}:1',
        );
      }
    });

    test('A11Y-2: the shared minimum tap target is 48 dp', () {
      expect(AppTheme.minTapTargetSize, 48);
    });
  });

  group('contrastRatio', () {
    test('matches the ratios WCAG names for black, white and mid grey', () {
      // Black on white is the extreme WCAG puts at 21:1, and any colour
      // against itself is 1:1; #767676 on white is the textbook 4.54:1 pass.
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
      expect(
        contrastRatio(const Color(0xFF3F51B5), const Color(0xFF3F51B5)),
        closeTo(1, 0.001),
      );
      expect(
        contrastRatio(const Color(0xFF767676), const Color(0xFFFFFFFF)),
        closeTo(4.54, 0.02),
      );
      // Order does not matter: the formula is symmetric.
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        closeTo(21, 0.01),
      );
    });
  });
}
