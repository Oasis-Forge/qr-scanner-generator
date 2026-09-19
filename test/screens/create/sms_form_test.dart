import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/sms_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the SMS form (GEN-7, GEN-8)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'number', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.sms);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an invalid number blocks Create with a message', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.sms);

      await tester.enterText(find.byKey(SmsFormFields.numberFieldKey), '1');
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

    testWidgets('a valid number enables Create; the message stays optional', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.sms);

      await tester.enterText(
        find.byKey(SmsFormFields.numberFieldKey),
        '+1 555 0100',
      );
      await tester.pump();

      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
