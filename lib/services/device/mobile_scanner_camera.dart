import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/permission_service.dart';

/// The formats SCAN-9 promises, as the plugin names them: the bundled ML Kit
/// set and nothing else.
///
/// ML Kit is asked for these only, so it spends no frame on Micro QR, MaxiCode
/// or DataBar, which SCAN-9 doesn't promise on Android; [symbologyForFormat]
/// drops them anyway if one ever comes back.
const List<ms.BarcodeFormat> scan9Formats = <ms.BarcodeFormat>[
  ms.BarcodeFormat.qrCode,
  ms.BarcodeFormat.dataMatrix,
  ms.BarcodeFormat.pdf417,
  ms.BarcodeFormat.aztec,
  ms.BarcodeFormat.code128,
  ms.BarcodeFormat.code39,
  ms.BarcodeFormat.code93,
  ms.BarcodeFormat.codabar,
  ms.BarcodeFormat.itf14,
  ms.BarcodeFormat.ean13,
  ms.BarcodeFormat.ean8,
  ms.BarcodeFormat.upcA,
  ms.BarcodeFormat.upcE,
];

/// The app's fixed symbology for a plugin [format], or `null` for a format
/// outside SCAN-9, which never becomes a detection (SCAN-9, DATA-1).
///
/// ML Kit reports ITF as the plugin's `itf14` (raw value 128), which is the
/// app's `itf`.
Symbology? symbologyForFormat(ms.BarcodeFormat format) => switch (format) {
  ms.BarcodeFormat.qrCode => Symbology.qr,
  ms.BarcodeFormat.dataMatrix => Symbology.dataMatrix,
  ms.BarcodeFormat.pdf417 => Symbology.pdf417,
  ms.BarcodeFormat.aztec => Symbology.aztec,
  ms.BarcodeFormat.code128 => Symbology.code128,
  ms.BarcodeFormat.code39 => Symbology.code39,
  ms.BarcodeFormat.code93 => Symbology.code93,
  ms.BarcodeFormat.codabar => Symbology.codabar,
  ms.BarcodeFormat.itf14 => Symbology.itf,
  ms.BarcodeFormat.ean13 => Symbology.ean13,
  ms.BarcodeFormat.ean8 => Symbology.ean8,
  ms.BarcodeFormat.upcA => Symbology.upcA,
  ms.BarcodeFormat.upcE => Symbology.upcE,
  _ => null,
};

/// The control characters that still read as text: tab and line breaks, plus
/// the separators structured codes carry (EOT, and FS, GS, RS and US in GS1
/// element strings and ISO/IEC 15434 data, RES-12).
const Set<int> _textControlCharacters = <int>{
  0x04,
  0x09,
  0x0A,
  0x0D,
  0x1C,
  0x1D,
  0x1E,
  0x1F,
};

/// Whether [text] reads as text, rather than bytes forced into characters.
///
/// A decoder that meets bytes it can't read as text either swaps them for
/// U+FFFD or maps them one for one onto control characters, and neither is
/// anything a person could read, so such a payload is binary (RES-13).
bool readsAsText(String text) {
  for (final int unit in text.codeUnits) {
    if (unit == 0xFFFD) {
      return false;
    }
    if (unit < 0x20 && !_textControlCharacters.contains(unit)) {
      return false;
    }
    if (unit >= 0x7F && unit <= 0x9F) {
      return false;
    }
  }
  return true;
}

/// The bytes the plugin decoded for [barcode], if it reported any.
Uint8List? _rawBytesOf(ms.Barcode barcode) => switch (barcode.rawDecodedBytes) {
  ms.DecodedBarcodeBytes(:final Uint8List bytes) => bytes,
  ms.DecodedVisionBarcodeBytes(
    :final Uint8List? bytes,
    :final Uint8List rawBytes,
  ) =>
    bytes ?? rawBytes,
  null => null,
};

/// [bytes] as UTF-8, or `null` when they aren't valid UTF-8.
String? _strictUtf8(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return null;
  }
}

