import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/screens/manual_entry_screen.dart';
import 'package:qrscanner/screens/scanner/scanner_layout.dart';

import '../helpers/test_app.dart';

void main() {
  group('ManualEntryScreen (SCAN-12)', () {
    testWidgets(
      'SCAN-12: a multi-line field and Scan, which stays disabled until the '
      'field holds more than whitespace',
      (WidgetTester tester) async {
        await pumpApp(tester, const ManualEntryScreen());

        expect(find.text('Type a code'), findsOneWidget);
        expect(find.text('Code content'), findsOneWidget);
        expect(find.text('Scan'), findsOneWidget);
        final TextField field = tester.widget<TextField>(
          find.byKey(ManualEntryScreen.fieldKey),
        );
        expect(field.maxLines, greaterThan(1));
        expect(_scanEnabled(tester), isFalse);

        await tester.enterText(find.byKey(ManualEntryScreen.fieldKey), '   ');
        await tester.pump();
        expect(_scanEnabled(tester), isFalse);

        await tester.enterText(
          find.byKey(ManualEntryScreen.fieldKey),
          'https://example.com',
        );
        await tester.pump();
        expect(_scanEnabled(tester), isTrue);

        await tester.enterText(find.byKey(ManualEntryScreen.fieldKey), '');
        await tester.pump();
        expect(_scanEnabled(tester), isFalse);
      },
    );

    testWidgets('SCAN-12: Scan is the largest control on the screen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, const ManualEntryScreen());

      final Size scan = tester.getSize(find.byKey(ManualEntryScreen.scanKey));
      expect(
        scan.height,
        greaterThanOrEqualTo(ScannerLayout.primaryActionHeight),
      );
      expect(
        scan.width,
        tester.getSize(find.byKey(ManualEntryScreen.fieldKey)).width,
      );
    });

    testWidgets(
      'SCAN-12: Scan closes the screen and hands the typed text, line breaks '
      'and all, to whoever opened it',
      (WidgetTester tester) async {
        String? returned;
        await pumpApp(
          tester,
          _Host(onResult: (String? text) => returned = text),
        );
        await tester.tap(find.byKey(_Host.openKey));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(ManualEntryScreen.fieldKey),
          'first line\nsecond line',
        );
        await tester.pump();
        await tester.tap(find.byKey(ManualEntryScreen.scanKey));
        await tester.pumpAndSettle();

        expect(find.byType(ManualEntryScreen), findsNothing);
        expect(returned, 'first line\nsecond line');
      },
    );

    testWidgets('SCAN-12: backing out hands nothing back', (
      WidgetTester tester,
    ) async {
      String? returned = 'untouched';
      await pumpApp(tester, _Host(onResult: (String? text) => returned = text));
      await tester.tap(find.byKey(_Host.openKey));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(ManualEntryScreen.fieldKey), 'draft');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ManualEntryScreen), findsNothing);
      expect(returned, isNull);
    });

    testWidgets(
      'LANG-5: in Arabic the label is Arabic and the screen right to left, '
      'while a code is typed left to right',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          const ManualEntryScreen(),
          locale: const Locale('ar'),
        );

        expect(find.text('كتابة رمز'), findsOneWidget);
        expect(find.text('محتوى الرمز'), findsOneWidget);
        expect(find.text('مسح'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(ManualEntryScreen))),
          TextDirection.rtl,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(ManualEntryScreen.fieldKey))
              .textDirection,
          TextDirection.ltr,
        );
      },
    );
  });
}

/// Whether Scan can be tapped.
bool _scanEnabled(WidgetTester tester) => tester
    .widget<ButtonStyleButton>(find.byKey(ManualEntryScreen.scanKey))
    .enabled;

/// A screen that opens typed entry the way the scanner does, and reports what
/// came back.
class _Host extends StatelessWidget {
  const _Host({required this.onResult});

  static const Key openKey = Key('test.open');

  final ValueChanged<String?> onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: openKey,
          onPressed: () async {
            onResult(
              await Navigator.of(context).push(ManualEntryScreen.route()),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}
