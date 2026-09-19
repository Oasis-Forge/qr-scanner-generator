import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/link_opener.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/record_enums.dart';
import '../../services/system_intents.dart';
import '../../state/result_state.dart';

/// RES-1: the result's one real action, a full-width filled button at
/// least 1.4× the height of the outlined ones.
///
/// RES-14: when [onPressed] is null the button shows disabled, greyed out
/// by Material's own disabled style, and [unavailableReason], when given,
/// says why in one line underneath — never colour (the greying) alone
/// (A11Y-6).
class ResultPrimaryButton extends StatelessWidget {
  const ResultPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.unavailableReason,
    super.key,
  });

  /// RES-1's "at least 1.4× the height of any other control"
  /// (`AppTheme.minTapTargetSize` is the "other control" it is measured
  /// against).
  static const double minHeight = AppTheme.minTapTargetSize * 1.4;

  final String label;
  final IconData icon;

  /// Null shows the button disabled (RES-14).
  final Future<void> Function()? onPressed;

  /// RES-14's one-line reason, shown only while [onPressed] is null.
  final String? unavailableReason;

  @override
  Widget build(BuildContext context) {
    final Future<void> Function()? action = onPressed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, minHeight),
          ),
          onPressed: action == null ? null : () => unawaited(action()),
          icon: Icon(icon),
          label: Text(label),
        ),
        if (action == null && unavailableReason != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            unavailableReason!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// RES-1: one of up to three smaller outlined actions, at least
/// `AppTheme.minTapTargetSize` square (A11Y-2).
class ResultSecondaryButton extends StatelessWidget {
  const ResultSecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final Future<void> Function()? onPressed;

  static final ButtonStyle _style = OutlinedButton.styleFrom(
    minimumSize: const Size(
      AppTheme.minTapTargetSize * 2,
      AppTheme.minTapTargetSize,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Future<void> Function()? action = onPressed;
    return OutlinedButton.icon(
      style: _style,
      onPressed: action == null ? null : () => unawaited(action()),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

/// RES-1: copies the exact decoded text and says what was copied, or that
/// copying failed.
Future<void> copyContent(BuildContext context) async {
  final ResultState state = context.read<ResultState>();
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ResultIoOutcome outcome = await state.copy();
  showCopyOutcome(messenger, l10n, state, outcome);
}

/// Says what a copy of the whole content did: "Copied the link" or "Copied
/// the content", or that it failed (RES-1, SET-3). Shared by Copy and by
/// Copy on scan, so both confirm the same way.
void showCopyOutcome(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  ResultState state,
  ResultIoOutcome outcome,
) {
  final String what = state.outcome.parsedType == ParsedType.url
      ? l10n.copiedWhatLink
      : l10n.copiedWhatContent;
  _showSnackBar(
    messenger,
    outcome == ResultIoOutcome.ok
        ? l10n.copiedSnackbar(what)
        : l10n.resultCopyFailed,
  );
}

/// RES-4, DATA-5: copies only the Wi-Fi password, never the whole payload.
Future<void> copyWifiPassword(BuildContext context) async {
  final ResultState state = context.read<ResultState>();
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ResultIoOutcome outcome = await state.copyWifiPassword();
  _showSnackBar(
    messenger,
    outcome == ResultIoOutcome.ok
        ? l10n.copiedSnackbar(l10n.copiedWhatPassword)
        : l10n.resultCopyFailed,
  );
}

/// RES-1: hands the exact decoded text to the share sheet. Nothing leaves
/// the device until the user picks where it goes (PRIV-4).
Future<void> shareContent(BuildContext context) async {
  final ResultState state = context.read<ResultState>();
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ResultIoOutcome outcome = await state.share();
  if (outcome == ResultIoOutcome.failed) {
    _showSnackBar(messenger, l10n.resultShareFailed);
  }
}

/// RES-4, RES-6, RES-7: hands off to a system app and says so only on
/// failure — the other app coming to the front is confirmation enough that
/// it worked (RES-2).
Future<void> performHandOff(
  BuildContext context,
  Future<SystemHandOffOutcome> Function() action,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final AppLocalizations l10n = AppLocalizations.of(context);
  final SystemHandOffOutcome outcome = await action();
  if (outcome != SystemHandOffOutcome.handedOff) {
    _showSnackBar(messenger, l10n.resultHandOffFailed);
  }
}

/// RES-9: opens the search-engine link and says so only on failure.
Future<void> performLinkHandOff(
  BuildContext context,
  Future<LinkOpenOutcome> Function() action,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final AppLocalizations l10n = AppLocalizations.of(context);
  final LinkOpenOutcome outcome = await action();
  if (outcome == LinkOpenOutcome.failed ||
      outcome == LinkOpenOutcome.noHandler) {
    _showSnackBar(messenger, l10n.resultHandOffFailed);
  }
}

void _showSnackBar(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
