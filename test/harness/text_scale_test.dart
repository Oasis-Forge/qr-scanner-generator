import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// The shared text-size harness.
///
/// A11Y-4 and LANG-6 ask the same thing from two directions: on a phone-size
/// screen, in every language, at the system text size and at 200%, nothing the
/// user needs may be clipped. This renders every screen the app has today in
/// every combination and fails when a box overflowed.
///
/// A screen PR adds its screen to `harnessScreens` and is covered here without
/// touching this file.
///
/// The last group proves the check bites: it is handed a row that cannot fit the
/// phone, and must fail naming that row.
void main() {
  for (final HarnessScreen screen in harnessScreens) {
    for (final Locale locale in harnessLocales) {
      for (final double textScale in harnessTextScales) {
        testWidgets(
          'A11Y-4, LANG-6: ${screen.name} in ${locale.languageCode} at '
          '${_scaleName(textScale)} text fits a phone screen',
          (WidgetTester tester) async {
            await pumpApp(
              tester,
              screen.build(),
              locale: locale,
              textScale: textScale,
            );

            // The screen really drew its content in this language, so the
            // overflow check is not passing over a blank frame.
            expect(
              find.text(screen.textIn(locale.languageCode)),
              findsOneWidget,
            );
            expectNoOverflow(tester);
          },
        );
      }
    }
  }

  group('the check itself', () {
    testWidgets(
      'A11Y-4, LANG-6: a row wider than the phone fails, and the failure names '
      'the row and the screen it did not fit',
      (WidgetTester tester) async {
        await pumpApp(tester, const _TooWideScreen());

        // Painting an overflow also reports it to the framework. Taking it here
        // leaves this test failing only if the check below misses the overflow.
        expect(tester.takeException(), isFlutterError);

        final TestFailure failure = _failureFrom(
          () => expectNoOverflow(tester),
        );

        expect(failure.message, contains('A11Y-4, LANG-6'));
        expect(failure.message, contains('harness.too_wide_row'));
        expect(failure.message, contains('411.0 x 731.0 dp screen'));
      },
    );

    testWidgets(
      'A11Y-4, LANG-6: a row that wraps instead of overflowing passes, even at '
      '2.0x text',
      (WidgetTester tester) async {
        await pumpApp(tester, const _WrappingScreen(), textScale: 2);

        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);
        expectNoOverflow(tester);
      },
    );
  });
}

/// `'1.0x'`, `'2.0x'`: the text size as a test name spells it.
String _scaleName(double textScale) => '${textScale.toStringAsFixed(1)}x';

/// Runs [check] and returns the failure it threw, so a test can read the
/// message the harness writes.
TestFailure _failureFrom(void Function() check) {
  try {
    check();
  } on TestFailure catch (failure) {
    return failure;
  }
  fail('the check passed, but it was given a screen that overflows');
}

/// The mistake A11Y-4 and LANG-6 are about: a row of fixed boxes that is wider
/// than the phone it is drawn on, so part of it can never be seen.
class _TooWideScreen extends StatelessWidget {
  const _TooWideScreen();

  static const Key rowKey = Key('harness.too_wide_row');

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          key: rowKey,
          children: <Widget>[
            SizedBox(width: 400, height: 40),
            SizedBox(width: 400, height: 40),
          ],
        ),
      ),
    );
  }
}

/// The same content done right: it wraps onto another line instead of running
/// off the screen, which is what a screen has to do at 2.0× text.
class _WrappingScreen extends StatelessWidget {
  const _WrappingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Wrap(
          children: <Widget>[
            SizedBox(width: 300, child: Text('One')),
            SizedBox(width: 300, child: Text('Two')),
          ],
        ),
      ),
    );
  }
}
