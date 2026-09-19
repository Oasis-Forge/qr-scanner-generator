import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/main.dart';
import 'package:qrscanner/screens/app_shell.dart';
import 'package:qrscanner/screens/settings_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../helpers/fake_stores.dart';

/// The Settings tab, driven through the shell that ships (`QrScannerApp`): the
/// providers, the language resolution and the themes are the real ones, and
/// the test reaches Settings the way the user does, from the bottom bar
/// (SCAN-1).
void main() {
  group('SettingsScreen', () {
    testWidgets('LANG-2: shows both switchers in English', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      // "System default" is one choice in each switcher.
      expect(find.text('System default'), findsNWidgets(2));
      // The screen's title and its bottom-bar label.
      expect(find.text('Settings'), findsNWidgets(2));
    });

    testWidgets(
      'LANG-1, LANG-5: a stored Arabic language shows Arabic text and lays the '
      'screen out right to left',
      (WidgetTester tester) async {
        await _pumpSettings(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'ar'},
        );

        expect(find.text('Theme'), findsNothing);
        expect(find.text('المظهر'), findsOneWidget);
        expect(find.text('فاتح'), findsOneWidget);
        expect(find.text('داكن'), findsOneWidget);
        expect(find.text('اللغة'), findsOneWidget);
        expect(_directionOnScreen(tester), TextDirection.rtl);
      },
    );

    testWidgets(
      'SET-1: choosing Dark stores the theme and repaints the app dark',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpSettings(tester);
        expect(_brightnessOnScreen(tester), Brightness.light);

        await tester.tap(find.byKey(SettingsScreen.darkThemeKey));
        await tester.pumpAndSettle();

        expect(harness.settings.themeMode, ThemeMode.dark);
        expect(harness.store.writes, contains('set settings.theme_mode=dark'));
        expect(_brightnessOnScreen(tester), Brightness.dark);
        // The chosen option is not colour alone: it carries a tick (A11Y-6).
        expect(
          find.descendant(
            of: find.byKey(SettingsScreen.darkThemeKey),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'LANG-1: choosing العربية stores the language and the app follows it '
      'without a restart',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpSettings(tester);
        expect(find.text('Language'), findsOneWidget);

        await tester.tap(find.byKey(SettingsScreen.arabicLanguageKey));
        await tester.pumpAndSettle();

        expect(harness.settings.localeOverride, const Locale('ar'));
        expect(harness.store.writes, contains('set settings.language=ar'));
        expect(find.text('اللغة'), findsOneWidget);
        // The bottom bar follows too, and Settings stays the open tab.
        expect(find.text('الإعدادات'), findsNWidgets(2));
        expect(_directionOnScreen(tester), TextDirection.rtl);
      },
    );

    testWidgets(
      'LANG-1: choosing System default removes the stored language, so the '
      'device language is followed again',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpSettings(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'ar'},
          deviceLanguages: const <Locale>[Locale('en')],
        );

        await tester.tap(find.byKey(SettingsScreen.systemLanguageKey));
        await tester.pumpAndSettle();

        expect(harness.settings.localeOverride, isNull);
        expect(harness.store.writes, contains('remove settings.language'));
        expect(
          harness.store.values.containsKey(SettingsState.localeKey),
          isFalse,
        );
        expect(find.text('Language'), findsOneWidget);
      },
    );

    testWidgets(
      'LANG-1: a device language the app does not have opens the app in '
      'English, not in the first language the message files happen to list',
      (WidgetTester tester) async {
        // The message files list Arabic first, so Flutter's own fallback would
        // hand this phone a right-to-left Arabic app.
        await _pumpSettings(
          tester,
          deviceLanguages: const <Locale>[Locale('fr', 'FR'), Locale('de')],
        );

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('اللغة'), findsNothing);
        expect(_directionOnScreen(tester), TextDirection.ltr);
      },
    );

    testWidgets(
      'LANG-1: a device set to a country the message files do not name still '
      'gets that language',
      (WidgetTester tester) async {
        await _pumpSettings(
          tester,
          deviceLanguages: const <Locale>[Locale('ar', 'EG')],
        );

        expect(find.text('اللغة'), findsOneWidget);
        expect(find.text('Language'), findsNothing);
        expect(_directionOnScreen(tester), TextDirection.rtl);
      },
    );

    testWidgets(
      'LANG-1: the language chosen in Settings wins over the device language '
      'list',
      (WidgetTester tester) async {
        // Arabic is what the device asks for first, and the app has it, so only
        // the stored choice can put the app into English.
        await _pumpSettings(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'en'},
          deviceLanguages: const <Locale>[Locale('ar'), Locale('en')],
        );

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('اللغة'), findsNothing);
        expect(_directionOnScreen(tester), TextDirection.ltr);
      },
    );

    testWidgets('A11Y-1: every switcher option carries its own screen-reader '
        'label', (WidgetTester tester) async {
      // Released inside the test body: the framework checks for live handles
      // before tearDowns run.
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pumpSettings(tester);

      const List<(Key, String)> expected = <(Key, String)>[
        (SettingsScreen.systemThemeKey, 'System default'),
        (SettingsScreen.lightThemeKey, 'Light'),
        (SettingsScreen.darkThemeKey, 'Dark'),
        (SettingsScreen.systemLanguageKey, 'System default'),
        (SettingsScreen.englishLanguageKey, 'English'),
        (SettingsScreen.arabicLanguageKey, 'العربية'),
      ];
      for (final (Key key, String label) in expected) {
        expect(
          tester.getSemantics(find.byKey(key)),
          isSemantics(label: label, isButton: true, hasTapAction: true),
          reason: '$label must be announced by its own name',
        );
      }
      // The chosen option announces that it is the chosen one.
      expect(
        tester.getSemantics(find.byKey(SettingsScreen.systemThemeKey)),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.byKey(SettingsScreen.darkThemeKey)),
        isSemantics(isSelected: false),
      );
      semantics.dispose();
    });

    testWidgets('A11Y-2: every switcher option is at least 48 x 48 dp', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      const List<Key> options = <Key>[
        SettingsScreen.systemThemeKey,
        SettingsScreen.lightThemeKey,
        SettingsScreen.darkThemeKey,
        SettingsScreen.systemLanguageKey,
        SettingsScreen.englishLanguageKey,
        SettingsScreen.arabicLanguageKey,
      ];
      for (final Key option in options) {
        final Size size = tester.getSize(find.byKey(option));
        expect(
          size.width,
          greaterThanOrEqualTo(AppTheme.minTapTargetSize),
          reason: '$option is too narrow to tap',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(AppTheme.minTapTargetSize),
          reason: '$option is too short to tap',
        );
      }
    });

    testWidgets(
      'a write that fails changes nothing and says so in the app language',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpSettings(tester);
        harness.store.failingKeys.add(SettingsState.themeModeKey);

        await tester.tap(find.byKey(SettingsScreen.darkThemeKey));
        await tester.pumpAndSettle();

        expect(harness.settings.themeMode, ThemeMode.system);
        expect(_brightnessOnScreen(tester), Brightness.light);
        expect(find.text('Nothing was saved. Try again.'), findsOneWidget);

        // Let the snackbar time out, so no timer is left pending.
        await tester.pumpAndSettle(const Duration(seconds: 5));
      },
    );
  });
}

