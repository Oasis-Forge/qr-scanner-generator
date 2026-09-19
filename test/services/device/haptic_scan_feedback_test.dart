import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/services/device/haptic_scan_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test(
    'the default settings vibrate and play no sound (SCAN-5, SET-2)',
    () async {
      await const HapticScanFeedback().success(vibrate: true, sound: false);

      expect(platformCalls, <Matcher>[
        isMethodCall('HapticFeedback.vibrate', arguments: null),
      ]);
    },
  );

  test('sound on plays the system click as well (SET-2)', () async {
    await const HapticScanFeedback().success(vibrate: true, sound: true);

    expect(platformCalls, <Matcher>[
      isMethodCall('HapticFeedback.vibrate', arguments: null),
      isMethodCall('SystemSound.play', arguments: 'SystemSoundType.click'),
    ]);
  });

  test('both off gives no feedback at all (SET-2)', () async {
    await const HapticScanFeedback().success(vibrate: false, sound: false);

    expect(platformCalls, isEmpty);
  });

  test(
    'a platform that refuses feedback still lets the result open (SCAN-3)',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (MethodCall call) async =>
                throw PlatformException(code: 'unavailable'),
          );

      await expectLater(
        const HapticScanFeedback().success(vibrate: true, sound: true),
        completes,
      );
    },
  );
}
