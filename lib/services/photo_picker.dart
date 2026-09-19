/// Picking one photo to scan (SCAN-11).
///
/// The system photo picker hands the app only the photo the user chose, so the
/// app asks for no media or storage permission (SCAN-11, RUN-2, RUN-3). The
/// photo is decoded and then forgotten; it is never stored (DATA-3).
abstract class PhotoPicker {
  /// Opens the system photo picker and returns the chosen photo's file path,
  /// or `null` when the user backs out without choosing one.
  ///
  /// Backing out is an answer, not an error: the scanner simply stays where it
  /// was, with nothing to decode (SCAN-11).
  Future<String?> pickImagePath();
}

/// A [PhotoPicker] that opens nothing.
///
/// It hands back [path], a seeded file path, so the decode step that follows
/// can be driven (SCAN-11); pass `path: null` to drive a user backing out.
/// [calls] records every time the picker was opened.
class NoopPhotoPicker implements PhotoPicker {
  NoopPhotoPicker({this.path = '/noop/photos/picked.png'});

  /// Every call made, in order: `'pickImagePath'`.
  final List<String> calls = <String>[];

  /// What [pickImagePath] reports: the "chosen" photo, or `null` for backing
  /// out.
  final String? path;

  @override
  Future<String?> pickImagePath() async {
    calls.add('pickImagePath');
    return path;
  }
}