/// What a test needs to look behind the screen: the state it drives and the
/// rows the store was told to write.
class _Harness {
  const _Harness({required this.settings, required this.store});

  final SettingsState settings;
  final FakeKeyValueStore store;
}

/// Builds the real app shell over an in-memory store and the no-op services,
/// then opens the Settings tab from the bottom bar, so a test drives the widget
/// tree that ships.
Future<_Harness> _pumpSettings(
  WidgetTester tester, {
  Map<String, String>? stored,
  List<Locale>? deviceLanguages,
}) async {
  if (deviceLanguages != null) {
    // Set before the first frame, so the shell resolves the language from this
    // list the way it would at launch, and put the real list back afterwards.
    tester.platformDispatcher.localesTestValue = deviceLanguages;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final FakeKeyValueStore store = FakeKeyValueStore(stored);
  final SettingsState settings = SettingsState(store);
  await settings.load();
  final SuccessCounts successCounts = SuccessCounts(store);
  await successCounts.load();
  // Nothing here reads records; the DAO is here because the shell provides
  // it, and its database is never opened.
  final RecordDao records = RecordDao(
    AppDatabase(
      directory: 'unopened-in-a-widget-test',
      runner: MigrationRunner(migrationSteps),
      // Never opened, so no native library is loaded.
      databaseFactory: databaseFactoryFfi,
    ),
  );

  await tester.pumpWidget(
    QrScannerApp(
      settings: settings,
      successCounts: successCounts,
      records: records,
      services: AppServices.fakes(),
    ),
  );
  await tester.pumpAndSettle();
  // SCAN-1: the app opens on the scanner; Settings is one tap away.
  expect(find.byType(SettingsScreen), findsNothing);
  await tester.tap(find.byKey(AppShell.settingsTabKey));
  await tester.pumpAndSettle();
  expect(find.byType(SettingsScreen), findsOneWidget);

  return _Harness(settings: settings, store: store);
}

/// The brightness the screen is actually painted with (SET-1).
Brightness _brightnessOnScreen(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(SettingsScreen))).brightness;

/// The direction the screen is laid out in (LANG-5).
TextDirection _directionOnScreen(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(SettingsScreen)));
