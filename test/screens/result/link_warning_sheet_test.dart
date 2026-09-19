import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/link_check.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/screens/result/link_warning_sheet.dart';
import 'package:qrscanner/screens/scanner/payload_text.dart';

import '../../helpers/test_app.dart';

/// Pumps a plain screen with one button that opens the sheet
/// ([showLinkWarningSheet] itself, not the bare widget), so a test can
/// drive the same tap-outside, back-gesture and button behaviour the real
/// result screen gets.
Future<void> _pumpTrigger(
  WidgetTester tester, {
  required Link link,
  required List<LinkCheck> checks,
  required Future<void> Function() onCopyWithoutOpening,
  required Future<void> Function() onOpenAnyway,
  Locale? locale,
  double textScale = 1,
}) => pumpApp(
  tester,
  Scaffold(
    body: Builder(
      builder: (BuildContext context) => ElevatedButton(
        // At least 48dp even though the modal barrier covers it once the
        // sheet is open: A11Y-2's harness sweep below measures every
        // tappable control it finds, this trigger included.
        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: () => showLinkWarningSheet(
          context,
          link: link,
          checks: checks,
          onCopyWithoutOpening: onCopyWithoutOpening,
          onOpenAnyway: onOpenAnyway,
        ),
        child: const Text('open the sheet'),
      ),
    ),
  ),
  locale: locale,
  textScale: textScale,
);

