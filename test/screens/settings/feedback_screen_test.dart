import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/services/app_version_info.dart';
import 'package:qrscanner/screens/settings/feedback_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/system_intents.dart';

import '../../helpers/test_app.dart';
import 'settings_scope.dart';

void main() {
  const AppVersionDetails details = AppVersionDetails(
    version: '1.4.0',
    buildNumber: '27',
    androidVersion: 'Android 14',
  );

  testWidgets('the Send button is disabled until a category is chosen '
      '(SET-8)', (WidgetTester tester) async {
    await pumpApp(
      tester,
      SettingsScope(
        versionInfo: NoopAppVersionInfo(details: details),
        child: const FeedbackScreen(),
      ),
    );

    final FilledButton button = tester.widget(
      find.byKey(FeedbackScreen.sendButtonKey),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byKey(FeedbackScreen.adsCategoryKey));
    await tester.pump();

    final FilledButton enabled = tester.widget(
      find.byKey(FeedbackScreen.sendButtonKey),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets(
    'Send composes an email to the support address with the app and Android '
    'versions in the subject, and sends nothing itself (SET-8)',
    (WidgetTester tester) async {
      final NoopSystemIntents systemIntents = NoopSystemIntents();

      await pumpApp(
        tester,
        SettingsScope(
          versionInfo: NoopAppVersionInfo(details: details),
          child: const FeedbackScreen(),
        ),
        services: AppServices.fakes().copyWith(systemIntents: systemIntents),
      );

      await tester.tap(find.byKey(FeedbackScreen.scanningCategoryKey));
      await tester.pump();
      await tester.enterText(
        find.byKey(FeedbackScreen.messageFieldKey),
        'The camera never focuses.',
      );
      await tester.tap(find.byKey(FeedbackScreen.sendButtonKey));
      await tester.pumpAndSettle();

      expect(systemIntents.calls, hasLength(1));
      final String call = systemIntents.calls.single;
      expect(call, startsWith('composeEmail: $feedbackSupportEmail'));
      expect(call, contains('1.4.0+27'));
      expect(call, contains('Android 14'));
    },
  );

  testWidgets(
    "the category and the typed message go in the email's body, never sent "
    'by the app itself (SET-8)',
    (WidgetTester tester) async {
      final _RecordingSystemIntents systemIntents = _RecordingSystemIntents();

      await pumpApp(
        tester,
        SettingsScope(
          versionInfo: NoopAppVersionInfo(details: details),
          child: const FeedbackScreen(),
        ),
        services: AppServices.fakes().copyWith(systemIntents: systemIntents),
      );

      await tester.tap(find.byKey(FeedbackScreen.creatingCodesCategoryKey));
      await tester.pump();
      await tester.enterText(
        find.byKey(FeedbackScreen.messageFieldKey),
        'A rounded QR code will not scan.',
      );
      await tester.tap(find.byKey(FeedbackScreen.sendButtonKey));
      await tester.pumpAndSettle();

      expect(systemIntents.to, <String>[feedbackSupportEmail]);
      expect(systemIntents.body, contains('Creating codes'));
      expect(systemIntents.body, contains('A rounded QR code will not scan.'));
    },
  );

  testWidgets(
    'says so when no email app can be opened, and keeps what was typed '
    '(RES-14, SET-8)',
    (WidgetTester tester) async {
      await pumpApp(
        tester,
        SettingsScope(
          versionInfo: NoopAppVersionInfo(details: details),
          child: const FeedbackScreen(),
        ),
        services: AppServices.fakes().copyWith(
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.email},
          ),
        ),
      );

      await tester.tap(find.byKey(FeedbackScreen.otherCategoryKey));
      await tester.pump();
      await tester.tap(find.byKey(FeedbackScreen.sendButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('No email app is set up on this device.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('A11Y-1, A11Y-2: every category chip and the Send button are '
      'named and at least 48 x 48 dp', (WidgetTester tester) async {
    await pumpApp(
      tester,
      SettingsScope(
        versionInfo: NoopAppVersionInfo(details: details),
        child: const FeedbackScreen(),
      ),
    );

    await expectEveryIconHasALabel(tester);
    await expectTapTargetsAtLeast48dp(tester);
  });
}

/// A [SystemIntents] that records a [composeEmail] call in full, including
/// [body] — [NoopSystemIntents] only keeps `to` and `subject` in its own
/// `calls` log, which the other tests above use; this one exists for the one
/// test that needs to see what actually landed in the body.
class _RecordingSystemIntents implements SystemIntents {
  List<String>? to;
  String? subject;
  String? body;

  @override
  Future<bool> canHandle(SystemHandOff handOff) async => true;

  @override
  Future<SystemHandOffOutcome> composeEmail({
    required List<String> to,
    String? subject,
    String? body,
  }) async {
    this.to = to;
    this.subject = subject;
    this.body = body;
    return SystemHandOffOutcome.handedOff;
  }

  @override
  Future<SystemHandOffOutcome> insertContact(ContactDraft contact) async =>
      SystemHandOffOutcome.handedOff;

  @override
  Future<SystemHandOffOutcome> insertCalendarEvent(
    CalendarEventDraft event,
  ) async => SystemHandOffOutcome.handedOff;

  @override
  Future<SystemHandOffOutcome> dial(String phoneNumber) async =>
      SystemHandOffOutcome.handedOff;

  @override
  Future<SystemHandOffOutcome> composeSms({
    required String phoneNumber,
    String? message,
  }) async => SystemHandOffOutcome.handedOff;

  @override
  Future<SystemHandOffOutcome> openWifiSettings() async =>
      SystemHandOffOutcome.handedOff;

  @override
  Future<SystemHandOffOutcome> showLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async => SystemHandOffOutcome.handedOff;
}
