import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/record_enums.dart';
import '../state/scan_outcome.dart';
import '../state/scanner_state.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';
import 'scanner/code_labels.dart';
import 'scanner/live_viewfinder.dart';
import 'scanner/no_code_found_panel.dart';
import 'scanner/permission_placeholder.dart';
import 'scanner/scan_choices_sheet.dart';

/// The Scan tab, where the app opens (SCAN-1).
///
/// Presentational (`CLAUDE.md`): it draws [ScannerState.phase] and whatever
/// the state has on top of it, and hands every tap to the state. It touches no
/// device service; the camera preview itself comes from
/// [ScannerState.buildPreview].
///
/// * No camera yet: RUN-1's placeholder, RUN-4's "Scan a photo" and "Type a
///   code", RUN-6's "Open settings" ([PermissionPlaceholder]).
/// * [ScannerPhase.checking]: the empty viewfinder, no text and no button, so a
///   launch with the camera allowed never flashes the placeholder (RUN-7).
/// * [ScannerPhase.granted]: the live scanner ([LiveViewfinder]).
/// * Several codes in one pass: the list to choose from (SCAN-13).
/// * A photo with no code: "No code found" (SCAN-11).
///
/// **Lifecycle.** The scanner is entered when this screen comes on screen and
/// left when it goes (another tab, or typing a code), and it follows the app
/// in and out of the foreground, so the camera and the torch only run while
/// the user can see them (SCAN-6).
///
/// **Results.** Whenever [ScannerState.outcome] turns up, from the camera, a
/// photo, typed entry or a pick from the list, this screen, and only this
/// screen, opens [ResultScreen] for it (RES-3). When that screen closes it
/// tells the state, so detection resumes and the code just shown is ignored
/// for 2 s (SCAN-3). A detected code is announced to screen readers in the
/// app's language and direction (A11Y-3).
///
/// No ad appears anywhere on it (ADS-1).
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  /// Read once: this screen enters and leaves it, and must still reach it in
  /// [dispose], where the tree can no longer be read.
  late final ScannerState _scanner;
  late final AppLifecycleListener _lifecycle;

  /// Whether the result route is open, so one outcome opens one screen.
  bool _resultOpen = false;

  /// Whether the typed-entry screen is open.
  bool _typing = false;

  /// Whether the outcome about to open was picked from the list, which was
  /// already announced (A11Y-3).
  bool _pickedFromList = false;

  /// Whether the list of codes was showing at the last change, so it is
  /// announced once when it appears (A11Y-3).
  bool _hadChoices = false;

  @override
  void initState() {
    super.initState();
    _scanner = context.read<ScannerState>();
    _scanner.addListener(_onScannerChanged);
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) =>
          unawaited(_scanner.onAppLifecycleChanged(state)),
    );
    unawaited(_scanner.enter());
    // A result the state already holds (none in practice) still opens.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _onScannerChanged();
    });
  }

  @override
  void dispose() {
    _scanner.removeListener(_onScannerChanged);
    _lifecycle.dispose();
    // The user went elsewhere: the camera and the torch stop (SCAN-6).
    unawaited(_scanner.leave());
    super.dispose();
  }

  /// Reacts to what the state just changed: opens a result, announces a
  /// detection, and reports an error once.
  void _onScannerChanged() {
    if (!mounted) {
      return;
    }
    final ScanOutcome? outcome = _scanner.outcome;
    if (outcome != null && !_resultOpen) {
      unawaited(_openResult(outcome));
    }

    final bool hasChoices = _scanner.hasChoices;
    if (hasChoices && !_hadChoices) {
      _announce(
        AppLocalizations.of(context)
            .scanChoicesAnnouncement(_scanner.choices.length),
      );
    }
    _hadChoices = hasChoices;

    final ScannerError? error = _scanner.error;
    if (error != null) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (error) {
            ScannerError.photoPickerFailed => l10n.scanPhotoPickerFailed,
            ScannerError.settingsDidNotOpen => l10n.scanSettingsDidNotOpen,
          }),
        ),
      );
      _scanner.clearError();
    }
  }

  /// Opens the result for [outcome] and, once it closes, tells the state
  /// (SCAN-3). Nothing on the result opens by itself (RES-2).
  Future<void> _openResult(ScanOutcome outcome) async {
    _resultOpen = true;
    final bool announce =
        !_pickedFromList && outcome.source != RecordSource.manual;
    _pickedFromList = false;
    if (announce) {
      _announce(
        AppLocalizations.of(context)
            .detectedAnnouncement(outcome.parsedType, outcome.symbology),
      );
    }
    await Navigator.of(context).push<void>(ResultScreen.route(outcome));
    _resultOpen = false;
    await _scanner.closeResult();
  }

  /// A11Y-3: says what was found, in the app's language and its direction.
  void _announce(String message) {
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
      ),
    );
  }

  /// "Scan a photo" and "Try another photo" (SCAN-11). The state decides
  /// what follows: a result, the list, or "No code found".
  void _scanPhoto() => unawaited(_scanner.pickPhoto());

  /// "Type a code" (SCAN-12): the scanner is left while the user types, so a
  /// code still in front of the camera can't open over the form, then the
  /// typed text goes through the same classification as a scan and the
  /// scanner is entered again.
  Future<void> _typeCode() async {
    if (_typing) {
      return;
    }
    _typing = true;
    // The form opens at once; the camera stops underneath it.
    final Future<String?> typing = Navigator.of(context)
        .push<String>(ManualEntryScreen.route());
    await _scanner.leave();
    final String? typed = await typing;
    _typing = false;
    if (typed != null) {
      await _scanner.submitTyped(typed);
    }
    if (mounted) {
      await _scanner.enter();
    }
  }

  void _choose(ScanChoice choice) {
    _pickedFromList = true;
    unawaited(_scanner.choose(choice));
  }

  @override
  Widget build(BuildContext context) {
    final ScannerState scanner = context.watch<ScannerState>();
    final bool hasOverlay = scanner.hasChoices || scanner.showsNoCodeFound;

    return PopScope(
      // Back closes the list or "No code found" before it leaves the scanner.
      canPop: !hasOverlay,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _dismissOverlay(scanner);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _phaseBody(scanner),
            if (scanner.isPickingPhoto) const _ReadingPhoto(),
            if (hasOverlay) ...<Widget>[
              ModalBarrier(
                color: Colors.black54,
                semanticsLabel: AppLocalizations.of(context).actionClose,
                onDismiss: () => _dismissOverlay(scanner),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: scanner.hasChoices
                    ? ScanChoicesSheet(
                        choices: scanner.choices,
                        onChoose: _choose,
                        onClose: () => unawaited(scanner.dismissChoices()),
                      )
                    : NoCodeFoundPanel(
                        busy: scanner.isBusy,
                        onTryAnotherPhoto: _scanPhoto,
                        onTypeCode: () => unawaited(_typeCode()),
                        onClose: () => unawaited(scanner.dismissNoCodeFound()),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _dismissOverlay(ScannerState scanner) {
    if (scanner.hasChoices) {
      unawaited(scanner.dismissChoices());
    } else if (scanner.showsNoCodeFound) {
      unawaited(scanner.dismissNoCodeFound());
    }
  }

  Widget _phaseBody(ScannerState scanner) {
    return switch (scanner.phase) {
      // RUN-7: nothing to read yet, so nothing is drawn.
      ScannerPhase.checking => const ColoredBox(color: Colors.black),
      ScannerPhase.granted => LiveViewfinder(
        onScanPhoto: _scanPhoto,
        onTypeCode: () => unawaited(_typeCode()),
      ),
      ScannerPhase.needsPermission ||
      ScannerPhase.denied ||
      ScannerPhase.permanentlyDenied ||
      ScannerPhase.cameraUnavailable => PermissionPlaceholder(
        phase: scanner.phase,
        offersPhotoAndTyping: scanner.offersPhotoAndTyping,
        busy: scanner.isBusy,
        onAllowCamera: () => unawaited(scanner.requestPermission()),
        onOpenSettings: () => unawaited(scanner.openSettings()),
        onScanPhoto: _scanPhoto,
        onTypeCode: () => unawaited(_typeCode()),
      ),
    };
  }
}

/// Shown while a picked photo is read (SCAN-11), with a name a screen reader
/// can say.
class _ReadingPhoto extends StatelessWidget {
  const _ReadingPhoto();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(
          semanticsLabel: AppLocalizations.of(context).scanReadingPhoto,
        ),
      ),
    );
  }
}
