// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Scan';

  @override
  String get navCreate => 'Create';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get cameraPermissionReason =>
      'The camera is used only to read codes on this device.';

  @override
  String get cameraAllowButton => 'Allow camera';

  @override
  String get cameraOpenSettingsButton => 'Open settings';

  @override
  String get scanFromPhotoButton => 'Scan a photo';

  @override
  String get typeCodeButton => 'Type a code';

  @override
  String get settingsGroupGeneral => 'General';

  @override
  String get settingsGroupPrivacy => 'Privacy';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSoundOnScan => 'Sound on scan';

  @override
  String get settingsVibrateOnScan => 'Vibrate on scan';

  @override
  String get settingsCopyOnScan => 'Copy on scan';

  @override
  String get settingsSearchEngine => 'Search engine';

  @override
  String get settingsSaveHistory => 'Save history';

  @override
  String get settingsSendCrashReports => 'Send crash reports';

  @override
  String get settingsPrivacyOptions => 'Privacy options';

  @override
  String get settingsRemoveAds => 'Remove ads';

  @override
  String get settingsRemoveAdsSubtitle => 'One-time purchase';

  @override
  String get settingsRestorePurchase => 'Restore purchase';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsOpenSourceLicences => 'Open-source licences';

  @override
  String get settingsVersion => 'Version';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get themeSystemDefault => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get historyHeaderToday => 'Today';

  @override
  String get historyHeaderYesterday => 'Yesterday';

  @override
  String historyHeaderWeekday(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.EEEE(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String historyHeaderDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String historySeenCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '×$countString';
  }

  @override
  String historyCodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes',
      one: '1 code',
      zero: 'No codes',
    );
    return '$_temp0';
  }

  @override
  String copiedSnackbar(String what) {
    return 'Copied $what';
  }

  @override
  String get errorStorageUnavailable =>
      'The app cannot open its storage. Close it and open it again.';

  @override
  String get errorSaveFailed => 'Nothing was saved. Try again.';

  @override
  String get actionRetry => 'Retry';
}
