import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/billing_service.dart';
import '../core/store/key_value_store.dart';
import 'success_counts.dart';

/// Pro: one non-consumable purchase that removes ads (PRO-1, PRO-2).
///
/// Ownership is cached in a [KeyValueStore], so an offline owner still sees no
/// ads (PRO-7): [load] reads that cache first and notifies with it before
/// asking the store anything. It then subscribes to
/// [BillingService.ownedProducts] for as long as this [ProState] lives, so a
/// refund arriving on that stream takes Pro away the moment the store reports
/// it, and separately re-checks with [BillingService.restorePurchases] once,
/// which is the "at every start when online" [load] is called for. Both paths
/// go through [_applyOwnership], so a refund is simply "the product is no
/// longer in the set the store hands back" either way.
///
/// The one Pro prompt (PRO-4) is gated the same reliable-write way every other
/// setting is (`CLAUDE.md`): [dismiss] writes before it changes
/// [shouldOfferPrompt]'s answer, and a failed write leaves the prompt exactly
/// as offered as it was.
class ProState extends ChangeNotifier {
  ProState({
    required BillingService billing,
    required KeyValueStore store,
    required SuccessCounts successCounts,
  }) : _billing = billing,
       _store = store,
       _successCounts = successCounts;

  /// The one product this app sells (PRO-1).
  ///
  /// This mirrors `lib/core/services/device/play_billing_service.dart`'s own
  /// `removeAdsProductId`: that file is real Play Billing plugin code, which
  /// `lib/state/` never imports (`CLAUDE.md`), so the id is repeated here
  /// rather than imported from it. Both must read `'remove_ads'`.
  static const String removeAdsProductId = 'remove_ads';

  /// Stores whether [removeAdsProductId] is owned, `'1'`/`'0'` (PRO-7).
  static const String ownedKey = 'pro.owned';

  /// Stores whether the one Pro prompt has already been shown and dismissed
  /// (PRO-4).
  static const String promptDismissedKey = 'prompts.pro_dismissed';

  final BillingService _billing;
  final KeyValueStore _store;
  final SuccessCounts _successCounts;

  StreamSubscription<Set<String>>? _ownershipSubscription;

  bool _isOwned = false;
  bool _promptDismissed = false;
  StoreProduct? _product;
  bool _isLoaded = false;

  /// Whether [load] has finished reading the cache. Until then [isOwned]
  /// reads `false`, the same as a fresh install with nothing purchased yet.
  bool get isLoaded => _isLoaded;

  /// Whether [removeAdsProductId] is owned (PRO-7). Ads stay off for the rest
  /// of this app while this is true (ADS-7).
  bool get isOwned => _isOwned;

  /// The product's Play listing, once [load] or [loadProduct] has fetched it,
  /// for its own localised price (PRO-5). `null` before it loads or when the
  /// store has none to offer, in which case the Settings row shows no price.
  StoreProduct? get product => _product;

  /// Whether the one dismissible Pro prompt may still be offered this install
  /// (PRO-4): not owned, not already dismissed, and the fifth successful scan
  /// or create has happened (`SuccessCounts.hasReachedProPromptThreshold`,
  /// DATA-8).
  bool get shouldOfferPrompt =>
      !_isOwned &&
      !_promptDismissed &&
      _successCounts.hasReachedProPromptThreshold;

  /// Reads the cached ownership and the prompt flag and notifies, then
  /// starts the ownership stream and the one start-up re-check (PRO-6,
  /// PRO-7).
  ///
  /// Returns once the cache is read, so the app can await it before its first
  /// frame without waiting on the store; the re-check carries on behind it
  /// as [startupCheck]. Every value is decoded before any field is assigned,
  /// so a read that throws leaves the cache exactly as a fresh install's
  /// (BAK-5).
  Future<void> load() async {
    final bool? ownedCached = await _store.getBool(ownedKey);
    final bool? dismissed = await _store.getBool(promptDismissedKey);

    _isOwned = ownedCached ?? false;
    _promptDismissed = dismissed ?? false;
    _isLoaded = true;
    notifyListeners();

    _ownershipSubscription ??= _billing.ownedProducts.listen(
      (Set<String> owned) => unawaited(_applyOwnershipQuietly(owned)),
    );

    unawaited(loadProduct());
    _startupCheck = _recheckQuietly();
  }

