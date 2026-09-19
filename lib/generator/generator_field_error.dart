/// What is wrong with one field of a generator form (GEN-1).
///
/// [GeneratorForm.validate] keys these by the field's own id constant (such
/// as `WifiForm.fieldSsid`), never by a localised message: the generator
/// screen — not this package — turns a code into the text `AppLocalizations`
/// carries for it, so this stays plain Dart with no message strings of its
/// own to keep in sync with `lib/l10n/`.
enum GeneratorFieldError {
  /// The field is empty and must not be: a Wi-Fi network name (GEN-5), a
  /// contact's name (GEN-6), a phone number (GEN-7), an email address or an
  /// SMS number (GEN-8).
  required,

  /// GEN-3: the URL field's normalised input has no `http`/`https` scheme,
  /// or isn't a URL at all.
  invalidScheme,

  /// GEN-8: not a validated email address.
  invalidEmail,

  /// GEN-7: not an optional leading `+` followed by 3 to 15 digits.
  invalidPhone,
}
