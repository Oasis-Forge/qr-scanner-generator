import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'record_enums.dart';

/// The value [ScanRecord.copyWith] uses for "leave this field alone", so
/// passing null can mean "clear it". Private, so no caller can pass it.
class _Keep {
  const _Keep();
}

/// The field keys a record flags as sensitive (DATA-5).
///
/// One name per masked field, named here and nowhere else, so every surface
/// that reads the flag masks the same field: list rows and share previews
/// (HIS-7), search (HIS-2) and export (EXP-4). A parser that finds a sensitive
/// field puts the key from here into [ScanRecord.sensitiveFields].
///
/// These strings are stored in the `sensitive_fields` column, so a key is part
/// of a tester's data: renaming one would unmask every record already written
/// and needs a migration step, not an edit here.
abstract final class SensitiveFieldKeys {
  /// A Wi-Fi network's password, the one field v1 masks (DATA-5, HIS-7).
  static const String wifiPassword = 'wifi.password';

  /// Every key a v1 record can carry, for a surface that masks the lot.
  static const List<String> all = <String>[wifiPassword];
}

/// One row of the `records` table: a code the user scanned or created.
///
/// Immutable, so a screen can hold one while the DAO writes another. Every v1
/// field is here from the first migration step, so no later step touches
/// testers' data (`docs/PRODUCT_RULES.md`, Roadmap impact).
///
/// The record keeps the decoded payload and, for a created code, its content
/// and style settings; never a camera frame, an imported image or a rendered
/// code (DATA-3).
class ScanRecord {
  /// Timestamps are truncated to the whole UTC seconds the schema stores, so a
  /// record in memory equals the row it came from (DATE-1).
  ScanRecord({
    required this.id,
    required this.seq,
    required this.kind,
    required this.source,
    required this.symbology,
    required this.parsedType,
    required this.payloadText,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.payloadBytes,
    List<String> sensitiveFields = const <String>[],
    this.label,
    this.favourite = false,
    this.duplicateCount = 1,
    this.batchSessionId,
    this.contentJson,
    this.styleJson,
    DateTime? deletedAt,
    DateTime? lastSeenAt,
  }) : createdAt = truncatedToUtcSeconds(createdAt),
       updatedAt = truncatedToUtcSeconds(updatedAt),
       deletedAt = _utcOrNull(deletedAt),
       lastSeenAt = _utcOrNull(lastSeenAt),
       sensitiveFields = List<String>.unmodifiable(sensitiveFields);

  /// Reads a row of [tableName].
  ///
  /// Anything the row does not explain — an enum ID this build cannot name, a
  /// sensitive-field list that is not a JSON array — reads as its fallback
  /// instead of throwing, so one odd row never hides the rest of History
  /// (DATA-1) and a restored backup written by a newer build still opens
  /// (BAK-5).
  factory ScanRecord.fromMap(Map<String, Object?> row) {
    return ScanRecord(
      id: _stringOf(row['id']) ?? '',
      seq: _intOf(row['seq']) ?? 0,
      kind: RecordKind.fromId(_stringOf(row['kind'])),
      source: RecordSource.fromId(_stringOf(row['source'])),
      symbology: Symbology.fromId(_stringOf(row['symbology'])),
      parsedType: ParsedType.fromId(_stringOf(row['parsed_type'])),
      payloadText: _stringOf(row['payload_text']) ?? '',
      payloadBytes: _bytesOf(row['payload_bytes']),
      sensitiveFields: _sensitiveFieldsOf(row['sensitive_fields']),
      label: _stringOf(row['label']),
      favourite: (_intOf(row['favourite']) ?? 0) != 0,
      duplicateCount: _intOf(row['duplicate_count']) ?? 1,
      batchSessionId: _stringOf(row['batch_session_id']),
      contentJson: _stringOf(row['content_json']),
      styleJson: _stringOf(row['style_json']),
      createdAt: _timeOf(row['created_at']) ?? _unsetTime,
      updatedAt: _timeOf(row['updated_at']) ?? _unsetTime,
      deletedAt: _timeOf(row['deleted_at']),
      lastSeenAt: _timeOf(row['last_seen_at']),
    );
  }

  /// The table these records live in.
  static const String tableName = 'records';

  /// The record's UUID v4, so records from a backup never collide (REC-2).
  final String id;

  /// The insert sequence, which orders records written in the same second
  /// (DATE-1).
  final int seq;

  /// Whether the code was scanned or created (DATA-4).
  final RecordKind kind;

