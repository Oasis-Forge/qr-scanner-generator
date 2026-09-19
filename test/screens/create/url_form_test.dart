import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/url_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the URL form (GEN-3)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'field', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.url);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('GEN-3: a bare domain shows the added https:// where the '
        'user can see it, and enables Create', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.url);

      await tester.enterText(find.byKey(UrlFormFields.fieldKey), 'example.com');
      // Settled: the field's error fades out over a few frames.
      await tester.pumpAndSettle();

      // The field itself still shows exactly what was typed (GEN-3).
      expect(
        tester
            .widget<TextField>(find.byKey(UrlFormFields.fieldKey))
            .controller!
            .text,
        'example.com',
      );
      expect(find.text('The code opens https://example.com'), findsOneWidget);
      expect(find.text('This field is required.'), findsNothing);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('GEN-3: a non-http(s) scheme is rejected before Create '
        'enables', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.url);

      await tester.enterText(
        find.byKey(UrlFormFields.fieldKey),
        'ftp://example.com',
      );
      await tester.pump();

      expect(
        find.text('Enter a web address starting with http:// or https://.'),
        findsOneWidget,
      );
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('an address already carrying https:// is accepted as is', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.url);

      await tester.enterText(
        find.byKey(UrlFormFields.fieldKey),
        'https://example.com/path',
      );
      await tester.pump();

      expect(
        find.text('The code opens https://example.com/path'),
        findsOneWidget,
      );
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
