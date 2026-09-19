import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../db/record_dao.dart';
import '../models/payload_classifier.dart';
import '../models/record_enums.dart';
import '../models/scan_record.dart';
import '../services/camera_scanner.dart';
import '../services/image_decoder.dart';
import '../services/permission_service.dart';
import '../services/photo_picker.dart';
import '../services/scan_feedback.dart';
import 'scan_outcome.dart';
import 'settings_state.dart';
import 'success_counts.dart';

/// What the scanner area shows, decided from the camera permission (RUN-1 to
/// RUN-7) and whether the camera started.
enum ScannerPhase {
  /// The permission is being read. Draw the empty viewfinder with no text and
  /// no button, so a launch with the camera allowed never flashes RUN-1's
  /// placeholder on its way to the live scanner (RUN-7).
  checking,

  /// The camera was never asked for: the placeholder, one reason and "Allow
  /// camera", the largest control (RUN-1). Its tap is the only thing that
  /// ever asks (RUN-3). Also shown when a grant ended ("Only this time"
  /// expired), so the system prompt is asked for again with no dialog of our
  /// own (RUN-5).
  needsPermission,

  /// The user tapped "Don't allow" and Android will still ask: RUN-1's
  /// placeholder, reason and "Allow camera", plus "Scan a photo" and "Type a
  /// code", always visible (RUN-4).
  denied,

  /// Android won't show its prompt any more: as [denied], but the button is
  /// "Open settings" and calls [ScannerState.openSettings] (RUN-6).
  permanentlyDenied,

  /// The camera is allowed but didn't start: the phone has no usable back
  /// camera, or another app holds it. The screen offers "Scan a photo" and
  /// "Type a code"; the camera is tried again whenever the scanner is
  /// reopened or the app returns to the foreground.
  cameraUnavailable,

  /// The live scanner (RUN-7, SCAN-1). The preview from
  /// [ScannerState.buildPreview] shows as soon as the camera is running.
  granted,
}

/// A failure the scanner screen reports in a snackbar, then clears with
/// [ScannerState.clearError].
///
/// A history write that fails is not here: the result still opens and says so
/// itself (`ScanOutcome.saveFailed`).
enum ScannerError {
  /// The system photo picker couldn't be opened (SCAN-11).
  photoPickerFailed,

  /// "Open settings" couldn't open the app's permission page (RUN-6).
  settingsDidNotOpen,
}

/// The scanner: camera permission, live detection, torch, zoom, scanning a
/// photo and typed entry, and turning whatever was read into a [ScanOutcome].
///
/// Screens stay presentational (`CLAUDE.md`): the scanner screen draws
/// [phase], [outcome], [choices], [showsNoCodeFound] and the torch and zoom
/// getters, and calls the methods below; it never touches a device service.
///
/// **Lifecycle.** The screen calls [enter] when the scanner comes on screen
/// and [leave] when the user goes elsewhere, and forwards app lifecycle
/// changes to [onAppLifecycleChanged] (an `AppLifecycleListener` works). The
/// camera runs only while the scanner is on screen and the app is in the
/// foreground; opening a result doesn't leave the scanner, it pauses detection
/// (SCAN-3).
///
/// **Results.** Whenever [outcome] turns from null to a value, the screen
/// opens the result screen for it, whichever flow produced it (camera, photo,
/// typed entry, a pick from the list), and calls [closeResult] when that
/// screen closes. The methods that produce an outcome also return it, for a
/// caller that awaits; open the result from one place only.
///
/// **Writes.** A scan is written to History (DATA-4) before [outcome] changes,
/// and only while "Save history" is on (HIS-8); while it is off the outcome
/// carries an unsaved record and nothing is written (DATA-6). A failed write
/// still opens the result, from an unsaved record, with
/// `ScanOutcome.saveFailed` set. Every outcome, from the camera, a photo or
/// typed entry, counts as a successful scan (DATA-8); "No code found" and a
/// list the user dismissed don't.
///
/// This state starts the camera it was given but doesn't own it: [dispose]
/// stops the camera and leaves the service to whoever built it.
class ScannerState extends ChangeNotifier {
  /// [now] is the clock behind SCAN-3's 2 s pause and the time a scan is
  /// stamped with (REC-1); tests pass a fake one.
  ScannerState({
    required PermissionService permissions,
    required CameraScanner camera,
    required ImageDecoder imageDecoder,
    required PhotoPicker photoPicker,
    required ScanFeedback feedback,
    required RecordDao records,
    required SettingsState settings,
    required SuccessCounts successCounts,
    DateTime Function() now = DateTime.now,
  }) : _permissions = permissions,
       _camera = camera,
       _imageDecoder = imageDecoder,
       _photoPicker = photoPicker,
       _feedback = feedback,
       _records = records,
       _settings = settings,
       _successCounts = successCounts,
       _now = now {
    _detections = camera.detections.listen(_onPass);
  }

