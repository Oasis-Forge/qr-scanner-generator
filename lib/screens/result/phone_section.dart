import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A phone number (`tel:`, RES-7): the number, a leading `+` kept. The
/// primary action opens the dialer prefilled and never places the call
/// (RES-2).
class PhoneSection extends StatelessWidget {
  const PhoneSection({required this.phone, super.key});

  final Phone phone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResultState state = context.watch<ResultState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: ResultField(
            label: l10n.resultPhoneNumberLabel,
            value: phone.number,
            forceLtr: true,
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultPhonePrimaryButton,
          icon: Icons.call_outlined,
          onPressed: state.canDial
              ? () => performHandOff(context, state.dial)
              : null,
          unavailableReason: l10n.resultUnavailableDialer,
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
