/// A hand-off the system app performs on the app's behalf.
///
/// Each one is a system app doing the work, so the app itself needs no contacts,
/// calendar, phone or SMS permission (RES-6, RES-7, RUN-2).
enum SystemHandOff {
  /// Insert a contact (`ACTION_INSERT`) (RES-6).
  insertContact,

  /// Insert a calendar event (`ACTION_INSERT`) (RES-6).
  insertCalendarEvent,

  /// Open the dialer prefilled, never placing the call (RES-7).
  dial,

  /// Open the email app prefilled, never sending (RES-7).
  email,

  /// Open the messaging app prefilled, never sending (RES-7).
  sms,

  /// Open system Wi-Fi settings (RES-4).
  wifiSettings,

  /// Show coordinates in whichever maps app Android chooses (RES-8).
  location,
}

/// What became of a hand-off.
enum SystemHandOffOutcome {
  /// The system app took it over. Nothing was sent, dialled or saved by us.
  handedOff,

  /// No installed app can handle it, so the action shows disabled with a
  /// one-line reason and Copy stays available (RES-14).
  noHandler,

  failed,
}

/// A contact to hand to the system contacts app, exactly as encoded (RES-6).
///
/// A leading "+" on a phone number is kept (RES-6, GEN-7).
class ContactDraft {
  const ContactDraft({
    required this.name,
    this.phoneNumbers = const <String>[],
    this.emails = const <String>[],
    this.organisation,
  });

  final String name;
  final List<String> phoneNumbers;
  final List<String> emails;
  final String? organisation;
}

/// An event to hand to the system calendar app, exactly as encoded (RES-6).
///
/// [start] and [end] keep whatever the code carried — floating local time, UTC,
/// or a zoned time — and never shift with the device's time zone (DATE-3).
class CalendarEventDraft {
  const CalendarEventDraft({
    required this.title,
    required this.start,
    this.end,
    this.allDay = false,
    this.location,
    this.notes,
  });

  final String title;
  final DateTime start;
  final DateTime? end;
  final bool allDay;
  final String? location;
  final String? notes;
}

/// Hand-offs to the system's own apps.
///
/// Every one of these is a prefilled system app the user still has to confirm:
/// nothing is dialled, sent, joined or saved without a tap in that app (RES-2,
/// RES-7), and the app asks for no contacts or calendar permission (RES-6).
abstract class SystemIntents {
  /// Whether any installed app can handle [handOff], so a result action can be
  /// shown disabled with a reason instead of failing on tap (RES-14).
  Future<bool> canHandle(SystemHandOff handOff);

  /// Opens the system contacts app's insert form, prefilled (RES-6).
  Future<SystemHandOffOutcome> insertContact(ContactDraft contact);

  /// Opens the system calendar app's insert form, prefilled (RES-6, DATE-3).
  Future<SystemHandOffOutcome> insertCalendarEvent(CalendarEventDraft event);

  /// Opens the dialer with [phoneNumber], and never places the call (RES-7).
  Future<SystemHandOffOutcome> dial(String phoneNumber);

  /// Opens the email app prefilled, and never sends (RES-7, SET-8).
  Future<SystemHandOffOutcome> composeEmail({
    required List<String> to,
    String? subject,
    String? body,
  });

  /// Opens the messaging app prefilled, and never sends (RES-7).
  Future<SystemHandOffOutcome> composeSms({
    required String phoneNumber,
    String? message,
  });

  /// Opens system Wi-Fi settings (RES-4).
  Future<SystemHandOffOutcome> openWifiSettings();

  /// Shows [latitude], [longitude] and the optional [label] in whichever maps
  /// app Android chooses (RES-8).
  Future<SystemHandOffOutcome> showLocation({
    required double latitude,
    required double longitude,
    String? label,
  });
}

/// A [SystemIntents] that starts nothing.
///
/// It records every hand-off in [calls] with the fields it was handed, so a test
/// can assert that a contact kept its leading "+" or that an event carried its
/// times, and reports [outcome] ([SystemHandOffOutcome.handedOff] by default).
/// [unhandled] names the hand-offs no app can take, for RES-14's disabled
/// action.
class NoopSystemIntents implements SystemIntents {
  NoopSystemIntents({
    this.outcome = SystemHandOffOutcome.handedOff,
    Set<SystemHandOff> unhandled = const <SystemHandOff>{},
  }) : unhandled = Set<SystemHandOff>.unmodifiable(unhandled);

  /// Every call made, in order, such as `'dial: +49301234567'`.
  final List<String> calls = <String>[];

  /// What a handled hand-off reports.
  final SystemHandOffOutcome outcome;

  /// The hand-offs [canHandle] answers no for (RES-14).
  final Set<SystemHandOff> unhandled;

  @override
  Future<bool> canHandle(SystemHandOff handOff) async {
    calls.add('canHandle: ${handOff.name}');
    return !unhandled.contains(handOff);
  }

  @override
  Future<SystemHandOffOutcome> insertContact(ContactDraft contact) async {
    calls.add(
      'insertContact: ${contact.name} '
      '(phones: ${contact.phoneNumbers.join(', ')}; '
      'emails: ${contact.emails.join(', ')}; '
      'org: ${contact.organisation ?? ''})',
    );
    return _outcomeFor(SystemHandOff.insertContact);
  }

  @override
  Future<SystemHandOffOutcome> insertCalendarEvent(
    CalendarEventDraft event,
  ) async {
    calls.add(
      'insertCalendarEvent: ${event.title} '
      '(${event.start.toIso8601String()} to '
      '${event.end?.toIso8601String() ?? ''}; allDay: ${event.allDay})',
    );
    return _outcomeFor(SystemHandOff.insertCalendarEvent);
  }

  @override
  Future<SystemHandOffOutcome> dial(String phoneNumber) async {
    calls.add('dial: $phoneNumber');
    return _outcomeFor(SystemHandOff.dial);
  }

  @override
  Future<SystemHandOffOutcome> composeEmail({
    required List<String> to,
    String? subject,
    String? body,
  }) async {
    calls.add('composeEmail: ${to.join(', ')} (subject: ${subject ?? ''})');
    return _outcomeFor(SystemHandOff.email);
  }

  @override
  Future<SystemHandOffOutcome> composeSms({
    required String phoneNumber,
    String? message,
  }) async {
    calls.add('composeSms: $phoneNumber (message: ${message ?? ''})');
    return _outcomeFor(SystemHandOff.sms);
  }

  @override
  Future<SystemHandOffOutcome> openWifiSettings() async {
    calls.add('openWifiSettings');
    return _outcomeFor(SystemHandOff.wifiSettings);
  }

  @override
  Future<SystemHandOffOutcome> showLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    calls.add('showLocation: $latitude,$longitude (label: ${label ?? ''})');
    return _outcomeFor(SystemHandOff.location);
  }

  SystemHandOffOutcome _outcomeFor(SystemHandOff handOff) =>
      unhandled.contains(handOff) ? SystemHandOffOutcome.noHandler : outcome;
}
