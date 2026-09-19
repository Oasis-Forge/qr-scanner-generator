import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import '../link_opener.dart';

/// `android.intent.action.VIEW` on an `https:` URI with no host: enough for
/// `AndroidIntent.canResolveActivity` to say whether any app at all can show
/// a web link, matching the manifest's own `<queries>` entry for this
/// action and scheme.
const AndroidIntent _webViewProbe = AndroidIntent(
  action: 'android.intent.action.VIEW',
  data: 'https://',
);

/// [LinkOpener] over `flutter_custom_tabs` (LINK-8).
///
/// [open] always asks for a Custom Tab in [themeColor]; on Android that is
/// `androidx.browser.customtabs.CustomTabsIntent`, which itself falls back
/// to the device's default browser when no app offers the Custom Tabs
/// service, with no extra code here and no bare `ACTION_VIEW` launch of our
/// own. The plugin has no way to report which of the two actually happened,
/// so a launch that doesn't throw is read as [LinkOpenOutcome.customTab];
/// [LinkOpenOutcome.browser] stays for a fake to stand in for the fallback
/// once a caller needs to word it differently.
///
/// Reusable core (`CLAUDE.md`): this imports nothing from the app, only
/// pub packages, so it and [LinkOpener] can be shared with the portfolio's
/// other apps. [themeColor] is passed in rather than read from `AppTheme`,
/// since the entry point builds this before the widget tree — and any
/// dynamic colour it carries — exists.
class CustomTabsLinkOpener implements LinkOpener {
  const CustomTabsLinkOpener({required this.themeColor});

  /// The toolbar colour a Custom Tab opens in.
  final Color themeColor;

  @override
  Future<LinkOpenOutcome> open(Uri url) async {
    assert(
      url.scheme == 'http' || url.scheme == 'https',
      'CustomTabsLinkOpener.open takes only an http(s) URL that already '
      'passed the link checks (LINK-1, LINK-5); a blocked scheme is never '
      'launched, bare or otherwise.',
    );
    try {
      await launchUrl(
        url,
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: themeColor,
          ),
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
      );
      return LinkOpenOutcome.customTab;
    } on Object {
      // [canOpenWebLinks] is what earns this a [LinkOpenOutcome.noHandler]
      // and a disabled action before the tap (RES-14); a throw here, past
      // that check, is the hand-off going wrong instead.
      return LinkOpenOutcome.failed;
    }
  }

  @override
  Future<bool> canOpenWebLinks() async {
    try {
      return await _webViewProbe.canResolveActivity() ?? false;
    } on Object {
      return false;
    }
  }
}
