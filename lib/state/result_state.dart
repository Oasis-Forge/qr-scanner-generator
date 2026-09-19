import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/clipboard_service.dart';
import '../core/services/link_opener.dart';
import '../core/services/share_service.dart';
import '../models/link_check.dart';
import '../models/parsed_payload.dart';
import '../parsers/payload_parser.dart';
import '../services/system_intents.dart';
import 'scan_outcome.dart';
import 'settings_state.dart' show SearchEngine;

/// What a Copy or Share attempt came back as, for the screen to word its
/// snackbar (RES-1, RES-4).
enum ResultIoOutcome {
  /// The clipboard or the share sheet took it.
  ok,

  /// The clipboard or the share sheet refused it.
  failed,
}

/// The result screen's state (RES-1 to RES-9): the parsed payload, which
/// hand-offs are available (RES-14), and the primary and secondary actions
/// for its type.
///
/// One instance per result screen — `ResultScreen` creates it and gives it
/// straight to the section widget for [payload]'s type
/// (`lib/screens/result/*.dart`). Screens stay presentational (`CLAUDE.md`):
/// they read [payload] and the `canX` getters and call the action methods,
/// which are the only place a device service is touched.
///
/// **Availability (RES-14).** The hand-off this type's primary action needs
/// is checked once, right away, by calling [SystemIntents.canHandle] or
/// [LinkOpener.canOpenWebLinks] — never a hand-off this type has no button
/// for, so a Link result never asks [SystemIntents] anything. Every `canX`
/// getter starts `true` (so the primary button never flashes disabled while
/// the check is still running) and is corrected once the answer is back.
///
/// **Copy on scan (SET-3, RES-2).** [notifyEntranceFinished] moves that rule
/// here from the screen: the screen still decides *when* the result has
/// finished coming on screen (that needs the route's own animation, a widget
/// concern `ResultScreen` still owns), and calls this exactly once when it
/// has; this decides *whether* to copy — only when Copy on scan is on, this
/// is not a record reopened from History, and it hasn't already copied for
/// this screen — and does the copy itself.
class ResultState extends ChangeNotifier {
  ResultState({
    required this.outcome,
    required this.isReopened,
    required bool copyOnScan,
    required SearchEngine searchEngine,
    required ClipboardService clipboard,
    required ShareService share,
    required SystemIntents systemIntents,
    required LinkOpener linkOpener,
  }) : payload = parsePayload(
         outcome.payloadText,
         bytes: outcome.payloadBytes,
         symbology: outcome.symbology,
         isBinary: outcome.isBinary,
       ),
       _copyOnScan = copyOnScan,
       _searchEngine = searchEngine,
       _clipboard = clipboard,
       _share = share,
       _systemIntents = systemIntents,
       _linkOpener = linkOpener {
    final ParsedPayload p = payload;
    // LINK-9: computed once here, from the payload this instance was built
    // for — a History reopen builds a fresh ResultState and runs this again,
    // so nothing is ever cached across screens. Never asked for a blocked
    // link (LINK-5): the result offers no Open or Review for one, so nothing
    // reads this list for it either.
    _linkChecks = p is Link && !p.isBlocked
        ? checkLink(p.uri, p.url)
        : const <LinkCheck>[];
    unawaited(_loadAvailability());
  }

  /// The scan this result is for (RES-1, RES-3).
  final ScanOutcome outcome;

  /// Whether this is a record reopened from History, which [SET-3] leaves
  /// alone.
  final bool isReopened;

  /// The full parse of [ScanOutcome.payloadText] (RES-4 to RES-13). Its
  /// [ParsedPayload.type] always agrees with [outcome]'s own `parsedType`
  /// (`payload_parser.dart`).
  final ParsedPayload payload;

  final bool _copyOnScan;
  final SearchEngine _searchEngine;
  final ClipboardService _clipboard;
  final ShareService _share;
  final SystemIntents _systemIntents;
  final LinkOpener _linkOpener;

  bool _passwordRevealed = false;
  bool _copiedOnScanDone = false;
  bool _disposed = false;

  bool _canOpenWifiSettings = true;
  bool _canAddToContacts = true;
  bool _canAddToCalendar = true;
  bool _canDial = true;
  bool _canComposeSms = true;
  bool _canComposeEmail = true;
  bool _canSearchTheWeb = true;
  bool _canOpenLink = true;

