import '../models/parsed_payload.dart';
import 'text_encoding.dart';

/// Parses a `BEGIN:VEVENT` (bare) or the first `VEVENT` inside a
/// `BEGIN:VCALENDAR` payload into a [CalendarEvent] (RES-6).
///
/// Unfolds continuation lines first, then reads `SUMMARY`, `DTSTART`,
/// `DTEND`, `LOCATION` and `DESCRIPTION`. `DTSTART` and `DTEND` are kept
/// exactly as encoded — floating, a trailing `Z` for UTC, or `TZID`-qualified
/// — and never converted to a [DateTime] or another time zone (DATE-3). A
/// block with none of these lines, or no `VEVENT` at all inside a
/// `VCALENDAR`, still returns an empty [CalendarEvent] rather than falling
/// back to another type, matching `classifyPayload`, which classifies the
/// header alone.
CalendarEvent parseICalendarEvent(String text) {
  final List<String> eventLines = _eventBlockOf(unfoldLines(text).split('\n'));

  String? summary;
  String? location;
  String? notes;
  String startRaw = '';
  String? startTzid;
  bool startIsDate = false;
  String? endRaw;
  String? endTzid;

  for (final String rawLine in eventLines) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final PropertyLine? property = parsePropertyLine(line);
    if (property == null) {
      continue;
    }
    switch (property.name) {
      case 'SUMMARY':
        summary = unescapeIcsText(property.value);
      case 'LOCATION':
        location = unescapeIcsText(property.value);
      case 'DESCRIPTION':
        notes = unescapeIcsText(property.value);
      case 'DTSTART':
        startRaw = property.value;
        startTzid = property.params['TZID'];
        startIsDate = _isDateOnly(property.value, property.params);
      case 'DTEND':
        endRaw = property.value;
        endTzid = property.params['TZID'];
    }
  }

  return CalendarEvent(
    title: summary ?? '',
    start: startRaw,
    startTzid: startTzid,
    end: endRaw,
    endTzid: endTzid,
    allDay: startIsDate,
    location: location,
    notes: notes,
  );
}

/// The lines strictly between the first `BEGIN:VEVENT` and the next
/// `END:VEVENT` (a bare `VEVENT`'s own lines, or the first of several inside
/// a `VCALENDAR`). Empty when there is no `BEGIN:VEVENT` at all.
List<String> _eventBlockOf(List<String> lines) {
  int start = -1;
  for (int i = 0; i < lines.length; i++) {
    if (_isKeyword(lines[i], 'BEGIN:VEVENT')) {
      start = i + 1;
      break;
    }
  }
  if (start == -1) {
    return const <String>[];
  }
  int end = lines.length;
  for (int i = start; i < lines.length; i++) {
    if (_isKeyword(lines[i], 'END:VEVENT')) {
      end = i;
      break;
    }
  }
  return lines.sublist(start, end);
}

bool _isKeyword(String line, String keyword) =>
    line.trim().toUpperCase() == keyword;

/// Whether a `DTSTART`/`DTEND` value is a date with no time: `VALUE=DATE`,
/// or (some generators omit the parameter) an 8-digit `YYYYMMDD` value.
bool _isDateOnly(String raw, Map<String, String> params) {
  if (params['VALUE']?.toUpperCase() == 'DATE') {
    return true;
  }
  return RegExp(r'^\d{8}$').hasMatch(raw.trim());
}