  /// How long a payload whose result just closed is ignored (SCAN-3).
  static const Duration samePayloadPause = Duration(seconds: 2);

  /// The zoom a double-tap switches to from 1x (SCAN-7).
  static const double doubleTapZoom = 2;

  /// The widest zoom (SCAN-7).
  static const double minZoom = 1;

  final PermissionService _permissions;
  final CameraScanner _camera;
  final ImageDecoder _imageDecoder;
  final PhotoPicker _photoPicker;
  final ScanFeedback _feedback;
  final RecordDao _records;
  final SettingsState _settings;
  final SuccessCounts _successCounts;
  final DateTime Function() _now;

  late final StreamSubscription<List<CodeDetection>> _detections;

  ScannerPhase _phase = ScannerPhase.checking;
  bool _onScreen = false;
  bool _inForeground = true;
  bool _disposed = false;

  /// What the camera permission last answered in this run of the app, from a
  /// request or a granted status. Spike S8: the system status can't tell
  /// "never asked" from "permanently denied", so the caller keeps the answer
  /// (see [PermissionService]).
  CameraPermissionState? _lastAnswer;

  /// Bumped by every permission check and request, so an older check that
  /// finishes late never overrides a newer answer.
  int _permissionCheck = 0;
  bool _requesting = false;
  Future<void>? _starting;

  ScanOutcome? _outcome;
  List<ScanChoice> _choices = const <ScanChoice>[];
  RecordSource _choicesSource = RecordSource.camera;

  /// The payloads of the list the current outcome was picked from, ignored
  /// with it once its result closes (SCAN-3, SCAN-13).
  Set<String> _listedKeys = const <String>{};
  bool _noCodeFound = false;
  bool _pickingPhoto = false;
  bool _processing = false;
  ScannerError? _error;

  Set<String> _ignoredKeys = const <String>{};
  DateTime? _ignoredUntil;

  bool _autoZoomEnabled = true;
  double _pinchStartZoom = minZoom;

  /// What the scanner area shows (RUN-1 to RUN-7).
  ScannerPhase get phase => _phase;

  /// Whether "Scan a photo" and "Type a code" show next to the placeholder:
  /// after a denial (RUN-4, RUN-6) and when the camera didn't start.
  bool get offersPhotoAndTyping =>
      _phase == ScannerPhase.denied ||
      _phase == ScannerPhase.permanentlyDenied ||
      _phase == ScannerPhase.cameraUnavailable;

  /// Whether the live preview is running.
  bool get isCameraRunning => _camera.isRunning;

  /// The result to show, or null. Set once the scan is written (or not, per
  /// HIS-8); cleared by [closeResult].
  ScanOutcome? get outcome => _outcome;

  /// The codes of a detection pass that found two or more, for the user to
  /// choose from (SCAN-13); empty otherwise. Detection is paused while they
  /// show.
  List<ScanChoice> get choices => _choices;

  /// Whether the multi-code list is open (SCAN-13).
  bool get hasChoices => _choices.isNotEmpty;

  /// Whether a picked photo held no code: "No code found", one hint, "Try
  /// another photo" ([pickPhoto]) and "Type a code" ([submitTyped]) (SCAN-11).
  /// Cleared by [dismissNoCodeFound], or by either of those.
  bool get showsNoCodeFound => _noCodeFound;

  /// Whether a photo is being picked or decoded (SCAN-11).
  bool get isPickingPhoto => _pickingPhoto;

  /// Whether a photo or a code is being turned into a result, so the screen
  /// can ignore a second tap.
  bool get isBusy => _pickingPhoto || _processing;

  /// The failure to report, or null.
  ScannerError? get error => _error;

