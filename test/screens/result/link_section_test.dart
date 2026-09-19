import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/link_callout.dart';
import 'package:qrscanner/screens/result/link_section.dart';
import 'package:qrscanner/screens/result/link_warning_sheet.dart';
import 'package:qrscanner/screens/scanner/payload_text.dart';
import 'package:qrscanner/state/result_state.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';
import 'section_test_helpers.dart';

/// Pumps [link]'s section inside the app shell, with its own
/// [SettingsState] so a test controls the RUN-8 callout independently of
/// [state] (`section_test_helpers.dart`'s `pumpSection` has no such knob).
///
/// [calloutSeen] defaults to already dismissed, so a test that isn't about
/// the callout doesn't have to see or work around it.
Future<void> _pumpLink(
  WidgetTester tester,
  ResultState state,
  Link link, {
  bool calloutSeen = true,
  Locale? locale,
  double textScale = 1,
}) => pumpApp(
  tester,
  ChangeNotifierProvider<ResultState>.value(
    value: state,
    child: Scaffold(
      body: SingleChildScrollView(child: LinkSection(link: link)),
    ),
  ),
  store: FakeKeyValueStore(
    calloutSeen
        ? <String, String>{SettingsState.linkCalloutSeenKey: '1'}
        : null,
  ),
  locale: locale,
  textScale: textScale,
);

