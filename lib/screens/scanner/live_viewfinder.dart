import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/scanner_state.dart';
import 'scanner_keys.dart';
import 'scanner_layout.dart';

/// The live scanner (RUN-7, SCAN-1): the full-screen preview, the square
/// target, the torch, zoom and the "Scan a photo" / "Type a code" shortcuts.
///
/// Presentational (`CLAUDE.md`): it draws what [ScannerState] reports and
/// calls its methods. No ad sits anywhere on it (ADS-1).
///
/// * SCAN-4: detection is automatic and limited to a square target about 70%
///   of the viewfinder's shorter side. The rect drawn is the rect handed to
///   [ScannerState.setScanWindow], so what the user aims at is exactly where
///   codes are read.
/// * SCAN-6: the torch button shows only while the camera reports a flash.
/// * SCAN-7: a zoom slider, pinch, and double-tap between 1x and 2x.
///
/// Text over the camera sits on a dark panel so it keeps its contrast however
/// bright the scene is (A11Y-5).
class LiveViewfinder extends StatefulWidget {
  const LiveViewfinder({
    required this.onScanPhoto,
    required this.onTypeCode,
    super.key,
  });

  final VoidCallback onScanPhoto;
  final VoidCallback onTypeCode;

  @override
  State<LiveViewfinder> createState() => _LiveViewfinderState();
}

class _LiveViewfinderState extends State<LiveViewfinder> {
  /// Colour of the panel behind text and controls over the camera: black at
  /// 60%, so white text on it stays above 4.5:1 even over a white scene
  /// (A11Y-5).
  static const Color _panelColor = Color(0x99000000);

  /// The scan window last handed to the state, so it is sent once per change
  /// of layout, not on every frame (SCAN-4).
  Rect? _sentWindow;

  /// Whether the camera was running when the window was sent: a camera that
  /// starts again gets the window again.
  bool _sentWhileRunning = false;

  /// The pinch in progress (SCAN-7): the gesture's scale when it became a
  /// two-finger pinch, so the zoom scales from where the pinch began.
  double? _pinchBaseScale;

  @override
  Widget build(BuildContext context) {
    final ScannerState scanner = context.watch<ScannerState>();
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = constraints.biggest;
          final Rect target = ScannerLayout.targetFor(size);
          _sendScanWindow(scanner, target);
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              scanner.buildPreview(),
              GestureDetector(
                key: ScannerKeys.viewfinder,
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () => unawaited(scanner.toggleZoom()),
                onScaleStart: (ScaleStartDetails details) =>
                    _onScaleStart(scanner, details),
                onScaleUpdate: (ScaleUpdateDetails details) =>
                    _onScaleUpdate(scanner, details),
                onScaleEnd: (ScaleEndDetails details) {
                  _pinchBaseScale = null;
                },
                child: CustomPaint(
                  painter: _TargetPainter(
                    target: target,
                    signal: AppColors.read(context).signal,
                  ),
                ),
              ),
              _Controls(
                scanner: scanner,
                panelColor: _panelColor,
                onScanPhoto: widget.onScanPhoto,
                onTypeCode: widget.onTypeCode,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Hands [target] to the state after this frame, once per change (SCAN-4).
  ///
  /// It runs after the frame because a layout pass is no place to call into
  /// the camera, and it runs again when the camera starts, so a camera that
  /// stopped and started (leaving the scanner, the app going to the
  /// background) is limited to the target again.
  void _sendScanWindow(ScannerState scanner, Rect target) {
    final bool running = scanner.isCameraRunning;
    if (!running) {
      // The next start gets the window again.
      _sentWhileRunning = false;
    }
    if (target == _sentWindow && (_sentWhileRunning || !running)) {
      return;
    }
    _sentWindow = target;
    _sentWhileRunning = running;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        unawaited(scanner.setScanWindow(target));
      }
    });
  }

  void _onScaleStart(ScannerState scanner, ScaleStartDetails details) {
    if (details.pointerCount > 1) {
      _pinchBaseScale = 1;
      scanner.beginPinch();
    }
  }

  /// A pinch is a manual zoom (SCAN-7). One finger dragging is not a pinch
  /// and changes nothing.
  void _onScaleUpdate(ScannerState scanner, ScaleUpdateDetails details) {
    if (details.pointerCount < 2) {
      return;
    }
    final double? base = _pinchBaseScale;
    if (base == null) {
      // The second finger landed after the gesture began.
      _pinchBaseScale = details.scale;
      scanner.beginPinch();
      return;
    }
    unawaited(scanner.updatePinch(details.scale / base));
  }
}

