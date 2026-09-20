import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import 'harness_screens.dart';

/// The shared accessibility harness.
///
/// It runs the two reusable checks — every icon-only control carries a
/// screen-reader name (A11Y-1), and every control a finger can hit is at least
/// 48 × 48 dp (A11Y-2) — over every screen the app has today, in every language
/// the message files ship, at the system text size and at 200%.
///
/// A screen PR adds its screen to `harnessScreens` (or, for a screen that reads
/// `ScannerState`, to `scannerHarnessScreens` in `harness_screens.dart`) and is
/// covered here without touching this file.
///
/// The last group proves the checks bite: each one is handed a control that
/// breaks its rule, and must fail naming that control, so a later PR can act on
/// the message without a debugger.
void main() {
  for (final HarnessScreen screen in allHarnessScreens) {
    for (final Locale locale in accessibilityLocales) {
      for (final double textScale in harnessTextScales) {
        final String where =
            '${screen.name} in ${locale.languageCode} at '
            '${_scaleName(textScale)} text';

        testWidgets('A11Y-1: $where names every icon-only control', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            screen.build(),
            locale: locale,
            textScale: textScale,
          );

          expect(find.text(screen.textIn(locale)), findsOneWidget);
          await expectEveryIconHasALabel(tester);
        });

        testWidgets('A11Y-2: every control on $where is at least 48 x 48 dp', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            screen.build(),
            locale: locale,
            textScale: textScale,
          );

          expect(find.text(screen.textIn(locale)), findsOneWidget);
          await expectTapTargetsAtLeast48dp(tester);
        });
      }
    }
  }

  group('the checks themselves', () {
    testWidgets(
      'A11Y-1: an icon-only button with no name fails, and the failure names it',
      (WidgetTester tester) async {
        await pumpApp(tester, const _UnlabelledIconScreen());

        final TestFailure failure = await _failureFrom(
          () => expectEveryIconHasALabel(tester),
        );

        expect(failure.message, contains('A11Y-1'));
        expect(failure.message, contains('harness.unlabelled_icon'));
      },
    );

    testWidgets(
      'A11Y-2: a 24 x 24 control fails, and the failure names it and its size',
      (WidgetTester tester) async {
        await pumpApp(tester, const _TinyTapTargetScreen());

        final TestFailure failure = await _failureFrom(
          () => expectTapTargetsAtLeast48dp(tester),
        );

        expect(failure.message, contains('A11Y-2'));
        expect(failure.message, contains('harness.tiny_target'));
        expect(failure.message, contains('24.0 x 24.0 dp'));
      },
    );

    testWidgets(
      'A11Y-1, A11Y-2: a named 48 x 48 icon button passes both checks, whether '
      'the name comes from a tooltip or from the icon',
      (WidgetTester tester) async {
        await pumpApp(tester, const _NamedIconButtonsScreen());

        expect(find.byIcon(Icons.copy), findsOneWidget);
        expect(find.byIcon(Icons.share), findsOneWidget);
        await expectEveryIconHasALabel(tester);
        await expectTapTargetsAtLeast48dp(tester);
      },
    );
  });
}

/// `'1.0x'`, `'2.0x'`: the text size as a test name spells it.
String _scaleName(double textScale) => '${textScale.toStringAsFixed(1)}x';

/// Runs [check] and returns the failure it threw, so a test can read the
/// message the harness writes.
Future<TestFailure> _failureFrom(Future<void> Function() check) async {
  try {
    await check();
  } on TestFailure catch (failure) {
    return failure;
  }
  fail('the check passed, but it was given a control that breaks its rule');
}

/// The mistake A11Y-1 is about: a control that shows an icon and nothing else,
/// with no name for a screen reader to read.
class _UnlabelledIconScreen extends StatelessWidget {
  const _UnlabelledIconScreen();

  static const Key buttonKey = Key('harness.unlabelled_icon');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          key: buttonKey,
          onPressed: () {},
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}

/// The mistake A11Y-2 is about: something tappable that is too small to hit.
class _TinyTapTargetScreen extends StatelessWidget {
  const _TinyTapTargetScreen();

  static const Key targetKey = Key('harness.tiny_target');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          key: targetKey,
          onTap: () {},
          child: const SizedBox(
            width: 24,
            height: 24,
            child: ColoredBox(color: Color(0xFF3F51B5)),
          ),
        ),
      ),
    );
  }
}

/// Two icon-only buttons done right, so the checks are shown to pass what they
/// should: one named by its tooltip, one by the icon's own label.
class _NamedIconButtonsScreen extends StatelessWidget {
  const _NamedIconButtonsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              tooltip: 'Copy',
              onPressed: () {},
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share, semanticLabel: 'Share'),
            ),
          ],
        ),
      ),
    );
  }
}
