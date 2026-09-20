import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/theme/app_theme.dart';

/// The app's signal colour, spelled out here instead of read from
/// [AppTheme], so a change to it fails these tests rather than moving along
/// with them.
const Color signalColour = Color(0xFFC9F24D);

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
    test('SET-1: the app paints its own palette, the same in both themes', () {
      // Pinned, so a changed signal is a failing test and not a silent
      // redesign.
      expect(AppTheme.seedColor, signalColour);
      expect(AppColors.dark.signal, signalColour);
      expect(AppColors.light.signal, signalColour);

      for (final Brightness brightness in Brightness.values) {
        final ThemeData theme = AppTheme.themeFor(brightness: brightness);
        expect(
          theme.extension<AppColors>(),
          same(AppColors.of(brightness)),
          reason: 'every screen reads the same colours from the theme',
        );
      }
    });

    test('SET-1: light and dark are two different schemes, not one painted '
        'twice', () {
      final ThemeData light = AppTheme.light();
      final ThemeData dark = AppTheme.dark();

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
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
      expect(light.colorScheme.surface.a, 1.0);
      expect(dark.colorScheme.surface.a, 1.0);
    });

    test('the two typefaces are the ones the design names', () {
      final ThemeData theme = AppTheme.dark();

      expect(theme.textTheme.headlineMedium?.fontFamily, 'Space Grotesk');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Space Grotesk');
      // Machine-read facts are the mono ones.
      expect(theme.textTheme.labelMedium?.fontFamily, 'IBM Plex Mono');
      expect(AppTheme.mono().fontFamily, 'IBM Plex Mono');
      // The letter spacing grows with the size, so a label keeps its look.
      expect(AppTheme.mono(size: 20).letterSpacing, closeTo(2.8, 0.001));
    });

    test('A11Y-5: text clears WCAG AA contrast in both themes', () {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light(),
        AppTheme.dark(),
      ]) {
        final ColorScheme scheme = theme.colorScheme;
        final AppColors colours = theme.extension<AppColors>()!;
        final String half = scheme.brightness.name;

        void expectReadable(Color foreground, Color background, String what) {
          final double ratio = contrastRatio(foreground, background);
          expect(
            ratio,
            greaterThanOrEqualTo(minTextContrastRatio),
            reason:
                '$what in the $half theme is only '
                '${ratio.toStringAsFixed(2)}:1',
          );
        }

        expectReadable(scheme.onSurface, scheme.surface, 'body text');
        expectReadable(
          scheme.onSurfaceVariant,
          scheme.surface,
          'the quieter text',
        );
        expectReadable(
          scheme.onPrimary,
          scheme.primary,
          'the label on the primary button',
        );
        // The signal carries small mono labels of its own, so it has to be
        // readable on the ground as well as behind ink.
        expectReadable(
          colours.signalText,
          scheme.surface,
          'a label in the signal colour',
        );
        expectReadable(colours.onSignal, colours.signal, 'ink on the signal');
        expectReadable(colours.ink, colours.paper, 'ink on paper');
      }
    });

    test('the chassis is drawn with hairlines, not shadows', () {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light(),
        AppTheme.dark(),
      ]) {
        final AppColors colours = theme.extension<AppColors>()!;
        expect(theme.dividerTheme.color, colours.hairline);
        expect(theme.dividerTheme.thickness, 1);
        // Visible, but never a solid rule.
        expect(colours.hairline.a, lessThan(0.5));
        expect(colours.hairlineStrong.a, greaterThan(colours.hairline.a));
      }
    });

    test('A11Y-2: the shared minimum tap target is 48 dp, and the buttons '
        'clear it', () {
      expect(AppTheme.minTapTargetSize, 48);

      final ThemeData theme = AppTheme.dark();
      final Size? filled = theme.filledButtonTheme.style?.minimumSize?.resolve(
        <WidgetState>{},
      );
      final Size? outlined = theme.outlinedButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});
      expect(filled?.height, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
      expect(outlined?.height, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
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
      expect(contrastRatio(signalColour, signalColour), closeTo(1, 0.001));
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
