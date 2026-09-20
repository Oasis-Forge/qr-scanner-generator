// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => '扫描';

  @override
  String get navCreate => '创建';

  @override
  String get navHistory => '历史';

  @override
  String get navSettings => '设置';

  @override
  String get cameraPermissionReason => '相机仅用于在本机上读取码。';

  @override
  String get cameraAllowButton => '允许使用相机';

  @override
  String get cameraOpenSettingsButton => '打开设置';

  @override
  String get scanFromPhotoButton => '扫描照片';

  @override
  String get typeCodeButton => '手动输入';

  @override
  String get placeholderCreateMessage => '创建码将在下一个测试版本中提供。';

  @override
  String get placeholderHistoryMessage => '历史列表将在下一个测试版本中提供。你的扫描记录已保存在这部手机上。';

  @override
  String get scanReadyStatus => '就绪';

  @override
  String get scanTargetHint => '将相机对准码';

  @override
  String get scanCameraUnavailable => '相机无法启动，可能有其他应用正在使用它。';

  @override
  String get scanTorchOn => '打开手电筒';

  @override
  String get scanTorchOff => '关闭手电筒';

  @override
  String get scanZoomLabel => '缩放';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => '正在读取照片';

  @override
  String get scanPhotoPickerFailed => '照片选择器未能打开，请重试。';

  @override
  String get scanSettingsDidNotOpen => '设置未能打开，请在手机设置中允许使用相机。';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '检测到 $format：$type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '检测到 $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '检测到 $count 个码',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 个码',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => '选择要打开的码。';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '二进制数据，$count 字节',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => '未找到码';

  @override
  String get noCodeFoundHint => '请确保整个码都在照片里，清晰且光线充足。';

  @override
  String get tryAnotherPhotoButton => '换一张照片';

  @override
  String get actionClose => '关闭';

  @override
  String get manualEntryTitle => '手动输入';

  @override
  String get manualEntryFieldLabel => '码内容';

  @override
  String get manualEntryFieldHint => '一个链接、一段文字或条码号';

  @override
  String get manualEntryScanButton => '扫描';

  @override
  String get settingsGroupGeneral => '通用';

  @override
  String get settingsGroupPrivacy => '隐私';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => '关于';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsSoundOnScan => '扫描时提示音';

  @override
  String get settingsVibrateOnScan => '扫描时振动';

  @override
  String get settingsCopyOnScan => '扫描时复制';

  @override
  String get settingsSearchEngine => '搜索引擎';

  @override
  String get settingsSaveHistory => '保存历史';

  @override
  String get settingsSendCrashReports => '发送崩溃报告';

  @override
  String get settingsPrivacyOptions => '隐私选项';

  @override
  String get settingsRemoveAds => '去除广告';

  @override
  String get settingsRemoveAdsSubtitle => '一次性购买';

  @override
  String get settingsRestorePurchase => '恢复购买';

  @override
  String settingsRemoveAdsPrice(String price) {
    return '一次性购买 · $price';
  }

  @override
  String get settingsProOwned => '广告已去除';

  @override
  String get proBuyFailed => '购买未能完成，请重试。';

  @override
  String get proRestoreSuccess => '购买已恢复。';

  @override
  String get proRestoreNotFound => '未找到以前的购买记录。';

  @override
  String get proRestoreFailed => '无法查询商店，请重试。';

  @override
  String get proPromptTitle => '去除广告？';

  @override
  String get proPromptBody => '一次性购买，不是订阅。';

  @override
  String get proPromptDismissTooltip => '关闭';

  @override
  String get settingsFeedback => '反馈';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsOpenSourceLicences => '开源许可';

  @override
  String get settingsVersion => '版本';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version（$build）';
  }

  @override
  String get settingsLinkOpenFailed => '无法打开链接。';

  @override
  String get feedbackCategoryLabel => '类别';

  @override
  String get feedbackCategoryScanning => '扫描';

  @override
  String get feedbackCategoryResults => '结果';

  @override
  String get feedbackCategoryCreatingCodes => '创建码';

  @override
  String get feedbackCategoryAds => '广告';

  @override
  String get feedbackCategoryOther => '其他';

  @override
  String get feedbackMessageHint => '发生了什么，你期望的是什么？';

  @override
  String get feedbackSendButton => '发送';

  @override
  String get feedbackSendNoHandler => '本机上没有设置电子邮件应用。';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle 反馈（$version+$build，$androidVersion）';
  }

  @override
  String get themeSystemDefault => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get historyHeaderToday => '今天';

  @override
  String get historyHeaderYesterday => '昨天';

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
      other: '$count 个码',
      zero: '没有码',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => '全部';

  @override
  String get historySegmentScanned => '已扫描';

  @override
  String get historySegmentCreated => '已创建';

  @override
  String get historyEmptyMessage => '你扫描或创建的码会显示在这里。';

  @override
  String get historyEmptyScanButton => '扫描码';

  @override
  String get historyEmptyCreateButton => '创建码';

  @override
  String get historyEmptyNotSavingMessage => '新的扫描不会被保存。';

  @override
  String get historyEmptySettingsButton => '前往设置';

  @override
  String get historyLoading => '正在加载历史';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => '撤销';

  @override
  String get historyDeleteFailed => '无法删除，请重试。';

  @override
  String get historyUndoFailed => '无法撤销，请重试。';

  @override
  String get historyLoadFailed => '历史无法加载，请重试。';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => '删除';

  @override
  String get historyCancelSelectionButton => '取消选择';

  @override
  String copiedSnackbar(String what) {
    return '已复制$what';
  }

  @override
  String get copiedWhatLink => '链接';

  @override
  String get copiedWhatContent => '内容';

  @override
  String get resultTitle => '结果';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => '复制';

  @override
  String get resultShareButton => '分享';

  @override
  String get resultNotSaved => '这次扫描未能保存到历史。';

  @override
  String get resultCopyFailed => '无法复制，请重试。';

  @override
  String get resultShareFailed => '无法打开分享，请重试。';

  @override
  String get parsedTypeUrl => '链接';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => '文字';

  @override
  String get parsedTypeContact => '联系人';

  @override
  String get parsedTypePhone => '电话号码';

  @override
  String get parsedTypeEmail => '电子邮件';

  @override
  String get parsedTypeSms => '短信';

  @override
  String get parsedTypeGeo => '位置';

  @override
  String get parsedTypeEvent => '日程';

  @override
  String get parsedTypeProduct => '商品';

  @override
  String get parsedTypeAppStore => '应用';

  @override
  String get parsedTypeUnknown => '未知';

  @override
  String get symbologyQr => 'QR 码';

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
  String get symbologyUnknown => '未知格式';

  @override
  String get errorStorageUnavailable => '应用无法打开自己的存储，请关闭后重新打开。';

  @override
  String get errorSaveFailed => '没有保存任何内容，请重试。';

  @override
  String get actionRetry => '重试';

  @override
  String get copiedWhatPassword => '密码';

  @override
  String get resultHandOffFailed => '无法打开，请重试。';

  @override
  String get resultUnavailableWifiSettings => '本机上无法打开 Wi-Fi 设置。';

  @override
  String get resultUnavailableContacts => '未安装联系人应用。';

  @override
  String get resultUnavailableCalendar => '未安装日历应用。';

  @override
  String get resultUnavailableDialer => '未安装电话应用。';

  @override
  String get resultUnavailableSms => '未安装短信应用。';

  @override
  String get resultUnavailableEmail => '未安装电子邮件应用。';

  @override
  String get resultUnavailableBrowser => '未安装浏览器。';

  @override
  String get resultLinkOpenButton => '打开';

  @override
  String get resultLinkReviewButton => '查看';

  @override
  String get resultLinkWarningTitle => '打开这个链接之前';

  @override
  String get resultLinkCheckIpAddressHost => '地址是一串 IP 数字，不是名称';

  @override
  String get resultLinkCheckUserinfo => '网站名前面带有用户名';

  @override
  String get resultLinkCheckInsecureScheme => '没有加密（http）';

  @override
  String get resultLinkCheckNonDefaultPort => '使用了不常见的端口';

  @override
  String get resultLinkCheckLongUrl => '网址异常长';

  @override
  String get resultLinkCopyWithoutOpeningButton => '只复制不打开';

  @override
  String get resultLinkOpenAnywayButton => '仍然打开';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '这里无法打开 $scheme 链接。';
  }

  @override
  String get resultLinkCalloutMessage => '本应用会在打开前检查链接，让你先看清它通向哪里。';

  @override
  String get resultLinkCalloutDismissTooltip => '关闭';

  @override
  String get resultWifiNetworkNameLabel => '网络名称';

  @override
  String get resultWifiSecurityLabel => '加密方式';

  @override
  String get resultWifiPasswordLabel => '密码';

  @override
  String get resultWifiRevealPasswordTooltip => '显示密码';

  @override
  String get resultWifiHidePasswordTooltip => '隐藏密码';

  @override
  String get resultWifiWepNotice => 'Android 不允许应用连接 WEP 网络。';

  @override
  String get resultWifiPrimaryButton => '打开 Wi-Fi 设置';

  @override
  String get resultWifiCopyPasswordButton => '复制密码';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => '无加密';

  @override
  String get resultContactNameLabel => '姓名';

  @override
  String get resultContactPhoneLabel => '电话';

  @override
  String get resultContactEmailLabel => '邮箱';

  @override
  String get resultContactOrganisationLabel => '单位';

  @override
  String get resultContactPrimaryButton => '添加到联系人';

  @override
  String get resultEventTitleLabel => '标题';

  @override
  String get resultEventStartLabel => '开始';

  @override
  String get resultEventEndLabel => '结束';

  @override
  String get resultEventLocationLabel => '地点';

  @override
  String get resultEventNotesLabel => '备注';

  @override
  String get resultEventAllDayNotice => '全天日程。';

  @override
  String resultEventTimeUtc(String time) {
    return '$time UTC';
  }

  @override
  String resultEventTimeZoned(String time, String zone) {
    return '$time（$zone）';
  }

  @override
  String get resultUnavailableEventNoStart => '这个日程没有开始时间，无法添加。';

  @override
  String get resultEventPrimaryButton => '添加到日历';

  @override
  String get resultPhoneNumberLabel => '号码';

  @override
  String get resultPhonePrimaryButton => '拨打';

  @override
  String get resultSmsNumberLabel => '号码';

  @override
  String get resultSmsMessageLabel => '内容';

  @override
  String get resultSmsPrimaryButton => '发短信';

  @override
  String get resultEmailToLabel => '收件人';

  @override
  String get resultEmailSubjectLabel => '主题';

  @override
  String get resultEmailBodyLabel => '正文';

  @override
  String get resultEmailPrimaryButton => '发邮件';

  @override
  String get resultProductNumberLabel => '编号';

  @override
  String get resultProductFormatLabel => '格式';

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
  String get resultProductSearchButton => '在网上搜索';

  @override
  String get resultLocationLatitudeLabel => '纬度';

  @override
  String get resultLocationLongitudeLabel => '经度';

  @override
  String get resultLocationNameLabel => '名称';

  @override
  String get createSubtitle => '选择要创建的内容';

  @override
  String get createUrlFieldLabel => '网址';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return '这个码会打开 $url';
  }

  @override
  String get createTextFieldLabel => '文字';

  @override
  String get createTextFieldHint => '任何你想写进码里的内容';

  @override
  String get createWifiSsidLabel => '网络名称';

  @override
  String get createWifiSecurityLabel => '加密方式';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP（不安全）';

  @override
  String get createWifiPasswordLabel => '密码';

  @override
  String get createWifiHiddenLabel => '隐藏网络';

  @override
  String get createContactNameLabel => '姓名';

  @override
  String get createContactPhoneLabel => '电话（可选）';

  @override
  String get createContactEmailLabel => '邮箱（可选）';

  @override
  String get createContactOrganisationLabel => '单位（可选）';

  @override
  String get createPhoneFieldLabel => '电话号码';

  @override
  String get createEmailToLabel => '电子邮件地址';

  @override
  String get createEmailSubjectLabel => '主题（可选）';

  @override
  String get createEmailBodyLabel => '正文（可选）';

  @override
  String get createSmsNumberLabel => '电话号码';

  @override
  String get createSmsMessageLabel => '内容（可选）';

  @override
  String get createFieldErrorRequired => '这一项必须填写。';

  @override
  String get createFieldErrorInvalidUrl => '请输入以 http:// 或 https:// 开头的网址。';

  @override
  String get createFieldErrorInvalidEmail => '请输入有效的电子邮件地址。';

  @override
  String get createFieldErrorInvalidPhone => '请输入 3 到 15 位数字的电话号码。';

  @override
  String createCapacityMeterLabel(int percent) {
    return '已用容量 $percent%';
  }

  @override
  String get createCapacityOverLimit => '内容超出了 QR 码的容量，请缩短后继续。';

  @override
  String get createButtonLabel => '创建';

  @override
  String get createCheckingMessage => '正在检查这个码能否正常扫描';

  @override
  String get createContentLabel => '内容';

  @override
  String get createCodeImageLabel => '创建好的 QR 码';

  @override
  String get createCheckFailedRenderFailed => '无法创建这个码，请缩短内容后重试。';

  @override
  String get createCheckFailedDecodeFailed => '无法检查这个码，保存和分享已关闭。';

  @override
  String get createCheckFailedMismatch => '这个码与你输入的内容不一致，保存和分享已关闭。';

  @override
  String get createNotSavedToHistory => '这个码未能保存到历史。';

  @override
  String get createSaveButton => '保存';

  @override
  String get createShareButton => '分享';

  @override
  String get createSavedSnackbarNoName => '码已保存';

  @override
  String createSavedSnackbar(String name) {
    return '已保存为 $name';
  }

  @override
  String get createShareFailed => '无法打开分享，请重试。';
}
