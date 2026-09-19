import 'package:android_intent_plus/android_intent.dart';

import '../system_intents.dart';

/// `Intent.ACTION_DIAL` (RES-7).
const String _actionDial = 'android.intent.action.DIAL';

/// `Intent.ACTION_SENDTO` (RES-7): a prefilled compose screen, never a send.
const String _actionSendTo = 'android.intent.action.SENDTO';

/// `Intent.ACTION_INSERT` (RES-6).
const String _actionInsert = 'android.intent.action.INSERT';

/// `Intent.ACTION_VIEW` (RES-8).
const String _actionView = 'android.intent.action.VIEW';

/// `android.provider.Settings.ACTION_WIFI_SETTINGS` (RES-4).
const String _actionWifiSettings = 'android.settings.WIFI_SETTINGS';

/// `ContactsContract.RawContacts.CONTENT_TYPE`, the mime type the manifest's
/// `<queries>` entry for `ACTION_INSERT` names (RES-6).
const String _contactMimeType = 'vnd.android.cursor.dir/contact';

/// `CalendarContract.Events.CONTENT_TYPE`, the mime type the manifest's
/// `<queries>` entry for `ACTION_INSERT` names (RES-6).
const String _eventMimeType = 'vnd.android.cursor.dir/event';

/// `CalendarContract.Events.CONTENT_URI`, where [insertCalendarEventIntent]
/// asks the calendar app to insert (RES-6).
const String _eventsContentUri = 'content://com.android.calendar/events';

/// `ContactsContract.Intents.Insert`'s extra keys, in the order a name's
/// phones and emails fill them: only the first three of each fit this
/// contract (RES-6).
const List<String> _phoneExtraKeys = <String>[
  'phone',
  'secondary_phone',
  'tertiary_phone',
];
const List<String> _emailExtraKeys = <String>[
  'email',
  'secondary_email',
  'tertiary_email',
];

/// `tel:` (RES-7). [phoneNumber] is used exactly as encoded, a leading `+`
/// kept.
AndroidIntent dialIntent(String phoneNumber) =>
    AndroidIntent(action: _actionDial, data: 'tel:$phoneNumber');

/// `smsto:` with the message, if any, in the well-known `sms_body` extra
/// (RES-7). Opens the messaging app prefilled; nothing is sent.
AndroidIntent composeSmsIntent({
  required String phoneNumber,
  String? message,
}) => AndroidIntent(
  action: _actionSendTo,
  data: 'smsto:$phoneNumber',
  arguments: message == null || message.isEmpty
      ? null
      : <String, dynamic>{'sms_body': message},
);

/// `mailto:` with `Intent.EXTRA_SUBJECT` and `Intent.EXTRA_TEXT` (RES-7).
/// Opens the email app prefilled; nothing is sent.
AndroidIntent composeEmailIntent({
  required List<String> to,
  String? subject,
  String? body,
}) => AndroidIntent(
  action: _actionSendTo,
  data: 'mailto:${to.join(',')}',
  arguments: <String, dynamic>{
    if (subject != null && subject.isNotEmpty)
      'android.intent.extra.SUBJECT': subject,
    if (body != null && body.isNotEmpty) 'android.intent.extra.TEXT': body,
  },
);

/// `ACTION_INSERT` on the contacts mime type, with `ContactsContract.Intents
/// .Insert`'s `name`, `phone`/`secondary_phone`/`tertiary_phone`,
/// `email`/`secondary_email`/`tertiary_email` and `company` extras (RES-6).
/// A fourth phone or email this contract has no slot for is left out rather
/// than guessed at; the result screen still shows every one it read.
AndroidIntent insertContactIntent(ContactDraft contact) => AndroidIntent(
  action: _actionInsert,
  type: _contactMimeType,
  arguments: <String, dynamic>{
    if (contact.name.isNotEmpty) 'name': contact.name,
    ..._numberedExtras(_phoneExtraKeys, contact.phoneNumbers),
    ..._numberedExtras(_emailExtraKeys, contact.emails),
    if (contact.organisation != null && contact.organisation!.isNotEmpty)
      'company': contact.organisation,
  },
);

/// `ACTION_INSERT` on `CalendarContract.Events.CONTENT_URI`, with
/// `CalendarContract`'s `title`, `beginTime`, `endTime`, `allDay`,
/// `eventLocation` and `description` extras, all-day flag included (RES-6).
/// [event]'s `start`/`end` are already the instants `ResultState` decided
/// (DATE-3, `lib/state/result_state.dart`); this only turns them into millis.
AndroidIntent insertCalendarEventIntent(CalendarEventDraft event) =>
    AndroidIntent(
      action: _actionInsert,
      // The events URI, not the bare mime type: Google Calendar answers a
      // type-only insert with its month view, and only the URI with its
      // prefilled event form (seen on API 37).
      data: _eventsContentUri,
      arguments: <String, dynamic>{
        'title': event.title,
        'beginTime': event.start.millisecondsSinceEpoch,
        if (event.end != null) 'endTime': event.end!.millisecondsSinceEpoch,
        'allDay': event.allDay,
        if (event.location != null && event.location!.isNotEmpty)
          'eventLocation': event.location,
        if (event.notes != null && event.notes!.isNotEmpty)
          'description': event.notes,
      },
    );

