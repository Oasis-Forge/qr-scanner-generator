import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import 'package:qrscanner/core/services/share_service.dart';

/// The system share sheet, through `share_plus`.
///
/// Built only by the app's entry point. Sharing text (RES-1) and a file as it
/// stands (SAVE-5) are real. Saving through the system file picker (SAVE-2)
/// arrives with the **Generator and save** PR; until then [saveFile] reports
/// [SaveOutcome.failed] and writes nothing, and no screen calls it.
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
  }) async => const SaveResult(outcome: SaveOutcome.failed);
}