  /// Whether the torch button shows: only on the live scanner of a camera that
  /// reports a flash (SCAN-6).
  bool get showsTorchButton =>
      _phase == ScannerPhase.granted &&
      _camera.isRunning &&
      _camera.torchState != TorchState.unavailable;

  /// Whether the torch is on (SCAN-6).
  bool get isTorchOn => _camera.torchState == TorchState.on;

  /// The current zoom, [minZoom] at the widest (SCAN-7).
  double get zoom => _camera.zoom;

  /// The largest zoom the slider reaches (SCAN-7), never below [minZoom].
  double get maxZoom => math.max(minZoom, _camera.maxZoom);

  /// Whether auto-zoom may step in. On each time the scanner opens; off after
  /// any manual zoom until the scanner is reopened (SCAN-7).
  bool get autoZoomEnabled => _autoZoomEnabled;

  /// The camera preview (RUN-7). Safe to build in every phase: it shows
  /// nothing until the camera is running.
  Widget buildPreview({BoxFit fit = BoxFit.cover}) =>
      _camera.buildPreview(fit: fit);

  /// The scanner came on screen: auto-zoom is back on (SCAN-7), the
  /// permission is read, and the camera starts if it is allowed (RUN-5,
  /// RUN-7). Asks for nothing (RUN-3).
  Future<void> enter() async {
    _onScreen = true;
    _autoZoomEnabled = true;
    await _quietly(() => _camera.setAutoZoom(enabled: true));
    await _refreshPermission();
  }

  /// The user left the scanner: the torch goes off (SCAN-6) and the camera
  /// stops. An open multi-code list or "No code found" closes with it; an open
  /// result stays until [closeResult].
  Future<void> leave() async {
    _onScreen = false;
    _permissionCheck++;
    _choices = const <ScanChoice>[];
    _noCodeFound = false;
    await _stopCamera();
    _notify();
  }

