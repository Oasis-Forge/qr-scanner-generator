import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-7's Phone form: one number, encoded as `tel:<number>`.
///
/// The field accepts `+` and separators (spaces, dashes, brackets) as the
/// user types (GEN-7); they are removed only when the payload is encoded,
/// never here, and a leading `+` is never dropped.
class PhoneFormFields extends StatelessWidget {
  const PhoneFormFields({super.key});

  static const Key fieldKey = Key('create.phone.field');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final PhoneForm form = state.form as PhoneForm;

    return CreateTextField(
      fieldKey: fieldKey,
      initialValue: form.number,
      onChanged: (String value) =>
          context.read<GeneratorState>().updatePhoneNumber(value),
      label: l10n.createPhoneFieldLabel,
      errorText: l10n.generatorFieldErrorMessage(
        state.fieldErrors[PhoneForm.fieldNumber],
      ),
      keyboardType: TextInputType.phone,
      forceLtr: true,
    );
  }
}
