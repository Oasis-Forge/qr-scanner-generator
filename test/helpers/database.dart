import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/core/store/sqflite_key_value_store.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fake_stores.dart' show fixtureTime;

/// Whether sqflite's FFI backend has been initialised in this isolate.
bool _ffiReady = false;

/// One open in-memory database, with everything that reads and writes it.
///
/// The connection runs the app's real [migrationSteps], so a test works against
/// the schema the app ships, indexes and constraints included, rather than a
/// hand-built table that can drift from it.
///
/// **Hand this one connection to every collaborator.** sqflite's in-memory path
/// is shared inside an isolate: a second `AppDatabase.inMemory()` opened in the
/// same test process can find the schema already at its version, skip every
/// migration step, and leave a test quietly asserting nothing. That is why this
/// helper hands out the [AppDatabase], the [RecordDao] and the [KeyValueStore]
/// together — take the three from one call instead of opening again.
class TestDatabase {
  const TestDatabase._({
    required this.database,
    required this.records,
    required this.store,
  });

  /// The open connection, for a test that needs raw SQL.
  final AppDatabase database;

  /// Reads and writes for `records` and `batch_staging`.
  final RecordDao records;

  /// The settings, consent, Pro and success-count rows (DATA-8), through the
  /// same store the app uses.
  final KeyValueStore store;

  /// The schema version the app's steps add up to.
  int get schemaVersion => database.targetVersion;

  /// Closes the connection. Safe to call twice, so a test that closes early
  /// still works with the tear-down [openTestDatabase] registers.
  Future<void> close() => database.close();
}

/// Opens a throwaway in-memory database with the app's real schema.
///
/// [now] is the clock the [TestDatabase.records] DAO stamps rows with; it
/// defaults to [fixtureTime], so a record written in a test carries a timestamp
/// the test can spell out (DATE-1). A test that needs time to move passes a
/// closure over its own variable:
///
/// ```dart
/// DateTime clock = fixtureTime;
/// final TestDatabase db = await openTestDatabase(now: () => clock);
/// clock = clock.add(const Duration(minutes: 1));
/// ```
///
/// [newId] replaces the DAO's UUID v4 generator (REC-2) when a test wants
/// predictable IDs.
///
/// Unless [closeWhenTheTestEnds] is false, the connection is closed in a
/// tear-down, so no test leaks a database into the next one.
Future<TestDatabase> openTestDatabase({
  DateTime Function()? now,
  String Function()? newId,
  bool closeWhenTheTestEnds = true,
}) async {
  if (!_ffiReady) {
    sqfliteFfiInit();
    _ffiReady = true;
  }
  final AppDatabase database = AppDatabase.inMemory(
    runner: MigrationRunner(migrationSteps),
    databaseFactory: databaseFactoryFfi,
  );
  await database.open();
  final TestDatabase opened = TestDatabase._(
    database: database,
    records: RecordDao(database, newId: newId, now: now ?? () => fixtureTime),
    store: SqfliteKeyValueStore(database.database),
  );
  if (closeWhenTheTestEnds) {
    addTearDown(opened.close);
  }
  return opened;
}
