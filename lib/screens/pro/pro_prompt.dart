import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/billing_service.dart';
import '../../l10n/app_localizations.dart';
import '../../state/pro_state.dart';

/// The one dismissible Pro prompt (PRO-4): offered at most once per install,
/// on History or Settings, after the fifth successful scan or create.
///
/// Renders nothing while [ProState.shouldOfferPrompt] is false — owned,
/// already dismissed, or the threshold hasn't been reached — so a caller can
/// place this unconditionally near the top of History or Settings and trust
/// it to disappear by itself once it no longer applies.
///
/// Presentational only (`CLAUDE.md`): it reads [ProState] with
/// `context.watch` and calls [ProState.buy] and [ProState.dismiss], the same
/// two entry points Settings → Pro uses.
class ProPrompt extends StatelessWidget {
  const ProPrompt({super.key});

  /// Closes the prompt without buying (PRO-4).
  static const Key dismissButtonKey = Key('pro_prompt.dismiss');

  /// Starts the same purchase Settings → Remove ads does (PRO-1).
  static const Key buyButtonKey = Key('pro_prompt.buy');

  @override
  Widget build(BuildContext context) {
    final ProState pro = context.watch<ProState>();
    if (!pro.shouldOfferPrompt) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? price = pro.product?.formattedPrice;

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.proPromptTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: dismissButtonKey,
                  tooltip: l10n.proPromptDismissTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () => unawaited(pro.dismiss()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.proPromptBody),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: buyButtonKey,
                onPressed: () => unawaited(_buy(context, pro)),
                child: Text(
                  price == null
                      ? l10n.settingsRemoveAds
                      : l10n.settingsRemoveAdsPrice(price),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Starts the purchase sheet and reports only a hard failure, the same as
  /// Settings → Remove ads (PRO-1).
  static Future<void> _buy(BuildContext context, ProState pro) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failed = AppLocalizations.of(context).proBuyFailed;
    final PurchaseResult result = await pro.buy();
    if (result.ownsProduct ||
        result.outcome == PurchaseOutcome.cancelled ||
        result.outcome == PurchaseOutcome.pending) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
