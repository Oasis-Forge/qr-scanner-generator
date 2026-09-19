import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// An SMS or MMS with an optional message (RES-7): the recipient number and
/// the pre-filled message, if any. The primary action opens the messaging
/// app prefilled and never sends (RES-2).
class SmsSection extends StatelessWidget {
  const SmsSection({required this.sms, super.key});

  final Sms sms;

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
                label: l10n.resultSmsNumberLabel,
                value: sms.number,
                forceLtr: true,
              ),
              if (sms.message != null)
                ResultField(
                  label: l10n.resultSmsMessageLabel,
                  value: sms.message!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultSmsPrimaryButton,
          icon: Icons.sms_outlined,
          onPressed: state.canComposeSms
              ? () => performHandOff(context, state.composeSms)
              : null,
          unavailableReason: l10n.resultUnavailableSms,
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
