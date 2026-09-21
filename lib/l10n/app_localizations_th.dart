// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'สแกน';

  @override
  String get navCreate => 'สร้าง';

  @override
  String get navHistory => 'ประวัติ';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get cameraPermissionReason =>
      'กล้องใช้สำหรับอ่านโค้ดบนเครื่องนี้เท่านั้น';

  @override
  String get cameraAllowButton => 'อนุญาตกล้อง';

  @override
  String get cameraOpenSettingsButton => 'เปิดการตั้งค่า';

  @override
  String get scanFromPhotoButton => 'สแกนจากรูป';

  @override
  String get typeCodeButton => 'พิมพ์โค้ด';

  @override
  String get placeholderCreateMessage => 'การสร้างโค้ดจะมาในรุ่นทดสอบถัดไป';

  @override
  String get placeholderHistoryMessage =>
      'รายการประวัติจะมาในรุ่นทดสอบถัดไป การสแกนของคุณถูกเก็บไว้ในเครื่องนี้แล้ว';

  @override
  String get scanReadyStatus => 'พร้อม';

  @override
  String get scanTargetHint => 'เล็งกล้องไปที่โค้ด';

  @override
  String get scanCameraUnavailable => 'เปิดกล้องไม่ได้ อาจมีแอปอื่นใช้งานอยู่';

  @override
  String get scanTorchOn => 'เปิดไฟฉาย';

  @override
  String get scanTorchOff => 'ปิดไฟฉาย';

  @override
  String get scanZoomLabel => 'ซูม';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'กำลังอ่านรูป';

  @override
  String get scanPhotoPickerFailed => 'เปิดตัวเลือกรูปไม่ได้ ลองอีกครั้ง';

  @override
  String get scanSettingsDidNotOpen =>
      'เปิดการตั้งค่าไม่ได้ อนุญาตกล้องจากการตั้งค่าของเครื่อง';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'ตรวจพบ $format: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'ตรวจพบ $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ตรวจพบโค้ด $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'พบโค้ด $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'เลือกโค้ดที่ต้องการเปิด';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ข้อมูลไบนารี $count ไบต์',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'ไม่พบโค้ด';

  @override
  String get noCodeFoundHint => 'ตรวจดูว่าเห็นโค้ดทั้งหมดในรูป ชัด และมีแสงพอ';

  @override
  String get tryAnotherPhotoButton => 'ลองรูปอื่น';

  @override
  String get actionClose => 'ปิด';

  @override
  String get manualEntryTitle => 'พิมพ์โค้ด';

  @override
  String get manualEntryFieldLabel => 'เนื้อหาโค้ด';

  @override
  String get manualEntryFieldHint => 'ลิงก์ ข้อความ หรือหมายเลขบาร์โค้ด';

  @override
  String get manualEntryScanButton => 'สแกน';

  @override
  String get settingsGroupGeneral => 'ทั่วไป';

  @override
  String get settingsGroupPrivacy => 'ความเป็นส่วนตัว';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'เกี่ยวกับ';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsSoundOnScan => 'เสียงเมื่อสแกน';

  @override
  String get settingsVibrateOnScan => 'สั่นเมื่อสแกน';

  @override
  String get settingsCopyOnScan => 'คัดลอกเมื่อสแกน';

  @override
  String get settingsSearchEngine => 'เครื่องมือค้นหา';

  @override
  String get settingsSaveHistory => 'บันทึกประวัติ';

  @override
  String get settingsSendCrashReports => 'ส่งรายงานข้อขัดข้อง';

  @override
  String get settingsPrivacyOptions => 'ตัวเลือกความเป็นส่วนตัว';

  @override
  String get settingsRemoveAds => 'เอาโฆษณาออก';

  @override
  String get settingsRemoveAdsSubtitle => 'ซื้อครั้งเดียว';

  @override
  String get settingsRestorePurchase => 'กู้คืนการซื้อ';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'ซื้อครั้งเดียว · $price';
  }

  @override
  String get settingsProOwned => 'เอาโฆษณาออกแล้ว';

  @override
  String get proBuyFailed => 'ทำรายการซื้อไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get proRestoreSuccess => 'กู้คืนการซื้อแล้ว';

  @override
  String get proRestoreNotFound => 'ไม่พบการซื้อก่อนหน้า';

  @override
  String get proRestoreFailed => 'ตรวจสอบสโตร์ไม่ได้ ลองอีกครั้ง';

  @override
  String get proPromptTitle => 'เอาโฆษณาออกไหม';

  @override
  String get proPromptBody => 'ซื้อครั้งเดียว ไม่ใช่การสมัครสมาชิก';

  @override
  String get proPromptDismissTooltip => 'ปิด';

  @override
  String get settingsFeedback => 'ความคิดเห็น';

  @override
  String get settingsPrivacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get settingsOpenSourceLicences => 'ใบอนุญาตโอเพนซอร์ส';

  @override
  String get settingsVersion => 'เวอร์ชัน';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'เปิดลิงก์ไม่ได้';

  @override
  String get feedbackCategoryLabel => 'หมวดหมู่';

  @override
  String get feedbackCategoryScanning => 'การสแกน';

  @override
  String get feedbackCategoryResults => 'ผลลัพธ์';

  @override
  String get feedbackCategoryCreatingCodes => 'การสร้างโค้ด';

  @override
  String get feedbackCategoryAds => 'โฆษณา';

  @override
  String get feedbackCategoryOther => 'อื่น ๆ';

  @override
  String get feedbackMessageHint => 'เกิดอะไรขึ้น และคุณคาดว่าจะเป็นอย่างไร';

  @override
  String get feedbackSendButton => 'ส่ง';

  @override
  String get feedbackSendNoHandler => 'เครื่องนี้ยังไม่ได้ตั้งค่าแอปอีเมล';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'ความคิดเห็นเกี่ยวกับ $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'ค่าเริ่มต้นของระบบ';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get themeDark => 'มืด';

  @override
  String get languageSystemDefault => 'ค่าเริ่มต้นของระบบ';

  @override
  String get historyHeaderToday => 'วันนี้';

  @override
  String get historyHeaderYesterday => 'เมื่อวาน';

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
      other: 'โค้ด $count รายการ',
      zero: 'ไม่มีโค้ด',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'ทั้งหมด';

  @override
  String get historySegmentScanned => 'สแกนแล้ว';

  @override
  String get historySegmentCreated => 'สร้างแล้ว';

  @override
  String get historyEmptyMessage => 'โค้ดที่คุณสแกนหรือสร้างจะแสดงที่นี่';

  @override
  String get historyEmptyScanButton => 'สแกนโค้ด';

  @override
  String get historyEmptyCreateButton => 'สร้างโค้ด';

  @override
  String get historyEmptyNotSavingMessage => 'การสแกนใหม่จะไม่ถูกบันทึก';

  @override
  String get historyEmptySettingsButton => 'ไปที่การตั้งค่า';

  @override
  String get historyLoading => 'กำลังโหลดประวัติ';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบแล้ว $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'เลิกทำ';

  @override
  String get historyDeleteFailed => 'ลบไม่ได้ ลองอีกครั้ง';

  @override
  String get historyUndoFailed => 'เลิกทำไม่ได้ ลองอีกครั้ง';

  @override
  String get historyLoadFailed => 'โหลดประวัติไม่ได้ ลองอีกครั้ง';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เลือกแล้ว $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'ลบ';

  @override
  String get historyCancelSelectionButton => 'ยกเลิกการเลือก';

  @override
  String copiedSnackbar(String what) {
    return 'คัดลอก$whatแล้ว';
  }

  @override
  String get copiedWhatLink => 'ลิงก์';

  @override
  String get copiedWhatContent => 'เนื้อหา';

  @override
  String get resultTitle => 'ผลลัพธ์';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'คัดลอก';

  @override
  String get resultShareButton => 'แชร์';

  @override
  String get resultNotSaved => 'บันทึกการสแกนนี้ลงประวัติไม่ได้';

  @override
  String get resultCopyFailed => 'คัดลอกไม่ได้ ลองอีกครั้ง';

  @override
  String get resultShareFailed => 'เปิดการแชร์ไม่ได้ ลองอีกครั้ง';

  @override
  String get parsedTypeUrl => 'ลิงก์';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'ข้อความ';

  @override
  String get parsedTypeContact => 'ผู้ติดต่อ';

  @override
  String get parsedTypePhone => 'หมายเลขโทรศัพท์';

  @override
  String get parsedTypeEmail => 'อีเมล';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'ตำแหน่ง';

  @override
  String get parsedTypeEvent => 'กิจกรรม';

  @override
  String get parsedTypeProduct => 'สินค้า';

  @override
  String get parsedTypeAppStore => 'แอป';

  @override
  String get parsedTypeUnknown => 'ไม่ทราบ';

  @override
  String get symbologyQr => 'โค้ด QR';

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
  String get symbologyUnknown => 'รูปแบบที่ไม่รู้จัก';

  @override
  String get errorStorageUnavailable =>
      'แอปเปิดที่เก็บข้อมูลไม่ได้ ปิดแล้วเปิดใหม่อีกครั้ง';

  @override
  String get errorSaveFailed => 'ไม่มีอะไรถูกบันทึก ลองอีกครั้ง';

  @override
  String get actionRetry => 'ลองอีกครั้ง';

  @override
  String get copiedWhatPassword => 'รหัสผ่าน';

  @override
  String get resultHandOffFailed => 'เปิดไม่ได้ ลองอีกครั้ง';

  @override
  String get resultUnavailableWifiSettings =>
      'เปิดการตั้งค่า Wi-Fi บนเครื่องนี้ไม่ได้';

  @override
  String get resultUnavailableContacts => 'ไม่ได้ติดตั้งแอปรายชื่อติดต่อ';

  @override
  String get resultUnavailableCalendar => 'ไม่ได้ติดตั้งแอปปฏิทิน';

  @override
  String get resultUnavailableDialer => 'ไม่ได้ติดตั้งแอปโทรศัพท์';

  @override
  String get resultUnavailableSms => 'ไม่ได้ติดตั้งแอปข้อความ';

  @override
  String get resultUnavailableEmail => 'ไม่ได้ติดตั้งแอปอีเมล';

  @override
  String get resultUnavailableBrowser => 'ไม่ได้ติดตั้งเบราว์เซอร์';

  @override
  String get resultLinkOpenButton => 'เปิด';

  @override
  String get resultLinkReviewButton => 'ตรวจสอบ';

  @override
  String get resultLinkWarningTitle => 'ก่อนเปิดลิงก์นี้';

  @override
  String get resultLinkCheckIpAddressHost =>
      'ที่อยู่เป็นหมายเลข IP ไม่ใช่ชื่อเว็บ';

  @override
  String get resultLinkCheckUserinfo => 'มีชื่อผู้ใช้อยู่หน้าชื่อเว็บ';

  @override
  String get resultLinkCheckInsecureScheme => 'ไม่ได้เข้ารหัส (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'ใช้พอร์ตที่ไม่ปกติ';

  @override
  String get resultLinkCheckLongUrl => 'ยาวผิดปกติ';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'คัดลอกโดยไม่เปิด';

  @override
  String get resultLinkOpenAnywayButton => 'เปิดต่อไป';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'เปิดลิงก์ $scheme ที่นี่ไม่ได้';
  }

  @override
  String get resultLinkCalloutMessage =>
      'แอปนี้ตรวจสอบลิงก์ก่อนเปิด คุณจึงเห็นก่อนว่าลิงก์พาไปที่ใด';

  @override
  String get resultLinkCalloutDismissTooltip => 'ปิด';

  @override
  String get resultWifiNetworkNameLabel => 'ชื่อเครือข่าย';

  @override
  String get resultWifiSecurityLabel => 'ความปลอดภัย';

  @override
  String get resultWifiPasswordLabel => 'รหัสผ่าน';

  @override
  String get resultWifiRevealPasswordTooltip => 'แสดงรหัสผ่าน';

  @override
  String get resultWifiHidePasswordTooltip => 'ซ่อนรหัสผ่าน';

  @override
  String get resultWifiWepNotice =>
      'Android เชื่อมต่อเครือข่าย WEP จากแอปไม่ได้';

  @override
  String get resultWifiPrimaryButton => 'เปิดการตั้งค่า Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'คัดลอกรหัสผ่าน';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'ไม่เข้ารหัส';

  @override
  String get resultContactNameLabel => 'ชื่อ';

  @override
  String get resultContactPhoneLabel => 'โทรศัพท์';

  @override
  String get resultContactEmailLabel => 'อีเมล';

  @override
  String get resultContactOrganisationLabel => 'องค์กร';

  @override
  String get resultContactPrimaryButton => 'เพิ่มในรายชื่อติดต่อ';

  @override
  String get resultEventTitleLabel => 'ชื่อกิจกรรม';

  @override
  String get resultEventStartLabel => 'เริ่ม';

  @override
  String get resultEventEndLabel => 'สิ้นสุด';

  @override
  String get resultEventLocationLabel => 'สถานที่';

  @override
  String get resultEventNotesLabel => 'หมายเหตุ';

  @override
  String get resultEventAllDayNotice => 'กิจกรรมตลอดวัน';

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
      'กิจกรรมนี้ไม่มีเวลาเริ่ม จึงเพิ่มไม่ได้';

  @override
  String get resultEventPrimaryButton => 'เพิ่มในปฏิทิน';

  @override
  String get resultPhoneNumberLabel => 'หมายเลข';

  @override
  String get resultPhonePrimaryButton => 'โทร';

  @override
  String get resultSmsNumberLabel => 'หมายเลข';

  @override
  String get resultSmsMessageLabel => 'ข้อความ';

  @override
  String get resultSmsPrimaryButton => 'ส่งข้อความ';

  @override
  String get resultEmailToLabel => 'ถึง';

  @override
  String get resultEmailSubjectLabel => 'หัวเรื่อง';

  @override
  String get resultEmailBodyLabel => 'ข้อความ';

  @override
  String get resultEmailPrimaryButton => 'ส่งอีเมล';

  @override
  String get resultProductNumberLabel => 'หมายเลข';

  @override
  String get resultProductFormatLabel => 'รูปแบบ';

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
  String get resultProductSearchButton => 'ค้นหาบนเว็บ';

  @override
  String get resultLocationLatitudeLabel => 'ละติจูด';

  @override
  String get resultLocationLongitudeLabel => 'ลองจิจูด';

  @override
  String get resultLocationNameLabel => 'ชื่อ';

  @override
  String get createSubtitle => 'เลือกสิ่งที่ต้องการสร้าง';

  @override
  String get createUrlFieldLabel => 'ที่อยู่เว็บ';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'โค้ดนี้จะเปิด $url';
  }

  @override
  String get createTextFieldLabel => 'ข้อความ';

  @override
  String get createTextFieldHint => 'ข้อความใดก็ได้ที่ต้องการใส่ในโค้ด';

  @override
  String get createWifiSsidLabel => 'ชื่อเครือข่าย';

  @override
  String get createWifiSecurityLabel => 'ความปลอดภัย';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (ไม่ปลอดภัย)';

  @override
  String get createWifiPasswordLabel => 'รหัสผ่าน';

  @override
  String get createWifiHiddenLabel => 'เครือข่ายที่ซ่อนอยู่';

  @override
  String get createContactNameLabel => 'ชื่อ';

  @override
  String get createContactPhoneLabel => 'โทรศัพท์ (ไม่บังคับ)';

  @override
  String get createContactEmailLabel => 'อีเมล (ไม่บังคับ)';

  @override
  String get createContactOrganisationLabel => 'องค์กร (ไม่บังคับ)';

  @override
  String get createPhoneFieldLabel => 'หมายเลขโทรศัพท์';

  @override
  String get createEmailToLabel => 'ที่อยู่อีเมล';

  @override
  String get createEmailSubjectLabel => 'หัวเรื่อง (ไม่บังคับ)';

  @override
  String get createEmailBodyLabel => 'ข้อความ (ไม่บังคับ)';

  @override
  String get createSmsNumberLabel => 'หมายเลขโทรศัพท์';

  @override
  String get createSmsMessageLabel => 'ข้อความ (ไม่บังคับ)';

  @override
  String get createFieldErrorRequired => 'ต้องกรอกช่องนี้';

  @override
  String get createFieldErrorInvalidUrl =>
      'ใส่ที่อยู่เว็บที่ขึ้นต้นด้วย http:// หรือ https://';

  @override
  String get createFieldErrorInvalidEmail => 'ใส่ที่อยู่อีเมลที่ถูกต้อง';

  @override
  String get createFieldErrorInvalidPhone => 'ใส่หมายเลขโทรศัพท์ 3 ถึง 15 หลัก';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'ใช้ความจุแล้ว $percent%';
  }

  @override
  String get createCapacityOverLimit =>
      'เนื้อหามากเกินไปสำหรับโค้ด QR ลดให้สั้นลงเพื่อไปต่อ';

  @override
  String get createButtonLabel => 'สร้าง';

  @override
  String get createCheckingMessage => 'กำลังตรวจว่าโค้ดสแกนได้ถูกต้อง';

  @override
  String get createContentLabel => 'เนื้อหา';

  @override
  String get createCodeImageLabel => 'โค้ด QR ที่สร้างขึ้น';

  @override
  String get createCheckFailedRenderFailed =>
      'สร้างโค้ดไม่ได้ ลดเนื้อหาให้สั้นลงแล้วลองอีกครั้ง';

  @override
  String get createCheckFailedDecodeFailed =>
      'ตรวจสอบโค้ดนี้ไม่ได้ ปุ่มบันทึกและแชร์จึงถูกปิดไว้';

  @override
  String get createCheckFailedMismatch =>
      'โค้ดนี้ไม่ตรงกับที่คุณกรอก ปุ่มบันทึกและแชร์จึงถูกปิดไว้';

  @override
  String get createNotSavedToHistory => 'บันทึกโค้ดนี้ลงประวัติไม่ได้';

  @override
  String get createSaveButton => 'บันทึก';

  @override
  String get createShareButton => 'แชร์';

  @override
  String get createSavedSnackbarNoName => 'บันทึกโค้ดแล้ว';

  @override
  String createSavedSnackbar(String name) {
    return 'บันทึกเป็น $name แล้ว';
  }

  @override
  String get createShareFailed => 'เปิดการแชร์ไม่ได้ ลองอีกครั้ง';
}
