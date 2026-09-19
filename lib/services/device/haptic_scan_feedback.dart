import 'package:flutter/services.dart';
import 'package:qrscanner/services/scan_feedback.dart';

/// The real [ScanFeedback], with Flutter's own haptics and system sound, so
/// no plugin and no vibrate permission (SCAN-5, RUN-2).
///
/// The vibration is Android's long-press haptic, and the sound is the system
/// click. Both follow the phone's own touch-feedback settings: a phone with
/// touch sounds or haptics turned off stays silent or still, whatever the
/// app's settings say (SET-2).
class HapticScanFeedback implements ScanFeedback {
  const HapticScanFeedback();

  @override
  Future<void> success({required bool vibrate, required bool sound}) async {
    try {
      await Future.wait<void>(<Future<void>>[
        if (vibrate) HapticFeedback.vibrate(),
        if (sound) SystemSound.play(SystemSoundType.click),
      ]);
    } on PlatformException {
      // Feedback is best effort; a result still opens without it.
    }
  }
}
