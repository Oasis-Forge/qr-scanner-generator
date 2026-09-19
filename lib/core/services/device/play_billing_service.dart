import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../billing_service.dart';

/// The app's one non-consumable product: one-time, never a subscription
/// (PRO-1).
const String removeAdsProductId = 'remove_ads';

/// How long [PlayBillingService.restorePurchases] waits for the Play
/// Store's restored-purchase events to arrive on the purchase stream before
/// deciding restore is done.
///
/// The plugin's own `restorePurchases()` future completes once the request
/// was sent, not once every restored purchase has arrived on
/// [InAppPurchase.purchaseStream]; there is no other signal for "finished".
const Duration restoreGracePeriod = Duration(seconds: 2);

/// A store [ProductDetails] as this app shows it: the store's own localised
/// price string, the only price ever shown (PRO-5).
StoreProduct mapProductDetails(ProductDetails details) => StoreProduct(
  id: details.id,
  title: details.title,
  formattedPrice: details.price,
);

/// A purchase update's [PurchaseDetails.status] → [PurchaseOutcome].
///
/// [PurchaseStatus.restored] counts as [PurchaseOutcome.purchased]: both mean
/// this account owns the product, and "Restore purchase" (PRO-6) only needs
/// to know that. A status this app never asked for a result on (an
/// unprompted restore or a delivery from a previous session) still maps
/// cleanly, since [PlayBillingService] uses this to update the owned set on
/// every purchase update, not only the ones [PlayBillingService.buy] is
/// waiting on.
PurchaseOutcome mapPurchaseStatus(PurchaseStatus status) {
  switch (status) {
    case PurchaseStatus.purchased:
    case PurchaseStatus.restored:
      return PurchaseOutcome.purchased;
    case PurchaseStatus.pending:
      return PurchaseOutcome.pending;
    case PurchaseStatus.canceled:
      return PurchaseOutcome.cancelled;
    case PurchaseStatus.error:
      return PurchaseOutcome.error;
  }
}

/// Whether [status] means the account owns the product (PRO-6, PRO-7).
bool ownsProductForStatus(PurchaseStatus status) =>
    status == PurchaseStatus.purchased || status == PurchaseStatus.restored;

/// [owned] with [update] applied (PRO-6, PRO-7).
///
/// A purchased or restored update adds [PurchaseDetails.productID]; a
/// cancelled or errored one removes it, which is also how a refund is
/// represented after [PlayBillingService.restorePurchases] rebuilds the whole
/// set from what the store restores (a product that used to be owned and
/// isn't restored again is simply left out). A pending update changes
/// nothing yet: ownership arrives with a later update on the same id (PRO-7).
Set<String> applyPurchaseUpdate(Set<String> owned, PurchaseDetails update) {
  final Set<String> next = Set<String>.of(owned);
  if (ownsProductForStatus(update.status)) {
    next.add(update.productID);
  } else if (update.status != PurchaseStatus.pending) {
    next.remove(update.productID);
  }
  return next;
}

/// The one-time Pro purchase through Play Billing (PRO-1, PRO-6, PRO-7).
///
/// A single [InAppPurchase.purchaseStream] subscription, started by
/// [initialize], is the only place ownership is decided: it applies every
/// update to the cached owned set with [applyPurchaseUpdate], completes any
/// purchase the plugin says is still pending completion, and republishes the
/// set on [ownedProducts]. [buy] and [restorePurchases] each open their own
/// short-lived listener purely to turn the plugin's fire-and-forget calls
/// into the `Future` this app's [BillingService] interface expects; neither
/// one decides ownership itself.
///
/// Built only by the app's entry point.
class PlayBillingService implements BillingService {
  PlayBillingService({InAppPurchase? inAppPurchase})
    : _iap = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Set<String> _owned = <String>{};

  final StreamController<Set<String>> _ownership =
      StreamController<Set<String>>.broadcast();

  @override
  Future<void> initialize() async {
    _subscription = _iap.purchaseStream.listen(_applyUpdates);
    try {
      await _iap.isAvailable();
    } on Object {
      // Buys nothing either way; a later call finds out for itself.
    }
  }

  Future<void> _applyUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      _owned = applyPurchaseUpdate(_owned, purchase);
      if (purchase.pendingCompletePurchase &&
          purchase.status != PurchaseStatus.pending) {
        try {
          await _iap.completePurchase(purchase);
        } on Object {
          // Retried the next time this purchase arrives on the stream, which
          // the plugin guarantees happens again next session if it doesn't
          // this one (`InAppPurchase.purchaseStream`'s own contract).
        }
      }
    }
    _ownership.add(Set<String>.unmodifiable(_owned));
  }

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        <String>{productId},
      );
      if (response.productDetails.isEmpty) {
        return null;
      }
      return mapProductDetails(response.productDetails.first);
    } on Object {
      return null;
    }
  }

  @override
  Future<PurchaseResult> buy(String productId) async {
    if (_owned.contains(productId)) {
      return const PurchaseResult(outcome: PurchaseOutcome.alreadyOwned);
    }
    late final ProductDetailsResponse response;
    try {
      response = await _iap.queryProductDetails(<String>{productId});
    } on Object {
      return const PurchaseResult(
        outcome: PurchaseOutcome.unavailable,
        message: 'Could not reach the store',
      );
    }
    if (response.productDetails.isEmpty) {
      return PurchaseResult(
        outcome: PurchaseOutcome.unavailable,
        message: response.error?.message,
      );
    }

    final Completer<PurchaseResult> result = Completer<PurchaseResult>();
    late final StreamSubscription<List<PurchaseDetails>> subscription;
    subscription = _iap.purchaseStream.listen((
      List<PurchaseDetails> purchases,
    ) {
      for (final PurchaseDetails purchase in purchases) {
        if (purchase.productID != productId || result.isCompleted) {
          continue;
        }
        result.complete(
          PurchaseResult(
            outcome: mapPurchaseStatus(purchase.status),
            message: purchase.error?.message,
          ),
        );
      }
      if (result.isCompleted) {
        unawaited(subscription.cancel());
      }
    });

    bool started;
    try {
      started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: response.productDetails.first,
        ),
      );
    } on Object {
      started = false;
    }
    if (!started && !result.isCompleted) {
      result.complete(
        const PurchaseResult(
          outcome: PurchaseOutcome.error,
          message: 'The store did not open a purchase sheet',
        ),
      );
      unawaited(subscription.cancel());
    }
    return result.future;
  }

  @override
  Future<Set<String>> restorePurchases() async {
    final Set<String> restored = <String>{};
    late final StreamSubscription<List<PurchaseDetails>> subscription;
    subscription = _iap.purchaseStream.listen((
      List<PurchaseDetails> purchases,
    ) {
      for (final PurchaseDetails purchase in purchases) {
        if (ownsProductForStatus(purchase.status)) {
          restored.add(purchase.productID);
        }
      }
    });
    try {
      await _iap.restorePurchases();
      await Future<void>.delayed(restoreGracePeriod);
    } on Object {
      // Offline or refused: no answer, so rethrow and let the caller keep its
      // cached ownership (PRO-7). Returning what this service knows would
      // hand back an empty set at start-up and take Pro from an offline owner.
      await subscription.cancel();
      rethrow;
    }
    await subscription.cancel();
    _owned = restored;
    _ownership.add(Set<String>.unmodifiable(_owned));
    return Set<String>.unmodifiable(_owned);
  }

  @override
  Future<bool> isOwned(String productId) async => _owned.contains(productId);

  @override
  Stream<Set<String>> get ownedProducts => _ownership.stream;

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _ownership.close();
  }
}
