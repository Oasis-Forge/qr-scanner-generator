import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/l10n/app_localizations.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/screens/app_shell.dart';
import 'package:qrscanner/screens/history_screen.dart';
import 'package:qrscanner/screens/manual_entry_screen.dart';
import 'package:qrscanner/screens/placeholder_tab.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/screens/scanner_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/scanner_state.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../helpers/fake_stores.dart';
import '../helpers/test_app.dart';
import '../screens/history/history_harness_data.dart';
import 'scanner_scope.dart';

/// Every screen and sheet the scanner PR adds, for the accessibility and
/// text-size harnesses (A11Y-1, A11Y-2, A11Y-4, LANG-6).
///
/// Both harnesses run these next to `harnessScreens` from
/// `test/helpers/test_app.dart`, in every language the message files ship, at
/// the system text size and at 200%. The scanner is rendered in each of its
/// phases (RUN-1, RUN-4, RUN-6, RUN-7, a camera that won't start) and with each
/// of its sheets open (SCAN-11, SCAN-13), since every phase is a different
/// screen to the user.
final List<HarnessScreen> scannerHarnessScreens = <HarnessScreen>[
  HarnessScreen(
    name: 'the app shell on the Scan tab',
    build: () => const ScannerScope(child: AppShell()),
    readableText: const <String, String>{'en': 'Create', 'ar': 'إنشاء'},
  ),
  HarnessScreen(
    name: 'the scanner asking for the camera (RUN-1)',
    build: () => const ScannerScope(child: ScannerScreen()),
    readableText: const <String, String>{
      'en': 'Allow camera',
      'ar': 'السماح بالكاميرا',
    },
  ),
  HarnessScreen(
    name: 'the scanner after a denial (RUN-4)',
    build: () => ScannerScope(
      services: _scannerServices(
        permissions: NoopPermissionService(
          requestedBefore: true,
          showsRationale: true,
        ),
      ),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': 'Scan a photo',
      'ar': 'مسح صورة',
    },
  ),
  HarnessScreen(
    name: 'the scanner once Android stops asking (RUN-6)',
    build: () => ScannerScope(
      services: _scannerServices(
        permissions: NoopPermissionService(requestedBefore: true),
      ),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': 'Open settings',
      'ar': 'فتح الإعدادات',
    },
  ),
  HarnessScreen(
    name: 'the scanner when the camera does not start',
    build: () => ScannerScope(
      services: _scannerServices(
        camera: NoopCameraScanner(startSucceeds: false),
      ),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': 'The camera could not start. Another app may be using it.',
      'ar': 'تعذّر تشغيل الكاميرا. ربما يستخدمها تطبيق آخر.',
    },
  ),
  HarnessScreen(
    name: 'the live scanner (RUN-7)',
    build: () => ScannerScope(
      services: _scannerServices(),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': 'Point the camera at a code',
      'ar': 'وجّه الكاميرا نحو رمز',
    },
  ),
  HarnessScreen(
    name: 'the list of codes over the live scanner (SCAN-13)',
    build: () => ScannerScope(
      services: _scannerServices(
        imageDecoder: NoopImageDecoder(
          result: const ImageDecodeResult(<CodeDetection>[
            CodeDetection(
              payload:
                  'https://example.com/a/very/long/path/that/goes/on/and/on',
              symbology: 'qr',
            ),
            CodeDetection(payload: '4006381333931', symbology: 'ean13'),
          ]),
        ),
      ),
      onCreated: (ScannerState scanner) => scanner.pickPhoto(),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': '2 codes found',
      'ar': 'تم العثور على رمزين',
    },
  ),
  HarnessScreen(
    name: '"No code found" over the live scanner (SCAN-11)',
    build: () => ScannerScope(
      services: _scannerServices(),
      onCreated: (ScannerState scanner) => scanner.pickPhoto(),
      child: const ScannerScreen(),
    ),
    readableText: const <String, String>{
      'en': 'No code found',
      'ar': 'لم يُعثر على رمز',
    },
  ),
  HarnessScreen(
    name: 'a link result (RES-1)',
    build: () => ResultScreen(
      outcome: ScanOutcome(
        record: aScanRecord(
          payloadText:
              'https://example.com/a/link/long/enough/to/wrap/onto/a/second/'
              'line/at/any/text/size?with=a&query=string',
        ),
        parsedType: ParsedType.url,
        symbology: Symbology.qr,
        source: RecordSource.camera,
        isSaved: true,
      ),
    ),
    readableText: const <String, String>{
      'en': 'Link · QR code',
      'ar': 'رابط · رمز QR',
    },
  ),
  HarnessScreen(
    name: 'a binary result that could not be saved (RES-13)',
    build: () => ResultScreen(
      outcome: ScanOutcome(
        record: aScanRecord(
          parsedType: ParsedType.unknown,
          payloadText: '��',
          payloadBytes: Uint8List.fromList(<int>[0xFF, 0xFE, 0x00]),
        ),
        parsedType: ParsedType.unknown,
        symbology: Symbology.qr,
        source: RecordSource.camera,
        isSaved: false,
        saveFailed: true,
      ),
    ),
    readableText: const <String, String>{
      'en': 'Binary data, 3 bytes',
      'ar': 'بيانات ثنائية، 3 بايتات',
    },
  ),
  HarnessScreen(
    name: 'typed entry (SCAN-12)',
    build: () => const ManualEntryScreen(),
    readableText: const <String, String>{
      'en': 'Code content',
      'ar': 'محتوى الرمز',
    },
  ),
  HarnessScreen(
    name: 'the Create tab placeholder',
    build: () => Builder(
      builder: (BuildContext context) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return PlaceholderTab(
          title: l10n.navCreate,
          message: l10n.placeholderCreateMessage,
          icon: Icons.add_box_outlined,
        );
      },
    ),
    readableText: const <String, String>{
      'en': 'Creating codes arrives in the next test build.',
      'ar': 'يصل إنشاء الرموز في النسخة التجريبية التالية.',
    },
  ),
  HarnessScreen(
    name: 'the History screen, empty (HIS-11)',
    build: () => _historyScreen(const <ScanRecord>[]),
    readableText: const <String, String>{
      'en': 'Codes you scan or create will show up here.',
      'ar': 'ستظهر هنا الرموز التي تمسحها أو تنشئها.',
    },
  ),
  HarnessScreen(
    name: 'the History screen, with rows (HIS-4)',
    build: () => _historyScreen(historyHarnessRecords()),
    // A link's content is never translated (LANG-5): the same string proves
    // the screen drew its rows in either language.
    readableText: const <String, String>{
      'en': 'https://example.com/harness',
      'ar': 'https://example.com/harness',
    },
  ),
];

