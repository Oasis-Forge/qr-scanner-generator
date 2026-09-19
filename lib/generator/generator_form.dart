import '../models/parsed_payload.dart' show WifiSecurity;
import '../models/record_enums.dart' show ParsedType;
import '../models/scan_record.dart' show SensitiveFieldKeys;
import 'field_validation.dart';
import 'generator_field_error.dart';

/// One generator type's form (GEN-1): its fields, [validate]ation per type,
/// and [encode]ing to the exact payload text the app's own
/// `lib/parsers/payload_parser.dart` reads back (GEN-3 to GEN-8, checked by
/// the round-trip tests in `test/generator/generator_form_test.dart`).
///
/// Immutable, like every model in this codebase (`CLAUDE.md`): each subclass
/// carries a `copyWith`, and `GeneratorState` holds one instance and swaps it
/// for a new one on every field edit rather than mutating it in place.
sealed class GeneratorForm {
  const GeneratorForm();

  /// The [ParsedType] this form builds (GEN-1), and what `create()` stores a
  /// created code's `parsed_type` as (GEN-13).
  ParsedType get type;

  /// Field-level errors, keyed by this form's own field id (such as
  /// [WifiForm.fieldSsid]). Empty means the form may be encoded.
  Map<String, GeneratorFieldError> validate();

  /// Whether [validate] found nothing wrong.
  bool get isValid => validate().isEmpty;

  /// The payload text this form encodes to (GEN-3 to GEN-8). Only ever
  /// called once [isValid] is true — an invalid form's fields (an empty
  /// required one, say) may still produce *some* string, but it is not
  /// guaranteed to mean anything, so [GeneratorState] never calls this
  /// without checking [isValid] first.
  String encode();

  /// This form's fields, exactly as entered, for a created code's
  /// `content_json` (GEN-13). Never the encoded payload: a created record
  /// keeps the fields so a later edit (GEN-14) can refill the form.
  Map<String, Object?> toJson();

  /// SAVE-4's file name comes from one non-secret field — never a password,
  /// number, email address or message. Null for a type with no such field
  /// (Text, Phone, Email, SMS), or when the field this type does have is
  /// still empty.
  String? get nonSecretName;
}

/// URL (GEN-3): `http` and `https` only. A bare domain gets `https://`
/// added where the user can see and edit it — [normalizedInput] — and any
/// other scheme is rejected before Create enables.
final class UrlForm extends GeneratorForm {
  const UrlForm({this.rawInput = ''});

  /// Exactly what the user typed, unmodified — what the field shows and what
  /// `content_json` keeps, so a re-edit (GEN-14) sees the same text back.
  final String rawInput;

  /// The [validate] and `content_json` key for [rawInput].
  static const String fieldUrl = 'url';

  @override
  ParsedType get type => ParsedType.url;

  /// [rawInput] with `https://` added when it has no scheme at all (GEN-3):
  /// what the screen shows as the "real" address and what [encode] sends to
  /// the QR code.
  String get normalizedInput {
    final String trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    final Uri? uri = Uri.tryParse(trimmed);
    // A host with a port ("example.com:8080") parses as the scheme
    // "example.com": a real scheme has `//` after it or no dot in it.
    if (uri != null &&
        uri.hasScheme &&
        (uri.hasAuthority || !uri.scheme.contains('.'))) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  @override
  Map<String, GeneratorFieldError> validate() {
    final String normalized = normalizedInput;
    if (normalized.isEmpty) {
      return const <String, GeneratorFieldError>{
        fieldUrl: GeneratorFieldError.required,
      };
    }
    final Uri? uri = Uri.tryParse(normalized);
    final String scheme = uri?.scheme.toLowerCase() ?? '';
    final bool isHttp = scheme == 'http' || scheme == 'https';
    if (uri == null || !uri.hasScheme || uri.host.isEmpty || !isHttp) {
      return const <String, GeneratorFieldError>{
        fieldUrl: GeneratorFieldError.invalidScheme,
      };
    }
    return const <String, GeneratorFieldError>{};
  }

  @override
  String encode() => normalizedInput;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'url': rawInput};

  @override
  String? get nonSecretName {
    final String host = Uri.tryParse(normalizedInput)?.host ?? '';
    return host.isEmpty ? null : host;
  }

  UrlForm copyWith({String? rawInput}) =>
      UrlForm(rawInput: rawInput ?? this.rawInput);
}

/// Text (GEN-8): any text that fits (GEN-12), encoded as is.
final class TextForm extends GeneratorForm {
  const TextForm({this.text = ''});

  final String text;

  static const String fieldText = 'text';

  @override
  ParsedType get type => ParsedType.text;

  @override
  Map<String, GeneratorFieldError> validate() => text.trim().isEmpty
      ? const <String, GeneratorFieldError>{
          fieldText: GeneratorFieldError.required,
        }
      : const <String, GeneratorFieldError>{};