  /// Follows the app in and out of the foreground.
  ///
  /// Hidden or paused, the camera stops, torch included (SCAN-6). Resumed,
  /// the permission is read again, so a grant made in Settings or an "Only
  /// this time" that expired is picked up with no dialog of our own (RUN-5),
  /// and the camera starts again. Inactive (a system dialog or the
  /// notification shade on top) changes nothing.
  Future<void> onAppLifecycleChanged(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _inForeground = true;
        if (_onScreen) {
          await _refreshPermission();
        }
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _inForeground = false;
        await _stopCamera();
        _notify();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// "Allow camera": shows the system prompt (RUN-1, RUN-3). A grant goes
  /// straight to the live scanner (RUN-7); "Don't allow" is
  /// [ScannerPhase.denied] (RUN-4); an Android that won't ask again is
  /// [ScannerPhase.permanentlyDenied] (RUN-6).
  Future<void> requestPermission() async {
    if (_requesting || _disposed) {
      return;
    }
    _requesting = true;
    _permissionCheck++;
    CameraPermissionState? answer;
    try {
      answer = await _permissions.requestCamera();
    } on Object {
      answer = null;
    } finally {
      _requesting = false;
    }
    if (_disposed) {
      return;
    }
    if (answer == null) {
      await _refreshPermission();
      return;
    }
    _lastAnswer = answer;
    await _enterPhase(switch (answer) {
      CameraPermissionState.granted => ScannerPhase.granted,
      CameraPermissionState.denied => ScannerPhase.denied,
      CameraPermissionState.permanentlyDenied => ScannerPhase.permanentlyDenied,
    });
  }

  /// "Open settings": opens the app's permission page (RUN-6). Whatever the
  /// user changes there is read when the app comes back
  /// ([onAppLifecycleChanged], RUN-5). If the page doesn't open, [error] says
  /// so.
  Future<void> openSettings() async {
    // The user can change anything there, so the next check reads the system
    // afresh instead of trusting this run's last answer.
    _lastAnswer = null;
    bool opened;
    try {
      opened = await _permissions.openAppSettings();
    } on Object {
      opened = false;
    }
    if (!opened) {
      _error = ScannerError.settingsDidNotOpen;
      _notify();
    }
  }

  /// "Scan a photo": the system photo picker, then decoding at once, with no
  /// extra tap (SCAN-11). Works in every phase, the camera denied included
  /// (RUN-4).
  ///
  /// No code shows [showsNoCodeFound]; two or more open the [choices]
  /// (SCAN-13); one becomes the [outcome], with source `image`, which is also
  /// returned. Backing out of the picker changes nothing and returns null.
  /// Detection is paused while this runs.
  Future<ScanOutcome?> pickPhoto() async {
    if (isBusy || _disposed) {
      return null;
    }
    _pickingPhoto = true;
    _noCodeFound = false;
    _error = null;
    _notify();
    await _pauseDetection();
    try {
      String? path;
      try {
        path = await _photoPicker.pickImagePath();
      } on Object {
        _error = ScannerError.photoPickerFailed;
      }
      if (path == null) {
        return null;
      }
      ImageDecodeResult decoded;
      try {
        decoded = await _imageDecoder.decodeFile(path);
      } on Object {
        // The decoder promises not to throw; if it does, the photo held
        // nothing this app could read, which is what the user is told.
        decoded = const ImageDecodeResult.noCodeFound();
      }
      final List<CodeDetection> codes = _distinct(decoded.detections);
      if (codes.isEmpty) {
        _noCodeFound = true;
        return null;
      }
      if (codes.length > 1) {
        _showChoices(codes, RecordSource.image);
        return null;
      }
      final ScanOutcome result = await _outcomeOf(
        codes.single,
        RecordSource.image,
      );
      _outcome = result;
      return result;
    } finally {
      _pickingPhoto = false;
      await _resumeDetectionIfIdle();
      _notify();
    }
  }

  /// "Type a code": [typed] goes through the same classification and opens
  /// the same result as a camera scan, with source `manual` (SCAN-12).
  ///
  /// Leading and trailing whitespace is dropped. A barcode number with a valid
  /// check digit is stored as that barcode, so it opens a product result
  /// (`typedSymbologyOf`, RES-9). Blank text does nothing and returns null.
  Future<ScanOutcome?> submitTyped(String typed) async {
    final String text = typed.trim();
    if (text.isEmpty || isBusy || _disposed) {
      return null;
    }
    _processing = true;
    _notify();
    await _pauseDetection();
    try {
      final Symbology symbology = typedSymbologyOf(text);
      final ScanOutcome result = await _outcomeOf(
        CodeDetection(payload: text, symbology: symbology.id),
        RecordSource.manual,
        symbology: symbology,
      );
      _noCodeFound = false;
      _choices = const <ScanChoice>[];
      _outcome = result;
      return result;
    } finally {
      _processing = false;
      await _resumeDetectionIfIdle();
      _notify();
    }
  }

  /// Opens the result of the code the user picked from [choices] (SCAN-13),
  /// with the source the list came from. Returns null for a code that isn't
  /// in the list.
  Future<ScanOutcome?> choose(ScanChoice choice) async {
    if (!_choices.contains(choice) || _processing || _disposed) {
      return null;
    }
    _processing = true;
    _notify();
    try {
      final ScanOutcome result = await _outcomeOf(
        choice.detection,
        _choicesSource,
      );
      _listedKeys = <String>{
        for (final ScanChoice listed in _choices) _keyOf(listed.detection),
      };
      _choices = const <ScanChoice>[];
      _outcome = result;
      return result;
    } finally {
      _processing = false;
      _notify();
    }
  }

  /// Closes the multi-code list without a pick (SCAN-13). Its codes are
  /// ignored for [samePayloadPause], so the list doesn't reopen on the frame
  /// still in view; other codes scan normally (SCAN-3).
  Future<void> dismissChoices() async {
    if (_choices.isEmpty) {
      return;
    }
    _ignore(<String>{
      for (final ScanChoice listed in _choices) _keyOf(listed.detection),
    });
    _choices = const <ScanChoice>[];
    await _resumeDetectionIfIdle();
    _notify();
  }

  /// Closes "No code found" (SCAN-11).
  Future<void> dismissNoCodeFound() async {
    if (!_noCodeFound) {
      return;
    }
    _noCodeFound = false;
    await _resumeDetectionIfIdle();
    _notify();
  }

  /// The result screen closed: detection resumes, and the payload just shown
  /// (with the rest of the list it was picked from) is ignored for
  /// [samePayloadPause] while other codes scan normally (SCAN-3).
  Future<void> closeResult() async {
    final ScanOutcome? shown = _outcome;
    if (shown == null) {
      return;
    }
    _ignore(<String>{
      _keyOfPayload(shown.record.payloadText, shown.record.payloadBytes),
      ..._listedKeys,
    });
    _listedKeys = const <String>{};
    _outcome = null;
    if (_camera.isRunning) {
      await _resumeDetectionIfIdle();
    } else {
      await _startCamera();
    }
    _notify();
  }

  /// Clears [error] once the screen has reported it.
  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    _notify();
  }

