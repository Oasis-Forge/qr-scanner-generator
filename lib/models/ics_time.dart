/// A date or date-time from an iCalendar field, kept as the numbers it was
/// written with (DATE-3): nothing here converts between time zones.
///
/// [kind] says how to read the numbers: a date with no time, a floating
/// local time, a UTC time (`Z`), or a time in the zone [tzid] names.
enum IcsTimeKind { date, floating, utc, zoned }

class IcsTime {
  const IcsTime({
    required this.year,
    required this.month,
    required this.day,
    required this.kind,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.tzid,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final IcsTimeKind kind;

  /// The zone a [IcsTimeKind.zoned] time is written in, such as
  /// `Europe/Paris`.
  final String? tzid;

  bool get hasTime => kind != IcsTimeKind.date;

  /// The same numbers as a [DateTime], for formatting only: its own zone is
  /// never consulted, so printing it shows the encoded wall-clock values.
  DateTime get wallClock => DateTime(year, month, day, hour, minute, second);
}

final RegExp _icsDate = RegExp(r'^(\d{4})(\d{2})(\d{2})$');
final RegExp _icsDateTime = RegExp(
  r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})?(Z)?$',
);

/// Reads an iCalendar `DATE` (`20261001`) or `DATE-TIME` (`20261001T090000`,
/// `20261001T090000Z`, or zoned by [tzid]). Returns null for anything else,
/// or for numbers that aren't a real date, so a caller can fall back to the
/// raw text.
IcsTime? parseIcsTime(String raw, {String? tzid}) {
  final String text = raw.trim();
  final RegExpMatch? date = _icsDate.firstMatch(text);
  if (date != null) {
    return _checked(
      IcsTime(
        year: int.parse(date.group(1)!),
        month: int.parse(date.group(2)!),
        day: int.parse(date.group(3)!),
        kind: IcsTimeKind.date,
      ),
    );
  }
  final RegExpMatch? dateTime = _icsDateTime.firstMatch(text);
  if (dateTime == null) {
    return null;
  }
  final bool utc = dateTime.group(7) != null;
  final bool zoned = !utc && tzid != null && tzid.trim().isNotEmpty;
  return _checked(
    IcsTime(
      year: int.parse(dateTime.group(1)!),
      month: int.parse(dateTime.group(2)!),
      day: int.parse(dateTime.group(3)!),
      hour: int.parse(dateTime.group(4)!),
      minute: int.parse(dateTime.group(5)!),
      second: int.parse(dateTime.group(6) ?? '0'),
      kind: utc
          ? IcsTimeKind.utc
          : zoned
          ? IcsTimeKind.zoned
          : IcsTimeKind.floating,
      tzid: zoned ? tzid.trim() : null,
    ),
  );
}

IcsTime? _checked(IcsTime time) {
  final DateTime probe = time.wallClock;
  final bool real =
      probe.year == time.year &&
      probe.month == time.month &&
      probe.day == time.day &&
      time.hour < 24 &&
      time.minute < 60 &&
      time.second < 61;
  return real ? time : null;
}
