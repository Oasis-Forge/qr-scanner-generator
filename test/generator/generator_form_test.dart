import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/generator_field_error.dart';
import 'package:qrscanner/generator/generator_form.dart';
import 'package:qrscanner/generator/generator_types.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/parsers/payload_parser.dart';

/// Parses [payload] the way a scan of it would be (SCAN-9's QR symbology),
/// so a round-trip test reads through the app's own parser, not a private
/// helper of its own.
ParsedPayload _reparse(String payload) =>
    parsePayload(payload, symbology: Symbology.qr, isBinary: false);

void main() {
  group('GEN-1: generatorTypes and emptyGeneratorForm', () {
    test('closed test order: URL, Text, Wi-Fi, Contact, Phone, Email, SMS', () {
      expect(generatorTypes, <ParsedType>[
        ParsedType.url,
        ParsedType.text,
        ParsedType.wifi,
        ParsedType.contact,
        ParsedType.phone,
        ParsedType.email,
        ParsedType.sms,
      ]);
    });

    test('every generator type has a blank form of its own type', () {
      for (final ParsedType type in generatorTypes) {
        expect(emptyGeneratorForm(type).type, type);
      }
    });

    test('a type outside GEN-1 has no form', () {
      expect(() => emptyGeneratorForm(ParsedType.geo), throwsArgumentError);
    });
  });

  group('URL (GEN-3)', () {
    test('empty input is required', () {
      expect(const UrlForm().validate(), <String, GeneratorFieldError>{
        UrlForm.fieldUrl: GeneratorFieldError.required,
      });
    });

    test('a bare domain gets https:// added, visibly', () {
      const UrlForm form = UrlForm(rawInput: 'example.com');
      expect(form.normalizedInput, 'https://example.com');
      expect(form.isValid, isTrue);
      expect(form.encode(), 'https://example.com');
    });

    test('an explicit http:// URL is kept as http (never upgraded)', () {
      const UrlForm form = UrlForm(rawInput: 'http://example.com');
      expect(form.normalizedInput, 'http://example.com');
      expect(form.isValid, isTrue);
    });

    test('an explicit https:// URL is kept as is', () {
      const UrlForm form = UrlForm(rawInput: 'https://example.com/path?q=1');
      expect(form.normalizedInput, 'https://example.com/path?q=1');
      expect(form.encode(), 'https://example.com/path?q=1');
    });

    test('any other scheme is rejected before Create enables', () {
      const UrlForm form = UrlForm(rawInput: 'ftp://example.com');
      expect(form.validate(), <String, GeneratorFieldError>{
        UrlForm.fieldUrl: GeneratorFieldError.invalidScheme,
      });
      expect(form.isValid, isFalse);
    });

    test('javascript: is rejected the same way', () {
      const UrlForm form = UrlForm(rawInput: 'javascript:alert(1)');
      expect(form.validate(), <String, GeneratorFieldError>{
        UrlForm.fieldUrl: GeneratorFieldError.invalidScheme,
      });
    });

    test('the file name comes from the host', () {
      const UrlForm form = UrlForm(rawInput: 'example.com/path');
      expect(form.nonSecretName, 'example.com');
    });

    test('round-trips through the parser as a Link', () {
      const UrlForm form = UrlForm(rawInput: 'example.com/path');
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<Link>());
      expect((parsed as Link).url, 'https://example.com/path');
    });

    test('toJson keeps the raw input, not the normalised one', () {
      const UrlForm form = UrlForm(rawInput: 'example.com');
      expect(form.toJson(), <String, Object?>{'url': 'example.com'});
    });
  });

  group('Text (GEN-8)', () {
    test('empty text is required', () {
      expect(const TextForm().validate(), <String, GeneratorFieldError>{
        TextForm.fieldText: GeneratorFieldError.required,
      });
    });

    test('has no non-secret field for SAVE-4', () {
      expect(const TextForm(text: 'hello').nonSecretName, isNull);
    });

    test('round-trips as plain text, unmodified', () {
      const TextForm form = TextForm(text: 'just some notes, and a colon: ok');
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<PlainText>());
      expect((parsed as PlainText).text, form.text);
    });

    test('Arabic text round-trips unmodified', () {
      const TextForm form = TextForm(text: 'مرحبا بالعالم');
      final ParsedPayload parsed = _reparse(form.encode());
      expect((parsed as PlainText).text, form.text);
    });
  });

  group('Wi-Fi (GEN-5)', () {
    test('empty SSID is required', () {
      expect(const WifiForm().validate(), <String, GeneratorFieldError>{
        WifiForm.fieldSsid: GeneratorFieldError.required,
      });
    });

    test('a hidden WPA/WPA2 network round-trips every field', () {
      const WifiForm form = WifiForm(
        ssid: 'Home Network',
        password: 'secret123',
        hidden: true,
      );
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<Wifi>());
      final Wifi wifi = parsed as Wifi;
      expect(wifi.ssid, 'Home Network');
      expect(wifi.security, WifiSecurity.wpa);
      expect(wifi.password, 'secret123');
      expect(wifi.hidden, isTrue);
    });

    for (final WifiSecurity security in wifiSecurityChoices) {
      test('${security.name} round-trips as itself', () {
        final WifiForm form = WifiForm(
          ssid: 'Net',
          security: security,
          password: security == WifiSecurity.none ? '' : 'p4ss',
        );
        final Wifi wifi = _reparse(form.encode()) as Wifi;
        expect(wifi.security, security);
      });
    }

    test('an open network never writes a password field (RES-4, DATA-5)', () {
      const WifiForm form = WifiForm(
        ssid: 'Free Wifi',
        security: WifiSecurity.none,
        password: 'leftover',
      );
      expect(form.hasPassword, isFalse);
      expect(form.encode(), isNot(contains('P:')));
      final Wifi wifi = _reparse(form.encode()) as Wifi;
      expect(wifi.password, isNull);
    });

    test('every escaped character round-trips in the SSID and password', () {
      const WifiForm form = WifiForm(
        ssid: r'a;b,c:d"e\f',
        security: WifiSecurity.wpa,
        password: r'p;w,d:"\end',
      );
      final Wifi wifi = _reparse(form.encode()) as Wifi;
      expect(wifi.ssid, form.ssid);
      expect(wifi.password, form.password);
    });

    test('the file name comes from the SSID, never the password', () {
      const WifiForm form = WifiForm(ssid: 'My Network', password: 'secret');
      expect(form.nonSecretName, 'My Network');
    });

    test('flags the password as sensitive only when there is one (DATA-5)', () {
      expect(
        sensitiveFieldsOf(const WifiForm(ssid: 'a', password: 'p')),
        <String>['wifi.password'],
      );
      expect(
        sensitiveFieldsOf(
          const WifiForm(ssid: 'a', security: WifiSecurity.none),
        ),
        isEmpty,
      );
      expect(sensitiveFieldsOf(const WifiForm(ssid: 'a')), isEmpty);
    });
  });

  group('Contact (GEN-6, closed-test fields)', () {
    test('empty name is required', () {
      expect(const ContactForm().validate(), <String, GeneratorFieldError>{
        ContactForm.fieldName: GeneratorFieldError.required,
      });
    });

    test('every field round-trips as a MECARD contact', () {
      const ContactForm form = ContactForm(
        name: 'Ada Lovelace',
        phone: '+1 (202) 555-0102',
        email: 'ada@example.com',
        organisation: 'Analytical Engines Ltd',
      );
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<Contact>());
      final Contact contact = parsed as Contact;
      expect(contact.name, 'Ada Lovelace');
      expect(contact.phones, <String>['+12025550102']);
      expect(contact.emails, <String>['ada@example.com']);
      expect(contact.organisation, 'Analytical Engines Ltd');
    });

    test('only the name is required; the rest may be left out', () {
      const ContactForm form = ContactForm(name: 'Ada');
      final Contact contact = _reparse(form.encode()) as Contact;
      expect(contact.name, 'Ada');
      expect(contact.phones, isEmpty);
      expect(contact.emails, isEmpty);
      expect(contact.organisation, isNull);
    });

    test('an invalid phone blocks Create without touching the name error', () {
      const ContactForm form = ContactForm(name: 'Ada', phone: 'ab');
      expect(form.validate(), <String, GeneratorFieldError>{
        ContactForm.fieldPhone: GeneratorFieldError.invalidPhone,
      });
    });

    test('an invalid email blocks Create', () {
      const ContactForm form = ContactForm(name: 'Ada', email: 'not-an-email');
      expect(form.validate(), <String, GeneratorFieldError>{
        ContactForm.fieldEmail: GeneratorFieldError.invalidEmail,
      });
    });

    test('every escaped character round-trips in every field', () {
      const ContactForm form = ContactForm(
        name: r'A;B,C:D"E\F',
        organisation: r'X;Y,Z:"\Corp',
      );
      final Contact contact = _reparse(form.encode()) as Contact;
      expect(contact.name, form.name);
      expect(contact.organisation, form.organisation);
    });

    test('the file name comes from the name, never phone or email', () {
      const ContactForm form = ContactForm(
        name: 'Ada Lovelace',
        phone: '+12025550102',
        email: 'ada@example.com',
      );
      expect(form.nonSecretName, 'Ada Lovelace');
    });
  });

  group('Phone (GEN-7, GEN-8)', () {
    test('empty number is required', () {
      expect(const PhoneForm().validate(), <String, GeneratorFieldError>{
        PhoneForm.fieldNumber: GeneratorFieldError.required,
      });
    });

    test('too few digits is invalid', () {
      expect(
        const PhoneForm(number: '12').validate(),
        <String, GeneratorFieldError>{
          PhoneForm.fieldNumber: GeneratorFieldError.invalidPhone,
        },
      );
    });

    test('too many digits is invalid', () {
      const PhoneForm form = PhoneForm(number: '1234567890123456');
      expect(form.validate(), <String, GeneratorFieldError>{
        PhoneForm.fieldNumber: GeneratorFieldError.invalidPhone,
      });
    });

    test('spaces, dashes and brackets are allowed while typing', () {
      const PhoneForm form = PhoneForm(number: '+1 (202) 555-0102');
      expect(form.isValid, isTrue);
      expect(form.encode(), 'tel:+12025550102');
    });

    test('a leading + is never dropped', () {
      const PhoneForm form = PhoneForm(number: '+44 20 7946 0958');
      expect(form.encode(), 'tel:+442079460958');
    });

    test('round-trips through the parser as a Phone', () {
      const PhoneForm form = PhoneForm(number: '+1 202 555 0102');
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<Phone>());
      expect((parsed as Phone).number, '+12025550102');
    });

    test('has no non-secret field for SAVE-4', () {
      expect(const PhoneForm(number: '12025550102').nonSecretName, isNull);
    });
  });

  group('Email (GEN-8)', () {
    test('empty address is required', () {
      expect(const EmailForm().validate(), <String, GeneratorFieldError>{
        EmailForm.fieldTo: GeneratorFieldError.required,
      });
    });

    test('an invalid address is rejected', () {
      expect(
        const EmailForm(to: 'not an email').validate(),
        <String, GeneratorFieldError>{
          EmailForm.fieldTo: GeneratorFieldError.invalidEmail,
        },
      );
    });

    test('the address alone encodes with no query string', () {
      const EmailForm form = EmailForm(to: 'a@example.com');
      expect(form.encode(), 'mailto:a@example.com');
    });

    test('subject and body round-trip through percent-encoding', () {
      const EmailForm form = EmailForm(
        to: 'a@example.com',
        subject: 'Hello & welcome?',
        body: 'Line one, line two = done',
      );
      final ParsedPayload parsed = _reparse(form.encode());
      expect(parsed, isA<Email>());
      final Email email = parsed as Email;
      expect(email.to, 'a@example.com');
      expect(email.subject, form.subject);
      expect(email.body, form.body);
    });

    test('has no non-secret field for SAVE-4', () {
      expect(const EmailForm(to: 'a@example.com').nonSecretName, isNull);
    });
  });

  group('SMS (GEN-8)', () {
    test('empty number is required', () {
      expect(const SmsForm().validate(), <String, GeneratorFieldError>{
        SmsForm.fieldNumber: GeneratorFieldError.required,
      });
    });

    test('an invalid number is rejected', () {
      expect(
        const SmsForm(number: 'abc').validate(),
        <String, GeneratorFieldError>{
          SmsForm.fieldNumber: GeneratorFieldError.invalidPhone,
        },
      );
    });

    test('no message encodes with no trailing colon', () {
      const SmsForm form = SmsForm(number: '+12025550102');
      expect(form.encode(), 'SMSTO:+12025550102');
      final Sms sms = _reparse(form.encode()) as Sms;
      expect(sms.number, '+12025550102');
      expect(sms.message, isNull);
    });

    test('a message with its own colon round-trips whole', () {
      const SmsForm form = SmsForm(
        number: '+12025550102',
        message: 'Meet at 5:30, ok?',
      );
      final Sms sms = _reparse(form.encode()) as Sms;
      expect(sms.number, '+12025550102');
      expect(sms.message, 'Meet at 5:30, ok?');
    });

    test('has no non-secret field for SAVE-4', () {
      expect(
        const SmsForm(number: '12025550102', message: 'hi').nonSecretName,
        isNull,
      );
    });
  });

  group('review fixes', () {
    test('a bare domain with a port gets https:// added (GEN-3)', () {
      const UrlForm form = UrlForm(rawInput: 'example.com:8080/menu');

      expect(form.normalizedInput, 'https://example.com:8080/menu');
      expect(form.isValid, isTrue);
    });

    test(
      'a non-web scheme is still refused, not turned into a host (GEN-3)',
      () {
        const UrlForm form = UrlForm(rawInput: 'javascript:alert(1)');

        expect(form.normalizedInput, 'javascript:alert(1)');
        expect(form.isValid, isFalse);
      },
    );

    test('a network name of only spaces is no name (GEN-5)', () {
      const WifiForm form = WifiForm(ssid: '   ');

      expect(form.validate(), <String, GeneratorFieldError>{
        WifiForm.fieldSsid: GeneratorFieldError.required,
      });
    });

    test('a network name keeps its own spaces in the code (GEN-5)', () {
      const WifiForm form = WifiForm(ssid: ' Cafe ');

      expect(form.isValid, isTrue);
      expect(form.encode(), contains('S: Cafe ;'));
    });
  });

  group('security tokens scanners read (GEN-5)', () {
    test('WPA/WPA2 writes T:WPA and WPA3 writes T:SAE', () {
      expect(
        const WifiForm(ssid: 'A', password: 'p').encode(),
        startsWith('WIFI:T:WPA;'),
      );
      expect(
        const WifiForm(
          ssid: 'A',
          security: WifiSecurity.wpa3,
          password: 'p',
        ).encode(),
        startsWith('WIFI:T:SAE;'),
      );
    });

    test('a WPA3 code reads back as WPA3', () {
      const WifiForm form = WifiForm(
        ssid: 'A',
        security: WifiSecurity.wpa3,
        password: 'p',
      );
      expect((_reparse(form.encode()) as Wifi).security, WifiSecurity.wpa3);
    });
  });
}
