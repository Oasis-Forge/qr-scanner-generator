import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// A group heading, announced as a header for a screen reader (SET-5).
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: AppTheme.mono(
                size: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.read(context).hairline,
            ),
          ),
        ],
      ),
    );
  }
}

/// A switch row for one on/off setting (SET-2, SET-3, HIS-8, PRIV-3).
///
/// [MergeSemantics] folds the row and the switch into one screen-reader
/// control named by [label] (A11Y-1); [ListTile]'s own row is the tap target,
/// comfortably past [AppTheme.minTapTargetSize] in height and the full row's
/// width wide (A11Y-2). Writes before it changes anything on screen
/// (`CLAUDE.md`): a write that throws leaves the switch exactly as it was and
/// tells the user in the app's own language, using [AppLocalizations.errorSaveFailed].
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.switchKey,
    super.key,
  });

  final String label;
  final bool value;
  final Future<void> Function(bool value) onChanged;

  /// The key a widget test finds the switch by.
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: SwitchListTile(
        key: switchKey,
        contentPadding: EdgeInsetsDirectional.zero,
        title: Text(label),
        value: value,
        onChanged: (bool next) =>
            unawaited(writeSetting(context, () => onChanged(next))),
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
          Set<WidgetState> states,
        ) {
          // The on/off state is never colour alone (A11Y-6): a check mark
          // rides the thumb once the switch is on, on top of Material's own
          // colour change.
          if (!states.contains(WidgetState.selected)) {
            return null;
          }
          return const Icon(Icons.check, size: 16);
        }),
      ),
    );
  }
}

/// A tappable row that opens something else: a sub-page, a link, a system
/// page (SET-6, SET-7, SET-8, PRIV-2).
///
/// [subtitle] is a second, quieter line under [title], such as a price or "One
/// -time purchase". [trailingText] sits at the end of the row instead, for a
/// short value like the version number.
class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.rowKey,
    this.leading,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final Key? rowKey;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: rowKey,
      contentPadding: EdgeInsetsDirectional.zero,
      leading: leading,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailingText == null
          ? (onTap == null ? null : const Icon(Icons.chevron_right))
          : Text(trailingText!),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}

/// One option of a single-choice group: a theme, a language (SET-1, LANG-1),
/// or a feedback category (SET-8).
///
/// [MergeSemantics] folds the button and its label into a single node, so a
/// screen reader reads one control with the name the user sees and whether it
/// is the chosen one (A11Y-1). The chosen option carries a tick as well as the
/// filled colour, so the state is never colour alone (A11Y-6), and the style
/// holds the tap target at [AppTheme.minTapTargetSize] (A11Y-2).
class ToggleChoiceButton extends StatelessWidget {
  const ToggleChoiceButton({
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
    final AppColors colors = AppColors.read(context);
    final Widget text = Text(label);
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: selected
            ? OutlinedButton.icon(
                onPressed: onPressed,
                style: _style.copyWith(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    colors.signalWash,
                  ),
                  foregroundColor: WidgetStatePropertyAll<Color>(
                    colors.signalText,
                  ),
                  side: WidgetStatePropertyAll<BorderSide>(
                    BorderSide(color: colors.signalText),
                  ),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: text,
              )
            : OutlinedButton(onPressed: onPressed, style: _style, child: text),
      ),
    );
  }
}

/// Runs [write], and shows [AppLocalizations.errorSaveFailed] if it throws.
///
/// Every switch in Settings goes through this: [AppLocalizations.of] and the
/// [ScaffoldMessengerState] are read before the `await`, so no [BuildContext]
/// crosses it, and a failed write changes nothing the user can see beyond that
/// one snackbar (`CLAUDE.md`).
Future<void> writeSetting(
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
