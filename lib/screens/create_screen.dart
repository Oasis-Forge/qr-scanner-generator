import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart' show AppLocalizations;
import '../models/record_enums.dart' show ParsedType;
import '../state/ads_state.dart';
import '../state/generator_state.dart';
import 'ads/ad_banner_slot.dart';
import 'create/create_form_body.dart';
import 'create/created_code_view.dart';
import 'create/type_picker.dart';
import 'scanner/code_labels.dart';

/// The Create tab (GEN-1 to GEN-13, STY-1, STY-5, SAVE-1).
///
/// Three steps, all inside this one screen rather than pushed as separate
/// routes — [GeneratorState] is provided once, above the app shell
/// (`main.dart`), and a pushed route would sit outside that provider's
/// scope, so the steps are plain conditional bodies of one [Scaffold]
/// instead:
///
/// 1. The type picker (GEN-1): the only place in this flow an ad may appear
///    (ADS-1).
/// 2. The chosen type's form, with the GEN-12 capacity meter and Create.
/// 3. The created code (STY-1, SAVE-1), once `GeneratorState.create` has
///    been called at least once for this selection — derived from
///    [GeneratorState] itself (`isCreating`, `renderedPng`, `checkError`),
///    never tracked separately here, so it reflects exactly what the state
///    holds.
///
/// Which type is chosen is the one thing this screen tracks on its own:
/// [GeneratorState] always has *some* type selected (it keeps its form
/// while the app runs), so "has the user opened a form yet" has to live here instead.
/// Leaving the Create tab (`app_shell.dart` builds only the selected tab)
/// discards that choice and returns here to the picker next time; the form
/// and any code it created are untouched, since [GeneratorState] itself
/// lives as long as the app.
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  /// Leaves the form or the created code back to the type picker.
  static const Key backKey = Key('create.back');

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  bool _typeChosen = false;

  void _chooseType(ParsedType type) {
    context.read<GeneratorState>().setType(type);
    setState(() => _typeChosen = true);
  }

  /// Back one step: from a created code to its form (fields kept),
  /// from a form to the type picker.
  void _back() {
    final GeneratorState state = context.read<GeneratorState>();
    if (state.renderedPng != null || state.checkError != null) {
      state.backToForm();
      return;
    }
    setState(() => _typeChosen = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!_typeChosen) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navCreate)),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Expanded(child: CreateTypePicker(onSelected: _chooseType)),
              // Fixed below the picker, the one Create step an ad may sit on;
              // never a form or a created code (ADS-1, ADS-3).
              const AdBannerSlot(slot: AdSlots.createTypePicker),
            ],
          ),
        ),
      );
    }

    final GeneratorState state = context.watch<GeneratorState>();
    final bool showsCreated =
        state.isCreating ||
        state.renderedPng != null ||
        state.checkError != null;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(key: CreateScreen.backKey, onPressed: _back),
        title: Text(l10n.parsedTypeLabel(state.type)),
      ),
      body: SafeArea(
        top: false,
        child: showsCreated ? const CreatedCodeView() : const CreateFormBody(),
      ),
    );
  }
}
