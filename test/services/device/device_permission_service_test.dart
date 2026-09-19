import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscanner/services/device/device_permission_service.dart';
import 'package:qrscanner/services/permission_service.dart';

import '../../helpers/fake_stores.dart';

/// The permission plugin's method channel, answered by [_SystemCamera]
/// instead of Android.
const MethodChannel _permissionsChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// How the plugin encodes each status on its channel.
const Map<PermissionStatus, int> _wireStatus = <PermissionStatus, int>{
  PermissionStatus.denied: 0,
  PermissionStatus.granted: 1,
  PermissionStatus.restricted: 2,
  PermissionStatus.limited: 3,
  PermissionStatus.permanentlyDenied: 4,
  PermissionStatus.provisional: 5,
};

/// Android's side of the camera permission, as spike S8 measured it on API 37:
/// the status never says permanently denied, and a request Android won't show
/// any more answers permanently denied.
class _SystemCamera {
  /// What a status check reports.
  PermissionStatus status = PermissionStatus.denied;

  /// What the next prompt answers.
  PermissionStatus answer = PermissionStatus.denied;

  /// What `shouldShowRequestPermissionRationale` reports.
  bool rationale = false;

  /// Every method the app called, in order.
  final List<String> calls = <String>[];

  Future<Object?> handle(MethodCall call) async {
    calls.add(call.method);
    switch (call.method) {
      case 'checkPermissionStatus':
        return _wireStatus[status];
      case 'requestPermissions':
        status = answer == PermissionStatus.granted
            ? PermissionStatus.granted
            : PermissionStatus.denied;
        return <int, int>{Permission.camera.value: _wireStatus[answer]!};
      case 'shouldShowRequestPermissionRationale':
        return rationale;
      case 'openAppSettings':
        return true;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cameraPermissionStateFrom, every row of spike S8', () {
    test(
      'never asked reads denied, so RUN-1 keeps "Allow camera" (RUN-1, S8)',
      () {
        expect(
          cameraPermissionStateFrom(
            status: PermissionStatus.denied,
            requestedBefore: false,
            showsRationale: false,
          ),
          CameraPermissionState.denied,
        );
      },
    );

    test('denied once reads denied: the prompt still shows (RUN-4, S8)', () {
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.denied,
          requestedBefore: true,
          showsRationale: true,
        ),
        CameraPermissionState.denied,
      );
    });