void main() {
  group('showLinkWarningSheet (LINK-4)', () {
    testWidgets(
      'lists one line per check, in order, and repeats the host and URL',
      (WidgetTester tester) async {
        await _pumpTrigger(
          tester,
          link: Link('http://user@192.168.1.1:8080/x'),
          checks: const <LinkCheck>[
            LinkCheck.ipAddressHost,
            LinkCheck.userinfo,
            LinkCheck.insecureScheme,
            LinkCheck.nonDefaultPort,
          ],
          onCopyWithoutOpening: () async {},
          onOpenAnyway: () async {},
        );
        await tester.tap(find.text('open the sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Before you open this link'), findsOneWidget);
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
        expect(find.text("It's unusually long"), findsNothing);
        expect(find.text('192.168.1.1'), findsOneWidget);
        expect(find.text('http://user@192.168.1.1:8080/x'), findsOneWidget);
        expect(find.text('Copy without opening'), findsOneWidget);
        expect(find.text('Open anyway'), findsOneWidget);
      },
    );

    testWidgets('A11Y-6: every check line pairs an icon with its text', (
      WidgetTester tester,
    ) async {
      await _pumpTrigger(
        tester,
        link: Link('http://example.com/'),
        checks: const <LinkCheck>[LinkCheck.insecureScheme, LinkCheck.longUrl],
        onCopyWithoutOpening: () async {},
        onOpenAnyway: () async {},
      );
      await tester.tap(find.text('open the sheet'));
      await tester.pumpAndSettle();

      // Both plain-language lines are on screen (so this is testing the two
      // real checks, not an empty sheet)...
      expect(find.text("It isn't encrypted (http)"), findsOneWidget);
      expect(find.text("It's unusually long"), findsOneWidget);
      // ...each paired with its own coloured icon (never colour alone,
      // A11Y-6): one per triggered check, distinct from the two buttons'
      // icons, which carry no colour of their own (they take the button's).
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Icon && widget.color != null,
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('Copy without opening runs the callback and closes the sheet, '
        'without running Open anyway', (WidgetTester tester) async {
      var copied = 0;
      var opened = 0;
      await _pumpTrigger(
        tester,
        link: Link('http://example.com/'),
        checks: const <LinkCheck>[LinkCheck.insecureScheme],
        onCopyWithoutOpening: () async {
          copied++;
        },
        onOpenAnyway: () async {
          opened++;
        },
      );
      await tester.tap(find.text('open the sheet'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(LinkWarningSheet.copyWithoutOpeningButtonKey),
      );
      await tester.pumpAndSettle();

      expect(copied, 1);
      expect(opened, 0);
      expect(find.byKey(LinkWarningSheet.sheetKey), findsNothing);
    });

    testWidgets('Open anyway runs the callback and closes the sheet, without '
        'running Copy without opening', (WidgetTester tester) async {
      var copied = 0;
      var opened = 0;
      await _pumpTrigger(
        tester,
        link: Link('http://example.com/'),
        checks: const <LinkCheck>[LinkCheck.insecureScheme],
        onCopyWithoutOpening: () async {
          copied++;
        },
        onOpenAnyway: () async {
          opened++;
        },
      );
      await tester.tap(find.text('open the sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LinkWarningSheet.openAnywayButtonKey));
      await tester.pumpAndSettle();

      expect(opened, 1);
      expect(copied, 0);
      expect(find.byKey(LinkWarningSheet.sheetKey), findsNothing);
    });

    testWidgets('the two buttons are the same size (LINK-4)', (
      WidgetTester tester,
    ) async {
      await _pumpTrigger(
        tester,
        link: Link('http://example.com/'),
        checks: const <LinkCheck>[LinkCheck.insecureScheme],
        onCopyWithoutOpening: () async {},
        onOpenAnyway: () async {},
      );
      await tester.tap(find.text('open the sheet'));
      await tester.pumpAndSettle();

      final Size copySize = tester.getSize(
        find.byKey(LinkWarningSheet.copyWithoutOpeningButtonKey),
      );
      final Size openSize = tester.getSize(
        find.byKey(LinkWarningSheet.openAnywayButtonKey),
      );
      expect(copySize, openSize);
    });

    testWidgets(
      'LINK-4: never closes by itself — no tap outside, no back gesture',
      (WidgetTester tester) async {
        await _pumpTrigger(
          tester,
          link: Link('http://example.com/'),
          checks: const <LinkCheck>[LinkCheck.insecureScheme],
          onCopyWithoutOpening: () async {},
          onOpenAnyway: () async {},
        );
        await tester.tap(find.text('open the sheet'));
        await tester.pumpAndSettle();

        expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);

        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);
      },
    );

    testWidgets('LANG-5: the host and URL stay left to right in Arabic', (
      WidgetTester tester,
    ) async {
      await _pumpTrigger(
        tester,
        link: Link('http://example.com/a'),
        checks: const <LinkCheck>[LinkCheck.insecureScheme],
        onCopyWithoutOpening: () async {},
        onOpenAnyway: () async {},
        locale: const Locale('ar'),
      );
      await tester.tap(find.text('open the sheet'));
      await tester.pumpAndSettle();

      final PayloadText hostPayload = tester.widget<PayloadText>(
        find.widgetWithText(PayloadText, 'example.com'),
      );
      expect(hostPayload.direction, TextDirection.ltr);
      final PayloadText urlPayload = tester.widget<PayloadText>(
        find.widgetWithText(PayloadText, 'http://example.com/a'),
      );
      expect(urlPayload.direction, TextDirection.ltr);
    });

    for (final Locale locale in harnessLocales) {
      for (final double textScale in harnessTextScales) {
        final String where =
            'the warning sheet in ${locale.languageCode} at '
            '${textScale.toStringAsFixed(1)}x text';

        testWidgets('A11Y-1, A11Y-2, A11Y-4: $where', (
          WidgetTester tester,
        ) async {
          await _pumpTrigger(
            tester,
            link: Link('http://user@192.168.1.1:8080/${'a' * 180}'),
            checks: const <LinkCheck>[
              LinkCheck.ipAddressHost,
              LinkCheck.userinfo,
              LinkCheck.insecureScheme,
              LinkCheck.nonDefaultPort,
              LinkCheck.longUrl,
            ],
            onCopyWithoutOpening: () async {},
            onOpenAnyway: () async {},
            locale: locale,
            textScale: textScale,
          );
          await tester.tap(find.text('open the sheet'));
          await tester.pumpAndSettle();

          expect(find.byKey(LinkWarningSheet.sheetKey), findsOneWidget);
          await expectEveryIconHasALabel(tester);
          await expectTapTargetsAtLeast48dp(tester);
          expectNoOverflow(tester);
        });
      }
    }
  });
}
