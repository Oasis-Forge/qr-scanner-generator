/// Small, shared validation and encoding helpers every generator form uses
/// (`generator_form.dart`), kept in one place so GEN-7's phone rule and the
/// `WIFI:`/`MECARD:` escaping are identical wherever a form needs them.
library;

/// GEN-7: [raw] with every space, dash, parenthesis and square bracket
/// removed, keeping a leading `+` and every digit — what a phone number
/// (Phone, SMS, Contact) actually encodes as. A `+` anywhere but the very
/// start of the trimmed input is dropped along with the other punctuation,
/// so it is never duplicated or moved.
String cleanGeneratorPhone(String raw) {
  final String trimmed = raw.trim();
  final bool hasLeadingPlus = trimmed.startsWith('+');
  final String digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return hasLeadingPlus ? '+$digits' : digits;
}

/// GEN-7: whether [raw] cleans down to an optional leading `+` and 3 to 15
/// digits. Empty input is not valid; the required field error handles that
/// case with its own message.
bool isValidGeneratorPhone(String raw) {
  final String cleaned = cleanGeneratorPhone(raw);
  final String digits = cleaned.startsWith('+')
      ? cleaned.substring(1)
      : cleaned;
  return digits.length >= 3 && digits.length <= 15;
}

/// A permissive address shape: a local part, `@`, and a domain with a dot,
/// none of them containing whitespace or another `@`. Not a full RFC 5322
/// validator — GEN-8 only asks that Create catch an address that is
/// obviously not one.
final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// GEN-8: whether [raw] (trimmed) matches [_emailPattern].
bool isValidGeneratorEmail(String raw) => _emailPattern.hasMatch(raw.trim());

/// The characters a `WIFI:` or `MECARD:` field value must escape with a
/// backslash so [parseEscapedFields] (`lib/parsers/text_encoding.dart`)
/// reads it back exactly: the record's own field (`;`) and key/value (`:`)
/// separators, a literal backslash (so an already-escaped sequence is never
/// produced by accident), a comma (kept escapable for a value that later
/// grows a comma-separated list, matching what `unescapeBackslashes`
/// already unescapes) and a double quote.
const Set<String> _wifiOrMeCardEscapedChars = <String>{
  r'\',
  ';',
  ',',
  ':',
  '"',
};

/// Escapes every character in [_wifiOrMeCardEscapedChars] in [value] with a
/// backslash — the exact inverse of `unescapeBackslashes`
/// (`lib/parsers/text_encoding.dart`), which every `WIFI:`/`MECARD:` field
/// this app generates (GEN-5, GEN-6) is read back through.
///
/// Deliberately not the `barcode` package's own `MeCard` escaping: that
/// helper escapes `;`, `:` and `"` but not a literal backslash, so a value
/// that already contains one round-trips to the wrong text through this
/// app's own parser.
String escapeGeneratorField(String value) {
  final StringBuffer out = StringBuffer();
  for (final int rune in value.runes) {
    final String char = String.fromCharCode(rune);
    if (_wifiOrMeCardEscapedChars.contains(char)) {
      out.write(r'\');
    }
    out.write(char);
  }
  return out.toString();
}
