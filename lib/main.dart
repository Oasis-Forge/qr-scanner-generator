import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/core/store/sqflite_key_value_store.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/l10n/app_localizations.dart';
import 'package:qrscanner/screens/app_shell.dart';
import 'package:qrscanner/core/services/device/admob_ads_service.dart';
import 'package:qrscanner/core/services/device/custom_tabs_link_opener.dart';
import 'package:qrscanner/core/services/device/flutter_clipboard_service.dart';
import 'package:qrscanner/core/services/device/play_billing_service.dart';
import 'package:qrscanner/core/services/device/share_plus_service.dart';
import 'package:qrscanner/core/services/device/ump_consent_service.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/device/android_system_intents.dart';
import 'package:qrscanner/services/device/device_permission_service.dart';
import 'package:qrscanner/services/device/haptic_scan_feedback.dart';
import 'package:qrscanner/services/device/image_picker_photo_picker.dart';
import 'package:qrscanner/services/device/mlkit_image_decoder.dart';
import 'package:qrscanner/services/device/mobile_scanner_camera.dart';
import 'package:qrscanner/services/device/platform_app_version_info.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/scanner_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

/// The app's entry point, and the only place a real device service or a real
/// database is ever built (`CLAUDE.md`).
///
/// It opens the database, brings the schema up to date, loads the settings and
/// the success counts, and only then draws the first frame, so no screen ever
/// shows a default the user has already changed. If the database cannot be
/// opened the app shows [DatabaseUnavailableApp] instead of crashing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _layOutUnderTheSystemBars();

  try {
    final Directory supportDirectory = await getApplicationSupportDirectory();
    final AppDatabase database = AppDatabase(
      directory: supportDirectory.path,
      runner: MigrationRunner(migrationSteps),
      // The entry point is the only place the real sqflite plugin is built;
      // tests pass the in-memory factory instead.
      databaseFactory: databaseFactorySqflitePlugin,
    );
    await database.open();

    final KeyValueStore store = SqfliteKeyValueStore(database.database);
    final AppServices services = _deviceServices(store);
    final SettingsState settings = SettingsState(store);
    final SuccessCounts successCounts = SuccessCounts(store);
    final ProState proState = ProState(
      billing: services.billing,
      store: store,
      successCounts: successCounts,
    );
    // Loaded together, not one after the other: they read disjoint keys
    // (`settings.*`, `counts.*` and `prompts.*`, `pro.*`), none writes
    // anything, and sqflite runs the reads on its own queue, so the outcome is
    // the one sequential loads gave — the first frame just waits for the reads
    // to interleave instead of for one set after the other. Billing starts
    // first, so its purchase stream is listening before Pro's start-up
    // re-check (PRO-6) asks the store; Pro's load returns once its cache is
    // read (PRO-7) and never waits on the store.
    await Future.wait<void>(<Future<void>>[
      services.billing.initialize(),
      settings.load(),
      successCounts.load(),
      proState.load(),
    ]);

    runApp(
      QrScannerApp(
        settings: settings,
        successCounts: successCounts,
        records: RecordDao(database),
        services: services,
        proState: proState,
      ),
    );
    // PRIV-1: consent is refreshed silently at each start; nothing shows. The
    // form itself waits until an ad screen is about to ask for an ad
    // (AdsState). The ads SDK starts only then too.
    unawaited(services.consent.refresh());
  } on Object catch (error, stackTrace) {
    // Nothing is sent anywhere: the crash-report opt-in (PRIV-3) lives in the
    // database that just failed to open, so the failure only goes to the log.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'qrscanner',
        context: ErrorDescription('opening the app database'),
      ),
    );
    runApp(const DatabaseUnavailableApp());
  }
}

