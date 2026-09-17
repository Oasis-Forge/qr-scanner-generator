import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A step that records itself, so a test can see which steps ran and in what
/// order. Its statements use plain `CREATE TABLE`, so a step that ran twice
/// would fail loudly instead of passing quietly.
class _LoggedStep extends MigrationStep {
  const _LoggedStep(this.version, this.statements);

  @override
  final int version;

  final List<String> statements;

  @override
  Future<void> up(DatabaseExecutor db) async {
    for (final statement in statements) {
      await db.execute(statement);
    }
    await db.insert('applied', {'step': version});
  }
}

const _step1 = _LoggedStep(1, [
  'CREATE TABLE applied ('
      'seq INTEGER PRIMARY KEY AUTOINCREMENT, step INTEGER NOT NULL)',
  'CREATE TABLE note (id INTEGER PRIMARY KEY, body TEXT NOT NULL)',
]);

const _step2 = _LoggedStep(2, ['ALTER TABLE note ADD COLUMN label TEXT']);

const _step3 = _LoggedStep(3, [
  'CREATE TABLE tag ('
      'id INTEGER PRIMARY KEY, '
      'note_id INTEGER NOT NULL REFERENCES note (id) ON DELETE CASCADE, '
      'name TEXT NOT NULL)',
]);

/// The steps that ran, in the order they ran.
Future<List<int>> _appliedSteps(Database db) async {
  final rows = await db.query('applied', columns: ['step'], orderBy: 'seq ASC');
  return [for (final row in rows) row['step']! as int];
}

AppDatabase _inMemory(List<MigrationStep> steps) => AppDatabase.inMemory(
  runner: MigrationRunner(steps),
  databaseFactory: databaseFactoryFfi,
);

