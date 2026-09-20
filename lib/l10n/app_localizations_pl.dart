// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Skanuj';

  @override
  String get navCreate => 'Utwórz';

  @override
  String get navHistory => 'Historia';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get cameraPermissionReason =>
      'Aparat służy wyłącznie do odczytywania kodów na tym urządzeniu.';

  @override
  String get cameraAllowButton => 'Zezwól na aparat';

  @override
  String get cameraOpenSettingsButton => 'Otwórz ustawienia';

  @override
  String get scanFromPhotoButton => 'Skanuj zdjęcie';

  @override
  String get typeCodeButton => 'Wpisz kod';

  @override
  String get placeholderCreateMessage =>
      'Tworzenie kodów pojawi się w następnej wersji testowej.';

  @override
  String get placeholderHistoryMessage =>
      'Lista Historii pojawi się w następnej wersji testowej. Twoje skany są już zapisywane w tym telefonie.';

  @override
  String get scanReadyStatus => 'Gotowe';

  @override
  String get scanTargetHint => 'Skieruj aparat na kod';

  @override
  String get scanCameraUnavailable =>
      'Nie udało się uruchomić aparatu. Może go używać inna aplikacja.';

  @override
  String get scanTorchOn => 'Włącz latarkę';

  @override
  String get scanTorchOff => 'Wyłącz latarkę';

  @override
  String get scanZoomLabel => 'Powiększenie';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Odczytywanie zdjęcia';

  @override
  String get scanPhotoPickerFailed =>
      'Nie udało się otworzyć wyboru zdjęć. Spróbuj ponownie.';

  @override
  String get scanSettingsDidNotOpen =>
      'Ustawienia nie otworzyły się. Zezwól na aparat w ustawieniach telefonu.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'Wykryto $format: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Wykryto $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wykryto $count kodu',
      many: 'Wykryto $count kodów',
      few: 'Wykryto $count kody',
      one: 'Wykryto 1 kod',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count kodu',
      many: 'Znaleziono $count kodów',
      few: 'Znaleziono $count kody',
      one: 'Znaleziono 1 kod',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Wybierz kod do otwarcia.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dane binarne, $count bajta',
      many: 'Dane binarne, $count bajtów',
      few: 'Dane binarne, $count bajty',
      one: 'Dane binarne, 1 bajt',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Nie znaleziono kodu';

  @override
  String get noCodeFoundHint =>
      'Upewnij się, że cały kod jest na zdjęciu, ostry i dobrze oświetlony.';

  @override
  String get tryAnotherPhotoButton => 'Wybierz inne zdjęcie';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get manualEntryTitle => 'Wpisz kod';

  @override
  String get manualEntryFieldLabel => 'Treść kodu';

  @override
  String get manualEntryFieldHint => 'Link, tekst lub numer kodu kreskowego';

  @override
  String get manualEntryScanButton => 'Skanuj';

  @override
  String get settingsGroupGeneral => 'Ogólne';

  @override
  String get settingsGroupPrivacy => 'Prywatność';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Informacje';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsSoundOnScan => 'Dźwięk przy skanie';

  @override
  String get settingsVibrateOnScan => 'Wibracja przy skanie';

  @override
  String get settingsCopyOnScan => 'Kopiowanie przy skanie';

  @override
  String get settingsSearchEngine => 'Wyszukiwarka';

  @override
  String get settingsSaveHistory => 'Zapisuj historię';

  @override
  String get settingsSendCrashReports => 'Wysyłaj raporty o awariach';

  @override
  String get settingsPrivacyOptions => 'Opcje prywatności';

  @override
  String get settingsRemoveAds => 'Usuń reklamy';

  @override
  String get settingsRemoveAdsSubtitle => 'Zakup jednorazowy';

  @override
  String get settingsRestorePurchase => 'Przywróć zakup';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Zakup jednorazowy · $price';
  }

  @override
  String get settingsProOwned => 'Reklamy usunięte';

  @override
  String get proBuyFailed =>
      'Nie udało się dokończyć zakupu. Spróbuj ponownie.';

  @override
  String get proRestoreSuccess => 'Zakup przywrócony.';

  @override
  String get proRestoreNotFound => 'Nie znaleziono wcześniejszego zakupu.';

  @override
  String get proRestoreFailed =>
      'Nie udało się sprawdzić sklepu. Spróbuj ponownie.';

  @override
  String get proPromptTitle => 'Usunąć reklamy?';

  @override
  String get proPromptBody => 'Zakup jednorazowy, nigdy abonament.';

  @override
  String get proPromptDismissTooltip => 'Odrzuć';

  @override
  String get settingsFeedback => 'Opinia';

  @override
  String get settingsPrivacyPolicy => 'Polityka prywatności';

  @override
  String get settingsOpenSourceLicences => 'Licencje open source';

  @override
  String get settingsVersion => 'Wersja';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Nie udało się otworzyć linku.';

  @override
  String get feedbackCategoryLabel => 'Kategoria';

  @override
  String get feedbackCategoryScanning => 'Skanowanie';

  @override
  String get feedbackCategoryResults => 'Wyniki';

  @override
  String get feedbackCategoryCreatingCodes => 'Tworzenie kodów';

  @override
  String get feedbackCategoryAds => 'Reklamy';

  @override
  String get feedbackCategoryOther => 'Inne';

  @override
  String get feedbackMessageHint => 'Co się stało i co miało się stać?';

  @override
  String get feedbackSendButton => 'Wyślij';

  @override
  String get feedbackSendNoHandler =>
      'Na tym urządzeniu nie skonfigurowano aplikacji pocztowej.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle — opinia ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Domyślny systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get languageSystemDefault => 'Domyślny systemowy';

  @override
  String get historyHeaderToday => 'Dzisiaj';

  @override
  String get historyHeaderYesterday => 'Wczoraj';

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
      other: '$count kodu',
      many: '$count kodów',
      few: '$count kody',
      one: '1 kod',
      zero: 'Brak kodów',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Wszystkie';

  @override
  String get historySegmentScanned => 'Zeskanowane';

  @override
  String get historySegmentCreated => 'Utworzone';

  @override
  String get historyEmptyMessage =>
      'Kody, które zeskanujesz lub utworzysz, pojawią się tutaj.';

  @override
  String get historyEmptyScanButton => 'Skanuj kod';

  @override
  String get historyEmptyCreateButton => 'Utwórz kod';

  @override
  String get historyEmptyNotSavingMessage => 'Nowe skany nie są zapisywane.';

  @override
  String get historyEmptySettingsButton => 'Przejdź do Ustawień';

  @override
  String get historyLoading => 'Wczytywanie Historii';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunięto $count elementu',
      many: 'Usunięto $count elementów',
      few: 'Usunięto $count elementy',
      one: 'Usunięto 1 element',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Cofnij';

  @override
  String get historyDeleteFailed => 'Nie udało się usunąć. Spróbuj ponownie.';

  @override
  String get historyUndoFailed => 'Nie udało się cofnąć. Spróbuj ponownie.';

  @override
  String get historyLoadFailed =>
      'Nie udało się wczytać Historii. Spróbuj ponownie.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wybrano $count',
      many: 'Wybrano $count',
      few: 'Wybrano $count',
      one: 'Wybrano 1',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Usuń';

  @override
  String get historyCancelSelectionButton => 'Anuluj wybór';

  @override
  String copiedSnackbar(String what) {
    return 'Skopiowano $what';
  }

  @override
  String get copiedWhatLink => 'link';

  @override
  String get copiedWhatContent => 'treść';

  @override
  String get resultTitle => 'Wynik';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Kopiuj';

  @override
  String get resultShareButton => 'Udostępnij';

  @override
  String get resultNotSaved => 'Nie udało się zapisać tego skanu w Historii.';

  @override
  String get resultCopyFailed => 'Nie udało się skopiować. Spróbuj ponownie.';

  @override
  String get resultShareFailed =>
      'Nie udało się otworzyć udostępniania. Spróbuj ponownie.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Tekst';

  @override
  String get parsedTypeContact => 'Kontakt';

  @override
  String get parsedTypePhone => 'Numer telefonu';

  @override
  String get parsedTypeEmail => 'E-mail';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Lokalizacja';

  @override
  String get parsedTypeEvent => 'Wydarzenie';

  @override
  String get parsedTypeProduct => 'Produkt';

  @override
  String get parsedTypeAppStore => 'Aplikacja';

  @override
  String get parsedTypeUnknown => 'Nieznany';

  @override
  String get symbologyQr => 'Kod QR';

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
  String get symbologyUnknown => 'Nieznany format';

  @override
  String get errorStorageUnavailable =>
      'Aplikacja nie może otworzyć swojej pamięci. Zamknij ją i otwórz ponownie.';

  @override
  String get errorSaveFailed => 'Nic nie zostało zapisane. Spróbuj ponownie.';

  @override
  String get actionRetry => 'Ponów';

  @override
  String get copiedWhatPassword => 'hasło';

  @override
  String get resultHandOffFailed => 'Nie udało się otworzyć. Spróbuj ponownie.';

  @override
  String get resultUnavailableWifiSettings =>
      'Na tym urządzeniu nie można otworzyć ustawień Wi-Fi.';

  @override
  String get resultUnavailableContacts =>
      'Nie zainstalowano aplikacji Kontakty.';

  @override
  String get resultUnavailableCalendar =>
      'Nie zainstalowano aplikacji Kalendarz.';

  @override
  String get resultUnavailableDialer => 'Nie zainstalowano aplikacji Telefon.';

  @override
  String get resultUnavailableSms =>
      'Nie zainstalowano aplikacji do wiadomości.';

  @override
  String get resultUnavailableEmail => 'Nie zainstalowano aplikacji pocztowej.';

  @override
  String get resultUnavailableBrowser => 'Nie zainstalowano przeglądarki.';

  @override
  String get resultLinkOpenButton => 'Otwórz';

  @override
  String get resultLinkReviewButton => 'Sprawdź';

  @override
  String get resultLinkWarningTitle => 'Zanim otworzysz ten link';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Adres to surowy numer IP, a nie nazwa';

  @override
  String get resultLinkCheckUserinfo =>
      'Zawiera nazwę użytkownika przed nazwą witryny';

  @override
  String get resultLinkCheckInsecureScheme => 'Nie jest szyfrowany (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Używa nietypowego portu';

  @override
  String get resultLinkCheckLongUrl => 'Jest nietypowo długi';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Kopiuj bez otwierania';

  @override
  String get resultLinkOpenAnywayButton => 'Otwórz mimo to';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Linków $scheme nie można tutaj otworzyć.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Ta aplikacja sprawdza linki przed otwarciem, więc najpierw widzisz, dokąd prowadzą.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Odrzuć';

  @override
  String get resultWifiNetworkNameLabel => 'Nazwa sieci';

  @override
  String get resultWifiSecurityLabel => 'Zabezpieczenie';

  @override
  String get resultWifiPasswordLabel => 'Hasło';

  @override
  String get resultWifiRevealPasswordTooltip => 'Pokaż hasło';

  @override
  String get resultWifiHidePasswordTooltip => 'Ukryj hasło';

  @override
  String get resultWifiWepNotice =>
      'Android nie łączy się z sieciami WEP z poziomu aplikacji.';

  @override
  String get resultWifiPrimaryButton => 'Otwórz ustawienia Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Kopiuj hasło';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Otwarta';

  @override
  String get resultContactNameLabel => 'Imię i nazwisko';

  @override
  String get resultContactPhoneLabel => 'Telefon';

  @override
  String get resultContactEmailLabel => 'E-mail';

  @override
  String get resultContactOrganisationLabel => 'Organizacja';

  @override
  String get resultContactPrimaryButton => 'Dodaj do kontaktów';

  @override
  String get resultEventTitleLabel => 'Tytuł';

  @override
  String get resultEventStartLabel => 'Początek';

  @override
  String get resultEventEndLabel => 'Koniec';

  @override
  String get resultEventLocationLabel => 'Miejsce';

  @override
  String get resultEventNotesLabel => 'Notatki';

  @override
  String get resultEventAllDayNotice => 'Wydarzenie całodniowe.';

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
      'To wydarzenie nie ma godziny rozpoczęcia, więc nie można go dodać.';

  @override
  String get resultEventPrimaryButton => 'Dodaj do kalendarza';

  @override
  String get resultPhoneNumberLabel => 'Numer';

  @override
  String get resultPhonePrimaryButton => 'Zadzwoń';

  @override
  String get resultSmsNumberLabel => 'Numer';

  @override
  String get resultSmsMessageLabel => 'Wiadomość';

  @override
  String get resultSmsPrimaryButton => 'Wyślij SMS';

  @override
  String get resultEmailToLabel => 'Do';

  @override
  String get resultEmailSubjectLabel => 'Temat';

  @override
  String get resultEmailBodyLabel => 'Wiadomość';

  @override
  String get resultEmailPrimaryButton => 'Wyślij e-mail';

  @override
  String get resultProductNumberLabel => 'Numer';

  @override
  String get resultProductFormatLabel => 'Format';

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
  String get resultProductSearchButton => 'Szukaj w sieci';

  @override
  String get resultLocationLatitudeLabel => 'Szerokość';

  @override
  String get resultLocationLongitudeLabel => 'Długość';

  @override
  String get resultLocationNameLabel => 'Nazwa';

  @override
  String get createSubtitle => 'Wybierz, co utworzyć';

  @override
  String get createUrlFieldLabel => 'Adres internetowy';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Kod otwiera $url';
  }

  @override
  String get createTextFieldLabel => 'Tekst';

  @override
  String get createTextFieldHint => 'Dowolna treść, którą ma zawierać kod';

  @override
  String get createWifiSsidLabel => 'Nazwa sieci';

  @override
  String get createWifiSecurityLabel => 'Zabezpieczenie';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (niebezpieczne)';

  @override
  String get createWifiPasswordLabel => 'Hasło';

  @override
  String get createWifiHiddenLabel => 'Sieć ukryta';

  @override
  String get createContactNameLabel => 'Imię i nazwisko';

  @override
  String get createContactPhoneLabel => 'Telefon (opcjonalnie)';

  @override
  String get createContactEmailLabel => 'E-mail (opcjonalnie)';

  @override
  String get createContactOrganisationLabel => 'Organizacja (opcjonalnie)';

  @override
  String get createPhoneFieldLabel => 'Numer telefonu';

  @override
  String get createEmailToLabel => 'Adres e-mail';

  @override
  String get createEmailSubjectLabel => 'Temat (opcjonalnie)';

  @override
  String get createEmailBodyLabel => 'Wiadomość (opcjonalnie)';

  @override
  String get createSmsNumberLabel => 'Numer telefonu';

  @override
  String get createSmsMessageLabel => 'Wiadomość (opcjonalnie)';

  @override
  String get createFieldErrorRequired => 'To pole jest wymagane.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Wpisz adres internetowy zaczynający się od http:// lub https://.';

  @override
  String get createFieldErrorInvalidEmail => 'Wpisz prawidłowy adres e-mail.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Wpisz numer telefonu zawierający od 3 do 15 cyfr.';

  @override
  String createCapacityMeterLabel(int percent) {
    return 'Wykorzystano $percent% pojemności';
  }

  @override
  String get createCapacityOverLimit =>
      'To za dużo treści jak na kod QR. Skróć ją, aby kontynuować.';

  @override
  String get createButtonLabel => 'Utwórz';

  @override
  String get createCheckingMessage =>
      'Sprawdzanie, czy kod poprawnie się skanuje';

  @override
  String get createContentLabel => 'Treść';

  @override
  String get createCodeImageLabel => 'Utworzony kod QR';

  @override
  String get createCheckFailedRenderFailed =>
      'Nie udało się utworzyć kodu. Skróć treść i spróbuj ponownie.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Nie udało się sprawdzić tego kodu. Zapisywanie i udostępnianie są wyłączone.';

  @override
  String get createCheckFailedMismatch =>
      'Ten kod nie zgadza się z wpisaną treścią. Zapisywanie i udostępnianie są wyłączone.';

  @override
  String get createNotSavedToHistory =>
      'Nie udało się zapisać tego kodu w Historii.';

  @override
  String get createSaveButton => 'Zapisz';

  @override
  String get createShareButton => 'Udostępnij';

  @override
  String get createSavedSnackbarNoName => 'Kod zapisany';

  @override
  String createSavedSnackbar(String name) {
    return 'Zapisano jako $name';
  }

  @override
  String get createShareFailed =>
      'Nie udało się otworzyć udostępniania. Spróbuj ponownie.';
}
