import 'package:flutter/material.dart';

import '../core/store/key_value_store.dart';

/// The web search engine "Search the web" uses on a product result (SET-4,
/// RES-9).
///
/// The engine only names the user's choice; building the search URL is the job
/// of whatever opens the link, so no URL is guessed here.
enum SearchEngine {
  /// The default until the user picks another (SET-4).
  google('google'),

  bing('bing'),

  duckDuckGo('duckduckgo'),

  ecosia('ecosia'),

  brave('brave'),

  yahoo('yahoo'),

  yandex('yandex');

  const SearchEngine(this.id);

  /// The value stored under [SettingsState.searchEngineKey].
  final String id;

  /// The engine stored as [id].
  ///
  /// An ID this build doesn't know, or no value at all, reads as [google], the
  /// documented default (SET-4), rather than throwing.
  static SearchEngine fromId(String? id) =>
      values.firstWhere((engine) => engine.id == id, orElse: () => google);
}

/// Every user setting, read from and written to a [KeyValueStore].
///
/// Screens stay presentational (`CLAUDE.md`): they read a getter and call a
/// setter, and never touch the store. Each setting has a documented default,
/// used while the store holds nothing for it, so a fresh install and a database
/// a migration has just created behave the same.
///
/// Reliable writes (`CLAUDE.md`): a setter writes to the store *first* and only
/// then changes the field and notifies. If the write throws, the in-memory
/// value is left exactly as it was, no listener is told anything changed, and
/// the failure reaches the caller instead of being swallowed, so the app and
/// the database never disagree about what the user chose.
///
/// Nothing here leaves the device (PRIV-8).
class SettingsState extends ChangeNotifier {
  SettingsState(KeyValueStore store) : _store = store;

  /// Stores [ThemeMode.name] (SET-1).
  static const String themeModeKey = 'settings.theme_mode';

  /// Stores a language tag such as `'ar'` or `'pt_BR'`; absent means the app
  /// follows the device language (LANG-1).
  static const String localeKey = 'settings.language';

  /// Stores the sound-on-scan switch (SET-2).
  static const String soundOnScanKey = 'settings.sound_on_scan';

  /// Stores the vibrate-on-scan switch (SET-2).
  static const String vibrateOnScanKey = 'settings.vibrate_on_scan';

  /// Stores the copy-on-scan switch (SET-3).
  static const String copyOnScanKey = 'settings.copy_on_scan';

  /// Stores [SearchEngine.id] (SET-4).
  static const String searchEngineKey = 'settings.search_engine';

  /// Stores the save-history switch (HIS-8).
  static const String saveHistoryKey = 'settings.save_history';

  /// Stores the crash-report opt-in (PRIV-3).
  static const String sendCrashReportsKey = 'settings.send_crash_reports';

  /// Theme: System default is the initial choice (SET-1).
  static const ThemeMode defaultThemeMode = ThemeMode.system;

  /// Sound on scan: off (SET-2).
  static const bool defaultSoundOnScan = false;

  /// Vibrate on scan: on (SET-2).
  static const bool defaultVibrateOnScan = true;

  /// Copy on scan: off (SET-3).
  static const bool defaultCopyOnScan = false;

  /// Search engine: Google (SET-4).
  static const SearchEngine defaultSearchEngine = SearchEngine.google;

  /// Save history: on (HIS-8).
  static const bool defaultSaveHistory = true;

  /// Send crash reports: off until the user turns it on (PRIV-3).
  static const bool defaultSendCrashReports = false;

  final KeyValueStore _store;

  ThemeMode _themeMode = defaultThemeMode;
  Locale? _localeOverride;
  bool _soundOnScan = defaultSoundOnScan;
  bool _vibrateOnScan = defaultVibrateOnScan;
  bool _copyOnScan = defaultCopyOnScan;
  SearchEngine _searchEngine = defaultSearchEngine;
  bool _saveHistory = defaultSaveHistory;
  bool _sendCrashReports = defaultSendCrashReports;
  bool _isLoaded = false;

  /// System default, Light or Dark (SET-1).
  ThemeMode get themeMode => _themeMode;

  /// The language the user picked, or `null` for "System default", where the
  /// app follows the device language (LANG-1).
  Locale? get localeOverride => _localeOverride;

  /// Whether a successful scan plays a sound (SET-2, SCAN-5).
  bool get soundOnScan => _soundOnScan;

  /// Whether a successful scan vibrates (SET-2, SCAN-5).
  bool get vibrateOnScan => _vibrateOnScan;

  /// Whether a result copies itself once it is on screen (SET-3, RES-2).
  bool get copyOnScan => _copyOnScan;

  /// The engine behind "Search the web" (SET-4, RES-9).
  SearchEngine get searchEngine => _searchEngine;

  /// Whether new scans and created codes are written to History (HIS-8). While
  /// off, a result works from an unsaved record (DATA-6).
  bool get saveHistory => _saveHistory;

  /// Whether the user has opted in to crash reports (PRIV-3).
  bool get sendCrashReports => _sendCrashReports;

  /// Whether [load] has finished. Until then every getter reads its documented
  /// default.
  bool get isLoaded => _isLoaded;

