import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/generator/qr_capacity.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/capacity_meter.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/text_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the Text form (GEN-8)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'field', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.text);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('enables Create once text is entered', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.text);

      await tester.enterText(find.byKey(TextFormFields.fieldKey), 'hello');
      await tester.pump();

      expect(find.text('This field is required.'), findsNothing);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('GEN-12: the capacity meter appears above 80% of capacity', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.text);

      final String underThreshold = ''.padLeft(
        (qrMaxCapacityBytes * 0.79).floor(),
        'a',
      );
      await tester.enterText(
        find.byKey(TextFormFields.fieldKey),
        underThreshold,
      );
      await tester.pump();
      expect(find.byKey(CapacityMeter.meterKey), findsNothing);

      final String overThreshold = ''.padLeft(
        (qrMaxCapacityBytes * 0.85).floor(),
        'a',
      );
      await tester.enterText(
        find.byKey(TextFormFields.fieldKey),
        overThreshold,
      );
      await tester.pump();
      expect(find.byKey(CapacityMeter.meterKey), findsOneWidget);
      final FilledButton stillEnabled = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(stillEnabled.onPressed, isNotNull);
    });

    testWidgets('GEN-12: Create is blocked above 100% of capacity, with the '
        'fix', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.text);

      final String overLimit = ''.padLeft(qrMaxCapacityBytes + 1, 'a');
      await tester.enterText(find.byKey(TextFormFields.fieldKey), overLimit);
      await tester.pump();

      expect(find.byKey(CapacityOverLimitNotice.noticeKey), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });
  });
}