  @override
  String encode() => text;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'text': text};

  @override
  String? get nonSecretName => null;

  TextForm copyWith({String? text}) => TextForm(text: text ?? this.text);
}

/// Wi-Fi (GEN-5): network name (required); security WPA/WPA2, WPA3, WEP
/// (labelled insecure) or none; password; hidden-network switch.
final class WifiForm extends GeneratorForm {
  const WifiForm({
    this.ssid = '',
    this.security = WifiSecurity.wpa,
    this.password = '',
    this.hidden = false,
  });

  final String ssid;
  final WifiSecurity security;
  final String password;
  final bool hidden;

  static const String fieldSsid = 'ssid';

  @override
  ParsedType get type => ParsedType.wifi;

  /// Whether this network carries a password worth writing (RES-4): never
  /// for an open network, and never an empty string (DATA-5).
  bool get hasPassword => security != WifiSecurity.none && password.isNotEmpty;

  @override
  // Only-spaces is no name; the SSID itself is written exactly as typed,
  // since a network's name may start or end with a space.
  Map<String, GeneratorFieldError> validate() => ssid.trim().isEmpty
      ? const <String, GeneratorFieldError>{
          fieldSsid: GeneratorFieldError.required,
        }
      : const <String, GeneratorFieldError>{};

  @override
  String encode() {
    final StringBuffer buffer = StringBuffer('WIFI:');
    buffer.write('T:${_securityToken(security)};');
    buffer.write('S:${escapeGeneratorField(ssid)};');
    if (hasPassword) {
      buffer.write('P:${escapeGeneratorField(password)};');
    }
    if (hidden) {
      buffer.write('H:true;');
    }
    buffer.write(';');
    return buffer.toString();
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'ssid': ssid,
    'security': security.name,
    'password': password,
    'hidden': hidden,
  };

  @override
  String? get nonSecretName => ssid.isEmpty ? null : ssid;

  WifiForm copyWith({
    String? ssid,
    WifiSecurity? security,
    String? password,
    bool? hidden,
  }) => WifiForm(
    ssid: ssid ?? this.ssid,
    security: security ?? this.security,
    password: password ?? this.password,
    hidden: hidden ?? this.hidden,
  );

  // The tokens scanners read: `WPA` covers WPA and WPA2, and WPA3 is `SAE`
  // (Android's own Wi-Fi QR format). `WPA2` and `WPA3` aren't standard.
  static String _securityToken(WifiSecurity security) => switch (security) {
    WifiSecurity.wpa || WifiSecurity.wpa2 => 'WPA',
    WifiSecurity.wpa3 => 'SAE',
    WifiSecurity.wep => 'WEP',
    WifiSecurity.none => 'nopass',
  };
}

/// GEN-5's four security choices, in the order the Wi-Fi form lists them.
/// WPA2 isn't one on its own: `T:WPA` already covers it.
const List<WifiSecurity> wifiSecurityChoices = <WifiSecurity>[
  WifiSecurity.wpa,
  WifiSecurity.wpa3,
  WifiSecurity.wep,
  WifiSecurity.none,
];

/// Contact (GEN-6, closed-test fields): name (required), phone, email,
/// organisation.
///
/// Encoded as a `MECARD:` record, not a vCard: MECARD uses the same
/// backslash-escaped `KEY:value;` grammar `WIFI:` already does, so its
/// escaping is exactly [escapeGeneratorField] with no line-folding, no
/// `BEGIN:VCARD`/`VERSION`/`END:VCARD` framing and no separate `TEXT`
/// escaping rules to keep in step — the smaller, already-tested surface a
/// four-field closed-test form needs. vCard's richer structure (grouped `N`
/// components, multiple typed phones) earns its cost once GEN-6's v1 fields
/// (job title, address, website, a photo) arrive; until then MECARD reads
/// back through `lib/parsers/vcard_parser.dart`'s `parseMeCard` exactly.
final class ContactForm extends GeneratorForm {
  const ContactForm({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.organisation = '',
  });

  final String name;
  final String phone;
  final String email;
  final String organisation;

  static const String fieldName = 'name';
  static const String fieldPhone = 'phone';
  static const String fieldEmail = 'email';

  @override
  ParsedType get type => ParsedType.contact;

  @override
  Map<String, GeneratorFieldError> validate() {
    final Map<String, GeneratorFieldError> errors =
        <String, GeneratorFieldError>{};
    if (name.trim().isEmpty) {
      errors[fieldName] = GeneratorFieldError.required;
    }
    if (phone.isNotEmpty && !isValidGeneratorPhone(phone)) {
      errors[fieldPhone] = GeneratorFieldError.invalidPhone;
    }
    if (email.isNotEmpty && !isValidGeneratorEmail(email)) {
      errors[fieldEmail] = GeneratorFieldError.invalidEmail;
    }
    return errors;
  }

