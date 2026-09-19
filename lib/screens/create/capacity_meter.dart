import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// GEN-12: the capacity meter that appears above 80% of a QR code's
/// byte-mode limit at error correction M.
///
/// [ratio] is `GeneratorState.capacityRatio` (0 to 1, or above 1 over the
/// limit); a screen only builds this once `GeneratorState.showsCapacityMeter`
/// is true.
class CapacityMeter extends StatelessWidget {
  const CapacityMeter({required this.ratio, super.key});

  static const Key meterKey = Key('create.capacity_meter');

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool over = ratio > 1;
    final int percent = (ratio * 100).round().clamp(0, 999).toInt();
    return Padding(
      key: meterKey,
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1).toDouble(),
              minHeight: 8,
              color: over ? theme.colorScheme.error : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.createCapacityMeterLabel(percent),
            textDirection: TextDirection.ltr,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// GEN-12: the message that replaces Create's enabled state once content is
/// over the QR byte-mode limit. Never colour alone (A11Y-6): the words say
/// what the meter's red fill also shows.
class CapacityOverLimitNotice extends StatelessWidget {
  const CapacityOverLimitNotice({super.key});

  static const Key noticeKey = Key('create.capacity_over_limit');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Padding(
      key: noticeKey,
      padding: const EdgeInsetsDirectional.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.createCapacityOverLimit,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
