import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/db/app_database.dart';
import '../models/record_enums.dart';
import '../models/scan_record.dart';
import '../models/staged_code.dart';

/// What a write to `records` did: the stored record, and whether it merged into
/// a code that was already there (DATA-4).
class RecordWrite {
  const RecordWrite({required this.record, required this.isDuplicate});

  /// The record as it now stands in the database.
  final ScanRecord record;

  /// True when a live duplicate was bumped instead of a record inserted, which
  /// is what History shows as "×N" on an existing row (HIS-4, HIS-5).
  final bool isDuplicate;
}

/// Reads and writes the `records` and `batch_staging` tables.
///
/// Holds no state of its own: every read goes to the database, so two callers
/// never disagree about what is stored. Every write runs in one transaction, so
/// a failed write leaves nothing behind and the sequence number a record gets
/// is the one no other write is using (DATE-1).
///
/// The DAO only ever writes the columns REC-3 allows to change — `favourite`,
/// `label`, `deleted_at`, `last_seen_at`, `duplicate_count` and `updated_at` —
/// so a scanned record's content stays exactly as it was decoded, including an
/// enum ID a newer version of the app wrote. It also refreshes `seq` when it
/// bumps a duplicate; `seq` is not content but the order two writes in the same
/// second are told apart by (DATE-1).
class RecordDao {
  /// [newId] and [now] are here for tests; the app uses UUID v4 (REC-2) and the
  /// device clock.
  RecordDao(
    AppDatabase database, {
    String Function()? newId,
    DateTime Function() now = DateTime.now,
  }) : _database = database,
       _newId = newId ?? _uuid.v4,
       _now = now;

  static const Uuid _uuid = Uuid();

  final AppDatabase _database;
  final String Function() _newId;
  final DateTime Function() _now;

  DatabaseExecutor get _db => _database.database;

