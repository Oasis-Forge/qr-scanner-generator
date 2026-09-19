import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/phone_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the Phone form (GEN-7)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'field', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.phone);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an invalid number blocks Create with a message', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.phone);

      await tester.enterText(find.byKey(PhoneFormFields.fieldKey), '12');
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

    testWidgets('GEN-7: the field keeps a leading + and separators as '
        'typed, and enables Create', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.phone);

      await tester.enterText(
        find.byKey(PhoneFormFields.fieldKey),
        '+1 (234) 567-8900',
      );
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.byKey(PhoneFormFields.fieldKey))
            .controller!
            .text,
        '+1 (234) 567-8900',
      );
      expect(
        find.text('Enter a phone number with 3 to 15 digits.'),
        findsNothing,
      );
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
