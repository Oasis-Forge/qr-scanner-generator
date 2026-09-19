import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/event_section.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';

import 'section_test_helpers.dart';

const String _event =
    'BEGIN:VEVENT\nSUMMARY:Standup\nDTSTART:20261016T090000\n'
    'DTEND:20261016T093000\nLOCATION:Room 1\nDESCRIPTION:Bring the roadmap\n'
    'END:VEVENT';

void main() {
  group('EventSection (RES-6)', () {
    testWidgets(
      'shows the title, start, end, location and notes, times in words with '
      'the encoded numbers (LANG-3, DATE-3)',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(_event, parsedType: ParsedType.event),
        );
        await pumpSection(
          tester,
          state,
          EventSection(event: state.payload as CalendarEvent),
        );

        expect(find.text('Standup'), findsOneWidget);
        // Friday 16 October 2026, 9:00 and 9:30, as encoded: never shifted.
        expect(find.textContaining('Oct 16, 2026'), findsNWidgets(2));
        expect(find.textContaining('9:00'), findsOneWidget);
        expect(find.textContaining('9:30'), findsOneWidget);
        expect(find.textContaining('20261016T'), findsNothing);
        expect(find.text('Room 1'), findsOneWidget);
        expect(find.text('Bring the roadmap'), findsOneWidget);
      },
    );

    testWidgets('an all-day event shows the all-day note', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'BEGIN:VEVENT\nSUMMARY:Conference\nDTSTART;VALUE=DATE:20261016\n'
          'END:VEVENT',
          parsedType: ParsedType.event,
        ),
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      expect(find.text('All-day event.'), findsOneWidget);
    });

    testWidgets('an event with no end shows no End row', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'BEGIN:VEVENT\nSUMMARY:Reminder\nDTSTART:20261016T090000\n'
          'END:VEVENT',
          parsedType: ParsedType.event,
        ),
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      expect(find.text('End'), findsNothing);
    });

    testWidgets('the primary action hands the event to insertCalendarEvent', (
      WidgetTester tester,
    ) async {
      final NoopSystemIntents intents = NoopSystemIntents();
      final ResultState state = resultStateFor(
        outcomeFor(_event, parsedType: ParsedType.event),
        systemIntents: intents,
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      await tester.tap(find.text('Add to calendar'));
      await tester.pumpAndSettle();

      expect(
        intents.calls.where((String c) => c.startsWith('insertCalendarEvent')),
        hasLength(1),
      );
      expect(
        intents.calls,
        contains(startsWith('insertCalendarEvent: Standup')),
      );
    });

    testWidgets(
      'RES-14: with no calendar app, the primary action is disabled with a '
      'reason',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(_event, parsedType: ParsedType.event),
          systemIntents: NoopSystemIntents(
            unhandled: <SystemHandOff>{SystemHandOff.insertCalendarEvent},
          ),
        );
        await pumpSection(
          tester,
          state,
          EventSection(event: state.payload as CalendarEvent),
        );

        final FilledButton button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add to calendar'),
        );
        expect(button.onPressed, isNull);
        expect(find.text('No calendar app is installed.'), findsOneWidget);
      },
    );

    testWidgets('DATE-3: a UTC time says UTC and keeps its numbers', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'BEGIN:VEVENT\nSUMMARY:Call\nDTSTART:20261016T090000Z\nEND:VEVENT',
          parsedType: ParsedType.event,
        ),
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      expect(find.textContaining('9:00'), findsOneWidget);
      expect(find.textContaining('UTC'), findsOneWidget);
    });

    testWidgets('DATE-3: a TZID time names its zone and keeps its numbers', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          'BEGIN:VEVENT\nSUMMARY:Call\n'
          'DTSTART;TZID=Europe/Paris:20261016T090000\nEND:VEVENT',
          parsedType: ParsedType.event,
        ),
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      expect(find.textContaining('9:00'), findsOneWidget);
      expect(find.textContaining('(Europe/Paris)'), findsOneWidget);
    });

    testWidgets('RES-14: an event with no start shows no empty rows, and Add '
        'to calendar is disabled with the reason', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor('BEGIN:VEVENT\nEND:VEVENT', parsedType: ParsedType.event),
      );
      await pumpSection(
        tester,
        state,
        EventSection(event: state.payload as CalendarEvent),
      );

      expect(find.text('Title'), findsNothing);
      expect(find.text('Start'), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Add to calendar'),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.text("This event has no start time, so it can't be added."),
        findsOneWidget,
      );
    });
  });
}