/// Everything drawn over the preview: the torch at the top, then the hint,
/// the zoom slider and the shortcuts at the bottom.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.scanner,
    required this.panelColor,
    required this.onScanPhoto,
    required this.onTypeCode,
  });

  final ScannerState scanner;
  final Color panelColor;
  final VoidCallback onScanPhoto;
  final VoidCallback onTypeCode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool busy = scanner.isBusy;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 0),
            child: Row(
              children: <Widget>[
                _ReadyMark(label: l10n.scanReadyStatus),
                const Spacer(),
                if (scanner.showsTorchButton)
                  _TorchButton(
                    isOn: scanner.isTorchOn,
                    onPressed: () => unawaited(scanner.toggleTorch()),
                  )
                else
                  const SizedBox.square(dimension: AppTheme.minTapTargetSize),
              ],
            ),
          ),
          // The target shows through here; the gesture layer below takes the
          // pinch and the double-tap.
          const Expanded(child: IgnorePointer(child: SizedBox.expand())),
          DecoratedBox(
            decoration: BoxDecoration(
              color: panelColor,
              border: Border(
                top: BorderSide(color: AppColors.read(context).hairline),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.scanTargetHint,
                    textAlign: TextAlign.center,
                    style: AppTheme.mono(size: 11, color: Colors.white70),
                  ),
                  if (scanner.maxZoom > ScannerState.minZoom)
                    _ZoomSlider(scanner: scanner),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      OutlinedButton.icon(
                        key: ScannerKeys.scanPhoto,
                        onPressed: busy ? null : onScanPhoto,
                        style: _shortcutStyle,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l10n.scanFromPhotoButton),
                      ),
                      OutlinedButton.icon(
                        key: ScannerKeys.typeCode,
                        onPressed: busy ? null : onTypeCode,
                        style: _shortcutStyle,
                        icon: const Icon(Icons.keyboard_outlined),
                        label: Text(l10n.typeCodeButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // On the dimmed scene, not on the app's own ground, so the outline and the
  // label stay white whichever theme is on.
  static final ButtonStyle _shortcutStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Color(0x59FFFFFF)),
    minimumSize: const Size(
      AppTheme.minTapTargetSize,
      AppTheme.minTapTargetSize,
    ),
  );
}

/// The status word beside the torch: the instrument saying it is looking.
class _ReadyMark extends StatelessWidget {
  const _ReadyMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color signal = AppColors.read(context).signal;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 8, height: 8, color: signal),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.mono(size: 11, color: signal)),
        ],
      ),
    );
  }
}

/// The torch button (SCAN-6).
///
/// Its name says what a tap does, it is announced as selected while the torch
/// is on, and the icon changes between a struck-out and a lit flashlight, so on
/// and off are never told apart by colour alone (A11Y-1, A11Y-6).
class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.isOn, required this.onPressed});

  final bool isOn;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return IconButton(
      key: ScannerKeys.torch,
      tooltip: isOn ? l10n.scanTorchOff : l10n.scanTorchOn,
      isSelected: isOn,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0x59FFFFFF)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius)),
        ),
        minimumSize: const Size(
          AppTheme.minTapTargetSize,
          AppTheme.minTapTargetSize,
        ),
      ),
      icon: const Icon(Icons.flashlight_off),
      selectedIcon: const Icon(Icons.flashlight_on),
    );
  }
}