/// One plugin [barcode] as the app's [CodeDetection], or `null` when it is in
/// a format outside SCAN-9 or carries nothing at all.
///
/// The symbology is the app's fixed id (DATA-1). Text travels as text, with no
/// second copy of it as bytes; content that doesn't read as text keeps its raw
/// bytes, with the payload as a best-effort decode and `isValidUtf8` false, so
/// the result screen shows "Binary data, N bytes" (DATA-2, RES-13).
///
/// ML Kit decodes a code in another character set (a Latin-1 QR code, say) to
/// the right text itself, so its text is trusted whenever it reads as text;
/// only when it doesn't are the bytes tried as UTF-8.
CodeDetection? detectionFromBarcode(ms.Barcode barcode) {
  final Symbology? symbology = symbologyForFormat(barcode.format);
  if (symbology == null) {
    return null;
  }
  final String text = barcode.rawValue ?? '';
  final Uint8List? bytes = _rawBytesOf(barcode);

  if (bytes == null || bytes.isEmpty) {
    // Nothing to fall back on: the decoder's text is all there is.
    return text.isEmpty
        ? null
        : CodeDetection(payload: text, symbology: symbology.id);
  }
  if (text.isNotEmpty && readsAsText(text)) {
    return CodeDetection(payload: text, symbology: symbology.id);
  }
  final String? utf8Text = _strictUtf8(bytes);
  if (utf8Text != null && readsAsText(utf8Text)) {
    return CodeDetection(payload: utf8Text, symbology: symbology.id);
  }
  return CodeDetection(
    payload: text.isNotEmpty ? text : utf8.decode(bytes, allowMalformed: true),
    symbology: symbology.id,
    rawBytes: Uint8List.fromList(bytes),
    isValidUtf8: false,
  );
}

/// Every code one detection pass found, in the order the plugin reported them,
/// each once (SCAN-13).
///
/// Codes in a format outside SCAN-9 are dropped, so a pass that found only
/// those comes back empty and is no detection at all (SCAN-9).
List<CodeDetection> detectionsFromCapture(ms.BarcodeCapture capture) {
  final Set<CodeDetection> pass = <CodeDetection>{};
  for (final ms.Barcode barcode in capture.barcodes) {
    final CodeDetection? detection = detectionFromBarcode(barcode);
    if (detection != null) {
      pass.add(detection);
    }
  }
  return List<CodeDetection>.unmodifiable(pass);
}

/// The scan window as fractions of the camera image, for a preview drawn
/// with [BoxFit.cover] into [previewSize] (SCAN-4).
///
/// [window] is in the preview's own coordinates, as the scanner screen draws
/// its target. The image is scaled to cover the preview and centred, so part
/// of it is cropped off two edges; this undoes that scaling and cropping.
/// Returns null when the sizes can't be compared (an empty size, or a
/// portrait preview over a landscape image), so the caller filters nothing
/// rather than everything.
Rect? windowInImageFraction({
  required Rect window,
  required Size previewSize,
  required Size imageSize,
}) {
  if (previewSize.isEmpty || imageSize.isEmpty) {
    return null;
  }
  final bool previewPortrait = previewSize.height >= previewSize.width;
  final bool imagePortrait = imageSize.height >= imageSize.width;
  if (previewPortrait != imagePortrait) {
    return null;
  }
  final double scale = math.max(
    previewSize.width / imageSize.width,
    previewSize.height / imageSize.height,
  );
  final Size drawn = imageSize * scale;
  final Offset origin = Offset(
    (previewSize.width - drawn.width) / 2,
    (previewSize.height - drawn.height) / 2,
  );
  return Rect.fromLTRB(
    (window.left - origin.dx) / drawn.width,
    (window.top - origin.dy) / drawn.height,
    (window.right - origin.dx) / drawn.width,
    (window.bottom - origin.dy) / drawn.height,
  );
}

