import 'package:flutter/material.dart';

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
  static const Key adSlotKey = Key('create.picker.ad_slot');

  final ValueChanged<ParsedType> onSelected;

  /// The key one type's tile is found by in a test, e.g. for [ParsedType.url].
  static Key tileKey(ParsedType type) => Key('create.picker.${type.id}');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l10n.createSubtitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final ParsedType type in generatorTypes)
                _TypeTile(type: type, onTap: () => onSelected(type)),
            ],
          ),
          const SizedBox(height: 24),
          ExcludeSemantics(
            child: Container(
              key: adSlotKey,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.onTap});

  final ParsedType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          key: CreateTypePicker.tileKey(type),
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  parsedTypeIcon(type),
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.parsedTypeLabel(type),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