  /// Where the code came from (DATA-2). Never changes (REC-3).
  final RecordSource source;

  /// The code format (SCAN-9). Never changes (REC-3).
  final Symbology symbology;

  /// What the payload was parsed as (DATA-1). Never changes (REC-3).
  final ParsedType parsedType;

  /// The payload as UTF-8 text (DATA-2). Never changes (REC-3).
  final String payloadText;

  /// The raw bytes, set only when the payload is not valid UTF-8 (DATA-2,
  /// RES-13). Treated as read-only.
  final Uint8List? payloadBytes;

  /// The field keys every surface must mask, from [SensitiveFieldKeys]: a
  /// Wi-Fi password today (DATA-5).
  ///
  /// Unmodifiable. List rows and share previews mask these (HIS-7), search
  /// skips them (HIS-2) and export hides them by default (EXP-4).
  final List<String> sensitiveFields;

  /// The user's own name for the record, or null (HIS-9).
  final String? label;

  /// Whether the user starred the record (HIS-9).
  final bool favourite;

  /// How many times this code has been seen, shown as "×N" from 2 up (HIS-4,
  /// DATA-4).
  final int duplicateCount;

  /// The batch session this code was saved from, or null for a single code
  /// (DATA-4, SCAN-14, HIS-6).
  final String? batchSessionId;

  /// A created code's content fields as JSON (GEN-5 to GEN-10), or null.
  final String? contentJson;

  /// A created code's style settings as JSON (STY-1 to STY-4), or null.
  final String? styleJson;

  /// When the record was written, in UTC (REC-1). Never changes, a duplicate
  /// scan included (DATA-4).
  final DateTime createdAt;

  /// When the record last changed, in UTC (REC-1, REC-3).
  final DateTime updatedAt;

  /// When the record was moved to Trash, or null while it is live (DEL-1).
  final DateTime? deletedAt;

  /// When this code was last seen, which is History's order (HIS-1, HIS-5).
  final DateTime? lastSeenAt;

  static const ListEquality<int> _bytesEquality = ListEquality<int>();
  static const ListEquality<String> _keysEquality = ListEquality<String>();
  static const Object _keep = _Keep();

  /// The separator between the parts of a duplicate key. The payload is the
  /// last part and the parts before it can never carry this character, so two
  /// different codes can never build the same key.
  static final String _keyPart = String.fromCharCode(0);

  /// Whether the record is in Trash, where it counts nowhere (DEL-1).
  bool get isDeleted => deletedAt != null;

  /// Whether [key] — a [SensitiveFieldKeys] value — names a field that must be
  /// masked (DATA-5).
  bool isSensitiveField(String key) => sensitiveFields.contains(key);

  /// What DATA-4 matches on: kind, format, the raw payload and, for a batch
  /// code, its session.
  String get duplicateKey => duplicateKeyOf(
    kind: kind,
    symbology: symbology,
    payloadText: payloadText,
    payloadBytes: payloadBytes,
    batchSessionId: batchSessionId,
  );

  /// The key two records must share to be duplicates (DATA-4).
  ///
  /// Scans match scans and created codes match created codes, on an exact raw
  /// payload: a payload kept as bytes never matches one kept as text. Codes
  /// saved from a batch carry their session, so a batch keeps every code it
  /// counted and batch codes never merge with single scans (SCAN-14).
  static String duplicateKeyOf({
    required RecordKind kind,
    required Symbology symbology,
    required String payloadText,
    Uint8List? payloadBytes,
    String? batchSessionId,
  }) {
    final String payload;
    if (payloadBytes == null) {
      payload = 'text:$payloadText';
    } else {
      payload = 'bytes:${base64Encode(payloadBytes)}';
    }
    return <String>[
      kind.id,
      symbology.id,
      batchSessionId ?? '',
      payload,
    ].join(_keyPart);
  }

