import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/settings_state.dart';

/// RUN-8: the one-time callout above a link result's actions, explaining
/// that the app checks links before opening them.
///
/// Shown above every link result — Open or Review, clean or warned — until
/// [SettingsState.linkCalloutSeen] is true, which the close button sets
/// (RUN-8: "one tap dismisses it for good"). It is never shown for a
/// blocked link (LINK-5): that result never offers Open or Review, so there
/// is nothing here for the callout to explain.
///
/// Reads and writes [SettingsState] straight from this presentational
/// widget, the same way `settings_screen.dart` does for its own switches
/// (`CLAUDE.md`): a stored user preference, not a device service, so no
/// state-layer method is needed just to shuttle it through.
class LinkCallout extends StatelessWidget {
  const LinkCallout({super.key});

  /// So a widget test can find the dismiss button by its own identity
  /// rather than by the icon it happens to draw.
  static const Key dismissButtonKey = Key('result.link_callout.dismiss');

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = context.watch<SettingsState>();
    if (settings.linkCalloutSeen) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.verified_user_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 12),
                  child: Text(
                    l10n.resultLinkCalloutMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: LinkCallout.dismissButtonKey,
                icon: const Icon(Icons.close),
                tooltip: l10n.resultLinkCalloutDismissTooltip,
                color: theme.colorScheme.onSecondaryContainer,
                onPressed: () => unawaited(
                  context.read<SettingsState>().dismissLinkCallout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