  /// Turns the torch on or off (SCAN-6). Does nothing while
  /// [showsTorchButton] is false.
  Future<void> setTorch({required bool on}) async {
    if (!showsTorchButton) {
      return;
    }
    await _quietly(() => _camera.setTorch(on: on));
    _notify();
  }

  /// The torch button (SCAN-6).
  Future<void> toggleTorch() => setTorch(on: !isTorchOn);

  /// The zoom slider (SCAN-7): zooms to [value], clamped to [minZoom] ...
  /// [maxZoom]. A manual zoom turns auto-zoom off until the scanner is
  /// reopened.
  Future<void> setZoom(double value) async {
    await _stopAutoZoom();
    await _quietly(() => _camera.setZoom(value.clamp(minZoom, maxZoom)));
    _notify();
  }

  /// A pinch started: [updatePinch] scales from the zoom it started at
  /// (SCAN-7).
  void beginPinch() {
    _pinchStartZoom = zoom;
  }

  /// A pinch moved: [scale] is the gesture's scale since [beginPinch]
  /// (SCAN-7). A manual zoom, so auto-zoom turns off.
  Future<void> updatePinch(double scale) => setZoom(_pinchStartZoom * scale);

  /// Double-tap (SCAN-7): from 1x to [doubleTapZoom], and from any other zoom
  /// back to 1x. A manual zoom, so auto-zoom turns off.
  Future<void> toggleZoom() {
    final bool atWidest = zoom < minZoom + 0.05;
    return setZoom(atWidest ? doubleTapZoom : minZoom);
  }

  /// Limits detection to the square target (SCAN-4): about 70% of the
  /// preview's shorter side, in the preview's coordinates. `null` clears it.
  Future<void> setScanWindow(Rect? window) =>
      _quietly(() => _camera.setScanWindow(window));

  @override
  void dispose() {
    _disposed = true;
    _permissionCheck++;
    unawaited(_detections.cancel());
    unawaited(_stopCamera());
    super.dispose();
  }

  // --- Permission (RUN-1 to RUN-7) ---------------------------------------

  /// Reads the permission and moves to its phase, starting or stopping the
  /// camera. Skipped while a request is showing the system prompt: that
  /// request's answer decides.
  Future<void> _refreshPermission() async {
    if (_requesting || _disposed) {
      return;
    }
    final int check = ++_permissionCheck;
    final ScannerPhase next = await _readPermissionPhase();
    if (_disposed || _requesting || check != _permissionCheck) {
      return;
    }
    await _enterPhase(next);
  }

  /// The phase the permission calls for now, without asking the user (RUN-3).
  ///
  /// Spike S8: the status only says granted or denied. A denial is read from
  /// this run's last answer when there is one: a grant that has since ended is
  /// RUN-5's "ask again", and a request's own answer stands. Otherwise from
  /// the system: never requested is RUN-1; requested with a rationale is
  /// RUN-4, since Android will ask again; requested with no rationale is
  /// RUN-6, since Android has stopped asking.
  Future<ScannerPhase> _readPermissionPhase() async {
    try {
      final CameraPermissionState status = await _permissions.cameraStatus();
      if (status == CameraPermissionState.granted) {
        _lastAnswer = CameraPermissionState.granted;
        return ScannerPhase.granted;
      }
      switch (_lastAnswer) {
        case CameraPermissionState.granted:
          return ScannerPhase.needsPermission;
        case CameraPermissionState.denied:
          return ScannerPhase.denied;
        case CameraPermissionState.permanentlyDenied:
          return ScannerPhase.permanentlyDenied;
        case null:
          break;
      }
      if (!await _permissions.cameraRequestedBefore()) {
        return ScannerPhase.needsPermission;
      }
      return await _permissions.shouldShowCameraRationale()
          ? ScannerPhase.denied
          : ScannerPhase.permanentlyDenied;
    } on Object {
      // Unreadable: offer "Allow camera", whose request gets a real answer.
      return ScannerPhase.needsPermission;
    }
  }

