// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ماسح ومنشئ رموز QR';

  @override
  String get navScan => 'مسح';

  @override
  String get navCreate => 'إنشاء';

  @override
  String get navHistory => 'السجل';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get cameraPermissionReason =>
      'تُستخدم الكاميرا لقراءة الرموز على هذا الجهاز فقط.';

  @override
  String get cameraAllowButton => 'السماح بالكاميرا';

  @override
  String get cameraOpenSettingsButton => 'فتح الإعدادات';

  @override
  String get scanFromPhotoButton => 'مسح صورة';

  @override
  String get typeCodeButton => 'كتابة رمز';

  @override
  String get placeholderCreateMessage =>
      'يصل إنشاء الرموز في النسخة التجريبية التالية.';

  @override
  String get placeholderHistoryMessage =>
      'تصل قائمة السجل في النسخة التجريبية التالية. عمليات المسح محفوظة من الآن على هذا الهاتف.';

  @override
  String get scanTargetHint => 'وجّه الكاميرا نحو رمز';

  @override
  String get scanCameraUnavailable =>
      'تعذّر تشغيل الكاميرا. ربما يستخدمها تطبيق آخر.';

  @override
  String get scanTorchOn => 'تشغيل الفلاش';

  @override
  String get scanTorchOff => 'إيقاف الفلاش';

  @override
  String get scanZoomLabel => 'التكبير';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'جارٍ قراءة الصورة';

  @override
  String get scanPhotoPickerFailed => 'لم يُفتح منتقي الصور. حاول مرة أخرى.';

  @override
  String get scanSettingsDidNotOpen =>
      'لم تُفتح الإعدادات. اسمح باستخدام الكاميرا من إعدادات الهاتف.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'تم اكتشاف $format: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'تم اكتشاف $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اكتشاف $count رمز',
      many: 'تم اكتشاف $count رمزًا',
      few: 'تم اكتشاف $count رموز',
      two: 'تم اكتشاف رمزين',
      one: 'تم اكتشاف رمز واحد',
      zero: 'لم يُكتشف أي رمز',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count رمز',
      many: 'تم العثور على $count رمزًا',
      few: 'تم العثور على $count رموز',
      two: 'تم العثور على رمزين',
      one: 'تم العثور على رمز واحد',
      zero: 'لم يُعثر على أي رمز',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'اختر الرمز الذي تريد فتحه.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بيانات ثنائية، $count بايت',
      many: 'بيانات ثنائية، $count بايتًا',
      few: 'بيانات ثنائية، $count بايتات',
      two: 'بيانات ثنائية، بايتان',
      one: 'بيانات ثنائية، بايت واحد',
      zero: 'بيانات ثنائية، 0 بايت',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'لم يُعثر على رمز';

  @override
  String get noCodeFoundHint =>
      'تأكد من ظهور الرمز كاملًا في الصورة، وأنه واضح وجيد الإضاءة.';

  @override
  String get tryAnotherPhotoButton => 'جرّب صورة أخرى';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get manualEntryTitle => 'كتابة رمز';

  @override
  String get manualEntryFieldLabel => 'محتوى الرمز';

  @override
  String get manualEntryFieldHint => 'رابط أو نص أو رقم باركود';

  @override
  String get manualEntryScanButton => 'مسح';

  @override
  String get settingsGroupGeneral => 'عام';

  @override
  String get settingsGroupPrivacy => 'الخصوصية';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'حول التطبيق';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSoundOnScan => 'صوت عند المسح';

  @override
  String get settingsVibrateOnScan => 'اهتزاز عند المسح';

  @override
  String get settingsCopyOnScan => 'النسخ عند المسح';

  @override
  String get settingsSearchEngine => 'محرك البحث';

  @override
  String get settingsSaveHistory => 'حفظ السجل';

  @override
  String get settingsSendCrashReports => 'إرسال تقارير الأعطال';

  @override
  String get settingsPrivacyOptions => 'خيارات الخصوصية';

  @override
  String get settingsRemoveAds => 'إزالة الإعلانات';

  @override
  String get settingsRemoveAdsSubtitle => 'شراء لمرة واحدة';

  @override
  String get settingsRestorePurchase => 'استعادة الشراء';

  @override
  String get settingsFeedback => 'الملاحظات';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsOpenSourceLicences => 'تراخيص المصادر المفتوحة';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get themeSystemDefault => 'حسب إعداد النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageSystemDefault => 'حسب لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get historyHeaderToday => 'اليوم';

  @override
  String get historyHeaderYesterday => 'أمس';

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
      other: '$count رمز',
      many: '$count رمزًا',
      few: '$count رموز',
      two: 'رمزان',
      one: 'رمز واحد',
      zero: 'لا رموز',
    );
    return '$_temp0';
  }

  @override
  String copiedSnackbar(String what) {
    return 'تم نسخ $what';
  }

  @override
  String get copiedWhatLink => 'الرابط';

  @override
  String get copiedWhatContent => 'المحتوى';

  @override
  String get resultTitle => 'النتيجة';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'نسخ';

  @override
  String get resultShareButton => 'مشاركة';

  @override
  String get resultNotSaved => 'تعذّر حفظ هذا المسح في السجل.';

  @override
  String get resultCopyFailed => 'تعذّر النسخ. حاول مرة أخرى.';

  @override
  String get resultShareFailed => 'تعذّر فتح المشاركة. حاول مرة أخرى.';

  @override
  String get parsedTypeUrl => 'رابط';

  @override
  String get parsedTypeWifi => 'شبكة Wi-Fi';

  @override
  String get parsedTypeText => 'نص';

  @override
  String get parsedTypeContact => 'جهة اتصال';

  @override
  String get parsedTypePhone => 'رقم هاتف';

  @override
  String get parsedTypeEmail => 'بريد إلكتروني';

  @override
  String get parsedTypeSms => 'رسالة نصية';

  @override
  String get parsedTypeGeo => 'موقع';

  @override
  String get parsedTypeEvent => 'حدث';

  @override
  String get parsedTypeProduct => 'منتج';

  @override
  String get parsedTypeAppStore => 'تطبيق';

  @override
  String get parsedTypeUnknown => 'غير معروف';

  @override
  String get symbologyQr => 'رمز QR';

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
  String get symbologyUnknown => 'تنسيق غير معروف';

  @override
  String get errorStorageUnavailable =>
      'لا يمكن للتطبيق فتح مساحة التخزين. أغلق التطبيق ثم افتحه من جديد.';

  @override
  String get errorSaveFailed => 'لم يتم حفظ أي شيء. حاول مرة أخرى.';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get copiedWhatPassword => 'كلمة المرور';

  @override
  String get resultHandOffFailed => 'تعذّر الفتح. حاول مرة أخرى.';

  @override
  String get resultUnavailableWifiSettings =>
      'لا يمكن فتح إعدادات Wi-Fi على هذا الجهاز.';

  @override
  String get resultUnavailableContacts => 'لا يوجد تطبيق جهات اتصال مثبَّت.';

  @override
  String get resultUnavailableCalendar => 'لا يوجد تطبيق تقويم مثبَّت.';

  @override
  String get resultUnavailableDialer => 'لا يوجد تطبيق هاتف مثبَّت.';

  @override
  String get resultUnavailableSms => 'لا يوجد تطبيق رسائل مثبَّت.';

  @override
  String get resultUnavailableEmail => 'لا يوجد تطبيق بريد إلكتروني مثبَّت.';

  @override
  String get resultUnavailableBrowser => 'لا يوجد متصفّح مثبَّت.';

  @override
  String get resultWifiNetworkNameLabel => 'اسم الشبكة';

  @override
  String get resultWifiSecurityLabel => 'الحماية';

  @override
  String get resultWifiPasswordLabel => 'كلمة المرور';

  @override
  String get resultWifiRevealPasswordTooltip => 'إظهار كلمة المرور';

  @override
  String get resultWifiHidePasswordTooltip => 'إخفاء كلمة المرور';

  @override
  String get resultWifiWepNotice =>
      'لا يمكن لنظام أندرويد الانضمام إلى شبكات WEP من التطبيقات.';

  @override
  String get resultWifiPrimaryButton => 'فتح إعدادات Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'نسخ كلمة المرور';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'مفتوحة';

  @override
  String get resultContactNameLabel => 'الاسم';

  @override
  String get resultContactPhoneLabel => 'الهاتف';

  @override
  String get resultContactEmailLabel => 'البريد الإلكتروني';

  @override
  String get resultContactOrganisationLabel => 'المؤسسة';

  @override
  String get resultContactPrimaryButton => 'إضافة إلى جهات الاتصال';

  @override
  String get resultEventTitleLabel => 'العنوان';

  @override
  String get resultEventStartLabel => 'البداية';

  @override
  String get resultEventEndLabel => 'النهاية';

  @override
  String get resultEventLocationLabel => 'الموقع';

  @override
  String get resultEventNotesLabel => 'ملاحظات';

  @override
  String get resultEventAllDayNotice => 'حدث يستغرق اليوم كله.';

  @override
  String resultEventTimeUtc(String time) {
    return '$time بالتوقيت العالمي';
  }

  @override
  String resultEventTimeZoned(String time, String zone) {
    return '$time ($zone)';
  }

  @override
  String get resultUnavailableEventNoStart =>
      'لا يحتوي هذا الحدث على وقت بدء، لذا لا يمكن إضافته.';

  @override
  String get resultEventPrimaryButton => 'إضافة إلى التقويم';

  @override
  String get resultPhoneNumberLabel => 'الرقم';

  @override
  String get resultPhonePrimaryButton => 'اتصال';

  @override
  String get resultSmsNumberLabel => 'الرقم';

  @override
  String get resultSmsMessageLabel => 'الرسالة';

  @override
  String get resultSmsPrimaryButton => 'رسالة';

  @override
  String get resultEmailToLabel => 'إلى';

  @override
  String get resultEmailSubjectLabel => 'الموضوع';

  @override
  String get resultEmailBodyLabel => 'الرسالة';

  @override
  String get resultEmailPrimaryButton => 'بريد إلكتروني';

  @override
  String get resultProductNumberLabel => 'الرقم';

  @override
  String get resultProductFormatLabel => 'الصيغة';

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
  String get resultProductSearchButton => 'البحث على الويب';

  @override
  String get resultLocationLatitudeLabel => 'خط العرض';

  @override
  String get resultLocationLongitudeLabel => 'خط الطول';

  @override
  String get resultLocationNameLabel => 'الاسم';
}
