import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/screens/pro/pro_prompt.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';
import '../settings/settings_scope.dart';

void main() {
  Future<SuccessCounts> countsAt(int successes) async {
    final SuccessCounts counts = SuccessCounts(FakeKeyValueStore());
    await counts.load();
    for (var i = 0; i < successes; i++) {
      await counts.recordSuccessfulScan();
    }
    return counts;
  }

  testWidgets('shows nothing before the fifth success (PRO-4)', (
    WidgetTester tester,
  ) async {
    final SuccessCounts counts = await countsAt(4);

    await pumpApp(
      tester,
      const SettingsScope(child: ProPrompt()),
      successCounts: counts,
    );

    expect(find.byType(ProPrompt), findsOneWidget);
    expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
  });

  testWidgets('offers the prompt once, after the fifth success (PRO-4)', (
    WidgetTester tester,
  ) async {
    final SuccessCounts counts = await countsAt(5);

    await pumpApp(
      tester,
      const SettingsScope(child: ProPrompt()),
      successCounts: counts,
    );

    expect(find.byKey(ProPrompt.buyButtonKey), findsOneWidget);
    expect(find.byKey(ProPrompt.dismissButtonKey), findsOneWidget);
  });

  testWidgets('dismissing hides the prompt and it stays hidden after a rebuild '
      '(PRO-4)', (WidgetTester tester) async {
    final SuccessCounts counts = await countsAt(5);
    final FakeKeyValueStore proStore = FakeKeyValueStore();

    await pumpApp(
      tester,
      SettingsScope(proStore: proStore, child: const ProPrompt()),
      successCounts: counts,
    );
    expect(find.byKey(ProPrompt.buyButtonKey), findsOneWidget);

    await tester.tap(find.byKey(ProPrompt.dismissButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
    expect(proStore.values[ProState.promptDismissedKey], '1');

    // A later success does not bring it back.
    await counts.recordSuccessfulScan();
    await tester.pumpAndSettle();
    expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
  });

  testWidgets('buying successfully removes the prompt (PRO-1, PRO-4)', (
    WidgetTester tester,
  ) async {
    final SuccessCounts counts = await countsAt(5);
    final _PurchasingBillingService billing = _PurchasingBillingService();

    await pumpApp(
      tester,
      const SettingsScope(child: ProPrompt()),
      successCounts: counts,
      services: AppServices.fakes().copyWith(billing: billing),
    );
    expect(find.byKey(ProPrompt.buyButtonKey), findsOneWidget);

    await tester.tap(find.byKey(ProPrompt.buyButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
  });

  testWidgets('a hard purchase failure says so and keeps the prompt', (
    WidgetTester tester,
  ) async {
    final SuccessCounts counts = await countsAt(5);

    await pumpApp(
      tester,
      // A Scaffold for the snackbar, as History and Settings have.
      const SettingsScope(child: Scaffold(body: ProPrompt())),
      successCounts: counts,
      // The store has no product loaded, so buy() reports "unavailable".
      services: AppServices.fakes().copyWith(billing: NoopBillingService()),
    );

    await tester.tap(find.byKey(ProPrompt.buyButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ProPrompt.buyButtonKey), findsOneWidget);
    expect(
      find.text('Could not complete the purchase. Try again.'),
      findsOneWidget,
    );
  });
}

/// A store whose purchase sheet always completes the purchase.
class _PurchasingBillingService extends NoopBillingService {
  @override
  Future<PurchaseResult> buy(String productId) async {
    calls.add('buy: $productId');
    return const PurchaseResult(outcome: PurchaseOutcome.purchased);
  }
}
