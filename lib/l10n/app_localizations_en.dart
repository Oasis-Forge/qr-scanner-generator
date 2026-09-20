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
  String get scanReadyStatus => 'Ready';

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
  String settingsRemoveAdsPrice(String price) {
    return 'One-time purchase · $price';
  }

  @override
  String get settingsProOwned => 'Ads removed';

  @override
  String get proBuyFailed => 'Could not complete the purchase. Try again.';

  @override
  String get proRestoreSuccess => 'Purchase restored.';

  @override
  String get proRestoreNotFound => 'No previous purchase was found.';

  @override
  String get proRestoreFailed => 'Could not check the store. Try again.';

  @override
  String get proPromptTitle => 'Remove ads?';

  @override
  String get proPromptBody => 'A one-time purchase, never a subscription.';

  @override
  String get proPromptDismissTooltip => 'Dismiss';

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
  String get settingsLinkOpenFailed => 'Could not open the link.';

  @override
  String get feedbackCategoryLabel => 'Category';

  @override
  String get feedbackCategoryScanning => 'Scanning';

  @override
  String get feedbackCategoryResults => 'Results';

  @override
  String get feedbackCategoryCreatingCodes => 'Creating codes';

  @override
  String get feedbackCategoryAds => 'Ads';

  @override
  String get feedbackCategoryOther => 'Other';

  @override
  String get feedbackMessageHint => 'What happened, and what did you expect?';

  @override
  String get feedbackSendButton => 'Send';

  @override
  String get feedbackSendNoHandler => 'No email app is set up on this device.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle feedback ($version+$build, $androidVersion)';
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
  String get historySegmentAll => 'All';

  @override
  String get historySegmentScanned => 'Scanned';

  @override
  String get historySegmentCreated => 'Created';

  @override
  String get historyEmptyMessage =>
      'Codes you scan or create will show up here.';

  @override
  String get historyEmptyScanButton => 'Scan a code';

  @override
  String get historyEmptyCreateButton => 'Create a code';

  @override
  String get historyEmptyNotSavingMessage => 'New scans aren\'t being saved.';

  @override
  String get historyEmptySettingsButton => 'Go to Settings';

  @override
  String get historyLoading => 'Loading History';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items deleted',
      one: '1 item deleted',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Undo';

  @override
  String get historyDeleteFailed => 'Could not delete. Try again.';

  @override
  String get historyUndoFailed => 'Could not undo. Try again.';

  @override
  String get historyLoadFailed => 'History couldn\'t be loaded. Try again.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Delete';

  @override
  String get historyCancelSelectionButton => 'Cancel selection';

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

  @override
  String get copiedWhatPassword => 'the password';

  @override
  String get resultHandOffFailed => 'Could not open. Try again.';

  @override
  String get resultUnavailableWifiSettings =>
      'Wi-Fi settings can\'t be opened on this device.';

  @override
  String get resultUnavailableContacts => 'No contacts app is installed.';

  @override
  String get resultUnavailableCalendar => 'No calendar app is installed.';

  @override
  String get resultUnavailableDialer => 'No phone app is installed.';

  @override
  String get resultUnavailableSms => 'No messaging app is installed.';

  @override
  String get resultUnavailableEmail => 'No email app is installed.';

  @override
  String get resultUnavailableBrowser => 'No browser is installed.';

  @override
  String get resultLinkOpenButton => 'Open';

  @override
  String get resultLinkReviewButton => 'Review';

  @override
  String get resultLinkWarningTitle => 'Before you open this link';

  @override
  String get resultLinkCheckIpAddressHost =>
      'The address is a raw IP number, not a name';

  @override
  String get resultLinkCheckUserinfo =>
      'It contains a user name before the site name';

  @override
  String get resultLinkCheckInsecureScheme => 'It isn\'t encrypted (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'It uses an unusual port';

  @override
  String get resultLinkCheckLongUrl => 'It\'s unusually long';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Copy without opening';

  @override
  String get resultLinkOpenAnywayButton => 'Open anyway';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme links can\'t be opened here.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'This app checks links before opening them, so you can see where they lead first.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Dismiss';

  @override
  String get resultWifiNetworkNameLabel => 'Network name';

  @override
  String get resultWifiSecurityLabel => 'Security';

  @override
  String get resultWifiPasswordLabel => 'Password';

  @override
  String get resultWifiRevealPasswordTooltip => 'Show password';

  @override
  String get resultWifiHidePasswordTooltip => 'Hide password';

  @override
  String get resultWifiWepNotice =>
      'Android can\'t join WEP networks from apps.';

  @override
  String get resultWifiPrimaryButton => 'Open Wi-Fi settings';

  @override
  String get resultWifiCopyPasswordButton => 'Copy password';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Open';

  @override
  String get resultContactNameLabel => 'Name';

  @override
  String get resultContactPhoneLabel => 'Phone';

  @override
  String get resultContactEmailLabel => 'Email';

  @override
  String get resultContactOrganisationLabel => 'Organisation';

  @override
  String get resultContactPrimaryButton => 'Add to contacts';

  @override
  String get resultEventTitleLabel => 'Title';

  @override
  String get resultEventStartLabel => 'Start';

  @override
  String get resultEventEndLabel => 'End';

  @override
  String get resultEventLocationLabel => 'Location';

  @override
  String get resultEventNotesLabel => 'Notes';

  @override
  String get resultEventAllDayNotice => 'All-day event.';

  @override
  String resultEventTimeUtc(String time) {
    return '$time UTC';
  }

  @override
  String resultEventTimeZoned(String time, String zone) {
    return '$time ($zone)';
  }

  @override
  String get resultUnavailableEventNoStart =>
      'This event has no start time, so it can\'t be added.';

  @override
  String get resultEventPrimaryButton => 'Add to calendar';

  @override
  String get resultPhoneNumberLabel => 'Number';

  @override
  String get resultPhonePrimaryButton => 'Call';

  @override
  String get resultSmsNumberLabel => 'Number';

  @override
  String get resultSmsMessageLabel => 'Message';

  @override
  String get resultSmsPrimaryButton => 'Message';

  @override
  String get resultEmailToLabel => 'To';

  @override
  String get resultEmailSubjectLabel => 'Subject';

  @override
  String get resultEmailBodyLabel => 'Message';

  @override
  String get resultEmailPrimaryButton => 'Email';

  @override
  String get resultProductNumberLabel => 'Number';

  @override
  String get resultProductFormatLabel => 'Format';

  @override
  String get resultProductFormatEan13 => 'EAN-13';

  @override
  String get resultProductFormatEan8 => 'EAN-8';

  @override
  String get resultProductFormatUpcA => 'UPC-A';

  @override
  String get resultProductFormatUpcE => 'UPC-E';

  @override
  String get resultProductFormatIsbn => 'ISBN';

  @override
  String get resultProductSearchButton => 'Search the web';

  @override
  String get resultLocationLatitudeLabel => 'Latitude';

  @override
  String get resultLocationLongitudeLabel => 'Longitude';

  @override
  String get resultLocationNameLabel => 'Name';

  @override
  String get createSubtitle => 'Choose what to create';

  @override
  String get createUrlFieldLabel => 'Web address';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'The code opens $url';
  }

  @override
  String get createTextFieldLabel => 'Text';

  @override
  String get createTextFieldHint => 'Anything you want the code to say';

  @override
  String get createWifiSsidLabel => 'Network name';

  @override
  String get createWifiSecurityLabel => 'Security';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (insecure)';

  @override
  String get createWifiPasswordLabel => 'Password';

  @override
  String get createWifiHiddenLabel => 'Hidden network';

  @override
  String get createContactNameLabel => 'Name';

  @override
  String get createContactPhoneLabel => 'Phone (optional)';

  @override
  String get createContactEmailLabel => 'Email (optional)';

  @override
  String get createContactOrganisationLabel => 'Organisation (optional)';

  @override
  String get createPhoneFieldLabel => 'Phone number';

  @override
  String get createEmailToLabel => 'Email address';

  @override
  String get createEmailSubjectLabel => 'Subject (optional)';

  @override
  String get createEmailBodyLabel => 'Message (optional)';

  @override
  String get createSmsNumberLabel => 'Phone number';

  @override
  String get createSmsMessageLabel => 'Message (optional)';

  @override
  String get createFieldErrorRequired => 'This field is required.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Enter a web address starting with http:// or https://.';

  @override
  String get createFieldErrorInvalidEmail => 'Enter a valid email address.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Enter a phone number with 3 to 15 digits.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% of capacity used';
  }

  @override
  String get createCapacityOverLimit =>
      'This is too much content for a QR code. Shorten it to continue.';

  @override
  String get createButtonLabel => 'Create';

  @override
  String get createCheckingMessage => 'Checking the code scans correctly';

  @override
  String get createContentLabel => 'Content';

  @override
  String get createCodeImageLabel => 'The created QR code';

  @override
  String get createCheckFailedRenderFailed =>
      'The code could not be created. Shorten the content and try again.';

  @override
  String get createCheckFailedDecodeFailed =>
      'This code could not be checked. Save and Share are turned off.';

  @override
  String get createCheckFailedMismatch =>
      'This code did not match what you entered. Save and Share are turned off.';

  @override
  String get createNotSavedToHistory =>
      'This code could not be saved to History.';

  @override
  String get createSaveButton => 'Save';

  @override
  String get createShareButton => 'Share';

  @override
  String get createSavedSnackbarNoName => 'Code saved';

  @override
  String createSavedSnackbar(String name) {
    return 'Saved as $name';
  }

  @override
  String get createShareFailed => 'Could not open sharing. Try again.';
}
