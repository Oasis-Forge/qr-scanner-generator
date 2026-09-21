// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => '스캔';

  @override
  String get navCreate => '만들기';

  @override
  String get navHistory => '기록';

  @override
  String get navSettings => '설정';

  @override
  String get cameraPermissionReason => '카메라는 이 기기에서 코드를 읽는 데에만 사용됩니다.';

  @override
  String get cameraAllowButton => '카메라 허용';

  @override
  String get cameraOpenSettingsButton => '설정 열기';

  @override
  String get scanFromPhotoButton => '사진 스캔';

  @override
  String get typeCodeButton => '코드 입력';

  @override
  String get placeholderCreateMessage => '코드 만들기는 다음 테스트 빌드에 들어갑니다.';

  @override
  String get placeholderHistoryMessage =>
      '기록 목록은 다음 테스트 빌드에 들어갑니다. 스캔한 내용은 이미 이 휴대폰에 저장되어 있습니다.';

  @override
  String get scanReadyStatus => '준비됨';

  @override
  String get scanTargetHint => '코드에 카메라를 비추세요';

  @override
  String get scanCameraUnavailable => '카메라를 시작할 수 없습니다. 다른 앱이 사용 중일 수 있습니다.';

  @override
  String get scanTorchOn => '손전등 켜기';

  @override
  String get scanTorchOff => '손전등 끄기';

  @override
  String get scanZoomLabel => '확대/축소';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => '사진을 읽는 중';

  @override
  String get scanPhotoPickerFailed => '사진 선택기가 열리지 않았습니다. 다시 시도하세요.';

  @override
  String get scanSettingsDidNotOpen => '설정이 열리지 않았습니다. 휴대폰 설정에서 카메라를 허용하세요.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format 감지됨: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type 감지됨';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '코드 $count개 감지됨',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '코드 $count개 찾음',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => '열 코드를 선택하세요.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '바이너리 데이터, $count바이트',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => '코드 없음';

  @override
  String get noCodeFoundHint => '코드 전체가 사진에 또렷하고 밝게 담겼는지 확인하세요.';

  @override
  String get tryAnotherPhotoButton => '다른 사진 선택';

  @override
  String get actionClose => '닫기';

  @override
  String get manualEntryTitle => '코드 입력';

  @override
  String get manualEntryFieldLabel => '코드 내용';

  @override
  String get manualEntryFieldHint => '링크, 텍스트 또는 바코드 번호';

  @override
  String get manualEntryScanButton => '스캔';

  @override
  String get settingsGroupGeneral => '일반';

  @override
  String get settingsGroupPrivacy => '개인 정보';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => '정보';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsSoundOnScan => '스캔 시 소리';

  @override
  String get settingsVibrateOnScan => '스캔 시 진동';

  @override
  String get settingsCopyOnScan => '스캔 시 복사';

  @override
  String get settingsSearchEngine => '검색 엔진';

  @override
  String get settingsSaveHistory => '기록 저장';

  @override
  String get settingsSendCrashReports => '오류 보고서 보내기';

  @override
  String get settingsPrivacyOptions => '개인 정보 옵션';

  @override
  String get settingsRemoveAds => '광고 제거';

  @override
  String get settingsRemoveAdsSubtitle => '1회 구매';

  @override
  String get settingsRestorePurchase => '구매 복원';

  @override
  String settingsRemoveAdsPrice(String price) {
    return '1회 구매 · $price';
  }

  @override
  String get settingsProOwned => '광고 제거됨';

  @override
  String get proBuyFailed => '구매를 완료할 수 없습니다. 다시 시도하세요.';

  @override
  String get proRestoreSuccess => '구매를 복원했습니다.';

  @override
  String get proRestoreNotFound => '이전 구매를 찾지 못했습니다.';

  @override
  String get proRestoreFailed => '스토어를 확인할 수 없습니다. 다시 시도하세요.';

  @override
  String get proPromptTitle => '광고를 제거할까요?';

  @override
  String get proPromptBody => '구독이 아니라 1회 구매입니다.';

  @override
  String get proPromptDismissTooltip => '닫기';

  @override
  String get settingsFeedback => '의견 보내기';

  @override
  String get settingsPrivacyPolicy => '개인정보처리방침';

  @override
  String get settingsOpenSourceLicences => '오픈소스 라이선스';

  @override
  String get settingsVersion => '버전';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => '링크를 열 수 없습니다.';

  @override
  String get feedbackCategoryLabel => '분류';

  @override
  String get feedbackCategoryScanning => '스캔';

  @override
  String get feedbackCategoryResults => '결과';

  @override
  String get feedbackCategoryCreatingCodes => '코드 만들기';

  @override
  String get feedbackCategoryAds => '광고';

  @override
  String get feedbackCategoryOther => '기타';

  @override
  String get feedbackMessageHint => '무슨 일이 있었고, 무엇을 기대했나요?';

  @override
  String get feedbackSendButton => '보내기';

  @override
  String get feedbackSendNoHandler => '이 기기에 설정된 이메일 앱이 없습니다.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle 의견 ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => '시스템 기본값';

  @override
  String get themeLight => '밝게';

  @override
  String get themeDark => '어둡게';

  @override
  String get languageSystemDefault => '시스템 기본값';

  @override
  String get historyHeaderToday => '오늘';

  @override
  String get historyHeaderYesterday => '어제';

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
      other: '코드 $count개',
      zero: '코드 없음',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => '전체';

  @override
  String get historySegmentScanned => '스캔';

  @override
  String get historySegmentCreated => '만들기';

  @override
  String get historyEmptyMessage => '스캔하거나 만든 코드가 여기에 표시됩니다.';

  @override
  String get historyEmptyScanButton => '코드 스캔';

  @override
  String get historyEmptyCreateButton => '코드 만들기';

  @override
  String get historyEmptyNotSavingMessage => '새 스캔이 저장되지 않고 있습니다.';

  @override
  String get historyEmptySettingsButton => '설정으로 이동';

  @override
  String get historyLoading => '기록 불러오는 중';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 삭제됨',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => '실행 취소';

  @override
  String get historyDeleteFailed => '삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get historyUndoFailed => '실행을 취소할 수 없습니다. 다시 시도하세요.';

  @override
  String get historyLoadFailed => '기록을 불러올 수 없습니다. 다시 시도하세요.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 선택됨',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => '삭제';

  @override
  String get historyCancelSelectionButton => '선택 취소';

  @override
  String copiedSnackbar(String what) {
    return '$what 복사됨';
  }

  @override
  String get copiedWhatLink => '링크';

  @override
  String get copiedWhatContent => '내용';

  @override
  String get resultTitle => '결과';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => '복사';

  @override
  String get resultShareButton => '공유';

  @override
  String get resultNotSaved => '이 스캔을 기록에 저장하지 못했습니다.';

  @override
  String get resultCopyFailed => '복사할 수 없습니다. 다시 시도하세요.';

  @override
  String get resultShareFailed => '공유를 열 수 없습니다. 다시 시도하세요.';

  @override
  String get parsedTypeUrl => '링크';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => '텍스트';

  @override
  String get parsedTypeContact => '연락처';

  @override
  String get parsedTypePhone => '전화번호';

  @override
  String get parsedTypeEmail => '이메일';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => '위치';

  @override
  String get parsedTypeEvent => '일정';

  @override
  String get parsedTypeProduct => '제품';

  @override
  String get parsedTypeAppStore => '앱';

  @override
  String get parsedTypeUnknown => '알 수 없음';

  @override
  String get symbologyQr => 'QR 코드';

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
  String get symbologyUnknown => '알 수 없는 형식';

  @override
  String get errorStorageUnavailable => '앱이 저장소를 열 수 없습니다. 앱을 닫았다가 다시 여세요.';

  @override
  String get errorSaveFailed => '저장된 것이 없습니다. 다시 시도하세요.';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get copiedWhatPassword => '비밀번호';

  @override
  String get resultHandOffFailed => '열 수 없습니다. 다시 시도하세요.';

  @override
  String get resultUnavailableWifiSettings => '이 기기에서는 Wi-Fi 설정을 열 수 없습니다.';

  @override
  String get resultUnavailableContacts => '설치된 연락처 앱이 없습니다.';

  @override
  String get resultUnavailableCalendar => '설치된 캘린더 앱이 없습니다.';

  @override
  String get resultUnavailableDialer => '설치된 전화 앱이 없습니다.';

  @override
  String get resultUnavailableSms => '설치된 메시지 앱이 없습니다.';

  @override
  String get resultUnavailableEmail => '설치된 이메일 앱이 없습니다.';

  @override
  String get resultUnavailableBrowser => '설치된 브라우저가 없습니다.';

  @override
  String get resultLinkOpenButton => '열기';

  @override
  String get resultLinkReviewButton => '자세히 보기';

  @override
  String get resultLinkWarningTitle => '이 링크를 열기 전에';

  @override
  String get resultLinkCheckIpAddressHost => '주소가 이름이 아니라 IP 번호입니다';

  @override
  String get resultLinkCheckUserinfo => '사이트 이름 앞에 사용자 이름이 있습니다';

  @override
  String get resultLinkCheckInsecureScheme => '암호화되지 않았습니다 (http)';

  @override
  String get resultLinkCheckNonDefaultPort => '흔치 않은 포트를 사용합니다';

  @override
  String get resultLinkCheckLongUrl => '유난히 깁니다';

  @override
  String get resultLinkCopyWithoutOpeningButton => '열지 않고 복사';

  @override
  String get resultLinkOpenAnywayButton => '그래도 열기';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme 링크는 여기에서 열 수 없습니다.';
  }

  @override
  String get resultLinkCalloutMessage =>
      '이 앱은 링크를 열기 전에 확인하므로, 어디로 이어지는지 먼저 볼 수 있습니다.';

  @override
  String get resultLinkCalloutDismissTooltip => '닫기';

  @override
  String get resultWifiNetworkNameLabel => '네트워크 이름';

  @override
  String get resultWifiSecurityLabel => '보안';

  @override
  String get resultWifiPasswordLabel => '비밀번호';

  @override
  String get resultWifiRevealPasswordTooltip => '비밀번호 표시';

  @override
  String get resultWifiHidePasswordTooltip => '비밀번호 숨기기';

  @override
  String get resultWifiWepNotice => 'Android는 앱에서 WEP 네트워크에 연결할 수 없습니다.';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi 설정 열기';

  @override
  String get resultWifiCopyPasswordButton => '비밀번호 복사';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => '개방형';

  @override
  String get resultContactNameLabel => '이름';

  @override
  String get resultContactPhoneLabel => '전화';

  @override
  String get resultContactEmailLabel => '이메일';

  @override
  String get resultContactOrganisationLabel => '소속';

  @override
  String get resultContactPrimaryButton => '연락처에 추가';

  @override
  String get resultEventTitleLabel => '제목';

  @override
  String get resultEventStartLabel => '시작';

  @override
  String get resultEventEndLabel => '종료';

  @override
  String get resultEventLocationLabel => '장소';

  @override
  String get resultEventNotesLabel => '메모';

  @override
  String get resultEventAllDayNotice => '종일 일정입니다.';

  @override
  String resultEventTimeUtc(String time) {
    return '$time UTC';
  }

  @override
  String resultEventTimeZoned(String time, String zone) {
    return '$time ($zone)';
  }

  @override
  String get resultUnavailableEventNoStart => '이 일정은 시작 시간이 없어 추가할 수 없습니다.';

  @override
  String get resultEventPrimaryButton => '캘린더에 추가';

  @override
  String get resultPhoneNumberLabel => '번호';

  @override
  String get resultPhonePrimaryButton => '전화 걸기';

  @override
  String get resultSmsNumberLabel => '번호';

  @override
  String get resultSmsMessageLabel => '메시지';

  @override
  String get resultSmsPrimaryButton => '메시지 보내기';

  @override
  String get resultEmailToLabel => '받는 사람';

  @override
  String get resultEmailSubjectLabel => '제목';

  @override
  String get resultEmailBodyLabel => '메시지';

  @override
  String get resultEmailPrimaryButton => '이메일 보내기';

  @override
  String get resultProductNumberLabel => '번호';

  @override
  String get resultProductFormatLabel => '형식';

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
  String get resultProductSearchButton => '웹에서 검색';

  @override
  String get resultLocationLatitudeLabel => '위도';

  @override
  String get resultLocationLongitudeLabel => '경도';

  @override
  String get resultLocationNameLabel => '이름';

  @override
  String get createSubtitle => '무엇을 만들지 선택하세요';

  @override
  String get createUrlFieldLabel => '웹 주소';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return '이 코드는 $url(으)로 이동합니다';
  }

  @override
  String get createTextFieldLabel => '텍스트';

  @override
  String get createTextFieldHint => '코드에 담고 싶은 내용';

  @override
  String get createWifiSsidLabel => '네트워크 이름';

  @override
  String get createWifiSecurityLabel => '보안';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (안전하지 않음)';

  @override
  String get createWifiPasswordLabel => '비밀번호';

  @override
  String get createWifiHiddenLabel => '숨겨진 네트워크';

  @override
  String get createContactNameLabel => '이름';

  @override
  String get createContactPhoneLabel => '전화 (선택)';

  @override
  String get createContactEmailLabel => '이메일 (선택)';

  @override
  String get createContactOrganisationLabel => '소속 (선택)';

  @override
  String get createPhoneFieldLabel => '전화번호';

  @override
  String get createEmailToLabel => '이메일 주소';

  @override
  String get createEmailSubjectLabel => '제목 (선택)';

  @override
  String get createEmailBodyLabel => '메시지 (선택)';

  @override
  String get createSmsNumberLabel => '전화번호';

  @override
  String get createSmsMessageLabel => '메시지 (선택)';

  @override
  String get createFieldErrorRequired => '필수 항목입니다.';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// 또는 https://로 시작하는 웹 주소를 입력하세요.';

  @override
  String get createFieldErrorInvalidEmail => '올바른 이메일 주소를 입력하세요.';

  @override
  String get createFieldErrorInvalidPhone => '숫자 3~15자리의 전화번호를 입력하세요.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '용량의 $percent% 사용됨';
  }

  @override
  String get createCapacityOverLimit =>
      'QR 코드에 담기에는 내용이 너무 많습니다. 줄여야 계속할 수 있습니다.';

  @override
  String get createButtonLabel => '만들기';

  @override
  String get createCheckingMessage => '코드가 제대로 스캔되는지 확인하는 중';

  @override
  String get createContentLabel => '내용';

  @override
  String get createCodeImageLabel => '만들어진 QR 코드';

  @override
  String get createCheckFailedRenderFailed =>
      '코드를 만들지 못했습니다. 내용을 줄이고 다시 시도하세요.';

  @override
  String get createCheckFailedDecodeFailed =>
      '이 코드를 확인하지 못했습니다. 저장과 공유를 사용할 수 없습니다.';

  @override
  String get createCheckFailedMismatch =>
      '이 코드가 입력한 내용과 일치하지 않습니다. 저장과 공유를 사용할 수 없습니다.';

  @override
  String get createNotSavedToHistory => '이 코드를 기록에 저장하지 못했습니다.';

  @override
  String get createSaveButton => '저장';

  @override
  String get createShareButton => '공유';

  @override
  String get createSavedSnackbarNoName => '코드 저장됨';

  @override
  String createSavedSnackbar(String name) {
    return '$name(으)로 저장됨';
  }

  @override
  String get createShareFailed => '공유를 열 수 없습니다. 다시 시도하세요.';
}
