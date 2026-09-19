import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/success_counts.dart';

class _FakeKeyValueStore implements KeyValueStore {
  _FakeKeyValueStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  final Map<String, String> values;
  final List<String> writes = <String>[];

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    writes.add('set $key=$value');
    values[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => int.tryParse(values[key] ?? '');

  @override
  Future<void> setInt(String key, int value) => setString(key, '$value');

  @override
  Future<bool?> getBool(String key) async => switch (values[key]) {
    '1' => true,
    '0' => false,
    _ => null,
  };

  @override
  Future<void> setBool(String key, {required bool value}) =>
      setString(key, value ? '1' : '0');

  @override
  Future<int> increment(String key, {int by = 1}) async {
    final int next = (int.tryParse(values[key] ?? '') ?? 0) + by;
    await setString(key, '$next');
    return next;
  }

  @override
  Future<void> remove(String key) async {
    writes.add('remove $key');
    values.remove(key);
  }

  @override
  Future<Map<String, String>> all() async => Map<String, String>.of(values);
}

/// A [BillingService] that always fails to reach the store, standing in for
/// being offline (PRO-7).
class _OfflineBillingService implements BillingService {
  @override
  Future<void> initialize() async {}

  @override
  Future<StoreProduct?> loadProduct(String productId) async => null;

  @override
  Future<PurchaseResult> buy(String productId) async =>
      throw StateError('offline');

  @override
  Future<Set<String>> restorePurchases() async => throw StateError('offline');

  @override
  Future<bool> isOwned(String productId) async => false;

  @override
  Stream<Set<String>> get ownedProducts => const Stream<Set<String>>.empty();

