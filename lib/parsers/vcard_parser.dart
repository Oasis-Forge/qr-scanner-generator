import '../models/parsed_payload.dart';
import 'text_encoding.dart';

/// Parses a `BEGIN:VCARD` payload (vCard 2.1, 3.0 or 4.0) into a [Contact]
/// (RES-6).
///
/// Unfolds continuation lines, then reads `FN`, `N` (only when there is no
/// `FN`), `TEL`, `EMAIL` and `ORG` property lines, whatever their
/// parameters. Every value is exactly as encoded, a leading `+` on a `TEL`
/// kept. A card with none of these lines still returns an empty [Contact]
/// rather than falling back to another type, matching `classifyPayload`,
/// which classifies the `BEGIN:VCARD` header alone.
Contact parseVCard(String text) {
  String? fn;
  String? n;
  final List<String> phones = <String>[];
  final List<String> emails = <String>[];
  String? org;
  for (final String rawLine in unfoldLines(text).split('\n')) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final PropertyLine? property = parsePropertyLine(line);
    if (property == null) {
      continue;
    }
    switch (property.name) {
      case 'FN':
        fn = unescapeIcsText(property.value);
      case 'N':
        n = property.value;
      case 'TEL':
        phones.add(unescapeIcsText(property.value));
      case 'EMAIL':
        emails.add(unescapeIcsText(property.value));
      case 'ORG':
        org = unescapeIcsText(property.value);
    }
  }
  return Contact(
    name: fn ?? _nameFromN(n),
    phones: phones,
    emails: emails,
    organisation: org,
  );
}

/// Parses a `MECARD:` payload into a [Contact] (RES-6).
///
/// Fields: `N:` the name, `TEL:` and `EMAIL:` (repeatable) and `ORG:`,
/// escaped as [parseEscapedFields] describes. A card with none of these
/// still returns an empty [Contact], matching `classifyPayload`.
Contact parseMeCard(String body) {
  String? name;
  final List<String> phones = <String>[];
  final List<String> emails = <String>[];
  String? org;
  for (final EscapedField field in parseEscapedFields(body)) {
    switch (field.key.trim().toUpperCase()) {
      case 'N':
        name = field.value;
      case 'TEL':
        phones.add(field.value);
      case 'EMAIL':
        emails.add(field.value);
      case 'ORG':
        org = field.value;
    }
  }
  return Contact(name: name, phones: phones, emails: emails, organisation: org);
}

/// A name built from vCard's structured `N` field
/// (`Family;Given;Middle;Prefix;Suffix`) when there is no `FN`: its
/// non-empty components, in that order, joined with a space. Null when [n]
/// is null or carries nothing.
String? _nameFromN(String? n) {
  if (n == null) {
    return null;
  }
  final String joined = splitUnescaped(n, ';')
      .map((String part) => unescapeIcsText(part).trim())
      .where((String part) => part.isNotEmpty)
      .join(' ');
  return joined.isEmpty ? null : joined;
}
