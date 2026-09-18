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
  String get errorStorageUnavailable =>
      'لا يمكن للتطبيق فتح مساحة التخزين. أغلق التطبيق ثم افتحه من جديد.';

  @override
  String get errorSaveFailed => 'لم يتم حفظ أي شيء. حاول مرة أخرى.';

  @override
  String get actionRetry => 'إعادة المحاولة';
}