/// Whether a code whose [corners] are in the camera image's pixels lies
/// wholly inside [windowFraction] of an image of [imageSize] (SCAN-4).
///
/// A code with no corners is kept: without them there is nothing to judge.
bool codeInsideWindow({
  required List<Offset> corners,
  required Size imageSize,
  required Rect windowFraction,
}) {
  if (corners.isEmpty || imageSize.isEmpty) {
    return true;
  }
  for (final Offset corner in corners) {
    final Offset fraction = Offset(
      corner.dx / imageSize.width,
      corner.dy / imageSize.height,
    );
    if (fraction.dx < windowFraction.left ||
        fraction.dx > windowFraction.right ||
        fraction.dy < windowFraction.top ||
        fraction.dy > windowFraction.bottom) {
      return false;
    }
  }
  return true;
}

/// The largest zoom the app assumes the back camera has (SCAN-7).
///
/// The plugin never reports the camera's zoom range, only a 0 ... 1 scale
/// between its narrowest and widest, so the app's 1x ... max range has to
/// assume a top. Phones' back cameras mostly top out between 8x and 10x of
/// digital zoom, and because the scale runs over the crop width (see
/// [zoomScaleForZoom]) a wrong guess moves low zooms very little: 2x lands at
/// about 2.06x on a 10x camera and 1.75x on a 4x one.
const double assumedMaxZoom = 8;

/// The plugin's zoom scale for the app's [zoom] (SCAN-7).
///
/// The scale is CameraX's linear zoom, which is linear in the crop width
/// (1 / zoom), not in the zoom itself: 0 is 1x, 1 is [maxZoom], and 2x on an
/// 8x camera is 4/7, not 1/7. [zoom] is clamped to 1 ... [maxZoom] first.
double zoomScaleForZoom(double zoom, {required double maxZoom}) {
  if (maxZoom <= 1 || zoom <= 1) {
    return 0;
  }
  final double ratio = zoom.clamp(1.0, maxZoom);
  final double scale = (1 / ratio - 1) / (1 / maxZoom - 1);
  return scale.clamp(0.0, 1.0);
}

/// The app's zoom for the plugin's zoom [scale], the inverse of
/// [zoomScaleForZoom] (SCAN-7).
double zoomForZoomScale(double scale, {required double maxZoom}) {
  if (maxZoom <= 1) {
    return 1;
  }
  final double linear = scale.clamp(0.0, 1.0);
  final double cropWidth = 1 + (1 / maxZoom - 1) * linear;
  return (1 / cropWidth).clamp(1.0, maxZoom);
}

/// The app's torch state for the plugin's (SCAN-6).
///
/// The plugin reports `unavailable` when the camera has no flash, which is
/// what hides the torch button. `auto` exists only on Apple platforms and
/// means the torch isn't forced on.
TorchState torchStateFromPlugin(ms.TorchState state) => switch (state) {
  ms.TorchState.unavailable => TorchState.unavailable,
  ms.TorchState.on => TorchState.on,
  ms.TorchState.off || ms.TorchState.auto => TorchState.off,
};

/// How long a torch change may take to be reported back before [setTorch]
/// returns anyway.
const Duration _torchSettleTimeout = Duration(milliseconds: 600);

/// The real [CameraScanner]: the back camera through `mobile_scanner` and its
/// bundled ML Kit (SCAN-9, spike S1).
///
/// - It never starts the camera without the permission: the plugin would show
///   the system prompt itself on start, and only RUN-1's button may ask
///   (RUN-3). [start] reports false instead, and the caller keeps RUN-1's
///   placeholder (RUN-1, RUN-4).
/// - Pausing stops delivering detections and keeps the camera running, so
///   coming back from a result scans again at once (SCAN-3).
/// - Each start runs on a fresh plugin controller, and so does an auto-zoom
///   change while the camera runs, because the plugin takes auto-zoom only when
///   a session starts. That restart keeps the zoom, the torch and whether
///   detections flow; it happens at most once per scanner visit, at the first
///   manual zoom (SCAN-7).
/// - Stopping the camera when the app goes to the background is the caller's
///   job: the plugin follows the app lifecycle only for controllers it builds
///   itself, and CameraX closes the camera with the activity either way.
///
/// Every operation runs in call order, one at a time, so a zoom asked for
/// during a restart lands on the new session.
class MobileScannerCamera implements CameraScanner {
  MobileScannerCamera({
    required PermissionService permissions,
    this.maxZoom = assumedMaxZoom,
  }) : assert(maxZoom >= 1, 'The widest zoom is 1x.'),
       _permissions = permissions {
    _current = ValueNotifier<ms.MobileScannerController>(
      _listenTo(_newController()),
    );
  }

