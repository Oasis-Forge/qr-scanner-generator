import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A `geo:` location (RES-8, shipping later): its fields, Copy and Share
/// only. "Open in maps" and the rest of RES-8 arrive with that PR; until
/// then this is the same Copy/Share every result gets, Copy given the
/// primary slot since there is nothing else to offer yet.
class LocationSection extends StatelessWidget {
  const LocationSection({required this.location, super.key});

  final Location location;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultField(
                label: l10n.resultLocationLatitudeLabel,
                value: '${location.latitude}',
                forceLtr: true,
              ),
              ResultField(
                label: l10n.resultLocationLongitudeLabel,
                value: '${location.longitude}',
                forceLtr: true,
              ),
              if (location.label != null)
                ResultField(
                  label: l10n.resultLocationNameLabel,
                  value: location.label!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultCopyButton,
          icon: Icons.copy,
          onPressed: () => copyContent(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ResultSecondaryButton(
              label: l10n.resultShareButton,
              icon: Icons.share,
              onPressed: () => shareContent(context),
            ),
          ],
        ),
      ],
    );
  }
}
