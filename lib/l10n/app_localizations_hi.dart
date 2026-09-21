// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'स्कैन';

  @override
  String get navCreate => 'बनाएँ';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get cameraPermissionReason =>
      'कैमरे का उपयोग सिर्फ़ इसी डिवाइस पर कोड पढ़ने के लिए होता है।';

  @override
  String get cameraAllowButton => 'कैमरे की अनुमति दें';

  @override
  String get cameraOpenSettingsButton => 'सेटिंग्स खोलें';

  @override
  String get scanFromPhotoButton => 'फ़ोटो स्कैन करें';

  @override
  String get typeCodeButton => 'कोड टाइप करें';

  @override
  String get placeholderCreateMessage =>
      'कोड बनाने की सुविधा अगले टेस्ट बिल्ड में आएगी।';

  @override
  String get placeholderHistoryMessage =>
      'इतिहास सूची अगले टेस्ट बिल्ड में आएगी। आपके स्कैन इस फ़ोन पर पहले से सहेजे जा रहे हैं।';

  @override
  String get scanReadyStatus => 'तैयार';

  @override
  String get scanTargetHint => 'कैमरा कोड की ओर रखें';

  @override
  String get scanCameraUnavailable =>
      'कैमरा शुरू नहीं हो सका। शायद कोई दूसरा ऐप उसका उपयोग कर रहा है।';

  @override
  String get scanTorchOn => 'टॉर्च चालू करें';

  @override
  String get scanTorchOff => 'टॉर्च बंद करें';

  @override
  String get scanZoomLabel => 'ज़ूम';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'फ़ोटो पढ़ी जा रही है';

  @override
  String get scanPhotoPickerFailed =>
      'फ़ोटो चुनने की स्क्रीन नहीं खुली। फिर कोशिश करें।';

  @override
  String get scanSettingsDidNotOpen =>
      'सेटिंग्स नहीं खुलीं। फ़ोन की सेटिंग्स से कैमरे की अनुमति दें।';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format पहचाना गया: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type पहचाना गया';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कोड पहचाने गए',
      one: '1 कोड पहचाना गया',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कोड मिले',
      one: '1 कोड मिला',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'खोलने के लिए कोड चुनें।';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बाइनरी डेटा, $count बाइट',
      one: 'बाइनरी डेटा, 1 बाइट',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'कोई कोड नहीं मिला';

  @override
  String get noCodeFoundHint =>
      'देखें कि पूरा कोड फ़ोटो में हो, साफ़ हो और उस पर अच्छी रोशनी हो।';

  @override
  String get tryAnotherPhotoButton => 'दूसरी फ़ोटो चुनें';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get manualEntryTitle => 'कोड टाइप करें';

  @override
  String get manualEntryFieldLabel => 'कोड की सामग्री';

  @override
  String get manualEntryFieldHint => 'कोई लिंक, कुछ टेक्स्ट या बारकोड नंबर';

  @override
  String get manualEntryScanButton => 'स्कैन करें';

  @override
  String get settingsGroupGeneral => 'सामान्य';

  @override
  String get settingsGroupPrivacy => 'निजता';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'ऐप के बारे में';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsSoundOnScan => 'स्कैन पर आवाज़';

  @override
  String get settingsVibrateOnScan => 'स्कैन पर कंपन';

  @override
  String get settingsCopyOnScan => 'स्कैन पर कॉपी';

  @override
  String get settingsSearchEngine => 'सर्च इंजन';

  @override
  String get settingsSaveHistory => 'इतिहास सहेजें';

  @override
  String get settingsSendCrashReports => 'क्रैश रिपोर्ट भेजें';

  @override
  String get settingsPrivacyOptions => 'निजता विकल्प';

  @override
  String get settingsRemoveAds => 'विज्ञापन हटाएँ';

  @override
  String get settingsRemoveAdsSubtitle => 'एक बार की खरीद';

  @override
  String get settingsRestorePurchase => 'खरीद बहाल करें';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'एक बार की खरीद · $price';
  }

  @override
  String get settingsProOwned => 'विज्ञापन हटा दिए गए';

  @override
  String get proBuyFailed => 'खरीद पूरी नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get proRestoreSuccess => 'खरीद बहाल हो गई।';

  @override
  String get proRestoreNotFound => 'पहले की कोई खरीद नहीं मिली।';

  @override
  String get proRestoreFailed => 'स्टोर की जाँच नहीं हो सकी। फिर कोशिश करें।';

  @override
  String get proPromptTitle => 'विज्ञापन हटाएँ?';

  @override
  String get proPromptBody => 'एक बार की खरीद, कोई सदस्यता नहीं।';

  @override
  String get proPromptDismissTooltip => 'खारिज करें';

  @override
  String get settingsFeedback => 'फ़ीडबैक';

  @override
  String get settingsPrivacyPolicy => 'निजता नीति';

  @override
  String get settingsOpenSourceLicences => 'ओपन-सोर्स लाइसेंस';

  @override
  String get settingsVersion => 'संस्करण';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'लिंक नहीं खुल सका।';

  @override
  String get feedbackCategoryLabel => 'श्रेणी';

  @override
  String get feedbackCategoryScanning => 'स्कैन करना';

  @override
  String get feedbackCategoryResults => 'नतीजे';

  @override
  String get feedbackCategoryCreatingCodes => 'कोड बनाना';

  @override
  String get feedbackCategoryAds => 'विज्ञापन';

  @override
  String get feedbackCategoryOther => 'अन्य';

  @override
  String get feedbackMessageHint => 'क्या हुआ, और आप क्या उम्मीद कर रहे थे?';

  @override
  String get feedbackSendButton => 'भेजें';

  @override
  String get feedbackSendNoHandler => 'इस डिवाइस पर कोई ईमेल ऐप सेट नहीं है।';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle फ़ीडबैक ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get languageSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get historyHeaderToday => 'आज';

  @override
  String get historyHeaderYesterday => 'कल';

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
      other: '$count कोड',
      one: '1 कोड',
      zero: 'कोई कोड नहीं',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'सभी';

  @override
  String get historySegmentScanned => 'स्कैन किए';

  @override
  String get historySegmentCreated => 'बनाए गए';

  @override
  String get historyEmptyMessage =>
      'आप जो कोड स्कैन करेंगे या बनाएँगे, वे यहाँ दिखेंगे।';

  @override
  String get historyEmptyScanButton => 'कोड स्कैन करें';

  @override
  String get historyEmptyCreateButton => 'कोड बनाएँ';

  @override
  String get historyEmptyNotSavingMessage => 'नए स्कैन सहेजे नहीं जा रहे हैं।';

  @override
  String get historyEmptySettingsButton => 'सेटिंग्स पर जाएँ';

  @override
  String get historyLoading => 'इतिहास लोड हो रहा है';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम मिटाए गए',
      one: '1 आइटम मिटाया गया',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'वापस लाएँ';

  @override
  String get historyDeleteFailed => 'मिटाया नहीं जा सका। फिर कोशिश करें।';

  @override
  String get historyUndoFailed => 'वापस नहीं लाया जा सका। फिर कोशिश करें।';

  @override
  String get historyLoadFailed => 'इतिहास लोड नहीं हो सका। फिर कोशिश करें।';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुने गए',
      one: '1 चुना गया',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'मिटाएँ';

  @override
  String get historyCancelSelectionButton => 'चयन रद्द करें';

  @override
  String copiedSnackbar(String what) {
    return 'कॉपी किया गया: $what';
  }

  @override
  String get copiedWhatLink => 'लिंक';

  @override
  String get copiedWhatContent => 'सामग्री';

  @override
  String get resultTitle => 'नतीजा';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'कॉपी करें';

  @override
  String get resultShareButton => 'शेयर करें';

  @override
  String get resultNotSaved => 'यह स्कैन इतिहास में सहेजा नहीं जा सका।';

  @override
  String get resultCopyFailed => 'कॉपी नहीं हो सका। फिर कोशिश करें।';

  @override
  String get resultShareFailed =>
      'शेयर करने की स्क्रीन नहीं खुली। फिर कोशिश करें।';

  @override
  String get parsedTypeUrl => 'लिंक';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'टेक्स्ट';

  @override
  String get parsedTypeContact => 'संपर्क';

  @override
  String get parsedTypePhone => 'फ़ोन नंबर';

  @override
  String get parsedTypeEmail => 'ईमेल';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'स्थान';

  @override
  String get parsedTypeEvent => 'इवेंट';

  @override
  String get parsedTypeProduct => 'उत्पाद';

  @override
  String get parsedTypeAppStore => 'ऐप';

  @override
  String get parsedTypeUnknown => 'अज्ञात';

  @override
  String get symbologyQr => 'QR कोड';

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
  String get symbologyUnknown => 'अज्ञात फ़ॉर्मेट';

  @override
  String get errorStorageUnavailable =>
      'ऐप अपना स्टोरेज नहीं खोल पा रहा है। इसे बंद करके फिर से खोलें।';

  @override
  String get errorSaveFailed => 'कुछ भी सहेजा नहीं गया। फिर कोशिश करें।';

  @override
  String get actionRetry => 'फिर कोशिश करें';

  @override
  String get copiedWhatPassword => 'पासवर्ड';

  @override
  String get resultHandOffFailed => 'खोला नहीं जा सका। फिर कोशिश करें।';

  @override
  String get resultUnavailableWifiSettings =>
      'इस डिवाइस पर Wi-Fi सेटिंग्स नहीं खोली जा सकतीं।';

  @override
  String get resultUnavailableContacts => 'कोई संपर्क ऐप इंस्टॉल नहीं है।';

  @override
  String get resultUnavailableCalendar => 'कोई कैलेंडर ऐप इंस्टॉल नहीं है।';

  @override
  String get resultUnavailableDialer => 'कोई फ़ोन ऐप इंस्टॉल नहीं है।';

  @override
  String get resultUnavailableSms => 'कोई मैसेजिंग ऐप इंस्टॉल नहीं है।';

  @override
  String get resultUnavailableEmail => 'कोई ईमेल ऐप इंस्टॉल नहीं है।';

  @override
  String get resultUnavailableBrowser => 'कोई ब्राउज़र इंस्टॉल नहीं है।';

  @override
  String get resultLinkOpenButton => 'खोलें';

  @override
  String get resultLinkReviewButton => 'जाँचें';

  @override
  String get resultLinkWarningTitle => 'यह लिंक खोलने से पहले';

  @override
  String get resultLinkCheckIpAddressHost =>
      'पता किसी नाम के बजाय सीधा IP नंबर है';

  @override
  String get resultLinkCheckUserinfo =>
      'इसमें साइट के नाम से पहले एक यूज़र नाम है';

  @override
  String get resultLinkCheckInsecureScheme => 'यह एन्क्रिप्टेड नहीं है (http)';

  @override
  String get resultLinkCheckNonDefaultPort =>
      'यह असामान्य पोर्ट का उपयोग करता है';

  @override
  String get resultLinkCheckLongUrl => 'यह असामान्य रूप से लंबा है';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'खोले बिना कॉपी करें';

  @override
  String get resultLinkOpenAnywayButton => 'फिर भी खोलें';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme लिंक यहाँ नहीं खोले जा सकते।';
  }

  @override
  String get resultLinkCalloutMessage =>
      'यह ऐप लिंक खोलने से पहले उनकी जाँच करता है, ताकि आप पहले देख सकें कि वे कहाँ ले जाते हैं।';

  @override
  String get resultLinkCalloutDismissTooltip => 'खारिज करें';

  @override
  String get resultWifiNetworkNameLabel => 'नेटवर्क नाम';

  @override
  String get resultWifiSecurityLabel => 'सुरक्षा';

  @override
  String get resultWifiPasswordLabel => 'पासवर्ड';

  @override
  String get resultWifiRevealPasswordTooltip => 'पासवर्ड दिखाएँ';

  @override
  String get resultWifiHidePasswordTooltip => 'पासवर्ड छिपाएँ';

  @override
  String get resultWifiWepNotice =>
      'Android ऐप्स से WEP नेटवर्क से नहीं जुड़ सकता।';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi सेटिंग्स खोलें';

  @override
  String get resultWifiCopyPasswordButton => 'पासवर्ड कॉपी करें';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'खुला';

  @override
  String get resultContactNameLabel => 'नाम';

  @override
  String get resultContactPhoneLabel => 'फ़ोन';

  @override
  String get resultContactEmailLabel => 'ईमेल';

  @override
  String get resultContactOrganisationLabel => 'संस्था';

  @override
  String get resultContactPrimaryButton => 'संपर्कों में जोड़ें';

  @override
  String get resultEventTitleLabel => 'शीर्षक';

  @override
  String get resultEventStartLabel => 'शुरू';

  @override
  String get resultEventEndLabel => 'समाप्त';

  @override
  String get resultEventLocationLabel => 'स्थान';

  @override
  String get resultEventNotesLabel => 'नोट्स';

  @override
  String get resultEventAllDayNotice => 'पूरे दिन का इवेंट।';

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
      'इस इवेंट का शुरू होने का समय नहीं है, इसलिए इसे जोड़ा नहीं जा सकता।';

  @override
  String get resultEventPrimaryButton => 'कैलेंडर में जोड़ें';

  @override
  String get resultPhoneNumberLabel => 'नंबर';

  @override
  String get resultPhonePrimaryButton => 'कॉल करें';

  @override
  String get resultSmsNumberLabel => 'नंबर';

  @override
  String get resultSmsMessageLabel => 'संदेश';

  @override
  String get resultSmsPrimaryButton => 'संदेश भेजें';

  @override
  String get resultEmailToLabel => 'प्रति';

  @override
  String get resultEmailSubjectLabel => 'विषय';

  @override
  String get resultEmailBodyLabel => 'संदेश';

  @override
  String get resultEmailPrimaryButton => 'ईमेल भेजें';

  @override
  String get resultProductNumberLabel => 'नंबर';

  @override
  String get resultProductFormatLabel => 'फ़ॉर्मेट';

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
  String get resultProductSearchButton => 'वेब पर खोजें';

  @override
  String get resultLocationLatitudeLabel => 'अक्षांश';

  @override
  String get resultLocationLongitudeLabel => 'देशांतर';

  @override
  String get resultLocationNameLabel => 'नाम';

  @override
  String get createSubtitle => 'चुनें कि क्या बनाना है';

  @override
  String get createUrlFieldLabel => 'वेब पता';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'यह कोड $url खोलेगा';
  }

  @override
  String get createTextFieldLabel => 'टेक्स्ट';

  @override
  String get createTextFieldHint => 'जो भी आप कोड में रखना चाहें';

  @override
  String get createWifiSsidLabel => 'नेटवर्क नाम';

  @override
  String get createWifiSecurityLabel => 'सुरक्षा';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (असुरक्षित)';

  @override
  String get createWifiPasswordLabel => 'पासवर्ड';

  @override
  String get createWifiHiddenLabel => 'छिपा नेटवर्क';

  @override
  String get createContactNameLabel => 'नाम';

  @override
  String get createContactPhoneLabel => 'फ़ोन (वैकल्पिक)';

  @override
  String get createContactEmailLabel => 'ईमेल (वैकल्पिक)';

  @override
  String get createContactOrganisationLabel => 'संस्था (वैकल्पिक)';

  @override
  String get createPhoneFieldLabel => 'फ़ोन नंबर';

  @override
  String get createEmailToLabel => 'ईमेल पता';

  @override
  String get createEmailSubjectLabel => 'विषय (वैकल्पिक)';

  @override
  String get createEmailBodyLabel => 'संदेश (वैकल्पिक)';

  @override
  String get createSmsNumberLabel => 'फ़ोन नंबर';

  @override
  String get createSmsMessageLabel => 'संदेश (वैकल्पिक)';

  @override
  String get createFieldErrorRequired => 'यह फ़ील्ड ज़रूरी है।';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// या https:// से शुरू होने वाला वेब पता डालें।';

  @override
  String get createFieldErrorInvalidEmail => 'सही ईमेल पता डालें।';

  @override
  String get createFieldErrorInvalidPhone =>
      '3 से 15 अंकों वाला फ़ोन नंबर डालें।';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'क्षमता का $percent% उपयोग हुआ';
  }

  @override
  String get createCapacityOverLimit =>
      'एक QR कोड के लिए यह सामग्री बहुत ज़्यादा है। आगे बढ़ने के लिए इसे छोटा करें।';

  @override
  String get createButtonLabel => 'बनाएँ';

  @override
  String get createCheckingMessage =>
      'जाँचा जा रहा है कि कोड सही स्कैन होता है';

  @override
  String get createContentLabel => 'सामग्री';

  @override
  String get createCodeImageLabel => 'बनाया गया QR कोड';

  @override
  String get createCheckFailedRenderFailed =>
      'कोड नहीं बनाया जा सका। सामग्री छोटी करके फिर कोशिश करें।';

  @override
  String get createCheckFailedDecodeFailed =>
      'इस कोड की जाँच नहीं हो सकी। सहेजें और शेयर करें बंद हैं।';

  @override
  String get createCheckFailedMismatch =>
      'यह कोड आपकी डाली गई सामग्री से मेल नहीं खाता। सहेजें और शेयर करें बंद हैं।';

  @override
  String get createNotSavedToHistory => 'यह कोड इतिहास में सहेजा नहीं जा सका।';

  @override
  String get createSaveButton => 'सहेजें';

  @override
  String get createShareButton => 'शेयर करें';

  @override
  String get createSavedSnackbarNoName => 'कोड सहेजा गया';

  @override
  String createSavedSnackbar(String name) {
    return '$name के रूप में सहेजा गया';
  }

  @override
  String get createShareFailed =>
      'शेयर करने की स्क्रीन नहीं खुली। फिर कोशिश करें।';
}
