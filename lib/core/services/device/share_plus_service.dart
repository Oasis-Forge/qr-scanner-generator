import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import 'package:qrscanner/core/services/share_service.dart';

/// The system share sheet, through `share_plus`, and the system save dialog,
/// through `flutter_file_dialog`.
///
/// Built only by the app's entry point. Sharing text (RES-1), a file as it
/// stands (SAVE-5) and saving a file through the system picker (SAVE-2) are
/// all real; none of the three needs a storage permission.
class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(path, mimeType: mimeType)],
        text: text,
      ),
    );
  }

  @override
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final String? savedPath;
    try {
      savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes,
          fileName: suggestedName,
          mimeTypesFilter: <String>[mimeType],
        ),
      );
    } on Object {
      return const SaveResult(outcome: SaveOutcome.failed);
    }
    if (savedPath == null) {
      // The user dismissed the picker (SAVE-2): nothing was written.
      return const SaveResult(outcome: SaveOutcome.cancelled);
    }
    // Android hands back a content URI (".../document/23"), whose last part
    // is an ID, not the name the user chose: name the file only when it is
    // one.
    final String name = p.basename(savedPath);
    return SaveResult(
      outcome: SaveOutcome.saved,
      displayName: name.contains('.') ? name : null,
    );
  }
}
