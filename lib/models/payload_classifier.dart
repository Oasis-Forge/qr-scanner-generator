import '../parsers/product_parser.dart'
    show hasValidGtinCheckDigit, isValidProductCode;
import 'record_enums.dart';
import 'scan_record.dart';

/// Which [ParsedType] a decoded payload is, from its text and its format.
///
/// This only *classifies*: it looks at a payload's scheme or header and names
/// the result screen it belongs on (RES-4 to RES-13). It reads no fields. The
/// results PR adds the full parsers (Wi-Fi, vCard, iCalendar, `tel:`, `geo:`
/// and so on), which take the type chosen here and pull the fields out, so a
/// payload that carries a type's header but not its fields (a `WIFI:` code
/// with no network name) still opens that type's screen, which then shows the
/// raw text it could not read.
///
/// A scanned record's `parsed_type` never changes once written (REC-3), so what
/// this returns is what History shows for that record for good. It is
/// deliberately a pure function of its arguments, the same on every source:
/// camera, photo, shared image and typed entry (SCAN-12, RES-3).
///
/// The order follows LINK-1: every more specific type (RES-4 to RES-12) is
/// tried first, and only then a link, so a `mailto:` or `geo:` payload is never
/// taken for a link, and a link is never taken for text.
///
/// 1. [isBinary], or nothing but whitespace: [ParsedType.unknown] (RES-13).
/// 2. An EAN-13, EAN-8, UPC-A or UPC-E [symbology] whose check digit is
///    valid, or whose digits don't match the count that format encodes:
///    [ParsedType.product] (RES-9). ISBN is an EAN-13, so it lands here
///    too. A digit-for-digit match against the format's own length with the
///    wrong check digit is not a product (`isValidProductCode`,
///    `lib/parsers/product_parser.dart`, which the full parser shares so
///    the two can never disagree about one).
/// 3. A header, ignoring case and any leading whitespace or byte-order mark:
///    `WIFI:` is [ParsedType.wifi] (RES-4); `BEGIN:VCARD` and `MECARD:` are
///    [ParsedType.contact], `BEGIN:VEVENT` and `BEGIN:VCALENDAR` are
///    [ParsedType.event] (RES-6); `tel:` is [ParsedType.phone], `SMSTO:`,
///    `sms:`, `MMSTO:` and `mms:` are [ParsedType.sms], `mailto:` and `MATMSG:`
///    are [ParsedType.email] (RES-7); `geo:` is [ParsedType.geo] (RES-8). A
///    `tel:`, `sms:`, `mailto:` or `geo:` header with nothing after it is not
///    that type, so an empty dialer or map never opens.
/// 4. A bare email address (`name@example.com`): [ParsedType.email] (RES-7).
/// 5. What Dart's [Uri] parses with an `http` or `https` scheme and a host,
///    userinfo and IP hosts included, or with a blocked scheme (`javascript:`,
///    `data:`, `file:`, `intent:`, `content:`): [ParsedType.url] (LINK-1,
///    LINK-5). A blocked link is still a link, so its result says it is
///    blocked instead of falling back to text.
/// 6. Anything else: [ParsedType.text].
///
/// A Play Store link is a link (RES-11): it classifies as [ParsedType.url],
/// and the result screen tells it apart by its host, so every link check
/// still runs on it. [ParsedType.appStore] is the generator's type (GEN-10).
/// Payment codes (RES-10) and GS1 element strings (RES-12) have no type of
/// their own yet and classify as text.
ParsedType classifyPayload(
  String payload, {
  required Symbology symbology,
  bool isBinary = false,
}) {
  if (isBinary) {
    return ParsedType.unknown;
  }
  final String text = _withoutLeadingMark(payload).trim();
  if (text.isEmpty) {
    return ParsedType.unknown;
  }
  if (isProductSymbology(symbology) && isValidProductCode(text, symbology)) {
    return ParsedType.product;
  }
  final String upper = text.toUpperCase();
  for (final _Header header in _headers) {
    if (upper.startsWith(header.prefix) &&
        (!header.needsContent || text.length > header.prefix.length)) {
      return header.type;
    }
  }
  if (_bareEmail.hasMatch(text)) {
    return ParsedType.email;
  }
  if (_isLink(text)) {
    return ParsedType.url;
  }
  return ParsedType.text;
}

/// Whether [symbology] is a retail product code, whose result is a product
/// (RES-9) whatever digits it carries.
bool isProductSymbology(Symbology symbology) =>
    _productSymbologies.contains(symbology);

/// The stored [Symbology] for a format as the decoder names it.
///
/// `mobile_scanner`'s `BarcodeFormat` names (`qrCode`, `dataMatrix`, `upcA`,
/// `itf14` ...) and the stored ids themselves (`qr`, `data_matrix`, `upc_a`)
/// both map, ignoring case, underscores and dashes, so this reads whatever the
/// camera scanner or the image decoder reports (DATA-2, SCAN-9). Every ITF
/// variant is [Symbology.itf]. A format SCAN-9 doesn't promise (Micro QR,
/// MaxiCode, DataBar) or doesn't know is [Symbology.unknown], so a record never
/// claims a format it wasn't read in.
Symbology symbologyFromDecoderName(String name) {
  final String key = name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  return switch (key) {
    'qrcode' || 'qr' => Symbology.qr,
    'datamatrix' => Symbology.dataMatrix,
    'pdf417' => Symbology.pdf417,
    'aztec' => Symbology.aztec,
    'code128' => Symbology.code128,
    'code39' => Symbology.code39,
    'code93' => Symbology.code93,
    'codabar' => Symbology.codabar,
    'itf' || 'itf14' || 'itf2of5' || 'itf2of5withchecksum' => Symbology.itf,
    'ean13' => Symbology.ean13,
    'ean8' => Symbology.ean8,
    'upca' => Symbology.upcA,
    'upce' => Symbology.upcE,
    _ => Symbology.unknown,
  };
}

