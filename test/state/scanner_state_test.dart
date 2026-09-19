import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/services/photo_picker.dart';
import 'package:qrscanner/services/scan_feedback.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/scanner_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../helpers/database.dart';
import '../helpers/fake_stores.dart';

/// A photo picker that opens nothing: it hands back [path], or null when the
/// test has the user back out, and records each call (SCAN-11).
class _FakePhotoPicker implements PhotoPicker {
  String? path = '/photos/code.png';

  /// When true the picker throws, as a device with no photo picker would.
  bool fails = false;

  final List<String> calls = <String>[];

  @override
  Future<String?> pickImagePath() async {
    calls.add('pickImagePath');
    if (fails) {
      throw StateError('no photo picker on this device');
    }
    return path;
  }
}

/// Records every success feedback with the switches it was given (SCAN-5,
/// SET-2).
class _RecordingFeedback implements ScanFeedback {
  final List<String> calls = <String>[];

  @override
  Future<void> success({required bool vibrate, required bool sound}) async {
    calls.add('success vibrate: $vibrate, sound: $sound');
  }
}

/// [NoopPermissionService] whose system status the test can change, as the
/// user does in Settings or as an "Only this time" grant does when it expires
/// (RUN-5, RUN-6).
class _SettingsPermissions extends NoopPermissionService {
  _SettingsPermissions({super.initialState, super.requestedBefore});

  /// What the system reports from now on, or null to leave the fake's own
  /// answer.
  CameraPermissionState? systemStatus;

  @override
  Future<CameraPermissionState> cameraStatus() async {
    final CameraPermissionState reported = await super.cameraStatus();
    return systemStatus ?? reported;
  }
}

/// A DAO whose scan writes all fail, as a full or locked database would.
class _FailingRecordDao extends RecordDao {
  _FailingRecordDao(super.database);

  int attempts = 0;

  @override
  Future<RecordWrite> recordScan({
    required RecordKind kind,
    required RecordSource source,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    Uint8List? payloadBytes,
    List<String> sensitiveFields = const <String>[],
    String? batchSessionId,
    String? contentJson,
    String? styleJson,
    DateTime? at,
  }) async {
    attempts++;
    throw StateError('the database refused the write');
  }
}

const CodeDetection _link = CodeDetection(
  payload: 'https://example.com',
  symbology: 'qr',
);

const CodeDetection _otherLink = CodeDetection(
  payload: 'https://example.org',
  symbology: 'qr',
);

const CodeDetection _wifi = CodeDetection(
  payload: 'WIFI:T:WPA;S:Home;P:secret;;',
  symbology: 'qr',
);

const CodeDetection _product = CodeDetection(
  payload: '5901234123457',
  symbology: 'ean13',
);

/// Waits until [condition] holds, checking each time [scanner] notifies. A
/// scan's result lands after a real database write, so the test waits for it
/// rather than for a fixed number of turns of the event loop.
Future<void> _until(ScannerState scanner, bool Function() condition) async {
  if (condition()) {
    return;
  }
  final Completer<void> done = Completer<void>();
  void check() {
    if (!done.isCompleted && condition()) {
      done.complete();
    }
  }

  scanner.addListener(check);
  try {
    await done.future.timeout(const Duration(seconds: 5));
  } finally {
    scanner.removeListener(check);
  }
}

