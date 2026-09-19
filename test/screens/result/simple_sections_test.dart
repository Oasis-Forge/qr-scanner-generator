import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/link_section.dart';
import 'package:qrscanner/screens/result/location_section.dart';
import 'package:qrscanner/screens/result/plain_text_section.dart';
import 'package:qrscanner/screens/result/unknown_section.dart';
import 'package:qrscanner/state/result_state.dart';
import 'package:qrscanner/state/scan_outcome.dart';

import '../../helpers/fake_stores.dart';
import 'section_test_helpers.dart';

/// The types with no primary hand-off of their own yet: Copy is the
/// primary action, and Share is the one secondary (RES-1, LINK-1, RES-8,
/// RES-13).
void main() {
  group('PlainTextSection', () {
    testWidgets('shows the text, and reports content, not a link, when '
        'copied', (WidgetTester tester) async {
      final NoopClipboardService clipboard = NoopClipboardService();
      final ResultState state = resultStateFor(
        outcomeFor('Hello there', parsedType: ParsedType.text),
        clipboard: clipboard,
      );
      await pumpSection(
        tester,
        state,
        PlainTextSection(text: state.payload as PlainText),
      );

      expect(find.text('Hello there'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
      await tester.pumpAndSettle();

      expect(find.text('Copied the content'), findsOneWidget);
    });

    testWidgets('LANG-5: Arabic text reads right to left', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('مرحبًا بكم', parsedType: ParsedType.text),
      );
      await pumpSection(
        tester,
        state,
        PlainTextSection(text: state.payload as PlainText),
        locale: const Locale('ar'),
      );

      final SelectableText content = tester.widget<SelectableText>(
        find.widgetWithText(SelectableText, 'مرحبًا بكم'),
      );
      expect(content.textDirection, TextDirection.rtl);
    });
  });

  group('UnknownSection (RES-13)', () {
    testWidgets('a blank payload shows as empty text, not "Binary data"', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('   ', parsedType: ParsedType.unknown),
      );
      await pumpSection(
        tester,
        state,
        UnknownSection(unknown: state.payload as Unknown),
      );

      final Unknown unknown = state.payload as Unknown;
      expect(unknown.isBinary, isFalse);
      expect(find.textContaining('Binary data'), findsNothing);
    });

    testWidgets('shows "Binary data, N bytes" instead of the lossy text', (
      WidgetTester tester,
    ) async {
      final ScanOutcome outcome = ScanOutcome(
        record: aScanRecord(
          payloadText: '',
          payloadBytes: Uint8List.fromList(<int>[0xFF, 0xFE, 0x00]),
          parsedType: ParsedType.unknown,
        ),
        parsedType: ParsedType.unknown,
        symbology: Symbology.qr,
        source: RecordSource.camera,
        isSaved: true,
      );
      final ResultState state = resultStateFor(outcome);
      await pumpSection(
        tester,
        state,
        UnknownSection(unknown: state.payload as Unknown),
      );

      expect(find.text('Binary data, 3 bytes'), findsOneWidget);
    });

    testWidgets('only Copy and Share are offered', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('   ', parsedType: ParsedType.unknown),
      );
      await pumpSection(
        tester,
        state,
        UnknownSection(unknown: state.payload as Unknown),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });

  group('LocationSection (RES-8, ships later)', () {
    testWidgets('shows latitude, longitude and the label, LTR coordinates', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'geo:51.5,-0.12?q=51.5,-0.12(Big Ben)',
          parsedType: ParsedType.geo,
        ),
      );
      await pumpSection(
        tester,
        state,
        LocationSection(location: state.payload as Location),
      );

      expect(find.text('51.5'), findsOneWidget);
      expect(find.text('-0.12'), findsOneWidget);
      expect(find.text('Big Ben'), findsOneWidget);
      expect(find.text('Search the web'), findsNothing);
      final FilledButton primary = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Copy'),
      );
      expect(primary.onPressed, isNotNull);
    });
  });

  group('a share that fails says so', () {
    testWidgets('Share reports failure through the snackbar', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor('https://example.com', parsedType: ParsedType.url),
        share: _ThrowingShareService(),
      );
      await pumpSection(
        tester,
        state,
        LinkSection(link: state.payload as Link),
      );

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(find.text('Could not open sharing. Try again.'), findsOneWidget);
    });
  });
}

class _ThrowingShareService implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) =>
      throw StateError('share sheet refused');

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  }) => throw StateError('share sheet refused');

  @override
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) => throw StateError('share sheet refused');
}
