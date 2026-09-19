import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/device/play_billing_service.dart';

PurchaseDetails _purchase(PurchaseStatus status, {String id = 'remove_ads'}) =>
    PurchaseDetails(
      productID: id,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'local',
        serverVerificationData: 'server',
        source: 'google_play',
      ),
      transactionDate: '0',
      status: status,
    );

void main() {
  group('mapProductDetails (PRO-5)', () {
    test('carries the store\'s own localised price string and nothing else '
        'invented on top of it', () {
      final ProductDetails details = ProductDetails(
        id: removeAdsProductId,
        title: 'Remove ads',
        description: 'One-time purchase',
        price: 'AED 11.99',
        rawPrice: 11.99,
        currencyCode: 'AED',
      );
      final StoreProduct product = mapProductDetails(details);
      expect(product.id, removeAdsProductId);
      expect(product.title, 'Remove ads');
      expect(product.formattedPrice, 'AED 11.99');
    });
  });

  group('mapPurchaseStatus (PRO-1, PRO-6, PRO-7)', () {
    test('purchased and restored both mean the account owns it', () {
      expect(
        mapPurchaseStatus(PurchaseStatus.purchased),
        PurchaseOutcome.purchased,
      );
      expect(
        mapPurchaseStatus(PurchaseStatus.restored),
        PurchaseOutcome.purchased,
      );
    });

    test('pending, cancelled and error keep their own outcome', () {
      expect(
        mapPurchaseStatus(PurchaseStatus.pending),
        PurchaseOutcome.pending,
      );
      expect(
        mapPurchaseStatus(PurchaseStatus.canceled),
        PurchaseOutcome.cancelled,
      );
      expect(mapPurchaseStatus(PurchaseStatus.error), PurchaseOutcome.error);
    });
  });

  group('ownsProductForStatus (PRO-6, PRO-7)', () {
    test('only purchased and restored count as owned', () {
      expect(ownsProductForStatus(PurchaseStatus.purchased), isTrue);
      expect(ownsProductForStatus(PurchaseStatus.restored), isTrue);
      expect(ownsProductForStatus(PurchaseStatus.pending), isFalse);
      expect(ownsProductForStatus(PurchaseStatus.canceled), isFalse);
      expect(ownsProductForStatus(PurchaseStatus.error), isFalse);
    });
  });

  group('applyPurchaseUpdate (PRO-6, PRO-7)', () {
    test('a purchased update grants ownership', () {
      final Set<String> owned = applyPurchaseUpdate(
        <String>{},
        _purchase(PurchaseStatus.purchased),
      );
      expect(owned, <String>{'remove_ads'});
    });

    test('a restored update grants ownership the same way "Restore '
        'purchase" needs (PRO-6)', () {
      final Set<String> owned = applyPurchaseUpdate(
        <String>{},
        _purchase(PurchaseStatus.restored),
      );
      expect(owned, <String>{'remove_ads'});
    });

    test('an errored update takes ownership away, which is how a refund '
        'shows up once a restore stops repeating a purchase (PRO-7)', () {
      final Set<String> owned = applyPurchaseUpdate(<String>{
        'remove_ads',
      }, _purchase(PurchaseStatus.error));
      expect(owned, isEmpty);
    });

    test('a cancelled update takes ownership away too', () {
      final Set<String> owned = applyPurchaseUpdate(<String>{
        'remove_ads',
      }, _purchase(PurchaseStatus.canceled));
      expect(owned, isEmpty);
    });

    test('a pending update changes nothing yet: ownership arrives with a '
        'later update on the same id (PRO-7)', () {
      final Set<String> owned = applyPurchaseUpdate(
        <String>{},
        _purchase(PurchaseStatus.pending),
      );
      expect(owned, isEmpty);

      final Set<String> stillOwned = applyPurchaseUpdate(<String>{
        'remove_ads',
      }, _purchase(PurchaseStatus.pending));
      expect(stillOwned, <String>{'remove_ads'});
    });

    test('leaves every other id in the set untouched', () {
      final Set<String> owned = applyPurchaseUpdate(<String>{
        'some_other_product',
      }, _purchase(PurchaseStatus.purchased));
      expect(owned, <String>{'some_other_product', 'remove_ads'});
    });
  });

  group('restorePurchases (PRO-7)', () {
    test('an offline restore throws instead of answering "owns nothing", so '
        'an owner keeps the cached Pro', () async {
      final _OfflineStore store = _OfflineStore();
      final PlayBillingService billing = PlayBillingService(
        inAppPurchase: store,
      );
      await billing.initialize();

      await expectLater(billing.restorePurchases(), throwsA(isA<StateError>()));
      await billing.dispose();
      await store.close();
    });
  });
}

/// A store the app can't reach: restoring fails straight away.
class _OfflineStore implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _purchases =
      StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.stream;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    throw StateError('offline');
  }

  Future<void> close() => _purchases.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
