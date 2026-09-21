// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'スキャン';

  @override
  String get navCreate => '作成';

  @override
  String get navHistory => '履歴';

  @override
  String get navSettings => '設定';

  @override
  String get cameraPermissionReason => 'カメラはこの端末でコードを読み取るためだけに使います。';

  @override
  String get cameraAllowButton => 'カメラを許可';

  @override
  String get cameraOpenSettingsButton => '設定を開く';

  @override
  String get scanFromPhotoButton => '写真をスキャン';

  @override
  String get typeCodeButton => 'コードを入力';

  @override
  String get placeholderCreateMessage => 'コードの作成は次のテストビルドで追加されます。';

  @override
  String get placeholderHistoryMessage =>
      '履歴の一覧は次のテストビルドで追加されます。スキャンした内容はすでにこの端末に保存されています。';

  @override
  String get scanReadyStatus => '準備完了';

  @override
  String get scanTargetHint => 'コードにカメラを向けてください';

  @override
  String get scanCameraUnavailable => 'カメラを起動できませんでした。他のアプリが使用している可能性があります。';

  @override
  String get scanTorchOn => 'ライトをつける';

  @override
  String get scanTorchOff => 'ライトを消す';

  @override
  String get scanZoomLabel => 'ズーム';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => '写真を読み取っています';

  @override
  String get scanPhotoPickerFailed => '写真の選択画面が開きませんでした。もう一度お試しください。';

  @override
  String get scanSettingsDidNotOpen => '設定が開きませんでした。端末の設定からカメラを許可してください。';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$formatを検出しました: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$typeを検出しました';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のコードを検出しました',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のコードが見つかりました',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => '開くコードを選んでください。';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'バイナリデータ、$countバイト',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'コードが見つかりません';

  @override
  String get noCodeFoundHint => 'コード全体が写真に収まり、ピントが合って明るく写っているか確認してください。';

  @override
  String get tryAnotherPhotoButton => '別の写真を試す';

  @override
  String get actionClose => '閉じる';

  @override
  String get manualEntryTitle => 'コードを入力';

  @override
  String get manualEntryFieldLabel => 'コードの内容';

  @override
  String get manualEntryFieldHint => 'リンク、テキスト、バーコード番号など';

  @override
  String get manualEntryScanButton => 'スキャン';

  @override
  String get settingsGroupGeneral => '一般';

  @override
  String get settingsGroupPrivacy => 'プライバシー';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'アプリについて';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsSoundOnScan => 'スキャン時に音を鳴らす';

  @override
  String get settingsVibrateOnScan => 'スキャン時に振動する';

  @override
  String get settingsCopyOnScan => 'スキャン時にコピーする';

  @override
  String get settingsSearchEngine => '検索エンジン';

  @override
  String get settingsSaveHistory => '履歴を保存';

  @override
  String get settingsSendCrashReports => 'クラッシュレポートを送信';

  @override
  String get settingsPrivacyOptions => 'プライバシー設定';

  @override
  String get settingsRemoveAds => '広告を非表示';

  @override
  String get settingsRemoveAdsSubtitle => '買い切り';

  @override
  String get settingsRestorePurchase => '購入を復元';

  @override
  String settingsRemoveAdsPrice(String price) {
    return '買い切り · $price';
  }

  @override
  String get settingsProOwned => '広告は非表示です';

  @override
  String get proBuyFailed => '購入を完了できませんでした。もう一度お試しください。';

  @override
  String get proRestoreSuccess => '購入を復元しました。';

  @override
  String get proRestoreNotFound => '以前の購入は見つかりませんでした。';

  @override
  String get proRestoreFailed => 'ストアを確認できませんでした。もう一度お試しください。';

  @override
  String get proPromptTitle => '広告を非表示にしますか';

  @override
  String get proPromptBody => '買い切りで、定期購入ではありません。';

  @override
  String get proPromptDismissTooltip => '閉じる';

  @override
  String get settingsFeedback => 'フィードバック';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsOpenSourceLicences => 'オープンソースライセンス';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'リンクを開けませんでした。';

  @override
  String get feedbackCategoryLabel => 'カテゴリ';

  @override
  String get feedbackCategoryScanning => 'スキャン';

  @override
  String get feedbackCategoryResults => '結果';

  @override
  String get feedbackCategoryCreatingCodes => 'コードの作成';

  @override
  String get feedbackCategoryAds => '広告';

  @override
  String get feedbackCategoryOther => 'その他';

  @override
  String get feedbackMessageHint => '何が起きて、どうなると思っていましたか';

  @override
  String get feedbackSendButton => '送信';

  @override
  String get feedbackSendNoHandler => 'この端末にメールアプリが設定されていません。';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle フィードバック ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'システムに合わせる';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get languageSystemDefault => 'システムに合わせる';

  @override
  String get historyHeaderToday => '今日';

  @override
  String get historyHeaderYesterday => '昨日';

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
      other: '$count件のコード',
      zero: 'コードなし',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'すべて';

  @override
  String get historySegmentScanned => 'スキャン';

  @override
  String get historySegmentCreated => '作成';

  @override
  String get historyEmptyMessage => 'スキャンまたは作成したコードがここに表示されます。';

  @override
  String get historyEmptyScanButton => 'コードをスキャン';

  @override
  String get historyEmptyCreateButton => 'コードを作成';

  @override
  String get historyEmptyNotSavingMessage => '新しいスキャンは保存されていません。';

  @override
  String get historyEmptySettingsButton => '設定を開く';

  @override
  String get historyLoading => '履歴を読み込んでいます';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件を削除しました',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => '元に戻す';

  @override
  String get historyDeleteFailed => '削除できませんでした。もう一度お試しください。';

  @override
  String get historyUndoFailed => '元に戻せませんでした。もう一度お試しください。';

  @override
  String get historyLoadFailed => '履歴を読み込めませんでした。もう一度お試しください。';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件を選択中',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => '削除';

  @override
  String get historyCancelSelectionButton => '選択を解除';

  @override
  String copiedSnackbar(String what) {
    return '$whatをコピーしました';
  }

  @override
  String get copiedWhatLink => 'リンク';

  @override
  String get copiedWhatContent => '内容';

  @override
  String get resultTitle => '結果';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'コピー';

  @override
  String get resultShareButton => '共有';

  @override
  String get resultNotSaved => 'このスキャンを履歴に保存できませんでした。';

  @override
  String get resultCopyFailed => 'コピーできませんでした。もう一度お試しください。';

  @override
  String get resultShareFailed => '共有を開けませんでした。もう一度お試しください。';

  @override
  String get parsedTypeUrl => 'リンク';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'テキスト';

  @override
  String get parsedTypeContact => '連絡先';

  @override
  String get parsedTypePhone => '電話番号';

  @override
  String get parsedTypeEmail => 'メール';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => '位置情報';

  @override
  String get parsedTypeEvent => '予定';

  @override
  String get parsedTypeProduct => '商品';

  @override
  String get parsedTypeAppStore => 'アプリ';

  @override
  String get parsedTypeUnknown => '不明';

  @override
  String get symbologyQr => 'QRコード';

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
  String get symbologyUnknown => '不明な形式';

  @override
  String get errorStorageUnavailable => 'アプリのデータを開けません。アプリを終了して、もう一度開いてください。';

  @override
  String get errorSaveFailed => '保存されませんでした。もう一度お試しください。';

  @override
  String get actionRetry => '再試行';

  @override
  String get copiedWhatPassword => 'パスワード';

  @override
  String get resultHandOffFailed => '開けませんでした。もう一度お試しください。';

  @override
  String get resultUnavailableWifiSettings => 'この端末ではWi-Fi設定を開けません。';

  @override
  String get resultUnavailableContacts => '連絡先アプリがインストールされていません。';

  @override
  String get resultUnavailableCalendar => 'カレンダーアプリがインストールされていません。';

  @override
  String get resultUnavailableDialer => '電話アプリがインストールされていません。';

  @override
  String get resultUnavailableSms => 'メッセージアプリがインストールされていません。';

  @override
  String get resultUnavailableEmail => 'メールアプリがインストールされていません。';

  @override
  String get resultUnavailableBrowser => 'ブラウザがインストールされていません。';

  @override
  String get resultLinkOpenButton => '開く';

  @override
  String get resultLinkReviewButton => '確認する';

  @override
  String get resultLinkWarningTitle => 'このリンクを開く前に';

  @override
  String get resultLinkCheckIpAddressHost => 'アドレスが名前ではなくIP番号です';

  @override
  String get resultLinkCheckUserinfo => 'サイト名の前にユーザー名が入っています';

  @override
  String get resultLinkCheckInsecureScheme => '暗号化されていません (http)';

  @override
  String get resultLinkCheckNonDefaultPort => '通常とは違うポートを使っています';

  @override
  String get resultLinkCheckLongUrl => '通常より長いアドレスです';

  @override
  String get resultLinkCopyWithoutOpeningButton => '開かずにコピー';

  @override
  String get resultLinkOpenAnywayButton => 'それでも開く';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$schemeのリンクはここでは開けません。';
  }

  @override
  String get resultLinkCalloutMessage =>
      'このアプリはリンクを開く前に調べるので、どこへつながるかを先に確認できます。';

  @override
  String get resultLinkCalloutDismissTooltip => '閉じる';

  @override
  String get resultWifiNetworkNameLabel => 'ネットワーク名';

  @override
  String get resultWifiSecurityLabel => 'セキュリティ';

  @override
  String get resultWifiPasswordLabel => 'パスワード';

  @override
  String get resultWifiRevealPasswordTooltip => 'パスワードを表示';

  @override
  String get resultWifiHidePasswordTooltip => 'パスワードを非表示';

  @override
  String get resultWifiWepNotice => 'AndroidではアプリからWEPネットワークに接続できません。';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi設定を開く';

  @override
  String get resultWifiCopyPasswordButton => 'パスワードをコピー';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'オープン';

  @override
  String get resultContactNameLabel => '名前';

  @override
  String get resultContactPhoneLabel => '電話';

  @override
  String get resultContactEmailLabel => 'メール';

  @override
  String get resultContactOrganisationLabel => '組織';

  @override
  String get resultContactPrimaryButton => '連絡先に追加';

  @override
  String get resultEventTitleLabel => 'タイトル';

  @override
  String get resultEventStartLabel => '開始';

  @override
  String get resultEventEndLabel => '終了';

  @override
  String get resultEventLocationLabel => '場所';

  @override
  String get resultEventNotesLabel => 'メモ';

  @override
  String get resultEventAllDayNotice => '終日の予定です。';

  @override
  String resultEventTimeUtc(String time) {
    return '$time UTC';
  }

  @override
  String resultEventTimeZoned(String time, String zone) {
    return '$time ($zone)';
  }

  @override
  String get resultUnavailableEventNoStart => 'この予定には開始時刻がないため、追加できません。';

  @override
  String get resultEventPrimaryButton => 'カレンダーに追加';

  @override
  String get resultPhoneNumberLabel => '番号';

  @override
  String get resultPhonePrimaryButton => '発信';

  @override
  String get resultSmsNumberLabel => '番号';

  @override
  String get resultSmsMessageLabel => 'メッセージ';

  @override
  String get resultSmsPrimaryButton => 'メッセージを送る';

  @override
  String get resultEmailToLabel => '宛先';

  @override
  String get resultEmailSubjectLabel => '件名';

  @override
  String get resultEmailBodyLabel => '本文';

  @override
  String get resultEmailPrimaryButton => 'メールを送る';

  @override
  String get resultProductNumberLabel => '番号';

  @override
  String get resultProductFormatLabel => '形式';

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
  String get resultProductSearchButton => 'ウェブで検索';

  @override
  String get resultLocationLatitudeLabel => '緯度';

  @override
  String get resultLocationLongitudeLabel => '経度';

  @override
  String get resultLocationNameLabel => '名前';

  @override
  String get createSubtitle => '作成するものを選んでください';

  @override
  String get createUrlFieldLabel => 'ウェブアドレス';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'このコードは$urlを開きます';
  }

  @override
  String get createTextFieldLabel => 'テキスト';

  @override
  String get createTextFieldHint => 'コードに入れたい内容';

  @override
  String get createWifiSsidLabel => 'ネットワーク名';

  @override
  String get createWifiSecurityLabel => 'セキュリティ';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (安全ではない)';

  @override
  String get createWifiPasswordLabel => 'パスワード';

  @override
  String get createWifiHiddenLabel => '非公開ネットワーク';

  @override
  String get createContactNameLabel => '名前';

  @override
  String get createContactPhoneLabel => '電話 (任意)';

  @override
  String get createContactEmailLabel => 'メール (任意)';

  @override
  String get createContactOrganisationLabel => '組織 (任意)';

  @override
  String get createPhoneFieldLabel => '電話番号';

  @override
  String get createEmailToLabel => 'メールアドレス';

  @override
  String get createEmailSubjectLabel => '件名 (任意)';

  @override
  String get createEmailBodyLabel => '本文 (任意)';

  @override
  String get createSmsNumberLabel => '電話番号';

  @override
  String get createSmsMessageLabel => 'メッセージ (任意)';

  @override
  String get createFieldErrorRequired => 'この項目は必須です。';

  @override
  String get createFieldErrorInvalidUrl =>
      'http:// または https:// で始まるウェブアドレスを入力してください。';

  @override
  String get createFieldErrorInvalidEmail => '正しいメールアドレスを入力してください。';

  @override
  String get createFieldErrorInvalidPhone => '3〜15桁の電話番号を入力してください。';

  @override
  String createCapacityMeterLabel(int percent) {
    return '容量の$percent%を使用';
  }

  @override
  String get createCapacityOverLimit => 'QRコードに入れるには内容が多すぎます。短くすると続けられます。';

  @override
  String get createButtonLabel => '作成';

  @override
  String get createCheckingMessage => 'コードが正しく読み取れるか確認しています';

  @override
  String get createContentLabel => '内容';

  @override
  String get createCodeImageLabel => '作成したQRコード';

  @override
  String get createCheckFailedRenderFailed =>
      'コードを作成できませんでした。内容を短くして、もう一度お試しください。';

  @override
  String get createCheckFailedDecodeFailed => 'このコードは確認できませんでした。保存と共有は使えません。';

  @override
  String get createCheckFailedMismatch => 'このコードは入力した内容と一致しませんでした。保存と共有は使えません。';

  @override
  String get createNotSavedToHistory => 'このコードを履歴に保存できませんでした。';

  @override
  String get createSaveButton => '保存';

  @override
  String get createShareButton => '共有';

  @override
  String get createSavedSnackbarNoName => 'コードを保存しました';

  @override
  String createSavedSnackbar(String name) {
    return '$nameとして保存しました';
  }

  @override
  String get createShareFailed => '共有を開けませんでした。もう一度お試しください。';
}
