import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/record_enums.dart' show ParsedType;
import '../../state/generator_state.dart';
import '../scanner/scanner_layout.dart';
import 'capacity_meter.dart';
import 'contact_form.dart';
import 'email_form.dart';
import 'phone_form.dart';
import 'sms_form.dart';
import 'text_form.dart';
import 'url_form.dart';
import 'wifi_form.dart';

/// GEN-1 to GEN-13's Create form: the fields for `GeneratorState.type`, the
/// GEN-12 capacity meter once it applies, and Create — the largest control,
/// disabled until the form is valid and within capacity.
class CreateFormBody extends StatelessWidget {
  const CreateFormBody({super.key});

  /// The largest control on a Create form (GEN-1); disabled until
  /// `GeneratorState.canCreate` is true.
  static const Key createButtonKey = Key('create.form.create_button');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _fieldsFor(state.type),
          if (state.showsCapacityMeter)
            CapacityMeter(ratio: state.capacityRatio),
          if (state.isOverCapacity) const CapacityOverLimitNotice(),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: createButtonKey,
            onPressed: state.canCreate
                ? () => unawaited(context.read<GeneratorState>().create())
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(
                ScannerLayout.primaryActionHeight,
              ),
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
            icon: const Icon(Icons.qr_code_2),
            label: Text(l10n.createButtonLabel),
          ),
        ],
      ),
    );
  }

  /// One widget per GEN-1 type, throwing for any [ParsedType] outside
  /// `generatorTypes` the same way `emptyGeneratorForm` does — never reached
  /// in practice, since `GeneratorState.setType` only ever sets one of the
  /// seven GEN-1 types.
  Widget _fieldsFor(ParsedType type) => switch (type) {
    ParsedType.url => const UrlFormFields(),
    ParsedType.text => const TextFormFields(),
    ParsedType.wifi => const WifiFormFields(),
    ParsedType.contact => const ContactFormFields(),
    ParsedType.phone => const PhoneFormFields(),
    ParsedType.email => const EmailFormFields(),
    ParsedType.sms => const SmsFormFields(),
    _ => throw ArgumentError.value(
      type,
      'type',
      'is not a generator type (GEN-1)',
    ),
  };
}