/// `android.settings.WIFI_SETTINGS`, with no data and no extras (RES-4).
AndroidIntent openWifiSettingsIntent() =>
    const AndroidIntent(action: _actionWifiSettings);

/// `ACTION_VIEW` on a `geo:` URI, Android's own `q=lat,lon(label)`
/// convention for an optional label (RES-8).
AndroidIntent showLocationIntent({
  required double latitude,
  required double longitude,
  String? label,
}) => AndroidIntent(
  action: _actionView,
  data: label == null || label.isEmpty
      ? 'geo:$latitude,$longitude'
      : 'geo:$latitude,$longitude?q=$latitude,$longitude'
            '(${Uri.encodeComponent(label)})',
);

/// A generic intent for [handOff], built with placeholder data, for
/// [AndroidSystemIntents.canHandle] to resolve: `canResolveActivity` only
/// needs the action, data scheme and mime type to match what a real hand-off
/// would use, never the actual content (RES-14).
AndroidIntent probeIntentFor(SystemHandOff handOff) => switch (handOff) {
  SystemHandOff.insertContact => const AndroidIntent(
    action: _actionInsert,
    type: _contactMimeType,
  ),
  SystemHandOff.insertCalendarEvent => const AndroidIntent(
    action: _actionInsert,
    type: _eventMimeType,
  ),
  SystemHandOff.dial => const AndroidIntent(action: _actionDial, data: 'tel:'),
  SystemHandOff.email => const AndroidIntent(
    action: _actionSendTo,
    data: 'mailto:',
  ),
  SystemHandOff.sms => const AndroidIntent(
    action: _actionSendTo,
    data: 'smsto:',
  ),
  SystemHandOff.wifiSettings => const AndroidIntent(
    action: _actionWifiSettings,
  ),
  SystemHandOff.location => const AndroidIntent(
    action: _actionView,
    data: 'geo:0,0',
  ),
};

/// [values] against [keys], in order, dropped once [keys] runs out.
Map<String, dynamic> _numberedExtras(List<String> keys, List<String> values) {
  final Map<String, dynamic> extras = <String, dynamic>{};
  for (var i = 0; i < values.length && i < keys.length; i++) {
    extras[keys[i]] = values[i];
  }
  return extras;
}

/// [SystemIntents] over `android_intent_plus`: every hand-off is a system
/// app's own screen, prefilled, that the user still has to confirm there
/// (RES-2, RES-6, RES-7); this never asks for a contacts, calendar, phone or
/// SMS permission.
///
/// Intent building is kept in the pure top-level functions above, which a
/// test can check without a device (`android_system_intents_test.dart`).
/// This class only resolves an intent and launches it: [canHandle] and every
/// hand-off answer [SystemHandOffOutcome.noHandler] once
/// `AndroidIntent.canResolveActivity` says no installed app can take it
/// (RES-14), rather than trying and failing, and [SystemHandOffOutcome.failed]
/// is only ever a platform failure past that point.
class AndroidSystemIntents implements SystemIntents {
  const AndroidSystemIntents();

  @override
  Future<bool> canHandle(SystemHandOff handOff) async {
    try {
      return await probeIntentFor(handOff).canResolveActivity() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<SystemHandOffOutcome> insertContact(ContactDraft contact) =>
      _run(insertContactIntent(contact));

  @override
  Future<SystemHandOffOutcome> insertCalendarEvent(CalendarEventDraft event) =>
      _run(insertCalendarEventIntent(event));

  @override
  Future<SystemHandOffOutcome> dial(String phoneNumber) =>
      _run(dialIntent(phoneNumber));

  @override
  Future<SystemHandOffOutcome> composeEmail({
    required List<String> to,
    String? subject,
    String? body,
  }) => _run(composeEmailIntent(to: to, subject: subject, body: body));

  @override
  Future<SystemHandOffOutcome> composeSms({
    required String phoneNumber,
    String? message,
  }) => _run(composeSmsIntent(phoneNumber: phoneNumber, message: message));

  @override
  Future<SystemHandOffOutcome> openWifiSettings() =>
      _run(openWifiSettingsIntent());

  @override
  Future<SystemHandOffOutcome> showLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) => _run(
    showLocationIntent(latitude: latitude, longitude: longitude, label: label),
  );

  /// Resolves [intent] before launching it (RES-14), and turns any platform
  /// failure past that point into [SystemHandOffOutcome.failed] instead of
  /// an uncaught exception.
  Future<SystemHandOffOutcome> _run(AndroidIntent intent) async {
    try {
      final bool canResolve = await intent.canResolveActivity() ?? false;
      if (!canResolve) {
        return SystemHandOffOutcome.noHandler;
      }
      await intent.launch();
      return SystemHandOffOutcome.handedOff;
    } on Object {
      // A `PlatformException` from the plugin, or anything else, is one
      // hand-off gone wrong, never an app crash.
      return SystemHandOffOutcome.failed;
    }
  }
}