/// Every device capability the app will use, built once (`CLAUDE.md`).
///
/// Real now: the camera scanner, image decoder, permissions, photo picker and
/// scan feedback (RUN-1, SCAN-1, SCAN-11), the clipboard and share sheet
/// (RES-1), the system hand-offs (RES-4, RES-6, RES-7) and the Custom Tabs
/// link opener (LINK-8, RES-9). Still the no-op fake until their PR: saving a
/// file (SAVE-2), ads, consent, billing and crash reports (ADS-1, PRIV-1,
/// PRO-1, PRIV-3), and Wi-Fi joining (RES-5).
/// The AdMob banner unit every ADS-1 slot shows in a release build. Ad unit
/// IDs aren't secrets; the matching app ID is in `AndroidManifest.xml`.
const String bannerAdUnitId = 'ca-app-pub-8287765177319119/9242359295';

AppServices _deviceServices(KeyValueStore store) {
  final PermissionService permissions = DevicePermissionService(store: store);
  return AppServices.fakes().copyWith(
    cameraScanner: MobileScannerCamera(permissions: permissions),
    imageDecoder: MlkitImageDecoder(),
    permissions: permissions,
    photoPicker: ImagePickerPhotoPicker(),
    scanFeedback: const HapticScanFeedback(),
    clipboard: const FlutterClipboardService(),
    share: const SharePlusService(),
    systemIntents: const AndroidSystemIntents(),
    linkOpener: const CustomTabsLinkOpener(themeColor: AppTheme.seedColor),
    // Real ads only in a release build; a debug build asks for Google's test
    // banner, so development never touches the real inventory.
    ads: AdmobAdsService(
      adUnitId: kReleaseMode ? bannerAdUnitId : testAdaptiveBannerAdUnitId,
    ),
    consent: UmpConsentService(),
    billing: PlayBillingService(),
    versionInfo: PlatformAppVersionInfo(),
  );
}

/// Lays the app out under the status and navigation bars.
///
/// Every screen then sees the real insets and keeps its own content clear of
/// them with `SafeArea`, which is what lets the scanner's viewfinder fill the
/// screen later without an ad or a control ever sitting under a system bar.
Future<void> _layOutUnderTheSystemBars() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
}

/// The language the app draws in when the device asks for one the message files
/// don't have (LANG-1). It is the template message file's language, so it is
/// always one of `AppLocalizations.supportedLocales`.
const Locale fallbackLocale = Locale('en');

/// The locale the app draws in, given the languages the device asks for
/// (LANG-1).
///
/// [preferred] is the device's language list, most wanted first, or the single
/// language the user chose in Settings: `MaterialApp` passes an explicit
/// `locale` through this same callback as a one-entry list, which is what makes
/// the Settings choice win over the device list. The first entry the app has
/// messages for wins — language and country first, then the language alone, so
/// a device set to `ar-EG` gets Arabic.
///
/// When nothing matches, or the device reports no language at all, the app
/// falls back to [fallbackLocale]. Flutter's own default would hand back
/// `supportedLocales.first`, which is Arabic here, so a phone set to French
/// would open a right-to-left Arabic app — LANG-1 says English.
Locale _resolveAppLocale(
  List<Locale>? preferred,
  Iterable<Locale> supportedLocales,
) {
  for (final Locale wanted in preferred ?? const <Locale>[]) {
    for (final Locale supported in supportedLocales) {
      if (supported.languageCode == wanted.languageCode &&
          supported.countryCode == wanted.countryCode) {
        return supported;
      }
    }
    for (final Locale supported in supportedLocales) {
      if (supported.languageCode == wanted.languageCode) {
        return supported;
      }
    }
  }
  return fallbackLocale;
}

/// The app shell: the state and services every screen reads, the themes
/// (SET-1), and the message files with the chosen language (LANG-1, LANG-2).
///
/// It builds nothing itself. [main] hands it the state layer and the service
/// container, and a test hands it an in-memory store and the no-op fakes, so the
/// shell under test is the one that ships.
class QrScannerApp extends StatelessWidget {
  const QrScannerApp({
    required this.settings,
    required this.successCounts,
    required this.records,
    required this.services,
    required this.proState,
    super.key,
  });

