import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/screens/history/history_row.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';

void main() {
  group('HistoryRow (HIS-4)', () {
    testWidgets('shows the content in bold when there is no label', (
      WidgetTester tester,
    ) async {
      await _pumpRow(
        tester,
        aScanRecord(payloadText: 'https://example.com/no-label'),
      );

      expect(find.text('https://example.com/no-label'), findsOneWidget);
      final Text title = tester.widget<Text>(
        find.text('https://example.com/no-label'),
      );
      expect(title.style?.fontWeight, FontWeight.bold);
    });

    testWidgets(
      'shows the label in bold and the content on a second line when a '
      'label is set (HIS-4)',
      (WidgetTester tester) async {
        await _pumpRow(
          tester,
          aScanRecord(
            payloadText: 'https://example.com/labelled',
            label: 'My favourite link',
          ),
        );

        expect(find.text('My favourite link'), findsOneWidget);
        expect(find.text('https://example.com/labelled'), findsOneWidget);
        final Text title = tester.widget<Text>(find.text('My favourite link'));
        expect(title.style?.fontWeight, FontWeight.bold);
      },
    );

    testWidgets(
      'shows ×N once the code has been seen 2 or more times (HIS-5)',
      (WidgetTester tester) async {
        await _pumpRow(tester, aScanRecord(duplicateCount: 1));
        expect(find.textContaining('×'), findsNothing);

        await _pumpRow(tester, aScanRecord(duplicateCount: 3));
        expect(find.textContaining('×3'), findsOneWidget);
      },
    );

    testWidgets('masks a Wi-Fi password in the row (HIS-7, DATA-5)', (
      WidgetTester tester,
    ) async {
      await _pumpRow(
        tester,
        aScanRecord(
          parsedType: ParsedType.wifi,
          payloadText: 'WIFI:T:WPA;S:HomeNet;P:letmein;;',
          sensitiveFields: const <String>[SensitiveFieldKeys.wifiPassword],
        ),
      );

      expect(find.textContaining('letmein'), findsNothing);
      expect(find.textContaining('••••••'), findsOneWidget);
      expect(find.textContaining('HomeNet'), findsOneWidget);
    });

    testWidgets('a tap calls onTap and a long-press calls onLongPress', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      int longPresses = 0;
      const Key rowKey = Key('history_row_harness');
      await pumpApp(
        tester,
        Scaffold(
          body: HistoryRow(
            key: rowKey,
            record: aScanRecord(),
            isSelectionMode: false,
            isSelected: false,
            onTap: () => taps++,
            onLongPress: () => longPresses++,
          ),
        ),
      );

      await tester.tap(find.byKey(rowKey));
      expect(taps, 1);
      expect(longPresses, 0);

      await tester.longPress(find.byKey(rowKey));
      expect(longPresses, 1);
    });

    testWidgets('shows a checkbox instead of the type icon in selection mode', (
      WidgetTester tester,
    ) async {
      await _pumpRow(tester, aScanRecord(), isSelectionMode: true);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}

Future<void> _pumpRow(
  WidgetTester tester,
  ScanRecord record, {
  bool isSelectionMode = false,
  bool isSelected = false,
}) async {
  await pumpApp(
    tester,
    Scaffold(
      body: HistoryRow(
        record: record,
        isSelectionMode: isSelectionMode,
        isSelected: isSelected,
        onTap: () {},
        onLongPress: () {},
      ),
    ),
  );
}
