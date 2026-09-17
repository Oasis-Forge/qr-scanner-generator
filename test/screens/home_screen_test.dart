import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/main.dart';
import 'package:qrscanner/screens/home_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

/// The English app name, as the message files spell it (LANG-2).
const String englishAppName = 'QR Scanner + Generator';

/// The Arabic app name, as the message files spell it (LANG-2).
const String arabicAppName = 'ماسح ومنشئ رموز QR';

void main() {
  group('HomeScreen', () {
    testWidgets('LANG-2: shows the app name and both switchers in English', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      expect(find.text(englishAppName), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      // "System default" is one choice in each switcher.
      expect(find.text('System default'), findsNWidgets(2));
    });

    testWidgets(
      'LANG-1, LANG-5: a stored Arabic language shows Arabic text and lays the '
      'screen out right to left',
      (WidgetTester tester) async {
        await _pumpApp(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'ar'},
        );

        expect(find.text(arabicAppName), findsOneWidget);
        expect(find.text(englishAppName), findsNothing);
        expect(find.text('المظهر'), findsOneWidget);
        expect(find.text('فاتح'), findsOneWidget);
        expect(find.text('داكن'), findsOneWidget);
        expect(find.text('اللغة'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.rtl,
        );
      },
    );

    testWidgets(
      'SET-1: choosing Dark stores the theme and repaints the app dark',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpApp(tester);
        expect(_brightnessOnScreen(tester), Brightness.light);

        await tester.tap(find.byKey(HomeScreen.darkThemeKey));
        await tester.pumpAndSettle();

        expect(harness.settings.themeMode, ThemeMode.dark);
        expect(harness.store.writes, contains('set settings.theme_mode=dark'));
        expect(_brightnessOnScreen(tester), Brightness.dark);
        // The chosen option is not colour alone: it carries a tick (A11Y-6).
        expect(
          find.descendant(
            of: find.byKey(HomeScreen.darkThemeKey),
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
        final _Harness harness = await _pumpApp(tester);
        expect(find.text(englishAppName), findsOneWidget);

        await tester.tap(find.byKey(HomeScreen.arabicLanguageKey));
        await tester.pumpAndSettle();

        expect(harness.settings.localeOverride, const Locale('ar'));
        expect(harness.store.writes, contains('set settings.language=ar'));
        expect(find.text(arabicAppName), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.rtl,
        );
      },
    );

    testWidgets(
      'LANG-1: choosing System default removes the stored language, so the '
      'device language is followed again',
      (WidgetTester tester) async {
        final _Harness harness = await _pumpApp(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'ar'},
        );

        await tester.tap(find.byKey(HomeScreen.systemLanguageKey));
        await tester.pumpAndSettle();

        expect(harness.settings.localeOverride, isNull);
        expect(harness.store.writes, contains('remove settings.language'));
        expect(
          harness.store.values.containsKey(SettingsState.localeKey),
          isFalse,
        );
        expect(find.text(englishAppName), findsOneWidget);
      },
    );

    testWidgets(
      'LANG-1: a device language the app does not have opens the app in '
      'English, not in the first language the message files happen to list',
      (WidgetTester tester) async {
        // The message files list Arabic first, so Flutter's own fallback would
        // hand this phone a right-to-left Arabic app.
        await _pumpApp(
          tester,
          deviceLanguages: const <Locale>[Locale('fr', 'FR'), Locale('de')],
        );

        expect(find.text(englishAppName), findsOneWidget);
        expect(find.text(arabicAppName), findsNothing);
        expect(find.text('Language'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.ltr,
        );
      },
    );

    testWidgets(
      'LANG-1: a device set to a country the message files do not name still '
      'gets that language',
      (WidgetTester tester) async {
        await _pumpApp(
          tester,
          deviceLanguages: const <Locale>[Locale('ar', 'EG')],
        );

        expect(find.text(arabicAppName), findsOneWidget);
        expect(find.text(englishAppName), findsNothing);
        expect(find.text('اللغة'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.rtl,
        );
      },
    );

    testWidgets(
      'LANG-1: the language chosen in Settings wins over the device language '
      'list',
      (WidgetTester tester) async {
        // Arabic is what the device asks for first, and the app has it, so only
        // the stored choice can put the app into English.
        await _pumpApp(
          tester,
          stored: <String, String>{SettingsState.localeKey: 'en'},
          deviceLanguages: const <Locale>[Locale('ar'), Locale('en')],
        );

        expect(find.text(englishAppName), findsOneWidget);
        expect(find.text(arabicAppName), findsNothing);
        expect(find.text('Language'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.ltr,
        );
      },
    );

    testWidgets('A11Y-1: every switcher option carries its own screen-reader '
        'label', (WidgetTester tester) async {
      // Released inside the test body: the framework checks for live handles
      // before tearDowns run.
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pumpApp(tester);

      const List<(Key, String)> expected = <(Key, String)>[
        (HomeScreen.systemThemeKey, 'System default'),
        (HomeScreen.lightThemeKey, 'Light'),
        (HomeScreen.darkThemeKey, 'Dark'),
        (HomeScreen.systemLanguageKey, 'System default'),
        (HomeScreen.englishLanguageKey, 'English'),
        (HomeScreen.arabicLanguageKey, 'العربية'),
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
        tester.getSemantics(find.byKey(HomeScreen.systemThemeKey)),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.byKey(HomeScreen.darkThemeKey)),
        isSemantics(isSelected: false),
      );
      semantics.dispose();
    });

    testWidgets('A11Y-2: every switcher option is at least 48 x 48 dp', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      const List<Key> options = <Key>[
        HomeScreen.systemThemeKey,
        HomeScreen.lightThemeKey,
        HomeScreen.darkThemeKey,
        HomeScreen.systemLanguageKey,
        HomeScreen.englishLanguageKey,
        HomeScreen.arabicLanguageKey,
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
        final _Harness harness = await _pumpApp(tester);
        harness.store.failingKeys.add(SettingsState.themeModeKey);

        await tester.tap(find.byKey(HomeScreen.darkThemeKey));
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
  final _FakeKeyValueStore store;
}

/// Builds the real app shell over an in-memory store and the no-op services,
/// so a test drives the widget tree that ships.
Future<_Harness> _pumpApp(
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
  final _FakeKeyValueStore store = _FakeKeyValueStore(stored);
  final SettingsState settings = SettingsState(store);
  await settings.load();
  final SuccessCounts successCounts = SuccessCounts(store);
  await successCounts.load();
  // The screen under test reads no records; the DAO is here because the shell
  // provides it, and its database is never opened.
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

  return _Harness(settings: settings, store: store);
}

/// The brightness the screen is actually painted with (SET-1).
Brightness _brightnessOnScreen(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(HomeScreen))).brightness;

/// An in-memory [KeyValueStore] that records its writes and can be told to fail
/// one, standing in for a full or locked database.
///
/// It decodes the way `SqfliteKeyValueStore` does — ints as decimal text, bools
/// as `'1'` or `'0'` — so the screen sees the values the real store would hand
/// back.
class _FakeKeyValueStore implements KeyValueStore {
  _FakeKeyValueStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  /// The rows the store holds, as the database would.
  final Map<String, String> values;

  /// Keys whose writes throw.
  final Set<String> failingKeys = <String>{};

  /// Every write that happened, as `'set settings.theme_mode=dark'` or
  /// `'remove settings.language'`.
  final List<String> writes = <String>[];

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    _failIfAsked(key);
    writes.add('set $key=$value');
    values[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => int.tryParse(values[key] ?? '');

  @override
  Future<void> setInt(String key, int value) => setString(key, '$value');

  @override
  Future<bool?> getBool(String key) async => switch (values[key]) {
    '1' => true,
    '0' => false,
    _ => null,
  };

  @override
  Future<void> setBool(String key, {required bool value}) =>
      setString(key, value ? '1' : '0');

  @override
  Future<int> increment(String key, {int by = 1}) async {
    final int next = (int.tryParse(values[key] ?? '') ?? 0) + by;
    await setString(key, '$next');
    return next;
  }

  @override
  Future<void> remove(String key) async {
    _failIfAsked(key);
    writes.add('remove $key');
    values.remove(key);
  }

  @override
  Future<Map<String, String>> all() async => Map<String, String>.from(values);

  void _failIfAsked(String key) {
    if (failingKeys.contains(key)) {
      throw StateError('the database refused to write $key');
    }
  }
}
