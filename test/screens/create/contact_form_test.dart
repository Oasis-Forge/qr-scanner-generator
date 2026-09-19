import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/contact_form.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';

import 'create_test_helpers.dart';

void main() {
  group('the Contact form (GEN-6)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'name', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.contact);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('enables Create once only the required name is filled in', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.contact);

      await tester.enterText(
        find.byKey(ContactFormFields.nameFieldKey),
        'Ada Lovelace',
      );
      await tester.pump();

      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('an invalid optional phone blocks Create with a message', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.contact);

      await tester.enterText(
        find.byKey(ContactFormFields.nameFieldKey),
        'Ada Lovelace',
      );
      await tester.enterText(find.byKey(ContactFormFields.phoneFieldKey), '1');
      await tester.pump();

      expect(
        find.text('Enter a phone number with 3 to 15 digits.'),
        findsOneWidget,
      );
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an invalid optional email blocks Create with a message', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.contact);

      await tester.enterText(
        find.byKey(ContactFormFields.nameFieldKey),
        'Ada Lovelace',
      );
      await tester.enterText(
        find.byKey(ContactFormFields.emailFieldKey),
        'not-an-email',
      );
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });
  });
}
