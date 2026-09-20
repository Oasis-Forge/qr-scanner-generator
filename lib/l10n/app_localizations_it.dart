// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Scansiona';

  @override
  String get navCreate => 'Crea';

  @override
  String get navHistory => 'Cronologia';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get cameraPermissionReason =>
      'La fotocamera serve solo a leggere i codici su questo dispositivo.';

  @override
  String get cameraAllowButton => 'Consenti fotocamera';

  @override
  String get cameraOpenSettingsButton => 'Apri impostazioni';

  @override
  String get scanFromPhotoButton => 'Scansiona una foto';

  @override
  String get typeCodeButton => 'Digita un codice';

  @override
  String get placeholderCreateMessage =>
      'La creazione dei codici arriva nella prossima build di prova.';

  @override
  String get placeholderHistoryMessage =>
      'L\'elenco Cronologia arriva nella prossima build di prova. Le tue scansioni sono già conservate su questo telefono.';

  @override
  String get scanReadyStatus => 'Pronto';

  @override
  String get scanTargetHint => 'Inquadra un codice con la fotocamera';

  @override
  String get scanCameraUnavailable =>
      'Non è stato possibile avviare la fotocamera. Forse un\'altra app la sta usando.';

  @override
  String get scanTorchOn => 'Accendi la torcia';

  @override
  String get scanTorchOff => 'Spegni la torcia';

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
  String get scanReadingPhoto => 'Lettura della foto';

  @override
  String get scanPhotoPickerFailed =>
      'Il selettore di foto non si è aperto. Riprova.';

  @override
  String get scanSettingsDidNotOpen =>
      'Le impostazioni non si sono aperte. Consenti la fotocamera dalle impostazioni del telefono.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format rilevato: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Rilevato: $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codici rilevati',
      one: '1 codice rilevato',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codici trovati',
      one: '1 codice trovato',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Scegli il codice da aprire.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dati binari, $count byte',
      one: 'Dati binari, 1 byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Nessun codice trovato';

  @override
  String get noCodeFoundHint =>
      'Assicurati che il codice sia tutto nella foto, nitido e ben illuminato.';

  @override
  String get tryAnotherPhotoButton => 'Prova un\'altra foto';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get manualEntryTitle => 'Digita un codice';

  @override
  String get manualEntryFieldLabel => 'Contenuto del codice';

  @override
  String get manualEntryFieldHint =>
      'Un link, del testo o il numero di un codice a barre';

  @override
  String get manualEntryScanButton => 'Scansiona';

  @override
  String get settingsGroupGeneral => 'Generali';

  @override
  String get settingsGroupPrivacy => 'Privacy';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Informazioni';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsSoundOnScan => 'Suono alla scansione';

  @override
  String get settingsVibrateOnScan => 'Vibrazione alla scansione';

  @override
  String get settingsCopyOnScan => 'Copia alla scansione';

  @override
  String get settingsSearchEngine => 'Motore di ricerca';

  @override
  String get settingsSaveHistory => 'Salva la Cronologia';

  @override
  String get settingsSendCrashReports => 'Invia report di arresto';

  @override
  String get settingsPrivacyOptions => 'Opzioni privacy';

  @override
  String get settingsRemoveAds => 'Rimuovi annunci';

  @override
  String get settingsRemoveAdsSubtitle => 'Acquisto una tantum';

  @override
  String get settingsRestorePurchase => 'Ripristina acquisto';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Acquisto una tantum · $price';
  }

  @override
  String get settingsProOwned => 'Annunci rimossi';

  @override
  String get proBuyFailed =>
      'Non è stato possibile completare l\'acquisto. Riprova.';

  @override
  String get proRestoreSuccess => 'Acquisto ripristinato.';

  @override
  String get proRestoreNotFound => 'Nessun acquisto precedente trovato.';

  @override
  String get proRestoreFailed =>
      'Non è stato possibile contattare lo store. Riprova.';

  @override
  String get proPromptTitle => 'Rimuovere gli annunci?';

  @override
  String get proPromptBody => 'Un acquisto una tantum, mai un abbonamento.';

  @override
  String get proPromptDismissTooltip => 'Ignora';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get settingsOpenSourceLicences => 'Licenze open source';

  @override
  String get settingsVersion => 'Versione';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Non è stato possibile aprire il link.';

  @override
  String get feedbackCategoryLabel => 'Categoria';

  @override
  String get feedbackCategoryScanning => 'Scansione';

  @override
  String get feedbackCategoryResults => 'Risultati';

  @override
  String get feedbackCategoryCreatingCodes => 'Creazione di codici';

  @override
  String get feedbackCategoryAds => 'Annunci';

  @override
  String get feedbackCategoryOther => 'Altro';

  @override
  String get feedbackMessageHint =>
      'Che cosa è successo e che cosa ti aspettavi?';

  @override
  String get feedbackSendButton => 'Invia';

  @override
  String get feedbackSendNoHandler =>
      'Nessuna app di posta è configurata su questo dispositivo.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Feedback su $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Predefinito di sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get historyHeaderToday => 'Oggi';

  @override
  String get historyHeaderYesterday => 'Ieri';

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
      other: '$count codici',
      one: '1 codice',
      zero: 'Nessun codice',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Tutti';

  @override
  String get historySegmentScanned => 'Scansionati';

  @override
  String get historySegmentCreated => 'Creati';

  @override
  String get historyEmptyMessage =>
      'I codici che scansioni o crei compariranno qui.';

  @override
  String get historyEmptyScanButton => 'Scansiona un codice';

  @override
  String get historyEmptyCreateButton => 'Crea un codice';

  @override
  String get historyEmptyNotSavingMessage =>
      'Le nuove scansioni non vengono salvate.';

  @override
  String get historyEmptySettingsButton => 'Vai alle Impostazioni';

  @override
  String get historyLoading => 'Caricamento Cronologia';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi eliminati',
      one: '1 elemento eliminato',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Annulla';

  @override
  String get historyDeleteFailed => 'Non è stato possibile eliminare. Riprova.';

  @override
  String get historyUndoFailed => 'Non è stato possibile annullare. Riprova.';

  @override
  String get historyLoadFailed =>
      'Non è stato possibile caricare la Cronologia. Riprova.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '1 selezionato',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Elimina';

  @override
  String get historyCancelSelectionButton => 'Annulla selezione';

  @override
  String copiedSnackbar(String what) {
    return 'Copiato: $what';
  }

  @override
  String get copiedWhatLink => 'link';

  @override
  String get copiedWhatContent => 'contenuto';

  @override
  String get resultTitle => 'Risultato';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Copia';

  @override
  String get resultShareButton => 'Condividi';

  @override
  String get resultNotSaved =>
      'Non è stato possibile salvare questa scansione nella Cronologia.';

  @override
  String get resultCopyFailed => 'Non è stato possibile copiare. Riprova.';

  @override
  String get resultShareFailed =>
      'Non è stato possibile aprire la condivisione. Riprova.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Testo';

  @override
  String get parsedTypeContact => 'Contatto';

  @override
  String get parsedTypePhone => 'Numero di telefono';

  @override
  String get parsedTypeEmail => 'Email';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Posizione';

  @override
  String get parsedTypeEvent => 'Evento';

  @override
  String get parsedTypeProduct => 'Prodotto';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Sconosciuto';

  @override
  String get symbologyQr => 'Codice QR';

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
  String get symbologyUnknown => 'Formato sconosciuto';

  @override
  String get errorStorageUnavailable =>
      'L\'app non riesce ad aprire il suo archivio. Chiudila e riaprila.';

  @override
  String get errorSaveFailed => 'Non è stato salvato nulla. Riprova.';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get copiedWhatPassword => 'password';

  @override
  String get resultHandOffFailed => 'Non è stato possibile aprire. Riprova.';

  @override
  String get resultUnavailableWifiSettings =>
      'Le impostazioni Wi-Fi non si possono aprire su questo dispositivo.';

  @override
  String get resultUnavailableContacts => 'Nessuna app Contatti è installata.';

  @override
  String get resultUnavailableCalendar =>
      'Nessuna app Calendario è installata.';

  @override
  String get resultUnavailableDialer => 'Nessuna app Telefono è installata.';

  @override
  String get resultUnavailableSms => 'Nessuna app di messaggi è installata.';

  @override
  String get resultUnavailableEmail => 'Nessuna app di posta è installata.';

  @override
  String get resultUnavailableBrowser => 'Nessun browser è installato.';

  @override
  String get resultLinkOpenButton => 'Apri';

  @override
  String get resultLinkReviewButton => 'Controlla';

  @override
  String get resultLinkWarningTitle => 'Prima di aprire questo link';

  @override
  String get resultLinkCheckIpAddressHost =>
      'L\'indirizzo è un numero IP, non un nome';

  @override
  String get resultLinkCheckUserinfo =>
      'Contiene un nome utente prima del nome del sito';

  @override
  String get resultLinkCheckInsecureScheme => 'Non è cifrato (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Usa una porta insolita';

  @override
  String get resultLinkCheckLongUrl => 'È insolitamente lungo';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Copia senza aprire';

  @override
  String get resultLinkOpenAnywayButton => 'Apri comunque';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'I link $scheme non si possono aprire qui.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Questa app controlla i link prima di aprirli, così puoi vedere dove portano.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Ignora';

  @override
  String get resultWifiNetworkNameLabel => 'Nome rete';

  @override
  String get resultWifiSecurityLabel => 'Sicurezza';

  @override
  String get resultWifiPasswordLabel => 'Password';

  @override
  String get resultWifiRevealPasswordTooltip => 'Mostra password';

  @override
  String get resultWifiHidePasswordTooltip => 'Nascondi password';

  @override
  String get resultWifiWepNotice =>
      'Android non può connettersi alle reti WEP dalle app.';

  @override
  String get resultWifiPrimaryButton => 'Apri impostazioni Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Copia password';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Aperta';

  @override
  String get resultContactNameLabel => 'Nome';

  @override
  String get resultContactPhoneLabel => 'Telefono';

  @override
  String get resultContactEmailLabel => 'Email';

  @override
  String get resultContactOrganisationLabel => 'Organizzazione';

  @override
  String get resultContactPrimaryButton => 'Aggiungi ai contatti';

  @override
  String get resultEventTitleLabel => 'Titolo';

  @override
  String get resultEventStartLabel => 'Inizio';

  @override
  String get resultEventEndLabel => 'Fine';

  @override
  String get resultEventLocationLabel => 'Luogo';

  @override
  String get resultEventNotesLabel => 'Note';

  @override
  String get resultEventAllDayNotice => 'Evento per tutto il giorno.';

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
      'Questo evento non ha un\'ora di inizio, quindi non si può aggiungere.';

  @override
  String get resultEventPrimaryButton => 'Aggiungi al calendario';

  @override
  String get resultPhoneNumberLabel => 'Numero';

  @override
  String get resultPhonePrimaryButton => 'Chiama';

  @override
  String get resultSmsNumberLabel => 'Numero';

  @override
  String get resultSmsMessageLabel => 'Messaggio';

  @override
  String get resultSmsPrimaryButton => 'Invia SMS';

  @override
  String get resultEmailToLabel => 'A';

  @override
  String get resultEmailSubjectLabel => 'Oggetto';

  @override
  String get resultEmailBodyLabel => 'Messaggio';

  @override
  String get resultEmailPrimaryButton => 'Invia email';

  @override
  String get resultProductNumberLabel => 'Numero';

  @override
  String get resultProductFormatLabel => 'Formato';

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
  String get resultProductSearchButton => 'Cerca sul web';

  @override
  String get resultLocationLatitudeLabel => 'Latitudine';

  @override
  String get resultLocationLongitudeLabel => 'Longitudine';

  @override
  String get resultLocationNameLabel => 'Nome';

  @override
  String get createSubtitle => 'Scegli che cosa creare';

  @override
  String get createUrlFieldLabel => 'Indirizzo web';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Il codice apre $url';
  }

  @override
  String get createTextFieldLabel => 'Testo';

  @override
  String get createTextFieldHint =>
      'Qualsiasi cosa tu voglia che il codice dica';

  @override
  String get createWifiSsidLabel => 'Nome rete';

  @override
  String get createWifiSecurityLabel => 'Sicurezza';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (non sicuro)';

  @override
  String get createWifiPasswordLabel => 'Password';

  @override
  String get createWifiHiddenLabel => 'Rete nascosta';

  @override
  String get createContactNameLabel => 'Nome';

  @override
  String get createContactPhoneLabel => 'Telefono (facoltativo)';

  @override
  String get createContactEmailLabel => 'Email (facoltativa)';

  @override
  String get createContactOrganisationLabel => 'Organizzazione (facoltativa)';

  @override
  String get createPhoneFieldLabel => 'Numero di telefono';

  @override
  String get createEmailToLabel => 'Indirizzo email';

  @override
  String get createEmailSubjectLabel => 'Oggetto (facoltativo)';

  @override
  String get createEmailBodyLabel => 'Messaggio (facoltativo)';

  @override
  String get createSmsNumberLabel => 'Numero di telefono';

  @override
  String get createSmsMessageLabel => 'Messaggio (facoltativo)';

  @override
  String get createFieldErrorRequired => 'Questo campo è obbligatorio.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Inserisci un indirizzo web che inizi con http:// o https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Inserisci un indirizzo email valido.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Inserisci un numero di telefono da 3 a 15 cifre.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% della capacità usata';
  }

  @override
  String get createCapacityOverLimit =>
      'Il contenuto è troppo per un codice QR. Accorcialo per continuare.';

  @override
  String get createButtonLabel => 'Crea';

  @override
  String get createCheckingMessage =>
      'Verifica che il codice si scansioni correttamente';

  @override
  String get createContentLabel => 'Contenuto';

  @override
  String get createCodeImageLabel => 'Il codice QR creato';

  @override
  String get createCheckFailedRenderFailed =>
      'Non è stato possibile creare il codice. Accorcia il contenuto e riprova.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Non è stato possibile verificare questo codice. Salva e Condividi sono disattivati.';

  @override
  String get createCheckFailedMismatch =>
      'Questo codice non corrisponde a ciò che hai inserito. Salva e Condividi sono disattivati.';

  @override
  String get createNotSavedToHistory =>
      'Non è stato possibile salvare questo codice nella Cronologia.';

  @override
  String get createSaveButton => 'Salva';

  @override
  String get createShareButton => 'Condividi';

  @override
  String get createSavedSnackbarNoName => 'Codice salvato';

  @override
  String createSavedSnackbar(String name) {
    return 'Salvato come $name';
  }

  @override
  String get createShareFailed =>
      'Non è stato possibile aprire la condivisione. Riprova.';
}
