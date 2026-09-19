import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// An email (`mailto:`, `MATMSG:` or a bare address, RES-7): the recipient,
/// subject and body, if any. The primary action opens the email app
/// prefilled and never sends (RES-2).
class EmailSection extends StatelessWidget {
  const EmailSection({required this.email, super.key});

  final Email email;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResultState state = context.watch<ResultState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultField(
                label: l10n.resultEmailToLabel,
                value: email.to,
                forceLtr: true,
              ),
              if (email.subject != null)
                ResultField(
                  label: l10n.resultEmailSubjectLabel,
                  value: email.subject!,
                ),
              if (email.body != null)
                ResultField(
                  label: l10n.resultEmailBodyLabel,
                  value: email.body!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultEmailPrimaryButton,
          icon: Icons.email_outlined,
          onPressed: state.canComposeEmail
              ? () => performHandOff(context, state.composeEmail)
              : null,
          unavailableReason: l10n.resultUnavailableEmail,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ResultSecondaryButton(
              label: l10n.resultCopyButton,
              icon: Icons.copy,
              onPressed: () => copyContent(context),
            ),
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
