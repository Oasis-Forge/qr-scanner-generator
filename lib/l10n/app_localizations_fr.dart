// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Scanner';

  @override
  String get navCreate => 'Créer';

  @override
  String get navHistory => 'Historique';

  @override
  String get navSettings => 'Réglages';

  @override
  String get cameraPermissionReason =>
      'La caméra sert uniquement à lire des codes sur cet appareil.';

  @override
  String get cameraAllowButton => 'Autoriser la caméra';

  @override
  String get cameraOpenSettingsButton => 'Ouvrir les réglages';

  @override
  String get scanFromPhotoButton => 'Scanner une photo';

  @override
  String get typeCodeButton => 'Saisir un code';

  @override
  String get placeholderCreateMessage =>
      'La création de codes arrive dans la prochaine version de test.';

  @override
  String get placeholderHistoryMessage =>
      'La liste Historique arrive dans la prochaine version de test. Vos scans sont déjà conservés sur ce téléphone.';

  @override
  String get scanReadyStatus => 'Prêt';

  @override
  String get scanTargetHint => 'Visez un code avec la caméra';

  @override
  String get scanCameraUnavailable =>
      'La caméra n\'a pas pu démarrer. Une autre application l\'utilise peut-être.';

  @override
  String get scanTorchOn => 'Allumer la lampe';

  @override
  String get scanTorchOff => 'Éteindre la lampe';

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
  String get scanReadingPhoto => 'Lecture de la photo';

  @override
  String get scanPhotoPickerFailed =>
      'Le sélecteur de photos ne s\'est pas ouvert. Réessayez.';

  @override
  String get scanSettingsDidNotOpen =>
      'Les réglages ne se sont pas ouverts. Autorisez la caméra dans les réglages du téléphone.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format détecté : $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Détecté : $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes détectés',
      one: '1 code détecté',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes trouvés',
      one: '1 code trouvé',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Choisissez le code à ouvrir.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Données binaires, $count octets',
      one: 'Données binaires, 1 octet',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Aucun code trouvé';

  @override
  String get noCodeFoundHint =>
      'Vérifiez que le code entier est sur la photo, net et bien éclairé.';

  @override
  String get tryAnotherPhotoButton => 'Essayer une autre photo';

  @override
  String get actionClose => 'Fermer';

  @override
  String get manualEntryTitle => 'Saisir un code';

  @override
  String get manualEntryFieldLabel => 'Contenu du code';

  @override
  String get manualEntryFieldHint =>
      'Un lien, du texte ou un numéro de code-barres';

  @override
  String get manualEntryScanButton => 'Scanner';

  @override
  String get settingsGroupGeneral => 'Général';

  @override
  String get settingsGroupPrivacy => 'Confidentialité';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'À propos';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSoundOnScan => 'Son au scan';

  @override
  String get settingsVibrateOnScan => 'Vibration au scan';

  @override
  String get settingsCopyOnScan => 'Copie au scan';

  @override
  String get settingsSearchEngine => 'Moteur de recherche';

  @override
  String get settingsSaveHistory => 'Enregistrer l\'historique';

  @override
  String get settingsSendCrashReports => 'Envoyer les rapports de plantage';

  @override
  String get settingsPrivacyOptions => 'Options de confidentialité';

  @override
  String get settingsRemoveAds => 'Supprimer les publicités';

  @override
  String get settingsRemoveAdsSubtitle => 'Achat unique';

  @override
  String get settingsRestorePurchase => 'Restaurer l\'achat';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Achat unique · $price';
  }

  @override
  String get settingsProOwned => 'Publicités supprimées';

  @override
  String get proBuyFailed => 'Impossible de finaliser l\'achat. Réessayez.';

  @override
  String get proRestoreSuccess => 'Achat restauré.';

  @override
  String get proRestoreNotFound => 'Aucun achat précédent n\'a été trouvé.';

  @override
  String get proRestoreFailed =>
      'Impossible de vérifier la boutique. Réessayez.';

  @override
  String get proPromptTitle => 'Supprimer les publicités ?';

  @override
  String get proPromptBody => 'Un achat unique, jamais un abonnement.';

  @override
  String get proPromptDismissTooltip => 'Masquer';

  @override
  String get settingsFeedback => 'Commentaires';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsOpenSourceLicences => 'Licences open source';

  @override
  String get settingsVersion => 'Version';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Impossible d\'ouvrir le lien.';

  @override
  String get feedbackCategoryLabel => 'Catégorie';

  @override
  String get feedbackCategoryScanning => 'Scan';

  @override
  String get feedbackCategoryResults => 'Résultats';

  @override
  String get feedbackCategoryCreatingCodes => 'Création de codes';

  @override
  String get feedbackCategoryAds => 'Publicités';

  @override
  String get feedbackCategoryOther => 'Autre';

  @override
  String get feedbackMessageHint =>
      'Que s\'est-il passé, et à quoi vous attendiez-vous ?';

  @override
  String get feedbackSendButton => 'Envoyer';

  @override
  String get feedbackSendNoHandler =>
      'Aucune application e-mail n\'est configurée sur cet appareil.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Commentaires $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageSystemDefault => 'Système';

  @override
  String get historyHeaderToday => 'Aujourd\'hui';

  @override
  String get historyHeaderYesterday => 'Hier';

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
      zero: 'Aucun code',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Tous';

  @override
  String get historySegmentScanned => 'Scannés';

  @override
  String get historySegmentCreated => 'Créés';

  @override
  String get historyEmptyMessage =>
      'Les codes que vous scannez ou créez apparaîtront ici.';

  @override
  String get historyEmptyScanButton => 'Scanner un code';

  @override
  String get historyEmptyCreateButton => 'Créer un code';

  @override
  String get historyEmptyNotSavingMessage =>
      'Les nouveaux scans ne sont pas enregistrés.';

  @override
  String get historyEmptySettingsButton => 'Aller aux réglages';

  @override
  String get historyLoading => 'Chargement de l\'historique';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments supprimés',
      one: '1 élément supprimé',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Annuler';

  @override
  String get historyDeleteFailed => 'Impossible de supprimer. Réessayez.';

  @override
  String get historyUndoFailed => 'Impossible d\'annuler. Réessayez.';

  @override
  String get historyLoadFailed =>
      'Impossible de charger l\'historique. Réessayez.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Supprimer';

  @override
  String get historyCancelSelectionButton => 'Annuler la sélection';

  @override
  String copiedSnackbar(String what) {
    return '$what a été copié';
  }

  @override
  String get copiedWhatLink => 'Le lien';

  @override
  String get copiedWhatContent => 'Le contenu';

  @override
  String get resultTitle => 'Résultat';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Copier';

  @override
  String get resultShareButton => 'Partager';

  @override
  String get resultNotSaved =>
      'Ce scan n\'a pas pu être enregistré dans l\'historique.';

  @override
  String get resultCopyFailed => 'Impossible de copier. Réessayez.';

  @override
  String get resultShareFailed => 'Impossible d\'ouvrir le partage. Réessayez.';

  @override
  String get parsedTypeUrl => 'Lien';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Texte';

  @override
  String get parsedTypeContact => 'Contact';

  @override
  String get parsedTypePhone => 'Numéro de téléphone';

  @override
  String get parsedTypeEmail => 'E-mail';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Lieu';

  @override
  String get parsedTypeEvent => 'Événement';

  @override
  String get parsedTypeProduct => 'Produit';

  @override
  String get parsedTypeAppStore => 'Application';

  @override
  String get parsedTypeUnknown => 'Inconnu';

  @override
  String get symbologyQr => 'Code QR';

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
  String get symbologyUnknown => 'Format inconnu';

  @override
  String get errorStorageUnavailable =>
      'L\'application ne peut pas ouvrir son stockage. Fermez-la puis rouvrez-la.';

  @override
  String get errorSaveFailed => 'Rien n\'a été enregistré. Réessayez.';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get copiedWhatPassword => 'Le mot de passe';

  @override
  String get resultHandOffFailed => 'Impossible d\'ouvrir. Réessayez.';

  @override
  String get resultUnavailableWifiSettings =>
      'Les réglages Wi-Fi ne peuvent pas être ouverts sur cet appareil.';

  @override
  String get resultUnavailableContacts =>
      'Aucune application Contacts n\'est installée.';

  @override
  String get resultUnavailableCalendar =>
      'Aucune application Agenda n\'est installée.';

  @override
  String get resultUnavailableDialer =>
      'Aucune application Téléphone n\'est installée.';

  @override
  String get resultUnavailableSms =>
      'Aucune application de messagerie n\'est installée.';

  @override
  String get resultUnavailableEmail =>
      'Aucune application e-mail n\'est installée.';

  @override
  String get resultUnavailableBrowser => 'Aucun navigateur n\'est installé.';

  @override
  String get resultLinkOpenButton => 'Ouvrir';

  @override
  String get resultLinkReviewButton => 'Examiner';

  @override
  String get resultLinkWarningTitle => 'Avant d\'ouvrir ce lien';

  @override
  String get resultLinkCheckIpAddressHost =>
      'L\'adresse est un numéro IP brut, pas un nom';

  @override
  String get resultLinkCheckUserinfo =>
      'Elle contient un nom d\'utilisateur avant le nom du site';

  @override
  String get resultLinkCheckInsecureScheme => 'Elle n\'est pas chiffrée (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Elle utilise un port inhabituel';

  @override
  String get resultLinkCheckLongUrl => 'Elle est anormalement longue';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Copier sans ouvrir';

  @override
  String get resultLinkOpenAnywayButton => 'Ouvrir quand même';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Les liens $scheme ne peuvent pas être ouverts ici.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Cette application vérifie les liens avant de les ouvrir, pour que vous voyiez d\'abord où ils mènent.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Masquer';

  @override
  String get resultWifiNetworkNameLabel => 'Nom du réseau';

  @override
  String get resultWifiSecurityLabel => 'Sécurité';

  @override
  String get resultWifiPasswordLabel => 'Mot de passe';

  @override
  String get resultWifiRevealPasswordTooltip => 'Afficher le mot de passe';

  @override
  String get resultWifiHidePasswordTooltip => 'Masquer le mot de passe';

  @override
  String get resultWifiWepNotice =>
      'Android ne peut pas rejoindre les réseaux WEP depuis une application.';

  @override
  String get resultWifiPrimaryButton => 'Ouvrir les réglages Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Copier le mot de passe';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Ouvert';

  @override
  String get resultContactNameLabel => 'Nom';

  @override
  String get resultContactPhoneLabel => 'Téléphone';

  @override
  String get resultContactEmailLabel => 'E-mail';

  @override
  String get resultContactOrganisationLabel => 'Organisation';

  @override
  String get resultContactPrimaryButton => 'Ajouter aux contacts';

  @override
  String get resultEventTitleLabel => 'Titre';

  @override
  String get resultEventStartLabel => 'Début';

  @override
  String get resultEventEndLabel => 'Fin';

  @override
  String get resultEventLocationLabel => 'Lieu';

  @override
  String get resultEventNotesLabel => 'Notes';

  @override
  String get resultEventAllDayNotice => 'Événement sur toute la journée.';

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
      'Cet événement n\'a pas d\'heure de début, il ne peut donc pas être ajouté.';

  @override
  String get resultEventPrimaryButton => 'Ajouter à l\'agenda';

  @override
  String get resultPhoneNumberLabel => 'Numéro';

  @override
  String get resultPhonePrimaryButton => 'Appeler';

  @override
  String get resultSmsNumberLabel => 'Numéro';

  @override
  String get resultSmsMessageLabel => 'Message';

  @override
  String get resultSmsPrimaryButton => 'Écrire un SMS';

  @override
  String get resultEmailToLabel => 'À';

  @override
  String get resultEmailSubjectLabel => 'Objet';

  @override
  String get resultEmailBodyLabel => 'Message';

  @override
  String get resultEmailPrimaryButton => 'Écrire un e-mail';

  @override
  String get resultProductNumberLabel => 'Numéro';

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
  String get resultProductSearchButton => 'Rechercher sur le Web';

  @override
  String get resultLocationLatitudeLabel => 'Latitude';

  @override
  String get resultLocationLongitudeLabel => 'Longitude';

  @override
  String get resultLocationNameLabel => 'Nom';

  @override
  String get createSubtitle => 'Choisissez quoi créer';

  @override
  String get createUrlFieldLabel => 'Adresse web';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Le code ouvre $url';
  }

  @override
  String get createTextFieldLabel => 'Texte';

  @override
  String get createTextFieldHint =>
      'Tout ce que vous voulez mettre dans le code';

  @override
  String get createWifiSsidLabel => 'Nom du réseau';

  @override
  String get createWifiSecurityLabel => 'Sécurité';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (non sécurisé)';

  @override
  String get createWifiPasswordLabel => 'Mot de passe';

  @override
  String get createWifiHiddenLabel => 'Réseau masqué';

  @override
  String get createContactNameLabel => 'Nom';

  @override
  String get createContactPhoneLabel => 'Téléphone (facultatif)';

  @override
  String get createContactEmailLabel => 'E-mail (facultatif)';

  @override
  String get createContactOrganisationLabel => 'Organisation (facultatif)';

  @override
  String get createPhoneFieldLabel => 'Numéro de téléphone';

  @override
  String get createEmailToLabel => 'Adresse e-mail';

  @override
  String get createEmailSubjectLabel => 'Objet (facultatif)';

  @override
  String get createEmailBodyLabel => 'Message (facultatif)';

  @override
  String get createSmsNumberLabel => 'Numéro de téléphone';

  @override
  String get createSmsMessageLabel => 'Message (facultatif)';

  @override
  String get createFieldErrorRequired => 'Ce champ est obligatoire.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Saisissez une adresse web commençant par http:// ou https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Saisissez une adresse e-mail valide.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Saisissez un numéro de téléphone de 3 à 15 chiffres.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent % de la capacité utilisée';
  }

  @override
  String get createCapacityOverLimit =>
      'Ce contenu est trop long pour un code QR. Raccourcissez-le pour continuer.';

  @override
  String get createButtonLabel => 'Créer';

  @override
  String get createCheckingMessage =>
      'Vérification que le code se scanne correctement';

  @override
  String get createContentLabel => 'Contenu';

  @override
  String get createCodeImageLabel => 'Le code QR créé';

  @override
  String get createCheckFailedRenderFailed =>
      'Le code n\'a pas pu être créé. Raccourcissez le contenu et réessayez.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Ce code n\'a pas pu être vérifié. Enregistrer et Partager sont désactivés.';

  @override
  String get createCheckFailedMismatch =>
      'Ce code ne correspond pas à ce que vous avez saisi. Enregistrer et Partager sont désactivés.';

  @override
  String get createNotSavedToHistory =>
      'Ce code n\'a pas pu être enregistré dans l\'historique.';

  @override
  String get createSaveButton => 'Enregistrer';

  @override
  String get createShareButton => 'Partager';

  @override
  String get createSavedSnackbarNoName => 'Code enregistré';

  @override
  String createSavedSnackbar(String name) {
    return 'Enregistré sous $name';
  }

  @override
  String get createShareFailed => 'Impossible d\'ouvrir le partage. Réessayez.';
}
