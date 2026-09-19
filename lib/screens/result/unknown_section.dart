import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A payload that fits no type (RES-13): its text if it is valid UTF-8,
/// otherwise "Binary data, N bytes". Only Copy and Share; Copy is given the
/// primary slot for the same reason plain text is.
class UnknownSection extends StatelessWidget {
  const UnknownSection({required this.unknown, super.key});

  final Unknown unknown;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          // RES-1: selectable like every other result's content.
          child: SelectableText(
            unknown.isBinary
                ? l10n.scanBinaryData(unknown.byteCount)
                : unknown.text,
            style: Theme.of(context).textTheme.bodyLarge,
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