void main() {
  group('LinkSection: a clean link (LINK-1, LINK-2, LINK-3, LINK-8)', () {
    testWidgets('shows the full URL, monospace and selectable, and the '
        'host, and Open as the primary action', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com/a/path', parsedType: ParsedType.url),
      );
      await _pumpLink(tester, state, state.payload as Link);

      expect(find.text('https://example.com/a/path'), findsOneWidget);
      expect(find.byKey(LinkSection.hostKey), findsOneWidget);
      expect(
        tester.widget<PayloadText>(find.byKey(LinkSection.hostKey)).text,
        'example.com',
      );
      final SelectableText urlText = tester.widget<SelectableText>(
        find.widgetWithText(SelectableText, 'https://example.com/a/path'),
      );
      expect(urlText.style?.fontFamily, 'monospace');
      final FilledButton primary = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Open'),
      );
      expect(primary.onPressed, isNotNull);
      expect(find.text('Review'), findsNothing);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('Open calls the fake LinkOpener with the exact Uri (LINK-8)', (
      WidgetTester tester,
    ) async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com/a?q=1', parsedType: ParsedType.url),
        linkOpener: linkOpener,
      );
      await _pumpLink(tester, state, state.payload as Link);

      await tester.tap(find.widgetWithText(FilledButton, 'Open'));
      await tester.pumpAndSettle();

      expect(linkOpener.openedUrls, <Uri>[
        Uri.parse('https://example.com/a?q=1'),
      ]);
    });

    testWidgets('an app-store link gets exactly the same Open flow (RES-11)', (
      WidgetTester tester,
    ) async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = resultStateFor(
        outcomeFor(
          'https://play.google.com/store/apps/details?id=com.example.app',
          parsedType: ParsedType.url,
        ),
        linkOpener: linkOpener,
      );
      await _pumpLink(tester, state, state.payload as Link);

      expect(find.widgetWithText(FilledButton, 'Open'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Open'));
      await tester.pumpAndSettle();

      expect(linkOpener.openedUrls, <Uri>[
        Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.app',
        ),
      ]);
    });

    testWidgets('RES-14: with no browser, Open is disabled with a reason', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com', parsedType: ParsedType.url),
        linkOpener: NoopLinkOpener(canOpen: false),
      );
      await _pumpLink(tester, state, state.payload as Link);
      await tester.pumpAndSettle();

      final FilledButton primary = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Open'),
      );
      expect(primary.onPressed, isNull);
      expect(find.text('No browser is installed.'), findsOneWidget);
    });
  });

  group('LinkSection: a link with checks (LINK-3, LINK-4)', () {
    testWidgets(
      'shows Review instead of Open, and opens a sheet listing exactly '
      "this link's checks",
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(
            'http://user@192.168.1.1:8080/',
            parsedType: ParsedType.url,
          ),
        );
        await _pumpLink(tester, state, state.payload as Link);

        expect(find.text('Open'), findsNothing);
        await tester.tap(find.widgetWithText(FilledButton, 'Review'));
        await tester.pumpAndSettle();

        expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);
        expect(
          find.text('The address is a raw IP number, not a name'),
          findsOneWidget,
        );
        expect(
          find.text('It contains a user name before the site name'),
          findsOneWidget,
        );
        expect(find.text("It isn't encrypted (http)"), findsOneWidget);
        expect(find.text('It uses an unusual port'), findsOneWidget);
        // This link isn't over 200 characters, so the long-URL line is not
        // one of "exactly this link's checks".
        expect(find.text("It's unusually long"), findsNothing);
      },
    );

    testWidgets('Open anyway opens the link and closes the sheet', (
      WidgetTester tester,
    ) async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = resultStateFor(
        outcomeFor('http://example.com/', parsedType: ParsedType.url),
        linkOpener: linkOpener,
      );
      await _pumpLink(tester, state, state.payload as Link);
      await tester.tap(find.widgetWithText(FilledButton, 'Review'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LinkWarningSheet.openAnywayButtonKey));
      await tester.pumpAndSettle();

      expect(linkOpener.openedUrls, <Uri>[Uri.parse('http://example.com/')]);
      expect(find.byKey(LinkWarningSheet.sheetKey), findsNothing);
    });

    testWidgets('Copy without opening copies the link and never opens it', (
      WidgetTester tester,
    ) async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final ResultState state = resultStateFor(
        outcomeFor('http://example.com/', parsedType: ParsedType.url),
        clipboard: clipboard,
        linkOpener: linkOpener,
      );
      await _pumpLink(tester, state, state.payload as Link);
      await tester.tap(find.widgetWithText(FilledButton, 'Review'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(LinkWarningSheet.copyWithoutOpeningButtonKey),
      );
      await tester.pumpAndSettle();

      expect(clipboard.calls, <String>['copyText: http://example.com/']);
      // RES-14's own availability probe (canOpenWebLinks) is expected;
      // what matters for LINK-4 is that the link itself was never opened.
      expect(linkOpener.openedUrls, isEmpty);
      expect(find.byKey(LinkWarningSheet.sheetKey), findsNothing);
    });

    testWidgets('LINK-4: the sheet stays open until the user acts — no tap '
        'outside, no back gesture', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('http://example.com/', parsedType: ParsedType.url),
      );
      await _pumpLink(tester, state, state.payload as Link);
      await tester.tap(find.widgetWithText(FilledButton, 'Review'));
      await tester.pumpAndSettle();

      expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);

      // A tap in the barrier, well outside the sheet's own content.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);

      // The system back gesture.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);
    });

    testWidgets('RES-14: with no browser, Review is disabled with a reason', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('http://example.com/', parsedType: ParsedType.url),
        linkOpener: NoopLinkOpener(canOpen: false),
      );
      await _pumpLink(tester, state, state.payload as Link);
      await tester.pumpAndSettle();

      final FilledButton primary = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Review'),
      );
      expect(primary.onPressed, isNull);
      expect(find.text('No browser is installed.'), findsOneWidget);
    });
  });

  group('LinkSection: a blocked link (LINK-5)', () {
    testWidgets('shows the URL and a blocked notice, Copy only (no Share: it could open elsewhere), and '
        'never calls the LinkOpener', (WidgetTester tester) async {
      final NoopLinkOpener linkOpener = NoopLinkOpener();
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = resultStateFor(
        outcomeFor('javascript:alert(1)', parsedType: ParsedType.url),
        linkOpener: linkOpener,
        clipboard: clipboard,
      );
      await _pumpLink(tester, state, state.payload as Link);

      expect(find.text('javascript:alert(1)'), findsOneWidget);
      expect(find.byKey(LinkSection.blockedNoticeKey), findsOneWidget);
      expect(
        find.text("javascript links can't be opened here."),
        findsOneWidget,
      );
      expect(find.text('Open'), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.byKey(LinkSection.hostKey), findsNothing);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
      await tester.pumpAndSettle();

      expect(clipboard.calls, <String>['copyText: javascript:alert(1)']);
      expect(linkOpener.calls, isEmpty);
    });
  });

  group('RUN-8: the one-time link-check callout', () {
    const String calloutMessage =
        'This app checks links before opening them, so you can see where '
        'they lead first.';

    testWidgets('shows above the actions on the first link result ever '
        'shown', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com', parsedType: ParsedType.url),
      );
      await _pumpLink(tester, state, state.payload as Link, calloutSeen: false);

      expect(find.text(calloutMessage), findsOneWidget);
    });

    testWidgets(
      'one tap dismisses it for good, and it stays hidden on the next '
      'link result over the same store',
      (WidgetTester tester) async {
        final FakeKeyValueStore store = FakeKeyValueStore();
        final SettingsState settings = SettingsState(store);
        await settings.load();
        final ResultState state = resultStateFor(
          outcomeFor('https://example.com', parsedType: ParsedType.url),
        );
        await pumpApp(
          tester,
          ChangeNotifierProvider<ResultState>.value(
            value: state,
            child: Scaffold(
              body: SingleChildScrollView(
                child: LinkSection(link: state.payload as Link),
              ),
            ),
          ),
          settings: settings,
        );
        expect(find.text(calloutMessage), findsOneWidget);

        await tester.tap(find.byKey(LinkCallout.dismissButtonKey));
        await tester.pumpAndSettle();

        expect(find.text(calloutMessage), findsNothing);

        // A brand-new ResultState (as a fresh result screen would build),
        // and a brand-new SettingsState loaded from the same store (as the
        // app's own single long-lived SettingsState would already reflect).
        final SettingsState reloaded = SettingsState(store);
        await reloaded.load();
        final ResultState nextState = resultStateFor(
          outcomeFor('https://example.org', parsedType: ParsedType.url),
        );
        await pumpApp(
          tester,
          ChangeNotifierProvider<ResultState>.value(
            value: nextState,
            child: Scaffold(
              body: SingleChildScrollView(
                child: LinkSection(link: nextState.payload as Link),
              ),
            ),
          ),
          settings: reloaded,
        );

        expect(find.text(calloutMessage), findsNothing);
      },
    );

    testWidgets('never shows for a blocked link (LINK-5)', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('javascript:alert(1)', parsedType: ParsedType.url),
      );
      await _pumpLink(tester, state, state.payload as Link, calloutSeen: false);

      expect(find.text(calloutMessage), findsNothing);
    });
  });

  group('LANG-5: Arabic RTL, URL and host stay left to right', () {
    testWidgets('a clean link', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com/a', parsedType: ParsedType.url),
      );
      await _pumpLink(
        tester,
        state,
        state.payload as Link,
        locale: const Locale('ar'),
      );

      final PayloadText urlPayload = tester.widget<PayloadText>(
        find.widgetWithText(PayloadText, 'https://example.com/a'),
      );
      expect(urlPayload.direction, TextDirection.ltr);
      final PayloadText hostPayload = tester.widget<PayloadText>(
        find.byKey(LinkSection.hostKey),
      );
      expect(hostPayload.direction, TextDirection.ltr);
    });
  });
}
