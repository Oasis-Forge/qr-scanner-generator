import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          l10n.historyHeaderLabel(header),
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
