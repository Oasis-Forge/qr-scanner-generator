import 'package:collection/collection.dart';

import 'record_enums.dart';

/// What a decoded payload actually holds, one subclass per result screen
/// (RES-4 to RES-13).
///
/// `classifyPayload` (`payload_classifier.dart`) only names the *type*; this
/// is the full parse, pulled apart into the fields each result screen shows.
/// [parsePayload] (`lib/parsers/payload_parser.dart`) builds these and never
/// throws: a payload whose header matches a type but whose body cannot be
/// read still returns that type with empty or best-effort fields, so a
/// [type] here always agrees with `classifyPayload` on the same input
/// (`payload_classifier_test.dart` checks this directly).
///
/// Pure Dart: no Flutter import, no plugin, so this and its parsers can be
/// unit tested with nothing faked.
sealed class ParsedPayload {
  const ParsedPayload();

  /// The [ParsedType] this payload's result screen is chosen from (RES-1).
  /// Matches what `classifyPayload` would return for the same input.
  ParsedType get type;
}

/// The schemes LINK-5 blocks, compared case-insensitively. A blocked link is
/// still a [Link] (LINK-1), so the result screen can say so instead of
/// falling back to text.
const Set<String> blockedLinkSchemes = <String>{
  'javascript',
  'data',
  'file',
  'intent',
  'content',
};

/// LINK-1: whether [uri] — already parsed, with a scheme — is a Link: an
/// `http`/`https` scheme with a host (userinfo and IP hosts included), or a
/// blocked scheme (LINK-5).
///
/// Shared by `classifyPayload` (`lib/models/payload_classifier.dart`) and
/// `parsePayload` (`lib/parsers/payload_parser.dart`), so the two are
/// structurally unable to disagree about what counts as a link — there is
/// still a test sweep, but it is no longer the only thing keeping them in
/// step.
bool isLinkUri(Uri uri) {
  final String scheme = uri.scheme.toLowerCase();
  if (blockedLinkSchemes.contains(scheme)) {
    return true;
  }
  return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
}

/// An `http` or `https` link, or one with a blocked scheme (LINK-1, LINK-5).
///
/// [url] is the payload exactly as decoded, never re-encoded or normalised:
/// LINK-2 shows it monospace and selectable. [uri] is [url], trimmed, parsed
/// by [Uri]; classification already proved that succeeds with an
/// `http`/`https` scheme and a host, or with a blocked scheme, for every
/// [Link] a parser builds, so [isBlocked] and [host] — both read straight off
/// [uri] — are never wrong for one. A [Link] built directly from text no
/// parser validated (a test, say) falls back to an empty [Uri] instead of
/// throwing, matching this codebase's never-throw parsers.
final class Link extends ParsedPayload {
  Link(this.url) : uri = Uri.tryParse(url.trim()) ?? Uri();

  /// The full URL as scanned.
  final String url;

  /// [url], trimmed, parsed by [Uri] (LINK-1).
  final Uri uri;

  /// Whether [uri]'s scheme is one LINK-5 blocks: the result says the link
  /// type is blocked and offers Copy only, instead of Open.
  bool get isBlocked => blockedLinkSchemes.contains(uri.scheme.toLowerCase());

  /// [uri]'s host, exactly as [Uri] reports it — the full host LINK-2
  /// emphasises until spike S11 finds a registrable-domain source. Empty
  /// when the link carries none (a blocked scheme without one).
  String get host => uri.host;

  @override
  ParsedType get type => ParsedType.url;

  @override
  bool operator ==(Object other) => other is Link && other.url == url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'Link';
}

/// A Wi-Fi network's security, as the payload's `T:` field names it.
///
/// The `WIFI:` format only ever carries these five (a bundled Android
/// "share network" QR can add `WPA3`, `GEN-5`'s own options). A `T:` field
/// this build does not recognise falls back to [wpa] when the payload also
/// carries a password, or [none] when it carries none, rather than adding a
/// sixth value no generator writes (RES-4).
enum WifiSecurity {
  /// `T:WPA` (also covers WPA2 mixed-mode networks that use this value).
  wpa,

  /// `T:WPA2`.
  wpa2,

  /// `T:SAE` (Android's Wi-Fi QR format), or `T:WPA3`.
  wpa3,

  /// `T:WEP` — RES-4 shows a line saying Android can't join WEP networks
  /// from apps.
  wep,

  /// `T:nopass`, an empty `T:` field, or no `T:` field at all, with no
  /// password.
  none,
}

/// A Wi-Fi network (RES-4). The password is a sensitive field the schema
/// flags on write (DATA-5); this parser never masks it, since the mask is a
/// display concern (`maskSensitive`, HIS-7).
///
/// Built from a `WIFI:` payload (case-insensitive header), unescaping `\\`,
/// `\;`, `\,`, `\:` and `\"` in every field. The header alone, with nothing
/// after it, still builds a [Wifi] with an empty [ssid] rather than falling
/// back to another type, so this always agrees with `classifyPayload`, which
/// classifies any `WIFI:`-prefixed payload as Wi-Fi regardless of its body.
final class Wifi extends ParsedPayload {
  const Wifi({
    required this.ssid,
    required this.security,
    this.password,
    this.hidden = false,
  });

