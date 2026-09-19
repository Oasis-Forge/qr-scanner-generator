import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/services/permission_service.dart';

/// The camera permission as the system reports it, turned into what the
/// scanner can act on (RUN-1, RUN-4 to RUN-6, spike S8).
///
/// Spike S8 on API 37: the status alone reads denied both before the first ask
/// and once Android has stopped asking, so a denied [status] is split by
/// [requestedBefore] (the stored flag, set once the user has denied the camera
/// at a prompt, see [deniedAtPrompt]) and [showsRationale]:
///
/// | S8 situation                    | status  | flag  | rationale | state              |
/// |---------------------------------|---------|-------|-----------|--------------------|
/// | Never asked                     | denied  | false | false     | denied             |
/// | Denied once                     | denied  | true  | true      | denied             |
/// | Denied twice                    | denied  | true  | false     | permanentlyDenied  |
/// | Revoked after a denial          | denied  | true  | false     | permanentlyDenied  |
/// | Granted, or "Only this time"    | granted | any   | false     | granted            |
///
/// "Only this time" expiring reads like never asked, because the flag is
/// cleared whenever the camera is seen granted, so the next launch shows
/// RUN-1's "Allow camera" again and the system prompt with it (RUN-5). A
/// revoke after a denial reads as permanently denied and leads to "Open
/// settings" (RUN-6), which reaches the permission whichever it really is.
///
/// A status the plugin itself resolves (permanently denied, or restricted,
/// which no prompt can change) is taken as it is.
CameraPermissionState cameraPermissionStateFrom({
  required ph.PermissionStatus status,
  required bool requestedBefore,
  required bool showsRationale,
}) => switch (status) {
  ph.PermissionStatus.granted ||
  ph.PermissionStatus.limited ||
  ph.PermissionStatus.provisional => CameraPermissionState.granted,
  ph.PermissionStatus.permanentlyDenied ||
  ph.PermissionStatus.restricted => CameraPermissionState.permanentlyDenied,
  ph.PermissionStatus.denied =>
    requestedBefore && !showsRationale
        ? CameraPermissionState.permanentlyDenied
        : CameraPermissionState.denied,
};

/// What a prompt's answer means for the scanner (RUN-4 to RUN-6).
///
/// The plugin resolves a request itself (S8: "Denied twice" answers permanently
/// denied without showing a dialog), so its answer is taken as it is.
CameraPermissionState cameraPermissionStateFromRequest(
  ph.PermissionStatus result,
) => cameraPermissionStateFrom(
  status: result,
  requestedBefore: false,
  showsRationale: false,
);

/// Whether a prompt's [result] was the user denying the camera, which is what
/// the stored flag remembers (spike S8).
///
/// A denial leaves Android showing a rationale ("Denied once"), or answers
/// permanently denied ("Denied twice"). A first prompt dismissed without a
/// choice answers denied with no rationale and is no denial: Android will
/// prompt again, so the flag stays unset and RUN-1's button stays "Allow
/// camera" rather than turning into "Open settings".
bool deniedAtPrompt(
  ph.PermissionStatus result, {
  required bool showsRationale,
}) => switch (result) {
  ph.PermissionStatus.denied => showsRationale,
  ph.PermissionStatus.permanentlyDenied => true,
  _ => false,
};

/// The real [PermissionService], over `permission_handler` (spike S8).
///
/// The camera is the only permission the app asks for, and only from RUN-1's
/// button (RUN-2, RUN-3). What the system status can't tell apart (S8) is
/// settled with a flag kept in [KeyValueStore] under [cameraRequestedKey]: it
/// is set when [requestCamera]'s prompt ends in a denial and cleared whenever
/// the camera is seen granted, so [cameraStatus] reports all three states (see
/// [cameraPermissionStateFrom]) and [cameraRequestedBefore] answers true only
/// while a denial stands.
///
/// A platform error reads as "not usable" (denied, no rationale, Settings not
/// opened), so the scanner falls back to RUN-1's placeholder instead of
/// failing. A failed store write is not swallowed: the flag is written before
/// the answer is reported.
class DevicePermissionService implements PermissionService {
  DevicePermissionService({required KeyValueStore store}) : _store = store;

  /// The stored flag: `true` while a denial at the camera prompt stands.
  static const String cameraRequestedKey = 'permissions.camera_requested';

  final KeyValueStore _store;

  @override
  Future<CameraPermissionState> cameraStatus() async {
    final ph.PermissionStatus status = await _systemStatus();
    final bool requestedBefore = await cameraRequestedBefore();
    // The rationale only matters while a denial stands (S8).
    final bool showsRationale =
        status == ph.PermissionStatus.denied && requestedBefore
        ? await shouldShowCameraRationale()
        : false;
    final CameraPermissionState state = cameraPermissionStateFrom(
      status: status,
      requestedBefore: requestedBefore,
      showsRationale: showsRationale,
    );
    if (state == CameraPermissionState.granted) {
      await _forgetDenial(requestedBefore: requestedBefore);
    }
    return state;
  }

  @override
  Future<bool> cameraRequestedBefore() async =>
      await _store.getBool(cameraRequestedKey) ?? false;

  @override
  Future<CameraPermissionState> requestCamera() async {
    final ph.PermissionStatus result = await _request();
    final CameraPermissionState state = cameraPermissionStateFromRequest(
      result,
    );
    if (state == CameraPermissionState.granted) {
      await _forgetDenial(requestedBefore: await cameraRequestedBefore());
      return state;
    }
    final bool showsRationale = result == ph.PermissionStatus.denied
        ? await shouldShowCameraRationale()
        : false;
    if (deniedAtPrompt(result, showsRationale: showsRationale)) {
      await _store.setBool(cameraRequestedKey, value: true);
    }
    return state;
  }

  @override
  Future<bool> shouldShowCameraRationale() async {
    try {
      return await ph.Permission.camera.shouldShowRequestRationale;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } on PlatformException {
      return false;
    }
  }

  Future<ph.PermissionStatus> _systemStatus() async {
    try {
      return await ph.Permission.camera.status;
    } on PlatformException {
      return ph.PermissionStatus.denied;
    }
  }

  Future<ph.PermissionStatus> _request() async {
    try {
      return await ph.Permission.camera.request();
    } on PlatformException {
      return ph.PermissionStatus.denied;
    }
  }

  /// Clears the flag once the camera is granted, so a grant that later lapses
  /// ("Only this time") or is revoked reads as never asked (RUN-5).
  Future<void> _forgetDenial({required bool requestedBefore}) async {
    if (requestedBefore) {
      await _store.remove(cameraRequestedKey);
    }
  }
}
