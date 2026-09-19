import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../models/record_enums.dart';
import '../scanner/payload_text.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A plain-text result: text that fits no other type.
///
/// Copy is the primary action; there is nothing more specific to offer than
/// the exact decoded text every result already gets (RES-1).
class PlainTextSection extends StatelessWidget {
  const PlainTextSection({required this.text, super.key});

  final PlainText text;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          // LANG-5: a plain-text payload reads in its own direction, Arabic
          // included, unlike a link or a code.
          child: PayloadText(
            text.text,
            type: ParsedType.text,
            selectable: true,
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
