// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Quét';

  @override
  String get navCreate => 'Tạo';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get cameraPermissionReason =>
      'Camera chỉ dùng để đọc mã trên thiết bị này.';

  @override
  String get cameraAllowButton => 'Cho phép camera';

  @override
  String get cameraOpenSettingsButton => 'Mở cài đặt';

  @override
  String get scanFromPhotoButton => 'Quét ảnh';

  @override
  String get typeCodeButton => 'Nhập mã';

  @override
  String get placeholderCreateMessage =>
      'Tính năng tạo mã sẽ có trong bản thử nghiệm tiếp theo.';

  @override
  String get placeholderHistoryMessage =>
      'Danh sách Lịch sử sẽ có trong bản thử nghiệm tiếp theo. Các lần quét của bạn vẫn được lưu trên điện thoại này.';

  @override
  String get scanReadyStatus => 'Sẵn sàng';

  @override
  String get scanTargetHint => 'Hướng camera vào mã';

  @override
  String get scanCameraUnavailable =>
      'Không khởi động được camera. Có thể ứng dụng khác đang dùng.';

  @override
  String get scanTorchOn => 'Bật đèn pin';

  @override
  String get scanTorchOff => 'Tắt đèn pin';

  @override
  String get scanZoomLabel => 'Thu phóng';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Đang đọc ảnh';

  @override
  String get scanPhotoPickerFailed =>
      'Không mở được trình chọn ảnh. Hãy thử lại.';

  @override
  String get scanSettingsDidNotOpen =>
      'Không mở được cài đặt. Hãy cho phép camera trong cài đặt điện thoại.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'Đã nhận diện $format: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Đã nhận diện $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhận diện $count mã',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tìm thấy $count mã',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Chọn mã để mở.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dữ liệu nhị phân, $count byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Không tìm thấy mã';

  @override
  String get noCodeFoundHint =>
      'Hãy đảm bảo toàn bộ mã nằm trong ảnh, rõ nét và đủ sáng.';

  @override
  String get tryAnotherPhotoButton => 'Thử ảnh khác';

  @override
  String get actionClose => 'Đóng';

  @override
  String get manualEntryTitle => 'Nhập mã';

  @override
  String get manualEntryFieldLabel => 'Nội dung mã';

  @override
  String get manualEntryFieldHint =>
      'Một liên kết, một đoạn văn bản hoặc số mã vạch';

  @override
  String get manualEntryScanButton => 'Quét';

  @override
  String get settingsGroupGeneral => 'Chung';

  @override
  String get settingsGroupPrivacy => 'Quyền riêng tư';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Giới thiệu';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsSoundOnScan => 'Âm thanh khi quét';

  @override
  String get settingsVibrateOnScan => 'Rung khi quét';

  @override
  String get settingsCopyOnScan => 'Sao chép khi quét';

  @override
  String get settingsSearchEngine => 'Công cụ tìm kiếm';

  @override
  String get settingsSaveHistory => 'Lưu lịch sử';

  @override
  String get settingsSendCrashReports => 'Gửi báo cáo sự cố';

  @override
  String get settingsPrivacyOptions => 'Tùy chọn quyền riêng tư';

  @override
  String get settingsRemoveAds => 'Gỡ quảng cáo';

  @override
  String get settingsRemoveAdsSubtitle => 'Mua một lần';

  @override
  String get settingsRestorePurchase => 'Khôi phục giao dịch';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Mua một lần · $price';
  }

  @override
  String get settingsProOwned => 'Đã gỡ quảng cáo';

  @override
  String get proBuyFailed => 'Không hoàn tất được giao dịch. Hãy thử lại.';

  @override
  String get proRestoreSuccess => 'Đã khôi phục giao dịch.';

  @override
  String get proRestoreNotFound => 'Không tìm thấy giao dịch nào trước đây.';

  @override
  String get proRestoreFailed => 'Không kiểm tra được cửa hàng. Hãy thử lại.';

  @override
  String get proPromptTitle => 'Gỡ quảng cáo?';

  @override
  String get proPromptBody => 'Mua một lần, không bao giờ là thuê bao.';

  @override
  String get proPromptDismissTooltip => 'Bỏ qua';

  @override
  String get settingsFeedback => 'Phản hồi';

  @override
  String get settingsPrivacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get settingsOpenSourceLicences => 'Giấy phép nguồn mở';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Không mở được liên kết.';

  @override
  String get feedbackCategoryLabel => 'Danh mục';

  @override
  String get feedbackCategoryScanning => 'Quét mã';

  @override
  String get feedbackCategoryResults => 'Kết quả';

  @override
  String get feedbackCategoryCreatingCodes => 'Tạo mã';

  @override
  String get feedbackCategoryAds => 'Quảng cáo';

  @override
  String get feedbackCategoryOther => 'Khác';

  @override
  String get feedbackMessageHint =>
      'Điều gì đã xảy ra, và bạn mong đợi điều gì?';

  @override
  String get feedbackSendButton => 'Gửi';

  @override
  String get feedbackSendNoHandler =>
      'Thiết bị này chưa thiết lập ứng dụng email nào.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Phản hồi $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get languageSystemDefault => 'Theo hệ thống';

  @override
  String get historyHeaderToday => 'Hôm nay';

  @override
  String get historyHeaderYesterday => 'Hôm qua';

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
      other: '$count mã',
      zero: 'Không có mã',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Tất cả';

  @override
  String get historySegmentScanned => 'Đã quét';

  @override
  String get historySegmentCreated => 'Đã tạo';

  @override
  String get historyEmptyMessage => 'Mã bạn quét hoặc tạo sẽ hiện ở đây.';

  @override
  String get historyEmptyScanButton => 'Quét mã';

  @override
  String get historyEmptyCreateButton => 'Tạo mã';

  @override
  String get historyEmptyNotSavingMessage => 'Các lần quét mới không được lưu.';

  @override
  String get historyEmptySettingsButton => 'Mở Cài đặt';

  @override
  String get historyLoading => 'Đang tải Lịch sử';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã xóa $count mục',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Hoàn tác';

  @override
  String get historyDeleteFailed => 'Không xóa được. Hãy thử lại.';

  @override
  String get historyUndoFailed => 'Không hoàn tác được. Hãy thử lại.';

  @override
  String get historyLoadFailed => 'Không tải được Lịch sử. Hãy thử lại.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã chọn $count',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Xóa';

  @override
  String get historyCancelSelectionButton => 'Hủy chọn';

  @override
  String copiedSnackbar(String what) {
    return 'Đã sao chép $what';
  }

  @override
  String get copiedWhatLink => 'liên kết';

  @override
  String get copiedWhatContent => 'nội dung';

  @override
  String get resultTitle => 'Kết quả';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Sao chép';

  @override
  String get resultShareButton => 'Chia sẻ';

  @override
  String get resultNotSaved => 'Không lưu được lần quét này vào Lịch sử.';

  @override
  String get resultCopyFailed => 'Không sao chép được. Hãy thử lại.';

  @override
  String get resultShareFailed => 'Không mở được phần chia sẻ. Hãy thử lại.';

  @override
  String get parsedTypeUrl => 'Liên kết';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Văn bản';

  @override
  String get parsedTypeContact => 'Liên hệ';

  @override
  String get parsedTypePhone => 'Số điện thoại';

  @override
  String get parsedTypeEmail => 'Email';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Vị trí';

  @override
  String get parsedTypeEvent => 'Sự kiện';

  @override
  String get parsedTypeProduct => 'Sản phẩm';

  @override
  String get parsedTypeAppStore => 'Ứng dụng';

  @override
  String get parsedTypeUnknown => 'Không rõ';

  @override
  String get symbologyQr => 'Mã QR';

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
  String get symbologyUnknown => 'Định dạng không rõ';

  @override
  String get errorStorageUnavailable =>
      'Không mở được bộ nhớ của ứng dụng. Hãy đóng rồi mở lại.';

  @override
  String get errorSaveFailed => 'Không có gì được lưu. Hãy thử lại.';

  @override
  String get actionRetry => 'Thử lại';

  @override
  String get copiedWhatPassword => 'mật khẩu';

  @override
  String get resultHandOffFailed => 'Không mở được. Hãy thử lại.';

  @override
  String get resultUnavailableWifiSettings =>
      'Không mở được cài đặt Wi-Fi trên thiết bị này.';

  @override
  String get resultUnavailableContacts => 'Chưa cài ứng dụng danh bạ nào.';

  @override
  String get resultUnavailableCalendar => 'Chưa cài ứng dụng lịch nào.';

  @override
  String get resultUnavailableDialer => 'Chưa cài ứng dụng điện thoại nào.';

  @override
  String get resultUnavailableSms => 'Chưa cài ứng dụng nhắn tin nào.';

  @override
  String get resultUnavailableEmail => 'Chưa cài ứng dụng email nào.';

  @override
  String get resultUnavailableBrowser => 'Chưa cài trình duyệt nào.';

  @override
  String get resultLinkOpenButton => 'Mở';

  @override
  String get resultLinkReviewButton => 'Xem lại';

  @override
  String get resultLinkWarningTitle => 'Trước khi mở liên kết này';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Địa chỉ là một dãy số IP, không phải tên';

  @override
  String get resultLinkCheckUserinfo =>
      'Có tên người dùng đứng trước tên trang';

  @override
  String get resultLinkCheckInsecureScheme => 'Không được mã hóa (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Dùng một cổng bất thường';

  @override
  String get resultLinkCheckLongUrl => 'Dài bất thường';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Sao chép mà không mở';

  @override
  String get resultLinkOpenAnywayButton => 'Vẫn mở';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Không mở được liên kết $scheme ở đây.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Ứng dụng này kiểm tra liên kết trước khi mở, để bạn thấy trước nơi nó dẫn đến.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Bỏ qua';

  @override
  String get resultWifiNetworkNameLabel => 'Tên mạng';

  @override
  String get resultWifiSecurityLabel => 'Bảo mật';

  @override
  String get resultWifiPasswordLabel => 'Mật khẩu';

  @override
  String get resultWifiRevealPasswordTooltip => 'Hiện mật khẩu';

  @override
  String get resultWifiHidePasswordTooltip => 'Ẩn mật khẩu';

  @override
  String get resultWifiWepNotice =>
      'Android không thể kết nối mạng WEP từ ứng dụng.';

  @override
  String get resultWifiPrimaryButton => 'Mở cài đặt Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Sao chép mật khẩu';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Mở';

  @override
  String get resultContactNameLabel => 'Tên';

  @override
  String get resultContactPhoneLabel => 'Điện thoại';

  @override
  String get resultContactEmailLabel => 'Email';

  @override
  String get resultContactOrganisationLabel => 'Tổ chức';

  @override
  String get resultContactPrimaryButton => 'Thêm vào danh bạ';

  @override
  String get resultEventTitleLabel => 'Tiêu đề';

  @override
  String get resultEventStartLabel => 'Bắt đầu';

  @override
  String get resultEventEndLabel => 'Kết thúc';

  @override
  String get resultEventLocationLabel => 'Địa điểm';

  @override
  String get resultEventNotesLabel => 'Ghi chú';

  @override
  String get resultEventAllDayNotice => 'Sự kiện cả ngày.';

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
      'Sự kiện này không có giờ bắt đầu nên không thể thêm được.';

  @override
  String get resultEventPrimaryButton => 'Thêm vào lịch';

  @override
  String get resultPhoneNumberLabel => 'Số';

  @override
  String get resultPhonePrimaryButton => 'Gọi';

  @override
  String get resultSmsNumberLabel => 'Số';

  @override
  String get resultSmsMessageLabel => 'Tin nhắn';

  @override
  String get resultSmsPrimaryButton => 'Nhắn tin';

  @override
  String get resultEmailToLabel => 'Đến';

  @override
  String get resultEmailSubjectLabel => 'Chủ đề';

  @override
  String get resultEmailBodyLabel => 'Nội dung';

  @override
  String get resultEmailPrimaryButton => 'Gửi email';

  @override
  String get resultProductNumberLabel => 'Số';

  @override
  String get resultProductFormatLabel => 'Định dạng';

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
  String get resultProductSearchButton => 'Tìm trên web';

  @override
  String get resultLocationLatitudeLabel => 'Vĩ độ';

  @override
  String get resultLocationLongitudeLabel => 'Kinh độ';

  @override
  String get resultLocationNameLabel => 'Tên';

  @override
  String get createSubtitle => 'Chọn thứ cần tạo';

  @override
  String get createUrlFieldLabel => 'Địa chỉ web';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Mã sẽ mở $url';
  }

  @override
  String get createTextFieldLabel => 'Văn bản';

  @override
  String get createTextFieldHint => 'Bất cứ nội dung nào bạn muốn mã chứa';

  @override
  String get createWifiSsidLabel => 'Tên mạng';

  @override
  String get createWifiSecurityLabel => 'Bảo mật';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (không an toàn)';

  @override
  String get createWifiPasswordLabel => 'Mật khẩu';

  @override
  String get createWifiHiddenLabel => 'Mạng ẩn';

  @override
  String get createContactNameLabel => 'Tên';

  @override
  String get createContactPhoneLabel => 'Điện thoại (tùy chọn)';

  @override
  String get createContactEmailLabel => 'Email (tùy chọn)';

  @override
  String get createContactOrganisationLabel => 'Tổ chức (tùy chọn)';

  @override
  String get createPhoneFieldLabel => 'Số điện thoại';

  @override
  String get createEmailToLabel => 'Địa chỉ email';

  @override
  String get createEmailSubjectLabel => 'Chủ đề (tùy chọn)';

  @override
  String get createEmailBodyLabel => 'Nội dung (tùy chọn)';

  @override
  String get createSmsNumberLabel => 'Số điện thoại';

  @override
  String get createSmsMessageLabel => 'Tin nhắn (tùy chọn)';

  @override
  String get createFieldErrorRequired => 'Trường này là bắt buộc.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Hãy nhập địa chỉ web bắt đầu bằng http:// hoặc https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Hãy nhập một địa chỉ email hợp lệ.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Hãy nhập số điện thoại có 3 đến 15 chữ số.';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'Đã dùng $percent% dung lượng';
  }

  @override
  String get createCapacityOverLimit =>
      'Nội dung quá nhiều cho một mã QR. Hãy rút ngắn để tiếp tục.';

  @override
  String get createButtonLabel => 'Tạo';

  @override
  String get createCheckingMessage => 'Đang kiểm tra mã có quét đúng không';

  @override
  String get createContentLabel => 'Nội dung';

  @override
  String get createCodeImageLabel => 'Mã QR đã tạo';

  @override
  String get createCheckFailedRenderFailed =>
      'Không tạo được mã. Hãy rút ngắn nội dung rồi thử lại.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Không kiểm tra được mã này. Lưu và Chia sẻ đã bị tắt.';

  @override
  String get createCheckFailedMismatch =>
      'Mã này không khớp với nội dung bạn đã nhập. Lưu và Chia sẻ đã bị tắt.';

  @override
  String get createNotSavedToHistory => 'Không lưu được mã này vào Lịch sử.';

  @override
  String get createSaveButton => 'Lưu';

  @override
  String get createShareButton => 'Chia sẻ';

  @override
  String get createSavedSnackbarNoName => 'Đã lưu mã';

  @override
  String createSavedSnackbar(String name) {
    return 'Đã lưu với tên $name';
  }

  @override
  String get createShareFailed => 'Không mở được phần chia sẻ. Hãy thử lại.';
}
