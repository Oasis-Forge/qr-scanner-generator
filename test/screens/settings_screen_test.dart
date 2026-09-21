import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/l10n/languages.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/main.dart';
import 'package:qrscanner/screens/ads/ad_banner_slot.dart';
import 'package:qrscanner/screens/app_shell.dart';
import 'package:qrscanner/screens/settings/about_section.dart';
import 'package:qrscanner/services/app_version_info.dart';
import 'package:qrscanner/screens/settings/feedback_screen.dart';
import 'package:qrscanner/screens/settings/general_section.dart';
import 'package:qrscanner/screens/settings/pro_section.dart';
import 'package:qrscanner/screens/settings/privacy_section.dart';
import 'package:qrscanner/screens/settings_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/interstitial_session.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../helpers/fake_stores.dart';
import '../helpers/test_app.dart';

/// The Settings tab, driven through the shell that ships (`QrScannerApp`): the
/// providers, the language resolution and the themes are the real ones, and
/// the test reaches Settings the way the user does, from the bottom bar
/// (SCAN-1).
void main() {
  group('SettingsScreen', () {
    group('General (SET-1, SET-2, SET-3, LANG-1)', () {
      testWidgets('LANG-2: shows both switchers in English', (
        WidgetTester tester,
      ) async {
        await _pumpSettings(tester);

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        // Theme's "System default" is a chip; language's is the closed
        // dropdown, showing the chosen language and no other (LANG-1,
        // changed 2026-09-21).
        expect(find.text('System default'), findsNWidgets(2));
        expect(find.text('English'), findsNothing);
        expect(find.text('العربية'), findsNothing);

        await _openLanguageMenu(tester);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('العربية'), findsOneWidget);
        // The screen's own title; the rail says the same word in capitals.
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('SETTINGS'), findsOneWidget);
      });

      testWidgets(
        'LANG-1, LANG-5: a stored Arabic language shows Arabic text and lays '
        'the screen out right to left',
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
        'SET-1: the app opens on its own chassis, and choosing Light stores '
        'that and repaints the app light',
        (WidgetTester tester) async {
          final _Harness harness = await _pumpSettings(tester);
          // Dark whatever the phone says: the chassis is the app's own.
          expect(harness.settings.themeMode, ThemeMode.dark);
          expect(_brightnessOnScreen(tester), Brightness.dark);
          expect(
            find.descendant(
              of: find.byKey(GeneralSection.darkThemeKey),
              matching: find.byIcon(Icons.check),
            ),
            findsOneWidget,
          );

          await _tapShown(tester, find.byKey(GeneralSection.lightThemeKey));
          await tester.pumpAndSettle();

          expect(harness.settings.themeMode, ThemeMode.light);
          expect(
            harness.store.writes,
            contains('set settings.theme_mode=light'),
          );
          expect(_brightnessOnScreen(tester), Brightness.light);
          // The chosen option is not colour alone: it carries a tick (A11Y-6).
          expect(
            find.descendant(
              of: find.byKey(GeneralSection.lightThemeKey),
              matching: find.byIcon(Icons.check),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'SET-2: sound off and vibrate on by default; each switch writes '
        'before it changes',
        (WidgetTester tester) async {
          final _Harness harness = await _pumpSettings(tester);
          _expectSwitch(tester, GeneralSection.soundOnScanKey, isFalse);
          _expectSwitch(tester, GeneralSection.vibrateOnScanKey, isTrue);

          await _tapShown(tester, find.byKey(GeneralSection.soundOnScanKey));
          await tester.pumpAndSettle();

          expect(harness.settings.soundOnScan, isTrue);
          expect(
            harness.store.writes,
            contains('set settings.sound_on_scan=1'),
          );
          _expectSwitch(tester, GeneralSection.soundOnScanKey, isTrue);
        },
      );

      testWidgets('SET-3: copy on scan off by default, and persists on', (
        WidgetTester tester,
      ) async {
        final _Harness harness = await _pumpSettings(tester);
        _expectSwitch(tester, GeneralSection.copyOnScanKey, isFalse);

        await _tapShown(tester, find.byKey(GeneralSection.copyOnScanKey));
        await tester.pumpAndSettle();

        expect(harness.settings.copyOnScan, isTrue);
        expect(harness.store.writes, contains('set settings.copy_on_scan=1'));
      });

      testWidgets(
        'LANG-1: choosing العربية stores the language and the app follows '
        'it without a restart',
        (WidgetTester tester) async {
          final _Harness harness = await _pumpSettings(tester);
          expect(find.text('Language'), findsOneWidget);

          // The dropdown is closed to begin with, so no language but the
          // chosen one is on screen (LANG-1, changed 2026-09-21).
          expect(find.text('العربية'), findsNothing);
          await _openLanguageMenu(tester);
          expect(find.byKey(Key(languageChoiceKey('ar'))), findsOneWidget);
          // Tapped by its name, which is what the user has to aim at: the
          // menu item's own box sits outside the hit path, so tapping the
          // key warns even where it works.
          await tester.tap(find.text('العربية'));
          await tester.pumpAndSettle();

          expect(harness.settings.localeOverride, const Locale('ar'));
          expect(harness.store.writes, contains('set settings.language=ar'));
          expect(find.text('اللغة'), findsOneWidget);
          // The rail follows too, and Settings stays the open tab.
          expect(find.text('الإعدادات'), findsNWidgets(2));
          expect(_directionOnScreen(tester), TextDirection.rtl);
        },
      );

      testWidgets(
        'a write that fails changes nothing and says so in the app language',
        (WidgetTester tester) async {
          final _Harness harness = await _pumpSettings(tester);
          harness.store.failingKeys.add(SettingsState.themeModeKey);

          await _tapShown(tester, find.byKey(GeneralSection.lightThemeKey));
          await tester.pumpAndSettle();

          expect(harness.settings.themeMode, ThemeMode.dark);
          expect(_brightnessOnScreen(tester), Brightness.dark);
          expect(find.text('Nothing was saved. Try again.'), findsOneWidget);

          // Let the snackbar time out, so no timer is left pending.
          await tester.pumpAndSettle(const Duration(seconds: 5));
        },
      );
    });

    group('Privacy (HIS-8, PRIV-2, PRIV-3)', () {
      testWidgets('save history is on by default and persists off (HIS-8)', (
        WidgetTester tester,
      ) async {
        final _Harness harness = await _pumpSettings(tester);
        _expectSwitch(tester, PrivacySection.saveHistoryKey, isTrue);

        await _tapShown(tester, find.byKey(PrivacySection.saveHistoryKey));
        await tester.pumpAndSettle();

        expect(harness.settings.saveHistory, isFalse);
        expect(harness.store.writes, contains('set settings.save_history=0'));
      });

      testWidgets(
        'the crash-report row is absent: Firebase is not wired in yet '
        '(PRIV-3, PRIV-8)',
        (WidgetTester tester) async {
          await _pumpSettings(tester);

          expect(find.byKey(PrivacySection.sendCrashReportsKey), findsNothing);
          expect(find.text('Send crash reports'), findsNothing);
        },
      );

      testWidgets(
        'privacy options is absent when the region needs none (PRIV-2)',
        (WidgetTester tester) async {
          await _pumpSettings(
            tester,
            services: AppServices.fakes().copyWith(
              consent: NoopConsentService(privacyOptionsRequired: false),
            ),
          );

          expect(find.byKey(PrivacySection.privacyOptionsKey), findsNothing);
        },
      );

      testWidgets('privacy options shows and reopens the consent form when the '
          'region needs it (PRIV-2)', (WidgetTester tester) async {
        final NoopConsentService consent = NoopConsentService(
          privacyOptionsRequired: true,
        );
        await _pumpSettings(
          tester,
          services: AppServices.fakes().copyWith(consent: consent),
        );

        expect(find.byKey(PrivacySection.privacyOptionsKey), findsOneWidget);
        await _tapShown(tester, find.byKey(PrivacySection.privacyOptionsKey));
        await tester.pumpAndSettle();

        expect(consent.calls, contains('showPrivacyOptions'));
      });
    });

    group('Pro (PRO-1, PRO-2, PRO-4, PRO-5, PRO-6)', () {
      testWidgets('shows the store\'s own price, and no other price or '
          'discount (PRO-5)', (WidgetTester tester) async {
        await _pumpSettings(
          tester,
          services: AppServices.fakes().copyWith(
            billing: NoopBillingService(
              product: const StoreProduct(
                id: ProState.removeAdsProductId,
                title: 'Remove ads',
                formattedPrice: r'$1.99',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Remove ads'), findsOneWidget);
        expect(find.textContaining(r'$1.99'), findsOneWidget);
      });

      testWidgets('restore purchase reports what it found (PRO-6)', (
        WidgetTester tester,
      ) async {
        await _pumpSettings(
          tester,
          services: AppServices.fakes().copyWith(billing: NoopBillingService()),
        );

        await _tapShown(tester, find.byKey(ProSection.restorePurchaseKey));
        await tester.pumpAndSettle();

        expect(find.text('No previous purchase was found.'), findsOneWidget);
      });

      testWidgets(
        'once owned, says so instead of offering to buy, and shows no ads '
        '(PRO-2, PRO-4, ADS-7)',
        (WidgetTester tester) async {
          await _pumpSettings(
            tester,
            services: AppServices.fakes().copyWith(
              billing: NoopBillingService(
                owned: <String>{ProState.removeAdsProductId},
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Ads removed'), findsOneWidget);
          expect(find.text('Remove ads'), findsNothing);
          expect(find.byType(AdBannerSlot), findsOneWidget);
          expect(find.byType(Divider), findsNothing);
        },
      );
    });

    group('About (SET-6, SET-7, SET-8)', () {
      testWidgets('shows the version once loaded (SET-5)', (
        WidgetTester tester,
      ) async {
        await _pumpSettings(
          tester,
          versionInfo: NoopAppVersionInfo(
            details: const AppVersionDetails(
              version: '1.4.0',
              buildNumber: '27',
              androidVersion: 'Android 14',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1.4.0 (27)'), findsOneWidget);
      });

      testWidgets('opens the privacy policy in Custom Tabs (SET-6, LINK-8)', (
        WidgetTester tester,
      ) async {
        final NoopLinkOpener linkOpener = NoopLinkOpener();
        await _pumpSettings(
          tester,
          services: AppServices.fakes().copyWith(linkOpener: linkOpener),
        );

        await _tapShown(tester, find.byKey(AboutSection.privacyPolicyKey));
        await tester.pumpAndSettle();

        expect(linkOpener.openedUrls, hasLength(1));
        expect(linkOpener.openedUrls.single.toString(), privacyPolicyUrl);
      });

      testWidgets('opens the feedback screen (SET-8)', (
        WidgetTester tester,
      ) async {
        await _pumpSettings(tester);

        await _tapShown(tester, find.byKey(AboutSection.feedbackKey));
        await tester.pumpAndSettle();

        expect(find.byType(FeedbackScreen), findsOneWidget);
      });
    });

    testWidgets('SET-5: the four groups appear General, Privacy, Pro, About, '
        'top to bottom', (WidgetTester tester) async {
      await _pumpSettings(tester);

      final double general = tester.getTopLeft(find.text('GENERAL')).dy;
      final double privacy = tester.getTopLeft(find.text('PRIVACY')).dy;
      final double pro = tester.getTopLeft(find.text('PRO')).dy;
      final double about = tester.getTopLeft(find.text('ABOUT')).dy;

      expect(general, lessThan(privacy));
      expect(privacy, lessThan(pro));
      expect(pro, lessThan(about));
    });

    group('the ADS-1 banner slot', () {
      testWidgets('is absent before the install\'s first success (ADS-6)', (
        WidgetTester tester,
      ) async {
        await _pumpSettings(tester, services: _eligibleAdsServices());

        expect(find.byType(AdBannerSlot), findsOneWidget);
        expect(find.byType(Divider), findsNothing);
      });

      testWidgets(
        'is present, fixed and non-scrolling, once eligible (ADS-1, ADS-3)',
        (WidgetTester tester) async {
          final SuccessCounts successCounts = SuccessCounts(
            FakeKeyValueStore(),
          );
          await successCounts.load();
          await successCounts.recordSuccessfulScan();

          await _pumpSettings(
            tester,
            services: _eligibleAdsServices(),
            successCounts: successCounts,
          );
          await tester.pumpAndSettle();

          expect(find.byType(Divider), findsOneWidget);
          // Fixed and non-scrolling: outside the scroll view, not inside it.
          expect(
            find.ancestor(
              of: find.byType(AdBannerSlot),
              matching: find.byType(SingleChildScrollView),
            ),
            findsNothing,
          );
        },
      );
    });

    testWidgets('A11Y-1: every switcher option carries its own screen-reader '
        'label', (WidgetTester tester) async {
      // Released inside the test body: the framework checks for live handles
      // before tearDowns run.
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pumpSettings(tester);

      final List<(Key, String)> expected = <(Key, String)>[
        (GeneralSection.systemThemeKey, 'System default'),
        (GeneralSection.lightThemeKey, 'Light'),
        (GeneralSection.darkThemeKey, 'Dark'),
      ];
      for (final (Key key, String label) in expected) {
        expect(
          tester.getSemantics(find.byKey(key)),
          isSemantics(label: label, isButton: true, hasTapAction: true),
          reason: '$label must be announced by its own name',
        );
      }

      // The languages live in the dropdown now (LANG-1, changed
      // 2026-09-21), so they are announced once it is open. Every one
      // announces its own untranslated name, so a screen reader set to that
      // language says something its user can recognise.
      await _openLanguageMenu(tester);
      final List<(Key, String)> languages = <(Key, String)>[
        (GeneralSection.systemLanguageKey, 'System default'),
        for (final MapEntry<String, String> language in appLanguages.entries)
          (Key(languageChoiceKey(language.key)), language.value),
      ];
      for (final (Key key, String label) in languages) {
        expect(
          tester.getSemantics(await _languageInMenu(tester, key)),
          isSemantics(label: label),
          reason: '$label must be announced by its own name',
        );
      }
      // The chosen option announces that it is the chosen one: the app's own
      // chassis to begin with (SET-1).
      expect(
        tester.getSemantics(find.byKey(GeneralSection.darkThemeKey)),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.byKey(GeneralSection.systemThemeKey)),
        isSemantics(isSelected: false),
      );
      semantics.dispose();
    });

    testWidgets('A11Y-2: every switcher option is at least 48 x 48 dp', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      // The closed dropdown is a tap target of its own, and the languages
      // inside it are targets once it is open (LANG-1, changed 2026-09-21).
      void expectLargeEnough(Finder option, Object name) {
        final Size size = tester.getSize(option);
        expect(
          size.width,
          greaterThanOrEqualTo(AppTheme.minTapTargetSize),
          reason: '$name is too narrow to tap',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(AppTheme.minTapTargetSize),
          reason: '$name is too short to tap',
        );
      }

      for (final Key option in <Key>[
        GeneralSection.systemThemeKey,
        GeneralSection.lightThemeKey,
        GeneralSection.darkThemeKey,
        GeneralSection.languageDropdownKey,
      ]) {
        expectLargeEnough(find.byKey(option), option);
      }

      await _openLanguageMenu(tester);
      for (final Key option in <Key>[
        GeneralSection.systemLanguageKey,
        for (final String languageCode in appLanguages.keys)
          Key(languageChoiceKey(languageCode)),
      ]) {
        expectLargeEnough(await _languageInMenu(tester, option), option);
      }
    });
  });
}

/// What a test needs to look behind the screen: the state it drives and the
/// rows the store was told to write.
class _Harness {
  const _Harness({required this.settings, required this.store});

  final SettingsState settings;
  final FakeKeyValueStore store;
}

/// [AppServices] with consent already resolved to "no message needed" and no
/// Pro ownership, so the ADS-1 banner slot is eligible as soon as the install
/// has its first success. Used only by the banner-slot tests: every other
/// test above keeps the default fakes, under which consent stays unresolved
/// and the slot never shows (ADS-5) — itself already covered.
AppServices _eligibleAdsServices() => AppServices.fakes().copyWith(
  ads: NoopAdsService(),
  consent: NoopConsentService(seededStatus: ConsentStatus.notNeeded),
);

/// Builds the real app shell over an in-memory store and the no-op services,
/// then opens the Settings tab from the bottom bar, so a test drives the
/// widget tree that ships.
Future<_Harness> _pumpSettings(
  WidgetTester tester, {
  Map<String, String>? stored,
  List<Locale>? deviceLanguages,
  AppServices? services,
  SuccessCounts? successCounts,
  AppVersionInfo? versionInfo,
}) async {
  if (deviceLanguages != null) {
    // Set before the first frame, so the shell resolves the language from
    // this list the way it would at launch, and put the real list back
    // afterwards.
    tester.platformDispatcher.localesTestValue = deviceLanguages;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  // The phone this app is drawn for, the same surface `pumpApp` uses, so a
  // control sits where it would on a phone rather than on a wide desktop
  // window.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = phoneSurfaceSize;
  addTearDown(tester.view.reset);

  final FakeKeyValueStore store = FakeKeyValueStore(stored);
  final SettingsState settings = SettingsState(store);
  await settings.load();
  final SuccessCounts counts = successCounts ?? SuccessCounts(store);
  if (successCounts == null) {
    await counts.load();
  }
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
  final AppServices baseServices = services ?? AppServices.fakes();
  final AppServices appServices = versionInfo == null
      ? baseServices
      : baseServices.copyWith(versionInfo: versionInfo);
  final ProState proState = ProState(
    billing: appServices.billing,
    store: FakeKeyValueStore(),
    successCounts: counts,
  );
  await proState.load();
  await proState.startupCheck;
  addTearDown(proState.dispose);

  await tester.pumpWidget(
    QrScannerApp(
      settings: settings,
      successCounts: counts,
      records: records,
      services: appServices,
      proState: proState,
      interstitialSession: InterstitialSession(),
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

/// Reads the [Switch] found by [key] and asserts its value, so a test names
/// the setting instead of Flutter's own widget shape.
void _expectSwitch(WidgetTester tester, Key key, Matcher isOn) {
  final SwitchListTile tile = tester.widget(find.byKey(key));
  expect(tile.value, isOn);
}

/// The brightness the screen is actually painted with (SET-1).
Brightness _brightnessOnScreen(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(SettingsScreen))).brightness;

/// The direction the screen is laid out in (LANG-5).
TextDirection _directionOnScreen(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(SettingsScreen)));

/// Scrolls [finder] into view, then taps it: Settings is taller than the test
/// surface, and a tap below its bottom edge would land on nothing.
/// Opens the language dropdown, so the languages are in the tree at all
/// (LANG-1). Closed, it builds only the chosen name.
Future<void> _openLanguageMenu(WidgetTester tester) async {
  await _tapShown(tester, find.byKey(GeneralSection.languageDropdownKey));
  await tester.pumpAndSettle();
}

/// Scrolls the open dropdown to one language and returns its finder.
///
/// The menu is a lazy list: with twenty-one options only those near the top
/// are built, so a test that walks every language has to bring each one into
/// view rather than assume it is already there.
Future<Finder> _languageInMenu(WidgetTester tester, Key key) async {
  final Finder item = find.byKey(key);
  await tester.scrollUntilVisible(
    item,
    56,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  return item;
}

Future<void> _tapShown(WidgetTester tester, Finder finder) async {
  // Settings is taller than the screen, so a control below the fold is
  // scrolled to first — but only then. Scrolling one that is already on
  // screen would park it under the app bar, where a tap lands on the bar.
  if (!_isTappable(tester, finder)) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    final double under = _appBarBottom - tester.getRect(finder).top;
    if (under > 0) {
      await tester.drag(find.byType(Scrollable), Offset(0, under + 8));
      await tester.pumpAndSettle();
    }
  }
  await tester.tap(finder);
}

/// Where a control has to start to be clear of the app bar above it.
const double _appBarBottom = kToolbarHeight;

/// Whether [finder]'s control is wholly on screen and clear of the app bar,
/// so a tap on its centre reaches it.
bool _isTappable(WidgetTester tester, Finder finder) {
  final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
  final Rect rect = tester.getRect(finder);
  return rect.top >= _appBarBottom && rect.bottom <= screen.height;
}
