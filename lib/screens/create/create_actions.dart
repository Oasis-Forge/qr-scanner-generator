import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/share_service.dart';
import '../../l10n/app_localizations.dart';
import '../../state/generator_state.dart';

/// SAVE-1, SAVE-2, SAVE-4: writes the created code through the system file
/// picker, and says so.
///
/// A saved file is confirmed by name, a cancelled save says nothing (the
/// user chose to back out), and a failure is confirmed with the same message
/// `settings_screen.dart` uses for its own failed writes.
///
/// The messenger and the strings are read before the `await`, so no
/// [BuildContext] is used across it (the pattern `settings_screen.dart`
/// documents for the same reason).
Future<void> saveCreatedCode(BuildContext context) async {
  final GeneratorState state = context.read<GeneratorState>();
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final AppLocalizations l10n = AppLocalizations.of(context);
  final SaveResult result = await state.save();
  switch (result.outcome) {
    case SaveOutcome.saved:
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (result.displayName) {
            final String name => l10n.createSavedSnackbar(name),
            null => l10n.createSavedSnackbarNoName,
          }),
        ),
      );
    case SaveOutcome.cancelled:
      break;
    case SaveOutcome.failed:
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorSaveFailed)));
  }
}

/// SAVE-1, SAVE-5: hands the exact file [saveCreatedCode] would write to the
/// system share sheet, without re-encoding it. Says nothing on success — the
/// share sheet opening is confirmation enough — and one line on failure.
Future<void> shareCreatedCode(BuildContext context) async {
  final GeneratorState state = context.read<GeneratorState>();
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final String failed = AppLocalizations.of(context).createShareFailed;
  try {
    await state.share();
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
