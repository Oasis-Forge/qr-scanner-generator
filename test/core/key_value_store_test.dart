import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/core/store/sqflite_key_value_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates the one table the store needs, the way the app's own first
/// migration step will.
class _CreateStateTable extends MigrationStep {
  const _CreateStateTable([
    this.tableName = SqfliteKeyValueStore.defaultTableName,
  ]);

  final String tableName;

  @override
  int get version => 1;

  @override
  Future<void> up(DatabaseExecutor db) =>
      db.execute(SqfliteKeyValueStore.createTableStatement(tableName));
}

AppDatabase _open([String? tableName]) => AppDatabase.inMemory(
  runner: MigrationRunner([
    tableName == null
        ? const _CreateStateTable()
        : _CreateStateTable(tableName),
  ]),
  databaseFactory: databaseFactoryFfi,
);

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase app;
  late KeyValueStore store;

  setUp(() async {
    app = _open();
    await app.open();
    store = SqfliteKeyValueStore(app.database);
  });

  tearDown(() => app.close());

  group('strings', () {
    test('round-trip (DATA-8)', () async {
      await store.setString('settings.theme_mode', 'dark');

      expect(await store.getString('settings.theme_mode'), 'dark');
    });

    test('land in the database before the write returns', () async {
      await store.setString('settings.language', 'ar');

      final rows = await app.database.query('app_state');
      expect(rows, [
        {'key': 'settings.language', 'value': 'ar'},
      ]);
    });

    test('replace the previous value for the same key', () async {
      await store.setString('settings.theme_mode', 'dark');
      await store.setString('settings.theme_mode', 'light');

      expect(await store.getString('settings.theme_mode'), 'light');
      expect(await store.all(), {'settings.theme_mode': 'light'});
    });

    test('read as null when the key was never set', () async {
      expect(await store.getString('settings.theme_mode'), isNull);
      expect(await store.getInt('counts.scans'), isNull);
      expect(await store.getBool('privacy.crash_reports'), isNull);
    });

    test('keep an empty value distinct from an unset key', () async {
      await store.setString('settings.label', '');

      expect(await store.getString('settings.label'), '');
      expect(await store.all(), {'settings.label': ''});
    });
  });

  group('ints', () {
    test('round-trip and are stored as text (DATA-8)', () async {
      await store.setInt('counts.scans', 42);

      expect(await store.getInt('counts.scans'), 42);
      expect(await store.all(), {'counts.scans': '42'});
    });

    test('round-trip when negative', () async {
      await store.setInt('counts.scans', -3);

      expect(await store.getInt('counts.scans'), -3);
    });
  });

  group('bools', () {
    test("are stored as '1' and '0' (PRIV-8)", () async {
      await store.setBool('privacy.crash_reports', value: true);
      await store.setBool('settings.sound', value: false);

      expect(await store.getBool('privacy.crash_reports'), isTrue);
      expect(await store.getBool('settings.sound'), isFalse);
      expect(await store.all(), {
        'privacy.crash_reports': '1',
        'settings.sound': '0',
      });
    });
  });

  group('increment', () {
    test('starts from zero when the key is unset (DATA-8)', () async {
      expect(await store.increment('counts.scans'), 1);

      expect(await store.getInt('counts.scans'), 1);
    });

    test('adds to the stored value and returns the new one', () async {
      await store.setInt('counts.creates', 4);

      expect(await store.increment('counts.creates'), 5);
      expect(await store.increment('counts.creates', by: 5), 10);
      expect(await store.getInt('counts.creates'), 10);
    });

    test('counts every overlapping increment once', () async {
      final results = await Future.wait([
        for (var i = 0; i < 5; i++) store.increment('counts.scans'),
      ]);

      expect(results.toSet(), {1, 2, 3, 4, 5});
      expect(await store.getInt('counts.scans'), 5);
    });

    test('treats a value it cannot read as zero', () async {
      await store.setString('counts.scans', 'rubbish');

      expect(await store.increment('counts.scans', by: 2), 2);
      expect(await store.getInt('counts.scans'), 2);
    });
  });

  group('a value the store cannot decode', () {
    test('reads as null instead of throwing', () async {
      await store.setString('counts.scans', 'not a number');
      await store.setString('settings.sound', 'yes please');

      expect(await store.getInt('counts.scans'), isNull);
      expect(await store.getBool('settings.sound'), isNull);
      expect(await store.getString('counts.scans'), 'not a number');
    });
  });

  group('remove', () {
    test('deletes the row', () async {
      await store.setString('settings.label', 'Work');

      await store.remove('settings.label');

      expect(await store.getString('settings.label'), isNull);
      expect(await store.all(), isEmpty);
    });

    test('leaves the other keys alone', () async {
      await store.setString('settings.label', 'Work');
      await store.setInt('counts.scans', 2);

      await store.remove('settings.never_written');

      expect(await store.all(), {
        'settings.label': 'Work',
        'counts.scans': '2',
      });
    });
  });

  group('all', () {
    test('lists every stored key as text', () async {
      await store.setString('settings.theme_mode', 'dark');
      await store.setInt('counts.scans', 7);
      await store.setBool('pro.owned', value: true);

      expect(await store.all(), {
        'settings.theme_mode': 'dark',
        'counts.scans': '7',
        'pro.owned': '1',
      });
    });

    test('is empty on a fresh database', () async {
      expect(await store.all(), isEmpty);
    });
  });

  group('the table name', () {
    test('can be chosen by the caller', () async {
      // One connection, not a second AppDatabase: every in-memory database in
      // this isolate is the same one, so a second open finds the schema already
      // at version 1 and never runs the step that would create this table.
      await app.database.execute(
        SqfliteKeyValueStore.createTableStatement('consent'),
      );
      final consent = SqfliteKeyValueStore(app.database, tableName: 'consent');

      await consent.setString('consent.status', 'obtained');

      expect(await app.database.query('consent'), [
        {'key': 'consent.status', 'value': 'obtained'},
      ]);
      expect(await consent.all(), {'consent.status': 'obtained'});
    });

    test('is refused when it is not a plain identifier', () {
      expect(
        () => SqfliteKeyValueStore(
          app.database,
          tableName: 'app_state; DROP TABLE app_state',
        ),
        throwsArgumentError,
      );
    });
  });
}
