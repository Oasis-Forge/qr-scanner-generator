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
  String get placeholderCreateMessage =>
      'Creating codes arrives in the next test build.';

  @override
  String get placeholderHistoryMessage =>
      'The History list arrives in the next test build. Your scans are already kept on this phone.';

  @override
  String get scanTargetHint => 'Point the camera at a code';

  @override
  String get scanCameraUnavailable =>
      'The camera could not start. Another app may be using it.';

  @override
  String get scanTorchOn => 'Turn on the torch';

  @override
  String get scanTorchOff => 'Turn off the torch';

  @override
  String get scanZoomLabel => 'Zoom';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Reading the photo';

  @override
  String get scanPhotoPickerFailed =>
      'The photo picker did not open. Try again.';

  @override
  String get scanSettingsDidNotOpen =>
      'Settings did not open. Allow the camera from your phone settings.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format detected: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type detected';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes detected',
      one: '1 code detected',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes found',
      one: '1 code found',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Choose the code to open.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Binary data, $count bytes',
      one: 'Binary data, 1 byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'No code found';

  @override
  String get noCodeFoundHint =>
      'Make sure the whole code is in the photo, sharp and well lit.';

  @override
  String get tryAnotherPhotoButton => 'Try another photo';

  @override
  String get actionClose => 'Close';

  @override
  String get manualEntryTitle => 'Type a code';

  @override
  String get manualEntryFieldLabel => 'Code content';

  @override
  String get manualEntryFieldHint => 'A link, some text or a barcode number';

  @override
  String get manualEntryScanButton => 'Scan';

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
  String get copiedWhatLink => 'the link';

  @override
  String get copiedWhatContent => 'the content';

  @override
  String get resultTitle => 'Result';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Copy';

  @override
  String get resultShareButton => 'Share';

  @override
  String get resultNotSaved => 'This scan could not be saved to History.';

  @override
  String get resultCopyFailed => 'Could not copy. Try again.';

  @override
  String get resultShareFailed => 'Could not open sharing. Try again.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Text';

  @override
  String get parsedTypeContact => 'Contact';

  @override
  String get parsedTypePhone => 'Phone number';

  @override
  String get parsedTypeEmail => 'Email';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Location';

  @override
  String get parsedTypeEvent => 'Event';

  @override
  String get parsedTypeProduct => 'Product';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Unknown';

  @override
  String get symbologyQr => 'QR code';

  @override
  String get symbologyDataMatrix => 'Data Matrix';

  @override
  String get symbologyPdf417 => 'PDF417';

  @override
  String get symbologyAztec => 'Aztec';

  @override
  String get symbologyCode128 => 'Code 128';

  @override
  String get symbologyCode39 => 'Code 39';

  @override
  String get symbologyCode93 => 'Code 93';

  @override
  String get symbologyCodabar => 'Codabar';

  @override
  String get symbologyItf => 'ITF';

  @override
  String get symbologyEan13 => 'EAN-13';

  @override
  String get symbologyEan8 => 'EAN-8';

  @override
  String get symbologyUpcA => 'UPC-A';

  @override
  String get symbologyUpcE => 'UPC-E';

  @override
  String get symbologyUnknown => 'Unknown format';

  @override
  String get errorStorageUnavailable =>
      'The app cannot open its storage. Close it and open it again.';

  @override
  String get errorSaveFailed => 'Nothing was saved. Try again.';

  @override
  String get actionRetry => 'Retry';
}
