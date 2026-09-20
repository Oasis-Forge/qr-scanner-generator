// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'اسکین';

  @override
  String get navCreate => 'بنائیں';

  @override
  String get navHistory => 'ہسٹری';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get cameraPermissionReason =>
      'کیمرا صرف اسی فون پر کوڈ پڑھنے کے لیے استعمال ہوتا ہے۔';

  @override
  String get cameraAllowButton => 'کیمرے کی اجازت دیں';

  @override
  String get cameraOpenSettingsButton => 'ترتیبات کھولیں';

  @override
  String get scanFromPhotoButton => 'تصویر اسکین کریں';

  @override
  String get typeCodeButton => 'کوڈ لکھیں';

  @override
  String get placeholderCreateMessage =>
      'کوڈ بنانے کی سہولت اگلے ٹیسٹ بلڈ میں آ رہی ہے۔';

  @override
  String get placeholderHistoryMessage =>
      'ہسٹری کی فہرست اگلے ٹیسٹ بلڈ میں آ رہی ہے۔ آپ کے اسکین پہلے سے اسی فون پر محفوظ ہیں۔';

  @override
  String get scanReadyStatus => 'تیار';

  @override
  String get scanTargetHint => 'کیمرا کوڈ کی طرف رکھیں';

  @override
  String get scanCameraUnavailable =>
      'کیمرا شروع نہیں ہو سکا۔ ممکن ہے کوئی دوسری ایپ اسے استعمال کر رہی ہو۔';

  @override
  String get scanTorchOn => 'ٹارچ آن کریں';

  @override
  String get scanTorchOff => 'ٹارچ آف کریں';

  @override
  String get scanZoomLabel => 'زوم';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'تصویر پڑھی جا رہی ہے';

  @override
  String get scanPhotoPickerFailed =>
      'تصویر منتخب کرنے کا صفحہ نہیں کھلا۔ دوبارہ کوشش کریں۔';

  @override
  String get scanSettingsDidNotOpen =>
      'ترتیبات نہیں کھلیں۔ اپنے فون کی ترتیبات سے کیمرے کی اجازت دیں۔';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format شناخت ہوا: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type شناخت ہوا';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کوڈ شناخت ہوئے',
      one: '1 کوڈ شناخت ہوا',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کوڈ ملے',
      one: '1 کوڈ ملا',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'کھولنے کے لیے کوڈ منتخب کریں۔';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بائنری ڈیٹا، $count بائٹس',
      one: 'بائنری ڈیٹا، 1 بائٹ',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'کوئی کوڈ نہیں ملا';

  @override
  String get noCodeFoundHint =>
      'یقینی بنائیں کہ پورا کوڈ تصویر میں ہو، صاف ہو اور روشنی اچھی ہو۔';

  @override
  String get tryAnotherPhotoButton => 'دوسری تصویر آزمائیں';

  @override
  String get actionClose => 'بند کریں';

  @override
  String get manualEntryTitle => 'کوڈ لکھیں';

  @override
  String get manualEntryFieldLabel => 'کوڈ کا مواد';

  @override
  String get manualEntryFieldHint => 'کوئی لنک، کچھ متن یا بارکوڈ نمبر';

  @override
  String get manualEntryScanButton => 'اسکین کریں';

  @override
  String get settingsGroupGeneral => 'عام';

  @override
  String get settingsGroupPrivacy => 'رازداری';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'تعارف';

  @override
  String get settingsTheme => 'تھیم';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsSoundOnScan => 'اسکین پر آواز';

  @override
  String get settingsVibrateOnScan => 'اسکین پر وائبریشن';

  @override
  String get settingsCopyOnScan => 'اسکین پر کاپی';

  @override
  String get settingsSearchEngine => 'سرچ انجن';

  @override
  String get settingsSaveHistory => 'ہسٹری محفوظ کریں';

  @override
  String get settingsSendCrashReports => 'کریش رپورٹس بھیجیں';

  @override
  String get settingsPrivacyOptions => 'رازداری کے اختیارات';

  @override
  String get settingsRemoveAds => 'اشتہارات ہٹائیں';

  @override
  String get settingsRemoveAdsSubtitle => 'ایک بار کی خریداری';

  @override
  String get settingsRestorePurchase => 'خریداری بحال کریں';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'ایک بار کی خریداری · $price';
  }

  @override
  String get settingsProOwned => 'اشتہارات ہٹا دیے گئے';

  @override
  String get proBuyFailed => 'خریداری مکمل نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get proRestoreSuccess => 'خریداری بحال ہو گئی۔';

  @override
  String get proRestoreNotFound => 'پہلے کی کوئی خریداری نہیں ملی۔';

  @override
  String get proRestoreFailed => 'اسٹور کی جانچ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get proPromptTitle => 'اشتہارات ہٹائیں؟';

  @override
  String get proPromptBody => 'ایک بار کی خریداری، سبسکرپشن نہیں۔';

  @override
  String get proPromptDismissTooltip => 'بند کریں';

  @override
  String get settingsFeedback => 'رائے';

  @override
  String get settingsPrivacyPolicy => 'رازداری کی پالیسی';

  @override
  String get settingsOpenSourceLicences => 'اوپن سورس لائسنس';

  @override
  String get settingsVersion => 'ورژن';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'لنک نہیں کھل سکا۔';

  @override
  String get feedbackCategoryLabel => 'زمرہ';

  @override
  String get feedbackCategoryScanning => 'اسکین کرنا';

  @override
  String get feedbackCategoryResults => 'نتائج';

  @override
  String get feedbackCategoryCreatingCodes => 'کوڈ بنانا';

  @override
  String get feedbackCategoryAds => 'اشتہارات';

  @override
  String get feedbackCategoryOther => 'دیگر';

  @override
  String get feedbackMessageHint => 'کیا ہوا، اور آپ کو کیا توقع تھی؟';

  @override
  String get feedbackSendButton => 'بھیجیں';

  @override
  String get feedbackSendNoHandler =>
      'اس فون پر کوئی ای میل ایپ سیٹ اپ نہیں ہے۔';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle رائے ($version+$build، $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'سسٹم کے مطابق';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'گہرا';

  @override
  String get languageSystemDefault => 'سسٹم کے مطابق';

  @override
  String get historyHeaderToday => 'آج';

  @override
  String get historyHeaderYesterday => 'کل';

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
      other: '$count کوڈ',
      one: '1 کوڈ',
      zero: 'کوئی کوڈ نہیں',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'سب';

  @override
  String get historySegmentScanned => 'اسکین شدہ';

  @override
  String get historySegmentCreated => 'بنائے گئے';

  @override
  String get historyEmptyMessage =>
      'آپ جو کوڈ اسکین کریں گے یا بنائیں گے وہ یہاں نظر آئیں گے۔';

  @override
  String get historyEmptyScanButton => 'کوڈ اسکین کریں';

  @override
  String get historyEmptyCreateButton => 'کوڈ بنائیں';

  @override
  String get historyEmptyNotSavingMessage => 'نئے اسکین محفوظ نہیں ہو رہے۔';

  @override
  String get historyEmptySettingsButton => 'ترتیبات میں جائیں';

  @override
  String get historyLoading => 'ہسٹری لوڈ ہو رہی ہے';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آئٹم حذف ہوئے',
      one: '1 آئٹم حذف ہوا',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'واپس لائیں';

  @override
  String get historyDeleteFailed => 'حذف نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get historyUndoFailed => 'واپس نہیں لایا جا سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get historyLoadFailed => 'ہسٹری لوڈ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتخب',
      one: '1 منتخب',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'حذف کریں';

  @override
  String get historyCancelSelectionButton => 'انتخاب منسوخ کریں';

  @override
  String copiedSnackbar(String what) {
    return '$what کاپی ہو گیا';
  }

  @override
  String get copiedWhatLink => 'لنک';

  @override
  String get copiedWhatContent => 'مواد';

  @override
  String get resultTitle => 'نتیجہ';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'کاپی کریں';

  @override
  String get resultShareButton => 'شیئر کریں';

  @override
  String get resultNotSaved => 'یہ اسکین ہسٹری میں محفوظ نہیں ہو سکا۔';

  @override
  String get resultCopyFailed => 'کاپی نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get resultShareFailed => 'شیئرنگ نہیں کھل سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get parsedTypeUrl => 'لنک';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'متن';

  @override
  String get parsedTypeContact => 'رابطہ';

  @override
  String get parsedTypePhone => 'فون نمبر';

  @override
  String get parsedTypeEmail => 'ای میل';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'مقام';

  @override
  String get parsedTypeEvent => 'ایونٹ';

  @override
  String get parsedTypeProduct => 'پروڈکٹ';

  @override
  String get parsedTypeAppStore => 'ایپ';

  @override
  String get parsedTypeUnknown => 'نامعلوم';

  @override
  String get symbologyQr => 'QR کوڈ';

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
  String get symbologyUnknown => 'نامعلوم فارمیٹ';

  @override
  String get errorStorageUnavailable =>
      'ایپ اپنا اسٹوریج نہیں کھول سکی۔ اسے بند کر کے دوبارہ کھولیں۔';

  @override
  String get errorSaveFailed => 'کچھ بھی محفوظ نہیں ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get actionRetry => 'دوبارہ کوشش';

  @override
  String get copiedWhatPassword => 'پاس ورڈ';

  @override
  String get resultHandOffFailed => 'نہیں کھل سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get resultUnavailableWifiSettings =>
      'اس فون پر Wi-Fi کی ترتیبات نہیں کھولی جا سکتیں۔';

  @override
  String get resultUnavailableContacts => 'رابطوں کی کوئی ایپ انسٹال نہیں ہے۔';

  @override
  String get resultUnavailableCalendar => 'کوئی کیلنڈر ایپ انسٹال نہیں ہے۔';

  @override
  String get resultUnavailableDialer => 'کوئی فون ایپ انسٹال نہیں ہے۔';

  @override
  String get resultUnavailableSms => 'کوئی پیغام رسانی ایپ انسٹال نہیں ہے۔';

  @override
  String get resultUnavailableEmail => 'کوئی ای میل ایپ انسٹال نہیں ہے۔';

  @override
  String get resultUnavailableBrowser => 'کوئی براؤزر انسٹال نہیں ہے۔';

  @override
  String get resultLinkOpenButton => 'کھولیں';

  @override
  String get resultLinkReviewButton => 'جائزہ لیں';

  @override
  String get resultLinkWarningTitle => 'یہ لنک کھولنے سے پہلے';

  @override
  String get resultLinkCheckIpAddressHost => 'پتہ نام کے بجائے خام IP نمبر ہے';

  @override
  String get resultLinkCheckUserinfo =>
      'اس میں سائٹ کے نام سے پہلے صارف نام موجود ہے';

  @override
  String get resultLinkCheckInsecureScheme => 'یہ خفیہ کاری کے بغیر ہے (http)';

  @override
  String get resultLinkCheckNonDefaultPort =>
      'یہ غیر معمولی پورٹ استعمال کرتا ہے';

  @override
  String get resultLinkCheckLongUrl => 'یہ غیر معمولی طور پر لمبا ہے';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'کھولے بغیر کاپی کریں';

  @override
  String get resultLinkOpenAnywayButton => 'پھر بھی کھولیں';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme لنک یہاں نہیں کھولے جا سکتے۔';
  }

  @override
  String get resultLinkCalloutMessage =>
      'یہ ایپ لنک کھولنے سے پہلے اس کی جانچ کرتی ہے، تاکہ آپ پہلے دیکھ سکیں کہ وہ کہاں لے جاتا ہے۔';

  @override
  String get resultLinkCalloutDismissTooltip => 'بند کریں';

  @override
  String get resultWifiNetworkNameLabel => 'نیٹ ورک کا نام';

  @override
  String get resultWifiSecurityLabel => 'سیکیورٹی';

  @override
  String get resultWifiPasswordLabel => 'پاس ورڈ';

  @override
  String get resultWifiRevealPasswordTooltip => 'پاس ورڈ دکھائیں';

  @override
  String get resultWifiHidePasswordTooltip => 'پاس ورڈ چھپائیں';

  @override
  String get resultWifiWepNotice =>
      'اینڈرائیڈ ایپس کے ذریعے WEP نیٹ ورکس سے نہیں جڑ سکتا۔';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi کی ترتیبات کھولیں';

  @override
  String get resultWifiCopyPasswordButton => 'پاس ورڈ کاپی کریں';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'کھلا';

  @override
  String get resultContactNameLabel => 'نام';

  @override
  String get resultContactPhoneLabel => 'فون';

  @override
  String get resultContactEmailLabel => 'ای میل';

  @override
  String get resultContactOrganisationLabel => 'ادارہ';

  @override
  String get resultContactPrimaryButton => 'رابطوں میں شامل کریں';

  @override
  String get resultEventTitleLabel => 'عنوان';

  @override
  String get resultEventStartLabel => 'آغاز';

  @override
  String get resultEventEndLabel => 'اختتام';

  @override
  String get resultEventLocationLabel => 'مقام';

  @override
  String get resultEventNotesLabel => 'نوٹس';

  @override
  String get resultEventAllDayNotice => 'پورے دن کا ایونٹ۔';

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
      'اس ایونٹ کا وقتِ آغاز نہیں ہے، اس لیے یہ شامل نہیں کیا جا سکتا۔';

  @override
  String get resultEventPrimaryButton => 'کیلنڈر میں شامل کریں';

  @override
  String get resultPhoneNumberLabel => 'نمبر';

  @override
  String get resultPhonePrimaryButton => 'کال کریں';

  @override
  String get resultSmsNumberLabel => 'نمبر';

  @override
  String get resultSmsMessageLabel => 'پیغام';

  @override
  String get resultSmsPrimaryButton => 'پیغام بھیجیں';

  @override
  String get resultEmailToLabel => 'بنام';

  @override
  String get resultEmailSubjectLabel => 'موضوع';

  @override
  String get resultEmailBodyLabel => 'پیغام';

  @override
  String get resultEmailPrimaryButton => 'ای میل کریں';

  @override
  String get resultProductNumberLabel => 'نمبر';

  @override
  String get resultProductFormatLabel => 'فارمیٹ';

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
  String get resultProductSearchButton => 'ویب پر تلاش کریں';

  @override
  String get resultLocationLatitudeLabel => 'عرض البلد';

  @override
  String get resultLocationLongitudeLabel => 'طول البلد';

  @override
  String get resultLocationNameLabel => 'نام';

  @override
  String get createSubtitle => 'منتخب کریں کہ کیا بنانا ہے';

  @override
  String get createUrlFieldLabel => 'ویب پتہ';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'یہ کوڈ $url کھولے گا';
  }

  @override
  String get createTextFieldLabel => 'متن';

  @override
  String get createTextFieldHint => 'جو بھی آپ کوڈ میں رکھنا چاہیں';

  @override
  String get createWifiSsidLabel => 'نیٹ ورک کا نام';

  @override
  String get createWifiSecurityLabel => 'سیکیورٹی';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (غیر محفوظ)';

  @override
  String get createWifiPasswordLabel => 'پاس ورڈ';

  @override
  String get createWifiHiddenLabel => 'پوشیدہ نیٹ ورک';

  @override
  String get createContactNameLabel => 'نام';

  @override
  String get createContactPhoneLabel => 'فون (اختیاری)';

  @override
  String get createContactEmailLabel => 'ای میل (اختیاری)';

  @override
  String get createContactOrganisationLabel => 'ادارہ (اختیاری)';

  @override
  String get createPhoneFieldLabel => 'فون نمبر';

  @override
  String get createEmailToLabel => 'ای میل پتہ';

  @override
  String get createEmailSubjectLabel => 'موضوع (اختیاری)';

  @override
  String get createEmailBodyLabel => 'پیغام (اختیاری)';

  @override
  String get createSmsNumberLabel => 'فون نمبر';

  @override
  String get createSmsMessageLabel => 'پیغام (اختیاری)';

  @override
  String get createFieldErrorRequired => 'یہ خانہ ضروری ہے۔';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// یا https:// سے شروع ہونے والا ویب پتہ درج کریں۔';

  @override
  String get createFieldErrorInvalidEmail => 'درست ای میل پتہ درج کریں۔';

  @override
  String get createFieldErrorInvalidPhone =>
      '3 سے 15 ہندسوں والا فون نمبر درج کریں۔';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'گنجائش کا $percent% استعمال ہوا';
  }

  @override
  String get createCapacityOverLimit =>
      'یہ مواد QR کوڈ کے لیے بہت زیادہ ہے۔ جاری رکھنے کے لیے اسے مختصر کریں۔';

  @override
  String get createButtonLabel => 'بنائیں';

  @override
  String get createCheckingMessage =>
      'جانچا جا رہا ہے کہ کوڈ درست اسکین ہوتا ہے';

  @override
  String get createContentLabel => 'مواد';

  @override
  String get createCodeImageLabel => 'بنایا گیا QR کوڈ';

  @override
  String get createCheckFailedRenderFailed =>
      'کوڈ نہیں بن سکا۔ مواد مختصر کریں اور دوبارہ کوشش کریں۔';

  @override
  String get createCheckFailedDecodeFailed =>
      'اس کوڈ کی جانچ نہیں ہو سکی۔ محفوظ کریں اور شیئر کریں بند ہیں۔';

  @override
  String get createCheckFailedMismatch =>
      'یہ کوڈ آپ کے درج کردہ مواد سے مطابقت نہیں رکھتا۔ محفوظ کریں اور شیئر کریں بند ہیں۔';

  @override
  String get createNotSavedToHistory => 'یہ کوڈ ہسٹری میں محفوظ نہیں ہو سکا۔';

  @override
  String get createSaveButton => 'محفوظ کریں';

  @override
  String get createShareButton => 'شیئر کریں';

  @override
  String get createSavedSnackbarNoName => 'کوڈ محفوظ ہو گیا';

  @override
  String createSavedSnackbar(String name) {
    return '$name کے نام سے محفوظ ہو گیا';
  }

  @override
  String get createShareFailed => 'شیئرنگ نہیں کھل سکی۔ دوبارہ کوشش کریں۔';
}
