// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'স্ক্যান';

  @override
  String get navCreate => 'তৈরি';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get cameraPermissionReason =>
      'এই ডিভাইসে কোড পড়ার জন্যই কেবল ক্যামেরা ব্যবহার করা হয়।';

  @override
  String get cameraAllowButton => 'ক্যামেরার অনুমতি দিন';

  @override
  String get cameraOpenSettingsButton => 'সেটিংস খুলুন';

  @override
  String get scanFromPhotoButton => 'ছবি স্ক্যান করুন';

  @override
  String get typeCodeButton => 'কোড টাইপ করুন';

  @override
  String get placeholderCreateMessage =>
      'কোড তৈরি করার সুবিধা পরের টেস্ট বিল্ডে আসছে।';

  @override
  String get placeholderHistoryMessage =>
      'ইতিহাসের তালিকা পরের টেস্ট বিল্ডে আসছে। আপনার স্ক্যানগুলি এই ফোনেই রাখা আছে।';

  @override
  String get scanReadyStatus => 'প্রস্তুত';

  @override
  String get scanTargetHint => 'ক্যামেরা কোডের দিকে ধরুন';

  @override
  String get scanCameraUnavailable =>
      'ক্যামেরা চালু করা যায়নি। অন্য কোনও অ্যাপ হয়তো এটি ব্যবহার করছে।';

  @override
  String get scanTorchOn => 'টর্চ জ্বালান';

  @override
  String get scanTorchOff => 'টর্চ নেভান';

  @override
  String get scanZoomLabel => 'জুম';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'ছবি পড়া হচ্ছে';

  @override
  String get scanPhotoPickerFailed =>
      'ছবি বাছাইয়ের জায়গাটি খোলেনি। আবার চেষ্টা করুন।';

  @override
  String get scanSettingsDidNotOpen =>
      'সেটিংস খোলেনি। ফোনের সেটিংস থেকে ক্যামেরার অনুমতি দিন।';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format শনাক্ত হয়েছে: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type শনাক্ত হয়েছে';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কোড শনাক্ত হয়েছে',
      one: 'একটি কোড শনাক্ত হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কোড পাওয়া গেছে',
      one: 'একটি কোড পাওয়া গেছে',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'যে কোডটি খুলতে চান সেটি বেছে নিন।';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বাইনারি ডেটা, $count বাইট',
      one: 'বাইনারি ডেটা, এক বাইট',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'কোনও কোড পাওয়া যায়নি';

  @override
  String get noCodeFoundHint =>
      'দেখে নিন পুরো কোডটি ছবিতে আছে, স্পষ্ট এবং ভালো আলোয় তোলা।';

  @override
  String get tryAnotherPhotoButton => 'অন্য ছবি চেষ্টা করুন';

  @override
  String get actionClose => 'বন্ধ করুন';

  @override
  String get manualEntryTitle => 'কোড টাইপ করুন';

  @override
  String get manualEntryFieldLabel => 'কোডের বিষয়বস্তু';

  @override
  String get manualEntryFieldHint => 'একটি লিঙ্ক, কিছু লেখা বা বারকোড নম্বর';

  @override
  String get manualEntryScanButton => 'স্ক্যান করুন';

  @override
  String get settingsGroupGeneral => 'সাধারণ';

  @override
  String get settingsGroupPrivacy => 'গোপনীয়তা';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'সম্পর্কে';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsSoundOnScan => 'স্ক্যানে শব্দ';

  @override
  String get settingsVibrateOnScan => 'স্ক্যানে কম্পন';

  @override
  String get settingsCopyOnScan => 'স্ক্যানে কপি';

  @override
  String get settingsSearchEngine => 'সার্চ ইঞ্জিন';

  @override
  String get settingsSaveHistory => 'ইতিহাস সংরক্ষণ';

  @override
  String get settingsSendCrashReports => 'ক্র্যাশ রিপোর্ট পাঠান';

  @override
  String get settingsPrivacyOptions => 'গোপনীয়তার বিকল্প';

  @override
  String get settingsRemoveAds => 'বিজ্ঞাপন সরান';

  @override
  String get settingsRemoveAdsSubtitle => 'একবারের কেনাকাটা';

  @override
  String get settingsRestorePurchase => 'কেনাকাটা ফিরিয়ে আনুন';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'একবারের কেনাকাটা · $price';
  }

  @override
  String get settingsProOwned => 'বিজ্ঞাপন সরানো হয়েছে';

  @override
  String get proBuyFailed => 'কেনাকাটা সম্পূর্ণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get proRestoreSuccess => 'কেনাকাটা ফিরিয়ে আনা হয়েছে।';

  @override
  String get proRestoreNotFound => 'আগের কোনও কেনাকাটা পাওয়া যায়নি।';

  @override
  String get proRestoreFailed => 'স্টোর যাচাই করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get proPromptTitle => 'বিজ্ঞাপন সরাবেন?';

  @override
  String get proPromptBody => 'একবারের কেনাকাটা, কখনও সাবস্ক্রিপশন নয়।';

  @override
  String get proPromptDismissTooltip => 'সরিয়ে দিন';

  @override
  String get settingsFeedback => 'মতামত';

  @override
  String get settingsPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get settingsOpenSourceLicences => 'ওপেন-সোর্স লাইসেন্স';

  @override
  String get settingsVersion => 'সংস্করণ';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'লিঙ্কটি খোলা যায়নি।';

  @override
  String get feedbackCategoryLabel => 'বিভাগ';

  @override
  String get feedbackCategoryScanning => 'স্ক্যান';

  @override
  String get feedbackCategoryResults => 'ফলাফল';

  @override
  String get feedbackCategoryCreatingCodes => 'কোড তৈরি';

  @override
  String get feedbackCategoryAds => 'বিজ্ঞাপন';

  @override
  String get feedbackCategoryOther => 'অন্যান্য';

  @override
  String get feedbackMessageHint => 'কী হয়েছিল, আর আপনি কী আশা করেছিলেন?';

  @override
  String get feedbackSendButton => 'পাঠান';

  @override
  String get feedbackSendNoHandler =>
      'এই ডিভাইসে কোনও ইমেল অ্যাপ সেট আপ করা নেই।';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle মতামত ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'সিস্টেমের ডিফল্ট';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get languageSystemDefault => 'সিস্টেমের ডিফল্ট';

  @override
  String get historyHeaderToday => 'আজ';

  @override
  String get historyHeaderYesterday => 'গতকাল';

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
      other: '$countটি কোড',
      one: 'একটি কোড',
      zero: 'কোনও কোড নেই',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'সব';

  @override
  String get historySegmentScanned => 'স্ক্যান করা';

  @override
  String get historySegmentCreated => 'তৈরি করা';

  @override
  String get historyEmptyMessage =>
      'আপনি যে কোড স্ক্যান বা তৈরি করবেন তা এখানে দেখা যাবে।';

  @override
  String get historyEmptyScanButton => 'কোড স্ক্যান করুন';

  @override
  String get historyEmptyCreateButton => 'কোড তৈরি করুন';

  @override
  String get historyEmptyNotSavingMessage =>
      'নতুন স্ক্যান সংরক্ষণ করা হচ্ছে না।';

  @override
  String get historyEmptySettingsButton => 'সেটিংসে যান';

  @override
  String get historyLoading => 'ইতিহাস লোড হচ্ছে';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম মুছে ফেলা হয়েছে',
      one: 'একটি আইটেম মুছে ফেলা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'ফেরান';

  @override
  String get historyDeleteFailed => 'মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get historyUndoFailed => 'ফেরানো যায়নি। আবার চেষ্টা করুন।';

  @override
  String get historyLoadFailed => 'ইতিহাস লোড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি নির্বাচিত',
      one: 'একটি নির্বাচিত',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'মুছুন';

  @override
  String get historyCancelSelectionButton => 'নির্বাচন বাতিল';

  @override
  String copiedSnackbar(String what) {
    return '$what কপি করা হয়েছে';
  }

  @override
  String get copiedWhatLink => 'লিঙ্ক';

  @override
  String get copiedWhatContent => 'বিষয়বস্তু';

  @override
  String get resultTitle => 'ফলাফল';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'কপি';

  @override
  String get resultShareButton => 'শেয়ার';

  @override
  String get resultNotSaved => 'এই স্ক্যানটি ইতিহাসে সংরক্ষণ করা যায়নি।';

  @override
  String get resultCopyFailed => 'কপি করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get resultShareFailed =>
      'শেয়ার করার জায়গাটি খোলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get parsedTypeUrl => 'লিঙ্ক';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'লেখা';

  @override
  String get parsedTypeContact => 'পরিচিতি';

  @override
  String get parsedTypePhone => 'ফোন নম্বর';

  @override
  String get parsedTypeEmail => 'ইমেল';

  @override
  String get parsedTypeSms => 'এসএমএস';

  @override
  String get parsedTypeGeo => 'অবস্থান';

  @override
  String get parsedTypeEvent => 'ইভেন্ট';

  @override
  String get parsedTypeProduct => 'পণ্য';

  @override
  String get parsedTypeAppStore => 'অ্যাপ';

  @override
  String get parsedTypeUnknown => 'অজানা';

  @override
  String get symbologyQr => 'QR কোড';

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
  String get symbologyUnknown => 'অজানা ফরম্যাট';

  @override
  String get errorStorageUnavailable =>
      'অ্যাপটি তার স্টোরেজ খুলতে পারছে না। বন্ধ করে আবার খুলুন।';

  @override
  String get errorSaveFailed => 'কিছুই সংরক্ষণ হয়নি। আবার চেষ্টা করুন।';

  @override
  String get actionRetry => 'আবার চেষ্টা';

  @override
  String get copiedWhatPassword => 'পাসওয়ার্ড';

  @override
  String get resultHandOffFailed => 'খোলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get resultUnavailableWifiSettings =>
      'এই ডিভাইসে Wi-Fi সেটিংস খোলা যায় না।';

  @override
  String get resultUnavailableContacts => 'কোনও পরিচিতি অ্যাপ ইনস্টল করা নেই।';

  @override
  String get resultUnavailableCalendar =>
      'কোনও ক্যালেন্ডার অ্যাপ ইনস্টল করা নেই।';

  @override
  String get resultUnavailableDialer => 'কোনও ফোন অ্যাপ ইনস্টল করা নেই।';

  @override
  String get resultUnavailableSms => 'কোনও মেসেজিং অ্যাপ ইনস্টল করা নেই।';

  @override
  String get resultUnavailableEmail => 'কোনও ইমেল অ্যাপ ইনস্টল করা নেই।';

  @override
  String get resultUnavailableBrowser => 'কোনও ব্রাউজার ইনস্টল করা নেই।';

  @override
  String get resultLinkOpenButton => 'খুলুন';

  @override
  String get resultLinkReviewButton => 'দেখে নিন';

  @override
  String get resultLinkWarningTitle => 'এই লিঙ্ক খোলার আগে';

  @override
  String get resultLinkCheckIpAddressHost =>
      'ঠিকানাটি কোনও নাম নয়, সরাসরি একটি IP নম্বর';

  @override
  String get resultLinkCheckUserinfo => 'সাইটের নামের আগে একটি ইউজার নাম আছে';

  @override
  String get resultLinkCheckInsecureScheme => 'এটি এনক্রিপ্ট করা নয় (http)';

  @override
  String get resultLinkCheckNonDefaultPort =>
      'এটি একটি অস্বাভাবিক পোর্ট ব্যবহার করে';

  @override
  String get resultLinkCheckLongUrl => 'এটি অস্বাভাবিক রকম লম্বা';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'না খুলে কপি করুন';

  @override
  String get resultLinkOpenAnywayButton => 'তবুও খুলুন';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme লিঙ্ক এখানে খোলা যায় না।';
  }

  @override
  String get resultLinkCalloutMessage =>
      'এই অ্যাপ লিঙ্ক খোলার আগে যাচাই করে, যাতে সেটি কোথায় নিয়ে যাচ্ছে তা আপনি আগেই দেখতে পান।';

  @override
  String get resultLinkCalloutDismissTooltip => 'সরিয়ে দিন';

  @override
  String get resultWifiNetworkNameLabel => 'নেটওয়ার্কের নাম';

  @override
  String get resultWifiSecurityLabel => 'নিরাপত্তা';

  @override
  String get resultWifiPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get resultWifiRevealPasswordTooltip => 'পাসওয়ার্ড দেখান';

  @override
  String get resultWifiHidePasswordTooltip => 'পাসওয়ার্ড লুকান';

  @override
  String get resultWifiWepNotice =>
      'অ্যাপ থেকে WEP নেটওয়ার্কে যোগ দেওয়া Android-এ সম্ভব নয়।';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi সেটিংস খুলুন';

  @override
  String get resultWifiCopyPasswordButton => 'পাসওয়ার্ড কপি করুন';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'খোলা';

  @override
  String get resultContactNameLabel => 'নাম';

  @override
  String get resultContactPhoneLabel => 'ফোন';

  @override
  String get resultContactEmailLabel => 'ইমেল';

  @override
  String get resultContactOrganisationLabel => 'প্রতিষ্ঠান';

  @override
  String get resultContactPrimaryButton => 'পরিচিতিতে যোগ করুন';

  @override
  String get resultEventTitleLabel => 'শিরোনাম';

  @override
  String get resultEventStartLabel => 'শুরু';

  @override
  String get resultEventEndLabel => 'শেষ';

  @override
  String get resultEventLocationLabel => 'অবস্থান';

  @override
  String get resultEventNotesLabel => 'নোট';

  @override
  String get resultEventAllDayNotice => 'সারা দিনের ইভেন্ট।';

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
      'এই ইভেন্টের শুরুর সময় নেই, তাই এটি যোগ করা যাবে না।';

  @override
  String get resultEventPrimaryButton => 'ক্যালেন্ডারে যোগ করুন';

  @override
  String get resultPhoneNumberLabel => 'নম্বর';

  @override
  String get resultPhonePrimaryButton => 'কল করুন';

  @override
  String get resultSmsNumberLabel => 'নম্বর';

  @override
  String get resultSmsMessageLabel => 'বার্তা';

  @override
  String get resultSmsPrimaryButton => 'বার্তা পাঠান';

  @override
  String get resultEmailToLabel => 'প্রাপক';

  @override
  String get resultEmailSubjectLabel => 'বিষয়';

  @override
  String get resultEmailBodyLabel => 'বার্তা';

  @override
  String get resultEmailPrimaryButton => 'ইমেল করুন';

  @override
  String get resultProductNumberLabel => 'নম্বর';

  @override
  String get resultProductFormatLabel => 'ফরম্যাট';

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
  String get resultProductSearchButton => 'ওয়েবে খুঁজুন';

  @override
  String get resultLocationLatitudeLabel => 'অক্ষাংশ';

  @override
  String get resultLocationLongitudeLabel => 'দ্রাঘিমাংশ';

  @override
  String get resultLocationNameLabel => 'নাম';

  @override
  String get createSubtitle => 'কী তৈরি করবেন বেছে নিন';

  @override
  String get createUrlFieldLabel => 'ওয়েব ঠিকানা';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'কোডটি $url খুলবে';
  }

  @override
  String get createTextFieldLabel => 'লেখা';

  @override
  String get createTextFieldHint => 'কোডে যা লেখা থাকবে';

  @override
  String get createWifiSsidLabel => 'নেটওয়ার্কের নাম';

  @override
  String get createWifiSecurityLabel => 'নিরাপত্তা';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (অনিরাপদ)';

  @override
  String get createWifiPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get createWifiHiddenLabel => 'লুকানো নেটওয়ার্ক';

  @override
  String get createContactNameLabel => 'নাম';

  @override
  String get createContactPhoneLabel => 'ফোন (ঐচ্ছিক)';

  @override
  String get createContactEmailLabel => 'ইমেল (ঐচ্ছিক)';

  @override
  String get createContactOrganisationLabel => 'প্রতিষ্ঠান (ঐচ্ছিক)';

  @override
  String get createPhoneFieldLabel => 'ফোন নম্বর';

  @override
  String get createEmailToLabel => 'ইমেল ঠিকানা';

  @override
  String get createEmailSubjectLabel => 'বিষয় (ঐচ্ছিক)';

  @override
  String get createEmailBodyLabel => 'বার্তা (ঐচ্ছিক)';

  @override
  String get createSmsNumberLabel => 'ফোন নম্বর';

  @override
  String get createSmsMessageLabel => 'বার্তা (ঐচ্ছিক)';

  @override
  String get createFieldErrorRequired => 'এই ঘরটি পূরণ করা দরকার।';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// বা https:// দিয়ে শুরু হওয়া একটি ওয়েব ঠিকানা লিখুন।';

  @override
  String get createFieldErrorInvalidEmail => 'একটি সঠিক ইমেল ঠিকানা লিখুন।';

  @override
  String get createFieldErrorInvalidPhone =>
      '3 থেকে 15 অঙ্কের একটি ফোন নম্বর লিখুন।';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'ধারণক্ষমতার $percent% ব্যবহৃত';
  }

  @override
  String get createCapacityOverLimit =>
      'একটি QR কোডের জন্য এই বিষয়বস্তু অনেক বেশি। এগোতে হলে ছোট করুন।';

  @override
  String get createButtonLabel => 'তৈরি করুন';

  @override
  String get createCheckingMessage =>
      'কোডটি ঠিকমতো স্ক্যান হয় কি না দেখা হচ্ছে';

  @override
  String get createContentLabel => 'বিষয়বস্তু';

  @override
  String get createCodeImageLabel => 'তৈরি করা QR কোড';

  @override
  String get createCheckFailedRenderFailed =>
      'কোডটি তৈরি করা যায়নি। বিষয়বস্তু ছোট করে আবার চেষ্টা করুন।';

  @override
  String get createCheckFailedDecodeFailed =>
      'এই কোডটি যাচাই করা যায়নি। সংরক্ষণ ও শেয়ার বন্ধ রাখা হয়েছে।';

  @override
  String get createCheckFailedMismatch =>
      'এই কোডটি আপনার লেখা বিষয়বস্তুর সঙ্গে মেলেনি। সংরক্ষণ ও শেয়ার বন্ধ রাখা হয়েছে।';

  @override
  String get createNotSavedToHistory => 'এই কোডটি ইতিহাসে সংরক্ষণ করা যায়নি।';

  @override
  String get createSaveButton => 'সংরক্ষণ';

  @override
  String get createShareButton => 'শেয়ার';

  @override
  String get createSavedSnackbarNoName => 'কোড সংরক্ষিত হয়েছে';

  @override
  String createSavedSnackbar(String name) {
    return '$name নামে সংরক্ষিত হয়েছে';
  }

  @override
  String get createShareFailed =>
      'শেয়ার করার জায়গাটি খোলা যায়নি। আবার চেষ্টা করুন।';
}
