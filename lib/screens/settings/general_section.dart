import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
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

  /// The closed dropdown that opens the language list (LANG-1).
  static const Key languageDropdownKey = Key('settings.language');

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
        _LanguageDropdown(
          title: l10n.settingsLanguage,
          systemDefaultLabel: l10n.languageSystemDefault,
          selected: settings.localeOverride,
          onSelected: (Locale? locale) =>
              context.read<SettingsState>().setLocaleOverride(locale),
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
/// One language's name in the open dropdown.
///
/// Two rules pull opposite ways here and this holds both. `itemHeight: null`
/// lets a long name wrap onto a second line at 200% text instead of
/// overflowing (A11Y-4), but it also drops the menu item's own floor, leaving
/// a short name like ไทย a 24 dp target — half of what A11Y-2 asks for. The
/// minimum height puts the floor back without capping the growth.
class _MenuItemLabel extends StatelessWidget {
  const _MenuItemLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppTheme.minTapTargetSize),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(label),
      ),
    );
  }
}

/// The language switcher: a dropdown, not the chip row the other switchers
/// use (LANG-1, changed 2026-09-21).
///
/// Twenty languages plus "System default" is twenty-one chips, and as chips
/// they filled the whole screen and pushed sound, vibration, copy on scan and
/// every group below them out of sight. Theme keeps its chips: three options
/// fit on two rows and are quicker to reach when they are all visible.
///
/// The value is the language code rather than the [Locale] itself, because
/// "System default" is a real choice here and not the absence of one; the
/// empty string carries it, where a null value would read as "nothing chosen".
class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.title,
    required this.systemDefaultLabel,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String systemDefaultLabel;
  final Locale? selected;
  final Future<void> Function(Locale? locale) onSelected;

  /// The code standing for "follow the device language" (LANG-1).
  static const String _systemDefault = '';

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
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            // The button below brings its own 48 dp height (A11Y-2), so the
            // box only needs to breathe either side of it.
            contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: GeneralSection.languageDropdownKey,
              value: selected?.languageCode ?? _systemDefault,
              // What shows is driven by the setting itself, never by the
              // dropdown's own state, so a write that fails leaves the name
              // on screen as it was (`CLAUDE.md`: write first, then state).
              isExpanded: true,
              // Items grow to fit a name that wraps at 200% text (A11Y-4),
              // as the Wi-Fi security field does. They keep the 48 dp
              // minimum height of their own accord (A11Y-2).
              itemHeight: null,
              // Only the closed button is built from this, so the keyed
              // items below exist solely in the open menu and a test that
              // finds one has really opened it. The closed button is a tap
              // target in its own right, and only what is inside it can be
              // tapped — the box's padding around it cannot — so the name
              // carries the same 48 dp minimum as a menu item (A11Y-2).
              selectedItemBuilder: (BuildContext context) => <Widget>[
                _MenuItemLabel(systemDefaultLabel),
                for (final String name in appLanguages.values)
                  _MenuItemLabel(name),
              ],
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  key: GeneralSection.systemLanguageKey,
                  value: _systemDefault,
                  child: _MenuItemLabel(systemDefaultLabel),
                ),
                // Every language the app has, each in its own name and never
                // translated, so it can be found whatever the app is showing
                // (LANG-1). Built from the one list in
                // `lib/l10n/languages.dart` rather than spelled out, so
                // adding a language is an ARB file and a line there.
                for (final MapEntry<String, String> language
                    in appLanguages.entries)
                  DropdownMenuItem<String>(
                    key: Key(languageChoiceKey(language.key)),
                    value: language.key,
                    child: _MenuItemLabel(language.value),
                  ),
              ],
              onChanged: (String? code) {
                if (code == null) {
                  return;
                }
                unawaited(
                  writeSetting(
                    context,
                    () => onSelected(
                      code == _systemDefault ? null : Locale(code),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

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
