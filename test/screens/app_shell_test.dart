import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/screens/app_shell.dart';
import 'package:qrscanner/screens/history_screen.dart';
import 'package:qrscanner/screens/placeholder_tab.dart';
import 'package:qrscanner/screens/scanner/scanner_keys.dart';
import 'package:qrscanner/screens/scanner_screen.dart';
import 'package:qrscanner/screens/settings_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/permission_service.dart';

import '../harness/scanner_scope.dart';
import '../helpers/test_app.dart';

void main() {
  group('AppShell (SCAN-1)', () {
    testWidgets(
      'SCAN-1: the app opens on the scanner, with Scan, Create, History and '
      'Settings in the bottom bar, each with an icon and a label',
      (WidgetTester tester) async {
        await pumpApp(tester, const ScannerScope(child: AppShell()));

        expect(find.byType(ScannerScreen), findsOneWidget);
        expect(find.text('Allow camera'), findsOneWidget);
        final NavigationBar bar = tester.widget<NavigationBar>(
          find.byType(NavigationBar),
        );
        expect(bar.selectedIndex, 0);
        for (final (Key key, String label, IconData icon)
            in <(Key, String, IconData)>[
              (AppShell.scanTabKey, 'Scan', Icons.qr_code_scanner),
              (AppShell.createTabKey, 'Create', Icons.add_box_outlined),
              (AppShell.historyTabKey, 'History', Icons.history),
              (AppShell.settingsTabKey, 'Settings', Icons.settings_outlined),
            ]) {
          expect(
            find.descendant(of: find.byKey(key), matching: find.text(label)),
            findsOneWidget,
          );
          expect(
            find.descendant(of: find.byKey(key), matching: find.byIcon(icon)),
            findsOneWidget,
          );
        }
      },
    );

    testWidgets('SCAN-1, LANG-5: the bottom bar reads in Arabic and mirrors', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        const ScannerScope(child: AppShell()),
        locale: const Locale('ar'),
      );

      expect(find.text('مسح'), findsOneWidget);
      expect(find.text('إنشاء'), findsOneWidget);
      expect(find.text('السجل'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
      // Scan, the first destination, sits at the right edge in Arabic.
      expect(
        tester.getCenter(find.byKey(AppShell.scanTabKey)).dx,
        greaterThan(tester.getCenter(find.byKey(AppShell.settingsTabKey)).dx),
      );
    });

    testWidgets(
      'SCAN-1: the bottom bar switches tabs, and Create and History say they '
      'arrive in the next test build',
      (WidgetTester tester) async {
        await pumpApp(tester, const ScannerScope(child: AppShell()));

        await tester.tap(find.byKey(AppShell.createTabKey));
        await tester.pumpAndSettle();
        expect(find.byType(ScannerScreen), findsNothing);
        expect(
          find.text('Creating codes arrives in the next test build.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          1,
        );

        // History is the real list now (HIS-1), no longer a placeholder.
        await tester.tap(find.byKey(AppShell.historyTabKey));
        await tester.pumpAndSettle();
        expect(find.byType(HistoryScreen), findsOneWidget);
        expect(find.byType(PlaceholderTab), findsNothing);

        await tester.tap(find.byKey(AppShell.settingsTabKey));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
        expect(find.byType(PlaceholderTab), findsNothing);

        await tester.tap(find.byKey(AppShell.scanTabKey));
        await tester.pumpAndSettle();
        expect(find.byType(ScannerScreen), findsOneWidget);
        expect(find.text('Allow camera'), findsOneWidget);
      },
    );

    testWidgets('SCAN-1: the placeholders read in Arabic', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        const ScannerScope(child: AppShell()),
        locale: const Locale('ar'),
      );

      await tester.tap(find.byKey(AppShell.createTabKey));
      await tester.pumpAndSettle();
      expect(
        find.text('يصل إنشاء الرموز في النسخة التجريبية التالية.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(AppShell.historyTabKey));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(HistoryScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets(
      'SCAN-6, SCAN-7: leaving Scan stops the camera and the torch, and coming '
      'back starts it again with auto-zoom back on',
      (WidgetTester tester) async {
        final NoopCameraScanner camera = NoopCameraScanner();
        await pumpApp(
          tester,
          const ScannerScope(child: AppShell()),
          services: AppServices.fakes().copyWith(
            permissions: NoopPermissionService(
              initialState: CameraPermissionState.granted,
            ),
            cameraScanner: camera,
          ),
        );
        expect(camera.isRunning, isTrue);

        await tester.tap(find.byKey(ScannerKeys.torch));
        await _doubleTap(tester, find.byKey(ScannerKeys.viewfinder));
        expect(camera.torchState, TorchState.on);
        expect(camera.autoZoomEnabled, isFalse);

        await tester.tap(find.byKey(AppShell.settingsTabKey));
        await tester.pumpAndSettle();

        expect(camera.isRunning, isFalse);
        expect(camera.torchState, TorchState.off);

        await tester.tap(find.byKey(AppShell.scanTabKey));
        await tester.pumpAndSettle();

        expect(camera.isRunning, isTrue);
        expect(camera.autoZoomEnabled, isTrue);
        expect(find.text('Point the camera at a code'), findsOneWidget);
      },
    );

    testWidgets('back on another tab returns to Scan instead of leaving', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, const ScannerScope(child: AppShell()));

      await tester.tap(find.byKey(AppShell.historyTabKey));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ScannerScreen), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
    });
  });
}

/// Two taps close enough together to be a double-tap.
Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 60));
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
