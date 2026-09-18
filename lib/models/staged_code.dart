import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'record_enums.dart';

/// The value [StagedCode.copyWith] uses for "leave this field alone", so
/// passing null can mean "clear it". Private, so no caller can pass it.
class _Keep {
  const _Keep();
}

/// One code counted by a batch session in progress: a row of `batch_staging`
/// (DATA-7, SCAN-14).
///
/// Staged codes are the app's crash protection for a long batch, not history:
/// they never appear in History, search, export or backup, and are
/// hard-deleted once the session is saved or discarded (DATA-7). A session left
/// behind by an interrupted batch is offered for review at the next launch
/// (SCAN-14).
///
/// There is no `kind` or `source` column: every staged code is a scan, and the
/// records written when the session is saved carry the source. There is no
/// `seq` either, since staged codes are ordered by when they were first seen.
class StagedCode {
  /// Timestamps are truncated to the whole UTC seconds the schema stores
  /// (DATE-1).
  StagedCode({
    required this.id,
    required this.sessionId,
    required this.symbology,
    required this.parsedType,
    required this.payloadText,
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
    this.payloadBytes,
    this.count = 1,
  }) : firstSeenAt = truncatedToUtcSeconds(firstSeenAt),
       lastSeenAt = truncatedToUtcSeconds(lastSeenAt);

  /// Reads a row of [tableName], mapping an ID this build cannot name to a
  /// fallback rather than throwing (DATA-1).
  ///
  /// The `duplicate_key` column is not read back: [duplicateKey] works it out
  /// from the fields it is built from, so a stored key can never disagree with
  /// the code it stands for.
  factory StagedCode.fromMap(Map<String, Object?> row) {
    return StagedCode(
      id: _stringOf(row['id']) ?? '',
      sessionId: _stringOf(row['session_id']) ?? '',
      symbology: Symbology.fromId(_stringOf(row['symbology'])),
      parsedType: ParsedType.fromId(_stringOf(row['parsed_type'])),
      payloadText: _stringOf(row['payload_text']) ?? '',
      payloadBytes: _bytesOf(row['payload_bytes']),
      count: _intOf(row['count']) ?? 1,
      firstSeenAt: _timeOf(row['first_seen_at']) ?? _unsetTime,
      lastSeenAt: _timeOf(row['last_seen_at']) ?? _unsetTime,
    );
  }

  /// The table staged codes live in.
  static const String tableName = 'batch_staging';

  /// The staged row's UUID v4 (REC-2).
  final String id;

  /// The batch session this code belongs to (DATA-7).
  final String sessionId;

  /// The code format (SCAN-9).
  final Symbology symbology;

  /// What the payload was parsed as (DATA-1).
  final ParsedType parsedType;

  /// The payload as UTF-8 text (DATA-2).
  final String payloadText;

  /// The raw bytes, set only when the payload is not valid UTF-8 (DATA-2).
  /// Treated as read-only.
  final Uint8List? payloadBytes;

  /// How many times the session has seen this code: a code already staged
  /// raises its own count instead of adding a row (SCAN-14).
  final int count;

  /// When the session first saw this code, in UTC, which is the review list's
  /// order (SCAN-14).
  final DateTime firstSeenAt;

  /// When the session last saw this code, in UTC.
  final DateTime lastSeenAt;

  static const ListEquality<int> _bytesEquality = ListEquality<int>();
  static const Object _keep = _Keep();

  /// The separator between the parts of a duplicate key. The payload is the
  /// last part and the parts before it can never carry this character, so two
  /// different codes can never build the same key.
  ///
  /// A unit separator and not a NUL: the key is written to a TEXT column, and a
  /// layer that treated a NUL as the end of the string would cut the key back
  /// to the session and collapse every code in that session into one row
  /// (DATA-7).
  static final String _keyPart = String.fromCharCode(0x1f);

  /// What staging matches on: the session, the format and the raw payload.
  ///
  /// The same key inside one session is the same staged code; the same payload
  /// in another session is a different one (DATA-4, SCAN-14).
  ///
  /// This is the value of the `duplicate_key` column, which the table's unique
  /// index is built on, so the database enforces the same match the DAO looks
  /// up. It folds in the raw bytes, so two non-UTF-8 codes that decode to the
  /// same lossy text are two codes, not one (DATA-2).
  String get duplicateKey => duplicateKeyOf(
    sessionId: sessionId,
    symbology: symbology,
    payloadText: payloadText,
    payloadBytes: payloadBytes,
  );

  /// The key two staged codes must share to be the same code (DATA-7).
  static String duplicateKeyOf({
    required String sessionId,
    required Symbology symbology,
    required String payloadText,
    Uint8List? payloadBytes,
  }) {
    final String payload;
    if (payloadBytes == null) {
      payload = 'text:$payloadText';
    } else {
      payload = 'bytes:${base64Encode(payloadBytes)}';
    }
    return <String>[sessionId, symbology.id, payload].join(_keyPart);
  }

  /// The row to write, one entry per column of [tableName].
  ///
  /// `duplicate_key` is always [duplicateKey], never a value a caller chose, so
  /// the row the unique index sees is the row staging matched on (DATA-7).
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'session_id': sessionId,
      'symbology': symbology.id,
      'parsed_type': parsedType.id,
      'payload_text': payloadText,
      'payload_bytes': payloadBytes,
      'duplicate_key': duplicateKey,
      'count': count,
      'first_seen_at': utcSecondsOf(firstSeenAt),
      'last_seen_at': utcSecondsOf(lastSeenAt),
    };
  }

  /// A copy with the given fields replaced. [payloadBytes] takes a sentinel, so
  /// passing null clears it while leaving it out keeps it.
  StagedCode copyWith({
    String? id,
    String? sessionId,
    Symbology? symbology,
    ParsedType? parsedType,
    String? payloadText,
    Object? payloadBytes = _keep,
    int? count,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) {
    return StagedCode(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      symbology: symbology ?? this.symbology,
      parsedType: parsedType ?? this.parsedType,
      payloadText: payloadText ?? this.payloadText,
      payloadBytes: _pick(payloadBytes, this.payloadBytes),
      count: count ?? this.count,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StagedCode &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.symbology == symbology &&
        other.parsedType == parsedType &&
        other.payloadText == payloadText &&
        _bytesEquality.equals(other.payloadBytes, payloadBytes) &&
        other.count == count &&
        other.firstSeenAt == firstSeenAt &&
        other.lastSeenAt == lastSeenAt;
  }

  /// Hashes the fields that tell two staged rows apart; `==` compares every
  /// column.
  @override
  int get hashCode => Object.hash(id, sessionId, payloadText, count);

  /// Describes the row without its payload: nothing that was scanned may reach
  /// a crash report (PRIV-4).
  @override
  String toString() {
    return 'StagedCode($id, session: $sessionId, ${symbology.id}, '
        '${parsedType.id}, ×$count)';
  }

  /// The timestamp a row with no readable `first_seen_at` reads as.
  static DateTime get _unsetTime =>
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Keeps [current] when the caller left a [copyWith] field out.
  static T _pick<T>(Object? given, T current) {
    if (given == _keep) {
      return current;
    }
    return given as T;
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
}
