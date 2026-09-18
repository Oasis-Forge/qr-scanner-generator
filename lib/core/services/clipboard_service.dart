/// Copying text out of the app, and reading text back in.
///
/// Copy is offered on every result (RES-1) and happens on its own only when
/// "Copy on scan" is on, and then only once the result is on screen (RES-2,
/// SET-3). Reading is never automatic: it happens on an explicit user action,
/// such as pasting into the typed-entry form (SCAN-12).
abstract class ClipboardService {
  /// Puts [text] on the clipboard, exactly as it was decoded (RES-1).
  Future<void> copyText(String text);

  /// The clipboard's text, or `null` when it holds none.
  ///
  /// Only ever called from a control the user tapped (RES-2).
  Future<String?> readText();
}

/// A [ClipboardService] that touches no clipboard.
///
/// It records every call in [calls] and remembers the last copied text, so a
/// test can assert what the app asked for. Tests get this by default; only the
/// app's entry point builds the real one (`CLAUDE.md`).
class NoopClipboardService implements ClipboardService {
  NoopClipboardService({String? clipboardText}) : _text = clipboardText;

  /// Every call made, in order, as `'copyText: hello'` or `'readText'`.
  final List<String> calls = <String>[];

  String? _text;

  @override
  Future<void> copyText(String text) async {
    calls.add('copyText: $text');
    _text = text;
  }

  @override
  Future<String?> readText() async {
    calls.add('readText');
    return _text;
  }
}
