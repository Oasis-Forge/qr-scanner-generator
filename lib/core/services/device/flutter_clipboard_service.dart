import 'package:flutter/services.dart';

import 'package:qrscanner/core/services/clipboard_service.dart';

/// The system clipboard, through Flutter's own [Clipboard]: no plugin.
///
/// Built only by the app's entry point. [readText] is called only from an
/// explicit user action, because Android 12+ shows a toast on every read.
class FlutterClipboardService implements ClipboardService {
  const FlutterClipboardService();

  @override
  Future<void> copyText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  @override
  Future<String?> readText() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
