import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/phone_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

void main() {
  group('PhoneSection (RES-7)', () {
    testWidgets('shows the number, a leading + kept', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('tel:+15551234567', parsedType: ParsedType.phone),
      );
      await pumpSection(
        tester,
        state,
        PhoneSection(phone: state.payload as Phone),
      );

      expect(find.text('+15551234567'), findsOneWidget);
    });

    testWidgets('the number stays left to right in Arabic (LANG-5)', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('tel:+15551234567', parsedType: ParsedType.phone),
      );
      await pumpSection(
        tester,
        state,
        PhoneSection(phone: state.payload as Phone),
        locale: const Locale('ar'),
      );

      expect(find.text('اتصال'), findsOneWidget);
      final SelectableText number = tester.widget<SelectableText>(
        find.widgetWithText(SelectableText, '+15551234567'),
      );
      expect(number.textDirection, TextDirection.ltr);
    });

    testWidgets(
      'the primary action opens the dialer prefilled, and never places the '
      'call itself',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = resultStateFor(
          outcomeFor('tel:+15551234567', parsedType: ParsedType.phone),
          systemIntents: intents,
        );
        await pumpSection(
          tester,
          state,
          PhoneSection(phone: state.payload as Phone),
        );

        await tester.tap(find.text('Call'));
        await tester.pumpAndSettle();

        expect(intents.calls, contains('dial: +15551234567'));
      },
    );

    testWidgets('RES-14: with no phone app, Call is disabled with a reason', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('tel:+15551234567', parsedType: ParsedType.phone),
        systemIntents: NoopSystemIntents(
          unhandled: <SystemHandOff>{SystemHandOff.dial},
        ),
      );
      await pumpSection(
        tester,
        state,
        PhoneSection(phone: state.payload as Phone),
      );

      final FilledButton button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Call'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('No phone app is installed.'), findsOneWidget);
    });
  });
}
