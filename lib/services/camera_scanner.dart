import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// One code found in one detection pass, from the camera or from a still image.
///
/// The payload travels as UTF-8 text plus the raw bytes when they aren't valid
/// UTF-8, from the moment of detection (DATA-2). No frame or image is ever kept
/// (DATA-3).
@immutable
class CodeDetection {
  const CodeDetection({
    required this.payload,
    required this.symbology,
    this.rawBytes,
    this.isValidUtf8 = true,
  });

  /// The decoded text. Best effort when [isValidUtf8] is false, where the result
  /// screen shows "Binary data, N bytes" from [rawBytes] instead (RES-13).
  final String payload;

  /// The code's format as the app's fixed symbology id (`qr`, `ean13`,
  /// `data_matrix`...: `Symbology.id` in `lib/models/record_enums.dart`), so it
  /// is stored as is and read back with `Symbology.fromId` (DATA-1, DATA-2).
  ///
  /// A device decoder hands over only SCAN-9's formats; a code in any other
  /// format never becomes a detection (SCAN-9).
  final String symbology;

  /// The raw bytes, kept only when the content isn't text, so a text code never
  /// stores a second copy of itself (DATA-2).
  final Uint8List? rawBytes;

  /// Whether [payload] is the whole content as valid UTF-8 text.
  final bool isValidUtf8;

  @override
  bool operator ==(Object other) =>
      other is CodeDetection &&
      other.payload == payload &&
      other.symbology == symbology &&
      other.isValidUtf8 == isValidUtf8 &&
      listEquals(other.rawBytes, rawBytes);

  @override
  int get hashCode =>
      Object.hash(payload, symbology, isValidUtf8, rawBytes?.length);

  @override
  String toString() => 'CodeDetection($symbology, $payload)';
}

/// Whether the device's torch can be used, and whether it is on (SCAN-6).
enum TorchState {
  /// The camera reports no flash, so no torch button is shown (SCAN-6).
  unavailable,
  off,
  on,
}

/// The live camera scanner.
///
/// The surface is separate from starting the camera, so the scanner screen shows
/// RUN-1's placeholder, RUN-4's denied state and RUN-7's live preview from one
/// tree, and nothing about this interface assumes the camera permission has been
/// granted.
abstract class CameraScanner {
  /// One event per detection pass, carrying every code that pass found, so two
  /// or more can be listed instead of guessed at (SCAN-13).
  Stream<List<CodeDetection>> get detections;

  /// The preview surface.
  ///
  /// Safe to build before the camera permission is granted: it shows nothing
  /// until [start] succeeds, so the layout never jumps when permission is
  /// granted later (RUN-1, RUN-4, RUN-5, RUN-7).
  Widget buildPreview({BoxFit fit = BoxFit.cover});

  /// Starts the camera and reports whether a live preview is running.
  ///
  /// False when the camera permission isn't granted or no camera is available;
  /// the caller keeps RUN-1's placeholder, reason and button then (RUN-1,
  /// RUN-4).
  Future<bool> start();

  /// Stops the camera and releases it, turning the torch off (SCAN-6).
  Future<void> stop();

  /// Whether the camera is running.
  bool get isRunning;

  /// Stops delivering detections while a result is open, keeping the camera
  /// (SCAN-3).
  Future<void> pause();

  /// Delivers detections again (SCAN-3).
  Future<void> resume();

  /// Whether detections are being delivered.
  bool get isDetecting;

  /// Limits detection to [window], the square target of about 70% of the
  /// screen's shorter side, so codes outside it are ignored (SCAN-4). `null`
  /// clears the limit.
  Future<void> setScanWindow(Rect? window);

  /// Whether the camera reports a flash, and whether the torch is on (SCAN-6).
  TorchState get torchState;

  /// Turns the torch on or off. Does nothing while [torchState] is
  /// [TorchState.unavailable] (SCAN-6, SCAN-10).
  Future<void> setTorch({required bool on});

  /// The current zoom, 1.0 at the widest (SCAN-7).
  double get zoom;