  /// The network name (`S:`), exactly as encoded. Empty when the payload
  /// carried no `S:` field.
  final String ssid;

  /// The security type, from the `T:` field.
  final WifiSecurity security;

  /// The password (`P:`), or null for an open network or a missing field
  /// (RES-4 shows no password row for either).
  final String? password;

  /// Whether the network is hidden (`H:true`).
  final bool hidden;

  @override
  ParsedType get type => ParsedType.wifi;

  @override
  bool operator ==(Object other) =>
      other is Wifi &&
      other.ssid == ssid &&
      other.security == security &&
      other.password == password &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(ssid, security, password, hidden);

  /// Leaves the password out: nothing scanned may reach a crash report
  /// (PRIV-4, DATA-5).
  @override
  String toString() => 'Wifi(${security.name}, hidden: $hidden)';
}

/// A contact: vCard (2.1, 3.0 or 4.0) or MECARD (RES-6).
///
/// Every field is exactly as encoded: [phones] and [name] keep a leading
/// `+` (RES-6), and nothing here reformats a name, splits a phone number or
/// validates an email address. A vCard or MECARD this cannot make sense of
/// still returns a [Contact] with empty fields — its header alone decided
/// the type — rather than a different one, matching `classifyPayload`.
final class Contact extends ParsedPayload {
  const Contact({
    this.name,
    this.phones = const <String>[],
    this.emails = const <String>[],
    this.organisation,
  });

  /// `FN`, or built from `N` when there is no `FN` (vCard); `N` (MECARD).
  /// Null when the payload carried neither.
  final String? name;

  /// Every `TEL` (vCard) or `TEL` (MECARD) value, in the order they appear,
  /// a leading `+` kept (RES-6).
  final List<String> phones;

  /// Every `EMAIL` value, in the order they appear.
  final List<String> emails;

  /// `ORG` (vCard) or `ORG` (MECARD), or null.
  final String? organisation;

  static const ListEquality<String> _listEquality = ListEquality<String>();

  @override
  ParsedType get type => ParsedType.contact;

  @override
  bool operator ==(Object other) =>
      other is Contact &&
      other.name == name &&
      _listEquality.equals(other.phones, phones) &&
      _listEquality.equals(other.emails, emails) &&
      other.organisation == organisation;

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAll(phones),
    Object.hashAll(emails),
    organisation,
  );

  @override
  String toString() =>
      'Contact(${phones.length} phone(s), ${emails.length} email(s))';
}

/// An iCalendar event: a bare `VEVENT` or the first one inside a
/// `VCALENDAR` (RES-6).
///
/// [start] and [end] are kept exactly as encoded — floating local time, UTC
/// with a trailing `Z`, or a `TZID`-qualified local time — and never
/// converted, so a device time-zone change can't shift them (DATE-3).
/// [allDay] is true for a `DATE`-only start (`VALUE=DATE`, or an 8-digit
/// value with no time part). A block this cannot make sense of still
/// returns a [CalendarEvent] with empty fields, matching `classifyPayload`,
/// which classifies any `BEGIN:VEVENT` or `BEGIN:VCALENDAR` payload as an
/// event regardless of its body.
final class CalendarEvent extends ParsedPayload {
  const CalendarEvent({
    required this.title,
    required this.start,
    this.startTzid,
    this.end,
    this.endTzid,
    this.allDay = false,
    this.location,
    this.notes,
  });

  /// `SUMMARY`, unescaped. Empty when the event carried none.
  final String title;

  /// `DTSTART`'s raw value, exactly as encoded (DATE-3). Empty when the
  /// event carried no `DTSTART`.
  final String start;

  /// `DTSTART`'s `TZID` parameter, or null when the start is floating or UTC.
  final String? startTzid;

  /// `DTEND`'s raw value, exactly as encoded, or null (DATE-3).
  final String? end;

  /// `DTEND`'s `TZID` parameter, or null.
  final String? endTzid;

  /// Whether [start] (and [end], when present) is a date with no time.
  final bool allDay;

  /// `LOCATION`, unescaped, or null.
  final String? location;

  /// `DESCRIPTION`, unescaped, or null.
  final String? notes;

  @override
  ParsedType get type => ParsedType.event;

  @override
  bool operator ==(Object other) =>
      other is CalendarEvent &&
      other.title == title &&
      other.start == start &&
      other.startTzid == startTzid &&
      other.end == end &&
      other.endTzid == endTzid &&
      other.allDay == allDay &&
      other.location == location &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(
    title,
    start,
    startTzid,
    end,
    endTzid,
    allDay,
    location,
    notes,
  );

  @override
  String toString() => 'CalendarEvent(allDay: $allDay)';
}

/// A phone number (`tel:`, RES-7).
final class Phone extends ParsedPayload {
  const Phone(this.number);

  /// The number exactly as encoded, a leading `+` kept.
  final String number;

  @override
  ParsedType get type => ParsedType.phone;

  @override
  bool operator ==(Object other) => other is Phone && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Phone';
}