  final PermissionService _permissions;

  /// The top of the zoom range; the plugin doesn't report the camera's own
  /// (see [assumedMaxZoom]).
  @override
  final double maxZoom;

  final StreamController<List<CodeDetection>> _detections =
      StreamController<List<CodeDetection>>.broadcast();

  /// The scan window, in the preview's own coordinates (SCAN-4).
  final ValueNotifier<Rect?> _scanWindow = ValueNotifier<Rect?>(null);

  /// The preview's size at its last layout, which [_scanWindow] is relative to.
  Size? _previewSize;

  /// The plugin controller of the current camera session. The preview listens
  /// to it and rebuilds on a fresh one.
  late final ValueNotifier<ms.MobileScannerController> _current;

  /// What the preview rebuilds on. Not disposed with the camera: a preview
  /// still on screen may unsubscribe after [dispose].
  late final Listenable _previewInputs = Listenable.merge(<Listenable>[
    _current,
    _scanWindow,
  ]);

  StreamSubscription<ms.BarcodeCapture>? _captures;
  Future<void> _queue = Future<void>.value();
  bool _running = false;
  bool _detecting = false;
  bool _autoZoom = true;
  bool _currentStarted = false;
  bool _disposed = false;
  double _zoom = 1;
  double? _reportedScale;

  ms.MobileScannerController get _controller => _current.value;

  @override
  Stream<List<CodeDetection>> get detections => _detections.stream;

