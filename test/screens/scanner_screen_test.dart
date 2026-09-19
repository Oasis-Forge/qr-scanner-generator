import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/screens/manual_entry_screen.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/screens/scanner/scanner_keys.dart';
import 'package:qrscanner/screens/scanner/scanner_layout.dart';
import 'package:qrscanner/screens/scanner_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/services/photo_picker.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/scanner_state.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../harness/scanner_scope.dart';
import '../helpers/test_app.dart';

/// RUN-1's one reason, as the English message file spells it.
const String englishReason =
    'The camera is used only to read codes on this device.';

/// The same reason in Arabic.
const String arabicReason =
    'تُستخدم الكاميرا لقراءة الرموز على هذا الجهاز فقط.';

/// A link longer than SCAN-13's 40-character preview.
const String longLink =
    'https://example.com/a/very/long/path/that/goes/on/and/on';

const CodeDetection linkCode = CodeDetection(
  payload: 'https://example.com',
  symbology: 'qr',
);

void main() {
  group('camera permission (RUN-1 to RUN-7)', () {
    testWidgets(
      'RUN-1, RUN-3: before the camera is allowed the scanner shows one reason '
      'and "Allow camera", the largest control, and asks for nothing yet',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          permissions: NoopPermissionService(),
        );

        expect(find.text(englishReason), findsOneWidget);
        expect(find.text('Allow camera'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(ScannerKeys.allowCamera)).height,
          greaterThanOrEqualTo(ScannerLayout.primaryActionHeight),
        );
        // RUN-1 has nothing else: the shortcuts arrive with a denial (RUN-4).
        expect(find.byKey(ScannerKeys.scanPhoto), findsNothing);
        expect(find.byKey(ScannerKeys.typeCode), findsNothing);
        expect(scanner.permissions.calls, isNot(contains('requestCamera')));
        expect(scanner.camera.isRunning, isFalse);
      },
    );

    testWidgets(
      'RUN-1, LANG-5: the placeholder reads in Arabic and lays out right to '
      'left',
      (WidgetTester tester) async {
        await _pumpScanner(
          tester,
          permissions: NoopPermissionService(),
          locale: const Locale('ar'),
        );

        expect(find.text(arabicReason), findsOneWidget);
        expect(find.text('السماح بالكاميرا'), findsOneWidget);
        expect(find.text(englishReason), findsNothing);
        expect(
          Directionality.of(tester.element(find.byType(ScannerScreen))),
          TextDirection.rtl,
        );
      },
    );

    testWidgets(
      'RUN-3, RUN-7: tapping "Allow camera" asks the system, and a grant goes '
      'straight to the live scanner',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          permissions: NoopPermissionService(
            requestResult: CameraPermissionState.granted,
          ),
        );

        await tester.tap(find.byKey(ScannerKeys.allowCamera));
        await tester.pumpAndSettle();

        expect(scanner.permissions.calls, contains('requestCamera'));
        expect(scanner.camera.calls, contains('start'));
        expect(find.text('Point the camera at a code'), findsOneWidget);
        expect(find.text(englishReason), findsNothing);
        expect(find.byKey(ScannerKeys.allowCamera), findsNothing);
      },
    );

    testWidgets(
      'RUN-4: after "Don’t allow" the reason and "Allow camera" stay, '
      'with "Scan a photo" and "Type a code" under them',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          permissions: NoopPermissionService(
            requestedBefore: true,
            showsRationale: true,
          ),
        );

        expect(find.text(englishReason), findsOneWidget);
        expect(find.text('Allow camera'), findsOneWidget);
        expect(find.text('Scan a photo'), findsOneWidget);
        expect(find.text('Type a code'), findsOneWidget);
        // "Allow camera" is still the largest control.
        final Size allow = tester.getSize(find.byKey(ScannerKeys.allowCamera));
        for (final Key other in <Key>[
          ScannerKeys.scanPhoto,
          ScannerKeys.typeCode,
        ]) {
          final Size size = tester.getSize(find.byKey(other));
          expect(allow.height, greaterThan(size.height));
          expect(allow.width, greaterThanOrEqualTo(size.width));
        }

        // Tapping it asks the system again.
        await tester.tap(find.byKey(ScannerKeys.allowCamera));
        await tester.pumpAndSettle();
        expect(scanner.permissions.calls, contains('requestCamera'));
      },
    );

    testWidgets('RUN-4: the denied placeholder reads in Arabic', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(
        tester,
        permissions: NoopPermissionService(
          requestedBefore: true,
          showsRationale: true,
        ),
        locale: const Locale('ar'),
      );

      expect(find.text(arabicReason), findsOneWidget);
      expect(find.text('السماح بالكاميرا'), findsOneWidget);
      expect(find.text('مسح صورة'), findsOneWidget);
      expect(find.text('كتابة رمز'), findsOneWidget);
    });

    testWidgets(
      'RUN-6: once Android stops asking, the button is "Open settings" and it '
      'opens the app’s permission page',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          permissions: NoopPermissionService(requestedBefore: true),
        );

        expect(find.text('Open settings'), findsOneWidget);
        expect(find.text('Allow camera'), findsNothing);
        expect(find.text('Scan a photo'), findsOneWidget);
        expect(find.text('Type a code'), findsOneWidget);

        await tester.tap(find.byKey(ScannerKeys.openSettings));
        await tester.pumpAndSettle();

        expect(scanner.permissions.calls, contains('openAppSettings'));
        expect(scanner.permissions.calls, isNot(contains('requestCamera')));
      },
    );

    testWidgets('RUN-6: "Open settings" reads in Arabic', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(
        tester,
        permissions: NoopPermissionService(requestedBefore: true),
        locale: const Locale('ar'),
      );

      expect(find.text('فتح الإعدادات'), findsOneWidget);
      expect(find.text('السماح بالكاميرا'), findsNothing);
    });

    testWidgets('RUN-6: a settings page that does not open says so', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(
        tester,
        permissions: NoopPermissionService(
          requestedBefore: true,
          settingsOpens: false,
        ),
      );

      await tester.tap(find.byKey(ScannerKeys.openSettings));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Settings did not open. Allow the camera from your phone settings.',
        ),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets(
      'a camera that will not start says so and offers "Scan a photo" and '
      '"Type a code", with nothing to allow',
      (WidgetTester tester) async {
        await _pumpScanner(
          tester,
          camera: NoopCameraScanner(startSucceeds: false),
        );

        expect(
          find.text('The camera could not start. Another app may be using it.'),
          findsOneWidget,
        );
        expect(find.text('Scan a photo'), findsOneWidget);
        expect(find.text('Type a code'), findsOneWidget);
        expect(find.byKey(ScannerKeys.allowCamera), findsNothing);
        expect(find.byKey(ScannerKeys.openSettings), findsNothing);
      },
    );
  });

  group('live scanner', () {
    testWidgets(
      'RUN-7, SCAN-4: a granted camera shows the live scanner, and the scan '
      'window is the centred square target, 70% of the shorter side',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        expect(scanner.camera.isRunning, isTrue);
        expect(find.text('Point the camera at a code'), findsOneWidget);
        expect(find.text('Scan a photo'), findsOneWidget);
        expect(find.text('Type a code'), findsOneWidget);

        final Size viewfinder = tester.getSize(
          find.byKey(ScannerKeys.viewfinder),
        );
        final Rect? window = scanner.camera.scanWindow;
        expect(window, isNotNull);
        final double side = viewfinder.shortestSide * 0.7;
        expect(window!.width, closeTo(side, 0.01));
        expect(window.height, closeTo(side, 0.01));
        expect(window.center.dx, closeTo(viewfinder.width / 2, 0.01));
        expect(window.center.dy, closeTo(viewfinder.height / 2, 0.01));
      },
    );

    testWidgets(
      'SCAN-6: the torch button shows when the camera reports a flash, and '
      'turns the torch on and off',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        expect(find.byTooltip('Turn on the torch'), findsOneWidget);
        await tester.tap(find.byKey(ScannerKeys.torch));
        await tester.pumpAndSettle();

        expect(scanner.camera.torchState, TorchState.on);
        expect(scanner.camera.calls, contains('setTorch: true'));
        // The name says what the next tap does, and the icon changes too, so
        // the state is never colour alone (A11Y-1, A11Y-6).
        expect(find.byTooltip('Turn off the torch'), findsOneWidget);
        expect(find.byIcon(Icons.flashlight_on), findsOneWidget);

        await tester.tap(find.byKey(ScannerKeys.torch));
        await tester.pumpAndSettle();

        expect(scanner.camera.torchState, TorchState.off);
        expect(find.byIcon(Icons.flashlight_off), findsOneWidget);
      },
    );

    testWidgets('SCAN-6: a camera with no flash shows no torch button', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(
        tester,
        camera: NoopCameraScanner(torchAvailable: false),
      );

      expect(find.text('Point the camera at a code'), findsOneWidget);
      expect(find.byKey(ScannerKeys.torch), findsNothing);
    });

    testWidgets(
      'SCAN-7: the zoom slider zooms in, and a manual zoom stops auto-zoom',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);
        expect(scanner.camera.autoZoomEnabled, isTrue);
        expect(find.text('1×'), findsOneWidget);

        await tester.drag(
          find.byKey(ScannerKeys.zoomSlider),
          const Offset(120, 0),
        );
        await tester.pumpAndSettle();

        expect(scanner.camera.zoom, greaterThan(1));
        expect(scanner.camera.autoZoomEnabled, isFalse);
        expect(find.text('1×'), findsNothing);
      },
    );

    testWidgets('SCAN-7: double-tap switches between 1x and 2x', (
      WidgetTester tester,
    ) async {
      final _Scanner scanner = await _pumpScanner(tester);

      await _doubleTap(tester, find.byKey(ScannerKeys.viewfinder));
      expect(scanner.camera.zoom, 2);
      expect(find.text('2×'), findsOneWidget);
      expect(scanner.camera.autoZoomEnabled, isFalse);

      await _doubleTap(tester, find.byKey(ScannerKeys.viewfinder));
      expect(scanner.camera.zoom, 1);
    });

    testWidgets('SCAN-7: pinching out zooms in', (WidgetTester tester) async {
      final _Scanner scanner = await _pumpScanner(tester);
      final Offset center = tester.getCenter(
        find.byKey(ScannerKeys.viewfinder),
      );

      final TestGesture first = await tester.startGesture(
        center - const Offset(30, 0),
        pointer: 7,
      );
      final TestGesture second = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 8,
      );
      for (int step = 0; step < 5; step++) {
        await first.moveBy(const Offset(-15, 0));
        await second.moveBy(const Offset(15, 0));
        await tester.pump();
      }
      await first.up();
      await second.up();
      await tester.pumpAndSettle();

      expect(scanner.camera.zoom, greaterThan(1));
      expect(scanner.camera.autoZoomEnabled, isFalse);
    });

    testWidgets('ADS-1: the scanner and its result request no ad', (
      WidgetTester tester,
    ) async {
      final _Scanner scanner = await _pumpScanner(tester);

      scanner.camera.emit(<CodeDetection>[linkCode]);
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      expect((scanner.services.ads as NoopAdsService).calls, isEmpty);
    });
  });

  group('results (SCAN-3, RES-2, RES-3, A11Y-3)', () {
    testWidgets(
      'SCAN-3: a code in the target opens its result with detection paused, '
      'and closing it resumes detection while that payload is ignored',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('Link · QR code'), findsOneWidget);
        expect(find.text('https://example.com'), findsOneWidget);
        expect(scanner.camera.isDetecting, isFalse);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsNothing);
        expect(_state(tester).outcome, isNull);
        expect(scanner.camera.isDetecting, isTrue);

        // The same code, still in view, doesn't reopen straight away.
        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();
        expect(find.byType(ResultScreen), findsNothing);
      },
    );

    testWidgets(
      'A11Y-3: a detected code is announced by format and type, in English '
      'and left to right',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);
        tester.takeAnnouncements();

        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();

        final List<CapturedAccessibilityAnnouncement> said = tester
            .takeAnnouncements();
        expect(
          said.map((CapturedAccessibilityAnnouncement a) => a.message),
          <String>['QR code detected: Link'],
        );
        expect(said.single.textDirection, TextDirection.ltr);
      },
    );

    testWidgets(
      'A11Y-3: in Arabic the announcement is Arabic and right to left',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          locale: const Locale('ar'),
        );
        tester.takeAnnouncements();

        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();

        final List<CapturedAccessibilityAnnouncement> said = tester
            .takeAnnouncements();
        expect(
          said.map((CapturedAccessibilityAnnouncement a) => a.message),
          <String>['تم اكتشاف رمز QR: رابط'],
        );
        expect(said.single.textDirection, TextDirection.rtl);
      },
    );

    testWidgets(
      'RES-2: a result opens nothing by itself: no link, no system app, no '
      'share sheet, and with Copy on scan off, no copy',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        final AppServices services = scanner.services;
        // Only the RES-14 availability probe; nothing was opened.
        expect(
          (services.linkOpener as NoopLinkOpener).calls,
          everyElement('canOpenWebLinks'),
        );
        expect((services.systemIntents as NoopSystemIntents).calls, isEmpty);
        expect((services.share as NoopShareService).calls, isEmpty);
        expect((services.clipboard as NoopClipboardService).calls, isEmpty);
      },
    );

    testWidgets(
      'SET-3, RES-2: with Copy on scan on, the text is copied only once the '
      'result is on screen, and a snackbar says what was copied',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          stored: <String, String>{SettingsState.copyOnScanKey: '1'},
        );
        final NoopClipboardService clipboard =
            scanner.services.clipboard as NoopClipboardService;

        scanner.camera.emit(<CodeDetection>[linkCode]);
        // Frames without advancing the clock: the scan is recorded and the
        // result is pushed, but its entrance animation has not moved yet.
        for (
          var i = 0;
          i < 10 && find.byType(ResultScreen).evaluate().isEmpty;
          i++
        ) {
          await tester.pump();
        }

        // The result is on its way in, and nothing is copied yet.
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(clipboard.calls, isEmpty);

        await tester.pumpAndSettle();

        expect(clipboard.calls, <String>['copyText: https://example.com']);
        expect(find.text('Copied the link'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      },
    );

    testWidgets(
      'DATA-4: a scan that could not be written to History still opens, and '
      'the result says it was not saved',
      (WidgetTester tester) async {
        // "Save history" is on; the harness DAO's database is never opened, so
        // the write fails the way a full disk would.
        final _Scanner scanner = await _pumpScanner(
          tester,
          stored: <String, String>{SettingsState.saveHistoryKey: '1'},
        );

        scanner.camera.emit(<CodeDetection>[linkCode]);
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('https://example.com'), findsOneWidget);
        expect(
          find.text('This scan could not be saved to History.'),
          findsOneWidget,
        );
      },
    );
  });

  group('several codes (SCAN-13)', () {
    testWidgets(
      'SCAN-13: two codes in one pass are listed with a type icon, the type '
      'and the first 40 characters, and the chosen one opens its result',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);
        tester.takeAnnouncements();

        scanner.camera.emit(<CodeDetection>[
          const CodeDetection(payload: longLink, symbology: 'qr'),
          const CodeDetection(payload: 'Hello there', symbology: 'qr'),
        ]);
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsNothing);
        expect(find.text('2 codes found'), findsOneWidget);
        expect(find.text('${longLink.substring(0, 40)}…'), findsOneWidget);
        expect(find.text(longLink), findsNothing);
        expect(find.text('Hello there'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(ScannerKeys.choice(0)),
            matching: find.byIcon(Icons.link),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(ScannerKeys.choice(0)),
            matching: find.text('Link · QR code'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(ScannerKeys.choice(1)),
            matching: find.byIcon(Icons.notes),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(ScannerKeys.choice(1)),
            matching: find.text('Text · QR code'),
          ),
          findsOneWidget,
        );
        expect(
          tester.takeAnnouncements().map(
            (CapturedAccessibilityAnnouncement a) => a.message,
          ),
          <String>['2 codes detected'],
        );

        await tester.tap(find.byKey(ScannerKeys.choice(0)));
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('Link · QR code'), findsOneWidget);
        // The full link, not the preview.
        expect(find.text(longLink), findsOneWidget);
        // The pick was already announced as a list; it isn't announced again.
        expect(tester.takeAnnouncements(), isEmpty);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byKey(ScannerKeys.choicesSheet), findsNothing);
        expect(scanner.camera.isDetecting, isTrue);
      },
    );

    testWidgets('SCAN-13, LANG-5: the list reads in Arabic, links left to '
        'right', (WidgetTester tester) async {
      final _Scanner scanner = await _pumpScanner(
        tester,
        locale: const Locale('ar'),
      );

      scanner.camera.emit(<CodeDetection>[
        linkCode,
        const CodeDetection(payload: '4006381333931', symbology: 'ean13'),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('تم العثور على رمزين'), findsOneWidget);
      expect(find.text('رابط · رمز QR'), findsOneWidget);
      expect(find.text('منتج · EAN-13'), findsOneWidget);
      final Text link = tester.widget<Text>(find.text('https://example.com'));
      expect(link.textDirection, TextDirection.ltr);
    });

    testWidgets(
      'SCAN-13: closing the list without a pick resumes detection and opens '
      'nothing',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        scanner.camera.emit(<CodeDetection>[
          linkCode,
          const CodeDetection(payload: 'Hello there', symbology: 'qr'),
        ]);
        await tester.pumpAndSettle();
        expect(scanner.camera.isDetecting, isFalse);

        await tester.tap(find.byKey(ScannerKeys.closeChoices));
        await tester.pumpAndSettle();

        expect(find.byKey(ScannerKeys.choicesSheet), findsNothing);
        expect(find.byType(ResultScreen), findsNothing);
        expect(scanner.camera.isDetecting, isTrue);
      },
    );

    testWidgets('SCAN-13: back closes the list before it leaves the scanner', (
      WidgetTester tester,
    ) async {
      final _Scanner scanner = await _pumpScanner(tester);

      scanner.camera.emit(<CodeDetection>[
        linkCode,
        const CodeDetection(payload: 'Hello there', symbology: 'qr'),
      ]);
      await tester.pumpAndSettle();
      expect(find.byKey(ScannerKeys.choicesSheet), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byKey(ScannerKeys.choicesSheet), findsNothing);
      expect(find.byType(ScannerScreen), findsOneWidget);
    });

    testWidgets(
      'SCAN-13: a photo with two codes lists them too, and a pick opens its '
      'result',
      (WidgetTester tester) async {
        await _pumpScanner(
          tester,
          imageDecoder: NoopImageDecoder(
            result: const ImageDecodeResult(<CodeDetection>[
              linkCode,
              CodeDetection(payload: 'Hello there', symbology: 'qr'),
            ]),
          ),
        );

        await tester.tap(find.byKey(ScannerKeys.scanPhoto));
        await tester.pumpAndSettle();
        expect(find.text('2 codes found'), findsOneWidget);

        await tester.tap(find.byKey(ScannerKeys.choice(1)));
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('Text · QR code'), findsOneWidget);
        expect(find.text('Hello there'), findsOneWidget);
      },
    );
  });

  group('scan a photo (SCAN-11)', () {
    testWidgets(
      'SCAN-11: a photo with no code shows "No code found", one hint, "Try '
      'another photo" as the largest control, and "Type a code"',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          permissions: NoopPermissionService(
            requestedBefore: true,
            showsRationale: true,
          ),
        );

        await tester.tap(find.byKey(ScannerKeys.scanPhoto));
        await tester.pumpAndSettle();

        expect(scanner.photoPicker.calls, <String>['pickImagePath']);
        expect(find.text('No code found'), findsOneWidget);
        expect(
          find.text(
            'Make sure the whole code is in the photo, sharp and well lit.',
          ),
          findsOneWidget,
        );
        expect(find.text('Try another photo'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(ScannerKeys.tryAnotherPhoto)).height,
          greaterThan(
            tester.getSize(find.byKey(ScannerKeys.noCodeTypeCode)).height,
          ),
        );
        expect(find.byType(ResultScreen), findsNothing);

        await tester.tap(find.byKey(ScannerKeys.tryAnotherPhoto));
        await tester.pumpAndSettle();

        expect(scanner.photoPicker.calls, <String>[
          'pickImagePath',
          'pickImagePath',
        ]);
        expect(find.text('No code found'), findsOneWidget);
      },
    );

    testWidgets('SCAN-11: "No code found" reads in Arabic', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(tester, locale: const Locale('ar'));

      await tester.tap(find.byKey(ScannerKeys.scanPhoto));
      await tester.pumpAndSettle();

      expect(find.text('لم يُعثر على رمز'), findsOneWidget);
      expect(find.text('جرّب صورة أخرى'), findsOneWidget);
    });

    testWidgets('SCAN-11: closing "No code found" returns to the scanner', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(tester);

      await tester.tap(find.byKey(ScannerKeys.scanPhoto));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ScannerKeys.closeNoCodeFound));
      await tester.pumpAndSettle();

      expect(find.byKey(ScannerKeys.noCodeFound), findsNothing);
      expect(find.text('Point the camera at a code'), findsOneWidget);
    });

    testWidgets(
      'SCAN-11: a photo with one code opens its result with no extra tap',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(
          tester,
          imageDecoder: NoopImageDecoder(
            result: const ImageDecodeResult(<CodeDetection>[linkCode]),
          ),
        );

        await tester.tap(find.byKey(ScannerKeys.scanPhoto));
        await tester.pumpAndSettle();

        expect(scanner.photoPicker.calls, <String>['pickImagePath']);
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('https://example.com'), findsOneWidget);
      },
    );

    testWidgets('SCAN-11: a photo picker that will not open says so', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(tester, photoPicker: _FailingPhotoPicker());

      await tester.tap(find.byKey(ScannerKeys.scanPhoto));
      await tester.pumpAndSettle();

      expect(
        find.text('The photo picker did not open. Try again.'),
        findsOneWidget,
      );
      expect(find.text('No code found'), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('typed entry (SCAN-12)', () {
    testWidgets(
      'SCAN-12: "Type a code" opens typed entry with the camera off, and the '
      'text opens the same result screen, source manual',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        await tester.tap(find.byKey(ScannerKeys.typeCode));
        await tester.pumpAndSettle();

        expect(find.byType(ManualEntryScreen), findsOneWidget);
        expect(scanner.camera.isRunning, isFalse);

        await tester.enterText(
          find.byKey(ManualEntryScreen.fieldKey),
          'Hello, world',
        );
        await tester.pump();
        await tester.tap(find.byKey(ManualEntryScreen.scanKey));
        await tester.pumpAndSettle();

        expect(find.byType(ManualEntryScreen), findsNothing);
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('Hello, world'), findsOneWidget);
        // Typed text was read from no code, so no format is claimed.
        expect(
          tester.widget<Text>(find.byKey(ResultScreen.typeLineKey)).data,
          'Text',
        );
        final ResultScreen result = tester.widget<ResultScreen>(
          find.byType(ResultScreen),
        );
        expect(result.outcome.source.id, 'manual');
        // Nothing typed is announced as detected (A11Y-3).
        expect(
          tester.takeAnnouncements().map(
            (CapturedAccessibilityAnnouncement a) => a.message,
          ),
          isNot(contains(contains('detected'))),
        );

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(scanner.camera.isRunning, isTrue);
      },
    );

    testWidgets(
      'SCAN-12: a barcode number typed in opens the same product result a scan '
      'of it would',
      (WidgetTester tester) async {
        await _pumpScanner(tester);

        await tester.tap(find.byKey(ScannerKeys.typeCode));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(ManualEntryScreen.fieldKey),
          '4006381333931',
        );
        await tester.pump();
        await tester.tap(find.byKey(ManualEntryScreen.scanKey));
        await tester.pumpAndSettle();

        expect(find.text('Product · EAN-13'), findsOneWidget);
      },
    );

    testWidgets(
      'SCAN-12: backing out of typed entry returns to the live scanner',
      (WidgetTester tester) async {
        final _Scanner scanner = await _pumpScanner(tester);

        await tester.tap(find.byKey(ScannerKeys.typeCode));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsNothing);
        expect(find.text('Point the camera at a code'), findsOneWidget);
        expect(scanner.camera.isRunning, isTrue);
      },
    );

    testWidgets('SCAN-12: typed entry works with the camera denied (RUN-4)', (
      WidgetTester tester,
    ) async {
      await _pumpScanner(
        tester,
        permissions: NoopPermissionService(
          requestedBefore: true,
          showsRationale: true,
        ),
      );

      await tester.tap(find.byKey(ScannerKeys.typeCode));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(ManualEntryScreen.fieldKey),
        'https://example.com',
      );
      await tester.pump();
      await tester.tap(find.byKey(ManualEntryScreen.scanKey));
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
    });
  });

  testWidgets('A11Y-2: the shortcuts on the live scanner are at least 48 dp', (
    WidgetTester tester,
  ) async {
    await _pumpScanner(tester);

    for (final Key key in <Key>[
      ScannerKeys.scanPhoto,
      ScannerKeys.typeCode,
      ScannerKeys.torch,
      ScannerKeys.zoomSlider,
    ]) {
      final Size size = tester.getSize(find.byKey(key));
      expect(size.height, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
      expect(size.width, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
    }
  });
}

/// The fakes behind one pumped scanner, for a test to drive and inspect.
class _Scanner {
  const _Scanner({
    required this.services,
    required this.camera,
    required this.permissions,
    required this.photoPicker,
  });

  final AppServices services;
  final NoopCameraScanner camera;
  final NoopPermissionService permissions;
  final _RecordingPhotoPicker photoPicker;
}

/// Pumps the scanner screen in the test shell, with the camera allowed unless
/// [permissions] says otherwise, and "Save history" off unless [stored] turns
/// it on, so a scan opens its result without a database (DATA-6).
Future<_Scanner> _pumpScanner(
  WidgetTester tester, {
  NoopPermissionService? permissions,
  NoopCameraScanner? camera,
  ImageDecoder? imageDecoder,
  PhotoPicker? photoPicker,
  Locale? locale,
  Map<String, String>? stored,
}) async {
  final NoopPermissionService usedPermissions =
      permissions ??
      NoopPermissionService(initialState: CameraPermissionState.granted);
  final NoopCameraScanner usedCamera = camera ?? NoopCameraScanner();
  final _RecordingPhotoPicker recorder = _RecordingPhotoPicker(
    photoPicker ?? NoopPhotoPicker(),
  );
  final AppServices services = AppServices.fakes().copyWith(
    permissions: usedPermissions,
    cameraScanner: usedCamera,
    imageDecoder: imageDecoder,
    photoPicker: recorder,
  );
  await pumpApp(
    tester,
    const ScannerScope(child: ScannerScreen()),
    services: services,
    locale: locale,
    stored: <String, String>{SettingsState.saveHistoryKey: '0', ...?stored},
  );
  return _Scanner(
    services: services,
    camera: usedCamera,
    permissions: usedPermissions,
    photoPicker: recorder,
  );
}

/// The scanner state the screen under test reads.
ScannerState _state(WidgetTester tester) =>
    tester.element(find.byType(ScannerScreen)).read<ScannerState>();

/// Two taps close enough together to be a double-tap.
Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 60));
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Records every time the picker is opened, whatever the picker underneath
/// answers.
class _RecordingPhotoPicker implements PhotoPicker {
  _RecordingPhotoPicker(this._inner);

  final PhotoPicker _inner;
  final List<String> calls = <String>[];

  @override
  Future<String?> pickImagePath() {
    calls.add('pickImagePath');
    return _inner.pickImagePath();
  }
}

/// A device with no photo picker to open (SCAN-11).
class _FailingPhotoPicker implements PhotoPicker {
  @override
  Future<String?> pickImagePath() async =>
      throw StateError('no photo picker on this device');
}
