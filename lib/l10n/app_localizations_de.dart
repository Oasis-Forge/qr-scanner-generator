// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Scannen';

  @override
  String get navCreate => 'Erstellen';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cameraPermissionReason =>
      'Die Kamera wird nur verwendet, um Codes auf diesem Gerät zu lesen.';

  @override
  String get cameraAllowButton => 'Kamera erlauben';

  @override
  String get cameraOpenSettingsButton => 'Einstellungen öffnen';

  @override
  String get scanFromPhotoButton => 'Foto scannen';

  @override
  String get typeCodeButton => 'Code eingeben';

  @override
  String get placeholderCreateMessage =>
      'Das Erstellen von Codes kommt im nächsten Test-Build.';

  @override
  String get placeholderHistoryMessage =>
      'Die Verlaufsliste kommt im nächsten Test-Build. Ihre Scans werden bereits auf diesem Telefon gespeichert.';

  @override
  String get scanReadyStatus => 'Bereit';

  @override
  String get scanTargetHint => 'Kamera auf einen Code richten';

  @override
  String get scanCameraUnavailable =>
      'Die Kamera konnte nicht starten. Eine andere App verwendet sie möglicherweise.';

  @override
  String get scanTorchOn => 'Licht einschalten';

  @override
  String get scanTorchOff => 'Licht ausschalten';

  @override
  String get scanZoomLabel => 'Zoom';

  @override
  String scanZoomValue(double zoom) {
    final intl.NumberFormat zoomNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String zoomString = zoomNumberFormat.format(zoom);

    return '$zoomString×';
  }

  @override
  String get scanReadingPhoto => 'Foto wird gelesen';

  @override
  String get scanPhotoPickerFailed =>
      'Die Fotoauswahl wurde nicht geöffnet. Bitte erneut versuchen.';

  @override
  String get scanSettingsDidNotOpen =>
      'Die Einstellungen wurden nicht geöffnet. Erlauben Sie die Kamera in den Telefoneinstellungen.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format erkannt: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type erkannt';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Codes erkannt',
      one: '1 Code erkannt',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Codes gefunden',
      one: '1 Code gefunden',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Wählen Sie den Code zum Öffnen.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Binärdaten, $count Bytes',
      one: 'Binärdaten, 1 Byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Kein Code gefunden';

  @override
  String get noCodeFoundHint =>
      'Achten Sie darauf, dass der ganze Code scharf und gut beleuchtet im Foto ist.';

  @override
  String get tryAnotherPhotoButton => 'Anderes Foto versuchen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get manualEntryTitle => 'Code eingeben';

  @override
  String get manualEntryFieldLabel => 'Code-Inhalt';

  @override
  String get manualEntryFieldHint =>
      'Ein Link, ein Text oder eine Barcode-Nummer';

  @override
  String get manualEntryScanButton => 'Scannen';

  @override
  String get settingsGroupGeneral => 'Allgemein';

  @override
  String get settingsGroupPrivacy => 'Datenschutz';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Über';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSoundOnScan => 'Ton beim Scannen';

  @override
  String get settingsVibrateOnScan => 'Vibration beim Scannen';

  @override
  String get settingsCopyOnScan => 'Kopieren beim Scannen';

  @override
  String get settingsSearchEngine => 'Suchmaschine';

  @override
  String get settingsSaveHistory => 'Verlauf speichern';

  @override
  String get settingsSendCrashReports => 'Absturzberichte senden';

  @override
  String get settingsPrivacyOptions => 'Datenschutzoptionen';

  @override
  String get settingsRemoveAds => 'Werbung entfernen';

  @override
  String get settingsRemoveAdsSubtitle => 'Einmaliger Kauf';

  @override
  String get settingsRestorePurchase => 'Kauf wiederherstellen';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Einmaliger Kauf · $price';
  }

  @override
  String get settingsProOwned => 'Werbung entfernt';

  @override
  String get proBuyFailed =>
      'Der Kauf konnte nicht abgeschlossen werden. Bitte erneut versuchen.';

  @override
  String get proRestoreSuccess => 'Kauf wiederhergestellt.';

  @override
  String get proRestoreNotFound => 'Es wurde kein früherer Kauf gefunden.';

  @override
  String get proRestoreFailed =>
      'Der Store konnte nicht geprüft werden. Bitte erneut versuchen.';

  @override
  String get proPromptTitle => 'Werbung entfernen?';

  @override
  String get proPromptBody => 'Ein einmaliger Kauf, niemals ein Abo.';

  @override
  String get proPromptDismissTooltip => 'Ausblenden';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsOpenSourceLicences => 'Open-Source-Lizenzen';

  @override
  String get settingsVersion => 'Version';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get feedbackCategoryLabel => 'Kategorie';

  @override
  String get feedbackCategoryScanning => 'Scannen';

  @override
  String get feedbackCategoryResults => 'Ergebnisse';

  @override
  String get feedbackCategoryCreatingCodes => 'Codes erstellen';

  @override
  String get feedbackCategoryAds => 'Werbung';

  @override
  String get feedbackCategoryOther => 'Sonstiges';

  @override
  String get feedbackMessageHint =>
      'Was ist passiert, und was haben Sie erwartet?';

  @override
  String get feedbackSendButton => 'Senden';

  @override
  String get feedbackSendNoHandler =>
      'Auf diesem Gerät ist keine E-Mail-App eingerichtet.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle Feedback ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Systemstandard';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get historyHeaderToday => 'Heute';

  @override
  String get historyHeaderYesterday => 'Gestern';

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
      other: '$count Codes',
      one: '1 Code',
      zero: 'Keine Codes',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Alle';

  @override
  String get historySegmentScanned => 'Gescannt';

  @override
  String get historySegmentCreated => 'Erstellt';

  @override
  String get historyEmptyMessage =>
      'Codes, die Sie scannen oder erstellen, erscheinen hier.';

  @override
  String get historyEmptyScanButton => 'Code scannen';

  @override
  String get historyEmptyCreateButton => 'Code erstellen';

  @override
  String get historyEmptyNotSavingMessage =>
      'Neue Scans werden nicht gespeichert.';

  @override
  String get historyEmptySettingsButton => 'Zu den Einstellungen';

  @override
  String get historyLoading => 'Verlauf wird geladen';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge gelöscht',
      one: '1 Eintrag gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Rückgängig';

  @override
  String get historyDeleteFailed =>
      'Löschen nicht möglich. Bitte erneut versuchen.';

  @override
  String get historyUndoFailed =>
      'Rückgängig machen nicht möglich. Bitte erneut versuchen.';

  @override
  String get historyLoadFailed =>
      'Der Verlauf konnte nicht geladen werden. Bitte erneut versuchen.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Löschen';

  @override
  String get historyCancelSelectionButton => 'Auswahl aufheben';

  @override
  String copiedSnackbar(String what) {
    return '$what kopiert';
  }

  @override
  String get copiedWhatLink => 'Link';

  @override
  String get copiedWhatContent => 'Inhalt';

  @override
  String get resultTitle => 'Ergebnis';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Kopieren';

  @override
  String get resultShareButton => 'Teilen';

  @override
  String get resultNotSaved =>
      'Dieser Scan konnte nicht im Verlauf gespeichert werden.';

  @override
  String get resultCopyFailed =>
      'Kopieren nicht möglich. Bitte erneut versuchen.';

  @override
  String get resultShareFailed =>
      'Teilen konnte nicht geöffnet werden. Bitte erneut versuchen.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Text';

  @override
  String get parsedTypeContact => 'Kontakt';

  @override
  String get parsedTypePhone => 'Telefonnummer';

  @override
  String get parsedTypeEmail => 'E-Mail';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Standort';

  @override
  String get parsedTypeEvent => 'Termin';

  @override
  String get parsedTypeProduct => 'Produkt';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Unbekannt';

  @override
  String get symbologyQr => 'QR-Code';

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
  String get symbologyUnknown => 'Unbekanntes Format';

  @override
  String get errorStorageUnavailable =>
      'Die App kann ihren Speicher nicht öffnen. Schließen Sie die App und öffnen Sie sie erneut.';

  @override
  String get errorSaveFailed =>
      'Es wurde nichts gespeichert. Bitte erneut versuchen.';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get copiedWhatPassword => 'Passwort';

  @override
  String get resultHandOffFailed =>
      'Öffnen nicht möglich. Bitte erneut versuchen.';

  @override
  String get resultUnavailableWifiSettings =>
      'Die Wi-Fi-Einstellungen können auf diesem Gerät nicht geöffnet werden.';

  @override
  String get resultUnavailableContacts =>
      'Es ist keine Kontakte-App installiert.';

  @override
  String get resultUnavailableCalendar =>
      'Es ist keine Kalender-App installiert.';

  @override
  String get resultUnavailableDialer => 'Es ist keine Telefon-App installiert.';

  @override
  String get resultUnavailableSms =>
      'Es ist keine Nachrichten-App installiert.';

  @override
  String get resultUnavailableEmail => 'Es ist keine E-Mail-App installiert.';

  @override
  String get resultUnavailableBrowser => 'Es ist kein Browser installiert.';

  @override
  String get resultLinkOpenButton => 'Öffnen';

  @override
  String get resultLinkReviewButton => 'Prüfen';

  @override
  String get resultLinkWarningTitle => 'Bevor Sie diesen Link öffnen';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Die Adresse ist eine reine IP-Nummer, kein Name';

  @override
  String get resultLinkCheckUserinfo =>
      'Sie enthält einen Benutzernamen vor dem Seitennamen';

  @override
  String get resultLinkCheckInsecureScheme =>
      'Sie ist nicht verschlüsselt (http)';

  @override
  String get resultLinkCheckNonDefaultPort =>
      'Sie verwendet einen ungewöhnlichen Port';

  @override
  String get resultLinkCheckLongUrl => 'Sie ist ungewöhnlich lang';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Kopieren, ohne zu öffnen';

  @override
  String get resultLinkOpenAnywayButton => 'Trotzdem öffnen';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme-Links können hier nicht geöffnet werden.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Diese App prüft Links vor dem Öffnen, damit Sie zuerst sehen, wohin sie führen.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Ausblenden';

  @override
  String get resultWifiNetworkNameLabel => 'Netzwerkname';

  @override
  String get resultWifiSecurityLabel => 'Sicherheit';

  @override
  String get resultWifiPasswordLabel => 'Passwort';

  @override
  String get resultWifiRevealPasswordTooltip => 'Passwort anzeigen';

  @override
  String get resultWifiHidePasswordTooltip => 'Passwort verbergen';

  @override
  String get resultWifiWepNotice =>
      'Android kann WEP-Netzwerken nicht über Apps beitreten.';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi-Einstellungen öffnen';

  @override
  String get resultWifiCopyPasswordButton => 'Passwort kopieren';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Offen';

  @override
  String get resultContactNameLabel => 'Name';

  @override
  String get resultContactPhoneLabel => 'Telefon';

  @override
  String get resultContactEmailLabel => 'E-Mail';

  @override
  String get resultContactOrganisationLabel => 'Organisation';

  @override
  String get resultContactPrimaryButton => 'Zu Kontakten hinzufügen';

  @override
  String get resultEventTitleLabel => 'Titel';

  @override
  String get resultEventStartLabel => 'Beginn';

  @override
  String get resultEventEndLabel => 'Ende';

  @override
  String get resultEventLocationLabel => 'Ort';

  @override
  String get resultEventNotesLabel => 'Notizen';

  @override
  String get resultEventAllDayNotice => 'Ganztägiger Termin.';

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
      'Dieser Termin hat keine Startzeit und kann daher nicht hinzugefügt werden.';

  @override
  String get resultEventPrimaryButton => 'Zum Kalender hinzufügen';

  @override
  String get resultPhoneNumberLabel => 'Nummer';

  @override
  String get resultPhonePrimaryButton => 'Anrufen';

  @override
  String get resultSmsNumberLabel => 'Nummer';

  @override
  String get resultSmsMessageLabel => 'Nachricht';

  @override
  String get resultSmsPrimaryButton => 'Nachricht senden';

  @override
  String get resultEmailToLabel => 'An';

  @override
  String get resultEmailSubjectLabel => 'Betreff';

  @override
  String get resultEmailBodyLabel => 'Nachricht';

  @override
  String get resultEmailPrimaryButton => 'E-Mail senden';

  @override
  String get resultProductNumberLabel => 'Nummer';

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
  String get resultProductSearchButton => 'Im Web suchen';

  @override
  String get resultLocationLatitudeLabel => 'Breitengrad';

  @override
  String get resultLocationLongitudeLabel => 'Längengrad';

  @override
  String get resultLocationNameLabel => 'Name';

  @override
  String get createSubtitle => 'Wählen Sie, was erstellt werden soll';

  @override
  String get createUrlFieldLabel => 'Webadresse';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Der Code öffnet $url';
  }

  @override
  String get createTextFieldLabel => 'Text';

  @override
  String get createTextFieldHint => 'Beliebiger Text für den Code';

  @override
  String get createWifiSsidLabel => 'Netzwerkname';

  @override
  String get createWifiSecurityLabel => 'Sicherheit';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (unsicher)';

  @override
  String get createWifiPasswordLabel => 'Passwort';

  @override
  String get createWifiHiddenLabel => 'Verborgenes Netzwerk';

  @override
  String get createContactNameLabel => 'Name';

  @override
  String get createContactPhoneLabel => 'Telefon (optional)';

  @override
  String get createContactEmailLabel => 'E-Mail (optional)';

  @override
  String get createContactOrganisationLabel => 'Organisation (optional)';

  @override
  String get createPhoneFieldLabel => 'Telefonnummer';

  @override
  String get createEmailToLabel => 'E-Mail-Adresse';

  @override
  String get createEmailSubjectLabel => 'Betreff (optional)';

  @override
  String get createEmailBodyLabel => 'Nachricht (optional)';

  @override
  String get createSmsNumberLabel => 'Telefonnummer';

  @override
  String get createSmsMessageLabel => 'Nachricht (optional)';

  @override
  String get createFieldErrorRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Geben Sie eine Webadresse ein, die mit http:// oder https:// beginnt.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Geben Sie eine Telefonnummer mit 3 bis 15 Ziffern ein.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent % der Kapazität belegt';
  }

  @override
  String get createCapacityOverLimit =>
      'Das ist zu viel Inhalt für einen QR-Code. Kürzen Sie ihn, um fortzufahren.';

  @override
  String get createButtonLabel => 'Erstellen';

  @override
  String get createCheckingMessage => 'Der Code wird auf Scanbarkeit geprüft';

  @override
  String get createContentLabel => 'Inhalt';

  @override
  String get createCodeImageLabel => 'Der erstellte QR-Code';

  @override
  String get createCheckFailedRenderFailed =>
      'Der Code konnte nicht erstellt werden. Kürzen Sie den Inhalt und versuchen Sie es erneut.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Dieser Code konnte nicht geprüft werden. Speichern und Teilen sind deaktiviert.';

  @override
  String get createCheckFailedMismatch =>
      'Dieser Code stimmt nicht mit Ihrer Eingabe überein. Speichern und Teilen sind deaktiviert.';

  @override
  String get createNotSavedToHistory =>
      'Dieser Code konnte nicht im Verlauf gespeichert werden.';

  @override
  String get createSaveButton => 'Speichern';

  @override
  String get createShareButton => 'Teilen';

  @override
  String get createSavedSnackbarNoName => 'Code gespeichert';

  @override
  String createSavedSnackbar(String name) {
    return 'Als $name gespeichert';
  }

  @override
  String get createShareFailed =>
      'Teilen konnte nicht geöffnet werden. Bitte erneut versuchen.';
}
