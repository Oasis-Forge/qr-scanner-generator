// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Escanear';

  @override
  String get navCreate => 'Crear';

  @override
  String get navHistory => 'Historial';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cameraPermissionReason =>
      'La cámara se usa solo para leer códigos en este dispositivo.';

  @override
  String get cameraAllowButton => 'Permitir cámara';

  @override
  String get cameraOpenSettingsButton => 'Abrir ajustes';

  @override
  String get scanFromPhotoButton => 'Escanear una foto';

  @override
  String get typeCodeButton => 'Escribir un código';

  @override
  String get placeholderCreateMessage =>
      'La creación de códigos llega en la próxima versión de prueba.';

  @override
  String get placeholderHistoryMessage =>
      'La lista del historial llega en la próxima versión de prueba. Tus escaneos ya se guardan en este teléfono.';

  @override
  String get scanReadyStatus => 'Listo';

  @override
  String get scanTargetHint => 'Apunta la cámara a un código';

  @override
  String get scanCameraUnavailable =>
      'No se pudo iniciar la cámara. Puede que otra app la esté usando.';

  @override
  String get scanTorchOn => 'Encender la linterna';

  @override
  String get scanTorchOff => 'Apagar la linterna';

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
  String get scanReadingPhoto => 'Leyendo la foto';

  @override
  String get scanPhotoPickerFailed =>
      'No se abrió el selector de fotos. Inténtalo de nuevo.';

  @override
  String get scanSettingsDidNotOpen =>
      'Los ajustes no se abrieron. Permite la cámara desde los ajustes del teléfono.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return 'Se detectó $format: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return 'Se detectó $type';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos detectados',
      one: '1 código detectado',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos encontrados',
      one: '1 código encontrado',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Elige el código que quieres abrir.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Datos binarios, $count bytes',
      one: 'Datos binarios, 1 byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Ningún código encontrado';

  @override
  String get noCodeFoundHint =>
      'Asegúrate de que el código completo esté en la foto, nítido y bien iluminado.';

  @override
  String get tryAnotherPhotoButton => 'Probar otra foto';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get manualEntryTitle => 'Escribir un código';

  @override
  String get manualEntryFieldLabel => 'Contenido del código';

  @override
  String get manualEntryFieldHint =>
      'Un enlace, un texto o un número de código de barras';

  @override
  String get manualEntryScanButton => 'Escanear';

  @override
  String get settingsGroupGeneral => 'General';

  @override
  String get settingsGroupPrivacy => 'Privacidad';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Acerca de';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSoundOnScan => 'Sonido al escanear';

  @override
  String get settingsVibrateOnScan => 'Vibrar al escanear';

  @override
  String get settingsCopyOnScan => 'Copiar al escanear';

  @override
  String get settingsSearchEngine => 'Buscador';

  @override
  String get settingsSaveHistory => 'Guardar historial';

  @override
  String get settingsSendCrashReports => 'Enviar informes de fallos';

  @override
  String get settingsPrivacyOptions => 'Opciones de privacidad';

  @override
  String get settingsRemoveAds => 'Quitar anuncios';

  @override
  String get settingsRemoveAdsSubtitle => 'Compra única';

  @override
  String get settingsRestorePurchase => 'Restaurar compra';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Compra única · $price';
  }

  @override
  String get settingsProOwned => 'Anuncios quitados';

  @override
  String get proBuyFailed =>
      'No se pudo completar la compra. Inténtalo de nuevo.';

  @override
  String get proRestoreSuccess => 'Compra restaurada.';

  @override
  String get proRestoreNotFound => 'No se encontró ninguna compra anterior.';

  @override
  String get proRestoreFailed =>
      'No se pudo consultar la tienda. Inténtalo de nuevo.';

  @override
  String get proPromptTitle => '¿Quitar anuncios?';

  @override
  String get proPromptBody => 'Una compra única, nunca una suscripción.';

  @override
  String get proPromptDismissTooltip => 'Descartar';

  @override
  String get settingsFeedback => 'Comentarios';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsOpenSourceLicences => 'Licencias de código abierto';

  @override
  String get settingsVersion => 'Versión';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'No se pudo abrir el enlace.';

  @override
  String get feedbackCategoryLabel => 'Categoría';

  @override
  String get feedbackCategoryScanning => 'Escaneo';

  @override
  String get feedbackCategoryResults => 'Resultados';

  @override
  String get feedbackCategoryCreatingCodes => 'Creación de códigos';

  @override
  String get feedbackCategoryAds => 'Anuncios';

  @override
  String get feedbackCategoryOther => 'Otro';

  @override
  String get feedbackMessageHint => '¿Qué pasó y qué esperabas?';

  @override
  String get feedbackSendButton => 'Enviar';

  @override
  String get feedbackSendNoHandler =>
      'No hay ninguna app de correo configurada en este dispositivo.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Comentarios sobre $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Predeterminado del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get historyHeaderToday => 'Hoy';

  @override
  String get historyHeaderYesterday => 'Ayer';

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
      other: '$count códigos',
      one: '1 código',
      zero: 'Ningún código',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Todos';

  @override
  String get historySegmentScanned => 'Escaneados';

  @override
  String get historySegmentCreated => 'Creados';

  @override
  String get historyEmptyMessage =>
      'Los códigos que escanees o crees aparecerán aquí.';

  @override
  String get historyEmptyScanButton => 'Escanear un código';

  @override
  String get historyEmptyCreateButton => 'Crear un código';

  @override
  String get historyEmptyNotSavingMessage =>
      'Los escaneos nuevos no se están guardando.';

  @override
  String get historyEmptySettingsButton => 'Ir a Ajustes';

  @override
  String get historyLoading => 'Cargando el historial';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos eliminados',
      one: '1 elemento eliminado',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Deshacer';

  @override
  String get historyDeleteFailed => 'No se pudo eliminar. Inténtalo de nuevo.';

  @override
  String get historyUndoFailed => 'No se pudo deshacer. Inténtalo de nuevo.';

  @override
  String get historyLoadFailed =>
      'No se pudo cargar el historial. Inténtalo de nuevo.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Eliminar';

  @override
  String get historyCancelSelectionButton => 'Cancelar selección';

  @override
  String copiedSnackbar(String what) {
    return 'Se copió $what';
  }

  @override
  String get copiedWhatLink => 'el enlace';

  @override
  String get copiedWhatContent => 'el contenido';

  @override
  String get resultTitle => 'Resultado';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Copiar';

  @override
  String get resultShareButton => 'Compartir';

  @override
  String get resultNotSaved =>
      'Este escaneo no se pudo guardar en el historial.';

  @override
  String get resultCopyFailed => 'No se pudo copiar. Inténtalo de nuevo.';

  @override
  String get resultShareFailed =>
      'No se pudo abrir el menú de compartir. Inténtalo de nuevo.';

  @override
  String get parsedTypeUrl => 'Enlace';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Texto';

  @override
  String get parsedTypeContact => 'Contacto';

  @override
  String get parsedTypePhone => 'Número de teléfono';

  @override
  String get parsedTypeEmail => 'Correo';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Ubicación';

  @override
  String get parsedTypeEvent => 'Evento';

  @override
  String get parsedTypeProduct => 'Producto';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Desconocido';

  @override
  String get symbologyQr => 'Código QR';

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
  String get symbologyUnknown => 'Formato desconocido';

  @override
  String get errorStorageUnavailable =>
      'La app no puede abrir su almacenamiento. Ciérrala y vuelve a abrirla.';

  @override
  String get errorSaveFailed => 'No se guardó nada. Inténtalo de nuevo.';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get copiedWhatPassword => 'la contraseña';

  @override
  String get resultHandOffFailed => 'No se pudo abrir. Inténtalo de nuevo.';

  @override
  String get resultUnavailableWifiSettings =>
      'Los ajustes de Wi-Fi no se pueden abrir en este dispositivo.';

  @override
  String get resultUnavailableContacts =>
      'No hay ninguna app de contactos instalada.';

  @override
  String get resultUnavailableCalendar =>
      'No hay ninguna app de calendario instalada.';

  @override
  String get resultUnavailableDialer =>
      'No hay ninguna app de teléfono instalada.';

  @override
  String get resultUnavailableSms =>
      'No hay ninguna app de mensajes instalada.';

  @override
  String get resultUnavailableEmail =>
      'No hay ninguna app de correo instalada.';

  @override
  String get resultUnavailableBrowser => 'No hay ningún navegador instalado.';

  @override
  String get resultLinkOpenButton => 'Abrir';

  @override
  String get resultLinkReviewButton => 'Revisar';

  @override
  String get resultLinkWarningTitle => 'Antes de abrir este enlace';

  @override
  String get resultLinkCheckIpAddressHost =>
      'La dirección es un número IP, no un nombre';

  @override
  String get resultLinkCheckUserinfo =>
      'Contiene un nombre de usuario antes del nombre del sitio';

  @override
  String get resultLinkCheckInsecureScheme => 'No está cifrado (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Usa un puerto poco habitual';

  @override
  String get resultLinkCheckLongUrl => 'Es inusualmente largo';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Copiar sin abrir';

  @override
  String get resultLinkOpenAnywayButton => 'Abrir igualmente';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Los enlaces $scheme no se pueden abrir aquí.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Esta app revisa los enlaces antes de abrirlos, para que veas primero adónde llevan.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Descartar';

  @override
  String get resultWifiNetworkNameLabel => 'Nombre de la red';

  @override
  String get resultWifiSecurityLabel => 'Seguridad';

  @override
  String get resultWifiPasswordLabel => 'Contraseña';

  @override
  String get resultWifiRevealPasswordTooltip => 'Mostrar contraseña';

  @override
  String get resultWifiHidePasswordTooltip => 'Ocultar contraseña';

  @override
  String get resultWifiWepNotice =>
      'Android no puede conectarse a redes WEP desde las apps.';

  @override
  String get resultWifiPrimaryButton => 'Abrir ajustes de Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Copiar contraseña';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Abierta';

  @override
  String get resultContactNameLabel => 'Nombre';

  @override
  String get resultContactPhoneLabel => 'Teléfono';

  @override
  String get resultContactEmailLabel => 'Correo';

  @override
  String get resultContactOrganisationLabel => 'Organización';

  @override
  String get resultContactPrimaryButton => 'Añadir a contactos';

  @override
  String get resultEventTitleLabel => 'Título';

  @override
  String get resultEventStartLabel => 'Inicio';

  @override
  String get resultEventEndLabel => 'Fin';

  @override
  String get resultEventLocationLabel => 'Ubicación';

  @override
  String get resultEventNotesLabel => 'Notas';

  @override
  String get resultEventAllDayNotice => 'Evento de todo el día.';

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
      'Este evento no tiene hora de inicio, así que no se puede añadir.';

  @override
  String get resultEventPrimaryButton => 'Añadir al calendario';

  @override
  String get resultPhoneNumberLabel => 'Número';

  @override
  String get resultPhonePrimaryButton => 'Llamar';

  @override
  String get resultSmsNumberLabel => 'Número';

  @override
  String get resultSmsMessageLabel => 'Mensaje';

  @override
  String get resultSmsPrimaryButton => 'Enviar mensaje';

  @override
  String get resultEmailToLabel => 'Para';

  @override
  String get resultEmailSubjectLabel => 'Asunto';

  @override
  String get resultEmailBodyLabel => 'Mensaje';

  @override
  String get resultEmailPrimaryButton => 'Enviar correo';

  @override
  String get resultProductNumberLabel => 'Número';

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
  String get resultProductSearchButton => 'Buscar en la web';

  @override
  String get resultLocationLatitudeLabel => 'Latitud';

  @override
  String get resultLocationLongitudeLabel => 'Longitud';

  @override
  String get resultLocationNameLabel => 'Nombre';

  @override
  String get createSubtitle => 'Elige qué crear';

  @override
  String get createUrlFieldLabel => 'Dirección web';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'El código abre $url';
  }

  @override
  String get createTextFieldLabel => 'Texto';

  @override
  String get createTextFieldHint => 'Lo que quieras que diga el código';

  @override
  String get createWifiSsidLabel => 'Nombre de la red';

  @override
  String get createWifiSecurityLabel => 'Seguridad';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (no seguro)';

  @override
  String get createWifiPasswordLabel => 'Contraseña';

  @override
  String get createWifiHiddenLabel => 'Red oculta';

  @override
  String get createContactNameLabel => 'Nombre';

  @override
  String get createContactPhoneLabel => 'Teléfono (opcional)';

  @override
  String get createContactEmailLabel => 'Correo (opcional)';

  @override
  String get createContactOrganisationLabel => 'Organización (opcional)';

  @override
  String get createPhoneFieldLabel => 'Número de teléfono';

  @override
  String get createEmailToLabel => 'Dirección de correo';

  @override
  String get createEmailSubjectLabel => 'Asunto (opcional)';

  @override
  String get createEmailBodyLabel => 'Mensaje (opcional)';

  @override
  String get createSmsNumberLabel => 'Número de teléfono';

  @override
  String get createSmsMessageLabel => 'Mensaje (opcional)';

  @override
  String get createFieldErrorRequired => 'Este campo es obligatorio.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Escribe una dirección web que empiece por http:// o https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Escribe una dirección de correo válida.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Escribe un número de teléfono de 3 a 15 dígitos.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% de la capacidad usada';
  }

  @override
  String get createCapacityOverLimit =>
      'Es demasiado contenido para un código QR. Acórtalo para continuar.';

  @override
  String get createButtonLabel => 'Crear';

  @override
  String get createCheckingMessage =>
      'Comprobando que el código se escanea bien';

  @override
  String get createContentLabel => 'Contenido';

  @override
  String get createCodeImageLabel => 'El código QR creado';

  @override
  String get createCheckFailedRenderFailed =>
      'No se pudo crear el código. Acorta el contenido e inténtalo de nuevo.';

  @override
  String get createCheckFailedDecodeFailed =>
      'No se pudo comprobar este código. Guardar y Compartir están desactivados.';

  @override
  String get createCheckFailedMismatch =>
      'Este código no coincide con lo que escribiste. Guardar y Compartir están desactivados.';

  @override
  String get createNotSavedToHistory =>
      'Este código no se pudo guardar en el historial.';

  @override
  String get createSaveButton => 'Guardar';

  @override
  String get createShareButton => 'Compartir';

  @override
  String get createSavedSnackbarNoName => 'Código guardado';

  @override
  String createSavedSnackbar(String name) {
    return 'Guardado como $name';
  }

  @override
  String get createShareFailed =>
      'No se pudo abrir el menú de compartir. Inténtalo de nuevo.';
}
