import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/store/sqflite_key_value_store.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The query History draws itself from (HIS-1), as `RecordDao.liveRecords`
/// builds it: the filter and the order the live-order index has to serve.
const String _historyQuery =
    'SELECT * FROM records WHERE deleted_at IS NULL '
    'ORDER BY COALESCE(last_seen_at, created_at) DESC, seq DESC';

/// The columns of [table], in the order the schema declares them, each as
/// `name TYPE [NOT NULL] [DEFAULT x] [PRIMARY KEY]`.
///
/// Read from the database itself, so this test fails if a later migration step
/// ever changes what step 1 wrote and a tester's rows would have to move.
Future<List<String>> _columns(DatabaseExecutor db, String table) async {
  final rows = await db.rawQuery('PRAGMA table_info($table)');
  final columns = <String>[];
  for (final row in rows) {
    final column = StringBuffer('${row['name']} ${row['type']}');
    if (row['notnull'] == 1) {
      column.write(' NOT NULL');
    }
    final fallback = row['dflt_value'];
    if (fallback != null) {
      column.write(' DEFAULT $fallback');
    }
    if (row['pk'] == 1) {
      column.write(' PRIMARY KEY');
    }
    columns.add(column.toString());
  }
  return columns;
}

/// The app's own tables, alphabetically. SQLite's internal tables are left out.
Future<List<String>> _tables(DatabaseExecutor db) async {
  final rows = await db.rawQuery(
    'SELECT name FROM sqlite_master '
    "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
    'ORDER BY name',
  );
  return rows.map((row) => row['name']).whereType<String>().toList();
}

