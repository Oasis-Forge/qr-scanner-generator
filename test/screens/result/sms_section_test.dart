import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/sms_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

void main() {
  group('SmsSection (RES-7)', () {
    testWidgets('shows the number and the pre-filled message', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('SMSTO:+15551234567:On my way', parsedType: ParsedType.sms),
      );
      await pumpSection(tester, state, SmsSection(sms: state.payload as Sms));

      expect(find.text('+15551234567'), findsOneWidget);
      expect(find.text('On my way'), findsOneWidget);
    });

    testWidgets('an SMS with no message shows no Message row', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('SMSTO:+15551234567', parsedType: ParsedType.sms),
      );
      await pumpSection(tester, state, SmsSection(sms: state.payload as Sms));

      // "Message" is also the primary button's label: with no message, the
      // button is the only place it appears, and no row carries it.
      expect(find.text('Message'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Message'), findsOneWidget);
    });

    testWidgets(
      'the primary action opens the messaging app prefilled, and never '
      'sends itself',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = resultStateFor(
          outcomeFor(
            'SMSTO:+15551234567:On my way',
            parsedType: ParsedType.sms,
          ),
          systemIntents: intents,
        );
        await pumpSection(tester, state, SmsSection(sms: state.payload as Sms));

        // "Message" is also the field label above the pre-filled text, so
        // the button is found by its widget type, not by the bare text.
        await tester.tap(find.widgetWithText(FilledButton, 'Message'));
        await tester.pumpAndSettle();

        expect(
          intents.calls,
          contains('composeSms: +15551234567 (message: On my way)'),
        );
      },
    );

    testWidgets(
      'RES-14: with no messaging app, Message is disabled with a reason',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor('SMSTO:+15551234567', parsedType: ParsedType.sms),
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.sms},
          ),
        );
        await pumpSection(tester, state, SmsSection(sms: state.payload as Sms));

        final FilledButton button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Message'),
        );
        expect(button.onPressed, isNull);
        expect(find.text('No messaging app is installed.'), findsOneWidget);
      },
    );
  });
}
