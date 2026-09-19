import '../models/record_enums.dart' show ParsedType;
import 'generator_form.dart';

/// GEN-1: the types at closed test, in the order the rule lists them — URL,
/// Text, Wi-Fi, Contact, Phone, Email, SMS — for a Create type picker to
/// show them in.
const List<ParsedType> generatorTypes = <ParsedType>[
  ParsedType.url,
  ParsedType.text,
  ParsedType.wifi,
  ParsedType.contact,
  ParsedType.phone,
  ParsedType.email,
  ParsedType.sms,
];

/// A blank [GeneratorForm] for [type] (GEN-1): what [GeneratorState.setType]
/// switches to.
///
/// Throws [ArgumentError] for a [ParsedType] outside [generatorTypes] (a
/// location, an event, a product...): none of those are a generator type at
/// closed test (GEN-1), so there is no form to build one from.
GeneratorForm emptyGeneratorForm(ParsedType type) => switch (type) {
  ParsedType.url => const UrlForm(),
  ParsedType.text => const TextForm(),
  ParsedType.wifi => const WifiForm(),
  ParsedType.contact => const ContactForm(),
  ParsedType.phone => const PhoneForm(),
  ParsedType.email => const EmailForm(),
  ParsedType.sms => const SmsForm(),
  _ => throw ArgumentError.value(
    type,
    'type',
    'is not a generator type (GEN-1)',
  ),
};
