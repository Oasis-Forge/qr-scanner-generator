import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-7, GEN-8's SMS form: number (required, GEN-7) and an optional
/// message.
class SmsFormFields extends StatelessWidget {
  const SmsFormFields({super.key});

  static const Key numberFieldKey = Key('create.sms.number');
  static const Key messageFieldKey = Key('create.sms.message');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final SmsForm form = state.form as SmsForm;
    final GeneratorState generator = context.read<GeneratorState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CreateTextField(
          fieldKey: numberFieldKey,
          initialValue: form.number,
          onChanged: generator.updateSmsNumber,
          label: l10n.createSmsNumberLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[SmsForm.fieldNumber],
          ),
          keyboardType: TextInputType.phone,
          forceLtr: true,
        ),
        const SizedBox(height: 16),
        CreateTextField(
          fieldKey: messageFieldKey,
          initialValue: form.message,
          onChanged: generator.updateSmsMessage,
          label: l10n.createSmsMessageLabel,
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }
}