/// A [HistoryScreen] over [records], provided the [HistoryState] the harness
/// cannot get from `pumpApp` alone (`test/helpers/test_app.dart` knows
/// nothing about History).
Widget _historyScreen(List<ScanRecord> records) {
  return ChangeNotifierProvider<HistoryState>(
    create: (BuildContext context) => HistoryState(
      records: StaticHistoryRecordDao(records),
      settings: context.read<SettingsState>(),
    ),
    child: const HistoryScreen(
      onSwitchToScan: _doNothing,
      onSwitchToCreate: _doNothing,
      onSwitchToSettings: _doNothing,
    ),
  );
}

void _doNothing() {}

/// Every screen both harnesses run: the ones `test_app.dart` registers and the
/// scanner PR's.
List<HarnessScreen> get allHarnessScreens => <HarnessScreen>[
  ...harnessScreens,
  ...scannerHarnessScreens,
];

/// The no-op services with the camera allowed, unless [permissions] says
/// otherwise, and any other scanner service swapped in.
AppServices _scannerServices({
  PermissionService? permissions,
  CameraScanner? camera,
  ImageDecoder? imageDecoder,
}) => AppServices.fakes().copyWith(
  permissions:
      permissions ??
      NoopPermissionService(initialState: CameraPermissionState.granted),
  cameraScanner: camera,
  imageDecoder: imageDecoder,
);