  /// LINK-3, LINK-9: every on-device check the link trips, in LINK-3's order
  /// (empty for a payload that isn't a [Link], and for a blocked one). See
  /// the constructor body for when and how this is computed.
  late final List<LinkCheck> _linkChecks;

  /// RES-4, RES-14: whether any app can open Wi-Fi settings.
  bool get canOpenWifiSettings => _canOpenWifiSettings;

  /// RES-6, RES-14: whether any app can take a new contact.
  bool get canAddToContacts => _canAddToContacts;

  /// RES-6, RES-14: whether any app can take a new calendar event.
  bool get canAddToCalendar => _canAddToCalendar;

  /// RES-7, RES-14: whether any app can open the dialer.
  bool get canDial => _canDial;

  /// RES-7, RES-14: whether any app can open a messaging compose screen.
  bool get canComposeSms => _canComposeSms;

  /// RES-7, RES-14: whether any app can open an email compose screen.
  bool get canComposeEmail => _canComposeEmail;

  /// RES-9, RES-14: whether any app can show a web search.
  bool get canSearchTheWeb => _canSearchTheWeb;

  /// LINK-3, LINK-8, RES-14: whether any app can show a web link — what
  /// "Open" needs directly, and what "Review"'s "Open anyway" would need in
  /// turn, so the one primary-action slot (whichever of the two it holds)
  /// is gated on this rather than on two separate checks. Never asked for a
  /// blocked link (LINK-5): [LinkOpener] is never called for one.
  bool get canOpenLink => _canOpenLink;

  /// LINK-1, LINK-5: whether the payload is a [Link] with a scheme LINK-5
  /// blocks. `false` for every other payload, including a [Link] that isn't
  /// blocked.
  bool get isLinkBlocked => payload is Link && (payload as Link).isBlocked;

  /// LINK-3: every check [linkChecks] lists, in LINK-3's stable order. Empty
  /// means the primary action is "Open"; any entry means it's "Review"
  /// (LINK-4). Always empty for a blocked link (LINK-5) or a payload that
  /// isn't a [Link].
  List<LinkCheck> get linkChecks => _linkChecks;

  /// RES-4, DATA-5: whether the Wi-Fi password is shown in the clear. A
  /// local, per-screen toggle: it starts masked every time this screen opens
  /// and is never remembered.
  bool get isWifiPasswordRevealed => _passwordRevealed;

