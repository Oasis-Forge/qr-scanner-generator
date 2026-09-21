// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Сканер';

  @override
  String get navCreate => 'Создать';

  @override
  String get navHistory => 'История';

  @override
  String get navSettings => 'Настройки';

  @override
  String get cameraPermissionReason =>
      'Камера используется только для чтения кодов на этом устройстве.';

  @override
  String get cameraAllowButton => 'Разрешить камеру';

  @override
  String get cameraOpenSettingsButton => 'Открыть настройки';

  @override
  String get scanFromPhotoButton => 'Сканировать фото';

  @override
  String get typeCodeButton => 'Ввести код';

  @override
  String get placeholderCreateMessage =>
      'Создание кодов появится в следующей тестовой сборке.';

  @override
  String get placeholderHistoryMessage =>
      'Список истории появится в следующей тестовой сборке. Ваши сканирования уже сохраняются на этом телефоне.';

  @override
  String get scanReadyStatus => 'Готово';

  @override
  String get scanTargetHint => 'Наведите камеру на код';

  @override
  String get scanCameraUnavailable =>
      'Не удалось запустить камеру. Возможно, её использует другое приложение.';

  @override
  String get scanTorchOn => 'Включить фонарик';

  @override
  String get scanTorchOff => 'Выключить фонарик';

  @override
  String get scanZoomLabel => 'Масштаб';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Чтение фото';

  @override
  String get scanPhotoPickerFailed =>
      'Не удалось открыть выбор фото. Попробуйте ещё раз.';

  @override
  String get scanSettingsDidNotOpen =>
      'Настройки не открылись. Разрешите камеру в настройках телефона.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'Обнаружено: $format, $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Обнаружено: $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Обнаружено $count кода',
      many: 'Обнаружено $count кодов',
      few: 'Обнаружено $count кода',
      one: 'Обнаружен $count код',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count кода',
      many: 'Найдено $count кодов',
      few: 'Найдено $count кода',
      one: 'Найден $count код',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Выберите код, который нужно открыть.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Двоичные данные, $count байта',
      many: 'Двоичные данные, $count байт',
      few: 'Двоичные данные, $count байта',
      one: 'Двоичные данные, $count байт',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Код не найден';

  @override
  String get noCodeFoundHint =>
      'Убедитесь, что код виден на фото целиком, чётко и при хорошем освещении.';

  @override
  String get tryAnotherPhotoButton => 'Выбрать другое фото';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get manualEntryTitle => 'Ввести код';

  @override
  String get manualEntryFieldLabel => 'Содержимое кода';

  @override
  String get manualEntryFieldHint => 'Ссылка, текст или номер штрихкода';

  @override
  String get manualEntryScanButton => 'Сканировать';

  @override
  String get settingsGroupGeneral => 'Общие';

  @override
  String get settingsGroupPrivacy => 'Конфиденциальность';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'О приложении';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSoundOnScan => 'Звук при сканировании';

  @override
  String get settingsVibrateOnScan => 'Вибрация при сканировании';

  @override
  String get settingsCopyOnScan => 'Копировать при сканировании';

  @override
  String get settingsSearchEngine => 'Поисковая система';

  @override
  String get settingsSaveHistory => 'Сохранять историю';

  @override
  String get settingsSendCrashReports => 'Отправлять отчёты о сбоях';

  @override
  String get settingsPrivacyOptions => 'Настройки конфиденциальности';

  @override
  String get settingsRemoveAds => 'Убрать рекламу';

  @override
  String get settingsRemoveAdsSubtitle => 'Разовая покупка';

  @override
  String get settingsRestorePurchase => 'Восстановить покупку';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Разовая покупка · $price';
  }

  @override
  String get settingsProOwned => 'Реклама убрана';

  @override
  String get proBuyFailed =>
      'Не удалось завершить покупку. Попробуйте ещё раз.';

  @override
  String get proRestoreSuccess => 'Покупка восстановлена.';

  @override
  String get proRestoreNotFound => 'Прежние покупки не найдены.';

  @override
  String get proRestoreFailed =>
      'Не удалось связаться с магазином. Попробуйте ещё раз.';

  @override
  String get proPromptTitle => 'Убрать рекламу?';

  @override
  String get proPromptBody => 'Разовая покупка, а не подписка.';

  @override
  String get proPromptDismissTooltip => 'Закрыть';

  @override
  String get settingsFeedback => 'Обратная связь';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsOpenSourceLicences => 'Лицензии открытого кода';

  @override
  String get settingsVersion => 'Версия';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Не удалось открыть ссылку.';

  @override
  String get feedbackCategoryLabel => 'Категория';

  @override
  String get feedbackCategoryScanning => 'Сканирование';

  @override
  String get feedbackCategoryResults => 'Результаты';

  @override
  String get feedbackCategoryCreatingCodes => 'Создание кодов';

  @override
  String get feedbackCategoryAds => 'Реклама';

  @override
  String get feedbackCategoryOther => 'Другое';

  @override
  String get feedbackMessageHint => 'Что произошло и чего вы ожидали?';

  @override
  String get feedbackSendButton => 'Отправить';

  @override
  String get feedbackSendNoHandler =>
      'На этом устройстве не настроено почтовое приложение.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle — отзыв ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get historyHeaderToday => 'Сегодня';

  @override
  String get historyHeaderYesterday => 'Вчера';

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
      other: '$count кода',
      many: '$count кодов',
      few: '$count кода',
      one: '$count код',
      zero: 'Нет кодов',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Все';

  @override
  String get historySegmentScanned => 'Сканы';

  @override
  String get historySegmentCreated => 'Созданные';

  @override
  String get historyEmptyMessage =>
      'Здесь появятся коды, которые вы отсканируете или создадите.';

  @override
  String get historyEmptyScanButton => 'Сканировать код';

  @override
  String get historyEmptyCreateButton => 'Создать код';

  @override
  String get historyEmptyNotSavingMessage =>
      'Новые сканирования не сохраняются.';

  @override
  String get historyEmptySettingsButton => 'Перейти в настройки';

  @override
  String get historyLoading => 'Загрузка истории';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count элемента',
      many: 'Удалено $count элементов',
      few: 'Удалено $count элемента',
      one: 'Удалён $count элемент',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Отменить';

  @override
  String get historyDeleteFailed => 'Не удалось удалить. Попробуйте ещё раз.';

  @override
  String get historyUndoFailed => 'Не удалось отменить. Попробуйте ещё раз.';

  @override
  String get historyLoadFailed =>
      'Не удалось загрузить историю. Попробуйте ещё раз.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Удалить';

  @override
  String get historyCancelSelectionButton => 'Отменить выбор';

  @override
  String copiedSnackbar(String what) {
    return 'Скопировано: $what';
  }

  @override
  String get copiedWhatLink => 'ссылка';

  @override
  String get copiedWhatContent => 'содержимое';

  @override
  String get resultTitle => 'Результат';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Копировать';

  @override
  String get resultShareButton => 'Поделиться';

  @override
  String get resultNotSaved =>
      'Это сканирование не удалось сохранить в историю.';

  @override
  String get resultCopyFailed => 'Не удалось скопировать. Попробуйте ещё раз.';

  @override
  String get resultShareFailed =>
      'Не удалось открыть меню «Поделиться». Попробуйте ещё раз.';

  @override
  String get parsedTypeUrl => 'Ссылка';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Текст';

  @override
  String get parsedTypeContact => 'Контакт';

  @override
  String get parsedTypePhone => 'Номер телефона';

  @override
  String get parsedTypeEmail => 'Эл. почта';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Местоположение';

  @override
  String get parsedTypeEvent => 'Событие';

  @override
  String get parsedTypeProduct => 'Товар';

  @override
  String get parsedTypeAppStore => 'Приложение';

  @override
  String get parsedTypeUnknown => 'Неизвестно';

  @override
  String get symbologyQr => 'QR-код';

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
  String get symbologyUnknown => 'Неизвестный формат';

  @override
  String get errorStorageUnavailable =>
      'Приложение не может открыть своё хранилище. Закройте его и откройте снова.';

  @override
  String get errorSaveFailed => 'Ничего не сохранено. Попробуйте ещё раз.';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get copiedWhatPassword => 'пароль';

  @override
  String get resultHandOffFailed => 'Не удалось открыть. Попробуйте ещё раз.';

  @override
  String get resultUnavailableWifiSettings =>
      'Настройки Wi-Fi нельзя открыть на этом устройстве.';

  @override
  String get resultUnavailableContacts =>
      'Приложение «Контакты» не установлено.';

  @override
  String get resultUnavailableCalendar =>
      'Приложение «Календарь» не установлено.';

  @override
  String get resultUnavailableDialer =>
      'Приложение для звонков не установлено.';

  @override
  String get resultUnavailableSms => 'Приложение для сообщений не установлено.';

  @override
  String get resultUnavailableEmail => 'Почтовое приложение не установлено.';

  @override
  String get resultUnavailableBrowser => 'Браузер не установлен.';

  @override
  String get resultLinkOpenButton => 'Открыть';

  @override
  String get resultLinkReviewButton => 'Подробнее';

  @override
  String get resultLinkWarningTitle => 'Прежде чем открыть эту ссылку';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Адрес указан числовым IP, а не именем';

  @override
  String get resultLinkCheckUserinfo =>
      'В ней есть имя пользователя перед именем сайта';

  @override
  String get resultLinkCheckInsecureScheme => 'Она без шифрования (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Она использует необычный порт';

  @override
  String get resultLinkCheckLongUrl => 'Она необычно длинная';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Копировать, не открывая';

  @override
  String get resultLinkOpenAnywayButton => 'Всё равно открыть';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Ссылки $scheme здесь открыть нельзя.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Приложение проверяет ссылки перед открытием, чтобы вы сначала видели, куда они ведут.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Закрыть';

  @override
  String get resultWifiNetworkNameLabel => 'Имя сети';

  @override
  String get resultWifiSecurityLabel => 'Защита';

  @override
  String get resultWifiPasswordLabel => 'Пароль';

  @override
  String get resultWifiRevealPasswordTooltip => 'Показать пароль';

  @override
  String get resultWifiHidePasswordTooltip => 'Скрыть пароль';

  @override
  String get resultWifiWepNotice =>
      'Android не может подключаться к сетям WEP из приложений.';

  @override
  String get resultWifiPrimaryButton => 'Открыть настройки Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Копировать пароль';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Открытая';

  @override
  String get resultContactNameLabel => 'Имя';

  @override
  String get resultContactPhoneLabel => 'Телефон';

  @override
  String get resultContactEmailLabel => 'Эл. почта';

  @override
  String get resultContactOrganisationLabel => 'Организация';

  @override
  String get resultContactPrimaryButton => 'Добавить в контакты';

  @override
  String get resultEventTitleLabel => 'Название';

  @override
  String get resultEventStartLabel => 'Начало';

  @override
  String get resultEventEndLabel => 'Окончание';

  @override
  String get resultEventLocationLabel => 'Место';

  @override
  String get resultEventNotesLabel => 'Заметки';

  @override
  String get resultEventAllDayNotice => 'Событие на весь день.';

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
      'У события нет времени начала, поэтому его нельзя добавить.';

  @override
  String get resultEventPrimaryButton => 'Добавить в календарь';

  @override
  String get resultPhoneNumberLabel => 'Номер';

  @override
  String get resultPhonePrimaryButton => 'Позвонить';

  @override
  String get resultSmsNumberLabel => 'Номер';

  @override
  String get resultSmsMessageLabel => 'Сообщение';

  @override
  String get resultSmsPrimaryButton => 'Написать';

  @override
  String get resultEmailToLabel => 'Кому';

  @override
  String get resultEmailSubjectLabel => 'Тема';

  @override
  String get resultEmailBodyLabel => 'Сообщение';

  @override
  String get resultEmailPrimaryButton => 'Написать письмо';

  @override
  String get resultProductNumberLabel => 'Номер';

  @override
  String get resultProductFormatLabel => 'Формат';

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
  String get resultProductSearchButton => 'Искать в интернете';

  @override
  String get resultLocationLatitudeLabel => 'Широта';

  @override
  String get resultLocationLongitudeLabel => 'Долгота';

  @override
  String get resultLocationNameLabel => 'Название';

  @override
  String get createSubtitle => 'Выберите, что создать';

  @override
  String get createUrlFieldLabel => 'Веб-адрес';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Код открывает $url';
  }

  @override
  String get createTextFieldLabel => 'Текст';

  @override
  String get createTextFieldHint => 'Всё, что должен содержать код';

  @override
  String get createWifiSsidLabel => 'Имя сети';

  @override
  String get createWifiSecurityLabel => 'Защита';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (небезопасно)';

  @override
  String get createWifiPasswordLabel => 'Пароль';

  @override
  String get createWifiHiddenLabel => 'Скрытая сеть';

  @override
  String get createContactNameLabel => 'Имя';

  @override
  String get createContactPhoneLabel => 'Телефон (необязательно)';

  @override
  String get createContactEmailLabel => 'Эл. почта (необязательно)';

  @override
  String get createContactOrganisationLabel => 'Организация (необязательно)';

  @override
  String get createPhoneFieldLabel => 'Номер телефона';

  @override
  String get createEmailToLabel => 'Адрес эл. почты';

  @override
  String get createEmailSubjectLabel => 'Тема (необязательно)';

  @override
  String get createEmailBodyLabel => 'Сообщение (необязательно)';

  @override
  String get createSmsNumberLabel => 'Номер телефона';

  @override
  String get createSmsMessageLabel => 'Сообщение (необязательно)';

  @override
  String get createFieldErrorRequired => 'Это поле обязательно.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Введите веб-адрес, начинающийся с http:// или https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Введите корректный адрес эл. почты.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Введите номер телефона из 3–15 цифр.';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'Использовано $percent% ёмкости';
  }

  @override
  String get createCapacityOverLimit =>
      'Слишком много содержимого для QR-кода. Сократите его, чтобы продолжить.';

  @override
  String get createButtonLabel => 'Создать';

  @override
  String get createCheckingMessage => 'Проверяем, что код сканируется';

  @override
  String get createContentLabel => 'Содержимое';

  @override
  String get createCodeImageLabel => 'Созданный QR-код';

  @override
  String get createCheckFailedRenderFailed =>
      'Не удалось создать код. Сократите содержимое и попробуйте ещё раз.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Этот код не удалось проверить. Кнопки «Сохранить» и «Поделиться» отключены.';

  @override
  String get createCheckFailedMismatch =>
      'Этот код не совпал с тем, что вы ввели. Кнопки «Сохранить» и «Поделиться» отключены.';

  @override
  String get createNotSavedToHistory =>
      'Этот код не удалось сохранить в историю.';

  @override
  String get createSaveButton => 'Сохранить';

  @override
  String get createShareButton => 'Поделиться';

  @override
  String get createSavedSnackbarNoName => 'Код сохранён';

  @override
  String createSavedSnackbar(String name) {
    return 'Сохранено как $name';
  }

  @override
  String get createShareFailed =>
      'Не удалось открыть меню «Поделиться». Попробуйте ещё раз.';
}
