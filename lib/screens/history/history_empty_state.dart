import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// HIS-11: History with no live records at all, whatever the segment.
///
/// One line, then "Scan a code" — filled, the largest control, since scanning
/// is the app's main action (`CLAUDE.md`) — and "Create a code", outlined;
/// both switch tabs through the callbacks `HistoryScreen` was given. While
/// "Save history" is off (HIS-8), a second line says new scans aren't being
/// saved, with a button to Settings.
class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({
    required this.saveHistory,
    required this.onScan,
    required this.onCreate,
    required this.onSettings,
    super.key,
  });

  /// Switches to the Scan tab (HIS-11).
  static const Key scanButtonKey = Key('history.empty.scan');

  /// Switches to the Create tab (HIS-11).
  static const Key createButtonKey = Key('history.empty.create');

  /// Switches to the Settings tab, shown only while [saveHistory] is off
  /// (HIS-8, HIS-11).
  static const Key settingsButtonKey = Key('history.empty.settings');

  /// Whether new scans and created codes are being written (HIS-8).
  final bool saveHistory;

  final VoidCallback onScan;
  final VoidCallback onCreate;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 64
                  ? constraints.maxHeight - 64
                  : 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.history, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.historyEmptyMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      key: scanButtonKey,
                      onPressed: onScan,
                      style: _buttonStyle,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.historyEmptyScanButton),
                    ),
                    OutlinedButton.icon(
                      key: createButtonKey,
                      onPressed: onCreate,
                      style: _buttonStyle,
                      icon: const Icon(Icons.add_box_outlined),
                      label: Text(l10n.historyEmptyCreateButton),
                    ),
                  ],
                ),
                if (!saveHistory) ...<Widget>[
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.historyEmptyNotSavingMessage,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    key: settingsButtonKey,
                    onPressed: onSettings,
                    style: _buttonStyle,
                    child: Text(l10n.historyEmptySettingsButton),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static const ButtonStyle _buttonStyle = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(
      Size(AppTheme.minTapTargetSize * 2, AppTheme.minTapTargetSize),
    ),
  );
}
