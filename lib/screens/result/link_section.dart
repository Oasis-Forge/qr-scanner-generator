import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/link_check.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parsed_payload.dart';
import '../../models/record_enums.dart';
import '../../state/result_state.dart';
import '../scanner/payload_text.dart';
import 'link_callout.dart';
import 'link_warning_sheet.dart';
import 'result_actions.dart';
import 'result_field.dart';

/// A link result (LINK-1 to LINK-5, LINK-8, LINK-9, RES-11).
///
/// A blocked link (LINK-5) shows the full URL and a notice that it can't be
/// opened, with only Copy and Share — [ResultState.openLink] is never
/// called, and neither is [ResultState.linkChecks], which is always empty
/// for one. Every other link shows the URL (monospace, selectable), the
/// emphasised host, and one primary action: "Open" with no check
/// triggered, or "Review" with any (LINK-3), which opens the warning sheet
/// (LINK-4) rather than opening the link directly. Both routes end at the
/// same [ResultState.openLink] call (LINK-8), so a clean Open and the
/// sheet's "Open anyway" can never disagree about how a link is opened.
///
/// An app-store link (`play.google.com/store/apps/...`, RES-11) is parsed
/// as an ordinary [Link] (`payload_classifier.dart`) and gets exactly this
/// same flow: nothing here treats it differently.
class LinkSection extends StatelessWidget {
  const LinkSection({required this.link, super.key});

  final Link link;

  /// The note shown instead of Open or Review on a blocked link (LINK-5).
  static const Key blockedNoticeKey = Key('result.link.blocked_notice');

  /// The larger, bold host line (LINK-2).
  static const Key hostKey = Key('result.link.host');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ResultState state = context.watch<ResultState>();

    final Widget urlBox = ResultContentBox(
      child: PayloadText(
        link.url,
        type: ParsedType.url,
        selectable: true,
        style: AppTheme.mono(size: 12, color: theme.colorScheme.onSurface),
      ),
    );

    if (link.isBlocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          urlBox,
          const SizedBox(height: 16),
          ResultNote(
            key: LinkSection.blockedNoticeKey,
            icon: Icons.block,
            message: l10n.resultLinkBlockedNotice(
              link.uri.scheme.toLowerCase(),
            ),
          ),
          const SizedBox(height: 24),
          // LINK-5: Copy only. Share would hand the link to another app,
          // which might open what this app refuses to.
          ResultPrimaryButton(
            label: l10n.resultCopyButton,
            icon: Icons.copy,
            onPressed: () => copyContent(context),
          ),
        ],
      );
    }

    final List<LinkCheck> checks = state.linkChecks;
    final bool hasWarnings = checks.isNotEmpty;

    // LINK-2: the name first and large, because that is what says where the
    // link goes; the address itself follows in the machine's own voice.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (link.host.isNotEmpty) ...<Widget>[
          PayloadText(
            link.host,
            key: LinkSection.hostKey,
            type: ParsedType.url,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
        ],
        urlBox,
        const SizedBox(height: 16),
        const LinkCallout(),
        ResultPrimaryButton(
          label: hasWarnings
              ? l10n.resultLinkReviewButton
              : l10n.resultLinkOpenButton,
          icon: hasWarnings ? Icons.warning_amber_rounded : Icons.open_in_new,
          onPressed: state.canOpenLink
              ? () => hasWarnings
                    ? showLinkWarningSheet(
                        context,
                        link: link,
                        checks: checks,
                        onCopyWithoutOpening: () => copyContent(context),
                        onOpenAnyway: () =>
                            performLinkHandOff(context, state.openLink),
                      )
                    : performLinkHandOff(context, state.openLink)
              : null,
          unavailableReason: l10n.resultUnavailableBrowser,
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
