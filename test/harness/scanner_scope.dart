import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/scanner_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

/// Provides a [ScannerState] to [child], built the way `main.dart` builds it:
/// from the settings, success counts, records and services the test shell
/// (`pumpApp`) already provides.
///
/// `pumpApp` knows nothing about the scanner, so a screen that reads
/// [ScannerState] — the app shell, the scanner screen — is pumped inside one of
/// these. The state is disposed with the tree when the test ends.
///
/// * [services] replaces the services the shell provides, for the scanner
///   only, so a harness entry, which can't pass `pumpApp` anything, can still
///   render a given phase (a denied camera, a camera that won't start).
/// * [onCreated] runs once the first frame is drawn, with the state, so an
///   entry can open a sheet the way the user would (pick a photo with two
///   codes in it).
class ScannerScope extends StatelessWidget {
  const ScannerScope({
    required this.child,
    this.services,
    this.onCreated,
    super.key,
  });

  final Widget child;
  final AppServices? services;
  final Future<void> Function(ScannerState scanner)? onCreated;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScannerState>(
      create: (BuildContext context) {
        final AppServices used = services ?? context.read<AppServices>();
        final ScannerState scanner = ScannerState(
          permissions: used.permissions,
          camera: used.cameraScanner,
          imageDecoder: used.imageDecoder,
          photoPicker: used.photoPicker,
          feedback: used.scanFeedback,
          records: context.read<RecordDao>(),
          settings: context.read<SettingsState>(),
          successCounts: context.read<SuccessCounts>(),
        );
        final Future<void> Function(ScannerState scanner)? hook = onCreated;
        if (hook != null) {
          // Not while the tree is being built: the state notifies.
          WidgetsBinding.instance.addPostFrameCallback((Duration _) {
            unawaited(hook(scanner));
          });
        }
        return scanner;
      },
      child: child,
    );
  }
}
