import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../l10n/app_localizations.dart';
import '../../models/payload_classifier.dart';
import '../../models/record_enums.dart';
import '../../models/scan_record.dart';
import '../scanner/code_labels.dart';
import '../scanner/payload_text.dart' show payloadDirectionOf;

/// One row of the History list (HIS-4): the type icon; the label if set,
/// otherwise the content, in bold; the content on a second line when a label
/// is set; the local time (DATE-1, LANG-3); and "×N" when the code has been
/// seen 2 or more times (DATA-4, HIS-5). A Wi-Fi password is masked exactly as
/// a share preview masks it (HIS-7, DATA-5); the content itself stays left to
/// right even in Arabic, while a label does not (LANG-5).
///
/// Presentational: a tap, a long-press or the selection checkbox only ever
/// call back to `HistoryScreen`, which owns selection, delete and undo
/// (`CLAUDE.md`).
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    required this.record,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final ScanRecord record;

  /// Whether the list is in multi-select (DEL-2): swaps the leading type icon
  /// for a checkbox.
  final bool isSelectionMode;

  /// Whether this row is one of the selected ones. Ignored outside selection
  /// mode.
  final bool isSelected;

  /// A tap: opens the row (RES-3) outside selection mode, toggles it inside.
  final VoidCallback onTap;

  /// A long-press: starts selection mode with this row selected (DEL-2).
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String content = _oneLine(
      maskSensitive(record.payloadText, record.parsedType),
    );
    final String? label = record.label;
    final bool hasLabel = label != null && label.isNotEmpty;
    final String titleText = hasLabel ? label : content;
    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final DateTime time = (record.lastSeenAt ?? record.createdAt).toLocal();
    final String timeText = intl.DateFormat.jm(l10n.localeName).format(time);

    return ListTile(
      leading: isSelectionMode
          ? Checkbox(value: isSelected, onChanged: (bool? _) => onTap())
          : Icon(
              parsedTypeIcon(record.parsedType),
              color: theme.colorScheme.primary,
              semanticLabel: l10n.parsedTypeLabel(record.parsedType),
            ),
      title: hasLabel
          ? Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            )
          : _PayloadLine(
              text: titleText,
              type: record.parsedType,
              style: titleStyle,
            ),
      subtitle: hasLabel
          ? _PayloadLine(text: content, type: record.parsedType)
          : null,
      // The time and "×N" share one line: stacked, two lines at 2.0x text
      // outgrow the tile's height (A11Y-4, LANG-6).
      trailing: Text(
        record.duplicateCount >= 2
            ? '$timeText  ${l10n.historySeenCount(record.duplicateCount)}'
            : timeText,
        maxLines: 1,
        style: theme.textTheme.bodySmall,
      ),
      selected: isSelectionMode && isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

/// A payload's content on one line, left to right even in Arabic (LANG-5),
/// ellipsised rather than wrapped so no row grows taller than its neighbours
/// (an ellipsis is a deliberate cut, not overflow: A11Y-4, LANG-6).
class _PayloadLine extends StatelessWidget {
  const _PayloadLine({required this.text, required this.type, this.style});

  final String text;
  final ParsedType type;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextAlign align = Directionality.of(context) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textDirection: payloadDirectionOf(text, type),
      textAlign: align,
      style: style,
    );
  }
}

/// Whitespace runs folded to a single space, so a multi-line payload (a
/// vCard, an iCalendar event) still reads as one row, the same way SCAN-13's
/// own list preview does.
String _oneLine(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
