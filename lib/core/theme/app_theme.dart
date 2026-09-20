import 'package:flutter/material.dart';

/// The app's own look: a dark instrument chassis, one signal colour, and
/// paper only where decoded content lives.
///
/// Three things carry it, and every screen reads them from here rather than
/// spelling out colours of its own:
///
/// * **Two typefaces with different jobs.** Space Grotesk names things
///   (headings, labels, content); IBM Plex Mono says what the machine read —
///   payloads, sizes, times, states — in small uppercase with wide letter
///   spacing ([mono]).
/// * **[AppColors.signal]**, the one accent. It marks what the app is doing
///   (the viewfinder's registration marks, the selected tab, the primary
///   button) and never decorates.
/// * **Hairlines and square corners** ([radius], [AppColors.hairline])
///   instead of cards and shadows, so the chassis reads as one instrument.
///
/// The palette is the app's own in both themes, not the device's (SET-1):
/// an identity this specific can't survive being recoloured by Material You.
abstract final class AppTheme {
  /// The signal colour, and the seed every other colour is built around.
  static const Color seedColor = Color(0xFFC9F24D);

  /// The smallest a control may be (A11Y-2).
  static const double minTapTargetSize = 48;

  /// The one corner radius: barely rounded, so edges read as machined.
  static const double radius = 6;

  /// The typeface for names and content.
  static const String displayFamily = 'Space Grotesk';

  /// The typeface for what the machine read: payloads, sizes, times, states.
  static const String monoFamily = 'IBM Plex Mono';

  /// A small uppercase mono label, the app's voice for machine-read facts.
  ///
  /// [size] is the font size; the letter spacing scales with it, so a label
  /// keeps its measured look at any size.
  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: monoFamily,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: size * 0.14,
    color: color,
  );

  static ThemeData light() => themeFor(brightness: Brightness.light);

  static ThemeData dark() => themeFor(brightness: Brightness.dark);

  static ThemeData themeFor({required Brightness brightness}) {
    final ColorScheme scheme = colorSchemeFor(brightness: brightness);
    final AppColors colors = AppColors.of(brightness);
    final TextTheme text = _textTheme(scheme);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      fontFamily: displayFamily,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.signal,
          foregroundColor: colors.onSignal,
          // Tall, but only as wide as it needs: a screen that wants a bar
          // across its foot stretches the button itself.
          minimumSize: const Size(minTapTargetSize, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          textStyle: mono(size: 13, weight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(minTapTargetSize, 52),
          side: BorderSide(color: colors.hairlineStrong),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          textStyle: mono(size: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.signalText,
          minimumSize: const Size(minTapTargetSize, minTapTargetSize),
          textStyle: mono(size: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(minTapTargetSize, minTapTargetSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // Underlined, not boxed: a field reads as a line to write on.
        filled: false,
        labelStyle: mono(size: 11, color: scheme.onSurfaceVariant),
        floatingLabelStyle: mono(size: 11, color: colors.signalText),
        helperStyle: mono(size: 11, color: scheme.onSurfaceVariant),
        helperMaxLines: 3,
        errorStyle: mono(size: 11, color: scheme.error),
        errorMaxLines: 3,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.hairlineStrong),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.signalText, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll<TextStyle>(mono(size: 11)),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: colors.hairlineStrong),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? colors.signalWash
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? colors.signalText
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 74,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => mono(
            size: 10,
            color: states.contains(WidgetState.selected)
                ? colors.signalText
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? colors.signalText
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        // A bar across the foot of the chassis, not a floating card: it also
        // keeps clear of the tab rail on a small screen.
        backgroundColor: colors.raised,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
        actionTextColor: colors.signalText,
        behavior: SnackBarBehavior.fixed,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.signal
              : scheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.signalWash
              : Colors.transparent,
        ),
        trackOutlineColor: WidgetStatePropertyAll<Color>(colors.hairlineStrong),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: mono(size: 11, color: scheme.onSurfaceVariant),
        iconColor: scheme.onSurfaceVariant,
      ),
    );
  }

  static ColorScheme colorSchemeFor({required Brightness brightness}) {
    final AppColors colors = AppColors.of(brightness);
    return brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: colors.signal,
            onPrimary: colors.onSignal,
            primaryContainer: colors.signalWash,
            onPrimaryContainer: colors.signalText,
            secondary: colors.paper,
            onSecondary: colors.ink,
            surface: const Color(0xFF0E0D0B),
            onSurface: const Color(0xFFF4F0E6),
            onSurfaceVariant: const Color(0xFFA9A499),
            surfaceContainerHighest: colors.raised,
            outline: colors.hairlineStrong,
            outlineVariant: colors.hairline,
            error: const Color(0xFFFF7A59),
            onError: colors.ink,
          )
        : ColorScheme.light(
            primary: colors.ink,
            onPrimary: colors.paper,
            primaryContainer: colors.signalWash,
            onPrimaryContainer: colors.ink,
            secondary: colors.signal,
            onSecondary: colors.ink,
            surface: colors.paper,
            onSurface: colors.ink,
            onSurfaceVariant: const Color(0xFF5B564A),
            surfaceContainerHighest: colors.raised,
            outline: colors.hairlineStrong,
            outlineVariant: colors.hairline,
            error: const Color(0xFF9B3418),
            onError: colors.paper,
          );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle display(double size, FontWeight weight, {double spacing = 0}) =>
        TextStyle(
          fontFamily: displayFamily,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: scheme.onSurface,
          height: 1.2,
        );

    return TextTheme(
      // Names: a screen's own title, a code's own subject.
      displaySmall: display(34, FontWeight.w700, spacing: -0.5),
      headlineMedium: display(30, FontWeight.w700, spacing: -0.5),
      headlineSmall: display(22, FontWeight.w700, spacing: -0.2),
      titleLarge: display(20, FontWeight.w500),
      titleMedium: display(17, FontWeight.w500),
      // Content the user reads as words.
      bodyLarge: display(16, FontWeight.w400).copyWith(height: 1.4),
      bodyMedium: display(14, FontWeight.w400).copyWith(height: 1.5),
      bodySmall: display(
        13,
        FontWeight.w400,
      ).copyWith(height: 1.5, color: scheme.onSurfaceVariant),
      // What the machine read.
      labelLarge: mono(
        size: 13,
        weight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      labelMedium: mono(size: 11, color: scheme.onSurfaceVariant),
      labelSmall: mono(size: 10, color: scheme.onSurfaceVariant),
    );
  }
}

