import 'dart:convert';
import 'dart:typed_data';

import '../models/parsed_payload.dart';
import '../models/payload_classifier.dart' show isProductSymbology;
import '../models/record_enums.dart';
import 'icalendar_parser.dart';
import 'product_parser.dart';
import 'text_encoding.dart';
import 'vcard_parser.dart';
import 'wifi_parser.dart';

/// Parses a decoded payload into its [ParsedPayload] (RES-4 to RES-13):
/// [text] is the payload as UTF-8, [symbology] the format it was read in
/// (SCAN-9), and [isBinary] whether the raw bytes aren't valid UTF-8, in
/// which case [bytes] gives the byte count for [Unknown].
///
/// Deterministic and never throws. The type this returns always matches
/// `classifyPayload` (`lib/models/payload_classifier.dart`) for the same
/// input — the two follow the same order and the same header, email and
/// link rules, and share [isValidProductCode] for a product's check digit
/// — so a payload that fits a type's header but not its body still gets
/// that type here (an empty [Wifi], a [Contact] with no fields) instead of
/// [PlainText]. [PlainText] is the fallback only for a payload this parser
/// truly can't place, and the last-resort catch for a bug this build didn't
/// anticipate, never for a recognised header with an unreadable body.
///
/// Order, mirroring `classifyPayload` (LINK-1):
/// 1. [isBinary], or nothing but whitespace: [Unknown] (RES-13).
/// 2. A product symbology whose check digit is valid, or that doesn't match
///    the digit count [Symbology] implies: [Product] (RES-9, ISBN
///    included).
/// 3. A header, ignoring case and any leading whitespace or byte-order
///    mark: `WIFI:` → [Wifi]; `BEGIN:VCARD`/`MECARD:` → [Contact];
///    `BEGIN:VEVENT`/`BEGIN:VCALENDAR` → [CalendarEvent]; `tel:` →
///    [Phone]; `SMSTO:`/`sms:`/`MMSTO:`/`mms:` → [Sms];
///    `mailto:`/`MATMSG:` → [Email]; `geo:` → [Location]. A header that
///    needs content (everything but `WIFI:`, the vCard and iCalendar
///    headers) with nothing after it is not that type.
/// 4. A bare email address: [Email].
/// 5. What [Uri] parses with an `http`/`https` scheme and a host, or a
///    blocked scheme (`javascript:`, `data:`, `file:`, `intent:`,
///    `content:`): [Link] (LINK-1, LINK-5).
/// 6. Anything else: [PlainText].
ParsedPayload parsePayload(
  String text, {
  Uint8List? bytes,
  required Symbology symbology,
  required bool isBinary,
}) {
  if (isBinary) {
    return Unknown(
      text: text,
      isBinary: true,
      byteCount: bytes?.length ?? utf8.encode(text).length,
    );
  }
  try {
    return _parse(text, symbology: symbology);
  } on Object {
    return PlainText(text);
  }
}

ParsedPayload _parse(String payload, {required Symbology symbology}) {
  final String withoutMark = _withoutLeadingMark(payload);
  final String trimmed = withoutMark.trim();
  if (trimmed.isEmpty) {
    return Unknown(
      text: payload,
      isBinary: false,
      byteCount: utf8.encode(payload).length,
    );
  }
  if (isProductSymbology(symbology) && isValidProductCode(trimmed, symbology)) {
    return buildProduct(trimmed, symbology);
  }
  final String upper = trimmed.toUpperCase();
  for (final _Header header in _headers) {
    if (upper.startsWith(header.prefix) &&
        (!header.needsContent || trimmed.length > header.prefix.length)) {
      final String arg = header.wholeText
          ? trimmed
          : trimmed.substring(header.prefix.length);
      return header.parse(arg);
    }
  }
  if (_bareEmail.hasMatch(trimmed)) {
    return Email(to: _percentDecode(trimmed));
  }
  if (_isLink(trimmed)) {
    return Link(withoutMark);
  }
  return PlainText(payload);
}

/// A header this parser recognises, and how to build its [ParsedPayload].
class _Header {
  const _Header(
    this.prefix,
    this.parse, {
    this.needsContent = false,
    this.wholeText = false,
  });

  /// Upper case, compared against the upper-cased payload.
  final String prefix;

  /// Whether something must follow the header, so `tel:` alone is not a
  /// phone number.
  final bool needsContent;

  /// Whether [parse] takes the whole trimmed payload (vCard, iCalendar,
  /// which read line by line) rather than just what follows [prefix].
  final bool wholeText;

  final ParsedPayload Function(String text) parse;
}

/// Same order as `classifyPayload`'s own header table (LINK-1).
final List<_Header> _headers = <_Header>[
  const _Header('WIFI:', parseWifi),
  const _Header('BEGIN:VCARD', parseVCard, wholeText: true),
  const _Header('MECARD:', parseMeCard),
  const _Header('BEGIN:VEVENT', parseICalendarEvent, wholeText: true),
  const _Header('BEGIN:VCALENDAR', parseICalendarEvent, wholeText: true),
  const _Header('TEL:', Phone.new, needsContent: true),
  const _Header('SMSTO:', _parseSmsColon, needsContent: true),
  const _Header('SMS:', _parseSmsUri, needsContent: true),
  const _Header('MMSTO:', _parseSmsColon, needsContent: true),
  const _Header('MMS:', _parseSmsUri, needsContent: true),
  const _Header('MAILTO:', _parseMailto, needsContent: true),
  const _Header('MATMSG:', _parseMatMsg, needsContent: true),
  const _Header('GEO:', _parseGeo, needsContent: true),
];