  @override
  Future<void> dispose() async {}
}

void main() {
  late _FakeKeyValueStore store;
  late SuccessCounts successCounts;

  Future<SuccessCounts> countsAt(int successes) async {
    final SuccessCounts counts = SuccessCounts(_FakeKeyValueStore());
    await counts.load();
    for (var i = 0; i < successes; i++) {
      await counts.recordSuccessfulScan();
    }
    return counts;
  }

  setUp(() {
    store = _FakeKeyValueStore();
  });

  tearDown(() => successCounts.dispose());

  group('load (PRO-7)', () {
    test(
      'a fresh install owns nothing and the prompt is not dismissed',
      () async {
        successCounts = await countsAt(0);
        final ProState pro = ProState(
          billing: NoopBillingService(),
          store: store,
          successCounts: successCounts,
        );

        await pro.load();
        await pro.startupCheck;

        expect(pro.isLoaded, isTrue);
        expect(pro.isOwned, isFalse);
        expect(store.writes, isEmpty);
        pro.dispose();
      },
    );

    test('an offline owner still sees no ads: the cache answers before the '
        'store is asked, and a failed re-check does not clear it', () async {
      successCounts = await countsAt(0);
      store.values[ProState.ownedKey] = '1';
      final ProState pro = ProState(
        billing: _OfflineBillingService(),
        store: store,
        successCounts: successCounts,
      );

      await pro.load();
      await pro.startupCheck;

      expect(pro.isOwned, isTrue);
      pro.dispose();
    });

    test(
      're-checks with the store when online and updates the cache (PRO-6)',
      () async {
        successCounts = await countsAt(0);
        final NoopBillingService billing = NoopBillingService(
          owned: <String>{ProState.removeAdsProductId},
        );
        final ProState pro = ProState(
          billing: billing,
          store: store,
          successCounts: successCounts,
        );

        await pro.load();
        await pro.startupCheck;

        expect(pro.isOwned, isTrue);
        expect(store.values[ProState.ownedKey], '1');
        pro.dispose();
      },
    );

    test('a refund arriving on the ownership stream turns ads back on '
        '(PRO-7)', () async {
      successCounts = await countsAt(0);
      final NoopBillingService billing = NoopBillingService(
        owned: <String>{ProState.removeAdsProductId},
      );
      final ProState pro = ProState(
        billing: billing,
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;
      expect(pro.isOwned, isTrue);

      final Completer<void> notified = Completer<void>();
      pro.addListener(() {
        if (!notified.isCompleted) {
          notified.complete();
        }
      });
      billing.revokeOwnership(ProState.removeAdsProductId);
      await notified.future.timeout(const Duration(seconds: 2));

      expect(pro.isOwned, isFalse);
      expect(store.values[ProState.ownedKey], '0');
      pro.dispose();
    });

    test('a refund found by the start-up re-check turns ads back on '
        '(PRO-7)', () async {
      successCounts = await countsAt(0);
      store.values[ProState.ownedKey] = '1';
      final ProState pro = ProState(
        billing: NoopBillingService(),
        store: store,
        successCounts: successCounts,
      );

      await pro.load();
      expect(pro.isOwned, isTrue, reason: 'the cache answers first');
      await pro.startupCheck;

      expect(pro.isOwned, isFalse);
      expect(store.values[ProState.ownedKey], '0');
      pro.dispose();
    });
  });

  group('buy and restore (PRO-1, PRO-6)', () {
    test('buy applies ownership immediately when the result reports owning '
        'the product, "already owned" included (PRO-6)', () async {
      successCounts = await countsAt(0);
      final NoopBillingService billing = NoopBillingService(
        product: const StoreProduct(
          id: ProState.removeAdsProductId,
          title: 'Remove ads',
          formattedPrice: r'$1.99',
        ),
      );
      billing.grantOwnership(ProState.removeAdsProductId);
      final ProState pro = ProState(
        billing: billing,
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;
      // The store already owns it (an already-owned purchase, PRO-6).
      final PurchaseResult result = await pro.buy();

      expect(result.outcome, PurchaseOutcome.alreadyOwned);
      expect(pro.isOwned, isTrue);
      pro.dispose();
    });

    test('restore reports what it found, and a failure reaches the caller '
        'unlike the best-effort start-up re-check', () async {
      successCounts = await countsAt(0);
      final ProState pro = ProState(
        billing: _OfflineBillingService(),
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;

      await expectLater(pro.restore(), throwsStateError);
      expect(pro.isOwned, isFalse);
      pro.dispose();
    });

    test('the store\'s own price is exposed once loaded (PRO-5)', () async {
      successCounts = await countsAt(0);
      final ProState pro = ProState(
        billing: NoopBillingService(
          product: const StoreProduct(
            id: ProState.removeAdsProductId,
            title: 'Remove ads',
            formattedPrice: r'$1.99',
          ),
        ),
        store: store,
        successCounts: successCounts,
      );

      await pro.load();
      await pro.startupCheck;

      expect(pro.product?.formattedPrice, r'$1.99');
      pro.dispose();
    });
  });

  group('shouldOfferPrompt (PRO-4)', () {
    test('false before the fifth success', () async {
      successCounts = await countsAt(4);
      final ProState pro = ProState(
        billing: NoopBillingService(),
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;

      expect(pro.shouldOfferPrompt, isFalse);
      pro.dispose();
    });

    test('true after the fifth success, for an install that has not '
        'bought or dismissed', () async {
      successCounts = await countsAt(5);
      final ProState pro = ProState(
        billing: NoopBillingService(),
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;

      expect(pro.shouldOfferPrompt, isTrue);
      pro.dispose();
    });

    test('false for a Pro owner, even past the threshold', () async {
      successCounts = await countsAt(5);
      final ProState pro = ProState(
        billing: NoopBillingService(
          owned: <String>{ProState.removeAdsProductId},
        ),
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;

      expect(pro.shouldOfferPrompt, isFalse);
      pro.dispose();
    });

    test('dismiss writes before it changes the answer, and stays dismissed '
        'after a reload; a second call writes nothing (PRO-4)', () async {
      successCounts = await countsAt(5);
      final ProState pro = ProState(
        billing: NoopBillingService(),
        store: store,
        successCounts: successCounts,
      );
      await pro.load();
      await pro.startupCheck;
      expect(pro.shouldOfferPrompt, isTrue);

      await pro.dismiss();
      expect(pro.shouldOfferPrompt, isFalse);
      expect(store.values[ProState.promptDismissedKey], '1');

      await pro.dismiss();
      expect(
        store.writes.where(
          (String w) => w.contains(ProState.promptDismissedKey),
        ),
        hasLength(1),
      );
      pro.dispose();

      final ProState reloaded = ProState(
        billing: NoopBillingService(),
        store: store,
        successCounts: successCounts,
      );
      await reloaded.load();
      await reloaded.startupCheck;
      expect(reloaded.shouldOfferPrompt, isFalse);
      reloaded.dispose();
    });
  });
}
