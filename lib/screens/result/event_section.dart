import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/ics_time.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// An iCalendar event (RES-6): title, start, end, location and notes.
///
/// Start and end show the encoded wall-clock numbers in the app's language
/// (LANG-3), never converted between zones (DATE-3): a UTC time says UTC, a
/// zoned one names its zone, and a value that isn't a real iCalendar time is
/// shown as written. Empty fields show no row. The primary action, "Add to
/// calendar", hands off to the system calendar app's insert form
/// (`ACTION_INSERT`, no calendar permission), and is disabled with a reason
/// when the event has no readable start (RES-14).
class EventSection extends StatelessWidget {
  const EventSection({required this.event, super.key});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResultState state = context.watch<ResultState>();
    final IcsTime? start = parseIcsTime(event.start, tzid: event.startTzid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (event.title.trim().isNotEmpty)
                ResultField(
                  label: l10n.resultEventTitleLabel,
                  value: event.title,
                ),
              if (event.start.trim().isNotEmpty)
                ResultField(
                  label: l10n.resultEventStartLabel,
                  value: _when(context, l10n, event.start, event.startTzid),
                  forceLtr: true,
                ),
              if (event.end != null && event.end!.trim().isNotEmpty)
                ResultField(
                  label: l10n.resultEventEndLabel,
                  value: _when(context, l10n, event.end!, event.endTzid),
                  forceLtr: true,
                ),
              if (event.allDay)
                ResultNote(message: l10n.resultEventAllDayNotice),
              if (event.location != null)
                ResultField(
                  label: l10n.resultEventLocationLabel,
                  value: event.location!,
                ),
              if (event.notes != null)
                ResultField(
                  label: l10n.resultEventNotesLabel,
                  value: event.notes!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultEventPrimaryButton,
          icon: Icons.event_outlined,
          onPressed: state.canAddToCalendar && start != null
              ? () => performHandOff(context, state.addToCalendar)
              : null,
          unavailableReason: start == null
              ? l10n.resultUnavailableEventNoStart
              : l10n.resultUnavailableCalendar,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ResultSecondaryButton(
              label: l10n.resultCopyButton,
              icon: Icons.copy,
              onPressed: () => copyContent(context),
            ),
            ResultSecondaryButton(
              label: l10n.resultShareButton,
              icon: Icons.share,
              onPressed: () => shareContent(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// [raw] in the app's language, with no zone conversion (LANG-3, DATE-3), or
/// [raw] itself when it isn't an iCalendar date or date-time.
String _when(
  BuildContext context,
  AppLocalizations l10n,
  String raw,
  String? tzid,
) {
  final IcsTime? time = parseIcsTime(raw, tzid: tzid);
  if (time == null) {
    return raw;
  }
  final String locale = Localizations.localeOf(context).toLanguageTag();
  final DateFormat format = time.hasTime
      ? DateFormat.yMMMEd(locale).add_jm()
      : DateFormat.yMMMEd(locale);
  final String text = format.format(time.wallClock);
  return switch (time.kind) {
    IcsTimeKind.utc => l10n.resultEventTimeUtc(text),
    IcsTimeKind.zoned => l10n.resultEventTimeZoned(text, time.tzid!),
    IcsTimeKind.date || IcsTimeKind.floating => text,
  };
}
