import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-8's Text form: any text that fits (GEN-12), encoded as is.
class TextFormFields extends StatelessWidget {
  const TextFormFields({super.key});

  static const Key fieldKey = Key('create.text.field');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final TextForm form = state.form as TextForm;

    return CreateTextField(
      fieldKey: fieldKey,
      initialValue: form.text,
      onChanged: (String value) =>
          context.read<GeneratorState>().updateText(value),
      label: l10n.createTextFieldLabel,
      hint: l10n.createTextFieldHint,
      errorText: l10n.generatorFieldErrorMessage(
        state.fieldErrors[TextForm.fieldText],
      ),
      minLines: 4,
      maxLines: 8,
    );
  }
}
