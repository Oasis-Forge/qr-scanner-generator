import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-3's URL form: one field, exactly as typed, with a helper line showing
/// the address that will actually be encoded once `https://` is added.
class UrlFormFields extends StatelessWidget {
  const UrlFormFields({super.key});

  static const Key fieldKey = Key('create.url.field');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final UrlForm form = state.form as UrlForm;
    final String normalized = form.normalizedInput;

    return CreateTextField(
      fieldKey: fieldKey,
      initialValue: form.rawInput,
      onChanged: (String value) =>
          context.read<GeneratorState>().updateUrl(value),
      label: l10n.createUrlFieldLabel,
      hint: l10n.createUrlFieldHint,
      helperText: normalized.isEmpty
          ? null
          : l10n.createUrlHelperText(normalized),
      errorText: l10n.generatorFieldErrorMessage(
        state.fieldErrors[UrlForm.fieldUrl],
      ),
      keyboardType: TextInputType.url,
      forceLtr: true,
    );
  }
}
