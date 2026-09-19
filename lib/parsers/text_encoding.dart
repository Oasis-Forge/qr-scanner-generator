/// Shared, pure-Dart text handling for the encodings the parsers read:
/// the backslash-escaped `KEY:value;` records `WIFI:`, `MECARD:` and
/// `MATMSG:` all use, and the folded, `NAME;PARAM=x:value` property lines
/// vCard and iCalendar both use.
///
/// Nothing here is a public API of its own type; each function is a small,
/// well-tested building block the format parsers share so escaping rules
/// stay identical across them.
library;

/// One field of an escaped `KEY:value;KEY:value;;` record (`WIFI:`,
/// `MECARD:`, `MATMSG:`).
class EscapedField {
  const EscapedField(this.key, this.value);

  /// The field's key, exactly as encoded (callers compare case-insensitively).
  final String key;

  /// The field's value, already unescaped.
  final String value;
}

/// Splits [body] — everything after a `WIFI:`, `MECARD:` or `MATMSG:` header
/// — into its fields.
///
/// Fields are separated by `;`; a field is `key:value`. Both the field
/// separator and the key/value separator can be escaped with `\`, so
/// `\;`, `\,`, `\:`, `\"` and `\\` inside a value are read as that literal
/// character, never as a separator. A field with no unescaped `:` is
/// dropped rather than guessed at. Never throws.
List<EscapedField> parseEscapedFields(String body) {
  final List<EscapedField> fields = <EscapedField>[];
  final StringBuffer current = StringBuffer();
  for (int i = 0; i < body.length; i++) {
    final String char = body[i];
    if (char == r'\' && i + 1 < body.length) {
      current.write(char);
      current.write(body[i + 1]);
      i++;
      continue;
    }
    if (char == ';') {
      _addEscapedField(fields, current.toString());
      current.clear();
      continue;
    }
    current.write(char);
  }
  _addEscapedField(fields, current.toString());
  return fields;
}

void _addEscapedField(List<EscapedField> fields, String segment) {
  final int colon = indexOfUnescaped(segment, ':');
  if (colon == -1) {
    return;
  }
  final String key = segment.substring(0, colon);
  final String rawValue = segment.substring(colon + 1);
  fields.add(EscapedField(key, unescapeBackslashes(rawValue)));
}

/// The index of the first [target] in [text] that isn't escaped with a
/// leading `\`, or -1. Used to find the separator between a property's
/// name (and parameters) and its value, and between an escaped record's
/// fields.
int indexOfUnescaped(String text, String target) {
  for (int i = 0; i < text.length; i++) {
    final String char = text[i];
    if (char == r'\' && i + 1 < text.length) {
      i++;
      continue;
    }
    if (char == target) {
      return i;
    }
  }
  return -1;
}

/// Un-escapes `\\`, `\;`, `\,`, `\:` and `\"`: a backslash followed by any
/// character becomes that character on its own, and a trailing lone
/// backslash is dropped. Used for `WIFI:`, `MECARD:` and `MATMSG:` values.
String unescapeBackslashes(String value) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < value.length; i++) {
    final String char = value[i];
    if (char == r'\' && i + 1 < value.length) {
      out.write(value[i + 1]);
      i++;
    } else if (char != r'\') {
      out.write(char);
    }
  }
  return out.toString();
}

/// Un-escapes an iCalendar/vCard `TEXT` value (RFC 5545 §3.3.11): `\n` and
/// `\N` become a newline, `\,` and `\;` become that literal character, and
/// `\\` becomes `\`. A backslash before anything else is dropped.
String unescapeIcsText(String value) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < value.length; i++) {
    final String char = value[i];
    if (char == r'\' && i + 1 < value.length) {
      final String next = value[i + 1];
      out.write(next == 'n' || next == 'N' ? '\n' : next);
      i++;
    } else {
      out.write(char);
    }
  }
  return out.toString();
}

/// Joins folded lines back together (RFC 5545 §3.1, RFC 6350 §3.2): a line
/// that starts with a single space or tab continues the line before it,
/// with that one leading space or tab removed. Normalises `\r\n` and bare
/// `\r` to `\n` first, so every line ending vCard and iCalendar allow reads
/// the same way.
String unfoldLines(String text) {
  final String normalized = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final StringBuffer out = StringBuffer();
  bool wroteLine = false;
  for (final String line in normalized.split('\n')) {
    if (wroteLine && line.isNotEmpty && (line[0] == ' ' || line[0] == '\t')) {
      out.write(line.substring(1));
      continue;
    }
    if (wroteLine) {
      out.write('\n');
    }
    out.write(line);
    wroteLine = true;
  }
  return out.toString();
}

/// Splits [text] on every unescaped [separator] (a single character),
/// leaving the escape sequence in each piece for the caller to unescape.
/// Used for vCard's structured fields (`N`'s
/// `Family;Given;Middle;Prefix;Suffix`), where a component can itself
/// escape the separator.
List<String> splitUnescaped(String text, String separator) {
  final List<String> parts = <String>[];
  int start = 0;
  while (true) {
    final int index = indexOfUnescaped(text.substring(start), separator);
    if (index == -1) {
      parts.add(text.substring(start));
      return parts;
    }
    parts.add(text.substring(start, start + index));
    start += index + 1;
  }
}

/// One `NAME;PARAM=value;PARAM=value:VALUE` line of a vCard or iCalendar
/// property (RFC 6350, RFC 5545), split into its parts. The value is not
/// unescaped: vCard/iCalendar `TEXT` values need [unescapeIcsText], and
/// dates and other typed values need none.
class PropertyLine {
  const PropertyLine(this.name, this.params, this.value);

  /// The property name, upper-cased (`FN`, `TEL`, `DTSTART`...).
  final String name;

  /// Parameter names and values, upper-cased keys, raw values
  /// (`{'TYPE': 'HOME,VOICE'}`, `{'VALUE': 'DATE'}`, `{'TZID': 'Europe/London'}`).
  final Map<String, String> params;

  /// Everything after the first unescaped `:`, not unescaped.
  final String value;
}

/// Parses one unfolded property line, or null when it carries no unescaped
/// `:` to separate a value from its name. Never throws.
PropertyLine? parsePropertyLine(String line) {
  final int colon = indexOfUnescaped(line, ':');
  if (colon == -1) {
    return null;
  }
  final String head = line.substring(0, colon);
  final String value = line.substring(colon + 1);
  final List<String> parts = head.split(';');
  final String name = parts.first.trim().toUpperCase();
  final Map<String, String> params = <String, String>{};
  for (final String part in parts.skip(1)) {
    final int equals = part.indexOf('=');
    if (equals == -1) {
      continue;
    }
    params[part.substring(0, equals).trim().toUpperCase()] = part.substring(
      equals + 1,
    );
  }
  return PropertyLine(name, params, value);
}
