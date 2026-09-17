import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// LANG-2. The app name, shown in the task switcher and as the fallback screen title.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner + Generator'**
  String get appTitle;

  /// SCAN-1. Bottom navigation destination for the live scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// SCAN-1. Bottom navigation destination for the code generator.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// SCAN-1. Bottom navigation destination for the list of scanned and created codes.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// SCAN-1. Bottom navigation destination for Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// RUN-1. The one reason shown on the scanner placeholder before the camera is allowed. Translations must stay at or under 70 characters.
  ///
  /// In en, this message translates to:
  /// **'The camera is used only to read codes on this device.'**
  String get cameraPermissionReason;

  /// RUN-1. Largest control on the scanner placeholder; opens the system camera prompt.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get cameraAllowButton;

  /// RUN-6. Replaces the allow button once Android will not show its prompt again; opens the app permission page.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get cameraOpenSettingsButton;

  /// RUN-4, SCAN-11. Opens the system photo picker to decode a code from an image.
  ///
  /// In en, this message translates to:
  /// **'Scan a photo'**
  String get scanFromPhotoButton;

  /// RUN-4, SCAN-12. Opens typed entry, which runs the same parsers as a camera scan.
  ///
  /// In en, this message translates to:
  /// **'Type a code'**
  String get typeCodeButton;

  /// SET-5. First Settings group: theme, language, sound, vibration, copy on scan, search engine.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// SET-5. Second Settings group: save history, send crash reports, privacy options.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsGroupPrivacy;

  /// SET-5, PRO-1. Third Settings group: remove ads, restore purchase. Pro is the product name, not a description.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get settingsGroupPro;

  /// SET-5. Fourth Settings group: feedback, privacy policy, open-source licences, version.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsGroupAbout;

  /// SET-1, SET-5. Settings row that opens the theme choice.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// LANG-1, SET-5. Settings row that opens the language choice.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// SET-2, SET-5. Switch for the scan sound, off by default.
  ///
  /// In en, this message translates to:
  /// **'Sound on scan'**
  String get settingsSoundOnScan;

  /// SET-2, SET-5. Switch for the scan vibration, on by default.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on scan'**
  String get settingsVibrateOnScan;

  /// SET-3, SET-5. Switch that copies the decoded text once the result is on screen, off by default.
  ///
  /// In en, this message translates to:
  /// **'Copy on scan'**
  String get settingsCopyOnScan;

  /// SET-4, SET-5. Settings row that chooses the engine used by Search the web.
  ///
  /// In en, this message translates to:
  /// **'Search engine'**
  String get settingsSearchEngine;

  /// HIS-8, SET-5. Switch that stores scans and created codes, on by default.
  ///
  /// In en, this message translates to:
  /// **'Save history'**
  String get settingsSaveHistory;

  /// PRIV-3, SET-5. Switch that turns on crash reporting, off by default.
  ///
  /// In en, this message translates to:
  /// **'Send crash reports'**
  String get settingsSendCrashReports;

  /// PRIV-2, SET-5. Settings row shown only where the consent SDK reports the region needs it.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get settingsPrivacyOptions;

  /// PRO-4, SET-5. Settings row that starts the one-time Pro purchase.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get settingsRemoveAds;

  /// PRO-1, PRO-3, PRO-5. Second line under Remove ads. Never a subscription, and no price or discount is shown here.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get settingsRemoveAdsSubtitle;

  /// PRO-6, SET-5. Settings row next to Remove ads that re-checks ownership.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get settingsRestorePurchase;

  /// SET-8, SET-5. Settings row that opens the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// SET-6, SET-5. Settings row that opens the published policy in Custom Tabs.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// SET-7, SET-5. Settings row that opens the Flutter licence page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsOpenSourceLicences;

  /// SET-5. Label of the last About row.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// SET-5. Value of the version row: the SemVer name followed by the build number in brackets.
  ///
  /// In en, this message translates to:
  /// **'{version} ({build})'**
  String settingsVersionValue(String version, String build);

  /// SET-1. Theme choice that follows the phone setting; the initial choice.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemDefault;

  /// SET-1. Light theme choice.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// SET-1. Dark theme choice.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// LANG-1. Language choice that follows the device language and falls back to English. Kept apart from themeSystemDefault because languages that inflect need different wording here.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// LANG-1. English, written in its own language; the same in every message file.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// LANG-1. Arabic, written in its own language; the same in every message file.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// DATE-2, HIS-3. Date header for rows from the current local calendar day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyHeaderToday;

  /// DATE-2, HIS-3. Date header for rows from the previous local calendar day.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyHeaderYesterday;

  /// DATE-2, HIS-3, LANG-3. Date header for rows from the last 7 days: the weekday name in the app language.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String historyHeaderWeekday(DateTime date);

  /// DATE-2, HIS-3, LANG-3. Date header for older rows: the local calendar day formatted for the app language.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String historyHeaderDate(DateTime date);

  /// HIS-4, LANG-3. Shown on a history row when the code was seen 2 or more times; the number follows the app language.
  ///
  /// In en, this message translates to:
  /// **'×{count}'**
  String historySeenCount(int count);

  /// HIS-6, DATA-8. A count of codes, used for a saved batch row and for empty states.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No codes} one{1 code} other{{count} codes}}'**
  String historyCodeCount(int count);

  /// SET-3, RES-2. Snackbar confirming what was copied. The placeholder takes an already translated noun, such as the link or the password.
  ///
  /// In en, this message translates to:
  /// **'Copied {what}'**
  String copiedSnackbar(String what);

  /// LANG-2. Fills the screen when the app database will not open at launch, so the app says what happened instead of crashing or showing a blank frame. Not errorSaveFailed: nothing was being saved.
  ///
  /// In en, this message translates to:
  /// **'The app cannot open its storage. Close it and open it again.'**
  String get errorStorageUnavailable;

  /// Reliable writes: shown when a write fails and the change was rolled back, so no partial record is left.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Try again.'**
  String get errorSaveFailed;

  /// Button that runs the failed action again, shown with errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
