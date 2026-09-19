/// The feedback a successful scan gives (SCAN-3, SCAN-5).
///
/// The caller passes the user's settings, vibration on and sound off by
/// default (SET-2), so this interface holds no settings of its own and a
/// setting change applies to the very next scan.
abstract class ScanFeedback {
  /// Plays the success feedback: a vibration when [vibrate] is on, a sound
  /// when [sound] is on, nothing when both are off (SCAN-5, SET-2).
  ///
  /// Called once a code is read, before the result screen opens, so the haptic
  /// lands within SCAN-3's 150 ms. It never throws: feedback is best effort and
  /// must not stop a result from opening.
  Future<void> success({required bool vibrate, required bool sound});
}

/// A [ScanFeedback] that vibrates and plays nothing.
///
/// [calls] records each request with the settings it carried, such as
/// `'success (vibrate: true, sound: false)'`, so a test can assert that SET-2's
/// switches reached the feedback (SCAN-5).
class NoopScanFeedback implements ScanFeedback {
  /// Every call made, in order.
  final List<String> calls = <String>[];

  @override
  Future<void> success({required bool vibrate, required bool sound}) async {
    calls.add('success (vibrate: $vibrate, sound: $sound)');
  }
}
