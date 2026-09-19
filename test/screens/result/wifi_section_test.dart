import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/payload_classifier.dart' show maskedSecret;
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/wifi_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

void main() {
  group('WifiSection (RES-4)', () {
    testWidgets(
      'shows the network name, the security and the password masked, with '
      'no password unmasked before the reveal button is tapped',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(
            'WIFI:T:WPA;S:Home Network;P:s3cretPass;;',
            parsedType: ParsedType.wifi,
          ),
        );
        await pumpSection(
          tester,
          state,
          WifiSection(wifi: state.payload as Wifi),
        );

        expect(find.text('Home Network'), findsOneWidget);
        expect(find.text('WPA'), findsOneWidget);
        expect(find.text(maskedSecret), findsOneWidget);
        expect(find.text('s3cretPass'), findsNothing);
      },
    );

    testWidgets('the reveal button shows the real password, and hides it '
        'again on a second tap', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'WIFI:T:WPA;S:Home;P:s3cretPass;;',
          parsedType: ParsedType.wifi,
        ),
      );
      await pumpSection(
        tester,
        state,
        WifiSection(wifi: state.payload as Wifi),
      );

      await tester.tap(find.byKey(WifiSection.revealPasswordKey));
      await tester.pump();

      expect(find.text('s3cretPass'), findsOneWidget);
      expect(find.text(maskedSecret), findsNothing);

      await tester.tap(find.byKey(WifiSection.revealPasswordKey));
      await tester.pump();

      expect(find.text('s3cretPass'), findsNothing);
      expect(find.text(maskedSecret), findsOneWidget);
    });

    testWidgets('an open network shows no password row at all', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('WIFI:T:nopass;S:Cafe;;', parsedType: ParsedType.wifi),
      );
      await pumpSection(
        tester,
        state,
        WifiSection(wifi: state.payload as Wifi),
      );

      expect(find.text(maskedSecret), findsNothing);
      expect(find.byKey(WifiSection.revealPasswordKey), findsNothing);
      expect(find.text('Copy password'), findsNothing);
    });

    testWidgets('a WEP network shows the line saying Android cannot join WEP '
        'networks from apps', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'WIFI:T:WEP;S:OldRouter;P:12345;;',
          parsedType: ParsedType.wifi,
        ),
      );
      await pumpSection(
        tester,
        state,
        WifiSection(wifi: state.payload as Wifi),
      );

      expect(
        find.text("Android can't join WEP networks from apps."),
        findsOneWidget,
      );
    });

    testWidgets(
      'the primary action opens Wi-Fi settings through SystemIntents',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        final ResultState state = resultStateFor(
          outcomeFor(
            'WIFI:T:WPA;S:Home;P:s3cret;;',
            parsedType: ParsedType.wifi,
          ),
          systemIntents: intents,
        );
        await pumpSection(
          tester,
          state,
          WifiSection(wifi: state.payload as Wifi),
        );

        await tester.tap(find.text('Open Wi-Fi settings'));
        await tester.pumpAndSettle();

        expect(
          intents.calls,
          containsAllInOrder(<String>[
            'canHandle: wifiSettings',
            'openWifiSettings',
          ]),
        );
      },
    );

    testWidgets(
      'RES-14: when nothing can open Wi-Fi settings, the primary action '
      'shows disabled with a one-line reason, and Copy stays available',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(
            'WIFI:T:WPA;S:Home;P:s3cret;;',
            parsedType: ParsedType.wifi,
          ),
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.wifiSettings},
          ),
        );
        await pumpSection(
          tester,
          state,
          WifiSection(wifi: state.payload as Wifi),
        );

        final FilledButton button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Open Wi-Fi settings'),
        );
        expect(button.onPressed, isNull);
        expect(
          find.text("Wi-Fi settings can't be opened on this device."),
          findsOneWidget,
        );
        expect(find.text('Copy'), findsOneWidget);
        await tester.tap(find.text('Copy'));
        await tester.pumpAndSettle();
        expect(find.text('Copied the content'), findsOneWidget);
      },
    );

    testWidgets(
      "'Copy password' copies only the password, never the whole payload",
      (WidgetTester tester) async {
        final NoopClipboardService clipboard = NoopClipboardService();
        final ResultState state = resultStateFor(
          outcomeFor(
            'WIFI:T:WPA;S:Home;P:s3cretPass;;',
            parsedType: ParsedType.wifi,
          ),
          clipboard: clipboard,
        );
        await pumpSection(
          tester,
          state,
          WifiSection(wifi: state.payload as Wifi),
        );

        await tester.tap(find.text('Copy password'));
        await tester.pumpAndSettle();

        expect(clipboard.calls, <String>['copyText: s3cretPass']);
        expect(find.text('Copied the password'), findsOneWidget);
      },
    );

    testWidgets('LANG-5: Arabic renders translated labels, the password '
        'stays left to right', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'WIFI:T:WPA2;S:منزل;P:s3cret;;',
          parsedType: ParsedType.wifi,
        ),
      );
      await pumpSection(
        tester,
        state,
        WifiSection(wifi: state.payload as Wifi),
        locale: const Locale('ar'),
      );

      expect(find.text('اسم الشبكة'), findsOneWidget);
      expect(find.text('الحماية'), findsOneWidget);
      expect(find.text('WPA2'), findsOneWidget);
      expect(find.text('فتح إعدادات Wi-Fi'), findsOneWidget);
      final SelectableText passwordField = tester.widget<SelectableText>(
        find.widgetWithText(SelectableText, maskedSecret),
      );
      expect(passwordField.textDirection, TextDirection.ltr);
    });
  });
}
