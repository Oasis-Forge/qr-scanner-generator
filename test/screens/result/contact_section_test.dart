import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/contact_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

const String _vcard =
    'BEGIN:VCARD\nVERSION:3.0\nFN:Ada Lovelace\nTEL:+15551234567\n'
    'EMAIL:ada@example.com\nORG:Analytical Engines\nEND:VCARD';

void main() {
  group('ContactSection (RES-6)', () {
    testWidgets(
      'shows the name, phone, email and organisation exactly as encoded',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(_vcard, parsedType: ParsedType.contact),
        );
        await pumpSection(
          tester,
          state,
          ContactSection(contact: state.payload as Contact),
        );

        expect(find.text('Ada Lovelace'), findsOneWidget);
        expect(find.text('+15551234567'), findsOneWidget);
        expect(find.text('ada@example.com'), findsOneWidget);
        expect(find.text('Analytical Engines'), findsOneWidget);
      },
    );

    testWidgets('a phone number stays left to right (LANG-5)', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(_vcard, parsedType: ParsedType.contact),
      );
      await pumpSection(
        tester,
        state,
        ContactSection(contact: state.payload as Contact),
        locale: const Locale('ar'),
      );

      final SelectableText phone = tester.widget<SelectableText>(
        find.widgetWithText(SelectableText, '+15551234567'),
      );
      expect(phone.textDirection, TextDirection.ltr);
    });

    testWidgets(
      'the primary action hands the contact to insertContact, and reports '
      'nothing on success',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = resultStateFor(
          outcomeFor(_vcard, parsedType: ParsedType.contact),
          systemIntents: intents,
        );
        await pumpSection(
          tester,
          state,
          ContactSection(contact: state.payload as Contact),
        );

        await tester.tap(find.text('Add to contacts'));
        await tester.pumpAndSettle();

        expect(
          intents.calls,
          contains(
            'insertContact: Ada Lovelace (phones: +15551234567; '
            'emails: ada@example.com; org: Analytical Engines)',
          ),
        );
        expect(find.text('Could not open. Try again.'), findsNothing);
      },
    );

    testWidgets(
      'RES-14: with no contacts app, the primary action is disabled with a '
      'reason, and Copy stays available',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(_vcard, parsedType: ParsedType.contact),
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.insertContact},
          ),
        );
        await pumpSection(
          tester,
          state,
          ContactSection(contact: state.payload as Contact),
        );

        final FilledButton button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add to contacts'),
        );
        expect(button.onPressed, isNull);
        expect(find.text('No contacts app is installed.'), findsOneWidget);
        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
      },
    );
  });
}
