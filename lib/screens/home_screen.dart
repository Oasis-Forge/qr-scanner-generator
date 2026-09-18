import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../state/settings_state.dart';

/// The app's first screen until Phase 2a puts the scanner here.
///
/// Presentational only (`CLAUDE.md`): it reads [SettingsState] with
/// `context.watch`, calls its setters with `context.read`, and touches no store,
/// no database and no device service. What it shows is the wiring Phase 1 built,
/// so the theme (SET-1) and the language (LANG-1) can be driven by hand on a
/// device before there is a viewfinder.
///
/// Every string comes from the message files (LANG-2) and every edge inset is
/// directional, so Arabic mirrors the whole screen (LANG-5). [SafeArea] keeps
/// the content out from under the system bars while the app lays out
/// edge to edge. [PopScope] leaves the back gesture to Android, which is what
/// makes the predictive-back animation run (paired with
/// `android:enableOnBackInvokedCallback`; the flag alone can swallow back
/// events, flutter/flutter#135815).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// The theme choice that follows the phone's setting (SET-1).
  static const Key systemThemeKey = Key('home.theme.system');

  /// The Light theme choice (SET-1).
  static const Key lightThemeKey = Key('home.theme.light');

  /// The Dark theme choice (SET-1).
  static const Key darkThemeKey = Key('home.theme.dark');

  /// The language choice that follows the device language (LANG-1).
  static const Key systemLanguageKey = Key('home.language.system');

  /// The English language choice (LANG-1).
  static const Key englishLanguageKey = Key('home.language.en');

  /// The Arabic language choice (LANG-1).
  static const Key arabicLanguageKey = Key('home.language.ar');

  /// The locale the English choice sets (LANG-1).
  static const Locale english = Locale('en');

  /// The locale the Arabic choice sets (LANG-1).
  static const Locale arabic = Locale('ar');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SettingsState settings = context.watch<SettingsState>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      // Nothing on this screen has unsaved work to guard, so the pop goes
      // through: Android runs its own predictive-back animation instead of the
      // app swallowing the gesture (flutter/flutter#135815).
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.appTitle, style: textTheme.headlineMedium),
                const SizedBox(height: 32),
                _ChoiceGroup<ThemeMode>(
                  title: l10n.settingsTheme,
                  selected: settings.themeMode,
                  onSelected: (ThemeMode mode) =>
                      context.read<SettingsState>().setThemeMode(mode),
                  options: <_Choice<ThemeMode>>[
                    _Choice<ThemeMode>(
                      buttonKey: systemThemeKey,
                      value: ThemeMode.system,
                      label: l10n.themeSystemDefault,
                    ),
                    _Choice<ThemeMode>(
                      buttonKey: lightThemeKey,
                      value: ThemeMode.light,
                      label: l10n.themeLight,
                    ),
                    _Choice<ThemeMode>(
                      buttonKey: darkThemeKey,
                      value: ThemeMode.dark,
                      label: l10n.themeDark,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _ChoiceGroup<Locale?>(
                  title: l10n.settingsLanguage,
                  selected: settings.localeOverride,
                  onSelected: (Locale? locale) =>
                      context.read<SettingsState>().setLocaleOverride(locale),
                  options: <_Choice<Locale?>>[
                    _Choice<Locale?>(
                      buttonKey: systemLanguageKey,
                      value: null,
                      label: l10n.languageSystemDefault,
                    ),
                    _Choice<Locale?>(
                      buttonKey: englishLanguageKey,
                      value: english,
                      label: l10n.languageEnglish,
                    ),
                    _Choice<Locale?>(
                      buttonKey: arabicLanguageKey,
                      value: arabic,
                      label: l10n.languageArabic,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One option of a switcher: which value it sets, what the user reads, and the
/// key a widget test taps it by.
class _Choice<T> {
  const _Choice({
    required this.buttonKey,
    required this.value,
    required this.label,
  });

  final Key buttonKey;
  final T value;

  /// Straight from the message files (LANG-2).
  final String label;
}

/// A heading and the row of options under it.
///
/// The row wraps instead of overflowing, so a long translation at 2.0× text
/// still fits on a phone (LANG-6, A11Y-4).
class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<_Choice<T>> options;
  final T selected;
  final Future<void> Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final _Choice<T> option in options)
              _ChoiceButton(
                key: option.buttonKey,
                label: option.label,
                selected: option.value == selected,
                onPressed: () => unawaited(
                  _applyChoice(context, () => onSelected(option.value)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Writes the choice, and says so when the write fails.
  ///
  /// Reliable writes (`CLAUDE.md`): [SettingsState] stores the value before it
  /// changes anything in memory and lets a failure through, so the screen is
  /// what tells the user nothing was saved, using the message files (LANG-2).
  /// The messenger and the strings are read before the `await`, so no
  /// `BuildContext` is used across it.
  static Future<void> _applyChoice(
    BuildContext context,
    Future<void> Function() write,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failed = AppLocalizations.of(context).errorSaveFailed;
    try {
      await write();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}

/// One tappable option.
///
/// [MergeSemantics] folds the button and its label into a single node, so a
/// screen reader reads one control with the name the user sees and whether it is
/// the chosen one (A11Y-1). The chosen option carries a tick as well as the
/// filled colour, so the state is never colour alone (A11Y-6), and the style
/// holds the tap target at [AppTheme.minTapTargetSize] (A11Y-2).
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  static const ButtonStyle _style = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(
      Size(AppTheme.minTapTargetSize, AppTheme.minTapTargetSize),
    ),
    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsetsDirectional.symmetric(horizontal: 20),
    ),
  );

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(label);
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: selected
            ? FilledButton.icon(
                onPressed: onPressed,
                style: _style,
                icon: const Icon(Icons.check),
                label: text,
              )
            : OutlinedButton(onPressed: onPressed, style: _style, child: text),
      ),
    );
  }
}