  /// Fills the settings from the store, then notifies once.
  ///
  /// Called once before the screens read anything. Every value is decoded
  /// before any field is assigned, so a read that throws leaves the whole set
  /// at its defaults rather than half loaded, and a value this build cannot
  /// read falls back to its default instead of throwing (BAK-5).
  Future<void> load() async {
    final themeMode = themeModeFromId(await _store.getString(themeModeKey));
    final locale = localeFromTag(await _store.getString(localeKey));
    final sound = await _store.getBool(soundOnScanKey);
    final vibrate = await _store.getBool(vibrateOnScanKey);
    final copy = await _store.getBool(copyOnScanKey);
    final engine = SearchEngine.fromId(await _store.getString(searchEngineKey));
    final saveHistory = await _store.getBool(saveHistoryKey);
    final crashReports = await _store.getBool(sendCrashReportsKey);

    _themeMode = themeMode;
    _localeOverride = locale;
    _soundOnScan = sound ?? defaultSoundOnScan;
    _vibrateOnScan = vibrate ?? defaultVibrateOnScan;
    _copyOnScan = copy ?? defaultCopyOnScan;
    _searchEngine = engine;
    _saveHistory = saveHistory ?? defaultSaveHistory;
    _sendCrashReports = crashReports ?? defaultSendCrashReports;
    _isLoaded = true;
    notifyListeners();
  }

  /// Stores the theme and applies it without a restart (SET-1).
  Future<void> setThemeMode(ThemeMode mode) => _apply(
    changed: mode != _themeMode,
    persist: () => _store.setString(themeModeKey, mode.name),
    assign: () => _themeMode = mode,
  );

  /// Stores the language and applies it without a restart (LANG-1).
  ///
  /// `null` is "System default": the stored value is removed, so a later
  /// device-language change is followed again.
  Future<void> setLocaleOverride(Locale? locale) => _apply(
    changed: locale != _localeOverride,
    persist: () => locale == null
        ? _store.remove(localeKey)
        : _store.setString(localeKey, localeTag(locale)),
    assign: () => _localeOverride = locale,
  );

  /// Stores the sound-on-scan switch (SET-2).
  Future<void> setSoundOnScan({required bool enabled}) => _apply(
    changed: enabled != _soundOnScan,
    persist: () => _store.setBool(soundOnScanKey, value: enabled),
    assign: () => _soundOnScan = enabled,
  );

  /// Stores the vibrate-on-scan switch (SET-2).
  Future<void> setVibrateOnScan({required bool enabled}) => _apply(
    changed: enabled != _vibrateOnScan,
    persist: () => _store.setBool(vibrateOnScanKey, value: enabled),
    assign: () => _vibrateOnScan = enabled,
  );

  /// Stores the copy-on-scan switch (SET-3).
  Future<void> setCopyOnScan({required bool enabled}) => _apply(
    changed: enabled != _copyOnScan,
    persist: () => _store.setBool(copyOnScanKey, value: enabled),
    assign: () => _copyOnScan = enabled,
  );

  /// Stores the engine "Search the web" uses (SET-4).
  Future<void> setSearchEngine(SearchEngine engine) => _apply(
    changed: engine != _searchEngine,
    persist: () => _store.setString(searchEngineKey, engine.id),
    assign: () => _searchEngine = engine,
  );

  /// Stores the save-history switch (HIS-8). Turning it off keeps the history
  /// already written.
  Future<void> setSaveHistory({required bool enabled}) => _apply(
    changed: enabled != _saveHistory,
    persist: () => _store.setBool(saveHistoryKey, value: enabled),
    assign: () => _saveHistory = enabled,
  );

  /// Stores the crash-report choice (PRIV-3).
  ///
  /// The stored choice is what the crash reporter is switched to; until the
  /// write lands, reporting stays exactly as it was, so nothing is collected on
  /// the strength of a setting that was never saved.
  Future<void> setSendCrashReports({required bool enabled}) => _apply(
    changed: enabled != _sendCrashReports,
    persist: () => _store.setBool(sendCrashReportsKey, value: enabled),
    assign: () => _sendCrashReports = enabled,
  );

  /// The theme stored as [id], [defaultThemeMode] when the value is missing or
  /// is one this build doesn't know (SET-1).
  static ThemeMode themeModeFromId(String? id) => ThemeMode.values.firstWhere(
    (mode) => mode.name == id,
    orElse: () => defaultThemeMode,
  );

  /// [locale] as the stored tag: `'ar'`, or `'pt_BR'` with a country.
  ///
  /// Only the language and the country are stored, which is all the app's
  /// supported languages need (LANG-7); a script subtag would not survive a
  /// round trip.
  static String localeTag(Locale locale) {
    final country = locale.countryCode;
    return country == null || country.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_$country';
  }

  /// The locale stored as [tag], or `null` for "System default" (LANG-1).
  ///
  /// A blank or malformed tag reads as `null`, so a hand-edited database or a
  /// restored backup falls back to the device language instead of throwing
  /// (BAK-5).
  static Locale? localeFromTag(String? tag) {
    final trimmed = tag?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final parts = trimmed.split(RegExp(r'[-_]'));
    final language = parts.first;
    if (language.isEmpty) {
      return null;
    }
    if (parts.length == 1) {
      return Locale(language);
    }
    final country = parts[1];
    return country.isEmpty ? Locale(language) : Locale(language, country);
  }

  /// Writes before it changes anything, and tells nobody when the write fails.
  ///
  /// A setter called with the value the setting already has writes nothing and
  /// notifies nobody, so a screen rebuilding cannot churn the database.
  Future<void> _apply({
    required bool changed,
    required Future<void> Function() persist,
    required void Function() assign,
  }) async {
    if (!changed) {
      return;
    }
    await persist();
    assign();
    notifyListeners();
  }
}
