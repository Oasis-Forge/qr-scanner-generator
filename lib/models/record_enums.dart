/// Whether a record was scanned or created in the app.
///
/// Duplicate matching only ever compares records of the same kind, so a scan
/// and a created code carrying the same content stay two records (DATA-4).
enum RecordKind {
  /// A code the user scanned, imported or typed.
  scan('scan'),

  /// A code the user made in the generator (GEN-13).
  created('created');

  const RecordKind(this.id);

  /// The value stored in `records.kind`.
  final String id;

  /// The kind stored as [id].
  ///
  /// An ID no kind carries reads as [scan] rather than throwing, so a row
  /// written by a newer version of the app still loads (BAK-5).
  static RecordKind fromId(String? id) =>
      values.firstWhere((kind) => kind.id == id, orElse: () => scan);
}

/// Where a record came from (DATA-2).
///
/// A scanned record's source never changes, a duplicate scan included (REC-3,
/// DATA-4).
enum RecordSource {
  /// The live camera scanner (SCAN-1).
  camera('camera'),

  /// A photo the user picked from the gallery (SCAN-11).
  image('image'),

  /// An image shared into the app (ENTRY-2).
  sharedImage('shared_image'),

  /// Content the user typed by hand (SCAN-12).
  manual('manual'),

  /// A code made in the generator (GEN-13).
  created('created');

  const RecordSource(this.id);

  /// The value stored in `records.source`.
  final String id;

  /// The source stored as [id].
  ///
  /// There is no "unknown" source, so an ID no source carries reads as
  /// [camera] rather than throwing. The stored value itself is left untouched,
  /// since the DAO only ever writes the columns REC-3 allows.
  static RecordSource fromId(String? id) =>
      values.firstWhere((source) => source.id == id, orElse: () => camera);
}

/// What a payload was parsed as, which decides the result screen (RES-4 to
/// RES-13) and the History type chips (HIS-1).
enum ParsedType {
  /// An `http` or `https` link, or one with a blocked scheme (LINK-1, LINK-5).
  url('url'),

  /// A Wi-Fi network (RES-4). Its password is a sensitive field (DATA-5).
  wifi('wifi'),

  /// Plain text that fits no other type.
  text('text'),

  /// A contact: vCard or MeCard (RES-6).
  contact('contact'),

  /// A phone number (RES-7).
  phone('phone'),

  /// An email address (RES-7).
  email('email'),

  /// An SMS with an optional message (RES-7).
  sms('sms'),

  /// A `geo:` location (RES-8).
  geo('geo'),

  /// An iCalendar event (RES-6).
  event('event'),

  /// A product code: EAN, UPC or ISBN (RES-9).
  product('product'),

  /// A Play Store link (RES-11).
  appStore('app_store'),

  /// A payload that fits no type (RES-13).
  unknown('unknown');

  const ParsedType(this.id);

  /// The value stored in `records.parsed_type`.
  final String id;

  /// The type stored as [id].
  ///
  /// An ID no type carries reads as [unknown] rather than throwing, so a record
  /// written by a newer version of the app still opens (RES-13, BAK-5).
  static ParsedType fromId(String? id) =>
      values.firstWhere((type) => type.id == id, orElse: () => unknown);
}

/// The code format a record was read from or is drawn in (SCAN-9, GEN-2).
enum Symbology {
  /// QR code.
  qr('qr'),

  /// Data Matrix.
  dataMatrix('data_matrix'),

  /// PDF417.
  pdf417('pdf417'),

  /// Aztec.
  aztec('aztec'),

  /// Code 128, which also carries GS1-128 element strings (RES-12).
  code128('code128'),

  /// Code 39.
  code39('code39'),

  /// Code 93.
  code93('code93'),

  /// Codabar.
  codabar('codabar'),

  /// ITF.
  itf('itf'),

  /// EAN-13, which also covers ISBN (RES-9).
  ean13('ean13'),

  /// EAN-8.
  ean8('ean8'),

  /// UPC-A.
  upcA('upc_a'),

  /// UPC-E.
  upcE('upc_e'),

  /// A format this build cannot name.
  unknown('unknown');

  const Symbology(this.id);

  /// The value stored in `records.symbology` and `batch_staging.symbology`.
  final String id;

  /// The format stored as [id].
  ///
  /// An ID no format carries reads as [unknown] rather than throwing (BAK-5).
  static Symbology fromId(String? id) =>
      values.firstWhere((format) => format.id == id, orElse: () => unknown);
}

/// The whole UTC seconds a timestamp column stores (DATE-1).
///
/// Sub-second precision is dropped, never rounded up, so a value read back is
/// never later than the value written.
int utcSecondsOf(DateTime at) =>
    (at.toUtc().millisecondsSinceEpoch / 1000).floor();

/// The UTC timestamp stored as [seconds] (DATE-1). Screens turn it into local
/// time when they draw it (DATE-2, LANG-3).
DateTime dateTimeFromUtcSeconds(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

/// [at] in UTC with anything under a second dropped, so a record in memory
/// carries exactly the timestamp the database holds (DATE-1).
DateTime truncatedToUtcSeconds(DateTime at) =>
    dateTimeFromUtcSeconds(utcSecondsOf(at));
