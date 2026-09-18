/// The camera permission as far as a caller can act on it (RUN-4 to RUN-6).
enum CameraPermissionState {
  /// The camera can be used, whether granted for good or "Only this time"
  /// (RUN-5, RUN-7).
  granted,

  /// Not usable, and the system will still show its prompt, so the screen keeps
  /// RUN-1's "Allow camera" button (RUN-1, RUN-4).
  denied,

  /// Not usable, and Android won't show its prompt any more (denied twice, or
  /// "Don't ask again"), so the button becomes "Open settings" (RUN-6).
  permanentlyDenied,
}

/// Runtime permissions. The camera is the only one the app asks for, and only
/// from RUN-1's button (RUN-2, RUN-3).
///
/// Spike S8 (`docs/research/technical-constraints.md`): on Android the system
/// status cannot tell "never asked" from "permanently denied" — both read as
/// denied — so [cameraStatus] never reports
/// [CameraPermissionState.permanentlyDenied]. RUN-6 is decided from what
/// [requestCamera] last returned (kept by the caller, which is why
/// [cameraRequestedBefore] exists), or from [shouldShowCameraRationale] as a
/// second signal.
abstract class PermissionService {
  /// The camera permission as the system reports it now.
  ///
  /// Reports granted or denied only, never permanently denied (spike S8).
  Future<CameraPermissionState> cameraStatus();

  /// Whether the camera was ever requested on this install.
  ///
  /// With [cameraStatus] denied: false means "never asked", so the prompt will
  /// still show (RUN-1); true with a denied status and no rationale means
  /// Android has stopped asking (RUN-6).
  Future<bool> cameraRequestedBefore();

  /// Shows the system prompt when Android will still show it.
  ///
  /// Returns [CameraPermissionState.permanentlyDenied] when it won't, which is
  /// the signal RUN-6 keys off. Records that the camera was requested, so
  /// [cameraRequestedBefore] answers true afterwards.
  Future<CameraPermissionState> requestCamera();

  /// Whether Android would show a rationale (the camera was denied once and the
  /// prompt will show again): spike S8's second signal.
  Future<bool> shouldShowCameraRationale();

  /// Opens the app's own permission page in system Settings, for RUN-6's "Open
  /// settings" button. Returns whether Settings opened.
  Future<bool> openAppSettings();
}

/// A [PermissionService] that asks the system nothing.
///
/// It starts at [initialState] (denied, never asked, like a fresh install) and
/// [requestCamera] reports [requestResult], so RUN-1, RUN-4, RUN-5 and RUN-6 can
/// each be driven. [calls] records what was asked, including whether Settings
/// was opened.
class NoopPermissionService implements PermissionService {
  NoopPermissionService({
    CameraPermissionState initialState = CameraPermissionState.denied,
    CameraPermissionState? requestResult,
    bool requestedBefore = false,
    this.showsRationale = false,
    this.settingsOpens = true,
  }) : _state = initialState,
       _requestResult = requestResult ?? initialState,
       _requestedBefore = requestedBefore;

  /// Every call made, in order, such as `'requestCamera'`.
  final List<String> calls = <String>[];

  /// What [shouldShowCameraRationale] reports.
  final bool showsRationale;

  /// What [openAppSettings] reports.
  final bool settingsOpens;

  CameraPermissionState _state;
  final CameraPermissionState _requestResult;
  bool _requestedBefore;

  @override
  Future<CameraPermissionState> cameraStatus() async {
    calls.add('cameraStatus');
    // Spike S8: the system status never says permanently denied.
    return _state == CameraPermissionState.granted
        ? CameraPermissionState.granted
        : CameraPermissionState.denied;
  }

  @override
  Future<bool> cameraRequestedBefore() async {
    calls.add('cameraRequestedBefore');
    return _requestedBefore;
  }

  @override
  Future<CameraPermissionState> requestCamera() async {
    calls.add('requestCamera');
    _requestedBefore = true;
    _state = _requestResult;
    return _requestResult;
  }

  @override
  Future<bool> shouldShowCameraRationale() async {
    calls.add('shouldShowCameraRationale');
    return showsRationale;
  }

  @override
  Future<bool> openAppSettings() async {
    calls.add('openAppSettings');
    return settingsOpens;
  }
}