  /// The largest zoom the camera reports; SCAN-7's 2x needs at least 2.0.
  double get maxZoom;

  /// Zooms to [zoom], clamped to 1.0 ... [maxZoom] (SCAN-7).
  Future<void> setZoom(double zoom);

  /// Turns auto-zoom on or off (SCAN-7).
  ///
  /// With it on, the camera steps in by itself when a code is seen but too
  /// small to read. SCAN-7 turns it off at the first manual zoom (slider, pinch
  /// or double-tap) and back on when the scanner is reopened; the caller decides
  /// when, this only applies it. It is on until the first call.
  Future<void> setAutoZoom({required bool enabled});

  /// Releases the camera and closes [detections].
  Future<void> dispose();
}

/// A [CameraScanner] that opens no camera.
///
/// It records every call in [calls] and keeps the state the interface exposes,
/// so a scanner screen can be driven without hardware: [start] reports
/// [startSucceeds], [emit] delivers a detection pass, and the torch and zoom
/// behave as the rules expect.
class NoopCameraScanner implements CameraScanner {
  NoopCameraScanner({
    this.startSucceeds = true,
    bool torchAvailable = true,
    this.maxZoom = 4,
  }) : _torchState = torchAvailable ? TorchState.off : TorchState.unavailable;

  /// Every call made, in order, such as `'setTorch: true'`.
  final List<String> calls = <String>[];

  /// What [start] reports, so a denied-permission screen can be driven (RUN-4).
  final bool startSucceeds;

  @override
  final double maxZoom;

  final StreamController<List<CodeDetection>> _detections =
      StreamController<List<CodeDetection>>.broadcast();

  TorchState _torchState;
  bool _running = false;
  bool _detecting = false;
  double _zoom = 1;
  bool _autoZoom = true;
  Rect? _scanWindow;

  /// The scan window last set, so a test can assert SCAN-4's target.
  Rect? get scanWindow => _scanWindow;

  /// Whether auto-zoom is on, so a test can assert that a manual zoom turned it
  /// off and reopening the scanner turned it back on (SCAN-7).
  bool get autoZoomEnabled => _autoZoom;

  /// Delivers one detection pass to [detections], as the camera would.
  void emit(List<CodeDetection> pass) {
    if (_detecting) {
      _detections.add(List<CodeDetection>.unmodifiable(pass));
    }
  }

  @override
  Stream<List<CodeDetection>> get detections => _detections.stream;

  @override
  Widget buildPreview({BoxFit fit = BoxFit.cover}) {
    calls.add('buildPreview: $fit');
    return const SizedBox.shrink();
  }

  @override
  Future<bool> start() async {
    calls.add('start');
    _running = startSucceeds;
    _detecting = startSucceeds;
    return startSucceeds;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _running = false;
    _detecting = false;
    if (_torchState == TorchState.on) {
      _torchState = TorchState.off;
    }
  }

  @override
  bool get isRunning => _running;

  @override
  Future<void> pause() async {
    calls.add('pause');
    _detecting = false;
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
    _detecting = _running;
  }

  @override
  bool get isDetecting => _detecting;

  @override
  Future<void> setScanWindow(Rect? window) async {
    calls.add('setScanWindow: $window');
    _scanWindow = window;
  }

  @override
  TorchState get torchState => _torchState;

  @override
  Future<void> setTorch({required bool on}) async {
    calls.add('setTorch: $on');
    if (_torchState == TorchState.unavailable) {
      return;
    }
    _torchState = on ? TorchState.on : TorchState.off;
  }

  @override
  double get zoom => _zoom;

  @override
  Future<void> setZoom(double zoom) async {
    calls.add('setZoom: $zoom');
    _zoom = zoom.clamp(1.0, maxZoom);
  }

  @override
  Future<void> setAutoZoom({required bool enabled}) async {
    calls.add('setAutoZoom: $enabled');
    _autoZoom = enabled;
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    _running = false;
    _detecting = false;
    await _detections.close();
  }
}
