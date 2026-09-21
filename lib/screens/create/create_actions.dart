import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/share_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../state/ads_state.dart';
import '../../state/generator_state.dart';
import '../../state/interstitial_session.dart';
import '../../state/pro_state.dart';
import '../../state/success_counts.dart';

/// ADS-9's interstitial, built from the app-wide state before any `await`, so
/// no [BuildContext] crosses one. Deciding whether it may show at all is
/// [AdsState]'s: this only asks.
AdsState _interstitial(BuildContext context) {
  final AppServices services = context.read<AppServices>();
  return AdsState(
    ads: services.ads,
    consent: services.consent,
    successCounts: context.read<SuccessCounts>(),
    proState: context.read<ProState>(),
    interstitialSession: context.read<InterstitialSession>(),
  );
}

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
  final AdsState ads = _interstitial(context);
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
      // Only once the file is written and confirmed (ADS-9). A cancelled or
      // failed save is not finished work and gets nothing.
      await ads.maybeShowInterstitial();
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
  final AdsState ads = _interstitial(context);
  try {
    await state.share();
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
    return;
  }
  // After the share sheet, never over it (ADS-9). Should the sheet still be up
  // when this runs, the ad cannot draw over a foreign activity and reports
  // that it never showed, so the session keeps its one for later.
  await ads.maybeShowInterstitial();
}
