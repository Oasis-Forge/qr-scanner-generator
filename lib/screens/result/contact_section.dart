import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A contact — vCard or MeCard (RES-6): name, phone numbers, emails and
/// organisation exactly as encoded. The primary action, "Add to contacts",
/// hands off to the system contacts app's insert form (`ACTION_INSERT`, no
/// contacts permission).
class ContactSection extends StatelessWidget {
  const ContactSection({required this.contact, super.key});

  final Contact contact;

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
                label: l10n.resultContactNameLabel,
                value: contact.name ?? '',
              ),
              for (final String phone in contact.phones)
                ResultField(
                  label: l10n.resultContactPhoneLabel,
                  value: phone,
                  forceLtr: true,
                ),
              for (final String email in contact.emails)
                ResultField(
                  label: l10n.resultContactEmailLabel,
                  value: email,
                  forceLtr: true,
                ),
              if (contact.organisation != null)
                ResultField(
                  label: l10n.resultContactOrganisationLabel,
                  value: contact.organisation!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultContactPrimaryButton,
          icon: Icons.person_add_outlined,
          onPressed: state.canAddToContacts
              ? () => performHandOff(context, state.addToContacts)
              : null,
          unavailableReason: l10n.resultUnavailableContacts,
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
