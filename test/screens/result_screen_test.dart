import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/l10n/app_localizations.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/contact_section.dart';
import 'package:qrscanner/screens/result/product_section.dart';
import 'package:qrscanner/screens/result/result_actions.dart';
import 'package:qrscanner/screens/result/wifi_section.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/screens/scanner/code_labels.dart';
import 'package:qrscanner/screens/scanner/payload_text.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../helpers/fake_stores.dart';
import '../helpers/test_app.dart';

/// A link long enough to wrap over several lines at any text size, so a
/// result that cut it short would show.
const String longLink =
    'https://example.com/a/very/long/path/that/keeps/going/and/going/past/the/'
    'edge/of/any/phone/screen/in/either/direction?query=string&with=several'
    '&parameters=that/also/matter&because=the/whole/thing/must/show';

void main() {
  group('ResultScreen (RES-1 to RES-3)', () {
    testWidgets(
      'RES-1: shows the type and format in words, the full content with '
      'nothing cut, and Copy (primary) and Share',
      (WidgetTester tester) async {
        await pumpApp(tester, ResultScreen(outcome: _outcome()));

        expect(find.text('Link · QR code'), findsOneWidget);
        expect(find.text(longLink), findsOneWidget);
        final SelectableText content = tester.widget<SelectableText>(
          find.byType(SelectableText),
        );
        expect(content.maxLines, isNull);
        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Result'), findsOneWidget);
      },
    );

    testWidgets('RES-1: the primary action is at least 1.4x '
        'AppTheme.minTapTargetSize tall', (WidgetTester tester) async {
      await pumpApp(tester, ResultScreen(outcome: _outcome()));

      final Size primary = tester.getSize(
        find.widgetWithText(FilledButton, 'Copy'),
      );
      expect(
        primary.height,
        greaterThanOrEqualTo(ResultPrimaryButton.minHeight - 0.01),
      );
      expect(
        ResultPrimaryButton.minHeight,
        greaterThanOrEqualTo(AppTheme.minTapTargetSize * 1.4 - 0.01),
      );
    });

    testWidgets(
      'LANG-5: in Arabic the type line is Arabic, the screen is right to '
      'left, and the link stays left to right',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          ResultScreen(outcome: _outcome()),
          locale: const Locale('ar'),
        );

        expect(find.text('رابط · رمز QR'), findsOneWidget);
        expect(find.text('نسخ'), findsOneWidget);
        expect(find.text('مشاركة'), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(ResultScreen))),
          TextDirection.rtl,
        );
        expect(
          tester.widget<PayloadText>(find.byType(PayloadText)).direction,
          TextDirection.ltr,
        );
        expect(
          tester
              .widget<SelectableText>(find.byType(SelectableText))
              .textDirection,
          TextDirection.ltr,
        );
      },
    );

    testWidgets(
      'LANG-5: a plain-text payload written in Arabic reads right to left',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          ResultScreen(
            outcome: _outcome(
              payloadText: 'مرحبًا بكم في المتجر',
              parsedType: ParsedType.text,
            ),
          ),
        );

        expect(find.text('Text · QR code'), findsOneWidget);
        expect(
          tester.widget<PayloadText>(find.byType(PayloadText)).direction,
          TextDirection.rtl,
        );
      },
    );

    testWidgets('DATA-1: a typed code shows its type alone, with no format', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        ResultScreen(
          outcome: _outcome(
            payloadText: 'Hello',
            parsedType: ParsedType.text,
            symbology: Symbology.unknown,
            source: RecordSource.manual,
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.byKey(ResultScreen.typeLineKey)).data,
        'Text',
      );
    });

    testWidgets(
      'RES-1: Copy puts the exact decoded text on the clipboard and says so',
      (WidgetTester tester) async {
        final TestApp app = await pumpApp(
          tester,
          ResultScreen(outcome: _outcome()),
        );
        final NoopClipboardService clipboard =
            app.services.clipboard as NoopClipboardService;

        await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
        await tester.pumpAndSettle();

        expect(clipboard.calls, <String>['copyText: $longLink']);
        expect(find.text('Copied the link'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      },
    );

    testWidgets('RES-1: the copy confirmation reads in Arabic', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        ResultScreen(
          outcome: _outcome(payloadText: 'Hello', parsedType: ParsedType.text),
        ),
        locale: const Locale('ar'),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'نسخ'));
      await tester.pumpAndSettle();

      expect(find.text('تم نسخ المحتوى'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets(
      'RES-1: Share hands the exact decoded text to the share sheet',
      (WidgetTester tester) async {
        final TestApp app = await pumpApp(
          tester,
          ResultScreen(outcome: _outcome()),
        );

        await tester.tap(find.widgetWithText(OutlinedButton, 'Share'));
        await tester.pumpAndSettle();

        expect((app.services.share as NoopShareService).calls, <String>[
          'shareText: $longLink',
        ]);
      },
    );

    testWidgets('RES-1: Copy and Share are at least 48 x 48 dp (A11Y-2)', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, ResultScreen(outcome: _outcome()));

      for (final Finder finder in <Finder>[
        find.widgetWithText(FilledButton, 'Copy'),
        find.widgetWithText(OutlinedButton, 'Share'),
      ]) {
        final Size size = tester.getSize(finder);
        expect(size.width, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
        expect(size.height, greaterThanOrEqualTo(AppTheme.minTapTargetSize));
      }
    });

    testWidgets(
      'RES-13: a payload that is not text reads "Binary data, N bytes"',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          ResultScreen(
            outcome: _outcome(
              payloadText: '��',
              payloadBytes: Uint8List.fromList(<int>[0xFF, 0xFE, 0x00]),
              parsedType: ParsedType.unknown,
            ),
          ),
        );

        expect(find.text('Unknown · QR code'), findsOneWidget);
        expect(find.text('Binary data, 3 bytes'), findsOneWidget);
        expect(find.text('��'), findsNothing);
      },
    );

    testWidgets('DATA-4: a scan that could not be saved says so, and still '
        'works', (WidgetTester tester) async {
      final TestApp app = await pumpApp(
        tester,
        ResultScreen(outcome: _outcome(isSaved: false, saveFailed: true)),
      );

      expect(
        find.text('This scan could not be saved to History.'),
        findsOneWidget,
      );
      // The warning carries an icon as well as its colour (A11Y-6).
      expect(
        find.descendant(
          of: find.byKey(ResultScreen.notSavedKey),
          matching: find.byIcon(Icons.error_outline),
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
      await tester.pumpAndSettle();
      expect((app.services.clipboard as NoopClipboardService).calls, <String>[
        'copyText: $longLink',
      ]);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('a saved scan shows no warning', (WidgetTester tester) async {
      await pumpApp(tester, ResultScreen(outcome: _outcome()));

      expect(find.byKey(ResultScreen.notSavedKey), findsNothing);
    });
  });

  group('RES-4 to RES-13: each type opens its own section', () {
    testWidgets('a Wi-Fi scan opens WifiSection', (WidgetTester tester) async {
      await pumpApp(
        tester,
        ResultScreen(
          outcome: _outcome(
            payloadText: 'WIFI:T:WPA;S:Home;P:secret;;',
            parsedType: ParsedType.wifi,
          ),
        ),
      );

      expect(find.byType(WifiSection), findsOneWidget);
    });

    testWidgets('a contact scan opens ContactSection', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        ResultScreen(
          outcome: _outcome(
            payloadText: 'BEGIN:VCARD\nVERSION:3.0\nFN:Ada\nEND:VCARD',
            parsedType: ParsedType.contact,
          ),
        ),
      );

      expect(find.byType(ContactSection), findsOneWidget);
    });

    testWidgets('a product scan opens ProductSection', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        ResultScreen(
          outcome: _outcome(
            payloadText: '4006381333931',
            parsedType: ParsedType.product,
            symbology: Symbology.ean13,
          ),
        ),
      );

      expect(find.byType(ProductSection), findsOneWidget);
    });
  });

  group('nothing happens without a tap (RES-2, SET-3)', () {
    testWidgets('RES-2: opening a link result opens no link, no system app, no '
        'share sheet, and copies nothing while Copy on scan is off', (
      WidgetTester tester,
    ) async {
      final TestApp app = await _openThroughARoute(tester);
      final AppServices services = app.services;

      expect(find.byType(ResultScreen), findsOneWidget);
      expect((services.linkOpener as NoopLinkOpener).calls, isEmpty);
      expect((services.systemIntents as NoopSystemIntents).calls, isEmpty);
      expect((services.share as NoopShareService).calls, isEmpty);
      expect((services.clipboard as NoopClipboardService).calls, isEmpty);
    });

    testWidgets(
      'RES-2, RES-14: opening a Wi-Fi result asks canHandle once, and takes '
      'no action itself',
      (WidgetTester tester) async {
        final NoopSystemIntents intents = NoopSystemIntents();
        await pumpApp(
          tester,
          ResultScreen(
            outcome: _outcome(
              payloadText: 'WIFI:T:WPA;S:Home;P:secret;;',
              parsedType: ParsedType.wifi,
            ),
          ),
          services: AppServices.fakes().copyWith(systemIntents: intents),
        );

        expect(intents.calls, <String>['canHandle: wifiSettings']);
      },
    );

    testWidgets(
      'SET-3, RES-2: with Copy on scan on, the text is copied once the result '
      'has finished coming on screen, never before, and a snackbar says so',
      (WidgetTester tester) async {
        final TestApp app = await _openThroughARoute(
          tester,
          copyOnScan: true,
          settle: false,
        );
        final NoopClipboardService clipboard =
            app.services.clipboard as NoopClipboardService;

        // The result is built and sliding in: nothing is copied yet. Frames
        // without advancing the clock leave its entrance animation unmoved.
        for (
          var i = 0;
          i < 10 && find.byType(ResultScreen).evaluate().isEmpty;
          i++
        ) {
          await tester.pump();
        }
        expect(find.byType(ResultScreen), findsOneWidget);
        expect(clipboard.calls, isEmpty);
        await tester.pump(const Duration(milliseconds: 50));
        expect(clipboard.calls, isEmpty);

        await tester.pumpAndSettle();

        expect(clipboard.calls, <String>['copyText: $longLink']);
        expect(find.text('Copied the link'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        // Once, not on every rebuild.
        expect(clipboard.calls, hasLength(1));
      },
    );

    testWidgets(
      'SET-3: a record reopened from History is not copied on open, even with '
      'Copy on scan on',
      (WidgetTester tester) async {
        final TestApp app = await _openThroughARoute(
          tester,
          copyOnScan: true,
          isReopened: true,
        );

        expect(find.byType(ResultScreen), findsOneWidget);
        expect((app.services.clipboard as NoopClipboardService).calls, isEmpty);
      },
    );
  });

  group('labels (DATA-1)', () {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      test('DATA-1: every type and every format has its own label in '
          '${locale.languageCode}', () {
        final AppLocalizations l10n = lookupAppLocalizations(locale);

        final List<String> types = ParsedType.values
            .map(l10n.parsedTypeLabel)
            .toList();
        expect(types.every((String label) => label.trim().isNotEmpty), isTrue);
        expect(types.toSet(), hasLength(ParsedType.values.length));

        final List<String> formats = Symbology.values
            .map(l10n.symbologyLabel)
            .toList();
        expect(
          formats.every((String label) => label.trim().isNotEmpty),
          isTrue,
        );
        expect(formats.toSet(), hasLength(Symbology.values.length));
      });
    }

    test('DATA-1: the type labels are translated, not English in Arabic', () {
      final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
      final AppLocalizations ar = lookupAppLocalizations(const Locale('ar'));
      for (final ParsedType type in ParsedType.values) {
        expect(
          ar.parsedTypeLabel(type),
          isNot(en.parsedTypeLabel(type)),
          reason: '${type.id} has no Arabic label',
        );
      }
      expect(ar.symbologyLabel(Symbology.qr), 'رمز QR');
      expect(en.typeAndFormat(ParsedType.url, Symbology.qr), 'Link · QR code');
      expect(ar.typeAndFormat(ParsedType.url, Symbology.qr), 'رابط · رمز QR');
    });
  });
}