  /// Every user setting, already loaded (SET-1, LANG-1).
  final SettingsState settings;

  /// The success counters behind ads and prompts (DATA-8).
  final SuccessCounts successCounts;

  /// Reads and writes for History and created codes.
  final RecordDao records;

  /// Every device capability, behind its interface (`CLAUDE.md`).
  final AppServices services;

  /// Pro ownership and the one Pro prompt (PRO), already loaded from its
  /// cache, like [settings].
  final ProState proState;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsState>.value(value: settings),
        ChangeNotifierProvider<SuccessCounts>.value(value: successCounts),
        Provider<RecordDao>.value(value: records),
        Provider<AppServices>.value(value: services),
        ChangeNotifierProvider<ProState>.value(value: proState),
        // The scanner (SCAN-1, RUN-1 to RUN-7), built from the same services,
        // records and settings every other screen reads. It lives as long as
        // the app; the scanner screen enters and leaves it.
        ChangeNotifierProvider<ScannerState>(
          create: (BuildContext context) => ScannerState(
            permissions: services.permissions,
            camera: services.cameraScanner,
            imageDecoder: services.imageDecoder,
            photoPicker: services.photoPicker,
            feedback: services.scanFeedback,
            records: records,
            settings: settings,
            successCounts: successCounts,
          ),
        ),
        // History (HIS-1). Built at start, not lazily, so DEL-4's purge of
        // Trash older than 30 local days runs at every app start; it runs
        // unawaited, so the first frame never waits for it, and it swallows
        // its own failures.
        ChangeNotifierProvider<HistoryState>(
          lazy: false,
          create: (BuildContext context) {
            final HistoryState history = HistoryState(
              records: records,
              settings: settings,
            );
            unawaited(history.purgeExpiredTrash());
            return history;
          },
        ),
      ],
      // The device's own palette, where Android offers one (SET-1). The schemes
      // are null until the platform answers, and on any device below Android 12,
      // and the theme falls back to the app's seed colour.
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) =>
            _MaterialShell(
              lightDynamic: lightDynamic,
              darkDynamic: darkDynamic,
            ),
      ),
    );
  }
}

/// The [MaterialApp] itself, below the providers so it can watch the settings:
/// a theme or language change repaints without a restart (SET-1, LANG-1).
class _MaterialShell extends StatelessWidget {
  const _MaterialShell({this.lightDynamic, this.darkDynamic});

  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = context.watch<SettingsState>();
    return MaterialApp(
      // The task switcher's label, from the message files (LANG-2), rebuilt
      // when the language changes.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      // AppLocalizations.delegate plus the Material, Cupertino and Widgets
      // delegates, which is what gives Arabic its right-to-left layout and its
      // own date and number formats (LANG-3, LANG-5).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Null follows the device language (LANG-1); the callback is what turns
      // "follows the device language" into "and falls back to English".
      locale: settings.localeOverride,
      localeListResolutionCallback: _resolveAppLocale,
      theme: AppTheme.light(dynamicScheme: lightDynamic),
      darkTheme: AppTheme.dark(dynamicScheme: darkDynamic),
      themeMode: settings.themeMode,
      home: const AppShell(),
    );
  }
}

/// What the app shows when the database cannot be opened.
///
/// A plain screen with the error string from the message files (LANG-2) rather
/// than a crash or a blank white frame. There are no settings to read, so it
/// takes the device language, resolved the same way the rest of the app resolves
/// it (LANG-1), and the seed theme.
class DatabaseUnavailableApp extends StatelessWidget {
  const DatabaseUnavailableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _resolveAppLocale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Center(
              child: Builder(
                builder: (BuildContext context) => Text(
                  AppLocalizations.of(context).errorStorageUnavailable,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
