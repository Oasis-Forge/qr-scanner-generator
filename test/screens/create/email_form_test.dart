import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/email_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the Email form (GEN-8)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'address', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.email);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an invalid address blocks Create with a message', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.email);

      await tester.enterText(find.byKey(EmailFormFields.toFieldKey), 'nope');
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('a valid address enables Create; subject and body stay '
        'optional', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.email);

      await tester.enterText(
        find.byKey(EmailFormFields.toFieldKey),
        'ada@example.com',
      );
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsNothing);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