  Future<void>? _startupCheck;

  /// The start-up re-check [load] began, done once the store has answered or
  /// failed to. Never throws.
  Future<void> get startupCheck => _startupCheck ?? Future<void>.value();

  /// Asks the store what this account owns and applies it. Being offline is
  /// the ordinary case PRO-7 is about, not a failure to report: the cache
  /// read by [load] is what an offline owner keeps seeing until a later start
  /// succeeds.
  Future<void> _recheckQuietly() async {
    try {
      final Set<String> owned = await _billing.restorePurchases();
      await _applyOwnership(owned);
    } on Object {
      // See above.
    }
  }

  /// Fetches the product's Play listing for its price (PRO-5). Called by
  /// [load]; a screen may call it again to retry after it came back `null`.
  Future<void> loadProduct() async {
    final StoreProduct? loaded = await _billing.loadProduct(removeAdsProductId);
    if (loaded == null) {
      return;
    }
    _product = loaded;
    notifyListeners();
  }

  /// Opens the store's own purchase sheet for [removeAdsProductId] (PRO-1).
  ///
  /// A successful or already-owned result is applied to the cache the same
  /// way a restore or a stream update is, before this returns, so the caller
  /// sees [isOwned] true immediately after. A cancelled, pending, unavailable
  /// or errored result changes nothing; the caller reads [PurchaseResult] to
  /// decide what to tell the user.
  Future<PurchaseResult> buy() async {
    final PurchaseResult result = await _billing.buy(removeAdsProductId);
    if (result.ownsProduct) {
      await _applyOwnership(<String>{removeAdsProductId});
    }
    return result;
  }

  /// Re-checks the store for what this account owns (PRO-6), applies it, and
  /// returns whether [removeAdsProductId] is owned afterwards.
  ///
  /// Unlike the best-effort re-check inside [load], a failure here (offline,
  /// the store refused) is left to reach the caller, since this is "Restore
  /// purchase" answering a tap, and the screen needs to say the restore
  /// didn't go through rather than quietly keep the old cache.
  Future<bool> restore() async {
    final Set<String> owned = await _billing.restorePurchases();
    await _applyOwnership(owned);
    return _isOwned;
  }

  /// Marks the one Pro prompt dismissed, so [shouldOfferPrompt] never answers
  /// true again on this install (PRO-4).
  ///
  /// Writes before it changes [shouldOfferPrompt]'s answer; a failed write
  /// leaves the prompt exactly as offered as it was; a second call once it
  /// already succeeded writes nothing and notifies nobody.
  Future<void> dismiss() async {
    if (_promptDismissed) {
      return;
    }
    await _store.setBool(promptDismissedKey, value: true);
    _promptDismissed = true;
    notifyListeners();
  }

  /// [_applyOwnership], swallowing a write failure.
  ///
  /// Used only for updates that arrive on [BillingService.ownedProducts]:
  /// there is no caller waiting on this one to report a failed cache write
  /// to, so it is logged nowhere further and simply tried again the next time
  /// the stream or a start-up re-check brings the same ownership.
  Future<void> _applyOwnershipQuietly(Set<String> owned) async {
    try {
      await _applyOwnership(owned);
    } on Object {
      // See above: nothing to report this to, and the next update retries it.
    }
  }

  /// Writes [owned]'s verdict on [removeAdsProductId] to the cache before
  /// changing [isOwned], the same reliable-write order every setting uses
  /// (`CLAUDE.md`). A refund is simply `owned` no longer containing the id,
  /// which turns ads back on the next time `AdsState.isAllowed` is asked
  /// (ADS-7, PRO-7).
  Future<void> _applyOwnership(Set<String> owned) async {
    final bool owns = owned.contains(removeAdsProductId);
    if (owns == _isOwned) {
      return;
    }
    await _store.setBool(ownedKey, value: owns);
    _isOwned = owns;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_ownershipSubscription?.cancel());
    super.dispose();
  }
}