  Future<void> _enterPhase(ScannerPhase next) async {
    if (next != ScannerPhase.granted) {
      _phase = next;
      await _stopCamera();
      _notify();
      return;
    }
    // A camera that didn't start keeps saying so while it is tried again,
    // rather than flashing the live phase in between.
    if (_phase != ScannerPhase.cameraUnavailable) {
      _phase = ScannerPhase.granted;
      _notify();
    }
    await _startCamera();
  }

  // --- Camera -------------------------------------------------------------

  bool get _shouldRun =>
      !_disposed &&
      _onScreen &&
      _inForeground &&
      // A result is on top: the camera doesn't start underneath it (a typed
      // or photo result would otherwise stream behind the result screen).
      // [closeResult] starts it again.
      _outcome == null &&
      (_phase == ScannerPhase.granted ||
          _phase == ScannerPhase.cameraUnavailable);

  /// Starts the camera when the scanner is on screen, in the foreground and
  /// allowed (RUN-7). Concurrent calls share one start.
  Future<void> _startCamera() {
    return _starting ??= _startOnce().whenComplete(() => _starting = null);
  }

  Future<void> _startOnce() async {
    if (!_shouldRun) {
      return;
    }
    if (_camera.isRunning) {
      _phase = ScannerPhase.granted;
      _notify();
      return;
    }
    bool started;
    try {
      started = await _camera.start();
    } on Object {
      started = false;
    }
    if (!_shouldRun) {
      // Left, backgrounded or disposed while the camera was starting.
      if (started) {
        await _stopCamera();
      }
      return;
    }
    if (!started) {
      // Either the permission went while we weren't looking, or there is no
      // camera to be had.
      final ScannerPhase next = await _readPermissionPhase();
      _phase = next == ScannerPhase.granted
          ? ScannerPhase.cameraUnavailable
          : next;
      _notify();
      return;
    }
    _phase = ScannerPhase.granted;
    if (_holdsDetection) {
      await _quietly(_camera.pause);
    }
    _notify();
  }

  /// Turns the torch off (SCAN-6) and stops the camera.
  Future<void> _stopCamera() async {
    if (_camera.torchState == TorchState.on) {
      await _quietly(() => _camera.setTorch(on: false));
    }
    if (_camera.isRunning) {
      await _quietly(_camera.stop);
    }
  }

  /// Whether something is on top of the live scanner, so detection stays
  /// paused (SCAN-3, SCAN-11, SCAN-13).
  bool get _holdsDetection =>
      _outcome != null ||
      _choices.isNotEmpty ||
      _noCodeFound ||
      _pickingPhoto ||
      _processing;

  Future<void> _pauseDetection() async {
    if (_camera.isRunning) {
      await _quietly(_camera.pause);
    }
  }

  Future<void> _resumeDetectionIfIdle() async {
    if (_camera.isRunning && _shouldRun && !_holdsDetection) {
      await _quietly(_camera.resume);
    }
  }

  Future<void> _stopAutoZoom() async {
    if (!_autoZoomEnabled) {
      return;
    }
    await _quietly(() => _camera.setAutoZoom(enabled: false));
    _autoZoomEnabled = false;
  }

  // --- Detection (SCAN-3 to SCAN-5, SCAN-13) --------------------------------

  void _onPass(List<CodeDetection> pass) => unawaited(_handlePass(pass));

  Future<void> _handlePass(List<CodeDetection> pass) async {
    if (!_shouldRun || _phase != ScannerPhase.granted || _holdsDetection) {
      return;
    }
    final List<CodeDetection> codes = _notIgnored(_distinct(pass));
    if (codes.isEmpty) {
      return;
    }
    _processing = true;
    // First, for SCAN-3's 150 ms haptic budget.
    unawaited(_giveFeedback());
    try {
      await _quietly(_camera.pause);
      if (codes.length > 1) {
        _showChoices(codes, RecordSource.camera);
        return;
      }
      _outcome = await _outcomeOf(codes.single, RecordSource.camera);
    } finally {
      _processing = false;
      _notify();
    }
  }

