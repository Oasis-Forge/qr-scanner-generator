import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/parsed_payload.dart';
import '../services/app_services.dart';
import '../state/result_state.dart';
import '../state/scan_outcome.dart';
import '../state/settings_state.dart';
import 'result/contact_section.dart';
import 'result/email_section.dart';
import 'result/event_section.dart';
import 'result/link_section.dart';
import 'result/location_section.dart';
import 'result/phone_section.dart';
import 'result/plain_text_section.dart';
import 'result/result_actions.dart';
import 'result/product_section.dart';
import 'result/sms_section.dart';
import 'result/unknown_section.dart';
import 'result/wifi_section.dart';
import 'scanner/code_labels.dart';

/// The result of one scanned code (RES-1 to RES-14).
///
/// One screen serves every source: the camera, a photo, typed entry, a pick
/// from the multi-code list, and a History reopen (RES-3). Top to bottom it
/// shows the type and format in words ("Link · QR code", DATA-1), then the
/// section for [ScanOutcome.parsedType] (`lib/screens/result/*.dart`), which
/// draws that type's own fields and its primary and secondary actions,
/// always including Copy and Share of the exact decoded text (RES-1).
///
/// Nothing happens without a tap (RES-2): nothing opens, dials, joins,
/// inserts or shares by itself. The one exception is "Copy on scan"
/// (SET-3), off by default, which copies only once this screen is fully on
/// screen and says so in a snackbar. No ad, upsell or Pro prompt appears
/// here (ADS-1).
///
/// Presentational (`CLAUDE.md`): every service call this screen's sections
/// make goes through [ResultState], which this screen creates once, from
/// the real [AppServices] and [SettingsState] the app already provides, and
/// disposes when it closes. The outcome arrives already written to History
/// (or not, HIS-8).
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.outcome,
    this.isReopened = false,
    super.key,
  });

  /// The route the scanner opens a result with.
  static Route<void> route(ScanOutcome outcome) => MaterialPageRoute<void>(
    builder: (BuildContext context) => ResultScreen(outcome: outcome),
  );

  /// The "Link · QR code" line (RES-1).
  static const Key typeLineKey = Key('result.type_line');

  /// The line saying the scan couldn't be written to History.
  static const Key notSavedKey = Key('result.not_saved');

  final ScanOutcome outcome;

  /// Whether this is a record reopened from History rather than a fresh scan,
  /// which "Copy on scan" leaves alone (SET-3).
  final bool isReopened;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  /// Built once, from the real services this screen is handed, and given to
  /// every section below through [ChangeNotifierProvider.value] — a `.value`
  /// provider never disposes what it's given, so [dispose] does that here.
  late final ResultState _resultState;

  /// The route animation being waited on, until this screen is fully shown.
  Animation<double>? _entrance;

  /// Whether the post-frame check of the entrance has been scheduled, so a
  /// second dependency change doesn't schedule another.
  bool _entranceChecked = false;

  @override
  void initState() {
    super.initState();
    final AppServices services = context.read<AppServices>();
    final SettingsState settings = context.read<SettingsState>();
    _resultState = ResultState(
      outcome: widget.outcome,
      isReopened: widget.isReopened,
      copyOnScan: settings.copyOnScan,
      searchEngine: settings.searchEngine,
      clipboard: services.clipboard,
      share: services.share,
      systemIntents: services.systemIntents,
      linkOpener: services.linkOpener,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isReopened || _entranceChecked) {
      return;
    }
    _entranceChecked = true;
    // SET-3, RES-2: "only once the result is on screen", so wait for the
    // route to finish sliding in. The route's animation is only attached
    // after the first frame: before that it stands in as an always-complete
    // animation, so reading it here would copy during the slide-in. Decide
    // after the first frame instead. A screen with nothing to wait for (the
    // first route) then reads as complete and copies straight away.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }
      final Animation<double>? animation = ModalRoute.of(context)?.animation;
      if (animation == null || animation.isCompleted) {
        unawaited(_copyOnArrival());
        return;
      }
      _entrance = animation..addStatusListener(_onEntranceStatus);
    });
  }

  @override
  void dispose() {
    _entrance?.removeStatusListener(_onEntranceStatus);
    _resultState.dispose();
    super.dispose();
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    _entrance?.removeStatusListener(_onEntranceStatus);
    unawaited(_copyOnArrival());
  }

  /// SET-3: once the result is fully on screen, copies when Copy on scan is
  /// on, and confirms with the same snackbar as the Copy button.
  Future<void> _copyOnArrival() async {
    if (!mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ResultIoOutcome? outcome = await _resultState
        .notifyEntranceFinished();
    if (outcome != null) {
      showCopyOutcome(messenger, l10n, _resultState, outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScanOutcome outcome = widget.outcome;

    // What was read is printed on paper, in both themes: the slip the
    // instrument hands back, against the dark chassis it was read with.
    final ThemeData paperTheme = AppTheme.light();
    const AppColors colors = AppColors.light;

    return ChangeNotifierProvider<ResultState>.value(
      value: _resultState,
      child: Theme(
        data: paperTheme,
        child: Scaffold(
          backgroundColor: colors.paper,
          appBar: AppBar(
            backgroundColor: colors.paper,
            title: Text(
              l10n.resultTitle,
              style: AppTheme.mono(size: 12, color: paperTheme.hintColor),
            ),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 32),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      parsedTypeIcon(outcome.parsedType),
                      size: 18,
                      color: colors.signalText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.typeAndFormat(
                            outcome.parsedType,
                            outcome.symbology,
                          ),
                          key: ResultScreen.typeLineKey,
                          style: AppTheme.mono(
                            size: 11,
                            color: colors.signalText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (outcome.saveFailed) ...<Widget>[
                  _NotSaved(message: l10n.resultNotSaved),
                  const SizedBox(height: 16),
                ],
                _sectionFor(_resultState.payload),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The one section for [payload]'s type (RES-4 to RES-13), a sealed switch
  /// so a new [ParsedPayload] subclass fails to compile here until it has
  /// one.
  Widget _sectionFor(ParsedPayload payload) => switch (payload) {
    Link link => LinkSection(link: link),
    Wifi wifi => WifiSection(wifi: wifi),
    Contact contact => ContactSection(contact: contact),
    CalendarEvent event => EventSection(event: event),
    Phone phone => PhoneSection(phone: phone),
    Sms sms => SmsSection(sms: sms),
    Email email => EmailSection(email: email),
    Location location => LocationSection(location: location),
    Product product => ProductSection(product: product),
    PlainText text => PlainTextSection(text: text),
    Unknown unknown => UnknownSection(unknown: unknown),
  };
}

/// Says the scan couldn't be written to History. The result still works; the
/// icon and the words carry the warning, never colour alone (A11Y-6).
class _NotSaved extends StatelessWidget {
  const _NotSaved({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      key: ResultScreen.notSavedKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.error_outline, color: theme.colorScheme.error),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
