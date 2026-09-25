import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/state/success_counts.dart';

/// An in-memory [KeyValueStore] that can be told to fail a write.
///
/// It decodes the way `SqfliteKeyValueStore` does — ints as decimal text, bools
/// as `'1'` or `'0'`, anything else as `null` — and increments by reading the
/// stored value back, so a count that changed underneath is what the caller
/// sees.
class _FakeKeyValueStore implements KeyValueStore {
  _FakeKeyValueStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  /// The rows the store holds, as the database would.
  final Map<String, String> values;

  /// Keys whose writes throw, standing in for a full or locked database.
  final Set<String> failingKeys = <String>{};

  /// Every write that happened, as `'set counts.scans=1'`.
  final List<String> writes = <String>[];

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    _failIfAsked(key);
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
    _failIfAsked(key);
    final next = (int.tryParse(values[key] ?? '') ?? 0) + by;
    await setString(key, '$next');
    return next;
  }

  @override
  Future<void> remove(String key) async {
    _failIfAsked(key);
    writes.add('remove $key');
    values.remove(key);
  }

  @override
  Future<Map<String, String>> all() async => Map<String, String>.of(values);

  void _failIfAsked(String key) {
    if (failingKeys.contains(key)) {
      throw StateError('the write to $key failed');
    }
  }
}

