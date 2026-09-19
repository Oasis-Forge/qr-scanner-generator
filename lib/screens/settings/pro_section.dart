import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/billing_service.dart';
import '../../l10n/app_localizations.dart';
import '../../state/pro_state.dart';
import 'settings_rows.dart';

/// Settings' third group: remove ads and restore purchase (SET-5, PRO-1,
/// PRO-4, PRO-5, PRO-6).
///
/// Presentational only (`CLAUDE.md`): it reads [ProState] with
/// `context.watch` and calls its [ProState.buy] and [ProState.restore], which
/// are the only place a purchase or a restore is ever started.
class ProSection extends StatelessWidget {
  const ProSection({super.key});

  /// The row that starts the purchase, or, once owned, just says so (PRO-1,
  /// PRO-4).
  static const Key removeAdsKey = Key('settings.remove_ads');

  /// The row that re-checks ownership with the store (PRO-6).
  static const Key restorePurchaseKey = Key('settings.restore_purchase');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ProState pro = context.watch<ProState>();
    final String? price = pro.product?.formattedPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingsSectionHeader(title: l10n.settingsGroupPro),
        pro.isOwned
            ? SettingsNavRow(
                rowKey: removeAdsKey,
                title: l10n.settingsProOwned,
                leading: const Icon(Icons.check_circle_outline),
              )
            : SettingsNavRow(
                rowKey: removeAdsKey,
                title: l10n.settingsRemoveAds,
                subtitle: price == null
                    ? l10n.settingsRemoveAdsSubtitle
                    : l10n.settingsRemoveAdsPrice(price),
                onTap: () => unawaited(_buy(context, pro)),
              ),
        SettingsNavRow(
          rowKey: restorePurchaseKey,
          title: l10n.settingsRestorePurchase,
          onTap: () => unawaited(_restore(context, pro)),
        ),
      ],
    );
  }

  /// Starts the purchase sheet and reports only a hard failure (PRO-1).
  ///
  /// A cancelled or still-pending outcome says nothing: the user's own choice
  /// needs no message, and a pending purchase's ownership arrives later on
  /// [ProState]'s own stream (PRO-7), which repaints this row by itself.
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

  /// Re-checks ownership with the store and says what it found (PRO-6).
  static Future<void> _restore(BuildContext context, ProState pro) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final bool owned = await pro.restore();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            owned ? l10n.proRestoreSuccess : l10n.proRestoreNotFound,
          ),
        ),
      );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.proRestoreFailed)));
    }
  }
}