  @override
  Widget buildPreview({BoxFit fit = BoxFit.cover}) => ListenableBuilder(
    listenable: _previewInputs,
    builder: (BuildContext context, Widget? child) {
      final ms.MobileScannerController controller = _controller;
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // The target is checked in [_onCapture] against this size (SCAN-4).
          _previewSize = constraints.biggest;
          return ms.MobileScanner(
            // A fresh controller is a fresh camera session, so it gets a fresh
            // widget: the plugin's widget binds its controller once.
            key: ObjectKey(controller),
            controller: controller,
            fit: fit,
            // No plugin scan window: SCAN-4 is applied to each capture in
            // [_onCapture] by [codeInsideWindow], a pure function with unit
            // tests, rather than in the plugin's native code, which no test
            // reaches.
            // Until the camera runs, and if it fails, the preview shows nothing,
            // and never the plugin's own English error text (LANG-2): the scanner
            // screen draws RUN-1's placeholder or RUN-4's state over it.
            placeholderBuilder: _showNothing,
            errorBuilder: _showNothingForError,
          );
        },
      );
    },
  );

  @override
  Future<bool> start() => _serially<bool>(() async {
    if (_disposed) {
      return false;
    }
    if (_running) {
      return true;
    }
    // RUN-3: the plugin's own start would show the system prompt.
    if (await _permissions.cameraStatus() != CameraPermissionState.granted) {
      return false;
    }
    if (_currentStarted || _controller.autoZoom != _autoZoom) {
      await _replaceController(torchOn: false);
    }
    _running = await _startCurrent();
    _detecting = _running;
    return _running;
  });

  @override
  Future<void> stop() => _serially<void>(() async {
    _running = false;
    _detecting = false;
    // Releasing the camera turns the torch off with it (SCAN-6).
    try {
      await _controller.stop();
    } on Exception {
      // Already stopped: there is nothing left to release.
    }
  });

  @override
  bool get isRunning => _running;

  @override
  Future<void> pause() => _serially<void>(() async {
    _detecting = false;
  });

  @override
  Future<void> resume() => _serially<void>(() async {
    _detecting = _running;
  });

  @override
  bool get isDetecting => _detecting;

  /// Limits detection to [window], given in the coordinates of the widget
  /// [buildPreview] returned (SCAN-4). The plugin maps it onto the camera
  /// image, taking the preview's fit into account.
  @override
  Future<void> setScanWindow(Rect? window) async {
    _scanWindow.value = window;
  }

  @override
  TorchState get torchState =>
      torchStateFromPlugin(_controller.value.torchState);

  @override
  Future<void> setTorch({required bool on}) => _serially<void>(() async {
    final ms.MobileScannerController controller = _controller;
    final TorchState wanted = on ? TorchState.on : TorchState.off;
    final TorchState now = torchStateFromPlugin(controller.value.torchState);
    if (!_running || now == TorchState.unavailable || now == wanted) {
      return;
    }
    try {
      await controller.toggleTorch();
    } on Exception {
      return;
    }
    await _untilTorch(controller, wanted);
  });

  @override
  double get zoom => _zoom;

  @override
  Future<void> setZoom(double zoom) => _serially<void>(() async {
    _zoom = zoom.clamp(1.0, maxZoom);
    if (_running) {
      await _applyZoom(_controller);
    }
  });

  @override
  Future<void> setAutoZoom({required bool enabled}) =>
      _serially<void>(() async {
        if (_disposed || _autoZoom == enabled) {
          return;
        }
        _autoZoom = enabled;
        if (!_running) {
          // The next start builds its controller with the new setting.
          return;
        }
        final bool torchOn = torchState == TorchState.on;
        final bool wasDetecting = _detecting;
        await _replaceController(torchOn: torchOn);
        _running = await _startCurrent();
        _detecting = _running && wasDetecting;
      });

  @override
  Future<void> dispose() => _serially<void>(() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _running = false;
    _detecting = false;
    await _captures?.cancel();
    _captures = null;
    _controller.removeListener(_onControllerChanged);
    await _release(_controller);
    await _detections.close();
  });

  /// Runs [operation] once every operation asked for before it has finished.
  Future<T> _serially<T>(Future<T> Function() operation) {
    final Future<T> result = _queue.then((_) => operation());
    _queue = result.then<void>((T _) {}, onError: (Object _) {});
    return result;
  }

  ms.MobileScannerController _newController({bool torchOn = false}) =>
      ms.MobileScannerController(
        // The camera starts only from [start], after the permission check.
        autoStart: false,
        formats: scan9Formats,
        autoZoom: _autoZoom,
        torchEnabled: torchOn,
        initialZoom: _zoom > 1
            ? zoomScaleForZoom(_zoom, maxZoom: maxZoom)
            : null,
        // No camera frame ever leaves the plugin (DATA-3).
        returnImage: false,
      );

  ms.MobileScannerController _listenTo(ms.MobileScannerController controller) {
    _captures = controller.barcodes.listen(
      _onCapture,
      onError: _ignoreFailedFrame,
    );
    _reportedScale = controller.value.zoomScale;
    controller.addListener(_onControllerChanged);
    return controller;
  }

  Future<void> _replaceController({required bool torchOn}) async {
    final ms.MobileScannerController old = _controller;
    await _captures?.cancel();
    _captures = null;
    old.removeListener(_onControllerChanged);
    // The plugin holds one camera session at a time, so the old one is
    // released before the new one starts.
    await _release(old);
    _currentStarted = false;
    _current.value = _listenTo(_newController(torchOn: torchOn));
  }

  Future<bool> _startCurrent() async {
    final ms.MobileScannerController controller = _controller;
    _currentStarted = true;
    try {
      // Waits for the preview to bind the controller, which it does on the
      // frame after a fresh controller is handed to it.
      await controller.start();
    } on Exception {
      return false;
    }
    // A camera that failed to open reports it in its state, not by throwing.
    if (!controller.value.isRunning) {
      return false;
    }
    if (_zoom > 1) {
      await _applyZoom(controller);
    }
    return true;
  }

  Future<void> _applyZoom(ms.MobileScannerController controller) async {
    if (!controller.value.isInitialized || !controller.value.isRunning) {
      return;
    }
    try {
      if (_zoom <= 1) {
        // Exactly 1x, even on a camera whose scale starts below it.
        await controller.resetZoomScale();
      } else {
        await controller.setZoomScale(
          zoomScaleForZoom(_zoom, maxZoom: maxZoom),
        );
      }
    } on Exception {
      // The camera stopped in between; the zoom applies at the next start.
    }
  }

  Future<void> _release(ms.MobileScannerController controller) async {
    try {
      await controller.stop();
    } on Exception {
      // Already stopped.
    }
    try {
      await controller.dispose();
    } on Exception {
      // Nothing left to release.
    }
  }

  void _onCapture(ms.BarcodeCapture capture) {
    if (!_detecting || _detections.isClosed) {
      return;
    }
    final ms.BarcodeCapture kept = _insideTarget(capture);
    final List<CodeDetection> pass = detectionsFromCapture(kept);
    if (pass.isNotEmpty) {
      _detections.add(pass);
    }
  }

  /// [capture] with only the codes wholly inside the target (SCAN-4). With no
  /// target, or sizes that can't be compared, every code stays.
  ms.BarcodeCapture _insideTarget(ms.BarcodeCapture capture) {
    final Rect? window = _scanWindow.value;
    final Size? previewSize = _previewSize;
    if (window == null || previewSize == null) {
      return capture;
    }
    final Rect? fraction = windowInImageFraction(
      window: window,
      previewSize: previewSize,
      imageSize: capture.size,
    );
    if (fraction == null) {
      return capture;
    }
    return ms.BarcodeCapture(
      barcodes: <ms.Barcode>[
        for (final ms.Barcode barcode in capture.barcodes)
          if (codeInsideWindow(
            corners: barcode.corners,
            imageSize: capture.size,
            windowFraction: fraction,
          ))
            barcode,
      ],
      raw: capture.raw,
      size: capture.size,
    );
  }

  /// Keeps [zoom] in step when auto-zoom moves the camera by itself (SCAN-7).
  ///
  /// Only a change in the reported scale counts: the plugin notifies for the
  /// torch and the running state too, and starts from a placeholder scale.
  void _onControllerChanged() {
    final ms.MobileScannerState state = _controller.value;
    if (state.zoomScale == _reportedScale) {
      return;
    }
    _reportedScale = state.zoomScale;
    if (_autoZoom && _running && state.isRunning) {
      _zoom = zoomForZoomScale(state.zoomScale, maxZoom: maxZoom);
    }
  }

  /// Waits, briefly, for the plugin to report the torch as [wanted], so
  /// [torchState] reads the new state once [setTorch] returns (SCAN-6).
  Future<void> _untilTorch(
    ms.MobileScannerController controller,
    TorchState wanted,
  ) async {
    if (torchStateFromPlugin(controller.value.torchState) == wanted) {
      return;
    }
    final Completer<void> settled = Completer<void>();
    void check() {
      if (!settled.isCompleted &&
          torchStateFromPlugin(controller.value.torchState) == wanted) {
        settled.complete();
      }
    }

    controller.addListener(check);
    try {
      await settled.future.timeout(_torchSettleTimeout, onTimeout: () {});
    } finally {
      controller.removeListener(check);
    }
  }
}

Widget _showNothing(BuildContext context) => const SizedBox.shrink();

Widget _showNothingForError(
  BuildContext context,
  ms.MobileScannerException error,
) => const SizedBox.shrink();

/// A frame ML Kit failed on is a frame with no code; the next one is tried.
void _ignoreFailedFrame(Object error) {}