/// A scanned result, by default a saved camera scan of [longLink] in a QR
/// code; each test overrides only what it is about.
ScanOutcome _outcome({
  String payloadText = longLink,
  Uint8List? payloadBytes,
  ParsedType parsedType = ParsedType.url,
  Symbology symbology = Symbology.qr,
  RecordSource source = RecordSource.camera,
  bool isSaved = true,
  bool saveFailed = false,
}) => ScanOutcome(
  record: aScanRecord(
    payloadText: payloadText,
    payloadBytes: payloadBytes,
    parsedType: parsedType,
    symbology: symbology,
    source: source,
  ),
  parsedType: parsedType,
  symbology: symbology,
  source: source,
  isSaved: isSaved,
  saveFailed: saveFailed,
);

/// Opens the result the way the scanner does, as a route pushed over another
/// screen, so "on screen" means after the route has come in (SET-3).
Future<TestApp> _openThroughARoute(
  WidgetTester tester, {
  bool copyOnScan = false,
  bool isReopened = false,
  bool settle = true,
}) async {
  final TestApp app = await pumpApp(
    tester,
    _Host(ResultScreen(outcome: _outcome(), isReopened: isReopened)),
    stored: <String, String>{
      SettingsState.copyOnScanKey: copyOnScan ? '1' : '0',
    },
  );
  await tester.tap(find.byKey(_Host.openKey));
  if (settle) {
    await tester.pumpAndSettle();
  }
  return app;
}

/// A screen with one button that pushes [screen].
class _Host extends StatelessWidget {
  const _Host(this.screen);

  static const Key openKey = Key('test.open');

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: openKey,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (BuildContext _) => screen)),
          child: const Text('open'),
        ),
      ),
    );
  }
}
