import 'dart:async';

/// A one-time, non-consumable store product.
///
/// The app's only product is `remove_ads`: one-time, never a subscription
/// (PRO-1), and it removes ads and nothing else (PRO-2). The product id lives
/// with the app, not here, so this interface stays reusable.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.formattedPrice,
  });

  final String id;

  final String title;

  /// The store's own localised price, the only price ever shown: no discount
  /// badge, crossed-out price or countdown (PRO-3, PRO-5).
  final String formattedPrice;
}

/// What became of a purchase attempt.
enum PurchaseOutcome {
  purchased,

  /// The account already owns it, so "Restore purchase" is all that was needed
  /// (PRO-6).
  alreadyOwned,

  /// The user dismissed the store's purchase sheet.
  cancelled,

  /// The store is still working on it; ownership arrives on the stream (PRO-7).
  pending,

  /// The product isn't available, for example offline or not yet live.
  unavailable,

  error,
}

/// The outcome of [BillingService.buy].
class PurchaseResult {
  const PurchaseResult({required this.outcome, this.message});

  final PurchaseOutcome outcome;

  /// A reason to show when the purchase didn't go through, or `null`.
  final String? message;

  bool get ownsProduct =>
      outcome == PurchaseOutcome.purchased ||
      outcome == PurchaseOutcome.alreadyOwned;
}

/// One-time purchases through the platform store.
///
/// Ownership is cached, so an offline owner still sees no ads, and a refund
/// brings ads back after the next successful online check (PRO-7).
abstract class BillingService {
  /// Connects to the store. Buys nothing.
  Future<void> initialize();

  /// The product's details from the store, or `null` when the store has none
  /// (offline, or the product isn't live).
  Future<StoreProduct?> loadProduct(String productId);

  /// Buys a one-time product, opening the store's own purchase sheet (PRO-1).
  Future<PurchaseResult> buy(String productId);

  /// Re-queries the store for what this account owns, behind "Restore purchase"
  /// and at every start when online (PRO-6). Returns the ids owned, and
  /// throws when the store can't answer (offline, refused), so the caller
  /// keeps its cached ownership (PRO-7).
  Future<Set<String>> restorePurchases();

  /// Whether [productId] is owned, answered from the cache when offline
  /// (PRO-7).
  Future<bool> isOwned(String productId);

  /// Ownership as it changes, a refund taking Pro away included (PRO-7).
  Stream<Set<String>> get ownedProducts;

  Future<void> dispose();
}

/// A [BillingService] that reaches no store.
///
/// It owns [owned] (nothing by default, so tests run as a free user), reports
/// [product] for any id when one is seeded, and records every call in [calls].
/// [grantOwnership] lets a test hand over Pro the way a finished purchase does,
/// including the [ownedProducts] event.
class NoopBillingService implements BillingService {
  NoopBillingService({Set<String> owned = const <String>{}, this.product})
    : _owned = Set<String>.of(owned);

  /// Every call made, in order, such as `'buy: remove_ads'`.
  final List<String> calls = <String>[];

  /// What [loadProduct] reports, or `null` for "the store has none".
  final StoreProduct? product;

  final Set<String> _owned;
  final StreamController<Set<String>> _ownership =
      StreamController<Set<String>>.broadcast();

  @override
  Future<void> initialize() async {
    calls.add('initialize');
  }

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
    calls.add('loadProduct: $productId');
    return product?.id == productId ? product : null;
  }

  @override
  Future<PurchaseResult> buy(String productId) async {
    calls.add('buy: $productId');
    if (_owned.contains(productId)) {
      return const PurchaseResult(outcome: PurchaseOutcome.alreadyOwned);
    }
    return const PurchaseResult(
      outcome: PurchaseOutcome.unavailable,
      message: 'No store in tests',
    );
  }

  @override
  Future<Set<String>> restorePurchases() async {
    calls.add('restorePurchases');
    return Set<String>.unmodifiable(_owned);
  }

  @override
  Future<bool> isOwned(String productId) async {
    calls.add('isOwned: $productId');
    return _owned.contains(productId);
  }

  @override
  Stream<Set<String>> get ownedProducts => _ownership.stream;

  /// Hands over [productId] the way a finished purchase or restore does.
  void grantOwnership(String productId) {
    _owned.add(productId);
    _ownership.add(Set<String>.unmodifiable(_owned));
  }

  /// Takes [productId] away the way a refund does (PRO-7).
  void revokeOwnership(String productId) {
    _owned.remove(productId);
    _ownership.add(Set<String>.unmodifiable(_owned));
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _ownership.close();
  }
}
