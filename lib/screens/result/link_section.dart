import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../models/record_enums.dart';
import '../scanner/payload_text.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A link result (LINK-1).
///
/// Copy is the primary action for now: the Link safety PR adds "Open"
/// behind LINK-3's on-device checks (LINK-2, LINK-8); until then this gives
/// Copy the primary slot rather than leaving the result with no real action
/// at all.
class LinkSection extends StatelessWidget {
  const LinkSection({required this.link, super.key});

  final Link link;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: PayloadText(
            link.url,
            type: ParsedType.url,
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
