import 'package:sqflite/sqflite.dart';

import 'key_value_store.dart';

/// A [KeyValueStore] backed by one two-column table.
///
/// Values are stored as TEXT, whatever their type: ints as their decimal text,
/// bools as `'1'` or `'0'`. Reads decode defensively, so a row written by an
/// older build, a hand-edited database or a restored backup reads as `null`
/// instead of throwing, and the caller falls back to its default.
///
/// Every write is awaited to completion before it returns, so the settings,
/// consent and Pro flags and the success counts behind ads and the Pro prompt
/// (DATA-8) are on disk before the caller changes its own state. Nothing here
/// leaves the device (PRIV-8).
class SqfliteKeyValueStore implements KeyValueStore {
  /// [tableName] must be a plain SQL identifier: it goes into the statements
  /// verbatim, since a table name can't be a bound parameter.
  SqfliteKeyValueStore(Database database, {this.tableName = defaultTableName})
    : _db = database {
    if (!_identifier.hasMatch(tableName)) {
      throw ArgumentError.value(
        tableName,
        'tableName',
        'must be a plain SQL identifier (letters, digits and underscores, '
            'not starting with a digit)',
      );
    }
  }

  /// The table name used when the caller doesn't pick one.
  static const String defaultTableName = 'app_state';

  /// The key column of the table.
  static const String keyColumn = 'key';

  /// The value column of the table.
  static const String valueColumn = 'value';

  static final RegExp _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  /// The statement that creates the table, for a migration step to run.
  static String createTableStatement([String tableName = defaultTableName]) =>
      'CREATE TABLE $tableName ('
      '$keyColumn TEXT PRIMARY KEY NOT NULL, '
      '$valueColumn TEXT NOT NULL'
      ')';

  /// The table this store reads and writes.
  final String tableName;

  final Database _db;

  @override
  Future<String?> getString(String key) => _read(_db, key);

  @override
  Future<void> setString(String key, String value) => _write(_db, key, value);

  @override
  Future<int?> getInt(String key) async => _decodeInt(await getString(key));

  @override
  Future<void> setInt(String key, int value) => setString(key, '$value');

  @override
  Future<bool?> getBool(String key) async => _decodeBool(await getString(key));

  @override
  Future<void> setBool(String key, {required bool value}) =>
      setString(key, value ? '1' : '0');

  /// Reads and writes in one transaction, so two increments that overlap both
  /// count: the second reads the first one's value, never the value before it.
  @override
  Future<int> increment(String key, {int by = 1}) =>
      _db.transaction<int>((txn) async {
        final current = _decodeInt(await _read(txn, key)) ?? 0;
        final next = current + by;
        await _write(txn, key, '$next');
        return next;
      });

  @override
  Future<void> remove(String key) async {
    await _db.delete(tableName, where: '$keyColumn = ?', whereArgs: [key]);
  }

  @override
  Future<Map<String, String>> all() async {
    final rows = await _db.query(
      tableName,
      columns: [keyColumn, valueColumn],
      orderBy: '$keyColumn ASC',
    );
    final values = <String, String>{};
    for (final row in rows) {
      final key = row[keyColumn];
      final value = row[valueColumn];
      if (key is String && value is String) {
        values[key] = value;
      }
    }
    return values;
  }

  Future<String?> _read(DatabaseExecutor db, String key) async {
    final rows = await db.query(
      tableName,
      columns: [valueColumn],
      where: '$keyColumn = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first[valueColumn];
    return value is String ? value : null;
  }

  Future<void> _write(DatabaseExecutor db, String key, String value) async {
    await db.insert(tableName, {
      keyColumn: key,
      valueColumn: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static int? _decodeInt(String? raw) =>
      raw == null ? null : int.tryParse(raw.trim());

  static bool? _decodeBool(String? raw) => switch (raw?.trim()) {
    '1' => true,
    '0' => false,
    _ => null,
  };
}