  /// Writes a new record and returns it as stored.
  ///
  /// The ID is a UUID v4 (REC-2), `created_at` and `updated_at` are the write
  /// time (REC-1), and `last_seen_at` starts there too, so the record sorts to
  /// the top of History (HIS-1).
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
  }) {
    final now = at ?? _now();
    return _database.transaction<ScanRecord>((txn) {
      return _insertRecord(
        txn,
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
        now: now,
      );
    });
  }

  /// Writes a scan or a created code, merging it into a live duplicate when
  /// DATA-4 says they are the same code.
  ///
  /// A live record with the same kind, format and raw payload — and, for a code
  /// saved from a batch, the same session — has its `last_seen_at`,
  /// `duplicate_count` and `updated_at` bumped, and never its `source` or
  /// `created_at` (DATA-4, REC-3). It also takes a fresh `seq`, so it outranks
  /// a record written in the same second (DATE-1). History then moves that row
  /// to the top and shows "×N", keeping its favourite and label (HIS-4, HIS-5).
  ///
  /// A payload that matches only a deleted record is written as a new record,
  /// since a record in Trash counts nowhere (DEL-1). Codes saved from a batch
  /// match only inside their own session, so a batch keeps every code it
  /// counted and batch codes never merge with single scans (SCAN-14).
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
  }) {
    final now = at ?? _now();
    return _database.transaction<RecordWrite>((txn) async {
      final live = await _findLiveDuplicate(
        txn,
        kind: kind,
        symbology: symbology,
        payloadText: payloadText,
        payloadBytes: payloadBytes,
        batchSessionId: batchSessionId,
      );
      if (live != null) {
        final seconds = utcSecondsOf(now);
        // The bumped row is the newest write, so it takes a fresh sequence
        // number in the same transaction: keeping the old one would leave it
        // sorting under a record inserted moments earlier in the same second,
        // instead of at the top of History (DATE-1, DATA-4, HIS-5).
        final seq = await _nextSeq(txn);
        await txn.rawUpdate(
          'UPDATE records '
          'SET seq = ?, last_seen_at = ?, updated_at = ?, '
          'duplicate_count = duplicate_count + 1 '
          'WHERE id = ?',
          <Object?>[seq, seconds, seconds, live.id],
        );
        final bumped = live.copyWith(
          seq: seq,
          duplicateCount: live.duplicateCount + 1,
          lastSeenAt: now,
          updatedAt: now,
        );
        return RecordWrite(record: bumped, isDuplicate: true);
      }
      final inserted = await _insertRecord(
        txn,
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
        now: now,
      );
      return RecordWrite(record: inserted, isDuplicate: false);
    });
  }

  /// The record with [id], or null. Records in Trash are included, since Trash
  /// reopens them (DEL-5).
  Future<ScanRecord?> findById(String id) => _findById(_db, id);

  /// Live records, newest first: the order History draws (HIS-1).
  ///
  /// Records in Trash appear nowhere (DEL-1). Rows are ordered by when their
  /// code was last seen, so a duplicate scan moves its row to the top (HIS-5),
  /// then by `seq`, so two records written in the same second keep a stable
  /// order (DATE-1).
  ///
  /// The filter and the order are the ones `idx_records_live_order` is built
  /// for, expression included, so History is read from the index without a
  /// sort; changing either here means changing the index in a new step.
  Future<List<ScanRecord>> liveRecords({int? limit, int? offset}) async {
    final rows = await _db.query(
      ScanRecord.tableName,
      where: 'deleted_at IS NULL',
      orderBy: 'COALESCE(last_seen_at, created_at) DESC, seq DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(ScanRecord.fromMap).toList(growable: false);
  }

  /// Moves a record to Trash: sets `deleted_at` and bumps `updated_at` (DEL-1,
  /// REC-3). Returns the stored record, or null when it was not live.
  Future<ScanRecord?> softDelete(String id, {DateTime? at}) async {
    final changed = await softDeleteAll(<String>[id], at: at);
    if (changed == 0) {
      return null;
    }
    return findById(id);
  }

  /// Moves several records to Trash in one write, for a multi-select or a swipe
  /// (DEL-2). Returns how many rows changed; a record already in Trash is not
  /// touched again.
  Future<int> softDeleteAll(Iterable<String> ids, {DateTime? at}) {
    final now = at ?? _now();
    return _setDeletedAt(ids, deletedAt: utcSecondsOf(now), updatedAt: now);
  }

  /// Takes a record out of Trash: clears `deleted_at` and bumps `updated_at`
  /// (REC-4). Returns the stored record, or null when it was not in Trash.
  Future<ScanRecord?> restore(String id, {DateTime? at}) async {
    final changed = await restoreAll(<String>[id], at: at);
    if (changed == 0) {
      return null;
    }
    return findById(id);
  }

  /// Takes several records out of Trash in one write, for Undo (DEL-2) and
  /// restore (DEL-5). Returns how many rows changed.
  Future<int> restoreAll(Iterable<String> ids, {DateTime? at}) {
    final now = at ?? _now();
    return _setDeletedAt(ids, deletedAt: null, updatedAt: now);
  }

  /// Sets or clears a record's label (HIS-9) and bumps `updated_at` (REC-3).
  /// Returns the stored record, or null when there is no such record.
  Future<ScanRecord?> updateLabel(
    String id, {
    required String? label,
    DateTime? at,
  }) {
    return _update(id, <String, Object?>{'label': label}, at: at);
  }

  /// Stars or unstars a record (HIS-9) and bumps `updated_at` (REC-3). Returns
  /// the stored record, or null when there is no such record.
  Future<ScanRecord?> setFavourite(
    String id, {
    required bool favourite,
    DateTime? at,
  }) {
    final stored = favourite ? 1 : 0;
    return _update(id, <String, Object?>{'favourite': stored}, at: at);
  }

  /// Stages one code of a batch session, or raises the count of the code
  /// already staged (DATA-7, SCAN-14). Returns the staged row.
  ///
  /// A staged code is matched the way the table's unique index is built, on the
  /// session and [StagedCode.duplicateKey], so the raw bytes of the first
  /// sighting are the ones the session keeps. The key folds in those bytes, so
  /// two non-UTF-8 codes that decode to the same lossy text are two staged
  /// codes and the session loses neither (DATA-2, DATA-4).
  Future<StagedCode> stageCode({
    required String sessionId,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    Uint8List? payloadBytes,
    DateTime? at,
  }) {
    final now = at ?? _now();
    final duplicateKey = StagedCode.duplicateKeyOf(
      sessionId: sessionId,
      symbology: symbology,
      payloadText: payloadText,
      payloadBytes: payloadBytes,
    );
    return _database.transaction<StagedCode>((txn) async {
      final rows = await txn.query(
        StagedCode.tableName,
        where: 'session_id = ? AND duplicate_key = ?',
        whereArgs: <Object?>[sessionId, duplicateKey],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final staged = StagedCode.fromMap(rows.first);
        await txn.rawUpdate(
          'UPDATE batch_staging '
          'SET count = count + 1, last_seen_at = ? '
          'WHERE id = ?',
          <Object?>[utcSecondsOf(now), staged.id],
        );
        return staged.copyWith(count: staged.count + 1, lastSeenAt: now);
      }
      final staged = StagedCode(
        id: _newId(),
        sessionId: sessionId,
        symbology: symbology,
        parsedType: parsedType,
        payloadText: payloadText,
        payloadBytes: payloadBytes,
        firstSeenAt: now,
        lastSeenAt: now,
      );
      await txn.insert(StagedCode.tableName, staged.toMap());
      return staged;
    });
  }

  /// Every code staged for [sessionId], in the order the session first saw
  /// them: the batch review list (SCAN-14).
  Future<List<StagedCode>> stagedCodes(String sessionId) async {
    final rows = await _db.query(
      StagedCode.tableName,
      where: 'session_id = ?',
      whereArgs: <Object?>[sessionId],
      orderBy: 'first_seen_at ASC, id ASC',
    );
    return rows.map(StagedCode.fromMap).toList(growable: false);
  }

  /// The sessions still in staging, oldest first: a batch interrupted by the
  /// app being killed is offered for review at the next launch (SCAN-14).
  Future<List<String>> stagedSessionIds() async {
    final rows = await _db.rawQuery(
      'SELECT session_id, MIN(first_seen_at) AS started FROM batch_staging '
      'GROUP BY session_id ORDER BY started ASC, session_id ASC',
    );
    return rows
        .map((row) => row['session_id'])
        .whereType<String>()
        .toList(growable: false);
  }

  /// Clears a batch session once it has been saved or discarded. Staged rows
  /// are hard-deleted, never moved to Trash (DATA-7). Returns how many rows
  /// went.
  Future<int> deleteStagedSession(String sessionId) {
    return _database.transaction<int>((txn) {
      return txn.delete(
        StagedCode.tableName,
        where: 'session_id = ?',
        whereArgs: <Object?>[sessionId],
      );
    });
  }

  Future<ScanRecord> _insertRecord(
    DatabaseExecutor txn, {
    required RecordKind kind,
    required RecordSource source,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    required DateTime now,
    Uint8List? payloadBytes,
    List<String> sensitiveFields = const <String>[],
    String? label,
    bool favourite = false,
    String? batchSessionId,
    String? contentJson,
    String? styleJson,
  }) async {
    final record = ScanRecord(
      id: _newId(),
      seq: await _nextSeq(txn),
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
      createdAt: now,
      updatedAt: now,
      lastSeenAt: now,
    );
    await txn.insert(ScanRecord.tableName, record.toMap());
    return record;
  }

  /// The next insert sequence, read inside the caller's transaction so two
  /// records written in the same second never share one (DATE-1).
  Future<int> _nextSeq(DatabaseExecutor txn) async {
    final rows = await txn.rawQuery(
      'SELECT COALESCE(MAX(seq), 0) + 1 AS next FROM records',
    );
    final next = rows.first['next'];
    return next is int ? next : 1;
  }

  /// The live record [payloadText] is a duplicate of, or null (DATA-4).
  ///
  /// The SQL narrows by the indexed columns and by session; the raw payload is
  /// then compared in full, so a payload kept as bytes never matches one kept
  /// as text (DATA-2). The newest match wins when a database from an older
  /// build holds more than one.
  Future<ScanRecord?> _findLiveDuplicate(
    DatabaseExecutor txn, {
    required RecordKind kind,
    required Symbology symbology,
    required String payloadText,
    required Uint8List? payloadBytes,
    required String? batchSessionId,
  }) async {
    final where = StringBuffer(
      'kind = ? AND symbology = ? AND payload_text = ? '
      'AND deleted_at IS NULL AND batch_session_id ',
    );
    final whereArgs = <Object?>[kind.id, symbology.id, payloadText];
    if (batchSessionId == null) {
      where.write('IS NULL');
    } else {
      where.write('= ?');
      whereArgs.add(batchSessionId);
    }
    final rows = await txn.query(
      ScanRecord.tableName,
      where: where.toString(),
      whereArgs: whereArgs,
      orderBy: 'seq DESC',
    );
    final key = ScanRecord.duplicateKeyOf(
      kind: kind,
      symbology: symbology,
      payloadText: payloadText,
      payloadBytes: payloadBytes,
      batchSessionId: batchSessionId,
    );
    for (final row in rows) {
      final candidate = ScanRecord.fromMap(row);
      if (candidate.duplicateKey == key) {
        return candidate;
      }
    }
    return null;
  }

  Future<ScanRecord?> _findById(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      ScanRecord.tableName,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanRecord.fromMap(rows.first);
  }

  /// Writes [values] plus `updated_at`, so no change can land without one
  /// (REC-3).
  Future<ScanRecord?> _update(
    String id,
    Map<String, Object?> values, {
    DateTime? at,
  }) async {
    final now = at ?? _now();
    final changed = await _database.transaction<int>((txn) {
      return txn.update(
        ScanRecord.tableName,
        <String, Object?>{...values, 'updated_at': utcSecondsOf(now)},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    });
    if (changed == 0) {
      return null;
    }
    return findById(id);
  }

  /// Sets `deleted_at` to [deletedAt] and `updated_at` to [updatedAt], only for
  /// the records the change is real for, so a count and an `updated_at` never
  /// move for a record that was already in that state (REC-3, REC-4).
  Future<int> _setDeletedAt(
    Iterable<String> ids, {
    required int? deletedAt,
    required DateTime updatedAt,
  }) {
    final unique = ids.toSet().toList(growable: false);
    if (unique.isEmpty) {
      return Future<int>.value(0);
    }
    final String guard;
    if (deletedAt == null) {
      guard = 'deleted_at IS NOT NULL';
    } else {
      guard = 'deleted_at IS NULL';
    }
    final placeholders = List<String>.filled(unique.length, '?').join(', ');
    return _database.transaction<int>((txn) {
      return txn.rawUpdate(
        'UPDATE records SET deleted_at = ?, updated_at = ? '
        'WHERE id IN ($placeholders) AND $guard',
        <Object?>[deletedAt, utcSecondsOf(updatedAt), ...unique],
      );
    });
  }
}
