import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../helpers/database.dart';
import '../helpers/fake_stores.dart';

/// A [RecordDao] whose soft-delete and restore writes can be made to fail, as
/// a full or locked database would (DEL-2's write-lands-first rollback).
class _FailingRecordDao extends RecordDao {
  _FailingRecordDao(super.database);

  bool failSoftDelete = false;
  bool failRestore = false;

  @override
  Future<int> softDeleteAll(Iterable<String> ids, {DateTime? at}) async {
    if (failSoftDelete) {
      throw StateError('the database refused the write');
    }
    return super.softDeleteAll(ids, at: at);
  }

  @override
  Future<int> restoreAll(Iterable<String> ids, {DateTime? at}) async {
    if (failRestore) {
      throw StateError('the database refused the write');
    }
    return super.restoreAll(ids, at: at);
  }
}

void main() {
  late TestDatabase db;
  late FakeKeyValueStore store;
  late SettingsState settings;
  late HistoryState history;
  late DateTime clock;

  /// Every scanned or created record in this file is a link, so a test names
  /// only what it is about.
  Future<ScanRecord> insertScan(String payload, {DateTime? at}) {
    return db.records.insert(
      kind: RecordKind.scan,
      source: RecordSource.camera,
      symbology: Symbology.qr,
      parsedType: ParsedType.url,
      payloadText: payload,
      at: at,
    );
  }

  Future<ScanRecord> insertCreated(String payload, {DateTime? at}) {
    return db.records.insert(
      kind: RecordKind.created,
      source: RecordSource.created,
      symbology: Symbology.qr,
      parsedType: ParsedType.url,
      payloadText: payload,
      at: at,
    );
  }

  /// The ids [history] currently shows, group order then row order (HIS-1).
  List<String> shownIds() => history.groups
      .expand((HistoryGroup group) => group.records)
      .map((ScanRecord record) => record.id)
      .toList(growable: false);

  setUp(() async {
    // A UTC instant, so an explicit `at:` a test passes to the DAO is stored
    // exactly as written, with no host time zone in the way (DATE-1).
    clock = DateTime.utc(2026, 9, 17, 10, 0, 0);
    db = await openTestDatabase(now: () => clock);
    store = FakeKeyValueStore();
    settings = SettingsState(store);
    await settings.load();
    history = HistoryState(
      records: db.records,
      settings: settings,
      now: () => clock,
    );
  });

  tearDown(() {
    history.dispose();
    settings.dispose();
  });

  group('refresh (HIS-1)', () {
    test('reads nothing before it is called', () {
      expect(history.isLoaded, isFalse);
      expect(history.isEmpty, isTrue);
      expect(history.groups, isEmpty);
    });

    test('loads live records newest first (HIS-1)', () async {
      await insertScan('https://first.example');
      await insertScan('https://second.example');

      await history.refresh();

      expect(history.isLoaded, isTrue);
      expect(history.isEmpty, isFalse);
      expect(
        history.groups.single.records
            .map((ScanRecord r) => r.payloadText)
            .toList(),
        <String>['https://second.example', 'https://first.example'],
      );
    });

    test('moves a duplicate scan back to the top (HIS-5)', () async {
      final first = await insertScan('https://first.example');
      await insertScan('https://second.example');
      await db.records.recordScan(
        kind: RecordKind.scan,
        source: RecordSource.camera,
        symbology: Symbology.qr,
        parsedType: ParsedType.url,
        payloadText: 'https://first.example',
      );

      await history.refresh();

      final ids = shownIds();
      expect(ids.first, first.id);
      expect(history.groups.single.records.first.duplicateCount, 2);
    });
  });

  group('segments (HIS-1)', () {
    test('All shows both kinds; Scanned and Created each show one', () async {
      final scan = await insertScan('https://scan.example');
      final created = await insertCreated('https://created.example');
      await history.refresh();

      expect(shownIds(), containsAll(<String>[scan.id, created.id]));

      history.setSegment(HistorySegment.scanned);
      expect(shownIds(), <String>[scan.id]);

      history.setSegment(HistorySegment.created);
      expect(shownIds(), <String>[created.id]);

      history.setSegment(HistorySegment.all);
      expect(shownIds(), containsAll(<String>[scan.id, created.id]));
    });

    test('setting the segment it already has does nothing', () async {
      await insertScan('https://example.com');
      await history.refresh();
      var notified = 0;
      history.addListener(() => notified++);

      history.setSegment(HistorySegment.all);

      expect(notified, 0);
    });
  });

  group('delete and undo (DEL-2, REC-4)', () {
    test('removes the rows, sets deleted_at, and undo restores order and '
        'clears it', () async {
      final first = await insertScan('https://first.example');
      final second = await insertScan('https://second.example');
      final third = await insertScan('https://third.example');
      await history.refresh();
      expect(shownIds(), <String>[third.id, second.id, first.id]);

      final token = await history.delete(<String>[second.id]);

      expect(token, isNotNull);
      expect(shownIds(), <String>[third.id, first.id]);
      expect((await db.records.findById(second.id))?.deletedAt, isNotNull);

      final restored = await history.undo(token!);

      expect(restored, isTrue);
      expect(shownIds(), <String>[third.id, second.id, first.id]);
      expect((await db.records.findById(second.id))?.deletedAt, isNull);
    });

    test('deletes several records with one Undo (DEL-2)', () async {
      final first = await insertScan('https://first.example');
      final second = await insertScan('https://second.example');
      await history.refresh();

      final token = await history.delete(<String>[first.id, second.id]);

      expect(shownIds(), isEmpty);
      expect(token, isNotNull);

      await history.undo(token!);
      expect(shownIds(), containsAll(<String>[first.id, second.id]));
    });

    test('deleting nothing returns null and changes nothing', () async {
      await insertScan('https://example.com');
      await history.refresh();
      final before = shownIds();

      final token = await history.delete(const <String>[]);

      expect(token, isNull);
      expect(shownIds(), before);
    });

    test('undo once the offer has ended does nothing (DEL-2)', () async {
      final record = await insertScan('https://example.com');
      await history.refresh();
      final token = await history.delete(<String>[record.id]);
      // The snackbar closed.
      history.endUndo(token!);

      final restored = await history.undo(token);

      expect(restored, isFalse);
      expect(shownIds(), isEmpty);
      expect((await db.records.findById(record.id))?.deletedAt, isNotNull);
    });

    test('undo still works past 5 seconds while the snackbar is still up '
        '(DEL-2: it offers Undo, so Undo must work)', () async {
      final record = await insertScan('https://example.com');
      await history.refresh();
      final token = await history.delete(<String>[record.id]);
      // The snackbar finished appearing after the delete, or TalkBack keeps
      // it up until dismissed.
      clock = clock.add(const Duration(seconds: 7));

      expect(await history.undo(token!), isTrue);
      expect(shownIds(), <String>[record.id]);
    });

    test('a token the screen never ended stops working after the one-minute '
        'cap', () async {
      final record = await insertScan('https://example.com');
      await history.refresh();
      final token = await history.delete(<String>[record.id]);
      clock = clock.add(HistoryState.undoLimit);

      expect(await history.undo(token!), isFalse);
      expect(shownIds(), isEmpty);
    });

    test('undo just inside the window still works (DEL-2)', () async {
      final record = await insertScan('https://example.com');
      await history.refresh();
      final token = await history.delete(<String>[record.id]);
      clock = clock.add(const Duration(seconds: 4));

      final restored = await history.undo(token!);

      expect(restored, isTrue);
      expect(shownIds(), <String>[record.id]);
    });

    test('an unknown or already-used token does nothing', () async {
      final record = await insertScan('https://example.com');
      await history.refresh();
      final token = await history.delete(<String>[record.id]);

      expect(await history.undo('no-such-token'), isFalse);
      expect(await history.undo(token!), isTrue);
      expect(await history.undo(token), isFalse);
    });

    test('a failing delete rolls back: the rows stay and an error is set '
        '(DEL-2)', () async {
      final record = await insertScan('https://example.com');
      final failing = _FailingRecordDao(db.database)..failSoftDelete = true;
      final localHistory = HistoryState(
        records: failing,
        settings: settings,
        now: () => clock,
      );
      await localHistory.refresh();

      final token = await localHistory.delete(<String>[record.id]);

      expect(token, isNull);
      expect(localHistory.error, HistoryError.deleteFailed);
      expect(localHistory.groups.single.records.single.id, record.id);
      expect((await db.records.findById(record.id))?.deletedAt, isNull);
      localHistory.dispose();
    });

    test('a failing undo rolls back: the row stays out and an error is set '
        '(DEL-2)', () async {
      final record = await insertScan('https://example.com');
      final failing = _FailingRecordDao(db.database);
      final localHistory = HistoryState(
        records: failing,
        settings: settings,
        now: () => clock,
      );
      await localHistory.refresh();
      final token = await localHistory.delete(<String>[record.id]);
      failing.failRestore = true;

      final restored = await localHistory.undo(token!);

      expect(restored, isFalse);
      expect(localHistory.error, HistoryError.undoFailed);
      expect(localHistory.groups, isEmpty);
      expect((await db.records.findById(record.id))?.deletedAt, isNotNull);
      localHistory.dispose();
    });

    test('a failed Undo can be tried again while its 5 seconds last '
        '(DEL-2, CLAUDE.md rollback)', () async {
      final record = await insertScan('https://example.com/retry');
      final failing = _FailingRecordDao(db.database);
      final localHistory = HistoryState(
        records: failing,
        settings: settings,
        now: () => clock,
      );
      await localHistory.refresh();
      final token = await localHistory.delete(<String>[record.id]);
      failing.failRestore = true;
      expect(await localHistory.undo(token!), isFalse);

      failing.failRestore = false;
      clock = clock.add(const Duration(seconds: 2));
      final restored = await localHistory.undo(token);

      expect(restored, isTrue);
      expect(localHistory.groups.single.records.single.id, record.id);
      expect((await db.records.findById(record.id))?.deletedAt, isNull);
      // Used once: a second Undo with the same token does nothing.
      expect(await localHistory.undo(token), isFalse);
      localHistory.dispose();
    });

    test('clearError clears it once and does nothing again', () async {
      final record = await insertScan('https://example.com');
      final failing = _FailingRecordDao(db.database)..failSoftDelete = true;
      final localHistory = HistoryState(
        records: failing,
        settings: settings,
        now: () => clock,
      );
      await localHistory.refresh();
      await localHistory.delete(<String>[record.id]);
      expect(localHistory.error, isNotNull);

      var notified = 0;
      localHistory.addListener(() => notified++);
      localHistory.clearError();

      expect(localHistory.error, isNull);
      expect(notified, 1);

      localHistory.clearError();

      expect(notified, 1);
      localHistory.dispose();
    });
  });

  group('saveHistory (HIS-8, HIS-11)', () {
    test('reads SettingsState.saveHistory', () async {
      expect(history.saveHistory, isTrue);

      await settings.setSaveHistory(enabled: false);

      expect(history.saveHistory, isFalse);
    });

    test('notifies History listeners when it changes', () async {
      var notified = 0;
      history.addListener(() => notified++);

      await settings.setSaveHistory(enabled: false);

      expect(notified, 1);
    });
  });

  group('HistoryHeader.of (HIS-3, DATE-2)', () {
    test('today is the same local calendar day, whatever the time of '
        'day', () {
      final now = DateTime(2026, 9, 19, 8, 0);

      expect(
        HistoryHeader.of(DateTime(2026, 9, 19, 23, 59), now).kind,
        HistoryHeaderKind.today,
      );
      expect(
        HistoryHeader.of(DateTime(2026, 9, 19), now).kind,
        HistoryHeaderKind.today,
      );
    });

    test('yesterday is exactly one local calendar day back, even minutes '
        'apart across midnight', () {
      final now = DateTime(2026, 9, 19, 0, 5);

      final header = HistoryHeader.of(DateTime(2026, 9, 18, 23, 59), now);

      expect(header.kind, HistoryHeaderKind.yesterday);
      expect(header.day, DateTime.utc(2026, 9, 18));
    });

    test('2 to 6 days back is a weekday; 7 or more is a date (week '
        'boundary)', () {
      final now = DateTime(2026, 9, 19);

      expect(
        HistoryHeader.of(DateTime(2026, 9, 17), now).kind,
        HistoryHeaderKind.weekday,
      );
      expect(
        HistoryHeader.of(DateTime(2026, 9, 13), now).kind,
        HistoryHeaderKind.weekday,
      );
      expect(
        HistoryHeader.of(DateTime(2026, 9, 12), now).kind,
        HistoryHeaderKind.date,
      );
    });

    test('a 23-hour local day never turns yesterday into today (DST '
        'spring-forward)', () {
      // Only 23 real hours apart, so a naive "under 24h = same day" check
      // would call this today; the calendar days are different regardless.
      final now = DateTime(2026, 3, 9, 0, 30);

      final header = HistoryHeader.of(DateTime(2026, 3, 8, 1, 30), now);

      expect(header.kind, HistoryHeaderKind.yesterday);
    });

    test('a 25-hour local day is still exactly one calendar day back (DST '
        'fall-back)', () {
      final now = DateTime(2026, 11, 2, 1, 30);

      final header = HistoryHeader.of(DateTime(2026, 11, 1, 0, 30), now);

      expect(header.kind, HistoryHeaderKind.yesterday);
    });
  });

  group('HistoryState.trashCutoffFor (DEL-4)', () {
    test('is local midnight 30 calendar days before now, not now minus '
        '30*24 hours', () {
      final now = DateTime(2026, 4, 16, 13, 45, 30);

      final cutoff = HistoryState.trashCutoffFor(now);

      expect(cutoff, DateTime(2026, 3, 17).toUtc());
      expect(cutoff, isNot(now.toUtc().subtract(const Duration(days: 30))));
    });

    test('is unaffected by the time of day now carries', () {
      final morning = HistoryState.trashCutoffFor(DateTime(2026, 6, 10, 0, 1));
      final night = HistoryState.trashCutoffFor(DateTime(2026, 6, 10, 23, 59));

      expect(morning, night);
    });
  });

  group('purgeExpiredTrash (DEL-4)', () {
    test('purges only records deleted more than 30 local days ago, keeping '
        'one deleted exactly 30 days ago', () async {
      final now = DateTime(2026, 4, 16, 9, 0, 0);
      clock = now;
      final cutoff = HistoryState.trashCutoffFor(now);

      final old = await insertScan('https://old.example');
      await db.records.softDelete(
        old.id,
        at: cutoff.subtract(const Duration(seconds: 1)),
      );
      final boundary = await insertScan('https://boundary.example');
      await db.records.softDelete(boundary.id, at: cutoff);
      final recent = await insertScan('https://recent.example');
      await db.records.softDelete(
        recent.id,
        at: cutoff.add(const Duration(days: 5)),
      );
      final live = await insertScan('https://live.example');

      final purged = await history.purgeExpiredTrash();

      expect(purged, 1);
      expect(await db.records.findById(old.id), isNull);
      expect(await db.records.findById(boundary.id), isNotNull);
      expect(await db.records.findById(recent.id), isNotNull);
      expect(await db.records.findById(live.id), isNotNull);
    });

    test('never changes the visible groups: a trashed record is never live '
        '(DEL-1)', () async {
      final record = await insertScan('https://example.com');
      await db.records.softDelete(
        record.id,
        at: HistoryState.trashCutoffFor(clock)
            .subtract(const Duration(days: 1)),
      );
      await history.refresh();
      expect(history.groups, isEmpty);

      await history.purgeExpiredTrash();

      expect(history.groups, isEmpty);
    });

    test('a purge failure is swallowed and returns 0', () async {
      final failing = _FailingRecordDao(db.database);
      final localHistory = HistoryState(
        records: failing,
        settings: settings,
        now: () => clock,
      );
      // purgeTrashDeletedBefore isn't overridden to fail directly, but a
      // closed database behind it is exactly the "full or locked database"
      // this guards against; simulate it by closing the connection.
      await db.database.close();

      final purged = await localHistory.purgeExpiredTrash();

      expect(purged, 0);
      localHistory.dispose();
    });
  });
}