  /// The row to write, one entry per column of [tableName].
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'seq': seq,
      'kind': kind.id,
      'source': source.id,
      'symbology': symbology.id,
      'parsed_type': parsedType.id,
      'payload_text': payloadText,
      'payload_bytes': payloadBytes,
      'sensitive_fields': jsonEncode(sensitiveFields),
      'label': label,
      'favourite': favourite ? 1 : 0,
      'duplicate_count': duplicateCount,
      'batch_session_id': batchSessionId,
      'content_json': contentJson,
      'style_json': styleJson,
      'created_at': utcSecondsOf(createdAt),
      'updated_at': utcSecondsOf(updatedAt),
      'deleted_at': _secondsOrNull(deletedAt),
      'last_seen_at': _secondsOrNull(lastSeenAt),
    };
  }

  /// A copy with the given fields replaced.
  ///
  /// The nullable fields take a sentinel, so passing null clears them while
  /// leaving them out keeps them: `copyWith(label: null)` removes a label
  /// (HIS-9) and `copyWith(deletedAt: null)` takes a record out of Trash
  /// (REC-4).
  ScanRecord copyWith({
    String? id,
    int? seq,
    RecordKind? kind,
    RecordSource? source,
    Symbology? symbology,
    ParsedType? parsedType,
    String? payloadText,
    Object? payloadBytes = _keep,
    List<String>? sensitiveFields,
    Object? label = _keep,
    bool? favourite,
    int? duplicateCount,
    Object? batchSessionId = _keep,
    Object? contentJson = _keep,
    Object? styleJson = _keep,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _keep,
    Object? lastSeenAt = _keep,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      symbology: symbology ?? this.symbology,
      parsedType: parsedType ?? this.parsedType,
      payloadText: payloadText ?? this.payloadText,
      payloadBytes: _pick(payloadBytes, this.payloadBytes),
      sensitiveFields: sensitiveFields ?? this.sensitiveFields,
      label: _pick(label, this.label),
      favourite: favourite ?? this.favourite,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      batchSessionId: _pick(batchSessionId, this.batchSessionId),
      contentJson: _pick(contentJson, this.contentJson),
      styleJson: _pick(styleJson, this.styleJson),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: _pick(deletedAt, this.deletedAt),
      lastSeenAt: _pick(lastSeenAt, this.lastSeenAt),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScanRecord &&
        other.id == id &&
        other.seq == seq &&
        other.kind == kind &&
        other.source == source &&
        other.symbology == symbology &&
        other.parsedType == parsedType &&
        other.payloadText == payloadText &&
        _bytesEquality.equals(other.payloadBytes, payloadBytes) &&
        _keysEquality.equals(other.sensitiveFields, sensitiveFields) &&
        other.label == label &&
        other.favourite == favourite &&
        other.duplicateCount == duplicateCount &&
        other.batchSessionId == batchSessionId &&
        other.contentJson == contentJson &&
        other.styleJson == styleJson &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.lastSeenAt == lastSeenAt;
  }

  /// Hashes the fields that tell two rows apart; `==` compares every column.
  @override
  int get hashCode =>
      Object.hash(id, seq, updatedAt, payloadText, duplicateCount);

  /// Describes the row without its payload, label or content: nothing that was
  /// scanned or created may reach a crash report (PRIV-4).
  @override
  String toString() {
    return 'ScanRecord($id, seq: $seq, ${kind.id}, ${parsedType.id}, '
        '${symbology.id}, ×$duplicateCount, deleted: $isDeleted)';
  }

  /// The timestamp a row with no readable `created_at` reads as.
  static DateTime get _unsetTime =>
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Keeps [current] when the caller left a [copyWith] field out.
  static T _pick<T>(Object? given, T current) {
    if (given == _keep) {
      return current;
    }
    return given as T;
  }

  static DateTime? _utcOrNull(DateTime? at) {
    if (at == null) {
      return null;
    }
    return truncatedToUtcSeconds(at);
  }

  static int? _secondsOrNull(DateTime? at) {
    if (at == null) {
      return null;
    }
    return utcSecondsOf(at);
  }

  static String? _stringOf(Object? value) => value is String ? value : null;

  static int? _intOf(Object? value) => switch (value) {
    final int stored => stored,
    final num stored => stored.toInt(),
    final String stored => int.tryParse(stored.trim()),
    _ => null,
  };

  static Uint8List? _bytesOf(Object? value) => switch (value) {
    final Uint8List stored => stored,
    final List<int> stored => Uint8List.fromList(stored),
    _ => null,
  };

  static DateTime? _timeOf(Object? value) {
    final seconds = _intOf(value);
    if (seconds == null) {
      return null;
    }
    return dateTimeFromUtcSeconds(seconds);
  }

  /// Reads the JSON array of masked field keys (DATA-5). A value that is not a
  /// JSON array of strings reads as no masked fields.
  static List<String> _sensitiveFieldsOf(Object? value) {
    final raw = _stringOf(value);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } on FormatException {
      return const <String>[];
    }
    return const <String>[];
  }
}