/// `SMSTO:number:message` and `MMSTO:number:message` (RES-7): the message is
/// everything after the first `:` in the body, and is optional.
Sms _parseSmsColon(String body) {
  final int colon = body.indexOf(':');
  if (colon == -1) {
    return Sms(number: body);
  }
  final String message = body.substring(colon + 1);
  return Sms(
    number: body.substring(0, colon),
    message: message.isEmpty ? null : message,
  );
}

/// `sms:number?body=message` and `mms:number?body=message` (RES-7): the
/// message is the percent-decoded `body` query parameter.
Sms _parseSmsUri(String body) {
  final int question = body.indexOf('?');
  final String number = question == -1 ? body : body.substring(0, question);
  String? message;
  if (question != -1) {
    for (final MapEntry<String, String> pair in _queryPairs(
      body.substring(question + 1),
    )) {
      if (pair.key.toLowerCase() == 'body') {
        message = _percentDecode(pair.value);
      }
    }
  }
  return Sms(number: number, message: message);
}

/// `mailto:to@example.com?subject=...&body=...` (RES-7), every field
/// percent-decoded.
Email _parseMailto(String body) {
  final int question = body.indexOf('?');
  final String to = question == -1 ? body : body.substring(0, question);
  String? subject;
  String? emailBody;
  if (question != -1) {
    for (final MapEntry<String, String> pair in _queryPairs(
      body.substring(question + 1),
    )) {
      switch (pair.key.toLowerCase()) {
        case 'subject':
          subject = _percentDecode(pair.value);
        case 'body':
          emailBody = _percentDecode(pair.value);
      }
    }
  }
  return Email(to: _percentDecode(to), subject: subject, body: emailBody);
}

/// `MATMSG:TO:to@example.com;SUB:subject;BODY:body;;` (RES-7).
Email _parseMatMsg(String body) {
  String? to;
  String? subject;
  String? emailBody;
  for (final EscapedField field in parseEscapedFields(body)) {
    switch (field.key.trim().toUpperCase()) {
      case 'TO':
        to = field.value;
      case 'SUB':
        subject = field.value;
      case 'BODY':
        emailBody = field.value;
    }
  }
  return Email(to: to ?? '', subject: subject, body: emailBody);
}

/// `geo:lat,lon` with an optional `?q=` label (RES-8), Android's own
/// convention for a trailing `(label)` on the `q` value read out of it.
Location _parseGeo(String body) {
  final int question = body.indexOf('?');
  final String coords = question == -1 ? body : body.substring(0, question);
  final List<String> parts = coords.split(',');
  final double latitude = parts.isNotEmpty
      ? double.tryParse(parts[0].trim()) ?? 0
      : 0;
  final double longitude = parts.length > 1
      ? double.tryParse(parts[1].trim()) ?? 0
      : 0;
  String? label;
  if (question != -1) {
    for (final MapEntry<String, String> pair in _queryPairs(
      body.substring(question + 1),
    )) {
      if (pair.key.toLowerCase() == 'q') {
        label = _geoLabelFrom(_percentDecode(pair.value));
      }
    }
  }
  return Location(latitude: latitude, longitude: longitude, label: label);
}

final RegExp _parenthesised = RegExp(r'\(([^)]*)\)\s*$');

String? _geoLabelFrom(String q) {
  final String label = (_parenthesised.firstMatch(q)?.group(1) ?? q).trim();
  return label.isEmpty ? null : label;
}

/// `key=value` pairs of a `?`-less query string, split on `&`. A pair with
/// no `=` is skipped.
Iterable<MapEntry<String, String>> _queryPairs(String query) sync* {
  for (final String pair in query.split('&')) {
    final int equals = pair.indexOf('=');
    if (equals == -1) {
      continue;
    }
    yield MapEntry<String, String>(
      pair.substring(0, equals),
      pair.substring(equals + 1),
    );
  }
}

/// Percent-decodes [value], or returns it unchanged when it isn't valid
/// percent-encoding. Never throws.
String _percentDecode(String value) {
  try {
    return Uri.decodeComponent(value);
  } on Object {
    return value;
  }
}

/// Drops a leading byte-order mark, which some generators put before a
/// vCard or iCalendar header.
String _withoutLeadingMark(String payload) =>
    payload.startsWith('﻿') ? payload.substring(1) : payload;

/// A bare address: no scheme, no spaces, one `@`, and a domain with a dot.
final RegExp _bareEmail = RegExp(r'^[^\s@:/]+@[^\s@:/]+\.[^\s@:/.]+$');

/// LINK-1: [Uri] decides, never a raw string match. [isLinkUri]
/// (`lib/models/parsed_payload.dart`) is shared with `classifyPayload`.
bool _isLink(String text) {
  final Uri? uri = Uri.tryParse(text);
  return uri != null && uri.hasScheme && isLinkUri(uri);
}
