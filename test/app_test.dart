import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/main.dart';

/// What the failure screen says in English, as the message files spell it
/// (LANG-2).
const String englishStorageError =
    'The app cannot open its storage. Close it and open it again.';

/// The same message in Arabic (LANG-2).
const String arabicStorageError =
    'لا يمكن للتطبيق فتح مساحة التخزين. أغلق التطبيق ثم افتحه من جديد.';

/// The message for a write that failed. The failure screen must not borrow it:
/// nothing was being saved when the database would not open.
const String englishSaveError = 'Nothing was saved. Try again.';

/// The entry point's failure path. The shell's normal path — the providers, the
/// themes and the language — is driven through `QrScannerApp` in
/// `test/screens/home_screen_test.dart`.
void main() {
  testWidgets(
    'a database that will not open says the storage is unavailable, not that a '
    'save failed (LANG-2)',
    (WidgetTester tester) async {
      _deviceLanguages(tester, const <Locale>[Locale('en')]);

      await tester.pumpWidget(const DatabaseUnavailableApp());
      await tester.pumpAndSettle();

      expect(find.text(englishStorageError), findsOneWidget);
      expect(find.text(englishSaveError), findsNothing);
    },
  );

  testWidgets(
    'LANG-1: the failure screen follows the device language, down to a country '
    'the message files do not name',
    (WidgetTester tester) async {
      // There are no settings to read on this path, so the device list is the
      // only thing that can choose the language.
      _deviceLanguages(tester, const <Locale>[Locale('ar', 'EG')]);

      await tester.pumpWidget(const DatabaseUnavailableApp());
      await tester.pumpAndSettle();

      expect(find.text(arabicStorageError), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(arabicStorageError))),
        TextDirection.rtl,
      );
    },
  );

  testWidgets(
    'LANG-1: a device language the app does not have falls back to English on '
    'the failure screen',
    (WidgetTester tester) async {
      // Languages the app genuinely doesn't have. French and German used to
      // stand in here and became real ones in v0.11.0 (LANG-7); Swedish and
      // Czech are outside the twenty-one, so pick from there if this ever
      // needs changing again.
      _deviceLanguages(tester, const <Locale>[
        Locale('sv', 'SE'),
        Locale('cs'),
      ]);

      await tester.pumpWidget(const DatabaseUnavailableApp());
      await tester.pumpAndSettle();

      expect(find.text(englishStorageError), findsOneWidget);
      expect(find.text(arabicStorageError), findsNothing);
      expect(
        Directionality.of(tester.element(find.text(englishStorageError))),
        TextDirection.ltr,
      );
    },
  );
}

/// Makes the device report [locales] as its language list, most wanted first,
/// and puts the real list back when the test ends.
void _deviceLanguages(WidgetTester tester, List<Locale> locales) {
  tester.platformDispatcher.localesTestValue = locales;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}
