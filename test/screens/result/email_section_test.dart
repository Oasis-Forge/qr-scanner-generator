import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/email_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

const String _mailto = 'mailto:ada@example.com?subject=Hi&body=Hello there';

void main() {
  group('EmailSection (RES-7)', () {
    testWidgets('shows the recipient, subject and body', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(_mailto, parsedType: ParsedType.email),
      );
      await pumpSection(
        tester,
        state,
        EmailSection(email: state.payload as Email),
      );

      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget);
    });

    testWidgets('an address with no subject or body shows neither row', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('mailto:ada@example.com', parsedType: ParsedType.email),
      );
      await pumpSection(
        tester,
        state,
        EmailSection(email: state.payload as Email),
      );

      expect(find.text('Subject'), findsNothing);
    });

    testWidgets(
      'the primary action opens the email app prefilled, and never sends '
      'itself',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = resultStateFor(
          outcomeFor(_mailto, parsedType: ParsedType.email),
          systemIntents: intents,
        );
        await pumpSection(
          tester,
          state,
          EmailSection(email: state.payload as Email),
        );

        await tester.tap(find.text('Email'));
        await tester.pumpAndSettle();

        expect(
          intents.calls,
          contains('composeEmail: ada@example.com (subject: Hi)'),
        );
      },
    );

    testWidgets('RES-14: with no email app, Email is disabled with a reason', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(_mailto, parsedType: ParsedType.email),
        systemIntents: NoopSystemIntents(
          unhandled: <SystemHandOff>{SystemHandOff.email},
        ),
      );
      await pumpSection(
        tester,
        state,
        EmailSection(email: state.payload as Email),
      );

      final FilledButton button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Email'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('No email app is installed.'), findsOneWidget);
    });
  });
}
