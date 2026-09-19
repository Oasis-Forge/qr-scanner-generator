import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/ics_time.dart';

void main() {
  group('parseIcsTime keeps the encoded numbers (DATE-3)', () {
    test('a floating time is read as written, with no zone', () {
      final IcsTime time = parseIcsTime('20261001T090000')!;
      expect(time.kind, IcsTimeKind.floating);
      expect(time.wallClock, DateTime(2026, 10, 1, 9));
      expect(time.tzid, isNull);
    });

    test('a UTC time keeps its numbers and is marked UTC, never shifted', () {
      final IcsTime time = parseIcsTime('20261001T090000Z')!;
      expect(time.kind, IcsTimeKind.utc);
      expect(time.hour, 9);
      expect(time.wallClock, DateTime(2026, 10, 1, 9));
    });

    test('a TZID time keeps its numbers and names its zone', () {
      final IcsTime time = parseIcsTime(
        '20261001T090000',
        tzid: 'Europe/Paris',
      )!;
      expect(time.kind, IcsTimeKind.zoned);
      expect(time.tzid, 'Europe/Paris');
      expect(time.hour, 9);
    });

    test('a date alone is an all-day date with no time', () {
      final IcsTime time = parseIcsTime('20261001')!;
      expect(time.kind, IcsTimeKind.date);
      expect(time.hasTime, isFalse);
    });

    test('seconds are optional', () {
      expect(parseIcsTime('20261001T0930')!.minute, 30);
    });

    test('anything else is null, so the raw text is shown instead', () {
      expect(parseIcsTime(''), isNull);
      expect(parseIcsTime('next Tuesday'), isNull);
      expect(parseIcsTime('20261341T090000'), isNull); // no 41st of the 13th
      expect(parseIcsTime('20261001T250000'), isNull); // no 25 o'clock
    });
  });
}
