import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/languages.dart';
import '../../state/settings_state.dart';
import 'settings_rows.dart';

/// Settings' first group: theme, language, sound, vibration and copy on scan
/// (SET-1, SET-2, SET-3, LANG-1, SET-5).
///
/// The search engine row SET-5 also lists here is out of scope until SET-4
/// ships (decided for this PR).
///
/// Presentational only (`CLAUDE.md`): it reads [SettingsState] with
/// `context.watch`, calls its setters with `context.read`, and touches no
/// store, no database and no device service.
class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  /// The theme choice that follows the phone's setting (SET-1).
  static const Key systemThemeKey = Key('settings.theme.system');

  /// The Light theme choice (SET-1).
  static const Key lightThemeKey = Key('settings.theme.light');

  /// The Dark theme choice (SET-1).
  static const Key darkThemeKey = Key('settings.theme.dark');

  /// The language choice that follows the device language (LANG-1).
  static const Key systemLanguageKey = Key('settings.language.system');

  /// The sound-on-scan switch (SET-2).
  static const Key soundOnScanKey = Key('settings.sound_on_scan');

  /// The vibrate-on-scan switch (SET-2).
  static const Key vibrateOnScanKey = Key('settings.vibrate_on_scan');

  /// The copy-on-scan switch (SET-3).
  static const Key copyOnScanKey = Key('settings.copy_on_scan');

  /// The locale the English choice sets (LANG-1). Kept because English is the
  /// fallback every other part of the app names explicitly; the rest of the
  /// languages come from [appLanguages].
  static const Locale english = Locale('en');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SettingsState settings = context.watch<SettingsState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingsSectionHeader(title: l10n.settingsGroupGeneral),
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
        const SizedBox(height: 24),
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
            // Every language the app has, each in its own name and never
            // translated, so it can be found whatever the app is showing
            // (LANG-1). Built from the one list in `lib/l10n/languages.dart`
            // rather than spelled out, so adding a language is an ARB file
            // and a line there.
            for (final MapEntry<String, String> language
                in appLanguages.entries)
              _Choice<Locale?>(
                buttonKey: Key(languageChoiceKey(language.key)),
                value: Locale(language.key),
                label: language.value,
              ),
          ],
        ),
        const SizedBox(height: 8),
        SettingsSwitchRow(
          switchKey: soundOnScanKey,
          label: l10n.settingsSoundOnScan,
          value: settings.soundOnScan,
          onChanged: (bool enabled) =>
              context.read<SettingsState>().setSoundOnScan(enabled: enabled),
        ),
        SettingsSwitchRow(
          switchKey: vibrateOnScanKey,
          label: l10n.settingsVibrateOnScan,
          value: settings.vibrateOnScan,
          onChanged: (bool enabled) =>
              context.read<SettingsState>().setVibrateOnScan(enabled: enabled),
        ),
        SettingsSwitchRow(
          switchKey: copyOnScanKey,
          label: l10n.settingsCopyOnScan,
          value: settings.copyOnScan,
          onChanged: (bool enabled) =>
              context.read<SettingsState>().setCopyOnScan(enabled: enabled),
        ),
      ],
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
              ToggleChoiceButton(
                key: option.buttonKey,
                label: option.label,
                selected: option.value == selected,
                onPressed: () => unawaited(
                  writeSetting(context, () => onSelected(option.value)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
