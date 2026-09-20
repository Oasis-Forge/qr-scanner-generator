import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/screens/history/history_date_header.dart';
import 'package:qrscanner/screens/history/history_empty_state.dart';
import 'package:qrscanner/screens/history_screen.dart';
import 'package:qrscanner/screens/pro/pro_prompt.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../helpers/fake_stores.dart';
import '../helpers/memory_record_dao.dart';
import '../helpers/test_app.dart';

/// A [RecordDao] whose soft-delete can be made to fail, so a test can drive
/// the write-lands-first rollback (`CLAUDE.md`) at the screen level. Mirrors
/// `test/state/history_state_test.dart`'s own fake.
class _FailingRecordDao extends MemoryRecordDao {
  _FailingRecordDao({super.now});

  bool failSoftDelete = false;

  @override
  Future<int> softDeleteAll(Iterable<String> ids, {DateTime? at}) async {
    if (failSoftDelete) {
      throw StateError('the database refused the write');
    }
    return super.softDeleteAll(ids, at: at);
  }
}

void main() {
  late MemoryRecordDao dao;
  late FakeKeyValueStore store;
  late SettingsState settings;
  late HistoryState history;
  late DateTime clock;
  late List<String> switchedTo;

  Future<ScanRecord> insertScan(String payload, {String? label, DateTime? at}) {
    return dao.insert(
      kind: RecordKind.scan,
      source: RecordSource.camera,
      symbology: Symbology.qr,
      parsedType: ParsedType.url,
      payloadText: payload,
      label: label,
      at: at,
    );
  }

  Future<ScanRecord> insertCreated(String payload, {DateTime? at}) {
    return dao.insert(
      kind: RecordKind.created,
      source: RecordSource.created,
      symbology: Symbology.qr,
      parsedType: ParsedType.url,
      payloadText: payload,
      at: at,
    );
  }

  Widget wrap({HistoryState? withHistory}) {
    return ChangeNotifierProvider<HistoryState>.value(
      value: withHistory ?? history,
      child: HistoryScreen(
        onSwitchToScan: () => switchedTo.add('scan'),
        onSwitchToCreate: () => switchedTo.add('create'),
        onSwitchToSettings: () => switchedTo.add('settings'),
      ),
    );
  }

  setUp(() async {
    // A UTC instant, so a header computed against it stays "Today" whatever
    // day the tests actually run on (DATE-2).
    clock = DateTime.utc(2026, 9, 17, 10, 0, 0);
    dao = MemoryRecordDao(now: () => clock);
    store = FakeKeyValueStore();
    settings = SettingsState(store);
    await settings.load();
    history = HistoryState(records: dao, settings: settings, now: () => clock);
    switchedTo = <String>[];
  });

  tearDown(() {
    history.dispose();
    settings.dispose();
  });

  group('HIS-1: All / Scanned / Created', () {
    testWidgets('filter the rows without leaving the segmented control', (
      WidgetTester tester,
    ) async {
      await insertScan('https://example.com/scan-1', at: clock);
      await insertCreated('https://example.com/created-1', at: clock);
      await pumpApp(tester, wrap(), settings: settings);

      expect(find.text('https://example.com/scan-1'), findsOneWidget);
      expect(find.text('https://example.com/created-1'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(HistoryScreen.segmentedControlKey),
          matching: find.text('Scanned'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('https://example.com/scan-1'), findsOneWidget);
      expect(find.text('https://example.com/created-1'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byKey(HistoryScreen.segmentedControlKey),
          matching: find.text('Created'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('https://example.com/scan-1'), findsNothing);
      expect(find.text('https://example.com/created-1'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(HistoryScreen.segmentedControlKey),
          matching: find.text('All'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('https://example.com/scan-1'), findsOneWidget);
      expect(find.text('https://example.com/created-1'), findsOneWidget);
    });
  });

  group('HIS-3, HIS-4: headers and row content', () {
    testWidgets('groups rows under date headers, "Today" included', (
      WidgetTester tester,
    ) async {
      await insertScan('https://example.com/today', at: clock);
      await insertScan(
        'https://example.com/old',
        at: clock.subtract(const Duration(days: 10)),
      );

      await pumpApp(tester, wrap(), settings: settings);

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.byType(HistoryDateHeader), findsNWidgets(2));
      expect(find.text('https://example.com/today'), findsOneWidget);
      expect(find.text('https://example.com/old'), findsOneWidget);
    });

    testWidgets(
      'shows the label in bold, the content on a second line, and the '
      'local time (DATE-1, LANG-3)',
      (WidgetTester tester) async {
        await insertScan(
          'https://example.com/time-check',
          label: 'My link',
          at: clock,
        );
        await pumpApp(tester, wrap(), settings: settings);

        expect(find.text('My link'), findsOneWidget);
        expect(find.text('https://example.com/time-check'), findsOneWidget);
        final String expectedTime = intl.DateFormat.jm('en')
            .format(clock.toLocal());
        expect(find.text(expectedTime), findsOneWidget);
      },
    );

    testWidgets('shows "×N" once a code has been scanned again (HIS-5)', (
      WidgetTester tester,
    ) async {
      // Seen twice: the DAO's DATA-4 bump is covered by record_dao_test; here
      // only what the row shows for it matters.
      dao.put(
        aScanRecord(
          id: 'dup',
          payloadText: 'https://example.com/dup',
          duplicateCount: 2,
          createdAt: clock,
          lastSeenAt: clock.add(const Duration(minutes: 1)),
        ),
      );

      await pumpApp(tester, wrap(), settings: settings);

      expect(find.textContaining('×2'), findsOneWidget);
    });

    testWidgets('masks a Wi-Fi password in the row (HIS-7, DATA-5)', (
      WidgetTester tester,
    ) async {
      await dao.insert(
        kind: RecordKind.scan,
        source: RecordSource.camera,
        symbology: Symbology.qr,
        parsedType: ParsedType.wifi,
        payloadText: 'WIFI:T:WPA;S:HomeNet;P:letmein;;',
        sensitiveFields: const <String>[SensitiveFieldKeys.wifiPassword],
        at: clock,
      );

      await pumpApp(tester, wrap(), settings: settings);

      expect(find.textContaining('letmein'), findsNothing);
      expect(find.textContaining('••••••'), findsOneWidget);
      expect(find.textContaining('HomeNet'), findsOneWidget);
    });
  });

  group('RES-3: reopening a row', () {
    testWidgets('opens ResultScreen with isReopened: true', (
      WidgetTester tester,
    ) async {
      final ScanRecord record = await insertScan(
        'https://example.com/reopen',
        at: clock,
      );
      await pumpApp(tester, wrap(), settings: settings);

      await tester.tap(find.text('https://example.com/reopen'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      final ResultScreen result = tester.widget<ResultScreen>(
        find.byType(ResultScreen),
      );
      expect(result.isReopened, isTrue);
      expect(result.outcome.record.id, record.id);
      expect(result.outcome.record.payloadText, 'https://example.com/reopen');
      expect(result.outcome.isSaved, isTrue);
    });
  });

  group('DEL-2: swipe to delete, with Undo', () {
    testWidgets(
      'swiping a row toward the start edge deletes it, and Undo restores it',
      (WidgetTester tester) async {
        final ScanRecord record = await insertScan(
          'https://example.com/swipe',
          at: clock,
        );
        await pumpApp(tester, wrap(), settings: settings);
        expect(find.text('https://example.com/swipe'), findsOneWidget);

        await tester.drag(
          find.byKey(HistoryScreen.rowKey(record.id)),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(find.text('https://example.com/swipe'), findsNothing);
        expect(find.text('1 item deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        expect(find.text('https://example.com/swipe'), findsOneWidget);
      },
    );

    testWidgets('a failed delete leaves the row shown and reports the error '
        '(CLAUDE.md rollback)', (WidgetTester tester) async {
      final _FailingRecordDao failingDao = _FailingRecordDao(now: () => clock)
        ..failSoftDelete = true;
      final HistoryState failingHistory = HistoryState(
        records: failingDao,
        settings: settings,
        now: () => clock,
      );
      // Into the failing DAO itself: it keeps its own records.
      final ScanRecord record = await failingDao.insert(
        kind: RecordKind.scan,
        source: RecordSource.camera,
        symbology: Symbology.qr,
        parsedType: ParsedType.url,
        payloadText: 'https://example.com/fails',
        at: clock,
      );

      await pumpApp(
        tester,
        wrap(withHistory: failingHistory),
        settings: settings,
      );

      await tester.drag(
        find.byKey(HistoryScreen.rowKey(record.id)),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('https://example.com/fails'), findsOneWidget);
      expect(find.text('Could not delete. Try again.'), findsOneWidget);

      failingHistory.dispose();
    });
  });

  group('DEL-2: multi-select delete', () {
    testWidgets(
      'long-press selects rows, the app bar shows a count, and deleting '
      'offers Undo for all of them',
      (WidgetTester tester) async {
        final ScanRecord a = await insertScan(
          'https://example.com/multi-a',
          at: clock,
        );
        final ScanRecord b = await insertScan(
          'https://example.com/multi-b',
          at: clock.add(const Duration(minutes: 1)),
        );
        await pumpApp(tester, wrap(), settings: settings);

        await tester.longPress(find.byKey(HistoryScreen.rowKey(a.id)));
        await tester.pumpAndSettle();
        expect(find.text('1 selected'), findsOneWidget);

        await tester.tap(find.byKey(HistoryScreen.rowKey(b.id)));
        await tester.pumpAndSettle();
        expect(find.text('2 selected'), findsOneWidget);

        await tester.tap(find.byKey(HistoryScreen.deleteSelectedKey));
        await tester.pumpAndSettle();

        expect(find.text('https://example.com/multi-a'), findsNothing);
        expect(find.text('https://example.com/multi-b'), findsNothing);
        expect(find.text('2 items deleted'), findsOneWidget);

        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        expect(find.text('https://example.com/multi-a'), findsOneWidget);
        expect(find.text('https://example.com/multi-b'), findsOneWidget);
      },
    );

    testWidgets('Cancel leaves selection mode without deleting anything', (
      WidgetTester tester,
    ) async {
      final ScanRecord a = await insertScan(
        'https://example.com/keep',
        at: clock,
      );
      await pumpApp(tester, wrap(), settings: settings);

      await tester.longPress(find.byKey(HistoryScreen.rowKey(a.id)));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.byKey(HistoryScreen.cancelSelectionKey));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsNothing);
      expect(find.text('https://example.com/keep'), findsOneWidget);
    });
  });

  group('HIS-11: the empty state', () {
    testWidgets('shows one line and two buttons that switch tabs through the '
        'callbacks', (WidgetTester tester) async {
      await pumpApp(tester, wrap(), settings: settings);

      expect(
        find.text('Codes you scan or create will show up here.'),
        findsOneWidget,
      );
      expect(find.byKey(HistoryEmptyState.scanButtonKey), findsOneWidget);
      expect(find.byKey(HistoryEmptyState.createButtonKey), findsOneWidget);
      expect(find.byKey(HistoryEmptyState.settingsButtonKey), findsNothing);

      await tester.tap(find.byKey(HistoryEmptyState.scanButtonKey));
      expect(switchedTo, const <String>['scan']);

      await tester.tap(find.byKey(HistoryEmptyState.createButtonKey));
      expect(switchedTo, const <String>['scan', 'create']);
    });

    testWidgets(
      'shows the save-history-off line and its Settings button only while '
      'Save history is off (HIS-8)',
      (WidgetTester tester) async {
        await pumpApp(tester, wrap(), settings: settings);
        expect(find.text("New scans aren't being saved."), findsNothing);

        await settings.setSaveHistory(enabled: false);
        await tester.pumpAndSettle();

        expect(find.text("New scans aren't being saved."), findsOneWidget);
        await tester.tap(find.byKey(HistoryEmptyState.settingsButtonKey));
        expect(switchedTo, const <String>['settings']);
      },
    );
  });

  group('LANG-5: the swipe direction mirrors in Arabic', () {
    testWidgets(
      'a leftward drag does nothing, and a rightward drag (toward the '
      'start edge in Arabic) deletes the row',
      (WidgetTester tester) async {
        final ScanRecord record = await insertScan(
          'https://example.com/rtl-swipe',
          at: clock,
        );
        await pumpApp(
          tester,
          wrap(),
          settings: settings,
          locale: const Locale('ar'),
        );

        await tester.drag(
          find.byKey(HistoryScreen.rowKey(record.id)),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('https://example.com/rtl-swipe'), findsOneWidget);

        await tester.drag(
          find.byKey(HistoryScreen.rowKey(record.id)),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('https://example.com/rtl-swipe'), findsNothing);
      },
    );
  });

  group('ADS-1, PRO-4: the banner and the Pro prompt', () {
    Future<SuccessCounts> countsAt(int successes) async {
      final SuccessCounts counts = SuccessCounts(FakeKeyValueStore());
      await counts.load();
      for (var i = 0; i < successes; i++) {
        await counts.recordSuccessfulScan();
      }
      addTearDown(counts.dispose);
      return counts;
    }

    AppServices adsAllowed(NoopAdsService ads) => AppServices.fakes().copyWith(
      ads: ads,
      consent: NoopConsentService(seededStatus: ConsentStatus.notNeeded),
    );

    testWidgets('a banner below the list, outside it, once the first success '
        'has happened (ADS-1, ADS-3)', (WidgetTester tester) async {
      await insertScan('https://example.com/banner', at: clock);
      final NoopAdsService ads = NoopAdsService();
      await pumpApp(
        tester,
        wrap(),
        settings: settings,
        services: adsAllowed(ads),
        successCounts: await countsAt(1),
      );

      expect(ads.calls.last, startsWith('loadBanner: history'));
      final Finder divider = find.byType(Divider);
      expect(divider, findsOneWidget);
      expect(
        find.ancestor(of: divider, matching: find.byType(ListView)),
        findsNothing,
      );
      expect(
        tester.getTopLeft(divider).dy,
        greaterThan(tester.getBottomLeft(find.byType(ListView)).dy - 1),
      );
    });

    testWidgets('no banner and no ad request before the first success '
        '(ADS-6)', (WidgetTester tester) async {
      await insertScan('https://example.com/no-banner', at: clock);
      final NoopAdsService ads = NoopAdsService();
      await pumpApp(
        tester,
        wrap(),
        settings: settings,
        services: adsAllowed(ads),
        successCounts: await countsAt(0),
      );

      expect(find.byType(Divider), findsNothing);
      expect(ads.calls, isEmpty);
    });

    testWidgets('the Pro prompt sits above the list after the 5th success, '
        'and not while rows are selected (PRO-4)', (WidgetTester tester) async {
      final ScanRecord record = await insertScan(
        'https://example.com/pro',
        at: clock,
      );
      await pumpApp(
        tester,
        wrap(),
        settings: settings,
        successCounts: await countsAt(5),
      );

      expect(find.byKey(ProPrompt.buyButtonKey), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(ProPrompt.buyButtonKey)).dy,
        lessThan(
          tester.getTopLeft(find.byKey(HistoryScreen.segmentedControlKey)).dy,
        ),
      );

      await tester.longPress(find.byKey(HistoryScreen.rowKey(record.id)));
      await tester.pumpAndSettle();
      expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
    });

    testWidgets('no Pro prompt before the 5th success (PRO-4)', (
      WidgetTester tester,
    ) async {
      await insertScan('https://example.com/no-pro', at: clock);
      await pumpApp(
        tester,
        wrap(),
        settings: settings,
        successCounts: await countsAt(4),
      );

      expect(find.byKey(ProPrompt.buyButtonKey), findsNothing);
    });
  });
}