void main() {
  late DateTime clock;
  late TestDatabase db;
  late NoopCameraScanner camera;
  late _FakePhotoPicker picker;
  late _RecordingFeedback feedback;
  late SettingsState settings;
  late SuccessCounts counts;

  setUp(() async {
    clock = fixtureTime;
    db = await openTestDatabase(now: () => clock);
    camera = NoopCameraScanner();
    picker = _FakePhotoPicker();
    feedback = _RecordingFeedback();
    settings = SettingsState(db.store);
    counts = SuccessCounts(db.store);
  });

  /// A scanner over the test's fakes. The camera is allowed unless the test
  /// passes other [permissions].
  ScannerState scannerWith({
    PermissionService? permissions,
    CameraScanner? cameraScanner,
    ImageDecoder? decoder,
    RecordDao? records,
  }) {
    final ScannerState scanner = ScannerState(
      permissions:
          permissions ??
          NoopPermissionService(initialState: CameraPermissionState.granted),
      camera: cameraScanner ?? camera,
      imageDecoder: decoder ?? NoopImageDecoder(),
      photoPicker: picker,
      feedback: feedback,
      records: records ?? db.records,
      settings: settings,
      successCounts: counts,
      now: () => clock,
    );
    addTearDown(scanner.dispose);
    return scanner;
  }

  /// A scanner on screen with the camera allowed and running (RUN-7).
  Future<ScannerState> liveScanner({
    ImageDecoder? decoder,
    RecordDao? records,
  }) async {
    final ScannerState scanner = scannerWith(
      decoder: decoder,
      records: records,
    );
    await scanner.enter();
    return scanner;
  }

  /// Delivers one detection pass and waits for its result.
  Future<ScanOutcome> scan(ScannerState scanner, CodeDetection code) async {
    camera.emit(<CodeDetection>[code]);
    await _until(scanner, () => scanner.outcome != null);
    return scanner.outcome!;
  }

  group('camera permission (RUN-1 to RUN-7)', () {
    test(
      'starts by reading the permission, with no placeholder yet (RUN-7)',
      () {
        expect(scannerWith().phase, ScannerPhase.checking);
      },
    );

    test('a camera never asked for shows Allow camera and asks nothing '
        '(RUN-1, RUN-3)', () async {
      final NoopPermissionService permissions = NoopPermissionService();
      final ScannerState scanner = scannerWith(permissions: permissions);

      await scanner.enter();

      expect(scanner.phase, ScannerPhase.needsPermission);
      expect(scanner.offersPhotoAndTyping, isFalse);
      expect(permissions.calls, isNot(contains('requestCamera')));
      expect(camera.calls, isNot(contains('start')));
      expect(scanner.isCameraRunning, isFalse);
    });

    test('Allow camera asks, and a grant goes straight to the live scanner '
        '(RUN-3, RUN-7)', () async {
      final NoopPermissionService permissions = NoopPermissionService(
        requestResult: CameraPermissionState.granted,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);
      await scanner.enter();
      final List<ScannerPhase> seen = <ScannerPhase>[];
      scanner.addListener(() => seen.add(scanner.phase));

      await scanner.requestPermission();

      expect(
        permissions.calls.where((String c) => c == 'requestCamera'),
        hasLength(1),
      );
      expect(scanner.phase, ScannerPhase.granted);
      expect(seen.toSet(), <ScannerPhase>{ScannerPhase.granted});
      expect(scanner.isCameraRunning, isTrue);
      expect(camera.isDetecting, isTrue);
    });

    test("Don't allow keeps the placeholder and adds Scan a photo and Type a "
        'code (RUN-4)', () async {
      final ScannerState scanner = scannerWith(
        permissions: NoopPermissionService(
          requestResult: CameraPermissionState.denied,
          showsRationale: true,
        ),
      );
      await scanner.enter();

      await scanner.requestPermission();

      expect(scanner.phase, ScannerPhase.denied);
      expect(scanner.offersPhotoAndTyping, isTrue);
      expect(scanner.isCameraRunning, isFalse);
    });

    test('a camera denied once before opens on the denied state, asking '
        'nothing (RUN-3, RUN-4)', () async {
      final NoopPermissionService permissions = NoopPermissionService(
        requestedBefore: true,
        showsRationale: true,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);

      await scanner.enter();

      expect(scanner.phase, ScannerPhase.denied);
      expect(permissions.calls, isNot(contains('requestCamera')));
    });

    test('a denied camera can still be allowed from the button (RUN-4, '
        'RUN-7)', () async {
      final ScannerState scanner = scannerWith(
        permissions: NoopPermissionService(
          requestedBefore: true,
          showsRationale: true,
          requestResult: CameraPermissionState.granted,
        ),
      );
      await scanner.enter();

      await scanner.requestPermission();

      expect(scanner.phase, ScannerPhase.granted);
      expect(scanner.isCameraRunning, isTrue);
    });

    test(
      'when Android stops asking, the button becomes Open settings (RUN-6)',
      () async {
        final ScannerState scanner = scannerWith(
          permissions: NoopPermissionService(
            requestResult: CameraPermissionState.permanentlyDenied,
          ),
        );
        await scanner.enter();

        await scanner.requestPermission();

        expect(scanner.phase, ScannerPhase.permanentlyDenied);
        expect(scanner.offersPhotoAndTyping, isTrue);
      },
    );

    test('a camera Android no longer asks for opens on Open settings, read '
        'from the rationale (RUN-6, spike S8)', () async {
      final NoopPermissionService permissions = NoopPermissionService(
        requestedBefore: true,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);

      await scanner.enter();

      expect(scanner.phase, ScannerPhase.permanentlyDenied);
      expect(permissions.calls, contains('shouldShowCameraRationale'));
      expect(permissions.calls, isNot(contains('requestCamera')));
    });

    test('Open settings opens the permission page, and a grant made there is '
        'picked up on return (RUN-5, RUN-6)', () async {
      final _SettingsPermissions permissions = _SettingsPermissions(
        requestedBefore: true,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);
      await scanner.enter();
      expect(scanner.phase, ScannerPhase.permanentlyDenied);

      await scanner.openSettings();
      await scanner.onAppLifecycleChanged(AppLifecycleState.paused);
      permissions.systemStatus = CameraPermissionState.granted;
      await scanner.onAppLifecycleChanged(AppLifecycleState.resumed);

      expect(permissions.calls, contains('openAppSettings'));
      expect(scanner.phase, ScannerPhase.granted);
      expect(scanner.isCameraRunning, isTrue);
      expect(camera.isDetecting, isTrue);
      expect(scanner.error, isNull);
    });

    test('a grant that ended while the app was away shows Allow camera again, '
        'with no dialog of our own (RUN-5)', () async {
      final _SettingsPermissions permissions = _SettingsPermissions(
        initialState: CameraPermissionState.granted,
        requestedBefore: true,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);
      await scanner.enter();
      expect(scanner.phase, ScannerPhase.granted);

      await scanner.onAppLifecycleChanged(AppLifecycleState.paused);
      permissions.systemStatus = CameraPermissionState.denied;
      await scanner.onAppLifecycleChanged(AppLifecycleState.resumed);

      expect(scanner.phase, ScannerPhase.needsPermission);
      expect(scanner.isCameraRunning, isFalse);
      expect(permissions.calls, isNot(contains('requestCamera')));
    });

    test('a camera already allowed opens straight on the live scanner, asking '
        'nothing (RUN-7)', () async {
      final NoopPermissionService permissions = NoopPermissionService(
        initialState: CameraPermissionState.granted,
      );
      final ScannerState scanner = scannerWith(permissions: permissions);
      final List<ScannerPhase> seen = <ScannerPhase>[];
      scanner.addListener(() => seen.add(scanner.phase));

      await scanner.enter();

      expect(scanner.phase, ScannerPhase.granted);
      expect(seen.toSet(), <ScannerPhase>{ScannerPhase.granted});
      expect(scanner.isCameraRunning, isTrue);
      expect(camera.isDetecting, isTrue);
      expect(permissions.calls, isNot(contains('requestCamera')));
    });

    test('Settings that do not open say so (RUN-6)', () async {
      final ScannerState scanner = scannerWith(
        permissions: NoopPermissionService(
          requestedBefore: true,
          settingsOpens: false,
        ),
      );
      await scanner.enter();

      await scanner.openSettings();

      expect(scanner.error, ScannerError.settingsDidNotOpen);
      scanner.clearError();
      expect(scanner.error, isNull);
    });

    test(
      'an allowed camera that does not start offers a photo and typing',
      () async {
        final ScannerState scanner = scannerWith(
          cameraScanner: NoopCameraScanner(startSucceeds: false),
        );

        await scanner.enter();

        expect(scanner.phase, ScannerPhase.cameraUnavailable);
        expect(scanner.offersPhotoAndTyping, isTrue);
        expect(scanner.isCameraRunning, isFalse);
      },
    );
  });

  group('lifecycle', () {
    test(
      'the camera stops in the background and starts again on return',
      () async {
        final ScannerState scanner = await liveScanner();

        await scanner.onAppLifecycleChanged(AppLifecycleState.hidden);
        expect(scanner.isCameraRunning, isFalse);
        expect(camera.calls, contains('stop'));

        await scanner.onAppLifecycleChanged(AppLifecycleState.resumed);
        expect(scanner.isCameraRunning, isTrue);
        expect(camera.isDetecting, isTrue);
      },
    );

    test('a system dialog on top leaves the camera running', () async {
      final ScannerState scanner = await liveScanner();

      await scanner.onAppLifecycleChanged(AppLifecycleState.inactive);

      expect(scanner.isCameraRunning, isTrue);
      expect(camera.calls, isNot(contains('stop')));
    });

    test(
      'leaving the scanner stops the camera, and coming back starts it',
      () async {
        final ScannerState scanner = await liveScanner();

        await scanner.leave();
        expect(scanner.isCameraRunning, isFalse);

        await scanner.enter();
        expect(scanner.isCameraRunning, isTrue);
      },
    );

    test(
      'the camera stays off when the app returns to another screen',
      () async {
        final ScannerState scanner = await liveScanner();
        await scanner.leave();

        await scanner.onAppLifecycleChanged(AppLifecycleState.paused);
        await scanner.onAppLifecycleChanged(AppLifecycleState.resumed);

        expect(scanner.isCameraRunning, isFalse);
      },
    );
  });

  group('torch (SCAN-6)', () {
    test('the torch button shows only on the live scanner of a camera with a '
        'flash (SCAN-6)', () async {
      final ScannerState withFlash = scannerWith();
      expect(withFlash.showsTorchButton, isFalse);
      await withFlash.enter();
      expect(withFlash.showsTorchButton, isTrue);

      final ScannerState noFlash = scannerWith(
        cameraScanner: NoopCameraScanner(torchAvailable: false),
      );
      await noFlash.enter();
      expect(noFlash.showsTorchButton, isFalse);
    });

    test('the torch button toggles the torch (SCAN-6)', () async {
      final ScannerState scanner = await liveScanner();

      await scanner.toggleTorch();
      expect(scanner.isTorchOn, isTrue);

      await scanner.toggleTorch();
      expect(scanner.isTorchOn, isFalse);
    });

    test('leaving the scanner turns the torch off (SCAN-6)', () async {
      final ScannerState scanner = await liveScanner();
      await scanner.setTorch(on: true);
      expect(camera.torchState, TorchState.on);

      await scanner.leave();

      expect(camera.torchState, TorchState.off);
      expect(scanner.isTorchOn, isFalse);
      expect(
        camera.calls,
        containsAllInOrder(<String>['setTorch: false', 'stop']),
      );
    });

    test('going to the background turns the torch off, and it stays off on '
        'return (SCAN-6)', () async {
      final ScannerState scanner = await liveScanner();
      await scanner.setTorch(on: true);

      await scanner.onAppLifecycleChanged(AppLifecycleState.paused);
      await scanner.onAppLifecycleChanged(AppLifecycleState.resumed);

      expect(scanner.isTorchOn, isFalse);
      expect(scanner.isCameraRunning, isTrue);
    });
  });

  group('zoom (SCAN-7)', () {
    bool autoZoomCallSaid(String enabled) {
      final Iterable<String> calls = camera.calls.where(
        (String call) => call.startsWith('setAutoZoom'),
      );
      return calls.isNotEmpty && calls.last.contains(enabled);
    }

    test('auto-zoom is on when the scanner opens (SCAN-7)', () async {
      final ScannerState scanner = await liveScanner();

      expect(scanner.autoZoomEnabled, isTrue);
      expect(autoZoomCallSaid('true'), isTrue);
    });

    test('the slider zooms, clamped to the camera, and turns auto-zoom off '
        'until the scanner is reopened (SCAN-7)', () async {
      final ScannerState scanner = await liveScanner();

      await scanner.setZoom(3);
      expect(scanner.zoom, 3);
      expect(scanner.autoZoomEnabled, isFalse);
      expect(autoZoomCallSaid('false'), isTrue);

      await scanner.setZoom(10);
      expect(scanner.zoom, scanner.maxZoom);
      await scanner.setZoom(0.2);
      expect(scanner.zoom, ScannerState.minZoom);

      await scanner.leave();
      await scanner.enter();
      expect(scanner.autoZoomEnabled, isTrue);
      expect(autoZoomCallSaid('true'), isTrue);
    });

    test('a pinch scales from the zoom it started at (SCAN-7)', () async {
      final ScannerState scanner = await liveScanner();
      await scanner.setZoom(2);

      scanner.beginPinch();
      await scanner.updatePinch(1.5);
      expect(scanner.zoom, 3);
      await scanner.updatePinch(0.75);
      expect(scanner.zoom, 1.5);
      expect(scanner.autoZoomEnabled, isFalse);
    });

    test('a pinch alone turns auto-zoom off (SCAN-7)', () async {
      final ScannerState scanner = await liveScanner();

      scanner.beginPinch();
      await scanner.updatePinch(1.2);

      expect(scanner.autoZoomEnabled, isFalse);
    });

    test('double-tap switches between 1x and 2x, and turns auto-zoom off '
        '(SCAN-7)', () async {
      final ScannerState scanner = await liveScanner();

      await scanner.toggleZoom();
      expect(scanner.zoom, 2);
      expect(scanner.autoZoomEnabled, isFalse);

      await scanner.toggleZoom();
      expect(scanner.zoom, 1);

      await scanner.setZoom(3.5);
      await scanner.toggleZoom();
      expect(scanner.zoom, 1);
    });
  });

  group('detection (SCAN-3 to SCAN-5, SCAN-13)', () {
    test('one code opens its result, pauses detection and vibrates without '
        'sound by default (SCAN-3, SCAN-5, SET-2)', () async {
      final ScannerState scanner = await liveScanner();

      final ScanOutcome outcome = await scan(scanner, _link);

      expect(outcome.payloadText, 'https://example.com');
      expect(outcome.parsedType, ParsedType.url);
      expect(outcome.symbology, Symbology.qr);
      expect(outcome.source, RecordSource.camera);
      expect(camera.isDetecting, isFalse);
      expect(camera.calls, contains('pause'));
      expect(feedback.calls, <String>['success vibrate: true, sound: false']);
    });

    test(
      'feedback follows the sound and vibration settings (SCAN-5, SET-2)',
      () async {
        await settings.setSoundOnScan(enabled: true);
        await settings.setVibrateOnScan(enabled: false);
        final ScannerState scanner = await liveScanner();

        await scan(scanner, _link);

        expect(feedback.calls, <String>['success vibrate: false, sound: true']);
      },
    );

    test('a scan is written to History and counted before its result shows '
        '(DATA-4, DATA-8)', () async {
      final ScannerState scanner = await liveScanner();

      final ScanOutcome outcome = await scan(scanner, _link);

      final List<ScanRecord> stored = await db.records.liveRecords();
      expect(stored, hasLength(1));
      expect(stored.single.id, outcome.record.id);
      expect(stored.single.payloadText, 'https://example.com');
      expect(stored.single.source, RecordSource.camera);
      expect(stored.single.parsedType, ParsedType.url);
      expect(stored.single.symbology, Symbology.qr);
      expect(outcome.isSaved, isTrue);
      expect(outcome.saveFailed, isFalse);
      expect(counts.successfulScans, 1);
      expect(await db.store.getInt(SuccessCounts.scansKey), 1);
    });

    test('a Wi-Fi scan is stored with its password flagged (DATA-5)', () async {
      final ScannerState scanner = await liveScanner();

      final ScanOutcome outcome = await scan(scanner, _wifi);

      expect(outcome.parsedType, ParsedType.wifi);
      final ScanRecord? stored = await db.records.findById(outcome.record.id);
      expect(stored!.sensitiveFields, <String>[
        SensitiveFieldKeys.wifiPassword,
      ]);
    });

    test(
      'several codes in one pass are listed, never guessed (SCAN-13)',
      () async {
        final ScannerState scanner = await liveScanner();

        camera.emit(<CodeDetection>[_link, _otherLink]);
        await _until(scanner, () => scanner.hasChoices);

        expect(scanner.outcome, isNull);
        expect(scanner.choices.map((ScanChoice c) => c.preview), <String>[
          'https://example.com',
          'https://example.org',
        ]);
        expect(
          scanner.choices.map((ScanChoice c) => c.parsedType),
          <ParsedType>[ParsedType.url, ParsedType.url],
        );
        expect(camera.isDetecting, isFalse);
        expect(await db.records.liveRecords(), isEmpty);
        expect(counts.successfulScans, 0);
      },
    );

    test('the code picked from the list opens its result from the camera '
        '(SCAN-13, RES-3)', () async {
      final ScannerState scanner = await liveScanner();
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await _until(scanner, () => scanner.hasChoices);

      final ScanOutcome? outcome = await scanner.choose(scanner.choices[1]);

      expect(outcome, isNotNull);
      expect(scanner.outcome, outcome);
      expect(outcome!.payloadText, 'https://example.org');
      expect(outcome.source, RecordSource.camera);
      expect(scanner.hasChoices, isFalse);
      expect(counts.successfulScans, 1);
      final List<ScanRecord> stored = await db.records.liveRecords();
      expect(stored.map((ScanRecord r) => r.payloadText), <String>[
        'https://example.org',
      ]);
    });

    test(
      'the list shows the first 40 characters of a long payload (SCAN-13)',
      () async {
        final ScannerState scanner = await liveScanner();
        final String long = 'https://example.com/${'a' * 60}';

        camera.emit(<CodeDetection>[
          CodeDetection(payload: long, symbology: 'qr'),
          _product,
        ]);
        await _until(scanner, () => scanner.hasChoices);

        final ScanChoice first = scanner.choices.first;
        expect(first.preview, long.substring(0, 40));
        expect(first.isPreviewTruncated, isTrue);
        expect(scanner.choices.last.preview, '5901234123457');
        expect(scanner.choices.last.parsedType, ParsedType.product);
        expect(scanner.choices.last.isPreviewTruncated, isFalse);
      },
    );

    test(
      'the same code twice in one pass is one code, not a list (SCAN-13)',
      () async {
        final ScannerState scanner = await liveScanner();

        camera.emit(<CodeDetection>[_link, _link]);
        await _until(scanner, () => scanner.outcome != null);

        expect(scanner.hasChoices, isFalse);
        expect(scanner.outcome!.payloadText, 'https://example.com');
      },
    );

    test('back on the scanner, the same payload is ignored for 2 s while '
        'another code scans (SCAN-3)', () async {
      final ScannerState scanner = await liveScanner();
      await scan(scanner, _link);

      await scanner.closeResult();
      expect(camera.isDetecting, isTrue);
      clock = clock.add(const Duration(milliseconds: 1900));
      camera.emit(<CodeDetection>[_link]);
      await pumpEventQueue();

      expect(scanner.outcome, isNull);
      expect(feedback.calls, hasLength(1));

      final ScanOutcome other = await scan(scanner, _otherLink);
      expect(other.payloadText, 'https://example.org');
    });

    test('after 2 s the same payload scans again, as a duplicate (SCAN-3, '
        'DATA-4, HIS-5)', () async {
      final ScannerState scanner = await liveScanner();
      await scan(scanner, _link);
      await scanner.closeResult();

      clock = clock.add(ScannerState.samePayloadPause);
      final ScanOutcome again = await scan(scanner, _link);

      expect(again.payloadText, 'https://example.com');
      expect(again.isDuplicate, isTrue);
      expect(again.record.duplicateCount, 2);
      expect(await db.records.liveRecords(), hasLength(1));
      expect(counts.successfulScans, 2);
    });

    test('closing a result picked from a list ignores the whole list for 2 s '
        '(SCAN-3, SCAN-13)', () async {
      final ScannerState scanner = await liveScanner();
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await _until(scanner, () => scanner.hasChoices);
      await scanner.choose(scanner.choices.first);

      await scanner.closeResult();
      clock = clock.add(const Duration(seconds: 1));
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await pumpEventQueue();

      expect(scanner.hasChoices, isFalse);
      expect(scanner.outcome, isNull);
    });

    test('a dismissed list is not reopened for 2 s by the codes still in view '
        '(SCAN-3, SCAN-13)', () async {
      final ScannerState scanner = await liveScanner();
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await _until(scanner, () => scanner.hasChoices);

      await scanner.dismissChoices();
      expect(camera.isDetecting, isTrue);
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await pumpEventQueue();
      expect(scanner.hasChoices, isFalse);

      clock = clock.add(ScannerState.samePayloadPause);
      camera.emit(<CodeDetection>[_link, _otherLink]);
      await _until(scanner, () => scanner.hasChoices);
      expect(scanner.choices, hasLength(2));
    });

    test('with Save history off, the result opens and nothing is written '
        '(HIS-8, DATA-6, DATA-8)', () async {
      await settings.setSaveHistory(enabled: false);
      final ScannerState scanner = await liveScanner();

      final ScanOutcome outcome = await scan(scanner, _link);

      expect(outcome.payloadText, 'https://example.com');
      expect(outcome.isSaved, isFalse);
      expect(outcome.saveFailed, isFalse);
      expect(outcome.record.id, ScanOutcome.unsavedRecordId);
      expect(outcome.record.source, RecordSource.camera);
      expect(await db.records.liveRecords(), isEmpty);
      expect(counts.successfulScans, 1);
    });

    test('a failed write still opens the result and says it was not saved '
        '(DATA-4, DATA-8)', () async {
      final _FailingRecordDao failing = _FailingRecordDao(db.database);
      final ScannerState scanner = await liveScanner(records: failing);

      final ScanOutcome outcome = await scan(scanner, _link);

      expect(failing.attempts, 1);
      expect(outcome.payloadText, 'https://example.com');
      expect(outcome.isSaved, isFalse);
      expect(outcome.saveFailed, isTrue);
      expect(counts.successfulScans, 1);
    });

    test('nothing is detected while the scanner is left', () async {
      final ScannerState scanner = await liveScanner();
      await scanner.leave();

      camera.emit(<CodeDetection>[_link]);
      await pumpEventQueue();

      expect(scanner.outcome, isNull);
      expect(feedback.calls, isEmpty);
    });
  });

  group('scan from a photo (SCAN-11)', () {
    test('a photo with one code opens its result at once, from the image '
        '(SCAN-11, RES-3)', () async {
      final NoopImageDecoder decoder = NoopImageDecoder(
        result: const ImageDecodeResult(<CodeDetection>[_link]),
      );
      final ScannerState scanner = await liveScanner(decoder: decoder);

      final ScanOutcome? outcome = await scanner.pickPhoto();

      expect(picker.calls, <String>['pickImagePath']);
      expect(decoder.calls, <String>['decodeFile: /photos/code.png']);
      expect(outcome, isNotNull);
      expect(scanner.outcome, outcome);
      expect(outcome!.source, RecordSource.image);
      expect(outcome.parsedType, ParsedType.url);
      expect(camera.isDetecting, isFalse);
      final List<ScanRecord> stored = await db.records.liveRecords();
      expect(stored.single.source, RecordSource.image);
      expect(counts.successfulScans, 1);
    });

    test('a photo with no code says No code found, and counts nothing '
        '(SCAN-11, DATA-8)', () async {
      final ScannerState scanner = await liveScanner();

      final ScanOutcome? outcome = await scanner.pickPhoto();

      expect(outcome, isNull);
      expect(scanner.showsNoCodeFound, isTrue);
      expect(scanner.outcome, isNull);
      expect(camera.isDetecting, isFalse);
      expect(await db.records.liveRecords(), isEmpty);
      expect(counts.successfulScans, 0);

      await scanner.dismissNoCodeFound();
      expect(scanner.showsNoCodeFound, isFalse);
      expect(camera.isDetecting, isTrue);
    });

    test(
      'Try another photo picks again from No code found (SCAN-11)',
      () async {
        final ScannerState scanner = await liveScanner();
        await scanner.pickPhoto();

        await scanner.pickPhoto();

        expect(picker.calls, <String>['pickImagePath', 'pickImagePath']);
        expect(scanner.showsNoCodeFound, isTrue);
      },
    );

    test('a photo with several codes lists them, and a pick opens it from the '
        'image (SCAN-11, SCAN-13)', () async {
      final ScannerState scanner = await liveScanner(
        decoder: NoopImageDecoder(
          result: const ImageDecodeResult(<CodeDetection>[_link, _wifi]),
        ),
      );

      final ScanOutcome? none = await scanner.pickPhoto();
      expect(none, isNull);
      expect(scanner.choices.map((ScanChoice c) => c.parsedType), <ParsedType>[
        ParsedType.url,
        ParsedType.wifi,
      ]);
      expect(counts.successfulScans, 0);

      final ScanOutcome? outcome = await scanner.choose(scanner.choices.last);
      expect(outcome!.source, RecordSource.image);
      expect(outcome.parsedType, ParsedType.wifi);
      expect(counts.successfulScans, 1);
    });

    test('backing out of the picker changes nothing (SCAN-11)', () async {
      final NoopImageDecoder decoder = NoopImageDecoder();
      final ScannerState scanner = await liveScanner(decoder: decoder);
      picker.path = null;

      final ScanOutcome? outcome = await scanner.pickPhoto();

      expect(outcome, isNull);
      expect(decoder.calls, isEmpty);
      expect(scanner.showsNoCodeFound, isFalse);
      expect(scanner.error, isNull);
      expect(camera.isDetecting, isTrue);
    });

    test('a picker that cannot open says so (SCAN-11)', () async {
      final ScannerState scanner = await liveScanner();
      picker.fails = true;

      await scanner.pickPhoto();

      expect(scanner.error, ScannerError.photoPickerFailed);
      expect(scanner.showsNoCodeFound, isFalse);
      expect(camera.isDetecting, isTrue);
    });

    test(
      'a photo can be scanned with the camera denied (RUN-4, SCAN-11)',
      () async {
        final ScannerState scanner = scannerWith(
          permissions: NoopPermissionService(
            requestedBefore: true,
            showsRationale: true,
          ),
          decoder: NoopImageDecoder(
            result: const ImageDecodeResult(<CodeDetection>[_product]),
          ),
        );
        await scanner.enter();

        final ScanOutcome? outcome = await scanner.pickPhoto();

        expect(scanner.phase, ScannerPhase.denied);
        expect(outcome!.parsedType, ParsedType.product);
        expect(outcome.symbology, Symbology.ean13);
      },
    );
  });

  group('typed entry (SCAN-12)', () {
    test(
      'typed text opens the same result, with source manual (SCAN-12)',
      () async {
        final ScannerState scanner = await liveScanner();

        final ScanOutcome? outcome = await scanner.submitTyped(
          '  https://example.com \n',
        );

        expect(scanner.outcome, outcome);
        expect(outcome!.payloadText, 'https://example.com');
        expect(outcome.parsedType, ParsedType.url);
        expect(outcome.symbology, Symbology.unknown);
        expect(outcome.source, RecordSource.manual);
        expect(camera.isDetecting, isFalse);
        final List<ScanRecord> stored = await db.records.liveRecords();
        expect(stored.single.source, RecordSource.manual);
        expect(counts.successfulScans, 1);
        expect(feedback.calls, isEmpty);
      },
    );

    test(
      'a typed barcode number opens a product result (SCAN-12, RES-9)',
      () async {
        final ScannerState scanner = await liveScanner();

        final ScanOutcome? outcome = await scanner.submitTyped('5901234123457');

        expect(outcome!.parsedType, ParsedType.product);
        expect(outcome.symbology, Symbology.ean13);
      },
    );

    test('typing a code scanned before bumps its row, and the result says it '
        'was typed (SCAN-12, DATA-4)', () async {
      final ScannerState scanner = await liveScanner();
      await scan(scanner, _product);
      await scanner.closeResult();

      final ScanOutcome? typed = await scanner.submitTyped('5901234123457');

      expect(typed!.isDuplicate, isTrue);
      expect(typed.source, RecordSource.manual);
      expect(typed.record.source, RecordSource.camera);
      expect(typed.record.duplicateCount, 2);
    });

    test('Type a code from No code found replaces it with the result '
        '(SCAN-11, SCAN-12)', () async {
      final ScannerState scanner = await liveScanner();
      await scanner.pickPhoto();
      expect(scanner.showsNoCodeFound, isTrue);

      await scanner.submitTyped('Hello');

      expect(scanner.showsNoCodeFound, isFalse);
      expect(scanner.outcome!.parsedType, ParsedType.text);
    });

    test('blank text opens nothing (SCAN-12)', () async {
      final ScannerState scanner = await liveScanner();

      expect(await scanner.submitTyped('   '), isNull);
      expect(scanner.outcome, isNull);
      expect(counts.successfulScans, 0);
    });
  });

  group('ScanOutcome', () {
    test('a History reopen shows the record as stored (RES-3, REC-3)', () {
      final ScanRecord record = aScanRecord(
        source: RecordSource.image,
        parsedType: ParsedType.wifi,
        payloadText: 'WIFI:S:Home;;',
      );

      final ScanOutcome reopened = ScanOutcome.reopened(record);

      expect(reopened.record, record);
      expect(reopened.parsedType, ParsedType.wifi);
      expect(reopened.source, RecordSource.image);
      expect(reopened.isSaved, isTrue);
    });

    test('a binary payload reports its byte count (RES-13)', () {
      final ScanOutcome outcome = ScanOutcome.reopened(
        aScanRecord(
          parsedType: ParsedType.unknown,
          payloadBytes: Uint8List.fromList(<int>[0xff, 0xfe, 0x00]),
        ),
      );

      expect(outcome.isBinary, isTrue);
      expect(outcome.byteCount, 3);
    });

    test('its description leaves the payload out (PRIV-4)', () {
      final ScanOutcome outcome = ScanOutcome.reopened(
        aScanRecord(payloadText: 'https://secret.example.com'),
      );

      expect(outcome.toString(), isNot(contains('secret')));
    });
  });
}