  @override
  String encode() {
    final StringBuffer buffer = StringBuffer('MECARD:');
    buffer.write('N:${escapeGeneratorField(name.trim())};');
    if (phone.isNotEmpty) {
      buffer.write('TEL:${escapeGeneratorField(cleanGeneratorPhone(phone))};');
    }
    if (email.isNotEmpty) {
      buffer.write('EMAIL:${escapeGeneratorField(email.trim())};');
    }
    if (organisation.isNotEmpty) {
      buffer.write('ORG:${escapeGeneratorField(organisation.trim())};');
    }
    buffer.write(';');
    return buffer.toString();
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'phone': phone,
    'email': email,
    'organisation': organisation,
  };

  @override
  String? get nonSecretName {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  ContactForm copyWith({
    String? name,
    String? phone,
    String? email,
    String? organisation,
  }) => ContactForm(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    organisation: organisation ?? this.organisation,
  );
}

/// Phone (GEN-7, GEN-8): one number, encoded as `tel:<number>`.
final class PhoneForm extends GeneratorForm {
  const PhoneForm({this.number = ''});

  final String number;

  static const String fieldNumber = 'number';

  @override
  ParsedType get type => ParsedType.phone;

  @override
  Map<String, GeneratorFieldError> validate() {
    if (number.trim().isEmpty) {
      return const <String, GeneratorFieldError>{
        fieldNumber: GeneratorFieldError.required,
      };
    }
    return isValidGeneratorPhone(number)
        ? const <String, GeneratorFieldError>{}
        : const <String, GeneratorFieldError>{
            fieldNumber: GeneratorFieldError.invalidPhone,
          };
  }

  @override
  String encode() => 'tel:${cleanGeneratorPhone(number)}';

  @override
  Map<String, Object?> toJson() => <String, Object?>{'number': number};

  @override
  String? get nonSecretName => null;

  PhoneForm copyWith({String? number}) =>
      PhoneForm(number: number ?? this.number);
}

/// Email (GEN-8): address (required and validated), with optional subject
/// and body, encoded as a `mailto:` link with percent-encoded fields.
final class EmailForm extends GeneratorForm {
  const EmailForm({this.to = '', this.subject = '', this.body = ''});

  final String to;
  final String subject;
  final String body;

  static const String fieldTo = 'to';

  @override
  ParsedType get type => ParsedType.email;

  @override
  Map<String, GeneratorFieldError> validate() {
    if (to.trim().isEmpty) {
      return const <String, GeneratorFieldError>{
        fieldTo: GeneratorFieldError.required,
      };
    }
    return isValidGeneratorEmail(to)
        ? const <String, GeneratorFieldError>{}
        : const <String, GeneratorFieldError>{
            fieldTo: GeneratorFieldError.invalidEmail,
          };
  }

  @override
  String encode() {
    final StringBuffer buffer = StringBuffer('mailto:${to.trim()}');
    final List<String> query = <String>[
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ];
    if (query.isNotEmpty) {
      buffer.write('?${query.join('&')}');
    }
    return buffer.toString();
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'to': to,
    'subject': subject,
    'body': body,
  };

  @override
  String? get nonSecretName => null;

  EmailForm copyWith({String? to, String? subject, String? body}) => EmailForm(
    to: to ?? this.to,
    subject: subject ?? this.subject,
    body: body ?? this.body,
  );
}

/// SMS (GEN-8): number and an optional message, encoded as
/// `SMSTO:<number>:<message>`.
final class SmsForm extends GeneratorForm {
  const SmsForm({this.number = '', this.message = ''});

  final String number;
  final String message;

  static const String fieldNumber = 'number';

  @override
  ParsedType get type => ParsedType.sms;

  @override
  Map<String, GeneratorFieldError> validate() {
    if (number.trim().isEmpty) {
      return const <String, GeneratorFieldError>{
        fieldNumber: GeneratorFieldError.required,
      };
    }
    return isValidGeneratorPhone(number)
        ? const <String, GeneratorFieldError>{}
        : const <String, GeneratorFieldError>{
            fieldNumber: GeneratorFieldError.invalidPhone,
          };
  }

  @override
  String encode() {
    final String cleaned = cleanGeneratorPhone(number);
    return message.isEmpty ? 'SMSTO:$cleaned' : 'SMSTO:$cleaned:$message';
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'number': number,
    'message': message,
  };

  @override
  String? get nonSecretName => null;

  SmsForm copyWith({String? number, String? message}) =>
      SmsForm(number: number ?? this.number, message: message ?? this.message);
}

/// DATA-5: the [SensitiveFieldKeys] a created code's record must flag, from
/// its form. Only a Wi-Fi form with a real password flags anything — the
/// same rule a scanned Wi-Fi payload is flagged by.
List<String> sensitiveFieldsOf(GeneratorForm form) {
  if (form is WifiForm && form.hasPassword) {
    return const <String>[SensitiveFieldKeys.wifiPassword];
  }
  return const <String>[];
}