/// The zoom slider (SCAN-7), from 1x to the camera's largest zoom.
///
/// Its screen-reader name is "Zoom" and its value the zoom in the app's
/// number format. A slider mirrors in Arabic by itself (LANG-5); the value
/// beside it stays left to right, as numbers do.
class _ZoomSlider extends StatelessWidget {
  const _ZoomSlider({required this.scanner});

  final ScannerState scanner;

  /// The zoom to one decimal, which is all the label needs.
  static double _rounded(double zoom) => (zoom * 10).roundToDouble() / 10;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double max = scanner.maxZoom;
    final double zoom = scanner.zoom.clamp(ScannerState.minZoom, max);
    return Row(
      children: <Widget>[
        const Icon(Icons.zoom_out, color: Colors.white),
        Expanded(
          child: MergeSemantics(
            child: Semantics(
              label: l10n.scanZoomLabel,
              child: SizedBox(
                height: AppTheme.minTapTargetSize,
                child: Slider(
                  key: ScannerKeys.zoomSlider,
                  min: ScannerState.minZoom,
                  max: max,
                  value: zoom,
                  onChanged: (double value) =>
                      unawaited(scanner.setZoom(value)),
                  semanticFormatterCallback: (double value) =>
                      l10n.scanZoomValue(_rounded(value)),
                ),
              ),
            ),
          ),
        ),
        const Icon(Icons.zoom_in, color: Colors.white),
        const SizedBox(width: 8),
        ExcludeSemantics(
          child: Text(
            l10n.scanZoomValue(_rounded(zoom)),
            textDirection: TextDirection.ltr,
            style: AppTheme.mono(size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// SCAN-4's target: the scene outside the square is dimmed, and the square
/// itself is marked the way an instrument marks what it is aimed at — corner
/// ticks and a centre crosshair in the signal colour, so where codes are read
/// is visible without reading any text.
class _TargetPainter extends CustomPainter {
  const _TargetPainter({required this.target, required this.signal});

  final Rect target;

  /// The app's signal colour, handed in so the painter draws the theme's own
  /// mark rather than one of its own.
  final Color signal;

  static const double _cornerLength = 34;
  static const double _strokeWidth = 3;
  static const double _crosshair = 11;

  @override
  void paint(Canvas canvas, Size size) {
    final Path outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(target);
    canvas.drawPath(outside, Paint()..color = const Color(0x8C0E0D0B));

    final Paint mark = Paint()
      ..color = signal
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final double l = target.left;
    final double t = target.top;
    final double r = target.right;
    final double b = target.bottom;
    const double c = _cornerLength;
    canvas
      ..drawLine(Offset(l, t + c), Offset(l, t), mark)
      ..drawLine(Offset(l, t), Offset(l + c, t), mark)
      ..drawLine(Offset(r - c, t), Offset(r, t), mark)
      ..drawLine(Offset(r, t), Offset(r, t + c), mark)
      ..drawLine(Offset(l, b - c), Offset(l, b), mark)
      ..drawLine(Offset(l, b), Offset(l + c, b), mark)
      ..drawLine(Offset(r - c, b), Offset(r, b), mark)
      ..drawLine(Offset(r, b), Offset(r, b - c), mark);

    // The centre: a thin rule across the target and a crosshair on it, which
    // is what the eye lines a code up against.
    final Offset centre = target.center;
    canvas
      ..drawLine(
        Offset(l, centre.dy),
        Offset(r, centre.dy),
        Paint()
          ..color = signal.withValues(alpha: 0.28)
          ..strokeWidth = 1,
      )
      ..drawLine(
        Offset(centre.dx - _crosshair, centre.dy),
        Offset(centre.dx + _crosshair, centre.dy),
        Paint()
          ..color = signal
          ..strokeWidth = 1.5,
      )
      ..drawLine(
        Offset(centre.dx, centre.dy - _crosshair),
        Offset(centre.dx, centre.dy + _crosshair),
        Paint()
          ..color = signal
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_TargetPainter oldDelegate) =>
      oldDelegate.target != target || oldDelegate.signal != signal;
}