/// The colours Material's own [ColorScheme] has no slot for: the signal, the
/// paper a decoded code is printed on, and the hairlines the chassis is drawn
/// with. Read with `Theme.of(context).extension<AppColors>()!`, or
/// [AppColors.read].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.signal,
    required this.onSignal,
    required this.signalText,
    required this.signalWash,
    required this.paper,
    required this.ink,
    required this.raised,
    required this.hairline,
    required this.hairlineStrong,
    required this.pass,
  });

  /// The one accent: registration marks, the selected tab, the real action.
  final Color signal;

  /// What reads on top of [signal].
  final Color onSignal;

  /// [signal] where it has to carry small text or a thin line, darkened on
  /// paper so it stays readable (A11Y-5).
  final Color signalText;

  /// [signal] at a wash, behind a selected chip or a switch's track.
  final Color signalWash;

  /// The ground a decoded or created code is printed on.
  final Color paper;

  /// What is printed on [paper].
  final Color ink;

  /// One step off the ground: the viewfinder, a snackbar.
  final Color raised;

  /// The line the chassis is drawn with.
  final Color hairline;

  /// The same line where it has to be seen: a field's underline, a border.
  final Color hairlineStrong;

  /// A check that passed, in the link report (RES-1, LINK-1).
  final Color pass;

  static const Color _signal = Color(0xFFC9F24D);
  static const Color _paper = Color(0xFFF4F0E6);
  static const Color _ink = Color(0xFF14120D);

  /// The set for [brightness].
  static AppColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The set the ambient theme carries.
  static AppColors read(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ??
      of(Theme.of(context).brightness);

  static const AppColors dark = AppColors(
    signal: _signal,
    onSignal: _ink,
    signalText: _signal,
    signalWash: Color(0x24C9F24D),
    paper: _paper,
    ink: _ink,
    raised: Color(0xFF17150F),
    hairline: Color(0x24F4F0E6),
    hairlineStrong: Color(0x59F4F0E6),
    pass: Color(0xFFA8D94A),
  );

  static const AppColors light = AppColors(
    signal: _signal,
    onSignal: _ink,
    // Lime can't carry small text on paper, so words in the signal's place
    // are the same colour taken down to a readable olive (A11Y-5).
    signalText: Color(0xFF4F6B00),
    signalWash: Color(0x33C9F24D),
    paper: _paper,
    ink: _ink,
    raised: Color(0xFFEAE5D6),
    hairline: Color(0x1F14120D),
    hairlineStrong: Color(0x6614120D),
    pass: Color(0xFF2F7D3E),
  );

  @override
  AppColors copyWith({
    Color? signal,
    Color? onSignal,
    Color? signalText,
    Color? signalWash,
    Color? paper,
    Color? ink,
    Color? raised,
    Color? hairline,
    Color? hairlineStrong,
    Color? pass,
  }) => AppColors(
    signal: signal ?? this.signal,
    onSignal: onSignal ?? this.onSignal,
    signalText: signalText ?? this.signalText,
    signalWash: signalWash ?? this.signalWash,
    paper: paper ?? this.paper,
    ink: ink ?? this.ink,
    raised: raised ?? this.raised,
    hairline: hairline ?? this.hairline,
    hairlineStrong: hairlineStrong ?? this.hairlineStrong,
    pass: pass ?? this.pass,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      signal: Color.lerp(signal, other.signal, t)!,
      onSignal: Color.lerp(onSignal, other.onSignal, t)!,
      signalText: Color.lerp(signalText, other.signalText, t)!,
      signalWash: Color.lerp(signalWash, other.signalWash, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      pass: Color.lerp(pass, other.pass, t)!,
    );
  }
}