void main() {
  setUpAll(sqfliteFfiInit);

  group('a fresh database', () {
    test('runs every step and lands on the target version', () async {
      final app = _inMemory([_step1, _step2, _step3]);
      addTearDown(app.close);

      final db = await app.open();

      expect(app.targetVersion, 3);
      expect(await db.getVersion(), 3);
      expect(await _appliedSteps(db), [1, 2, 3]);
    });

    test(
      'runs steps in version order whatever order they are given in',
      () async {
        final app = _inMemory([_step3, _step1, _step2]);
        addTearDown(app.close);

        final db = await app.open();

        expect(await _appliedSteps(db), [1, 2, 3]);
        expect(await db.getVersion(), 3);
      },
    );

    test('ends up with the columns a later step added', () async {
      final app = _inMemory([_step1, _step2, _step3]);
      addTearDown(app.close);
      final db = await app.open();

      await db.insert('note', {'body': 'https://example.org', 'label': 'Work'});

      final rows = await db.query('note', columns: ['body', 'label']);
      expect(rows.single['body'], 'https://example.org');
      expect(rows.single['label'], 'Work');
    });
  });

  group('an existing database', () {
    late Directory directory;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('qrscanner_db_test');
    });

    tearDown(() {
      try {
        directory.deleteSync(recursive: true);
      } on FileSystemException {
        // A file lock can outlive the test on Windows; the directory is
        // disposable either way.
      }
    });

    AppDatabase openAt(List<MigrationStep> steps, {String? fileName}) =>
        AppDatabase(
          directory: directory.path,
          runner: MigrationRunner(steps),
          fileName: fileName ?? AppDatabase.defaultFileName,
          databaseFactory: databaseFactoryFfi,
        );

    test(
      'runs only the missing steps, in order, and keeps its rows (BAK-5)',
      () async {
        final firstRun = openAt([_step1]);
        final firstDb = await firstRun.open();
        expect(await firstDb.getVersion(), 1);
        expect(await _appliedSteps(firstDb), [1]);
        await firstDb.insert('note', {'id': 7, 'body': 'kept across upgrades'});
        await firstRun.close();

        final secondRun = openAt([_step1, _step2, _step3]);
        addTearDown(secondRun.close);
        final secondDb = await secondRun.open();

        // Step 1 is not run again: it appears once, and its own CREATE TABLE
        // would have failed if it had run twice.
        expect(await _appliedSteps(secondDb), [1, 2, 3]);
        expect(await secondDb.getVersion(), 3);
        final rows = await secondDb.query(
          'note',
          columns: ['id', 'body', 'label'],
        );
        expect(rows.single['body'], 'kept across upgrades');
        expect(rows.single['label'], isNull);
      },
    );

    test('runs nothing when it is already at the target version', () async {
      final firstRun = openAt([_step1, _step2]);
      final firstDb = await firstRun.open();
      expect(await _appliedSteps(firstDb), [1, 2]);
      await firstRun.close();

      final secondRun = openAt([_step1, _step2]);
      addTearDown(secondRun.close);
      final secondDb = await secondRun.open();

      expect(await _appliedSteps(secondDb), [1, 2]);
      expect(await secondDb.getVersion(), 2);
    });

    test(
      'writes to the default file name in the directory it is given',
      () async {
        final app = openAt([_step1]);
        addTearDown(app.close);

        await app.open();

        expect(app.path, p.join(directory.path, 'qrscanner.db'));
        expect(
          File(p.join(directory.path, 'qrscanner.db')).existsSync(),
          isTrue,
        );
      },
    );

    test('writes to the file name the caller picks', () async {
      final app = openAt([_step1], fileName: 'scratch.db');
      addTearDown(app.close);

      await app.open();

      expect(app.path, p.join(directory.path, 'scratch.db'));
      expect(File(p.join(directory.path, 'scratch.db')).existsSync(), isTrue);
    });
  });

  group('step numbering', () {
    test('an empty history is refused, so no database is stamped at a version '
        'nothing created', () {
      // Left unchecked, the runner would report target version 1 and let
      // sqflite stamp a brand-new database at 1 without creating a table;
      // the real step 1 would then be skipped forever on that install.
      expect(
        () => MigrationRunner(<MigrationStep>[]),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message.toString(),
            'message',
            contains('at least one migration step'),
          ),
        ),
      );
    });

    test('the target version is the last step, not a hard-coded 1', () {
      expect(MigrationRunner([_step1]).targetVersion, 1);
      expect(MigrationRunner([_step1, _step2]).targetVersion, 2);
      expect(MigrationRunner([_step1, _step2, _step3]).targetVersion, 3);
    });

    test('a gap between steps is refused', () {
      expect(() => MigrationRunner([_step1, _step3]), throwsArgumentError);
    });

    test('a history that does not start at 1 is refused', () {
      expect(() => MigrationRunner([_step2, _step3]), throwsArgumentError);
    });

    test('two steps with the same version are refused', () {
      expect(
        () => MigrationRunner([_step1, const _LoggedStep(1, [])]),
        throwsArgumentError,
      );
    });
  });

  group('the open database', () {
    // Plumbing, not a product rule: no shipped table declares a foreign key
    // yet (a batch staging session, DATA-7, is cleared by its own delete), so
    // this proves the connection-level pragma is on and a `REFERENCES` clause
    // added by a later step will be enforced rather than ignored.
    test(
      'enforces a declared foreign key, so a child row cannot be orphaned',
      () async {
        final app = _inMemory([_step1, _step2, _step3]);
        addTearDown(app.close);
        final db = await app.open();
        await db.insert('note', {'id': 1, 'body': 'parent'});
        await db.insert('tag', {'note_id': 1, 'name': 'keep'});

        await db.delete('note', where: 'id = ?', whereArgs: [1]);

        expect(await db.query('tag'), isEmpty);
        await expectLater(
          db.insert('tag', {'note_id': 404, 'name': 'orphan'}),
          throwsA(isA<DatabaseException>()),
        );
      },
    );

    test('rolls a failed transaction back', () async {
      final app = _inMemory([_step1]);
      addTearDown(app.close);
      final db = await app.open();

      await expectLater(
        app.transaction<void>((txn) async {
          await txn.insert('note', {'body': 'rolled back'});
          throw StateError('the caller gave up');
        }),
        throwsStateError,
      );

      expect(await db.query('note'), isEmpty);
    });

    test('keeps a committed transaction', () async {
      final app = _inMemory([_step1]);
      addTearDown(app.close);
      final db = await app.open();

      final id = await app.transaction<int>(
        (txn) => txn.insert('note', {'body': 'committed'}),
      );

      expect(id, 1);
      expect((await db.query('note')).single['body'], 'committed');
    });

    test('is the same connection when open is called again', () async {
      final app = _inMemory([_step1]);
      addTearDown(app.close);

      final first = await app.open();
      final second = await app.open();

      expect(identical(first, second), isTrue);
      expect(identical(app.database, first), isTrue);
    });

    test('is refused before open and after close', () async {
      final app = _inMemory([_step1]);
      expect(app.isOpen, isFalse);
      expect(() => app.database, throwsStateError);

      await app.open();
      expect(app.isOpen, isTrue);
      await app.close();

      expect(app.isOpen, isFalse);
      expect(() => app.database, throwsStateError);
    });
  });
}
