import 'dart:typed_data';

/// What became of a save through the system file picker (SAVE-2).
enum SaveOutcome {
  /// The user chose a destination and the bytes were written there.
  saved,

  /// The user dismissed the picker. Nothing was written.
  cancelled,

  /// The picker or the write failed. Nothing was written.
  failed,
}

/// The outcome of [ShareService.saveFile].
class SaveResult {
  const SaveResult({required this.outcome, this.displayName});

  final SaveOutcome outcome;

  /// The name the file was saved under, for the confirmation message, or `null`
  /// when nothing was written.
  final String? displayName;

  bool get saved => outcome == SaveOutcome.saved;
}

/// Handing content to other apps, and writing files where the user chooses.
///
/// Save and Share are the created-code screen's two largest buttons (SAVE-1),
/// Share sends exactly the file Save writes, without re-encoding it (SAVE-5),
/// and a CSV export goes out the same way (EXP-1). Nothing leaves the device
/// until the user taps one of them (PRIV-4).
abstract class ShareService {
  /// Sends [text] to the system share sheet (RES-1, EXP-3).
  Future<void> shareText(String text, {String? subject});

  /// Sends the file at [path] as it stands, without re-encoding it (SAVE-5).
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  });

  /// Writes [bytes] where the user chooses, through the system file picker, so
  /// the app needs no storage permission (SAVE-2, EXP-1).
  ///
  /// [suggestedName] follows SAVE-4 (or EXP-5 for an export) and is ASCII.
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  });
}

/// A [ShareService] that writes nothing and opens no share sheet.
///
/// It records every call in [calls], including the byte count it was handed, so
/// a test can assert what the app tried to send. [saveOutcome] seeds what
/// [saveFile] reports, so both the saved and the cancelled path can be driven
/// without a file system.
class NoopShareService implements ShareService {
  NoopShareService({this.saveOutcome = SaveOutcome.saved});

  /// Every call made, in order, such as
  /// `'saveFile: qr-20260917.png (image/png, 12 bytes)'`.
  final List<String> calls = <String>[];

  final SaveOutcome saveOutcome;

  @override
  Future<void> shareText(String text, {String? subject}) async {
    calls.add(
      'shareText: $text${subject == null ? '' : ' (subject: $subject)'}',
    );
  }

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  }) async {
    calls.add('shareFile: $path ($mimeType)');
  }

  @override
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    calls.add('saveFile: $suggestedName ($mimeType, ${bytes.length} bytes)');
    return SaveResult(
      outcome: saveOutcome,
      displayName: saveOutcome == SaveOutcome.saved ? suggestedName : null,
    );
  }
}