  /// RES-4: flips [isWifiPasswordRevealed]. Never touches the share preview
  /// (HIS-7): [share] always sends the exact decoded payload, mask or no
  /// mask has nothing to do with it.
  void toggleWifiPasswordRevealed() {
    _passwordRevealed = !_passwordRevealed;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// SET-3, RES-2: called once by the screen when the result's entrance has
  /// finished (or was already complete). Copies only when Copy on scan is
  /// on, this isn't a reopened record, and this is the first call for this
  /// screen; every later call, and every call on a reopened record, does
  /// nothing.
  Future<ResultIoOutcome?> notifyEntranceFinished() async {
    if (isReopened || _copiedOnScanDone || !_copyOnScan) {
      return null;
    }
    _copiedOnScanDone = true;
    return copy();
  }

  /// RES-1: copies the exact decoded text, whatever the type.
  Future<ResultIoOutcome> copy() =>
      _guarded(() => _clipboard.copyText(outcome.payloadText));

  /// RES-4: copies only the Wi-Fi password, never the whole `WIFI:` payload
  /// (DATA-5). Only ever called for a [Wifi] payload that has one.
  Future<ResultIoOutcome> copyWifiPassword() {
    final String? password = (payload as Wifi).password;
    if (password == null) {
      return Future<ResultIoOutcome>.value(ResultIoOutcome.failed);
    }
    return _guarded(() => _clipboard.copyText(password));
  }

  /// RES-1: hands the exact decoded text to the share sheet, whatever the
  /// type. Nothing leaves the device until the user picks where it goes
  /// (PRIV-4).
  Future<ResultIoOutcome> share() =>
      _guarded(() => _share.shareText(outcome.payloadText));

  /// RES-4: opens system Wi-Fi settings. Never joins a network itself
  /// (RES-2); joining is RES-5, after spike S5.
  Future<SystemHandOffOutcome> openWifiSettings() =>
      _systemIntents.openWifiSettings();

  /// RES-6: hands the contact to the system contacts app's insert form,
  /// exactly as encoded. Only ever called for a [Contact] payload.
  Future<SystemHandOffOutcome> addToContacts() {
    final Contact contact = payload as Contact;
    return _systemIntents.insertContact(
      ContactDraft(
        name: contact.name ?? '',
        // vCard 4.0 may carry a number as a `tel:` URI; the contacts app
        // wants the number alone. The screen still shows it as encoded.
        phoneNumbers: <String>[
          for (final String phone in contact.phones)
            phone.replaceFirst(RegExp('^(tel|sip):', caseSensitive: false), ''),
        ],
        emails: contact.emails,
        organisation: contact.organisation,
      ),
    );
  }

  /// RES-6: hands the event to the system calendar app's insert form
  /// (DATE-3). Only ever called for a [CalendarEvent] payload.
  Future<SystemHandOffOutcome> addToCalendar() {
    final CalendarEvent event = payload as CalendarEvent;
    final DateTime start = _dateTimeOf(
      event.start,
      tzid: event.startTzid,
      allDay: event.allDay,
    );
    final DateTime? end = event.end == null
        ? null
        : _dateTimeOf(event.end!, tzid: event.endTzid, allDay: event.allDay);
    return _systemIntents.insertCalendarEvent(
      CalendarEventDraft(
        title: event.title,
        start: start,
        end: end,
        allDay: event.allDay,
        location: event.location,
        notes: event.notes,
      ),
    );
  }

  /// RES-7: opens the dialer prefilled, and never places the call. Only
  /// ever called for a [Phone] payload.
  Future<SystemHandOffOutcome> dial() =>
      _systemIntents.dial((payload as Phone).number);

  /// RES-7: opens the messaging app prefilled, and never sends. Only ever
  /// called for an [Sms] payload.
  Future<SystemHandOffOutcome> composeSms() {
    final Sms sms = payload as Sms;
    return _systemIntents.composeSms(
      phoneNumber: sms.number,
      message: sms.message,
    );
  }

  /// RES-7: opens the email app prefilled, and never sends. Only ever
  /// called for an [Email] payload.
  Future<SystemHandOffOutcome> composeEmail() {
    final Email email = payload as Email;
    return _systemIntents.composeEmail(
      to: <String>[email.to],
      subject: email.subject,
      body: email.body,
    );
  }

  /// LINK-3, LINK-8: opens the link through [LinkOpener] (Custom Tabs,
  /// falling back to the browser). Called for "Open" with no checks
  /// triggered, and for "Open anyway" on the warning sheet with any — both
  /// take the exact same route (LINK-4). Only ever called for a [Link]
  /// payload that isn't blocked; LINK-5 leaves [LinkOpener] untouched for
  /// one that is.
  Future<LinkOpenOutcome> openLink() => _linkOpener.open((payload as Link).uri);

  /// RES-9: opens a web search for the product's number, using the search
  /// engine chosen in Settings (SET-4). Only ever called for a [Product]
  /// payload. No product database, no shopping action: this is a plain web
  /// search, and the URL is built here since building it is not
  /// `SettingsState`'s job (see `SearchEngine`'s own doc comment).
  Future<LinkOpenOutcome> searchTheWeb() =>
      _linkOpener.open(_searchUrlFor((payload as Product).code));

  Uri _searchUrlFor(String query) {
    final String q = Uri.encodeQueryComponent(query);
    return switch (_searchEngine) {
      SearchEngine.google => Uri.parse('https://www.google.com/search?q=$q'),
      SearchEngine.bing => Uri.parse('https://www.bing.com/search?q=$q'),
      SearchEngine.duckDuckGo => Uri.parse('https://duckduckgo.com/?q=$q'),
      SearchEngine.ecosia => Uri.parse('https://www.ecosia.org/search?q=$q'),
      SearchEngine.brave => Uri.parse('https://search.brave.com/search?q=$q'),
      SearchEngine.yahoo => Uri.parse('https://search.yahoo.com/search?p=$q'),
      SearchEngine.yandex => Uri.parse('https://yandex.com/search/?text=$q'),
    };
  }

  /// RES-14: the one `canHandle`/`canOpenWebLinks` call this type's primary
  /// action needs, asked once, right away. A type with no primary hand-off
  /// at all (plain text, Unknown, a location) asks nothing, so its
  /// [SystemIntents] and [LinkOpener] see no call at all (RES-2). A blocked
  /// [Link] (LINK-5) asks nothing either: its result offers no Open or
  /// Review, so [LinkOpener] is never called for one, [canOpenWebLinks]
  /// included.
  Future<void> _loadAvailability() async {
    final bool? result = switch (payload) {
      Wifi() => await _systemIntents.canHandle(SystemHandOff.wifiSettings),
      Contact() => await _systemIntents.canHandle(SystemHandOff.insertContact),
      CalendarEvent() => await _systemIntents.canHandle(
        SystemHandOff.insertCalendarEvent,
      ),
      Phone() => await _systemIntents.canHandle(SystemHandOff.dial),
      Sms() => await _systemIntents.canHandle(SystemHandOff.sms),
      Email() => await _systemIntents.canHandle(SystemHandOff.email),
      Product() => await _linkOpener.canOpenWebLinks(),
      Link link when !link.isBlocked => await _linkOpener.canOpenWebLinks(),
      Link() || PlainText() || Location() || Unknown() => null,
    };
    if (result == null || _disposed) {
      return;
    }
    switch (payload) {
      case Wifi():
        _canOpenWifiSettings = result;
      case Contact():
        _canAddToContacts = result;
      case CalendarEvent():
        _canAddToCalendar = result;
      case Phone():
        _canDial = result;
      case Sms():
        _canComposeSms = result;
      case Email():
        _canComposeEmail = result;
      case Product():
        _canSearchTheWeb = result;
      case Link link when !link.isBlocked:
        _canOpenLink = result;
      case Link() || PlainText() || Location() || Unknown():
        break;
    }
    notifyListeners();
  }

  Future<ResultIoOutcome> _guarded(Future<void> Function() action) async {
    try {
      await action();
      return ResultIoOutcome.ok;
    } on Object {
      return ResultIoOutcome.failed;
    }
  }

  /// An iCalendar `DTSTART`/`DTEND` raw value (`YYYYMMDD` or
  /// `YYYYMMDDTHHMMSS`, an optional trailing `Z`) as the [DateTime]
  /// [SystemIntents.insertCalendarEvent] hands to the system calendar
  /// (RES-6, DATE-3).
  ///
  /// - An all-day date is midnight UTC, so the day it names never shifts
  ///   with the device's time zone.
  /// - A floating time (no `Z`, no [tzid]) has no zone of its own: RES-6
  ///   hands it to the calendar app in the zone at hand right now, the
  ///   device's own.
  /// - A UTC time (trailing `Z`) or a `TZID`-qualified time is a specific
  ///   instant that must never shift with the device's zone (DATE-3). A
  ///   `TZID` needs a time-zone database this build doesn't carry (the
  ///   package list in `CLAUDE.md`), so rather than guess by reinterpreting
  ///   its wall-clock numbers in whatever zone the device happens to be in
  ///   — which would be exactly the shift DATE-3 forbids — they are read as
  ///   UTC, the one reading that never depends on the device.
  /// - A value this build can't parse at all (an empty `DTSTART`, say)
  ///   reads as now, so "Add to calendar" still opens with something rather
  ///   than throwing.
  DateTime _dateTimeOf(String raw, {String? tzid, required bool allDay}) {
    final RegExpMatch? match = _icsPattern.firstMatch(raw.trim());
    if (match == null) {
      return DateTime.now();
    }
    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    if (allDay || match.group(4) == null) {
      return DateTime.utc(year, month, day);
    }
    final int hour = int.parse(match.group(5)!);
    final int minute = int.parse(match.group(6)!);
    final int second = int.parse(match.group(7) ?? '0');
    final bool isUtc = match.group(8) != null;
    if (isUtc || tzid != null) {
      return DateTime.utc(year, month, day, hour, minute, second);
    }
    return DateTime(year, month, day, hour, minute, second);
  }
}

/// `YYYYMMDD`, or `YYYYMMDDTHHMMSS` with an optional seconds part and an
/// optional trailing `Z`.
final RegExp _icsPattern = RegExp(
  r'^(\d{4})(\d{2})(\d{2})(T(\d{2})(\d{2})(\d{2})?(Z)?)?$',
);
