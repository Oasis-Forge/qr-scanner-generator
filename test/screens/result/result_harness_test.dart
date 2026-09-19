import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/state/scan_outcome.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';

/// One result of each type, run through the shared accessibility and
/// text-size harness (A11Y-1, A11Y-2, A11Y-4, LANG-6), the same checks
/// `test/harness/accessibility_test.dart` and `test/harness/text_scale_test.dart`
/// run over the app's other screens.
///
/// `ResultScreen` isn't registered in `test/harness/harness_screens.dart`
/// (out of this PR's owned files, `needsCentral`); this file runs the same
/// checks directly instead, over a result of every type this PR adds,
/// picked with a full set of optional fields and a password so the busiest
/// layout (Wi-Fi, three secondary actions) is included.
class _Case {
  const _Case(this.name, this.outcome, this.readableText);

  final String name;
  final ScanOutcome outcome;
  final Map<String, String> readableText;
}

final List<_Case> _cases = <_Case>[
  _Case(
    'a link',
    _outcome('https://example.com/a/long/enough/path?q=1', ParsedType.url),
    const <String, String>{'en': 'Link · QR code', 'ar': 'رابط · رمز QR'},
  ),
  _Case(
    'a Wi-Fi network',
    _outcome(
      'WIFI:T:WPA;S:A Rather Long Home Network Name;P:aRatherLongPassword123;;',
      ParsedType.wifi,
    ),
    const <String, String>{
      'en': 'Wi-Fi · QR code',
      'ar': 'شبكة Wi-Fi · رمز QR',
    },
  ),
  _Case(
    'a contact',
    _outcome(
      'BEGIN:VCARD\nVERSION:3.0\nFN:Ada Lovelace\nTEL:+15551234567\n'
      'TEL:+15557654321\nEMAIL:ada@example.com\nORG:Analytical Engines\n'
      'END:VCARD',
      ParsedType.contact,
    ),
    const <String, String>{
      'en': 'Contact · QR code',
      'ar': 'جهة اتصال · رمز QR',
    },
  ),
  _Case(
    'a calendar event',
    _outcome(
      'BEGIN:VEVENT\nSUMMARY:A rather long meeting title\n'
      'DTSTART:20261016T090000\nDTEND:20261016T093000\n'
      'LOCATION:A conference room somewhere\n'
      'DESCRIPTION:Bring the roadmap and the coffee\nEND:VEVENT',
      ParsedType.event,
    ),
    const <String, String>{'en': 'Event · QR code', 'ar': 'حدث · رمز QR'},
  ),
  _Case(
    'a phone number',
    _outcome('tel:+15551234567', ParsedType.phone),
    const <String, String>{
      'en': 'Phone number · QR code',
      'ar': 'رقم هاتف · رمز QR',
    },
  ),
  _Case(
    'an SMS',
    _outcome(
      'SMSTO:+15551234567:A rather long pre-filled message body',
      ParsedType.sms,
    ),
    const <String, String>{'en': 'SMS · QR code', 'ar': 'رسالة نصية · رمز QR'},
  ),
  _Case(
    'an email',
    _outcome(
      'mailto:ada@example.com?subject=A rather long subject line'
      '&body=A rather long pre-filled body of the message',
      ParsedType.email,
    ),
    const <String, String>{
      'en': 'Email · QR code',
      'ar': 'بريد إلكتروني · رمز QR',
    },
  ),
  _Case(
    'a product',
    _outcome('4006381333931', ParsedType.product, symbology: Symbology.ean13),
    const <String, String>{'en': 'Product · EAN-13', 'ar': 'منتج · EAN-13'},
  ),
  _Case(
    'a location',
    _outcome(
      'geo:51.5,-0.12?q=51.5,-0.12(A rather long place name)',
      ParsedType.geo,
    ),
    const <String, String>{'en': 'Location · QR code', 'ar': 'موقع · رمز QR'},
  ),
  _Case(
    'plain text',
    _outcome(
      'A rather long piece of plain text that fits no other type',
      ParsedType.text,
    ),
    const <String, String>{'en': 'Text · QR code', 'ar': 'نص · رمز QR'},
  ),
  _Case(
    'binary data',
    ScanOutcome(
      record: aScanRecord(
        payloadText: '',
        payloadBytes: Uint8List.fromList(<int>[0xFF, 0xFE, 0x00]),
        parsedType: ParsedType.unknown,
      ),
      parsedType: ParsedType.unknown,
      symbology: Symbology.qr,
      source: RecordSource.camera,
      isSaved: true,
    ),
    const <String, String>{
      'en': 'Unknown · QR code',
      'ar': 'غير معروف · رمز QR',
    },
  ),
];

void main() {
  for (final _Case testCase in _cases) {
    for (final Locale locale in harnessLocales) {
      for (final double textScale in harnessTextScales) {
        final String where =
            'the result screen for ${testCase.name} in ${locale.languageCode} '
            'at ${textScale.toStringAsFixed(1)}x text';

        testWidgets('A11Y-1: $where names every icon-only control', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            ResultScreen(outcome: testCase.outcome),
            locale: locale,
            textScale: textScale,
          );

          expect(
            find.text(testCase.readableText[locale.languageCode]!),
            findsOneWidget,
          );
          await expectEveryIconHasALabel(tester);
        });

        testWidgets('A11Y-2: every control on $where is at least 48 x 48 dp', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            ResultScreen(outcome: testCase.outcome),
            locale: locale,
            textScale: textScale,
          );

          expect(
            find.text(testCase.readableText[locale.languageCode]!),
            findsOneWidget,
          );
          await expectTapTargetsAtLeast48dp(tester);
        });

        testWidgets('A11Y-4, LANG-6: $where fits a phone screen', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            ResultScreen(outcome: testCase.outcome),
            locale: locale,
            textScale: textScale,
          );

          expect(
            find.text(testCase.readableText[locale.languageCode]!),
            findsOneWidget,
          );
          expectNoOverflow(tester);
        });
      }
    }
  }
}

ScanOutcome _outcome(
  String payloadText,
  ParsedType parsedType, {
  Symbology symbology = Symbology.qr,
}) => ScanOutcome(
  record: aScanRecord(
    payloadText: payloadText,
    parsedType: parsedType,
    symbology: symbology,
  ),
  parsedType: parsedType,
  symbology: symbology,
  source: RecordSource.camera,
  isSaved: true,
);
