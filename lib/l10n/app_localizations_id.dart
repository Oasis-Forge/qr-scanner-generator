// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'QR Scanner + Generator';

  @override
  String get navScan => 'Pindai';

  @override
  String get navCreate => 'Buat';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get cameraPermissionReason =>
      'Kamera hanya dipakai untuk membaca kode di perangkat ini.';

  @override
  String get cameraAllowButton => 'Izinkan kamera';

  @override
  String get cameraOpenSettingsButton => 'Buka pengaturan';

  @override
  String get scanFromPhotoButton => 'Pindai foto';

  @override
  String get typeCodeButton => 'Ketik kode';

  @override
  String get placeholderCreateMessage =>
      'Pembuatan kode hadir di versi uji berikutnya.';

  @override
  String get placeholderHistoryMessage =>
      'Daftar Riwayat hadir di versi uji berikutnya. Pemindaian Anda sudah tersimpan di ponsel ini.';

  @override
  String get scanReadyStatus => 'Siap';

  @override
  String get scanTargetHint => 'Arahkan kamera ke kode';

  @override
  String get scanCameraUnavailable =>
      'Kamera tidak dapat dimulai. Aplikasi lain mungkin sedang memakainya.';

  @override
  String get scanTorchOn => 'Nyalakan senter';

  @override
  String get scanTorchOff => 'Matikan senter';

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
  String get scanReadingPhoto => 'Membaca foto';

  @override
  String get scanPhotoPickerFailed => 'Pemilih foto tidak terbuka. Coba lagi.';

  @override
  String get scanSettingsDidNotOpen =>
      'Pengaturan tidak terbuka. Izinkan kamera dari pengaturan ponsel Anda.';

  @override
  String scanDetectedAnnouncement(String format, String type) {
    return '$format terdeteksi: $type';
  }

  @override
  String scanTypeDetectedAnnouncement(String type) {
    return '$type terdeteksi';
  }

  @override
  String scanChoicesAnnouncement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kode terdeteksi',
    );
    return '$_temp0';
  }

  @override
  String scanChoicesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kode ditemukan',
    );
    return '$_temp0';
  }

  @override
  String get scanChoicesHint => 'Pilih kode yang akan dibuka.';

  @override
  String scanBinaryData(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Data biner, $count byte',
    );
    return '$_temp0';
  }

  @override
  String get noCodeFoundTitle => 'Kode tidak ditemukan';

  @override
  String get noCodeFoundHint =>
      'Pastikan seluruh kode ada di foto, tajam dan cukup terang.';

  @override
  String get tryAnotherPhotoButton => 'Coba foto lain';

  @override
  String get actionClose => 'Tutup';

  @override
  String get manualEntryTitle => 'Ketik kode';

  @override
  String get manualEntryFieldLabel => 'Isi kode';

  @override
  String get manualEntryFieldHint => 'Tautan, teks, atau nomor barcode';

  @override
  String get manualEntryScanButton => 'Pindai';

  @override
  String get settingsGroupGeneral => 'Umum';

  @override
  String get settingsGroupPrivacy => 'Privasi';

  @override
  String get settingsGroupPro => 'Pro';

  @override
  String get settingsGroupAbout => 'Tentang';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsSoundOnScan => 'Suara saat memindai';

  @override
  String get settingsVibrateOnScan => 'Getar saat memindai';

  @override
  String get settingsCopyOnScan => 'Salin saat memindai';

  @override
  String get settingsSearchEngine => 'Mesin pencari';

  @override
  String get settingsSaveHistory => 'Simpan riwayat';

  @override
  String get settingsSendCrashReports => 'Kirim laporan kerusakan';

  @override
  String get settingsPrivacyOptions => 'Opsi privasi';

  @override
  String get settingsRemoveAds => 'Hapus iklan';

  @override
  String get settingsRemoveAdsSubtitle => 'Pembelian sekali bayar';

  @override
  String get settingsRestorePurchase => 'Pulihkan pembelian';

  @override
  String settingsRemoveAdsPrice(String price) {
    return 'Pembelian sekali bayar · $price';
  }

  @override
  String get settingsProOwned => 'Iklan dihapus';

  @override
  String get proBuyFailed => 'Pembelian tidak dapat diselesaikan. Coba lagi.';

  @override
  String get proRestoreSuccess => 'Pembelian dipulihkan.';

  @override
  String get proRestoreNotFound => 'Tidak ada pembelian sebelumnya.';

  @override
  String get proRestoreFailed => 'Tidak dapat memeriksa toko. Coba lagi.';

  @override
  String get proPromptTitle => 'Hapus iklan?';

  @override
  String get proPromptBody => 'Pembelian sekali bayar, bukan langganan.';

  @override
  String get proPromptDismissTooltip => 'Tutup';

  @override
  String get settingsFeedback => 'Masukan';

  @override
  String get settingsPrivacyPolicy => 'Kebijakan privasi';

  @override
  String get settingsOpenSourceLicences => 'Lisensi sumber terbuka';

  @override
  String get settingsVersion => 'Versi';

  @override
  String settingsVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String get settingsLinkOpenFailed => 'Tautan tidak dapat dibuka.';

  @override
  String get feedbackCategoryLabel => 'Kategori';

  @override
  String get feedbackCategoryScanning => 'Pemindaian';

  @override
  String get feedbackCategoryResults => 'Hasil';

  @override
  String get feedbackCategoryCreatingCodes => 'Pembuatan kode';

  @override
  String get feedbackCategoryAds => 'Iklan';

  @override
  String get feedbackCategoryOther => 'Lainnya';

  @override
  String get feedbackMessageHint =>
      'Apa yang terjadi, dan apa yang Anda harapkan?';

  @override
  String get feedbackSendButton => 'Kirim';

  @override
  String get feedbackSendNoHandler =>
      'Tidak ada aplikasi email di perangkat ini.';

  @override
  String feedbackEmailSubject(
    String appTitle,
    String version,
    String build,
    String androidVersion,
  ) {
    return 'Masukan $appTitle ($version+$build, $androidVersion)';
  }

  @override
  String get themeSystemDefault => 'Bawaan sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get languageSystemDefault => 'Bawaan sistem';

  @override
  String get historyHeaderToday => 'Hari ini';

  @override
  String get historyHeaderYesterday => 'Kemarin';

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
      other: '$count kode',
      zero: 'Tidak ada kode',
    );
    return '$_temp0';
  }

  @override
  String get historySegmentAll => 'Semua';

  @override
  String get historySegmentScanned => 'Dipindai';

  @override
  String get historySegmentCreated => 'Dibuat';

  @override
  String get historyEmptyMessage =>
      'Kode yang Anda pindai atau buat akan muncul di sini.';

  @override
  String get historyEmptyScanButton => 'Pindai kode';

  @override
  String get historyEmptyCreateButton => 'Buat kode';

  @override
  String get historyEmptyNotSavingMessage => 'Pemindaian baru tidak disimpan.';

  @override
  String get historyEmptySettingsButton => 'Buka Pengaturan';

  @override
  String get historyLoading => 'Memuat Riwayat';

  @override
  String historyDeletedSnackbar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dihapus',
    );
    return '$_temp0';
  }

  @override
  String get historyUndoButton => 'Urungkan';

  @override
  String get historyDeleteFailed => 'Tidak dapat menghapus. Coba lagi.';

  @override
  String get historyUndoFailed => 'Tidak dapat mengurungkan. Coba lagi.';

  @override
  String get historyLoadFailed => 'Riwayat tidak dapat dimuat. Coba lagi.';

  @override
  String historySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
    );
    return '$_temp0';
  }

  @override
  String get historyDeleteSelectedButton => 'Hapus';

  @override
  String get historyCancelSelectionButton => 'Batalkan pilihan';

  @override
  String copiedSnackbar(String what) {
    return '$what disalin';
  }

  @override
  String get copiedWhatLink => 'Tautan';

  @override
  String get copiedWhatContent => 'Isi';

  @override
  String get resultTitle => 'Hasil';

  @override
  String resultTypeAndFormat(String type, String format) {
    return '$type · $format';
  }

  @override
  String get resultCopyButton => 'Salin';

  @override
  String get resultShareButton => 'Bagikan';

  @override
  String get resultNotSaved =>
      'Pemindaian ini tidak dapat disimpan ke Riwayat.';

  @override
  String get resultCopyFailed => 'Tidak dapat menyalin. Coba lagi.';

  @override
  String get resultShareFailed =>
      'Tidak dapat membuka fitur berbagi. Coba lagi.';

  @override
  String get parsedTypeUrl => 'Tautan';

  @override
  String get parsedTypeWifi => 'Wi-Fi';

  @override
  String get parsedTypeText => 'Teks';

  @override
  String get parsedTypeContact => 'Kontak';

  @override
  String get parsedTypePhone => 'Nomor telepon';

  @override
  String get parsedTypeEmail => 'Email';

  @override
  String get parsedTypeSms => 'SMS';

  @override
  String get parsedTypeGeo => 'Lokasi';

  @override
  String get parsedTypeEvent => 'Acara';

  @override
  String get parsedTypeProduct => 'Produk';

  @override
  String get parsedTypeAppStore => 'Aplikasi';

  @override
  String get parsedTypeUnknown => 'Tidak dikenal';

  @override
  String get symbologyQr => 'Kode QR';

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
  String get symbologyUnknown => 'Format tidak dikenal';

  @override
  String get errorStorageUnavailable =>
      'Aplikasi tidak dapat membuka penyimpanannya. Tutup lalu buka lagi.';

  @override
  String get errorSaveFailed => 'Tidak ada yang tersimpan. Coba lagi.';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get copiedWhatPassword => 'Kata sandi';

  @override
  String get resultHandOffFailed => 'Tidak dapat membuka. Coba lagi.';

  @override
  String get resultUnavailableWifiSettings =>
      'Pengaturan Wi-Fi tidak dapat dibuka di perangkat ini.';

  @override
  String get resultUnavailableContacts =>
      'Tidak ada aplikasi kontak yang terpasang.';

  @override
  String get resultUnavailableCalendar =>
      'Tidak ada aplikasi kalender yang terpasang.';

  @override
  String get resultUnavailableDialer =>
      'Tidak ada aplikasi telepon yang terpasang.';

  @override
  String get resultUnavailableSms => 'Tidak ada aplikasi pesan yang terpasang.';

  @override
  String get resultUnavailableEmail =>
      'Tidak ada aplikasi email yang terpasang.';

  @override
  String get resultUnavailableBrowser => 'Tidak ada peramban yang terpasang.';

  @override
  String get resultLinkOpenButton => 'Buka';

  @override
  String get resultLinkReviewButton => 'Periksa';

  @override
  String get resultLinkWarningTitle => 'Sebelum Anda membuka tautan ini';

  @override
  String get resultLinkCheckIpAddressHost =>
      'Alamatnya berupa nomor IP, bukan nama';

  @override
  String get resultLinkCheckUserinfo => 'Ada nama pengguna sebelum nama situs';

  @override
  String get resultLinkCheckInsecureScheme => 'Tidak terenkripsi (http)';

  @override
  String get resultLinkCheckNonDefaultPort => 'Memakai port yang tidak biasa';

  @override
  String get resultLinkCheckLongUrl => 'Panjangnya tidak biasa';

  @override
  String get resultLinkCopyWithoutOpeningButton => 'Salin tanpa membuka';

  @override
  String get resultLinkOpenAnywayButton => 'Tetap buka';

  @override
  String resultLinkBlockedNotice(String scheme) {
    return 'Tautan $scheme tidak dapat dibuka di sini.';
  }

  @override
  String get resultLinkCalloutMessage =>
      'Aplikasi ini memeriksa tautan sebelum membukanya, jadi Anda bisa melihat dulu ke mana tautan itu menuju.';

  @override
  String get resultLinkCalloutDismissTooltip => 'Tutup';

  @override
  String get resultWifiNetworkNameLabel => 'Nama jaringan';

  @override
  String get resultWifiSecurityLabel => 'Keamanan';

  @override
  String get resultWifiPasswordLabel => 'Kata sandi';

  @override
  String get resultWifiRevealPasswordTooltip => 'Tampilkan kata sandi';

  @override
  String get resultWifiHidePasswordTooltip => 'Sembunyikan kata sandi';

  @override
  String get resultWifiWepNotice =>
      'Android tidak dapat menyambung ke jaringan WEP dari aplikasi.';

  @override
  String get resultWifiPrimaryButton => 'Buka pengaturan Wi-Fi';

  @override
  String get resultWifiCopyPasswordButton => 'Salin kata sandi';

  @override
  String get resultWifiSecurityWpa => 'WPA';

  @override
  String get resultWifiSecurityWpa2 => 'WPA2';

  @override
  String get resultWifiSecurityWpa3 => 'WPA3';

  @override
  String get resultWifiSecurityWep => 'WEP';

  @override
  String get resultWifiSecurityNone => 'Terbuka';

  @override
  String get resultContactNameLabel => 'Nama';

  @override
  String get resultContactPhoneLabel => 'Telepon';

  @override
  String get resultContactEmailLabel => 'Email';

  @override
  String get resultContactOrganisationLabel => 'Organisasi';

  @override
  String get resultContactPrimaryButton => 'Tambah ke kontak';

  @override
  String get resultEventTitleLabel => 'Judul';

  @override
  String get resultEventStartLabel => 'Mulai';

  @override
  String get resultEventEndLabel => 'Selesai';

  @override
  String get resultEventLocationLabel => 'Lokasi';

  @override
  String get resultEventNotesLabel => 'Catatan';

  @override
  String get resultEventAllDayNotice => 'Acara sepanjang hari.';

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
      'Acara ini tidak punya waktu mulai, jadi tidak dapat ditambahkan.';

  @override
  String get resultEventPrimaryButton => 'Tambah ke kalender';

  @override
  String get resultPhoneNumberLabel => 'Nomor';

  @override
  String get resultPhonePrimaryButton => 'Telepon';

  @override
  String get resultSmsNumberLabel => 'Nomor';

  @override
  String get resultSmsMessageLabel => 'Pesan';

  @override
  String get resultSmsPrimaryButton => 'Kirim pesan';

  @override
  String get resultEmailToLabel => 'Kepada';

  @override
  String get resultEmailSubjectLabel => 'Subjek';

  @override
  String get resultEmailBodyLabel => 'Pesan';

  @override
  String get resultEmailPrimaryButton => 'Email';

  @override
  String get resultProductNumberLabel => 'Nomor';

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
  String get resultProductSearchButton => 'Cari di web';

  @override
  String get resultLocationLatitudeLabel => 'Lintang';

  @override
  String get resultLocationLongitudeLabel => 'Bujur';

  @override
  String get resultLocationNameLabel => 'Nama';

  @override
  String get createSubtitle => 'Pilih apa yang akan dibuat';

  @override
  String get createUrlFieldLabel => 'Alamat web';

  @override
  String get createUrlFieldHint => 'example.com';

  @override
  String createUrlHelperText(String url) {
    return 'Kode ini membuka $url';
  }

  @override
  String get createTextFieldLabel => 'Teks';

  @override
  String get createTextFieldHint => 'Apa pun yang ingin disampaikan kode ini';

  @override
  String get createWifiSsidLabel => 'Nama jaringan';

  @override
  String get createWifiSecurityLabel => 'Keamanan';

  @override
  String get createWifiSecurityWpaWpa2 => 'WPA/WPA2';

  @override
  String get createWifiSecurityWepInsecure => 'WEP (tidak aman)';

  @override
  String get createWifiPasswordLabel => 'Kata sandi';

  @override
  String get createWifiHiddenLabel => 'Jaringan tersembunyi';

  @override
  String get createContactNameLabel => 'Nama';

  @override
  String get createContactPhoneLabel => 'Telepon (opsional)';

  @override
  String get createContactEmailLabel => 'Email (opsional)';

  @override
  String get createContactOrganisationLabel => 'Organisasi (opsional)';

  @override
  String get createPhoneFieldLabel => 'Nomor telepon';

  @override
  String get createEmailToLabel => 'Alamat email';

  @override
  String get createEmailSubjectLabel => 'Subjek (opsional)';

  @override
  String get createEmailBodyLabel => 'Pesan (opsional)';

  @override
  String get createSmsNumberLabel => 'Nomor telepon';

  @override
  String get createSmsMessageLabel => 'Pesan (opsional)';

  @override
  String get createFieldErrorRequired => 'Kolom ini wajib diisi.';

  @override
  String get createFieldErrorInvalidUrl =>
      'Masukkan alamat web yang diawali http:// atau https://.';

  @override
  String get createFieldErrorInvalidEmail =>
      'Masukkan alamat email yang valid.';

  @override
  String get createFieldErrorInvalidPhone =>
      'Masukkan nomor telepon dengan 3 sampai 15 digit.';

  @override
  String createCapacityMeterLabel(int percent) {
    return '$percent% kapasitas terpakai';
  }

  @override
  String get createCapacityOverLimit =>
      'Isinya terlalu banyak untuk kode QR. Perpendek untuk melanjutkan.';

  @override
  String get createButtonLabel => 'Buat';

  @override
  String get createCheckingMessage =>
      'Memeriksa bahwa kode dapat dipindai dengan benar';

  @override
  String get createContentLabel => 'Isi';

  @override
  String get createCodeImageLabel => 'Kode QR yang dibuat';

  @override
  String get createCheckFailedRenderFailed =>
      'Kode tidak dapat dibuat. Perpendek isinya lalu coba lagi.';

  @override
  String get createCheckFailedDecodeFailed =>
      'Kode ini tidak dapat diperiksa. Simpan dan Bagikan dimatikan.';

  @override
  String get createCheckFailedMismatch =>
      'Kode ini tidak cocok dengan yang Anda masukkan. Simpan dan Bagikan dimatikan.';

  @override
  String get createNotSavedToHistory =>
      'Kode ini tidak dapat disimpan ke Riwayat.';

  @override
  String get createSaveButton => 'Simpan';

  @override
  String get createShareButton => 'Bagikan';

  @override
  String get createSavedSnackbarNoName => 'Kode disimpan';

  @override
  String createSavedSnackbar(String name) {
    return 'Disimpan sebagai $name';
  }

  @override
  String get createShareFailed =>
      'Tidak dapat membuka fitur berbagi. Coba lagi.';
}