void main() {
  late _FakeKeyValueStore store;
  late SuccessCounts counts;
  late int notifications;

  /// Loads [counts] and starts counting notifications after, so a test counts
  /// only the successes it records itself.
  Future<void> loadAndListen() async {
    await counts.load();
    counts.addListener(() => notifications++);
  }

  setUp(() {
    store = _FakeKeyValueStore();
    counts = SuccessCounts(store);
    notifications = 0;
  });

  tearDown(() => counts.dispose());

  group('defaults, with nothing stored', () {
    test('both counts are zero (DATA-8), and the Pro prompt threshold is not '
        'reached (PRO-4)', () async {
      await counts.load();

      expect(counts.successfulScans, 0);
      expect(counts.successfulCreates, 0);
      expect(counts.totalSuccesses, 0);
      expect(counts.isLoaded, isTrue);
      expect(counts.hasReachedProPromptThreshold, isFalse);
    });

    test('the review prompt is unused (SET-9)', () async {
      await counts.load();

      expect(counts.reviewPromptUsed, isFalse);
    });

    test('loading writes nothing', () async {
      await counts.load();

      expect(store.writes, isEmpty);
      expect(store.values, isEmpty);
    });
  });

  group('load', () {
    test(
      'reads the stored counts and the review flag (DATA-8, SET-9)',
      () async {
        store = _FakeKeyValueStore({
          SuccessCounts.scansKey: '12',
          SuccessCounts.createsKey: '3',
          SuccessCounts.reviewPromptUsedKey: '1',
        });
        counts = SuccessCounts(store);

        await counts.load();

        expect(counts.successfulScans, 12);
        expect(counts.successfulCreates, 3);
        expect(counts.totalSuccesses, 15);
        expect(counts.reviewPromptUsed, isTrue);
      },
    );

    test('a count this build cannot read reads as zero', () async {
      store = _FakeKeyValueStore({
        SuccessCounts.scansKey: 'lots',
        SuccessCounts.reviewPromptUsedKey: 'maybe',
      });
      counts = SuccessCounts(store);

      await counts.load();

      expect(counts.successfulScans, 0);
      expect(counts.reviewPromptUsed, isFalse);
    });

    test('notifies once', () async {
      counts.addListener(() => notifications++);

      await counts.load();

      expect(notifications, 1);
    });
  });

  group('counting successes', () {
    test('a successful scan is counted and notified once (DATA-8)', () async {
      await loadAndListen();

      expect(await counts.recordSuccessfulScan(), 1);

      expect(counts.successfulScans, 1);
      expect(counts.successfulCreates, 0);
      expect(store.values[SuccessCounts.scansKey], '1');
      expect(notifications, 1);
    });

    test(
      'a successful create is counted separately (DATA-8, GEN-13)',
      () async {
        await loadAndListen();

        expect(await counts.recordSuccessfulCreate(), 1);

        expect(counts.successfulCreates, 1);
        expect(counts.successfulScans, 0);
        expect(store.values[SuccessCounts.createsKey], '1');
        expect(store.values.containsKey(SuccessCounts.scansKey), isFalse);
      },
    );

    test('the Pro prompt waits for the fifth success (PRO-4)', () async {
      await loadAndListen();

      for (var i = 0; i < 4; i++) {
        await counts.recordSuccessfulScan();
      }
      expect(counts.hasReachedProPromptThreshold, isFalse);
      await counts.recordSuccessfulCreate();

      expect(counts.totalSuccesses, 5);
      expect(counts.hasReachedProPromptThreshold, isTrue);
    });

    test('counts survive a reload (DATA-8)', () async {
      await counts.load();
      await counts.recordSuccessfulScan();
      await counts.recordSuccessfulScan();
      await counts.recordSuccessfulCreate();

      final reloaded = SuccessCounts(store);
      await reloaded.load();

      expect(reloaded.successfulScans, 2);
      expect(reloaded.successfulCreates, 1);
      expect(reloaded.totalSuccesses, 3);
      reloaded.dispose();
    });

    test('counting goes through the store, not the field', () async {
      await loadAndListen();
      // Another writer got there first, the way two increments overlapping in
      // the real store do.
      store.values[SuccessCounts.scansKey] = '7';

      expect(await counts.recordSuccessfulScan(), 8);

      expect(counts.successfulScans, 8);
      expect(store.values[SuccessCounts.scansKey], '8');
    });

    test('concurrent successes all count (DATA-8)', () async {
      await loadAndListen();

      await Future.wait([
        counts.recordSuccessfulScan(),
        counts.recordSuccessfulScan(),
        counts.recordSuccessfulScan(),
      ]);

      expect(store.values[SuccessCounts.scansKey], '3');
      expect(counts.successfulScans, 3);
    });
  });

  group('the review prompt (SET-9)', () {
    test('is marked used, stored and notified once', () async {
      await loadAndListen();

      await counts.markReviewPromptUsed();

      expect(counts.reviewPromptUsed, isTrue);
      expect(store.values[SuccessCounts.reviewPromptUsedKey], '1');
      expect(notifications, 1);
    });

    test('is marked at most once per install', () async {
      await loadAndListen();

      await counts.markReviewPromptUsed();
      await counts.markReviewPromptUsed();

      expect(store.writes, ['set ${SuccessCounts.reviewPromptUsedKey}=1']);
      expect(notifications, 1);
    });

    test('stays used after a reload', () async {
      await counts.load();
      await counts.markReviewPromptUsed();

      final reloaded = SuccessCounts(store);
      await reloaded.load();

      expect(reloaded.reviewPromptUsed, isTrue);
      reloaded.dispose();
    });
  });

  group('a failed write', () {
    test('leaves the count and the listeners untouched (DATA-8)', () async {
      await loadAndListen();
      store.failingKeys.add(SuccessCounts.scansKey);

      await expectLater(counts.recordSuccessfulScan(), throwsStateError);

      expect(counts.successfulScans, 0);
      expect(store.values, isEmpty);
      expect(notifications, 0);
    });

    test('leaves the review prompt unused (SET-9)', () async {
      await loadAndListen();
      store.failingKeys.add(SuccessCounts.reviewPromptUsedKey);

      await expectLater(counts.markReviewPromptUsed(), throwsStateError);

      expect(counts.reviewPromptUsed, isFalse);
      expect(store.values, isEmpty);
      expect(notifications, 0);
    });

    test('a later success still counts', () async {
      await loadAndListen();
      store.failingKeys.add(SuccessCounts.scansKey);

      await expectLater(counts.recordSuccessfulScan(), throwsStateError);
      store.failingKeys.clear();

      expect(await counts.recordSuccessfulScan(), 1);
      expect(counts.successfulScans, 1);
      expect(notifications, 1);
    });
  });
}
