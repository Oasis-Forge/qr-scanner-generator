// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Tara';

  @override
  String get navCreate => 'Oluştur';

  @override
  String get navHistory => 'Geçmiş';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get cameraPermissionReason =>
      'Kamera yalnızca bu cihazda kod okumak için kullanılır.';

  @override
  String get cameraAllowButton => 'Kamera izni ver';

  @override
  String get cameraOpenSettingsButton => 'Ayarları aç';

  @override
  String get scanFromPhotoButton => 'Fotoğraf tara';

  @override
  String get typeCodeButton => 'Kod yaz';

  @override
  String get placeholderCreateMessage =>
      'Kod oluşturma bir sonraki test sürümünde geliyor.';

  @override
  String get placeholderHistoryMessage =>
      'Geçmiş listesi bir sonraki test sürümünde geliyor. Taramalarınız şimdiden bu telefonda saklanıyor.';

  @override
  String get scanReadyStatus => 'Hazır';

  @override
  String get scanTargetHint => 'Kamerayı bir koda doğrultun';

  @override
  String get scanCameraUnavailable =>
      'Kamera başlatılamadı. Başka bir uygulama kullanıyor olabilir.';

  @override
  String get scanTorchOn => 'Feneri aç';

  @override
  String get scanTorchOff => 'Feneri kapat';

  @override
  String get scanZoomLabel => 'Yakınlaştırma';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Fotoğraf okunuyor';

  @override
  String get scanPhotoPickerFailed =>
      'Fotoğraf seçici açılmadı. Tekrar deneyin.';

  @override
  String get scanSettingsDidNotOpen =>
      'Ayarlar açılmadı. Kameraya telefon ayarlarınızdan izin verin.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format algılandı: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type algılandı';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kod algılandı',
      one: '1 kod algılandı',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kod bulundu',
      one: '1 kod bulundu',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Açılacak kodu seçin.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'İkili veri, $count bayt',
      one: 'İkili veri, 1 bayt',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Kod bulunamadı';

  @override
  String get noCodeFoundHint =>
      'Kodun tamamının fotoğrafta, net ve iyi aydınlatılmış olduğundan emin olun.';

  @override
  String get tryAnotherPhotoButton => 'Başka fotoğraf dene';

  @override
  String get actionClose => 'Kapat';

  @override
  String get manualEntryTitle => 'Kod yaz';

  @override
  String get manualEntryFieldLabel => 'Kod içeriği';

  @override
  String get manualEntryFieldHint =>
      'Bir bağlantı, bir metin veya bir barkod numarası';

  @override
  String get manualEntryScanButton => 'Tara';

  @override
  String get settingsGroupGeneral => 'Genel';

  @override
  String get settingsGroupPrivacy => 'Gizlilik';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Hakkında';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsSoundOnScan => 'Taramada ses';

  @override
  String get settingsVibrateOnScan => 'Taramada titreşim';

  @override
  String get settingsCopyOnScan => 'Taramada kopyala';

  @override
  String get settingsSearchEngine => 'Arama motoru';

  @override
  String get settingsSaveHistory => 'Geçmişi kaydet';

  @override
  String get settingsSendCrashReports => 'Çökme raporları gönder';

  @override
  String get settingsPrivacyOptions => 'Gizlilik seçenekleri';

  @override
  String get settingsRemoveAds => 'Reklamları kaldır';

  @override
  String get settingsRemoveAdsSubtitle => 'Tek seferlik satın alma';

  @override
  String get settingsRestorePurchase => 'Satın almayı geri yükle';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Tek seferlik satın alma · $price';
  }

  @override
  String get settingsProOwned => 'Reklamlar kaldırıldı';

  @override
  String get proBuyFailed => 'Satın alma tamamlanamadı. Tekrar deneyin.';

  @override
  String get proRestoreSuccess => 'Satın alma geri yüklendi.';

  @override
  String get proRestoreNotFound => 'Önceki bir satın alma bulunamadı.';

  @override
  String get proRestoreFailed => 'Mağaza denetlenemedi. Tekrar deneyin.';

  @override
  String get proPromptTitle => 'Reklamlar kaldırılsın mı?';

  @override
  String get proPromptBody =>
      'Tek seferlik bir satın alma, asla abonelik değil.';

  @override
  String get proPromptDismissTooltip => 'Kapat';

  @override
  String get settingsFeedback => 'Geri bildirim';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik politikası';

  @override
  String get settingsOpenSourceLicences => 'Açık kaynak lisansları';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Bağlantı açılamadı.';

  @override
  String get feedbackCategoryLabel => 'Kategori';

  @override
  String get feedbackCategoryScanning => 'Tarama';

  @override
  String get feedbackCategoryResults => 'Sonuçlar';

  @override
  String get feedbackCategoryCreatingCodes => 'Kod oluşturma';

  @override
  String get feedbackCategoryAds => 'Reklamlar';

  @override
  String get feedbackCategoryOther => 'Diğer';

  @override
  String get feedbackMessageHint => 'Ne oldu ve ne bekliyordunuz?';

  @override
  String get feedbackSendButton => 'Gönder';

  @override
  String get feedbackSendNoHandler =>
      'Bu cihazda kurulu bir e-posta uygulaması yok.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle geri bildirim ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Sistem varsayılanı';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get languageSystemDefault => 'Sistem varsayılanı';

  @override
  String get historyHeaderToday => 'Bugün';

  @override
  String get historyHeaderYesterday => 'Dün';

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
      other: '$count kod',
      one: '1 kod',
      zero: 'Kod yok',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Tümü';

  @override
  String get historySegmentScanned => 'Taranan';

  @override
  String get historySegmentCreated => 'Oluşturulan';

  @override
  String get historyEmptyMessage =>
      'Taradığınız veya oluşturduğunuz kodlar burada görünür.';

  @override
  String get historyEmptyScanButton => 'Kod tara';

  @override
  String get historyEmptyCreateButton => 'Kod oluştur';

  @override
  String get historyEmptyNotSavingMessage => 'Yeni taramalar kaydedilmiyor.';

  @override
  String get historyEmptySettingsButton => 'Ayarlara git';

  @override
  String get historyLoading => 'Geçmiş yükleniyor';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe silindi',
      one: '1 öğe silindi',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Geri al';

  @override
  String get historyDeleteFailed => 'Silinemedi. Tekrar deneyin.';

  @override
  String get historyUndoFailed => 'Geri alınamadı. Tekrar deneyin.';

  @override
  String get historyLoadFailed => 'Geçmiş yüklenemedi. Tekrar deneyin.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seçildi',
      one: '1 seçildi',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Sil';

  @override
  String get historyCancelSelectionButton => 'Seçimi iptal et';

  @override
  String copiedSnackbar(String what) {
    return '$what kopyalandı';
  }

  @override
  String get copiedWhatLink => 'Bağlantı';

  @override
  String get copiedWhatContent => 'İçerik';

  @override
  String get resultTitle => 'Sonuç';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Kopyala';

  @override
  String get resultShareButton => 'Paylaş';

  @override
  String get resultNotSaved => 'Bu tarama Geçmişe kaydedilemedi.';

  @override
  String get resultCopyFailed => 'Kopyalanamadı. Tekrar deneyin.';

  @override
  String get resultShareFailed => 'Paylaşım açılamadı. Tekrar deneyin.';

  @override
  String get parsedTypeUrl => 'Bağlantı';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Metin';

  @override
  String get parsedTypeContact => 'Kişi';

  @override
  String get parsedTypePhone => 'Telefon numarası';

  @override
  String get parsedTypeEmail => 'E-posta';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Konum';

  @override
  String get parsedTypeEvent => 'Etkinlik';

  @override
  String get parsedTypeProduct => 'Ürün';

  @override
  String get parsedTypeAppStore => 'Uygulama';

  @override
  String get parsedTypeUnknown => 'Bilinmeyen';

  @override
  String get symbologyQr => 'QR kodu';

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
  String get symbologyUnknown => 'Bilinmeyen biçim';

  @override
  String get errorStorageUnavailable =>
      'Uygulama kendi depolamasını açamıyor. Uygulamayı kapatıp yeniden açın.';

  @override
  String get errorSaveFailed => 'Hiçbir şey kaydedilmedi. Tekrar deneyin.';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String get copiedWhatPassword => 'Parola';

  @override
  String get resultHandOffFailed => 'Açılamadı. Tekrar deneyin.';

  @override
  String get resultUnavailableWifiSettings =>
      'Bu cihazda Wi-Fi ayarları açılamıyor.';

  @override
  String get resultUnavailableContacts => 'Kurulu bir kişiler uygulaması yok.';

  @override
  String get resultUnavailableCalendar => 'Kurulu bir takvim uygulaması yok.';

  @override
  String get resultUnavailableDialer => 'Kurulu bir telefon uygulaması yok.';

  @override
  String get resultUnavailableSms => 'Kurulu bir mesajlaşma uygulaması yok.';

  @override
  String get resultUnavailableEmail => 'Kurulu bir e-posta uygulaması yok.';

  @override
  String get resultUnavailableBrowser => 'Kurulu bir tarayıcı yok.';

  @override
  String get resultLinkOpenButton => 'Aç';

  @override
  String get resultLinkReviewButton => 'İncele';

  @override
  String get resultLinkWarningTitle => 'Bu bağlantıyı açmadan önce';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Adres bir ad değil, doğrudan IP numarası';

  @override
  String get resultLinkCheckUserinfo =>
      'Site adından önce bir kullanıcı adı içeriyor';

  @override
  String get resultLinkCheckInsecureScheme => 'Şifrelenmemiş (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Alışılmadık bir port kullanıyor';

  @override
  String get resultLinkCheckLongUrl => 'Alışılmadık derecede uzun';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Açmadan kopyala';

  @override
  String get resultLinkOpenAnywayButton => 'Yine de aç';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme bağlantıları burada açılamaz.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Bu uygulama bağlantıları açmadan önce denetler, böylece nereye gittiklerini önce görebilirsiniz.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Kapat';

  @override
  String get resultWifiNetworkNameLabel => 'Ağ adı';

  @override
  String get resultWifiSecurityLabel => 'Güvenlik';

  @override
  String get resultWifiPasswordLabel => 'Parola';

  @override
  String get resultWifiRevealPasswordTooltip => 'Parolayı göster';

  @override
  String get resultWifiHidePasswordTooltip => 'Parolayı gizle';

  @override
  String get resultWifiWepNotice =>
      'Android, uygulamalardan WEP ağlarına bağlanamaz.';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi ayarlarını aç';

  @override
  String get resultWifiCopyPasswordButton => 'Parolayı kopyala';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Açık';

  @override
  String get resultContactNameLabel => 'Ad';

  @override
  String get resultContactPhoneLabel => 'Telefon';

  @override
  String get resultContactEmailLabel => 'E-posta';

  @override
  String get resultContactOrganisationLabel => 'Kurum';

  @override
  String get resultContactPrimaryButton => 'Kişilere ekle';

  @override
  String get resultEventTitleLabel => 'Başlık';

  @override
  String get resultEventStartLabel => 'Başlangıç';

  @override
  String get resultEventEndLabel => 'Bitiş';

  @override
  String get resultEventLocationLabel => 'Konum';

  @override
  String get resultEventNotesLabel => 'Notlar';

  @override
  String get resultEventAllDayNotice => 'Tüm gün süren etkinlik.';

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
      'Bu etkinliğin başlangıç saati yok, bu yüzden eklenemez.';

  @override
  String get resultEventPrimaryButton => 'Takvime ekle';

  @override
  String get resultPhoneNumberLabel => 'Numara';

  @override
  String get resultPhonePrimaryButton => 'Ara';

  @override
  String get resultSmsNumberLabel => 'Numara';

  @override
  String get resultSmsMessageLabel => 'Mesaj';

  @override
  String get resultSmsPrimaryButton => 'Mesaj gönder';

  @override
  String get resultEmailToLabel => 'Kime';

  @override
  String get resultEmailSubjectLabel => 'Konu';

  @override
  String get resultEmailBodyLabel => 'Mesaj';

  @override
  String get resultEmailPrimaryButton => 'E-posta gönder';

  @override
  String get resultProductNumberLabel => 'Numara';

  @override
  String get resultProductFormatLabel => 'Biçim';

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
  String get resultProductSearchButton => 'İnternette ara';

  @override
  String get resultLocationLatitudeLabel => 'Enlem';

  @override
  String get resultLocationLongitudeLabel => 'Boylam';

  @override
  String get resultLocationNameLabel => 'Ad';

  @override
  String get createSubtitle => 'Ne oluşturacağınızı seçin';

  @override
  String get createUrlFieldLabel => 'Web adresi';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Kod $url adresini açar';
  }

  @override
  String get createTextFieldLabel => 'Metin';

  @override
  String get createTextFieldHint => 'Kodun içermesini istediğiniz her şey';

  @override
  String get createWifiSsidLabel => 'Ağ adı';

  @override
  String get createWifiSecurityLabel => 'Güvenlik';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (güvensiz)';

  @override
  String get createWifiPasswordLabel => 'Parola';

  @override
  String get createWifiHiddenLabel => 'Gizli ağ';

  @override
  String get createContactNameLabel => 'Ad';

  @override
  String get createContactPhoneLabel => 'Telefon (isteğe bağlı)';

  @override
  String get createContactEmailLabel => 'E-posta (isteğe bağlı)';

  @override
  String get createContactOrganisationLabel => 'Kurum (isteğe bağlı)';

  @override
  String get createPhoneFieldLabel => 'Telefon numarası';

  @override
  String get createEmailToLabel => 'E-posta adresi';

  @override
  String get createEmailSubjectLabel => 'Konu (isteğe bağlı)';

  @override
  String get createEmailBodyLabel => 'Mesaj (isteğe bağlı)';

  @override
  String get createSmsNumberLabel => 'Telefon numarası';

  @override
  String get createSmsMessageLabel => 'Mesaj (isteğe bağlı)';

  @override
  String get createFieldErrorRequired => 'Bu alan zorunludur.';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// veya https:// ile başlayan bir web adresi girin.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Geçerli bir e-posta adresi girin.';

  @override
  String get createFieldErrorInvalidPhone =>
      '3 ile 15 hane arasında bir telefon numarası girin.';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'Kapasitenin %$percent kadarı kullanıldı';
  }

  @override
  String get createCapacityOverLimit =>
      'Bu içerik bir QR kodu için fazla. Devam etmek için kısaltın.';

  @override
  String get createButtonLabel => 'Oluştur';

  @override
  String get createCheckingMessage => 'Kodun doğru tarandığı denetleniyor';

  @override
  String get createContentLabel => 'İçerik';

  @override
  String get createCodeImageLabel => 'Oluşturulan QR kodu';

  @override
  String get createCheckFailedRenderFailed =>
      'Kod oluşturulamadı. İçeriği kısaltıp tekrar deneyin.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Bu kod denetlenemedi. Kaydet ve Paylaş kapatıldı.';

  @override
  String get createCheckFailedMismatch =>
      'Bu kod girdiğinizle eşleşmedi. Kaydet ve Paylaş kapatıldı.';

  @override
  String get createNotSavedToHistory => 'Bu kod Geçmişe kaydedilemedi.';

  @override
  String get createSaveButton => 'Kaydet';

  @override
  String get createShareButton => 'Paylaş';

  @override
  String get createSavedSnackbarNoName => 'Kod kaydedildi';

  @override
  String createSavedSnackbar(String name) {
    return '$name olarak kaydedildi';
  }

  @override
  String get createShareFailed => 'Paylaşım açılamadı. Tekrar deneyin.';
}
