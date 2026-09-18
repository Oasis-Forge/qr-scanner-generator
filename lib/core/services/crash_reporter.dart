/// Crash and error reporting, off until the user turns it on.
///
/// Collection is disabled in the manifest and stays off until "Send crash
/// reports" is switched on in Settings, so no report leaves the device before
/// then (PRIV-3). Reports never carry scanned or created content (PRIV-4).
abstract class CrashReporter {
  /// Whether collection is on. False until the user opts in (PRIV-3).
  bool get isCollectionEnabled;

  /// Turns collection on or off. While off, nothing is collected or sent.
  ///
  /// The choice is stored on the device only (PRIV-8).
  Future<void> setCollectionEnabled({required bool enabled});

  /// Records a caught error, and only while collection is on.
  ///
  /// Never pass a payload, label, Wi-Fi password or file name taken from user
  /// content: crash reports contain none of it (PRIV-4).
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  });
}

/// A [CrashReporter] that reports nothing anywhere.
///
/// It starts disabled, like the real one (PRIV-3), records every call in
/// [calls], and appends to [recordedErrors] only while collection is on, so a
/// test can assert that an error raised before the user opted in was dropped.
class NoopCrashReporter implements CrashReporter {
  NoopCrashReporter({bool collectionEnabled = false})
    : _enabled = collectionEnabled;

  /// Every call made, in order, such as `'setCollectionEnabled: true'`.
  final List<String> calls = <String>[];

  /// The errors that were actually kept, as `'Bad state: boom (reason)'`.
  final List<String> recordedErrors = <String>[];

  bool _enabled;

  @override
  bool get isCollectionEnabled => _enabled;

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    calls.add('setCollectionEnabled: $enabled');
    _enabled = enabled;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    calls.add('recordError: $error');
    if (!_enabled) {
      return;
    }
    recordedErrors.add('$error${reason == null ? '' : ' ($reason)'}');
  }
}