    test('denied twice reads permanently denied, so the button opens Settings (RUN-6, S8)', () {
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.denied,
          requestedBefore: true,
          showsRationale: false,
        ),
        CameraPermissionState.permanentlyDenied,
      );
    });

    test('revoked after a denial reads permanently denied, and Settings reaches it (RUN-6, S8)', () {
      // S8 measured the same signals as "Denied twice": denied, no rationale,
      // after a denial the flag remembers.
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.denied,
          requestedBefore: true,
          showsRationale: false,
        ),
        CameraPermissionState.permanentlyDenied,
      );
    });

    test('granted, or "Only this time", reads granted whatever the flag (RUN-5, RUN-7, S8)', () {
      for (final bool requestedBefore in <bool>[false, true]) {
        expect(
          cameraPermissionStateFrom(
            status: PermissionStatus.granted,
            requestedBefore: requestedBefore,
            showsRationale: false,
          ),
          CameraPermissionState.granted,
        );
      }
    });

    test('a status the plugin resolved itself is taken as it is (RUN-6)', () {
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.permanentlyDenied,
          requestedBefore: false,
          showsRationale: false,
        ),
        CameraPermissionState.permanentlyDenied,
      );
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.restricted,
          requestedBefore: false,
          showsRationale: false,
        ),
        CameraPermissionState.permanentlyDenied,
      );
      expect(
        cameraPermissionStateFrom(
          status: PermissionStatus.limited,
          requestedBefore: false,
          showsRationale: false,
        ),
        CameraPermissionState.granted,
      );
    });
  });

  test(
    'a prompt answer is taken as the plugin resolved it (RUN-4, RUN-6, S8)',
    () {
      expect(
        cameraPermissionStateFromRequest(PermissionStatus.granted),
        CameraPermissionState.granted,
      );
      expect(
        cameraPermissionStateFromRequest(PermissionStatus.denied),
        CameraPermissionState.denied,
      );
      // S8 "Denied twice": the request shows no dialog and says so.
      expect(
        cameraPermissionStateFromRequest(PermissionStatus.permanentlyDenied),
        CameraPermissionState.permanentlyDenied,
      );
    },
  );

  test('a denial at the prompt is remembered, a dismissed first prompt is not (S8)', () {
    expect(
      deniedAtPrompt(PermissionStatus.denied, showsRationale: true),
      isTrue,
    );
    expect(
      deniedAtPrompt(PermissionStatus.permanentlyDenied, showsRationale: false),
      isTrue,
    );
    expect(
      deniedAtPrompt(PermissionStatus.denied, showsRationale: false),
      isFalse,
    );
    expect(
      deniedAtPrompt(PermissionStatus.granted, showsRationale: false),
      isFalse,
    );
  });

  group('DevicePermissionService', () {
    late _SystemCamera system;

    setUp(() {
      system = _SystemCamera();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_permissionsChannel, system.handle);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_permissionsChannel, null);
    });

    test('a fresh install reads denied and never asked, and stores nothing (RUN-1, S8)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore();
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );

      expect(await permissions.cameraStatus(), CameraPermissionState.denied);
      expect(await permissions.cameraRequestedBefore(), isFalse);

      expect(store.writes, isEmpty);
      // Nothing is asked of Android beyond the status: no prompt (RUN-3).
      expect(system.calls, <String>['checkPermissionStatus']);
    });

    test('denying the prompt once is stored, and the prompt still shows (RUN-4, S8)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore();
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );
      system
        ..answer = PermissionStatus.denied
        ..rationale = true;

      expect(await permissions.requestCamera(), CameraPermissionState.denied);

      expect(store.values, <String, String>{
        DevicePermissionService.cameraRequestedKey: '1',
      });
      expect(await permissions.cameraRequestedBefore(), isTrue);
      expect(await permissions.cameraStatus(), CameraPermissionState.denied);
    });

    test('once Android stops asking, every later launch offers Settings (RUN-6, S8)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore(<String, String>{
        DevicePermissionService.cameraRequestedKey: '1',
      });
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );
      system
        ..answer = PermissionStatus.permanentlyDenied
        ..rationale = false;

      expect(
        await permissions.requestCamera(),
        CameraPermissionState.permanentlyDenied,
      );
      // The next launch: the status alone only says denied (S8).
      expect(
        await permissions.cameraStatus(),
        CameraPermissionState.permanentlyDenied,
      );

      expect(await permissions.openAppSettings(), isTrue);
      expect(system.calls.last, 'openAppSettings');
      expect(store.values[DevicePermissionService.cameraRequestedKey], '1');
    });

    test('a first prompt dismissed without a choice stores nothing, so "Allow camera" stays (RUN-1, S8)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore();
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );
      system
        ..answer = PermissionStatus.denied
        ..rationale = false;

      expect(await permissions.requestCamera(), CameraPermissionState.denied);

      expect(store.writes, isEmpty);
      expect(await permissions.cameraStatus(), CameraPermissionState.denied);
    });

    test('a grant clears the stored denial, so a lapsed "Only this time" asks again (RUN-5)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore(<String, String>{
        DevicePermissionService.cameraRequestedKey: '1',
      });
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );
      system.answer = PermissionStatus.granted;

      expect(await permissions.requestCamera(), CameraPermissionState.granted);
      expect(store.writes, <String>[
        'remove ${DevicePermissionService.cameraRequestedKey}',
      ]);

      // The one-time grant lapses: Android reads as if never asked.
      system
        ..status = PermissionStatus.denied
        ..rationale = false;

      expect(await permissions.cameraStatus(), CameraPermissionState.denied);
      expect(await permissions.cameraRequestedBefore(), isFalse);
    });

    test('a camera already allowed clears a stored denial (RUN-7)', () async {
      final FakeKeyValueStore store = FakeKeyValueStore(<String, String>{
        DevicePermissionService.cameraRequestedKey: '1',
      });
      final DevicePermissionService permissions = DevicePermissionService(
        store: store,
      );
      system.status = PermissionStatus.granted;

      expect(await permissions.cameraStatus(), CameraPermissionState.granted);

      expect(store.values, isEmpty);
    });
  });
}