/// The format a typed entry is stored with (SCAN-12).
///
/// Typed text was read from no code, so it is [Symbology.unknown], except a
/// barcode number: 13, 12 or 8 digits whose GTIN check digit is right are
/// EAN-13, UPC-A or EAN-8, so typing the number under a barcode opens the same
/// product result as scanning it (RES-9) and matches that scan in History
/// (DATA-4). Spaces and dashes inside the number are not accepted, since the
/// stored payload has to be the number itself.
Symbology typedSymbologyOf(String typed) {
  final String digits = typed.trim();
  if (!_digitsOnly.hasMatch(digits) || !hasValidGtinCheckDigit(digits)) {
    return Symbology.unknown;
  }
  return switch (digits.length) {
    13 => Symbology.ean13,
    12 => Symbology.upcA,
    8 => Symbology.ean8,
    _ => Symbology.unknown,
  };
}

/// The fields a record of [type] must flag as sensitive when it is written
/// (DATA-5).
///
/// Every Wi-Fi record is flagged, whether or not its payload holds a password:
/// the flag can't be added after the write (REC-3), and a flag on an open
/// network masks nothing, while a missing one would show a password in
/// History rows and share previews for good (HIS-7).
List<String> sensitiveFieldsOf(ParsedType type) {
  if (type == ParsedType.wifi) {
    return const <String>[SensitiveFieldKeys.wifiPassword];
  }
  return const <String>[];
}

/// A header the payload starts with, and the type it names.
class _Header {
  const _Header(this.prefix, this.type, {this.needsContent = false});

  /// Upper case, compared against the upper-cased payload.
  final String prefix;

  final ParsedType type;

  /// Whether something must follow the header, so `tel:` alone is not a phone
  /// number.
  final bool needsContent;
}

const List<_Header> _headers = <_Header>[
  _Header('WIFI:', ParsedType.wifi),
  _Header('BEGIN:VCARD', ParsedType.contact),
  _Header('MECARD:', ParsedType.contact),
  _Header('BEGIN:VEVENT', ParsedType.event),
  _Header('BEGIN:VCALENDAR', ParsedType.event),
  _Header('TEL:', ParsedType.phone, needsContent: true),
  _Header('SMSTO:', ParsedType.sms, needsContent: true),
  _Header('SMS:', ParsedType.sms, needsContent: true),
  _Header('MMSTO:', ParsedType.sms, needsContent: true),
  _Header('MMS:', ParsedType.sms, needsContent: true),
  _Header('MAILTO:', ParsedType.email, needsContent: true),
  _Header('MATMSG:', ParsedType.email, needsContent: true),
  _Header('GEO:', ParsedType.geo, needsContent: true),
];

const Set<Symbology> _productSymbologies = <Symbology>{
  Symbology.ean13,
  Symbology.ean8,
  Symbology.upcA,
  Symbology.upcE,
};

/// The schemes LINK-5 blocks. They are still links (LINK-1), so the result
/// screen can say so.
const Set<String> _blockedSchemes = <String>{
  'javascript',
  'data',
  'file',
  'intent',
  'content',
};

/// A bare address: no scheme, no spaces, one `@`, and a domain with a dot.
///
/// A colon or slash before the `@` means a scheme or a path, which LINK-1
/// leaves to [Uri] (`https://user@host` is a link, not an address).
final RegExp _bareEmail = RegExp(r'^[^\s@:/]+@[^\s@:/]+\.[^\s@:/.]+$');

final RegExp _digitsOnly = RegExp(r'^[0-9]+$');

/// LINK-1: Dart's [Uri] decides, never a raw string match.
bool _isLink(String text) {
  final Uri? uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  final String scheme = uri.scheme.toLowerCase();
  if (_blockedSchemes.contains(scheme)) {
    return true;
  }
  return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
}

/// Drops a leading byte-order mark, which some generators put before a vCard
/// or iCalendar header.
String _withoutLeadingMark(String payload) =>
    payload.startsWith('﻿') ? payload.substring(1) : payload;

/// What stands in for a hidden secret in a one-line preview (DATA-5).
const String maskedSecret = '••••••';

/// [payload] with its sensitive fields masked, for list rows and previews
/// (DATA-5, HIS-7, SCAN-13).
///
/// Today that is a Wi-Fi password: the `P:` field of a `WIFI:` payload, up to
/// its first unescaped `;`. Every other payload comes back unchanged. The
/// stored record keeps the real value (BAK-2); only what is shown is masked.
String maskSensitive(String payload, ParsedType type) {
  if (type != ParsedType.wifi) {
    return payload;
  }
  return payload.replaceAllMapped(
    RegExp(r'((?:^|;|WIFI:)P:)((?:\\.|[^;\\])*)', caseSensitive: false),
    (Match m) =>
        m.group(2)!.isEmpty ? m.group(0)! : '${m.group(1)}$maskedSecret',
  );
}