  /// SET-2's switches, read at the moment of the scan (SCAN-5).
  Future<void> _giveFeedback() async {
    try {
      await _feedback.success(
        vibrate: _settings.vibrateOnScan,
        sound: _settings.soundOnScan,
      );
    } on Object {
      // Feedback is a courtesy: a scan never fails over a missing vibrator.
    }
  }

  void _showChoices(List<CodeDetection> codes, RecordSource source) {
    _choices = List<ScanChoice>.unmodifiable(codes.map(ScanChoice.of));
    _choicesSource = source;
  }

  /// Each code once, in the order the decoder reported them.
  List<CodeDetection> _distinct(List<CodeDetection> codes) =>
      codes.toSet().toList(growable: false);

  /// Drops the payloads SCAN-3 is still ignoring.
  List<CodeDetection> _notIgnored(List<CodeDetection> codes) {
    final DateTime? until = _ignoredUntil;
    if (until == null || !_now().isBefore(until)) {
      _ignoredKeys = const <String>{};
      _ignoredUntil = null;
      return codes;
    }
    return codes
        .where((CodeDetection code) => !_ignoredKeys.contains(_keyOf(code)))
        .toList(growable: false);
  }

  void _ignore(Set<String> keys) {
    _ignoredKeys = keys;
    _ignoredUntil = _now().add(samePayloadPause);
  }

  String _keyOf(CodeDetection code) =>
      _keyOfPayload(code.payload, code.isValidUtf8 ? null : code.rawBytes);

  /// The raw payload, whatever format it came in: SCAN-3 ignores "the same
  /// payload".
  String _keyOfPayload(String text, Uint8List? bytes) =>
      bytes == null ? 'text:$text' : 'bytes:${base64Encode(bytes)}';

  // --- Recording (DATA-4, DATA-6, DATA-8, HIS-8) ---------------------------

  /// Classifies [code], writes it when "Save history" is on, and counts the
  /// success. Never throws: a failed write becomes an unsaved outcome with
  /// `saveFailed` set.
  Future<ScanOutcome> _outcomeOf(
    CodeDetection code,
    RecordSource source, {
    Symbology? symbology,
  }) async {
    final Symbology format =
        symbology ?? symbologyFromDecoderName(code.symbology);
    final bool isBinary = !code.isValidUtf8;
    final ParsedType type = classifyPayload(
      code.payload,
      symbology: format,
      isBinary: isBinary,
    );
    final Uint8List? bytes = isBinary ? code.rawBytes : null;
    final List<String> sensitive = sensitiveFieldsOf(type);
    final DateTime at = _now();

    ScanOutcome unsaved({required bool saveFailed}) => ScanOutcome(
      record: ScanRecord(
        id: ScanOutcome.unsavedRecordId,
        seq: 0,
        kind: RecordKind.scan,
        source: source,
        symbology: format,
        parsedType: type,
        payloadText: code.payload,
        payloadBytes: bytes,
        sensitiveFields: sensitive,
        createdAt: at,
        updatedAt: at,
        lastSeenAt: at,
      ),
      parsedType: type,
      symbology: format,
      source: source,
      isSaved: false,
      saveFailed: saveFailed,
    );

    ScanOutcome result;
    if (_settings.saveHistory) {
      try {
        final RecordWrite write = await _records.recordScan(
          kind: RecordKind.scan,
          source: source,
          symbology: format,
          parsedType: type,
          payloadText: code.payload,
          payloadBytes: bytes,
          sensitiveFields: sensitive,
          at: at,
        );
        result = ScanOutcome(
          record: write.record,
          parsedType: type,
          symbology: format,
          source: source,
          isSaved: true,
          isDuplicate: write.isDuplicate,
        );
      } on Object {
        result = unsaved(saveFailed: true);
      }
    } else {
      // DATA-6: nothing is written while "Save history" is off.
      result = unsaved(saveFailed: false);
    }

    try {
      await _successCounts.recordSuccessfulScan();
    } on Object {
      // DATA-8: the count only gates ads and prompts. A failed count leaves
      // the stored value as it was and the result opens regardless; nothing
      // the user could act on is worth a message.
    }
    return result;
  }

  // --- Plumbing -----------------------------------------------------------

  /// Runs a camera call whose failure the screen can't act on. The getters
  /// read the camera's own state afterwards, so the screen still shows the
  /// truth.
  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      // See above.
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
