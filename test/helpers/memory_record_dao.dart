import 'dart:typed_data';

import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fake_stores.dart';

/// A [RecordDao] that keeps its records in a list, for widget tests.
///
/// The real DAO talks to SQLite on another isolate, and under a widget test's
/// fake clock those writes never complete. This one answers at once, so a
/// screen test can insert, record, list, delete and restore inside
/// `testWidgets`. It follows the real DAO's rules for what it implements: a
/// live duplicate (same kind, format and raw payload) is bumped instead of
/// inserted (DATA-4), live records come newest first by `last_seen_at` then
/// `seq` (HIS-1), soft delete and restore
/// setting and clearing `deleted_at` (DEL-1, REC-4), and the Trash purge
/// (DEL-4). The database it hands to [RecordDao] is never opened.
class MemoryRecordDao extends RecordDao {
  MemoryRecordDao({DateTime Function()? now})
    : _clock = now ?? (() => fixtureTime),
      super(
        AppDatabase(
          directory: 'never-opened-in-a-widget-test',
          runner: MigrationRunner(migrationSteps),
          databaseFactory: databaseFactoryFfi,
        ),
      );

  final DateTime Function() _clock;
  final List<ScanRecord> records = <ScanRecord>[];
  int _seq = 0;

  @override
  Future<ScanRecord> insert({
    required RecordKind kind,
    required RecordSource source,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    Uint8List? payloadBytes,
    List<String> sensitiveFields = const <String>[],
    String? label,
    bool favourite = false,
    String? batchSessionId,
    String? contentJson,
    String? styleJson,
    DateTime? at,
  }) async {
    final DateTime when = (at ?? _clock()).toUtc();
    _seq++;
    final ScanRecord record = aScanRecord(
      id: 'memory-$_seq',
      seq: _seq,
      kind: kind,
      source: source,
      symbology: symbology,
      parsedType: parsedType,
      payloadText: payloadText,
      payloadBytes: payloadBytes,
      sensitiveFields: sensitiveFields,
      label: label,
      favourite: favourite,
      batchSessionId: batchSessionId,
      contentJson: contentJson,
      styleJson: styleJson,
      createdAt: when,
      updatedAt: when,
      lastSeenAt: when,
    );
    records.add(record);
    return record;
  }

  /// Adds [record] as it stands, for a test that builds its own fixture.
  void put(ScanRecord record) => records.add(record);

  @override
  Future<RecordWrite> recordScan({
    required RecordKind kind,
    required RecordSource source,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    Uint8List? payloadBytes,
    List<String> sensitiveFields = const <String>[],
    String? batchSessionId,
    String? contentJson,
    String? styleJson,
    DateTime? at,
  }) async {
    final DateTime when = (at ?? _clock()).toUtc();
    final String key = ScanRecord.duplicateKeyOf(
      kind: kind,
      symbology: symbology,
      payloadText: payloadText,
      payloadBytes: payloadBytes,
      batchSessionId: batchSessionId,
    );
    for (var i = 0; i < records.length; i++) {
      final ScanRecord candidate = records[i];
      if (candidate.deletedAt == null && candidate.duplicateKey == key) {
        _seq++;
        final ScanRecord bumped = candidate.copyWith(
          seq: _seq,
          duplicateCount: candidate.duplicateCount + 1,
          lastSeenAt: when,
          updatedAt: when,
        );
        records[i] = bumped;
        return RecordWrite(record: bumped, isDuplicate: true);
      }
    }
    _seq++;
    final ScanRecord inserted = aScanRecord(
      id: 'memory-$_seq',
      seq: _seq,
      kind: kind,
      source: source,
      symbology: symbology,
      parsedType: parsedType,
      payloadText: payloadText,
      payloadBytes: payloadBytes,
      sensitiveFields: sensitiveFields,
      batchSessionId: batchSessionId,
      contentJson: contentJson,
      styleJson: styleJson,
      createdAt: when,
      updatedAt: when,
      lastSeenAt: when,
    );
    records.add(inserted);
    return RecordWrite(record: inserted, isDuplicate: false);
  }

  @override
  Future<List<ScanRecord>> liveRecords({int? limit, int? offset}) async {
    final List<ScanRecord> live =
        records.where((ScanRecord r) => r.deletedAt == null).toList()
          ..sort((ScanRecord a, ScanRecord b) {
            final DateTime seenA = a.lastSeenAt ?? a.createdAt;
            final DateTime seenB = b.lastSeenAt ?? b.createdAt;
            final int bySeen = seenB.compareTo(seenA);
            return bySeen != 0 ? bySeen : b.seq.compareTo(a.seq);
          });
    final Iterable<ScanRecord> skipped = live.skip(offset ?? 0);
    return (limit == null ? skipped : skipped.take(limit)).toList();
  }

  @override
  Future<int> softDeleteAll(Iterable<String> ids, {DateTime? at}) async =>
      _setDeletedAt(ids, (at ?? _clock()).toUtc());

  @override
  Future<int> restoreAll(Iterable<String> ids, {DateTime? at}) async =>
      _setDeletedAt(ids, null);

  @override
  Future<int> purgeTrashDeletedBefore(DateTime cutoff) async {
    final int before = records.length;
    records.removeWhere(
      (ScanRecord r) => r.deletedAt != null && r.deletedAt!.isBefore(cutoff),
    );
    return before - records.length;
  }

  int _setDeletedAt(Iterable<String> ids, DateTime? deletedAt) {
    final Set<String> wanted = ids.toSet();
    var changed = 0;
    for (var i = 0; i < records.length; i++) {
      if (wanted.contains(records[i].id)) {
        records[i] = records[i].copyWith(deletedAt: deletedAt);
        changed++;
      }
    }
    return changed;
  }
}
