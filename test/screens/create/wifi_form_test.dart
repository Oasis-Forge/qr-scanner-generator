import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/wifi_form.dart';

import 'create_test_helpers.dart';

void main() {
  group('the Wi-Fi form (GEN-5)', () {
    testWidgets('shows Create disabled and a required error on an empty '
        'network name', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.wifi);

      expect(find.text('This field is required.'), findsOneWidget);
      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('enables Create once a network name is entered', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.wifi);

      await tester.enterText(find.byKey(WifiFormFields.ssidFieldKey), 'Home');
      await tester.pump();

      final FilledButton button = tester.widget<FilledButton>(
        find.byKey(CreateFormBody.createButtonKey),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('WEP is labelled insecure in the security list', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.wifi);

      await tester.tap(find.byKey(WifiFormFields.securityFieldKey));
      await tester.pumpAndSettle();

      expect(find.text('WEP (insecure)'), findsOneWidget);
      // Never the plain "WEP" a result screen shows next to its own
      // separate warning line: here the word itself carries the warning.
      expect(find.text('WEP'), findsNothing);
    });

    testWidgets('the password is masked by default and a reveal button '
        'shows it', (WidgetTester tester) async {
      await pumpCreateForm(tester, ParsedType.wifi);

      await tester.enterText(
        find.byKey(WifiFormFields.passwordFieldKey),
        'secret123',
      );
      await tester.pump();

      TextField field() =>
          tester.widget<TextField>(find.byKey(WifiFormFields.passwordFieldKey));
      expect(field().obscureText, isTrue);

      await tester.tap(find.byKey(WifiFormFields.revealPasswordKey));
      await tester.pump();

      expect(field().obscureText, isFalse);
    });

    testWidgets('the password field disappears for an open network', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.wifi);
      expect(find.byKey(WifiFormFields.passwordFieldKey), findsOneWidget);

      await tester.tap(find.byKey(WifiFormFields.securityFieldKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open').last);
      await tester.pumpAndSettle();

      expect(find.byKey(WifiFormFields.passwordFieldKey), findsNothing);
    });

    testWidgets('the hidden-network switch toggles', (
      WidgetTester tester,
    ) async {
      await pumpCreateForm(tester, ParsedType.wifi);

      expect(
        tester
            .widget<SwitchListTile>(find.byKey(WifiFormFields.hiddenSwitchKey))
            .value,
        isFalse,
      );

      await tester.tap(find.byKey(WifiFormFields.hiddenSwitchKey));
      await tester.pump();

      expect(
        tester
            .widget<SwitchListTile>(find.byKey(WifiFormFields.hiddenSwitchKey))
            .value,
        isTrue,
      );
    });
  });
}
