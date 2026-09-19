import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-8's Email form: address (required and validated), with optional
/// subject and body.
class EmailFormFields extends StatelessWidget {
  const EmailFormFields({super.key});

  static const Key toFieldKey = Key('create.email.to');
  static const Key subjectFieldKey = Key('create.email.subject');
  static const Key bodyFieldKey = Key('create.email.body');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final EmailForm form = state.form as EmailForm;
    final GeneratorState generator = context.read<GeneratorState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CreateTextField(
          fieldKey: toFieldKey,
          initialValue: form.to,
          onChanged: generator.updateEmailTo,
          label: l10n.createEmailToLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[EmailForm.fieldTo],
          ),
          keyboardType: TextInputType.emailAddress,
          forceLtr: true,
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: subjectFieldKey,
          initialValue: form.subject,
          onChanged: generator.updateEmailSubject,
          label: l10n.createEmailSubjectLabel,
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: bodyFieldKey,
          initialValue: form.body,
          onChanged: generator.updateEmailBody,
          label: l10n.createEmailBodyLabel,
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }
}
