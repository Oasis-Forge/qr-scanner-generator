import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../generator/generator_types.dart';
import '../../l10n/app_localizations.dart';
import '../../models/record_enums.dart' show ParsedType;
import '../scanner/code_labels.dart';

/// GEN-1's type picker: URL, Text, Wi-Fi, Contact, Phone, Email and SMS, each
/// a tile with an icon and a visible label (A11Y-1), in closed-test order.
///
/// A [Wrap] rather than a fixed grid, so a long translation at 2.0× text
/// still fits a phone (LANG-6, A11Y-4) — the same choice
/// `settings_screen.dart`'s `_ChoiceGroup` makes.
class CreateTypePicker extends StatelessWidget {
  const CreateTypePicker({required this.onSelected, super.key});

  /// ADS-1: the one spot on the whole Create flow an ad may fill — ready for
  /// theme 5, and empty here. Excluded from semantics since it says nothing
  /// yet.
  final ValueChanged<ParsedType> onSelected;

  /// The key one type's tile is found by in a test, e.g. for [ParsedType.url].
  static Key tileKey(ParsedType type) => Key('create.picker.${type.id}');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 14),
            child: Semantics(
              header: true,
              child: Text(
                l10n.createSubtitle.toUpperCase(),
                style: AppTheme.mono(
                  size: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          for (final (int index, ParsedType type) in generatorTypes.indexed)
            _TypeRow(
              type: type,
              index: index + 1,
              onTap: () => onSelected(type),
            ),
        ],
      ),
    );
  }
}

/// One format in the index: its number, its icon and its name.
///
/// A row, not a card: the picker reads as a list of what the instrument can
/// make. The whole row is the tap target (A11Y-2).
class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.type,
    required this.index,
    required this.onTap,
  });

  final ParsedType type;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AppColors colors = AppColors.read(context);
    final Color quiet = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      key: CreateTypePicker.tileKey(type),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.hairline)),
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: SizedBox(
                width: 26,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: AppTheme.mono(size: 11, color: quiet),
                ),
              ),
            ),
            Icon(parsedTypeIcon(type), size: 20, color: quiet),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.parsedTypeLabel(type),
                style: theme.textTheme.titleMedium,
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: quiet),
          ],
        ),
      ),
    );
  }
}