/// The app's own indexes on [table], by name, with the statement that made each
/// one. Whitespace is collapsed so the assertions stay readable.
Future<Map<String, String>> _indexes(DatabaseExecutor db, String table) async {
  final rows = await db.rawQuery(
    'SELECT name, sql FROM sqlite_master '
    "WHERE type = 'index' AND tbl_name = ? AND name NOT LIKE 'sqlite_%' "
    'ORDER BY name',
    <Object?>[table],
  );
  final indexes = <String, String>{};
  for (final row in rows) {
    final name = row['name'];
    final sql = row['sql'];
    if (name is String && sql is String) {
      indexes[name] = sql.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
  }
  return indexes;
}

/// How SQLite says it will run [sql], one line per step.
Future<List<String>> _queryPlan(DatabaseExecutor db, String sql) async {
  final rows = await db.rawQuery('EXPLAIN QUERY PLAN $sql');
  return rows.map((row) => row['detail']).whereType<String>().toList();
}

Map<String, Object?> _minimalRecord(String id) {
  return <String, Object?>{
    'id': id,
    'seq': 1,
    'kind': 'scan',
    'source': 'camera',
    'symbology': 'qr',
    'parsed_type': 'text',
    'payload_text': 'hello',
    'created_at': 1789641015,
    'updated_at': 1789641015,
  };
}

/// The separator `StagedCode.duplicateKey` joins its parts with: a unit
/// separator, never a NUL, so the whole key reaches the TEXT column (DATA-7).
final String _keyPart = String.fromCharCode(0x1f);

/// A staged code's `duplicate_key` for an EAN-13 code in [sessionId], where
/// [payload] is the key's last part: `text:<payload>` for a code kept as text,
/// `bytes:<base64>` for one kept as raw bytes (DATA-2).
String _stagedKey(String sessionId, String payload) =>
    <String>[sessionId, 'ean13', payload].join(_keyPart);

/// A staged row with every NOT NULL column filled, `duplicate_key` included:
/// the session, the format and the raw payload, the way
/// `StagedCode.duplicateKey` builds it (DATA-7).
Map<String, Object?> _minimalStagedCode(
  String id, {
  String sessionId = 'session-1',
  String payload = '4006381333931',
}) {
  return <String, Object?>{
    'id': id,
    'session_id': sessionId,
    'symbology': 'ean13',
    'parsed_type': 'product',
    'payload_text': payload,
    'duplicate_key': _stagedKey(sessionId, 'text:$payload'),
    'first_seen_at': 1789641015,
    'last_seen_at': 1789641015,
  };
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('a new database, opened at version 0', () {
    late AppDatabase app;
    late Database db;

    setUp(() async {
      app = AppDatabase.inMemory(
        runner: MigrationRunner(migrationSteps),
        databaseFactory: databaseFactoryFfi,
      );
      db = await app.open();
    });

    tearDown(() => app.close());

    test('lands on the schema version a backup is checked against '
        '(BAK-5)', () async {
      expect(app.targetVersion, 1);
      expect(await db.getVersion(), 1);
    });

    test('creates the three tables the app needs (DATA-7, DATA-8)', () async {
      expect(await _tables(db), <String>[
        'app_state',
        'batch_staging',
        'records',
      ]);
    });

    test('creates every records column v1 uses, so no later step has to '
        "touch testers' data", () async {
      expect(await _columns(db, 'records'), <String>[
        'id TEXT NOT NULL PRIMARY KEY',
        'seq INTEGER NOT NULL',
        'kind TEXT NOT NULL',
        'source TEXT NOT NULL',
        'symbology TEXT NOT NULL',
        'parsed_type TEXT NOT NULL',
        'payload_text TEXT NOT NULL',
        'payload_bytes BLOB',
        "sensitive_fields TEXT NOT NULL DEFAULT '[]'",
        'label TEXT',
        'favourite INTEGER NOT NULL DEFAULT 0',
        'duplicate_count INTEGER NOT NULL DEFAULT 1',
        'batch_session_id TEXT',
        'content_json TEXT',
        'style_json TEXT',
        'created_at INTEGER NOT NULL',
        'updated_at INTEGER NOT NULL',
        'deleted_at INTEGER',
        'last_seen_at INTEGER',
      ]);
    });

    test('creates the batch staging table, duplicate key included '
        '(DATA-7)', () async {
      expect(await _columns(db, 'batch_staging'), <String>[
        'id TEXT NOT NULL PRIMARY KEY',
        'session_id TEXT NOT NULL',
        'symbology TEXT NOT NULL',
        'parsed_type TEXT NOT NULL',
        'payload_text TEXT NOT NULL',
        'payload_bytes BLOB',
        'duplicate_key TEXT NOT NULL',
        'count INTEGER NOT NULL DEFAULT 1',
        'first_seen_at INTEGER NOT NULL',
        'last_seen_at INTEGER NOT NULL',
      ]);
    });

    test('creates the table the settings store reads (DATA-8)', () async {
      expect(await _columns(db, 'app_state'), <String>[
        'key TEXT NOT NULL PRIMARY KEY',
        'value TEXT NOT NULL',
      ]);
      // Step 1 spells this table out instead of asking the store for the
      // statement, so a store renamed away from the frozen schema fails here
      // rather than quietly changing what version 1 means.
      expect(SqfliteKeyValueStore.defaultTableName, 'app_state');
      expect(SqfliteKeyValueStore.keyColumn, 'key');
      expect(SqfliteKeyValueStore.valueColumn, 'value');
    });

    test('indexes the History order, duplicate lookup and batches '
        '(HIS-1, DATA-4)', () async {
      expect(await _indexes(db, 'records'), <String, String>{
        'idx_records_batch_session':
            'CREATE INDEX idx_records_batch_session ON records '
            '(batch_session_id)',
        'idx_records_duplicate':
            'CREATE INDEX idx_records_duplicate ON records '
            '(kind, symbology, payload_text)',
        'idx_records_live_order':
            'CREATE INDEX idx_records_live_order ON records '
            '(deleted_at, COALESCE(last_seen_at, created_at) DESC, seq DESC)',
      });
    });

    test('draws the History list straight from the live-order index, with no '
        'sort (HIS-1, HIS-5, DATE-1)', () async {
      final plan = (await _queryPlan(db, _historyQuery)).join(' | ');

      expect(plan, contains('idx_records_live_order'));
      expect(plan, isNot(contains('TEMP B-TREE')));
    });

    test('indexes a staging session and the code inside it (DATA-7)', () async {
      expect(await _indexes(db, 'batch_staging'), <String, String>{
        'idx_batch_staging_session':
            'CREATE INDEX idx_batch_staging_session ON batch_staging '
            '(session_id)',
        'idx_batch_staging_unique':
            'CREATE UNIQUE INDEX idx_batch_staging_unique ON batch_staging '
            '(session_id, duplicate_key)',
      });
    });

    test(
      'defaults a new record to unstarred, unmasked and seen once',
      () async {
        await db.insert('records', _minimalRecord('r1'));

        final row = (await db.query('records')).single;

        expect(row['sensitive_fields'], '[]');
        expect(row['favourite'], 0);
        expect(row['duplicate_count'], 1);
        expect(row['label'], isNull);
        expect(row['payload_bytes'], isNull);
        expect(row['batch_session_id'], isNull);
        expect(row['deleted_at'], isNull);
        expect(row['last_seen_at'], isNull);
      },
    );

    test('refuses a second record with the same ID (REC-2)', () async {
      await db.insert('records', _minimalRecord('r1'));

      await expectLater(
        db.insert('records', _minimalRecord('r1')),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('refuses a record written without timestamps (REC-1)', () async {
      final incomplete = _minimalRecord('r1')..remove('created_at');

      await expectLater(
        db.insert('records', incomplete),
        throwsA(isA<DatabaseException>()),
      );
    });

    test(
      'refuses the same code staged twice in one session (SCAN-14)',
      () async {
        await db.insert('batch_staging', _minimalStagedCode('s1'));

        await expectLater(
          db.insert('batch_staging', _minimalStagedCode('s2')),
          throwsA(isA<DatabaseException>()),
        );
      },
    );

    test('stages the same code in another session (SCAN-14)', () async {
      await db.insert('batch_staging', _minimalStagedCode('s1'));

      await db.insert(
        'batch_staging',
        _minimalStagedCode('s2', sessionId: 'session-2'),
      );

      final sessions = (await db.query(
        'batch_staging',
        orderBy: 'id ASC',
      )).map((row) => row['session_id']).toList();
      expect(sessions, <String>['session-1', 'session-2']);
    });

    test('stages two codes of one session whose keys differ but whose text is '
        'the same (DATA-2, SCAN-14)', () async {
      await db.insert('batch_staging', _minimalStagedCode('s1'));
      // What two non-UTF-8 codes with the same lossy text look like: one text
      // payload, two keys. Matching on the text alone would lose one (DATA-7).
      final other = _minimalStagedCode('s2')
        ..['duplicate_key'] = _stagedKey('session-1', 'bytes:/kE=');

      await db.insert('batch_staging', other);

      final rows = await db.query('batch_staging', orderBy: 'id ASC');
      expect(rows.map((row) => row['payload_text']), <String>[
        '4006381333931',
        '4006381333931',
      ]);
      expect(rows.map((row) => row['duplicate_key']).toSet(), hasLength(2));
    });

    test('refuses a staged code written without a duplicate key '
        '(DATA-7)', () async {
      final incomplete = _minimalStagedCode('s1')..remove('duplicate_key');

      await expectLater(
        db.insert('batch_staging', incomplete),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('the steps run by hand', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    });

    tearDown(() => db.close());

    test('upgrade a version-0 database to the whole schema', () async {
      final runner = MigrationRunner(migrationSteps);
      expect(await db.getVersion(), 0);

      await runner.upgrade(db, from: 0, to: runner.targetVersion);

      expect(await _tables(db), <String>[
        'app_state',
        'batch_staging',
        'records',
      ]);
      expect((await _columns(db, 'records')).length, 19);
      expect((await _indexes(db, 'records')).keys, hasLength(3));
      expect((await _indexes(db, 'batch_staging')).keys, hasLength(2));
    });

    test('leave a database already at the schema version alone', () async {
      final runner = MigrationRunner(migrationSteps);
      await runner.upgrade(db, from: 0, to: runner.targetVersion);

      // Running step 1 again would fail: the tables already exist.
      await runner.upgrade(
        db,
        from: runner.targetVersion,
        to: runner.targetVersion,
      );

      expect(await _tables(db), <String>[
        'app_state',
        'batch_staging',
        'records',
      ]);
    });
  });
}
