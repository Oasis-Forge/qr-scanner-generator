// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Scannen';

  @override
  String get navCreate => 'Maken';

  @override
  String get navHistory => 'Geschiedenis';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get cameraPermissionReason =>
      'De camera wordt alleen gebruikt om codes op dit toestel te lezen.';

  @override
  String get cameraAllowButton => 'Camera toestaan';

  @override
  String get cameraOpenSettingsButton => 'Instellingen openen';

  @override
  String get scanFromPhotoButton => 'Foto scannen';

  @override
  String get typeCodeButton => 'Code typen';

  @override
  String get placeholderCreateMessage =>
      'Codes maken komt in de volgende testversie.';

  @override
  String get placeholderHistoryMessage =>
      'De lijst Geschiedenis komt in de volgende testversie. Je scans worden al op deze telefoon bewaard.';

  @override
  String get scanReadyStatus => 'Gereed';

  @override
  String get scanTargetHint => 'Richt de camera op een code';

  @override
  String get scanCameraUnavailable =>
      'De camera kon niet starten. Mogelijk gebruikt een andere app hem.';

  @override
  String get scanTorchOn => 'Zaklamp aanzetten';

  @override
  String get scanTorchOff => 'Zaklamp uitzetten';

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
  String get scanReadingPhoto => 'Foto wordt gelezen';

  @override
  String get scanPhotoPickerFailed =>
      'De fotokiezer ging niet open. Probeer het opnieuw.';

  @override
  String get scanSettingsDidNotOpen =>
      'Instellingen gingen niet open. Geef de camera toestemming via de instellingen van je telefoon.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format gedetecteerd: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type gedetecteerd';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes gedetecteerd',
      one: '1 code gedetecteerd',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes gevonden',
      one: '1 code gevonden',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Kies de code die je wilt openen.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Binaire gegevens, $count bytes',
      one: 'Binaire gegevens, 1 byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Geen code gevonden';

  @override
  String get noCodeFoundHint =>
      'Zorg dat de hele code op de foto staat, scherp en goed verlicht.';

  @override
  String get tryAnotherPhotoButton => 'Andere foto proberen';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get manualEntryTitle => 'Code typen';

  @override
  String get manualEntryFieldLabel => 'Inhoud van de code';

  @override
  String get manualEntryFieldHint => 'Een link, wat tekst of een barcodenummer';

  @override
  String get manualEntryScanButton => 'Scannen';

  @override
  String get settingsGroupGeneral => 'Algemeen';

  @override
  String get settingsGroupPrivacy => 'Privacy';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Over';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsSoundOnScan => 'Geluid bij scannen';

  @override
  String get settingsVibrateOnScan => 'Trillen bij scannen';

  @override
  String get settingsCopyOnScan => 'Kopiëren bij scannen';

  @override
  String get settingsSearchEngine => 'Zoekmachine';

  @override
  String get settingsSaveHistory => 'Geschiedenis opslaan';

  @override
  String get settingsSendCrashReports => 'Crashrapporten versturen';

  @override
  String get settingsPrivacyOptions => 'Privacyopties';

  @override
  String get settingsRemoveAds => 'Advertenties verwijderen';

  @override
  String get settingsRemoveAdsSubtitle => 'Eenmalige aankoop';

  @override
  String get settingsRestorePurchase => 'Aankoop herstellen';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Eenmalige aankoop · $price';
  }

  @override
  String get settingsProOwned => 'Advertenties verwijderd';

  @override
  String get proBuyFailed =>
      'De aankoop kon niet worden voltooid. Probeer het opnieuw.';

  @override
  String get proRestoreSuccess => 'Aankoop hersteld.';

  @override
  String get proRestoreNotFound => 'Er is geen eerdere aankoop gevonden.';

  @override
  String get proRestoreFailed =>
      'De store kon niet worden gecontroleerd. Probeer het opnieuw.';

  @override
  String get proPromptTitle => 'Advertenties verwijderen?';

  @override
  String get proPromptBody => 'Een eenmalige aankoop, nooit een abonnement.';

  @override
  String get proPromptDismissTooltip => 'Verbergen';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsPrivacyPolicy => 'Privacybeleid';

  @override
  String get settingsOpenSourceLicences => 'Open-sourcelicenties';

  @override
  String get settingsVersion => 'Versie';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'De link kon niet worden geopend.';

  @override
  String get feedbackCategoryLabel => 'Categorie';

  @override
  String get feedbackCategoryScanning => 'Scannen';

  @override
  String get feedbackCategoryResults => 'Resultaten';

  @override
  String get feedbackCategoryCreatingCodes => 'Codes maken';

  @override
  String get feedbackCategoryAds => 'Advertenties';

  @override
  String get feedbackCategoryOther => 'Overig';

  @override
  String get feedbackMessageHint => 'Wat gebeurde er, en wat verwachtte je?';

  @override
  String get feedbackSendButton => 'Versturen';

  @override
  String get feedbackSendNoHandler =>
      'Er is geen e-mailapp ingesteld op dit toestel.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return '$appTitle feedback ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Systeemstandaard';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get languageSystemDefault => 'Systeemstandaard';

  @override
  String get historyHeaderToday => 'Vandaag';

  @override
  String get historyHeaderYesterday => 'Gisteren';

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
      other: '$count codes',
      one: '1 code',
      zero: 'Geen codes',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Alle';

  @override
  String get historySegmentScanned => 'Gescand';

  @override
  String get historySegmentCreated => 'Gemaakt';

  @override
  String get historyEmptyMessage =>
      'Codes die je scant of maakt verschijnen hier.';

  @override
  String get historyEmptyScanButton => 'Code scannen';

  @override
  String get historyEmptyCreateButton => 'Code maken';

  @override
  String get historyEmptyNotSavingMessage =>
      'Nieuwe scans worden niet opgeslagen.';

  @override
  String get historyEmptySettingsButton => 'Naar Instellingen';

  @override
  String get historyLoading => 'Geschiedenis wordt geladen';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items verwijderd',
      one: '1 item verwijderd',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Ongedaan maken';

  @override
  String get historyDeleteFailed =>
      'Verwijderen is mislukt. Probeer het opnieuw.';

  @override
  String get historyUndoFailed =>
      'Ongedaan maken is mislukt. Probeer het opnieuw.';

  @override
  String get historyLoadFailed =>
      'Geschiedenis kon niet worden geladen. Probeer het opnieuw.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geselecteerd',
      one: '1 geselecteerd',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Verwijderen';

  @override
  String get historyCancelSelectionButton => 'Selectie annuleren';

  @override
  String copiedSnackbar(String what) {
    return '$what is gekopieerd';
  }

  @override
  String get copiedWhatLink => 'De link';

  @override
  String get copiedWhatContent => 'De inhoud';

  @override
  String get resultTitle => 'Resultaat';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Kopiëren';

  @override
  String get resultShareButton => 'Delen';

  @override
  String get resultNotSaved =>
      'Deze scan kon niet in Geschiedenis worden opgeslagen.';

  @override
  String get resultCopyFailed => 'Kopiëren is mislukt. Probeer het opnieuw.';

  @override
  String get resultShareFailed =>
      'Delen kon niet worden geopend. Probeer het opnieuw.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Tekst';

  @override
  String get parsedTypeContact => 'Contact';

  @override
  String get parsedTypePhone => 'Telefoonnummer';

  @override
  String get parsedTypeEmail => 'E-mail';

  @override
  String get parsedTypeSms => 'Sms';

  @override
  String get parsedTypeGeo => 'Locatie';

  @override
  String get parsedTypeEvent => 'Evenement';

  @override
  String get parsedTypeProduct => 'Product';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Onbekend';

  @override
  String get symbologyQr => 'QR-code';

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
  String get symbologyUnknown => 'Onbekend formaat';

  @override
  String get errorStorageUnavailable =>
      'De app kan zijn opslag niet openen. Sluit de app en open hem opnieuw.';

  @override
  String get errorSaveFailed => 'Er is niets opgeslagen. Probeer het opnieuw.';

  @override
  String get actionRetry => 'Opnieuw';

  @override
  String get copiedWhatPassword => 'Het wachtwoord';

  @override
  String get resultHandOffFailed => 'Openen is mislukt. Probeer het opnieuw.';

  @override
  String get resultUnavailableWifiSettings =>
      'Wi-Fi-instellingen kunnen op dit toestel niet worden geopend.';

  @override
  String get resultUnavailableContacts =>
      'Er is geen contactenapp geïnstalleerd.';

  @override
  String get resultUnavailableCalendar =>
      'Er is geen agenda-app geïnstalleerd.';

  @override
  String get resultUnavailableDialer => 'Er is geen telefoonapp geïnstalleerd.';

  @override
  String get resultUnavailableSms => 'Er is geen berichtenapp geïnstalleerd.';

  @override
  String get resultUnavailableEmail => 'Er is geen e-mailapp geïnstalleerd.';

  @override
  String get resultUnavailableBrowser => 'Er is geen browser geïnstalleerd.';

  @override
  String get resultLinkOpenButton => 'Openen';

  @override
  String get resultLinkReviewButton => 'Bekijken';

  @override
  String get resultLinkWarningTitle => 'Voordat je deze link opent';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Het adres is een kaal IP-nummer, geen naam';

  @override
  String get resultLinkCheckUserinfo =>
      'Er staat een gebruikersnaam voor de sitenaam';

  @override
  String get resultLinkCheckInsecureScheme => 'Het is niet versleuteld (http)';

  @override
  String get resultLinkCheckNonDefaultPort =>
      'Het gebruikt een ongebruikelijke poort';

  @override
  String get resultLinkCheckLongUrl => 'Het is ongewoon lang';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Kopiëren zonder openen';

  @override
  String get resultLinkOpenAnywayButton => 'Toch openen';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return '$scheme-links kunnen hier niet worden geopend.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Deze app controleert links voordat ze worden geopend, zodat je eerst ziet waar ze heen gaan.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Verbergen';

  @override
  String get resultWifiNetworkNameLabel => 'Netwerknaam';

  @override
  String get resultWifiSecurityLabel => 'Beveiliging';

  @override
  String get resultWifiPasswordLabel => 'Wachtwoord';

  @override
  String get resultWifiRevealPasswordTooltip => 'Wachtwoord tonen';

  @override
  String get resultWifiHidePasswordTooltip => 'Wachtwoord verbergen';

  @override
  String get resultWifiWepNotice =>
      'Android kan vanuit apps geen verbinding maken met WEP-netwerken.';

  @override
  String get resultWifiPrimaryButton => 'Wi-Fi-instellingen openen';

  @override
  String get resultWifiCopyPasswordButton => 'Wachtwoord kopiëren';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Open';

  @override
  String get resultContactNameLabel => 'Naam';

  @override
  String get resultContactPhoneLabel => 'Telefoon';

  @override
  String get resultContactEmailLabel => 'E-mail';

  @override
  String get resultContactOrganisationLabel => 'Organisatie';

  @override
  String get resultContactPrimaryButton => 'Aan contacten toevoegen';

  @override
  String get resultEventTitleLabel => 'Titel';

  @override
  String get resultEventStartLabel => 'Begin';

  @override
  String get resultEventEndLabel => 'Einde';

  @override
  String get resultEventLocationLabel => 'Locatie';

  @override
  String get resultEventNotesLabel => 'Notities';

  @override
  String get resultEventAllDayNotice => 'Duurt de hele dag.';

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
      'Dit evenement heeft geen begintijd en kan daarom niet worden toegevoegd.';

  @override
  String get resultEventPrimaryButton => 'Aan agenda toevoegen';

  @override
  String get resultPhoneNumberLabel => 'Nummer';

  @override
  String get resultPhonePrimaryButton => 'Bellen';

  @override
  String get resultSmsNumberLabel => 'Nummer';

  @override
  String get resultSmsMessageLabel => 'Bericht';

  @override
  String get resultSmsPrimaryButton => 'Bericht sturen';

  @override
  String get resultEmailToLabel => 'Aan';

  @override
  String get resultEmailSubjectLabel => 'Onderwerp';

  @override
  String get resultEmailBodyLabel => 'Bericht';

  @override
  String get resultEmailPrimaryButton => 'E-mailen';

  @override
  String get resultProductNumberLabel => 'Nummer';

  @override
  String get resultProductFormatLabel => 'Formaat';

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
  String get resultProductSearchButton => 'Op het web zoeken';

  @override
  String get resultLocationLatitudeLabel => 'Breedtegraad';

  @override
  String get resultLocationLongitudeLabel => 'Lengtegraad';

  @override
  String get resultLocationNameLabel => 'Naam';

  @override
  String get createSubtitle => 'Kies wat je wilt maken';

  @override
  String get createUrlFieldLabel => 'Webadres';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'De code opent $url';
  }

  @override
  String get createTextFieldLabel => 'Tekst';

  @override
  String get createTextFieldHint => 'Alles wat je in de code wilt zetten';

  @override
  String get createWifiSsidLabel => 'Netwerknaam';

  @override
  String get createWifiSecurityLabel => 'Beveiliging';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (onveilig)';

  @override
  String get createWifiPasswordLabel => 'Wachtwoord';

  @override
  String get createWifiHiddenLabel => 'Verborgen netwerk';

  @override
  String get createContactNameLabel => 'Naam';

  @override
  String get createContactPhoneLabel => 'Telefoon (optioneel)';

  @override
  String get createContactEmailLabel => 'E-mail (optioneel)';

  @override
  String get createContactOrganisationLabel => 'Organisatie (optioneel)';

  @override
  String get createPhoneFieldLabel => 'Telefoonnummer';

  @override
  String get createEmailToLabel => 'E-mailadres';

  @override
  String get createEmailSubjectLabel => 'Onderwerp (optioneel)';

  @override
  String get createEmailBodyLabel => 'Bericht (optioneel)';

  @override
  String get createSmsNumberLabel => 'Telefoonnummer';

  @override
  String get createSmsMessageLabel => 'Bericht (optioneel)';

  @override
  String get createFieldErrorRequired => 'Dit veld is verplicht.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Voer een webadres in dat begint met http:// of https://.';

  @override
  String get createFieldErrorInvalidEmail => 'Voer een geldig e-mailadres in.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Voer een telefoonnummer met 3 tot 15 cijfers in.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% van de capaciteit gebruikt';
  }

  @override
  String get createCapacityOverLimit =>
      'Dit is te veel inhoud voor een QR-code. Kort het in om door te gaan.';

  @override
  String get createButtonLabel => 'Maken';

  @override
  String get createCheckingMessage =>
      'Er wordt gecontroleerd of de code goed scant';

  @override
  String get createContentLabel => 'Inhoud';

  @override
  String get createCodeImageLabel => 'De gemaakte QR-code';

  @override
  String get createCheckFailedRenderFailed =>
      'De code kon niet worden gemaakt. Kort de inhoud in en probeer het opnieuw.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Deze code kon niet worden gecontroleerd. Opslaan en Delen staan uit.';

  @override
  String get createCheckFailedMismatch =>
      'Deze code kwam niet overeen met wat je hebt ingevoerd. Opslaan en Delen staan uit.';

  @override
  String get createNotSavedToHistory =>
      'Deze code kon niet in Geschiedenis worden opgeslagen.';

  @override
  String get createSaveButton => 'Opslaan';

  @override
  String get createShareButton => 'Delen';

  @override
  String get createSavedSnackbarNoName => 'Code opgeslagen';

  @override
  String createSavedSnackbar(String name) {
    return 'Opgeslagen als $name';
  }

  @override
  String get createShareFailed =>
      'Delen kon niet worden geopend. Probeer het opnieuw.';
}
