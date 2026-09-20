import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:qrscanner/screens/history/history_date_header.dart';
import 'package:qrscanner/state/history_state.dart';

import '../../helpers/test_app.dart';

/// [HistoryHeader.of]'s four kinds computed from real local "now", so the
/// expected weekday and date strings below are worked out with the same
/// [intl.DateFormat] the extension uses, rather than a literal that could
/// name the wrong day on a test machine in another time zone.
void main() {
  testWidgets(
    'HistoryHeaderLabel formats "Today", "Yesterday", a weekday name within '
    '7 days, and a date beyond that (HIS-3, DATE-2)',
    (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      final HistoryHeader today = HistoryHeader.of(now, now);
      final HistoryHeader yesterday = HistoryHeader.of(
        now.subtract(const Duration(days: 1)),
        now,
      );
      final HistoryHeader weekday = HistoryHeader.of(
        now.subtract(const Duration(days: 3)),
        now,
      );
      final HistoryHeader date = HistoryHeader.of(
        now.subtract(const Duration(days: 10)),
        now,
      );

      await pumpApp(
        tester,
        Scaffold(
          body: Column(
            children: <Widget>[
              HistoryDateHeader(header: today),
              HistoryDateHeader(header: yesterday),
              HistoryDateHeader(header: weekday),
              HistoryDateHeader(header: date),
            ],
          ),
        ),
      );

      // A day is labelled in the app's monospaced voice, in capitals.
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(
        find.text(intl.DateFormat.EEEE('en').format(weekday.day).toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(intl.DateFormat.yMMMMd('en').format(date.day).toUpperCase()),
        findsOneWidget,
      );
    },
  );
}
