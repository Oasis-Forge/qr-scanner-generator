import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migration.dart';

/// Opens a sqflite database and keeps its schema at the version a
/// [MigrationRunner]'s steps add up to.
///
/// A fresh install runs every step in one go and lands directly on
/// [targetVersion]; an existing database runs only the steps above the version
/// it stored, so a merged step never runs twice. That stored version is also
/// what a backup file is compared against on restore (BAK-5).
///
/// Reusable plumbing: it holds no app-specific SQL and no knowledge of the
/// app's tables. The caller decides the directory and the [DatabaseFactory], so
/// this file never asks the platform where to write (no `path_provider`) and
/// never builds a factory of its own.
///
/// The database is the whole store: there is no account and no cloud sync
/// (PRIV-7).
class AppDatabase {
  /// Opens `<directory>/<fileName>`.
  ///
  /// [databaseFactory] is required and has no default on purpose: `lib/core/`
  /// may not reach for a plugin (`CLAUDE.md`), and a real factory sitting in a
  /// default parameter would hand a caller real file I/O by accident. The app's
  /// entry point passes `databaseFactorySqflitePlugin` from
  /// `package:sqflite/sqflite.dart` — the one place the real plugin is built —
  /// and tests pass `databaseFactoryFfi`.
  AppDatabase({
    required String directory,
    required MigrationRunner runner,
    required DatabaseFactory databaseFactory,
    String fileName = defaultFileName,
  }) : this._(
         path: p.join(directory, fileName),
         runner: runner,
         openWith: databaseFactory,
       );

  /// Opens a throwaway database that lives only as long as it is open, for
  /// tests. Needs an in-memory capable [databaseFactory], such as
  /// `databaseFactoryFfi`.
  AppDatabase.inMemory({
    required MigrationRunner runner,
    required DatabaseFactory databaseFactory,
  }) : this._(
         path: inMemoryDatabasePath,
         runner: runner,
         openWith: databaseFactory,
       );

  AppDatabase._({
    required this.path,
    required MigrationRunner runner,
    required DatabaseFactory openWith,
  }) : _runner = runner,
       _factory = openWith;

  /// The file name used when the caller doesn't pick one.
  static const String defaultFileName = 'qrscanner.db';

  /// Where the database file lives, or `:memory:`.
  final String path;

  final MigrationRunner _runner;
  final DatabaseFactory _factory;

  Database? _db;

  /// The schema version [open] brings the database to.
  int get targetVersion => _runner.targetVersion;

  /// Whether [open] has completed and [close] hasn't run since.
  bool get isOpen => _db != null;

  /// The open database.
  ///
  /// Throws a [StateError] when [open] hasn't been awaited yet, rather than
  /// handing out a half-built connection.
  Database get database {
    final db = _db;
    if (db == null) {
      throw StateError('AppDatabase.open() has not been awaited for $path');
    }
    return db;
  }

  /// Opens the database, migrating it if needed. Calling it again while open
  /// returns the same [Database].
  Future<Database> open() async {
    final existing = _db;
    if (existing != null) {
      return existing;
    }
    final db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _runner.targetVersion,
        onConfigure: _configure,
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
    _db = db;
    return db;
  }

  /// Runs [action] in a transaction, so a write that fails leaves nothing
  /// behind.
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) => database.transaction<T>(action, exclusive: exclusive);

  /// Closes the database. Safe to call when it was never opened.
  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  /// Foreign keys are off by default in SQLite and the setting belongs to the
  /// connection, not the file, so every open turns them on. No table in the
  /// schema declares one today — a batch staging session (DATA-7) is cleared by
  /// its own delete, not by a cascade — so this is here so that the first
  /// `REFERENCES` clause a later migration step adds is enforced from its first
  /// open instead of being silently ignored.
  Future<void> _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// A new file starts at 0, so every step runs.
  Future<void> _create(Database db, int version) =>
      _runner.upgrade(db, from: 0, to: version);

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) =>
      _runner.upgrade(db, from: oldVersion, to: newVersion);
}
