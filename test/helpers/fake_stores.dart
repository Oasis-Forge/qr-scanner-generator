import 'dart:typed_data';

import 'package:qrscanner/core/store/key_value_store.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/models/staged_code.dart';

/// The one timestamp every fixture uses, so a test that asserts a date reads a
/// value it can spell out (DATE-1).
///
/// It is UTC and on a whole second, which is exactly what the schema stores, so
/// a fixture written to the database and read back compares equal.
final DateTime fixtureTime = DateTime.utc(2026, 9, 17, 10, 30, 15);

/// An in-memory [KeyValueStore] that records its writes and can be told to fail
/// them.
///
/// It decodes the way `SqfliteKeyValueStore` does — ints as decimal text, bools
/// as `'1'` or `'0'` — so state built on it sees the values the real store would
/// hand back, and a test can look at [values] to check what was stored.
///
/// [failingKeys] and [failEveryWrite] are the switch behind the roll-back tests:
/// the state layer writes before it changes anything in memory (`CLAUDE.md`), so
/// a write that throws must leave the app showing exactly what it showed before.
class FakeKeyValueStore implements KeyValueStore {
  FakeKeyValueStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  /// The rows the store holds, as the database would hold them.
  final Map<String, String> values;

  /// Keys whose writes throw a [StateError], standing in for a full or locked
  /// database.
  final Set<String> failingKeys = <String>{};

  /// Every write that was attempted, in order, as `'set settings.theme_mode=dark'`
  /// or `'remove settings.language'`. A failed write is not recorded, because
  /// nothing was written.
  final List<String> writes = <String>[];

  /// When true every write throws, whatever its key.
  bool failEveryWrite = false;

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
    final int next = (int.tryParse(values[key] ?? '') ?? 0) + by;
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
  Future<Map<String, String>> all() async => Map<String, String>.from(values);

  void _failIfAsked(String key) {
    if (failEveryWrite || failingKeys.contains(key)) {
      throw StateError('the database refused to write $key');
    }
  }
}

/// A scanned QR code carrying a link, with every field overridable.
///
/// The defaults are the plainest record the app can hold: one live camera scan
/// of an `https` link, seen once, not starred and not in Trash (DATA-2, REC-1).
/// A test overrides only the field it is about, so what it asserts is the field
/// it named.
ScanRecord aScanRecord({
  String id = 'record-1',
  int seq = 1,
  RecordKind kind = RecordKind.scan,
  RecordSource source = RecordSource.camera,
  Symbology symbology = Symbology.qr,
  ParsedType parsedType = ParsedType.url,
  String payloadText = 'https://example.com',
  Uint8List? payloadBytes,
  List<String> sensitiveFields = const <String>[],
  String? label,
  bool favourite = false,
  int duplicateCount = 1,
  String? batchSessionId,
  String? contentJson,
  String? styleJson,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
  DateTime? lastSeenAt,
}) {
  final DateTime created = createdAt ?? fixtureTime;
  return ScanRecord(
    id: id,
    seq: seq,
    kind: kind,
    source: source,
    symbology: symbology,
    parsedType: parsedType,
    payloadText: payloadText,
    payloadBytes: payloadBytes,
    sensitiveFields: sensitiveFields,
    label: label,
    favourite: favourite,
    duplicateCount: duplicateCount,
    batchSessionId: batchSessionId,
    contentJson: contentJson,
    styleJson: styleJson,
    createdAt: created,
    updatedAt: updatedAt ?? created,
    deletedAt: deletedAt,
    lastSeenAt: lastSeenAt ?? created,
  );
}

/// A code the user made in the generator (GEN-13): [aScanRecord] with the kind
/// and source a created code carries, so duplicate matching keeps it apart from
/// a scan of the same content (DATA-4).
ScanRecord aCreatedRecord({
  String id = 'created-1',
  int seq = 1,
  Symbology symbology = Symbology.qr,
  ParsedType parsedType = ParsedType.url,
  String payloadText = 'https://example.com',
  String? contentJson,
  String? styleJson,
  String? label,
  bool favourite = false,
  int duplicateCount = 1,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
  DateTime? lastSeenAt,
}) {
  return aScanRecord(
    id: id,
    seq: seq,
    kind: RecordKind.created,
    source: RecordSource.created,
    symbology: symbology,
    parsedType: parsedType,
    payloadText: payloadText,
    contentJson: contentJson,
    styleJson: styleJson,
    label: label,
    favourite: favourite,
    duplicateCount: duplicateCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    lastSeenAt: lastSeenAt,
  );
}

/// One code counted by a batch session in progress (DATA-7, SCAN-14).
StagedCode aStagedCode({
  String id = 'staged-1',
  String sessionId = 'session-1',
  Symbology symbology = Symbology.qr,
  ParsedType parsedType = ParsedType.url,
  String payloadText = 'https://example.com',
  Uint8List? payloadBytes,
  int count = 1,
  DateTime? firstSeenAt,
  DateTime? lastSeenAt,
}) {
  final DateTime first = firstSeenAt ?? fixtureTime;
  return StagedCode(
    id: id,
    sessionId: sessionId,
    symbology: symbology,
    parsedType: parsedType,
    payloadText: payloadText,
    payloadBytes: payloadBytes,
    count: count,
    firstSeenAt: first,
    lastSeenAt: lastSeenAt ?? first,
  );
}
