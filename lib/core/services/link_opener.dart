/// How a link was handed off (LINK-8).
enum LinkOpenOutcome {
  /// Opened in a Custom Tab.
  customTab,

  /// Custom Tabs wasn't available, so the default browser took it.
  browser,

  /// No installed app can show a web link, so the action shows disabled with a
  /// reason instead (RES-14).
  noHandler,

  /// The hand-off failed.
  failed,
}

/// Opening web links outside the app.
///
/// A link always goes to Custom Tabs, falling back to the default browser, and
/// never to an in-app WebView or a bare launch (LINK-8). The caller opens one
/// only after the user has seen where it leads (LINK-3, LINK-4), and never for a
/// blocked scheme (LINK-5). Settings uses the same route for the privacy policy
/// (SET-6).
abstract class LinkOpener {
  /// Opens [url] in a Custom Tab.
  ///
  /// [url] is an `http` or `https` URL that already passed the link checks.
  Future<LinkOpenOutcome> open(Uri url);

  /// Whether any installed app can show a web link, so an Open action can be
  /// shown disabled with a one-line reason instead of failing on tap (RES-14).
  Future<bool> canOpenWebLinks();
}

/// A [LinkOpener] that opens nothing.
///
/// It records every URL in [openedUrls] and every call in [calls], and reports
/// [outcome] (a Custom Tab by default) so a result screen's flow can be driven
/// without leaving the test.
class NoopLinkOpener implements LinkOpener {
  NoopLinkOpener({
    this.outcome = LinkOpenOutcome.customTab,
    this.canOpen = true,
  });

  /// Every call made, in order, such as `'open: https://example.com'`.
  final List<String> calls = <String>[];

  /// The URLs the app asked to open, in order.
  final List<Uri> openedUrls = <Uri>[];

  final LinkOpenOutcome outcome;

  final bool canOpen;

  @override
  Future<LinkOpenOutcome> open(Uri url) async {
    calls.add('open: $url');
    openedUrls.add(url);
    return outcome;
  }

  @override
  Future<bool> canOpenWebLinks() async {
    calls.add('canOpenWebLinks');
    return canOpen;
  }
}
