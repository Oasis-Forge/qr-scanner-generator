import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/history_state.dart';

/// The header text for one [HistoryGroup] (HIS-3, DATE-2): "Today",
/// "Yesterday", a weekday name within 7 days, or the date, already formatted
/// for the app's language (LANG-3). [HistoryHeader] carries only the data;
/// this is the one place that turns it into words.
extension HistoryHeaderLabel on AppLocalizations {
  String historyHeaderLabel(HistoryHeader header) => switch (header.kind) {
    HistoryHeaderKind.today => historyHeaderToday,
    HistoryHeaderKind.yesterday => historyHeaderYesterday,
    HistoryHeaderKind.weekday => historyHeaderWeekday(header.day),
    HistoryHeaderKind.date => historyHeaderDate(header.day),
  };
}

/// One date header row over a run of History rows (HIS-3).
class HistoryDateHeader extends StatelessWidget {
  const HistoryDateHeader({required this.header, super.key});

  final HistoryHeader header;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AppColors colors = AppColors.read(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 22, 16, 10),
      child: Row(
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l10n.historyHeaderLabel(header).toUpperCase(),
              style: AppTheme.mono(
                size: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: colors.hairline)),
        ],
      ),
    );
  }
}
