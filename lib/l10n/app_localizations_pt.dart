// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Escanear';

  @override
  String get navCreate => 'Criar';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navSettings => 'Configurações';

  @override
  String get cameraPermissionReason =>
      'A câmera é usada apenas para ler códigos neste dispositivo.';

  @override
  String get cameraAllowButton => 'Permitir câmera';

  @override
  String get cameraOpenSettingsButton => 'Abrir configurações';

  @override
  String get scanFromPhotoButton => 'Escanear foto';

  @override
  String get typeCodeButton => 'Digitar código';

  @override
  String get placeholderCreateMessage =>
      'A criação de códigos chega na próxima versão de teste.';

  @override
  String get placeholderHistoryMessage =>
      'A lista do Histórico chega na próxima versão de teste. Seus escaneamentos já ficam salvos neste celular.';

  @override
  String get scanReadyStatus => 'Pronto';

  @override
  String get scanTargetHint => 'Aponte a câmera para um código';

  @override
  String get scanCameraUnavailable =>
      'Não foi possível iniciar a câmera. Outro app pode estar usando a câmera.';

  @override
  String get scanTorchOn => 'Ligar a lanterna';

  @override
  String get scanTorchOff => 'Desligar a lanterna';

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
  String get scanReadingPhoto => 'Lendo a foto';

  @override
  String get scanPhotoPickerFailed =>
      'O seletor de fotos não abriu. Tente novamente.';

  @override
  String get scanSettingsDidNotOpen =>
      'As configurações não abriram. Permita a câmera nas configurações do celular.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format detectado: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type detectado';
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
  String get scanChoicesHint => 'Escolha o código para abrir.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dados binários, $count bytes',
      one: 'Dados binários, 1 byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Nenhum código encontrado';

  @override
  String get noCodeFoundHint =>
      'Confira se o código inteiro aparece na foto, nítido e bem iluminado.';

  @override
  String get tryAnotherPhotoButton => 'Tentar outra foto';

  @override
  String get actionClose => 'Fechar';

  @override
  String get manualEntryTitle => 'Digitar código';

  @override
  String get manualEntryFieldLabel => 'Conteúdo do código';

  @override
  String get manualEntryFieldHint =>
      'Um link, um texto ou o número de um código de barras';

  @override
  String get manualEntryScanButton => 'Escanear';

  @override
  String get settingsGroupGeneral => 'Geral';

  @override
  String get settingsGroupPrivacy => 'Privacidade';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Sobre';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSoundOnScan => 'Som ao escanear';

  @override
  String get settingsVibrateOnScan => 'Vibrar ao escanear';

  @override
  String get settingsCopyOnScan => 'Copiar ao escanear';

  @override
  String get settingsSearchEngine => 'Buscador';

  @override
  String get settingsSaveHistory => 'Salvar histórico';

  @override
  String get settingsSendCrashReports => 'Enviar relatórios de erro';

  @override
  String get settingsPrivacyOptions => 'Opções de privacidade';

  @override
  String get settingsRemoveAds => 'Remover anúncios';

  @override
  String get settingsRemoveAdsSubtitle => 'Compra única';

  @override
  String get settingsRestorePurchase => 'Restaurar compra';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Compra única · $price';
  }

  @override
  String get settingsProOwned => 'Anúncios removidos';

  @override
  String get proBuyFailed =>
      'Não foi possível concluir a compra. Tente novamente.';

  @override
  String get proRestoreSuccess => 'Compra restaurada.';

  @override
  String get proRestoreNotFound => 'Nenhuma compra anterior foi encontrada.';

  @override
  String get proRestoreFailed =>
      'Não foi possível consultar a loja. Tente novamente.';

  @override
  String get proPromptTitle => 'Remover anúncios?';

  @override
  String get proPromptBody => 'Uma compra única, nunca uma assinatura.';

  @override
  String get proPromptDismissTooltip => 'Dispensar';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidade';

  @override
  String get settingsOpenSourceLicences => 'Licenças de código aberto';

  @override
  String get settingsVersion => 'Versão';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Não foi possível abrir o link.';

  @override
  String get feedbackCategoryLabel => 'Categoria';

  @override
  String get feedbackCategoryScanning => 'Escaneamento';

  @override
  String get feedbackCategoryResults => 'Resultados';

  @override
  String get feedbackCategoryCreatingCodes => 'Criação de códigos';

  @override
  String get feedbackCategoryAds => 'Anúncios';

  @override
  String get feedbackCategoryOther => 'Outro';

  @override
  String get feedbackMessageHint => 'O que aconteceu e o que você esperava?';

  @override
  String get feedbackSendButton => 'Enviar';

  @override
  String get feedbackSendNoHandler =>
      'Nenhum app de e-mail está configurado neste dispositivo.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Feedback do $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get historyHeaderToday => 'Hoje';

  @override
  String get historyHeaderYesterday => 'Ontem';

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
      zero: 'Nenhum código',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Todos';

  @override
  String get historySegmentScanned => 'Escaneados';

  @override
  String get historySegmentCreated => 'Criados';

  @override
  String get historyEmptyMessage =>
      'Os códigos que você escanear ou criar vão aparecer aqui.';

  @override
  String get historyEmptyScanButton => 'Escanear um código';

  @override
  String get historyEmptyCreateButton => 'Criar um código';

  @override
  String get historyEmptyNotSavingMessage =>
      'Novos escaneamentos não estão sendo salvos.';

  @override
  String get historyEmptySettingsButton => 'Ir para Configurações';

  @override
  String get historyLoading => 'Carregando o Histórico';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens excluídos',
      one: '1 item excluído',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Desfazer';

  @override
  String get historyDeleteFailed =>
      'Não foi possível excluir. Tente novamente.';

  @override
  String get historyUndoFailed => 'Não foi possível desfazer. Tente novamente.';

  @override
  String get historyLoadFailed =>
      'Não foi possível carregar o Histórico. Tente novamente.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Excluir';

  @override
  String get historyCancelSelectionButton => 'Cancelar seleção';

  @override
  String copiedSnackbar(String what) {
    return 'Copiado: $what';
  }

  @override
  String get copiedWhatLink => 'o link';

  @override
  String get copiedWhatContent => 'o conteúdo';

  @override
  String get resultTitle => 'Resultado';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Copiar';

  @override
  String get resultShareButton => 'Compartilhar';

  @override
  String get resultNotSaved =>
      'Não foi possível salvar este escaneamento no Histórico.';

  @override
  String get resultCopyFailed => 'Não foi possível copiar. Tente novamente.';

  @override
  String get resultShareFailed =>
      'Não foi possível abrir o compartilhamento. Tente novamente.';

  @override
  String get parsedTypeUrl => 'Link';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Texto';

  @override
  String get parsedTypeContact => 'Contato';

  @override
  String get parsedTypePhone => 'Telefone';

  @override
  String get parsedTypeEmail => 'E-mail';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Local';

  @override
  String get parsedTypeEvent => 'Evento';

  @override
  String get parsedTypeProduct => 'Produto';

  @override
  String get parsedTypeAppStore => 'App';

  @override
  String get parsedTypeUnknown => 'Desconhecido';

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
  String get symbologyUnknown => 'Formato desconhecido';

  @override
  String get errorStorageUnavailable =>
      'O app não consegue abrir o armazenamento. Feche e abra o app de novo.';

  @override
  String get errorSaveFailed => 'Nada foi salvo. Tente novamente.';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get copiedWhatPassword => 'a senha';

  @override
  String get resultHandOffFailed => 'Não foi possível abrir. Tente novamente.';

  @override
  String get resultUnavailableWifiSettings =>
      'Não é possível abrir as configurações de Wi-Fi neste dispositivo.';

  @override
  String get resultUnavailableContacts =>
      'Nenhum app de contatos está instalado.';

  @override
  String get resultUnavailableCalendar =>
      'Nenhum app de calendário está instalado.';

  @override
  String get resultUnavailableDialer =>
      'Nenhum app de telefone está instalado.';

  @override
  String get resultUnavailableSms => 'Nenhum app de mensagens está instalado.';

  @override
  String get resultUnavailableEmail => 'Nenhum app de e-mail está instalado.';

  @override
  String get resultUnavailableBrowser => 'Nenhum navegador está instalado.';

  @override
  String get resultLinkOpenButton => 'Abrir';

  @override
  String get resultLinkReviewButton => 'Conferir';

  @override
  String get resultLinkWarningTitle => 'Antes de abrir este link';

  @override
  String get resultLinkCheckIpAddressHost =>
      'O endereço é um número IP, não um nome';

  @override
  String get resultLinkCheckUserinfo =>
      'Tem um nome de usuário antes do nome do site';

  @override
  String get resultLinkCheckInsecureScheme => 'Não é criptografado (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Usa uma porta incomum';

  @override
  String get resultLinkCheckLongUrl => 'É incomumente longo';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Copiar sem abrir';

  @override
  String get resultLinkOpenAnywayButton => 'Abrir mesmo assim';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Links $scheme não podem ser abertos aqui.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Este app verifica os links antes de abrir, para você ver aonde eles levam primeiro.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Dispensar';

  @override
  String get resultWifiNetworkNameLabel => 'Nome da rede';

  @override
  String get resultWifiSecurityLabel => 'Segurança';

  @override
  String get resultWifiPasswordLabel => 'Senha';

  @override
  String get resultWifiRevealPasswordTooltip => 'Mostrar senha';

  @override
  String get resultWifiHidePasswordTooltip => 'Ocultar senha';

  @override
  String get resultWifiWepNotice =>
      'O Android não conecta a redes WEP a partir de apps.';

  @override
  String get resultWifiPrimaryButton => 'Abrir configurações de Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Copiar senha';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Aberta';

  @override
  String get resultContactNameLabel => 'Nome';

  @override
  String get resultContactPhoneLabel => 'Telefone';

  @override
  String get resultContactEmailLabel => 'E-mail';

  @override
  String get resultContactOrganisationLabel => 'Organização';

  @override
  String get resultContactPrimaryButton => 'Adicionar aos contatos';

  @override
  String get resultEventTitleLabel => 'Título';

  @override
  String get resultEventStartLabel => 'Início';

  @override
  String get resultEventEndLabel => 'Término';

  @override
  String get resultEventLocationLabel => 'Local';

  @override
  String get resultEventNotesLabel => 'Notas';

  @override
  String get resultEventAllDayNotice => 'Evento de dia inteiro.';

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
      'Este evento não tem horário de início, então não pode ser adicionado.';

  @override
  String get resultEventPrimaryButton => 'Adicionar ao calendário';

  @override
  String get resultPhoneNumberLabel => 'Número';

  @override
  String get resultPhonePrimaryButton => 'Ligar';

  @override
  String get resultSmsNumberLabel => 'Número';

  @override
  String get resultSmsMessageLabel => 'Mensagem';

  @override
  String get resultSmsPrimaryButton => 'Enviar mensagem';

  @override
  String get resultEmailToLabel => 'Para';

  @override
  String get resultEmailSubjectLabel => 'Assunto';

  @override
  String get resultEmailBodyLabel => 'Mensagem';

  @override
  String get resultEmailPrimaryButton => 'Enviar e-mail';

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
  String get resultProductSearchButton => 'Buscar na web';

  @override
  String get resultLocationLatitudeLabel => 'Latitude';

  @override
  String get resultLocationLongitudeLabel => 'Longitude';

  @override
  String get resultLocationNameLabel => 'Nome';

  @override
  String get createSubtitle => 'Escolha o que criar';

  @override
  String get createUrlFieldLabel => 'Endereço da web';

  @override
  String get createUrlFieldHint => 'exemplo.com';

  @override
  String createUrlHelperText(String url) {
    return 'O código abre $url';
  }

  @override
  String get createTextFieldLabel => 'Texto';

  @override
  String get createTextFieldHint => 'Qualquer coisa que você queira no código';

  @override
  String get createWifiSsidLabel => 'Nome da rede';

  @override
  String get createWifiSecurityLabel => 'Segurança';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (insegura)';

  @override
  String get createWifiPasswordLabel => 'Senha';

  @override
  String get createWifiHiddenLabel => 'Rede oculta';

  @override
  String get createContactNameLabel => 'Nome';

  @override
  String get createContactPhoneLabel => 'Telefone (opcional)';

  @override
  String get createContactEmailLabel => 'E-mail (opcional)';

  @override
  String get createContactOrganisationLabel => 'Organização (opcional)';

  @override
  String get createPhoneFieldLabel => 'Número de telefone';

  @override
  String get createEmailToLabel => 'Endereço de e-mail';

  @override
  String get createEmailSubjectLabel => 'Assunto (opcional)';

  @override
  String get createEmailBodyLabel => 'Mensagem (opcional)';

  @override
  String get createSmsNumberLabel => 'Número de telefone';

  @override
  String get createSmsMessageLabel => 'Mensagem (opcional)';

  @override
  String get createFieldErrorRequired => 'Este campo é obrigatório.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Digite um endereço que comece com http:// ou https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Digite um endereço de e-mail válido.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Digite um número de telefone com 3 a 15 dígitos.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% da capacidade usada';
  }

  @override
  String get createCapacityOverLimit =>
      'Conteúdo demais para um código QR. Encurte para continuar.';

  @override
  String get createButtonLabel => 'Criar';

  @override
  String get createCheckingMessage =>
      'Verificando se o código é lido corretamente';

  @override
  String get createContentLabel => 'Conteúdo';

  @override
  String get createCodeImageLabel => 'O código QR criado';

  @override
  String get createCheckFailedRenderFailed =>
      'Não foi possível criar o código. Encurte o conteúdo e tente novamente.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Não foi possível verificar este código. Salvar e Compartilhar estão desativados.';

  @override
  String get createCheckFailedMismatch =>
      'Este código não corresponde ao que você digitou. Salvar e Compartilhar estão desativados.';

  @override
  String get createNotSavedToHistory =>
      'Não foi possível salvar este código no Histórico.';

  @override
  String get createSaveButton => 'Salvar';

  @override
  String get createShareButton => 'Compartilhar';

  @override
  String get createSavedSnackbarNoName => 'Código salvo';

  @override
  String createSavedSnackbar(String name) {
    return 'Salvo como $name';
  }

  @override
  String get createShareFailed =>
      'Não foi possível abrir o compartilhamento. Tente novamente.';
}
