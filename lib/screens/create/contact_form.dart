import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-6's Contact form (closed-test fields): name (required), phone, email
/// and organisation.
class ContactFormFields extends StatelessWidget {
  const ContactFormFields({super.key});

  static const Key nameFieldKey = Key('create.contact.name');
  static const Key phoneFieldKey = Key('create.contact.phone');
  static const Key emailFieldKey = Key('create.contact.email');
  static const Key organisationFieldKey = Key('create.contact.organisation');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final ContactForm form = state.form as ContactForm;
    final GeneratorState generator = context.read<GeneratorState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CreateTextField(
          fieldKey: nameFieldKey,
          initialValue: form.name,
          onChanged: generator.updateContactName,
          label: l10n.createContactNameLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[ContactForm.fieldName],
          ),
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: phoneFieldKey,
          initialValue: form.phone,
          onChanged: generator.updateContactPhone,
          label: l10n.createContactPhoneLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[ContactForm.fieldPhone],
          ),
          keyboardType: TextInputType.phone,
          forceLtr: true,
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: emailFieldKey,
          initialValue: form.email,
          onChanged: generator.updateContactEmail,
          label: l10n.createContactEmailLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[ContactForm.fieldEmail],
          ),
          keyboardType: TextInputType.emailAddress,
          forceLtr: true,
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: organisationFieldKey,
          initialValue: form.organisation,
          onChanged: generator.updateContactOrganisation,
          label: l10n.createContactOrganisationLabel,
        ),
      ],
    );
  }
}
