import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/link_check.dart';
import '../../models/parsed_payload.dart';
import '../../models/record_enums.dart';
import '../scanner/payload_text.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// LINK-4: opens the warning sheet over [context] for [link], listing
/// [checks] and offering "Copy without opening" and "Open anyway".
///
/// [onCopyWithoutOpening] and [onOpenAnyway] are the exact closures the
/// caller would use for a plain Copy or Open button on the result screen
/// itself (`copyContent`, `performLinkHandOff(context, state.openLink)`):
/// this only ever changes *where* they are offered, never what they do, so
/// a clean Open and an "Open anyway" hand off to [LinkOpener] the same way
/// (LINK-8).
///
/// `isDismissible: false` and `enableDrag: false` are LINK-4's "never
/// closes by itself": nothing but tapping one of the two actions ends it —
/// no tap outside, no swipe, no back gesture.
Future<void> showLinkWarningSheet(
  BuildContext context, {
  required Link link,
  required List<LinkCheck> checks,
  required Future<void> Function() onCopyWithoutOpening,
  required Future<void> Function() onOpenAnyway,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => LinkWarningSheet(
      link: link,
      checks: checks,
      onCopyWithoutOpening: onCopyWithoutOpening,
      onOpenAnyway: onOpenAnyway,
    ),
  );
}

/// The sheet [showLinkWarningSheet] opens (LINK-4): one plain-language line
/// per check in [checks], the URL and the emphasised host repeated, and the
/// two equally-sized actions.
///
/// A "dumb" widget on purpose: it takes [onCopyWithoutOpening] and
/// [onOpenAnyway] as plain callbacks rather than reading [ResultState]
/// itself, since `showModalBottomSheet` opens this in the Navigator's own
/// overlay, a sibling of the result screen's route rather than a
/// descendant of the `Provider` it scoped there — a lookup from in here
/// would not find it.
class LinkWarningSheet extends StatelessWidget {
  const LinkWarningSheet({
    required this.link,
    required this.checks,
    required this.onCopyWithoutOpening,
    required this.onOpenAnyway,
    super.key,
  });

  /// So a widget test can find this sheet's own root, and each button
  /// below by its own identity rather than by its label.
  static const Key sheetKey = Key('result.link_warning_sheet');
  static const Key copyWithoutOpeningButtonKey = Key(
    'result.link_warning_sheet.copy',
  );
  static const Key openAnywayButtonKey = Key('result.link_warning_sheet.open');

  final Link link;

  /// LINK-3's checks this link tripped, in LINK-3's own order — never empty:
  /// nothing opens this sheet otherwise.
  final List<LinkCheck> checks;

  /// Copies [link]'s exact text and reports the outcome, without opening it.
  final Future<void> Function() onCopyWithoutOpening;

  /// Opens [link] through `ResultState.openLink` (LINK-8), the same route a
  /// clean Open takes.
  final Future<void> Function() onOpenAnyway;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    // LINK-4's "never closes by itself" covers the system back gesture too,
    // not only the barrier tap and the drag `showLinkWarningSheet` already
    // turns off: the two buttons below are the only way out.
    return PopScope(
      canPop: false,
      child: SafeArea(
        key: LinkWarningSheet.sheetKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.resultLinkWarningTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (final LinkCheck check in checks)
                  _CheckLine(check: check, l10n: l10n),
                const SizedBox(height: 16),
                PayloadText(
                  link.host,
                  type: ParsedType.url,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ResultContentBox(
                  child: PayloadText(
                    link.url,
                    type: ParsedType.url,
                    selectable: true,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: LinkWarningSheet.copyWithoutOpeningButtonKey,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      ResultPrimaryButton.minHeight,
                    ),
                  ),
                  onPressed: () =>
                      unawaited(_act(context, onCopyWithoutOpening)),
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.resultLinkCopyWithoutOpeningButton),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: LinkWarningSheet.openAnywayButtonKey,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      ResultPrimaryButton.minHeight,
                    ),
                  ),
                  onPressed: () => unawaited(_act(context, onOpenAnyway)),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.resultLinkOpenAnywayButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// LINK-4: runs one of the two actions, then closes the sheet — the only
  /// way it ever closes.
  Future<void> _act(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    await action();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// One plain-language line for a triggered check (LINK-3, LINK-4): an icon
/// and text together, so nothing here is said by colour alone (A11Y-6).
class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.check, required this.l10n});

  final LinkCheck check;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(_iconFor(check), color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _lineFor(l10n, check),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(LinkCheck check) => switch (check) {
    LinkCheck.ipAddressHost => Icons.dns_outlined,
    LinkCheck.userinfo => Icons.person_outline,
    LinkCheck.insecureScheme => Icons.lock_open,
    LinkCheck.nonDefaultPort => Icons.settings_ethernet,
    LinkCheck.longUrl => Icons.straighten,
  };

  static String _lineFor(AppLocalizations l10n, LinkCheck check) =>
      switch (check) {
        LinkCheck.ipAddressHost => l10n.resultLinkCheckIpAddressHost,
        LinkCheck.userinfo => l10n.resultLinkCheckUserinfo,
        LinkCheck.insecureScheme => l10n.resultLinkCheckInsecureScheme,
        LinkCheck.nonDefaultPort => l10n.resultLinkCheckNonDefaultPort,
        LinkCheck.longUrl => l10n.resultLinkCheckLongUrl,
      };
}
