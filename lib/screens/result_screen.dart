import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/clipboard_service.dart';
import '../core/services/share_service.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/record_enums.dart';
import '../services/app_services.dart';
import '../state/scan_outcome.dart';
import '../state/settings_state.dart';
import 'scanner/code_labels.dart';
import 'scanner/payload_text.dart';

/// The result of one scanned code (RES-1 to RES-3).
///
/// One screen serves every source: the camera, a photo, typed entry and a pick
/// from the multi-code list, and later a History reopen (RES-3). Top to
/// bottom it shows the type and format in words ("Link · QR code", DATA-1),
/// the full decoded content, selectable and never truncated, left to right
/// even in Arabic (LANG-5), and Copy and Share of the exact decoded text
/// (RES-1). The results PR adds each type's own primary action above them.
///
/// Nothing happens without a tap (RES-2): nothing opens, dials, joins or
/// shares by itself. The one exception is "Copy on scan" (SET-3), off by
/// default, which copies only once this screen is fully on screen and says so
/// in a snackbar. No ad, upsell or Pro prompt appears here (ADS-1).
///
/// Presentational: the outcome arrives already written to History (or not,
/// HIS-8); the only calls this screen makes are the copy and share the user
/// asked for, through the app's services.
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

  /// The full decoded content (RES-1).
  static const Key contentKey = Key('result.content');

  /// Copy (RES-1).
  static const Key copyKey = Key('result.copy');

  /// Share (RES-1).
  static const Key shareKey = Key('result.share');

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
  /// Whether "Copy on scan" has been dealt with for this result, so it copies
  /// at most once (SET-3).
  bool _copyOnScanDone = false;

  /// The route animation being waited on, until this screen is fully shown.
  Animation<double>? _entrance;

  /// Whether the post-frame check of the entrance has been scheduled, so a
  /// second dependency change doesn't schedule another.
  bool _entranceChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isReopened || _copyOnScanDone || _entranceChecked) {
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
      if (!mounted || _copyOnScanDone) {
        return;
      }
      final Animation<double>? animation = ModalRoute.of(context)?.animation;
      if (animation == null || animation.isCompleted) {
        _copyOnScanDone = true;
        unawaited(_copyOnScan());
        return;
      }
      _entrance = animation..addStatusListener(_onEntranceStatus);
    });
  }

  @override
  void dispose() {
    _entrance?.removeStatusListener(_onEntranceStatus);
    super.dispose();
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _copyOnScanDone) {
      return;
    }
    _copyOnScanDone = true;
    _entrance?.removeStatusListener(_onEntranceStatus);
    unawaited(_copyOnScan());
  }

  /// SET-3: copies when the user turned "Copy on scan" on, and only then.
  Future<void> _copyOnScan() async {
    if (!mounted || !context.read<SettingsState>().copyOnScan) {
      return;
    }
    await _copy();
  }

  /// Copies the exact decoded text and says what was copied (RES-1, SET-3).
  Future<void> _copy() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ClipboardService clipboard = context.read<AppServices>().clipboard;
    final String what = widget.outcome.parsedType == ParsedType.url
        ? l10n.copiedWhatLink
        : l10n.copiedWhatContent;
    String message;
    try {
      await clipboard.copyText(widget.outcome.payloadText);
      message = l10n.copiedSnackbar(what);
    } on Object {
      message = l10n.resultCopyFailed;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Hands the exact decoded text to the system share sheet (RES-1). Nothing
  /// leaves the device until the user picks where it goes.
  Future<void> _share() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ShareService share = context.read<AppServices>().share;
    try {
      await share.shareText(widget.outcome.payloadText);
    } on Object {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.resultShareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ScanOutcome outcome = widget.outcome;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  parsedTypeIcon(outcome.parsedType),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.typeAndFormat(outcome.parsedType, outcome.symbology),
                      key: ResultScreen.typeLineKey,
                      style: theme.textTheme.titleMedium,
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
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: outcome.isBinary
                    // RES-13: raw bytes aren't text to show.
                    ? Text(
                        l10n.scanBinaryData(outcome.byteCount ?? 0),
                        key: ResultScreen.contentKey,
                        style: theme.textTheme.bodyLarge,
                      )
                    : PayloadText(
                        outcome.payloadText,
                        key: ResultScreen.contentKey,
                        type: outcome.parsedType,
                        selectable: true,
                        style: theme.textTheme.bodyLarge,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                OutlinedButton.icon(
                  key: ResultScreen.copyKey,
                  onPressed: () => unawaited(_copy()),
                  style: _actionStyle,
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.resultCopyButton),
                ),
                OutlinedButton.icon(
                  key: ResultScreen.shareKey,
                  onPressed: () => unawaited(_share()),
                  style: _actionStyle,
                  icon: const Icon(Icons.share),
                  label: Text(l10n.resultShareButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final ButtonStyle _actionStyle = OutlinedButton.styleFrom(
    minimumSize: const Size(
      AppTheme.minTapTargetSize * 2,
      AppTheme.minTapTargetSize,
    ),
  );
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