/// An SMS or MMS with an optional message (`SMSTO:`, `sms:`, `MMSTO:`,
/// `mms:`, RES-7).
final class Sms extends ParsedPayload {
  const Sms({required this.number, this.message});

  /// The recipient exactly as encoded, a leading `+` kept.
  final String number;

  /// The pre-filled message (`SMSTO:number:message` or `sms:number?body=`),
  /// percent-decoded for the `sms:` form, or null when there is none.
  final String? message;

  @override
  ParsedType get type => ParsedType.sms;

  @override
  bool operator ==(Object other) =>
      other is Sms && other.number == number && other.message == message;

  @override
  int get hashCode => Object.hash(number, message);

  @override
  String toString() => 'Sms';
}

/// An email (`mailto:`, `MATMSG:` or a bare address, RES-7).
final class Email extends ParsedPayload {
  const Email({required this.to, this.subject, this.body});

  /// The recipient(s), exactly as encoded (not percent-decoded: RFC 6068
  /// leaves the mailbox part unencoded).
  final String to;

  /// The `subject` query parameter, percent-decoded, or null.
  final String? subject;

  /// The `body` query parameter, percent-decoded, or null.
  final String? body;

  @override
  ParsedType get type => ParsedType.email;

  @override
  bool operator ==(Object other) =>
      other is Email &&
      other.to == to &&
      other.subject == subject &&
      other.body == body;

  @override
  int get hashCode => Object.hash(to, subject, body);

  @override
  String toString() => 'Email';
}

/// A `geo:` location (RES-8). Ships as a result screen after RES-8, but
/// parsed from v1 so History and export never need a schema change to add
/// it.
final class Location extends ParsedPayload {
  const Location({required this.latitude, required this.longitude, this.label});

  /// Decimal degrees. 0 when the coordinate could not be read.
  final double latitude;

  /// Decimal degrees. 0 when the coordinate could not be read.
  final double longitude;

  /// The `q=` query parameter's label, decoded, or null.
  final String? label;

  @override
  ParsedType get type => ParsedType.geo;

  @override
  bool operator ==(Object other) =>
      other is Location &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.label == label;

  @override
  int get hashCode => Object.hash(latitude, longitude, label);

  @override
  String toString() => 'Location';
}

/// The barcode format a [Product] carries (RES-9). ISBN is an EAN-13 whose
/// digits start `978` or `979`; every other value matches a [Symbology] of
/// the same shape.
enum ProductCodeFormat {
  /// EAN-13, and every EAN-13 the digits don't mark as [isbn].
  ean13,

  /// EAN-8.
  ean8,

  /// UPC-A.
  upcA,

  /// UPC-E.
  upcE,

  /// An EAN-13 whose digits start `978` or `979`.
  isbn,
}

/// A retail product code: EAN-13, EAN-8, UPC-A, UPC-E or ISBN (RES-9).
///
/// Only ever built once the GS1 check digit has been verified against
/// [format]'s digit count (`isValidProductCode`); a wrong check digit is not
/// a product (`lib/parsers/product_parser.dart`), and `classifyPayload`
/// shares that same check so the two can never disagree.
final class Product extends ParsedPayload {
  const Product({required this.code, required this.format});

  /// The digits exactly as scanned.
  final String code;

  /// The format the digits and symbology name.
  final ProductCodeFormat format;

  @override
  ParsedType get type => ParsedType.product;

  @override
  bool operator ==(Object other) =>
      other is Product && other.code == code && other.format == format;

  @override
  int get hashCode => Object.hash(code, format);

  @override
  String toString() => 'Product(${format.name})';
}

/// Plain text that fits no other type.
final class PlainText extends ParsedPayload {
  const PlainText(this.text);

  /// The payload exactly as decoded.
  final String text;

  @override
  ParsedType get type => ParsedType.text;

  @override
  bool operator ==(Object other) => other is PlainText && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'PlainText';
}

/// A payload that fits no type: invalid UTF-8, or empty or blank text
/// (RES-13).
///
/// [isBinary] tells the two cases apart. When it's true the result shows
/// "Binary data, N bytes" from [byteCount] instead of [text], which then
/// holds only a lossy, best-effort decoding. When it's false, [text] is the
/// exact (if empty or blank) decoded payload, and [byteCount] is its UTF-8
/// length.
final class Unknown extends ParsedPayload {
  const Unknown({
    required this.text,
    required this.isBinary,
    required this.byteCount,
  });

  /// The decoded text. Best-effort and lossy when [isBinary].
  final String text;

  /// Whether the raw bytes are not valid UTF-8.
  final bool isBinary;

  /// The raw byte count, shown as "Binary data, N bytes" when [isBinary].
  final int byteCount;

  @override
  ParsedType get type => ParsedType.unknown;

  @override
  bool operator ==(Object other) =>
      other is Unknown &&
      other.text == text &&
      other.isBinary == isBinary &&
      other.byteCount == byteCount;

  @override
  int get hashCode => Object.hash(text, isBinary, byteCount);

  @override
  String toString() => 'Unknown(isBinary: $isBinary, $byteCount bytes)';
}
