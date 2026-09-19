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
  String get historySegmentAll => 'الكل';

  @override
  String get historySegmentScanned => 'الممسوحة';

  @override
  String get historySegmentCreated => 'المُنشأة';

  @override
  String get historyEmptyMessage => 'ستظهر هنا الرموز التي تمسحها أو تنشئها.';

  @override
  String get historyEmptyScanButton => 'مسح رمز';

  @override
  String get historyEmptyCreateButton => 'إنشاء رمز';

  @override
  String get historyEmptyNotSavingMessage => 'لا يتم حفظ عمليات المسح الجديدة.';

  @override
  String get historyEmptySettingsButton => 'الانتقال إلى الإعدادات';

  @override
  String get historyLoading => 'جارٍ تحميل السجل';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف $count عنصر',
      many: 'تم حذف $count عنصرًا',
      few: 'تم حذف $count عناصر',
      two: 'تم حذف عنصرين',
      one: 'تم حذف عنصر واحد',
      zero: 'لم يُحذف أي عنصر',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'تراجع';

  @override
  String get historyDeleteFailed => 'تعذّر الحذف. حاول مرة أخرى.';

  @override
  String get historyUndoFailed => 'تعذّر التراجع. حاول مرة أخرى.';

  @override
  String get historyLoadFailed => 'تعذّر تحميل السجل. حاول مرة أخرى.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تحديد $count عنصر',
      many: 'تم تحديد $count عنصرًا',
      few: 'تم تحديد $count عناصر',
      two: 'تم تحديد عنصرين',
      one: 'تم تحديد عنصر واحد',
      zero: 'لم يتم تحديد أي عنصر',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'حذف';

  @override
  String get historyCancelSelectionButton => 'إلغاء التحديد';

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
  String get resultLinkOpenButton => 'فتح';

  @override
  String get resultLinkReviewButton => 'مراجعة';

  @override
  String get resultLinkWarningTitle => 'قبل فتح هذا الرابط';

  @override
  String get resultLinkCheckIpAddressHost => 'العنوان رقم IP خام وليس اسمًا';

  @override
  String get resultLinkCheckUserinfo => 'يحتوي على اسم مستخدم قبل اسم الموقع';

  @override
  String get resultLinkCheckInsecureScheme => 'غير مشفّر (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'يستخدم منفذًا غير معتاد';

  @override
  String get resultLinkCheckLongUrl => 'طويل بشكل غير معتاد';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'نسخ بدون فتح';

  @override
  String get resultLinkOpenAnywayButton => 'فتح رغم ذلك';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'روابط $scheme لا يمكن فتحها هنا.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'يتحقق هذا التطبيق من الروابط قبل فتحها، لتعرف وجهتها أولًا.';

  @override
  String get resultLinkCalloutDismissTooltip => 'إغلاق';

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

  @override
  String get createSubtitle => 'اختر ما تريد إنشاءه';

  @override
  String get createUrlFieldLabel => 'عنوان الويب';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'يفتح الرمز $url';
  }

  @override
  String get createTextFieldLabel => 'نص';

  @override
  String get createTextFieldHint => 'أي نص تريد أن يحمله الرمز';

  @override
  String get createWifiSsidLabel => 'اسم الشبكة';

  @override
  String get createWifiSecurityLabel => 'الحماية';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (غير آمنة)';

  @override
  String get createWifiPasswordLabel => 'كلمة المرور';

  @override
  String get createWifiHiddenLabel => 'شبكة مخفية';

  @override
  String get createContactNameLabel => 'الاسم';

  @override
  String get createContactPhoneLabel => 'الهاتف (اختياري)';

  @override
  String get createContactEmailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get createContactOrganisationLabel => 'المؤسسة (اختياري)';

  @override
  String get createPhoneFieldLabel => 'رقم الهاتف';

  @override
  String get createEmailToLabel => 'عنوان البريد الإلكتروني';

  @override
  String get createEmailSubjectLabel => 'الموضوع (اختياري)';

  @override
  String get createEmailBodyLabel => 'الرسالة (اختياري)';

  @override
  String get createSmsNumberLabel => 'رقم الهاتف';

  @override
  String get createSmsMessageLabel => 'الرسالة (اختياري)';

  @override
  String get createFieldErrorRequired => 'هذا الحقل مطلوب.';

  @override
  String get createFieldErrorInvalidUrl =>
      'أدخل عنوان ويب يبدأ بـ http:// أو https://.';

  @override
  String get createFieldErrorInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get createFieldErrorInvalidPhone => 'أدخل رقم هاتف من 3 إلى 15 رقمًا.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% من السعة مُستخدَمة';
  }

  @override
  String get createCapacityOverLimit =>
      'هذا محتوى أكبر من سعة رمز QR. اختصره للمتابعة.';

  @override
  String get createButtonLabel => 'إنشاء';

  @override
  String get createCheckingMessage => 'التحقق من أن الرمز يُقرأ بشكل صحيح';

  @override
  String get createContentLabel => 'المحتوى';

  @override
  String get createCodeImageLabel => 'رمز QR الذي تم إنشاؤه';

  @override
  String get createCheckFailedRenderFailed =>
      'تعذّر إنشاء الرمز. اختصر المحتوى وحاول مرة أخرى.';

  @override
  String get createCheckFailedDecodeFailed =>
      'تعذّر التحقق من هذا الرمز. تم إيقاف الحفظ والمشاركة.';

  @override
  String get createCheckFailedMismatch =>
      'لم يطابق هذا الرمز ما أدخلته. تم إيقاف الحفظ والمشاركة.';

  @override
  String get createNotSavedToHistory => 'تعذّر حفظ هذا الرمز في السجل.';

  @override
  String get createSaveButton => 'حفظ';

  @override
  String get createShareButton => 'مشاركة';

  @override
  String get createSavedSnackbarNoName => 'تم حفظ الرمز';

  @override
  String createSavedSnackbar(String name) {
    return 'تم الحفظ باسم $name';
  }

  @override
  String get createShareFailed => 'تعذّر فتح المشاركة. حاول مرة أخرى.';
}
