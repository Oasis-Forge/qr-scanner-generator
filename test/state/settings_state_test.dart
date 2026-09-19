import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/state/settings_state.dart';

/// An in-memory [KeyValueStore] that can be told to fail a write.
///
/// It decodes the way `SqfliteKeyValueStore` does — ints as decimal text, bools
/// as `'1'` or `'0'`, anything else as `null` — so a test sees the values the
/// real store would hand back.
class _FakeKeyValueStore implements KeyValueStore {
  _FakeKeyValueStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  /// The rows the store holds, as the database would.
  final Map<String, String> values;

  /// Keys whose writes throw, standing in for a full or locked database.
  final Set<String> failingKeys = <String>{};

  /// Every write that happened, as `'set settings.copy_on_scan=1'` or
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
    final next = (int.tryParse(values[key] ?? '') ?? 0) + by;
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
  Future<Map<String, String>> all() async => Map<String, String>.of(values);

  void _failIfAsked(String key) {
    if (failingKeys.contains(key)) {
      throw StateError('the write to $key failed');
    }
  }
}

void main() {
  late _FakeKeyValueStore store;
  late SettingsState settings;
  late int notifications;

  /// Loads [settings] from [store] and starts counting notifications after, so
  /// a test counts only the changes it makes itself.
  Future<void> loadAndListen() async {
    await settings.load();
    settings.addListener(() => notifications++);
  }

  setUp(() {
    store = _FakeKeyValueStore();
    settings = SettingsState(store);
    notifications = 0;
  });

  tearDown(() => settings.dispose());

  group('defaults, with nothing stored', () {
    test('the theme follows the system (SET-1)', () async {
      await settings.load();

      expect(settings.themeMode, ThemeMode.system);
    });

    test('the language follows the device (LANG-1)', () async {
      await settings.load();

      expect(settings.localeOverride, isNull);
    });

    test('vibration is on and sound is off (SET-2)', () async {
      await settings.load();

      expect(settings.vibrateOnScan, isTrue);
      expect(settings.soundOnScan, isFalse);
    });

    test('copy on scan is off (SET-3)', () async {
      await settings.load();

      expect(settings.copyOnScan, isFalse);
    });

    test('the search engine is Google (SET-4)', () async {
      await settings.load();

      expect(settings.searchEngine, SearchEngine.google);
    });

    test('save history is on (HIS-8)', () async {
      await settings.load();

      expect(settings.saveHistory, isTrue);
    });

    test('crash reports are off until the user opts in (PRIV-3)', () async {
      await settings.load();

      expect(settings.sendCrashReports, isFalse);
    });

    test('the link callout has not been seen yet (RUN-8)', () async {
      await settings.load();

      expect(settings.linkCalloutSeen, isFalse);
    });

    test('a default is not written to the store', () async {
      await settings.load();

      expect(store.writes, isEmpty);
      expect(store.values, isEmpty);
    });

    test('the defaults hold before load is called', () {
      expect(settings.isLoaded, isFalse);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.vibrateOnScan, isTrue);
      expect(settings.saveHistory, isTrue);
      expect(settings.sendCrashReports, isFalse);
      expect(settings.linkCalloutSeen, isFalse);
    });
  });

  group('load', () {
    test('reads every stored value (SET-1, SET-2, SET-3, SET-4)', () async {
      store = _FakeKeyValueStore({
        SettingsState.themeModeKey: 'dark',
        SettingsState.localeKey: 'pt_BR',
        SettingsState.soundOnScanKey: '1',
        SettingsState.vibrateOnScanKey: '0',
        SettingsState.copyOnScanKey: '1',
        SettingsState.searchEngineKey: 'ecosia',
        SettingsState.saveHistoryKey: '0',
        SettingsState.sendCrashReportsKey: '1',
        SettingsState.linkCalloutSeenKey: '1',
      });
      settings = SettingsState(store);

      await settings.load();

      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.localeOverride, const Locale('pt', 'BR'));
      expect(settings.soundOnScan, isTrue);
      expect(settings.vibrateOnScan, isFalse);
      expect(settings.copyOnScan, isTrue);
      expect(settings.searchEngine, SearchEngine.ecosia);
      expect(settings.saveHistory, isFalse);
      expect(settings.sendCrashReports, isTrue);
      expect(settings.linkCalloutSeen, isTrue);
      expect(settings.isLoaded, isTrue);
    });

    test('reads a language with no country (LANG-1)', () async {
      store = _FakeKeyValueStore({SettingsState.localeKey: 'ar'});
      settings = SettingsState(store);

      await settings.load();

      expect(settings.localeOverride, const Locale('ar'));
    });

    test('a value this build cannot read falls back (SET-1, SET-4)', () async {
      store = _FakeKeyValueStore({
        SettingsState.themeModeKey: 'midnight',
        SettingsState.localeKey: '   ',
        SettingsState.searchEngineKey: 'lycos',
        SettingsState.saveHistoryKey: 'yes',
      });
      settings = SettingsState(store);

      await settings.load();

      expect(settings.themeMode, ThemeMode.system);
      expect(settings.localeOverride, isNull);
      expect(settings.searchEngine, SearchEngine.google);
      expect(settings.saveHistory, isTrue);
    });

    test('notifies once', () async {
      settings.addListener(() => notifications++);

      await settings.load();

      expect(notifications, 1);
    });
  });

  group('setters', () {
    test('the theme is stored by name and notified once (SET-1)', () async {
      await loadAndListen();

      await settings.setThemeMode(ThemeMode.dark);

      expect(settings.themeMode, ThemeMode.dark);
      expect(store.values[SettingsState.themeModeKey], 'dark');
      expect(notifications, 1);
    });

    test('copy on scan is stored and notified once (SET-3)', () async {
      await loadAndListen();

      await settings.setCopyOnScan(enabled: true);

      expect(settings.copyOnScan, isTrue);
      expect(store.values[SettingsState.copyOnScanKey], '1');
      expect(await store.getBool(SettingsState.copyOnScanKey), isTrue);
      expect(notifications, 1);
    });

    test('sound and vibration are stored (SET-2)', () async {
      await loadAndListen();

      await settings.setSoundOnScan(enabled: true);
      await settings.setVibrateOnScan(enabled: false);

      expect(settings.soundOnScan, isTrue);
      expect(settings.vibrateOnScan, isFalse);
      expect(store.values[SettingsState.soundOnScanKey], '1');
      expect(store.values[SettingsState.vibrateOnScanKey], '0');
      expect(notifications, 2);
    });

    test('the search engine is stored by id (SET-4)', () async {
      await loadAndListen();

      await settings.setSearchEngine(SearchEngine.duckDuckGo);

      expect(settings.searchEngine, SearchEngine.duckDuckGo);
      expect(store.values[SettingsState.searchEngineKey], 'duckduckgo');
      expect(notifications, 1);
    });

    test('turning save history off is stored (HIS-8)', () async {
      await loadAndListen();

      await settings.setSaveHistory(enabled: false);

      expect(settings.saveHistory, isFalse);
      expect(store.values[SettingsState.saveHistoryKey], '0');
    });

    test('the crash-report opt-in is stored (PRIV-3)', () async {
      await loadAndListen();

      await settings.setSendCrashReports(enabled: true);

      expect(settings.sendCrashReports, isTrue);
      expect(store.values[SettingsState.sendCrashReportsKey], '1');
      expect(notifications, 1);
    });

    test('dismissLinkCallout stores it seen, for good (RUN-8)', () async {
      await loadAndListen();

      await settings.dismissLinkCallout();

      expect(settings.linkCalloutSeen, isTrue);
      expect(store.values[SettingsState.linkCalloutSeenKey], '1');
      expect(notifications, 1);
    });

    test(
      'dismissLinkCallout a second time writes nothing more (RUN-8)',
      () async {
        await loadAndListen();
        await settings.dismissLinkCallout();

        await settings.dismissLinkCallout();

        expect(store.writes, hasLength(1));
        expect(notifications, 1);
      },
    );

    test('a dismissal survives a reload (RUN-8)', () async {
      await settings.load();
      await settings.dismissLinkCallout();

      final SettingsState reloaded = SettingsState(store);
      await reloaded.load();

      expect(reloaded.linkCalloutSeen, isTrue);
      reloaded.dispose();
    });

    test('a language is stored as a tag (LANG-1)', () async {
      await loadAndListen();

      await settings.setLocaleOverride(const Locale('pt', 'BR'));

      expect(settings.localeOverride, const Locale('pt', 'BR'));
      expect(store.values[SettingsState.localeKey], 'pt_BR');
      expect(notifications, 1);
    });

    test('System default removes the stored language (LANG-1)', () async {
      store = _FakeKeyValueStore({SettingsState.localeKey: 'ar'});
      settings = SettingsState(store);
      await loadAndListen();

      await settings.setLocaleOverride(null);

      expect(settings.localeOverride, isNull);
      expect(store.values.containsKey(SettingsState.localeKey), isFalse);
      expect(store.writes, ['remove ${SettingsState.localeKey}']);
      expect(notifications, 1);
    });

    test('a stored language survives a reload (LANG-1)', () async {
      await settings.load();
      await settings.setLocaleOverride(const Locale('ar'));

      final reloaded = SettingsState(store);
      await reloaded.load();

      expect(reloaded.localeOverride, const Locale('ar'));
      reloaded.dispose();
    });

    test('setting the value it already has writes nothing', () async {
      await loadAndListen();

      await settings.setSaveHistory(enabled: true);
      await settings.setThemeMode(ThemeMode.system);
      await settings.setSearchEngine(SearchEngine.google);
      await settings.setLocaleOverride(null);

      expect(store.writes, isEmpty);
      expect(notifications, 0);
    });
  });

  group('a failed write', () {
    test('leaves the value and the listeners untouched (SET-3)', () async {
      await loadAndListen();
      store.failingKeys.add(SettingsState.copyOnScanKey);

      await expectLater(
        settings.setCopyOnScan(enabled: true),
        throwsStateError,
      );

      expect(settings.copyOnScan, isFalse);
      expect(store.values.containsKey(SettingsState.copyOnScanKey), isFalse);
      expect(store.writes, isEmpty);
      expect(notifications, 0);
    });

    test('leaves crash reports off (PRIV-3)', () async {
      await loadAndListen();
      store.failingKeys.add(SettingsState.sendCrashReportsKey);

      await expectLater(
        settings.setSendCrashReports(enabled: true),
        throwsStateError,
      );

      expect(settings.sendCrashReports, isFalse);
      expect(store.values, isEmpty);
      expect(notifications, 0);
    });

    test('leaves the link callout unseen (RUN-8)', () async {
      await loadAndListen();
      store.failingKeys.add(SettingsState.linkCalloutSeenKey);

      await expectLater(settings.dismissLinkCallout(), throwsStateError);

      expect(settings.linkCalloutSeen, isFalse);
      expect(store.values, isEmpty);
      expect(notifications, 0);
    });

    test('leaves the language as it was (LANG-1)', () async {
      store = _FakeKeyValueStore({SettingsState.localeKey: 'ar'});
      settings = SettingsState(store);
      await loadAndListen();
      store.failingKeys.add(SettingsState.localeKey);

      await expectLater(
        settings.setLocaleOverride(const Locale('de')),
        throwsStateError,
      );

      expect(settings.localeOverride, const Locale('ar'));
      expect(store.values[SettingsState.localeKey], 'ar');
      expect(notifications, 0);
    });

    test('a later write still works (SET-4)', () async {
      await loadAndListen();
      store.failingKeys.add(SettingsState.searchEngineKey);

      await expectLater(
        settings.setSearchEngine(SearchEngine.bing),
        throwsStateError,
      );
      store.failingKeys.clear();
      await settings.setSearchEngine(SearchEngine.bing);

      expect(settings.searchEngine, SearchEngine.bing);
      expect(store.values[SettingsState.searchEngineKey], 'bing');
      expect(notifications, 1);
    });
  });

  group('language tags', () {
    test('round-trip a language and a country (LANG-1)', () {
      expect(
        SettingsState.localeFromTag(
          SettingsState.localeTag(const Locale('pt', 'BR')),
        ),
        const Locale('pt', 'BR'),
      );
      expect(
        SettingsState.localeFromTag(
          SettingsState.localeTag(const Locale('ar')),
        ),
        const Locale('ar'),
      );
    });

    test('a hyphen tag reads the same as an underscore one', () {
      expect(SettingsState.localeFromTag('pt-BR'), const Locale('pt', 'BR'));
    });

    test('a blank or empty tag means System default (LANG-1)', () {
      expect(SettingsState.localeFromTag(null), isNull);
      expect(SettingsState.localeFromTag(''), isNull);
      expect(SettingsState.localeFromTag('  '), isNull);
      expect(SettingsState.localeFromTag('_BR'), isNull);
    });
  });
}
