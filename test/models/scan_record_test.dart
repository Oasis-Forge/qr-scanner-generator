import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/models/staged_code.dart';

/// Bytes no UTF-8 payload can hold, so a record has to keep them (DATA-2).
final Uint8List _binaryPayload = Uint8List.fromList(<int>[
  0xff,
  0xfe,
  0x00,
  0x41,
]);

ScanRecord _record({
  String id = 'a0b1c2d3-0000-4000-8000-000000000001',
  int seq = 7,
  RecordKind kind = RecordKind.scan,
  RecordSource source = RecordSource.camera,
  Symbology symbology = Symbology.qr,
  ParsedType parsedType = ParsedType.wifi,
  String payloadText = 'WIFI:T:WPA;S:Home;P:hunter2;;',
  Uint8List? payloadBytes,
  List<String> sensitiveFields = SensitiveFieldKeys.all,
  String? label = 'Home network',
  bool favourite = true,
  int duplicateCount = 3,
  String? batchSessionId = 'b0000000-0000-4000-8000-000000000009',
  String? contentJson = '{"ssid":"Home"}',
  String? styleJson = '{"foreground":"#000000"}',
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
  DateTime? lastSeenAt,
}) {
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
    createdAt: createdAt ?? DateTime.utc(2026, 9, 17, 10, 30, 15),
    updatedAt: updatedAt ?? DateTime.utc(2026, 9, 17, 11),
    deletedAt: deletedAt,
    lastSeenAt: lastSeenAt ?? DateTime.utc(2026, 9, 17, 11),
  );
}

StagedCode _staged({
  String id = 'c0000000-0000-4000-8000-000000000001',
  String sessionId = 'session-1',
  Symbology symbology = Symbology.ean13,
  ParsedType parsedType = ParsedType.product,
  String payloadText = '4006381333931',
  Uint8List? payloadBytes,
  int count = 2,
  DateTime? firstSeenAt,
  DateTime? lastSeenAt,
}) {
  return StagedCode(
    id: id,
    sessionId: sessionId,
    symbology: symbology,
    parsedType: parsedType,
    payloadText: payloadText,
    payloadBytes: payloadBytes,
    count: count,
    firstSeenAt: firstSeenAt ?? DateTime.utc(2026, 9, 17, 10),
    lastSeenAt: lastSeenAt ?? DateTime.utc(2026, 9, 17, 10, 0, 40),
  );
}

void main() {
  group('ScanRecord', () {
    test('round-trips every column through toMap and fromMap', () {
      final record = _record();

      expect(ScanRecord.fromMap(record.toMap()), record);
    });

    test('keeps a payload UTF-8 text cannot hold (DATA-2)', () {
      final record = _record(
        parsedType: ParsedType.unknown,
        payloadText: utf8.decode(_binaryPayload, allowMalformed: true),
        payloadBytes: _binaryPayload,
        sensitiveFields: const <String>[],
      );

      final read = ScanRecord.fromMap(record.toMap());

      expect(read.payloadBytes, _binaryPayload);
      expect(read.payloadText, record.payloadText);
      expect(read, record);
    });

    test('writes exactly the columns the schema declares', () {
      expect(_record().toMap().keys.toList(), <String>[
        'id',
        'seq',
        'kind',
        'source',
        'symbology',
        'parsed_type',
        'payload_text',
        'payload_bytes',
        'sensitive_fields',
        'label',
        'favourite',
        'duplicate_count',
        'batch_session_id',
        'content_json',
        'style_json',
        'created_at',
        'updated_at',
        'deleted_at',
        'last_seen_at',
      ]);
    });

    test('stores the fixed IDs and flags, not labels (DATA-1)', () {
      final map = _record(
        kind: RecordKind.created,
        source: RecordSource.sharedImage,
        symbology: Symbology.upcA,
        parsedType: ParsedType.appStore,
        favourite: false,
      ).toMap();

      expect(map['kind'], 'created');
      expect(map['source'], 'shared_image');
      expect(map['symbology'], 'upc_a');
      expect(map['parsed_type'], 'app_store');
      expect(map['favourite'], 0);
      expect(map['sensitive_fields'], '["wifi.password"]');
    });

    test('stores timestamps as whole UTC seconds (DATE-1)', () {
      final record = _record(
        createdAt: DateTime.utc(2026, 9, 17, 10, 30, 15, 750),
        updatedAt: DateTime.utc(2026, 9, 17, 10, 30, 15, 750),
        deletedAt: DateTime.utc(2026, 9, 18),
      );

      expect(record.createdAt, DateTime.utc(2026, 9, 17, 10, 30, 15));
      // Seconds since the epoch, not milliseconds: 2026-09-17 10:30:15 UTC.
      expect(record.toMap()['created_at'], 1789641015);
      expect(record.toMap()['updated_at'], 1789641015);
      expect(record.toMap()['deleted_at'], 1789689600);
    });

    test('writes an unset timestamp as null (DATE-1)', () {
      final record = _record().copyWith(lastSeenAt: null);

      expect(record.toMap()['last_seen_at'], isNull);
      expect(record.toMap()['deleted_at'], isNull);
    });

    test('keeps a local timestamp as the same instant in UTC (DATE-1)', () {
      final local = DateTime(2026, 9, 17, 12, 34, 56);

      final record = _record(createdAt: local);

      expect(record.createdAt.isUtc, isTrue);
      expect(record.createdAt, local.toUtc());
    });

    test('reads an ID this build cannot name as a fallback (DATA-1)', () {
      final map =
          _record(kind: RecordKind.created, source: RecordSource.manual).toMap()
            ..['kind'] = 'imported'
            ..['source'] = 'nfc'
            ..['symbology'] = 'micro_qr'
            ..['parsed_type'] = 'crypto_wallet';

      final read = ScanRecord.fromMap(map);

      expect(read.kind, RecordKind.scan);
      expect(read.source, RecordSource.camera);
      expect(read.symbology, Symbology.unknown);
      expect(read.parsedType, ParsedType.unknown);
    });

    test('reads a sensitive-field list it cannot parse as none (DATA-5)', () {
      final broken = _record().toMap()..['sensitive_fields'] = 'not json';
      final wrongShape = _record().toMap()..['sensitive_fields'] = '{"a":1}';

      expect(ScanRecord.fromMap(broken).sensitiveFields, isEmpty);
      expect(ScanRecord.fromMap(wrongShape).sensitiveFields, isEmpty);
    });

    test('masks the fields the record flags (DATA-5)', () {
      final record = _record(sensitiveFields: SensitiveFieldKeys.all);

      expect(record.isSensitiveField(SensitiveFieldKeys.wifiPassword), isTrue);
      expect(record.isSensitiveField('wifi.ssid'), isFalse);
      expect(record.sensitiveFields, <String>['wifi.password']);
    });

    test('names the masked fields once, for every surface that reads them '
        '(DATA-5, HIS-7, HIS-2, EXP-4)', () {
      // The key is stored in the record, so this is the string already on a
      // tester's phone: it can only change with a migration.
      expect(SensitiveFieldKeys.wifiPassword, 'wifi.password');
      expect(SensitiveFieldKeys.all, <String>['wifi.password']);

      final record = _record(sensitiveFields: SensitiveFieldKeys.all);

      expect(record.toMap()['sensitive_fields'], '["wifi.password"]');
      expect(
        ScanRecord.fromMap(record.toMap()).sensitiveFields,
        SensitiveFieldKeys.all,
      );
    });

    test('refuses to have its sensitive fields changed from outside', () {
      final record = _record();

      expect(
        () => record.sensitiveFields.add('wifi.ssid'),
        throwsUnsupportedError,
      );
    });

    test('is deleted only once deleted_at is set (DEL-1)', () {
      expect(_record().isDeleted, isFalse);
      expect(_record(deletedAt: DateTime.utc(2026, 9, 18)).isDeleted, isTrue);
    });
  });

  group('ScanRecord.copyWith', () {
    test('clears the nullable fields when they are passed as null (REC-4)', () {
      final record = _record(
        payloadBytes: _binaryPayload,
        deletedAt: DateTime.utc(2026, 9, 18),
      );

      final cleared = record.copyWith(
        label: null,
        deletedAt: null,
        lastSeenAt: null,
        batchSessionId: null,
        payloadBytes: null,
        contentJson: null,
        styleJson: null,
      );

      expect(cleared.label, isNull);
      expect(cleared.deletedAt, isNull);
      expect(cleared.isDeleted, isFalse);
      expect(cleared.lastSeenAt, isNull);
      expect(cleared.batchSessionId, isNull);
      expect(cleared.payloadBytes, isNull);
      expect(cleared.contentJson, isNull);
      expect(cleared.styleJson, isNull);
      expect(cleared.payloadText, record.payloadText);
    });

    test('keeps every field the caller leaves out', () {
      final record = _record(payloadBytes: _binaryPayload);

      expect(record.copyWith(), record);
    });

    test('replaces one field and leaves the rest alone (HIS-5)', () {
      final record = _record(duplicateCount: 1);

      final bumped = record.copyWith(
        duplicateCount: 2,
        lastSeenAt: DateTime.utc(2026, 9, 17, 12),
      );

      expect(bumped.duplicateCount, 2);
      expect(bumped.lastSeenAt, DateTime.utc(2026, 9, 17, 12));
      expect(bumped.createdAt, record.createdAt);
      expect(bumped.source, record.source);
      expect(bumped.label, record.label);
      expect(bumped.favourite, record.favourite);
    });
  });

  group('ScanRecord.duplicateKey (DATA-4)', () {
    test('matches the same kind, format and payload', () {
      final first = _record(id: 'one', seq: 1, batchSessionId: null);
      final second = _record(
        id: 'two',
        seq: 2,
        batchSessionId: null,
        label: 'Another label',
        favourite: false,
        duplicateCount: 9,
        source: RecordSource.manual,
      );

      expect(second.duplicateKey, first.duplicateKey);
    });

    test('separates a scan from a created code', () {
      final scanned = _record(kind: RecordKind.scan, batchSessionId: null);
      final made = _record(kind: RecordKind.created, batchSessionId: null);

      expect(made.duplicateKey, isNot(scanned.duplicateKey));
    });

    test('separates two formats carrying the same text', () {
      final ean = _record(symbology: Symbology.ean13, batchSessionId: null);
      final qr = _record(symbology: Symbology.qr, batchSessionId: null);

      expect(qr.duplicateKey, isNot(ean.duplicateKey));
    });

    test(
      'separates a payload kept as bytes from one kept as text (DATA-2)',
      () {
        final text = _record(batchSessionId: null, payloadText: 'AAA=');
        final bytes = _record(
          batchSessionId: null,
          payloadText: 'AAA=',
          payloadBytes: _binaryPayload,
        );

        expect(bytes.duplicateKey, isNot(text.duplicateKey));
      },
    );

    test('separates codes saved from different batches (SCAN-14)', () {
      final single = _record(batchSessionId: null);
      final batchOne = _record(batchSessionId: 'session-1');
      final batchTwo = _record(batchSessionId: 'session-2');

      expect(batchOne.duplicateKey, isNot(single.duplicateKey));
      expect(batchTwo.duplicateKey, isNot(batchOne.duplicateKey));
    });
  });

  group('ScanRecord.toString', () {
    test('leaves the payload, label and content out (PRIV-4)', () {
      final described = _record().toString();

      expect(described, contains('a0b1c2d3-0000-4000-8000-000000000001'));
      expect(described, contains('wifi'));
      expect(described, isNot(contains('hunter2')));
      expect(described, isNot(contains('Home network')));
      expect(described, isNot(contains('"ssid"')));
    });
  });

  group('StagedCode (DATA-7)', () {
    test('round-trips every column through toMap and fromMap', () {
      final staged = _staged();

      expect(StagedCode.fromMap(staged.toMap()), staged);
    });

    test('writes exactly the columns the schema declares', () {
      expect(_staged().toMap().keys.toList(), <String>[
        'id',
        'session_id',
        'symbology',
        'parsed_type',
        'payload_text',
        'payload_bytes',
        'duplicate_key',
        'count',
        'first_seen_at',
        'last_seen_at',
      ]);
    });

    test('writes the key the staging table matches a code on (DATA-7)', () {
      final staged = _staged();

      expect(staged.toMap()['duplicate_key'], staged.duplicateKey);
      expect(staged.duplicateKey.split(String.fromCharCode(0x1f)), <String>[
        'session-1',
        'ean13',
        'text:4006381333931',
      ]);
      // A NUL would let a layer that stops at one cut the key back to the
      // session and collapse the whole session into one row (DATA-7).
      expect(staged.duplicateKey, isNot(contains(String.fromCharCode(0))));
    });

    test('keys two binary codes whose lossy text is the same apart '
        '(DATA-2, DATA-4)', () {
      final firstBytes = Uint8List.fromList(<int>[0xff, 0x41]);
      final secondBytes = Uint8List.fromList(<int>[0xfe, 0x41]);
      final lossyText = utf8.decode(firstBytes, allowMalformed: true);
      expect(utf8.decode(secondBytes, allowMalformed: true), lossyText);

      final first = _staged(
        payloadText: lossyText,
        payloadBytes: firstBytes,
      ).toMap();
      final second = _staged(
        payloadText: lossyText,
        payloadBytes: secondBytes,
      ).toMap();

      expect(first['payload_text'], second['payload_text']);
      expect(second['duplicate_key'], isNot(first['duplicate_key']));
    });

    test('keeps a payload UTF-8 text cannot hold (DATA-2)', () {
      final staged = _staged(
        symbology: Symbology.qr,
        parsedType: ParsedType.unknown,
        payloadText: utf8.decode(_binaryPayload, allowMalformed: true),
        payloadBytes: _binaryPayload,
      );

      final read = StagedCode.fromMap(staged.toMap());

      expect(read.payloadBytes, _binaryPayload);
      expect(read, staged);
    });

    test('stores timestamps as whole UTC seconds (DATE-1)', () {
      final staged = _staged(
        firstSeenAt: DateTime.utc(2026, 9, 17, 10, 0, 0, 900),
        lastSeenAt: DateTime.utc(2026, 9, 17, 10, 0, 40, 900),
      );

      expect(staged.firstSeenAt, DateTime.utc(2026, 9, 17, 10));
      expect(staged.toMap()['first_seen_at'], 1789639200);
      expect(staged.toMap()['last_seen_at'], 1789639240);
    });

    test('copyWith clears the bytes and keeps the rest', () {
      final staged = _staged(payloadBytes: _binaryPayload);

      final cleared = staged.copyWith(payloadBytes: null);

      expect(cleared.payloadBytes, isNull);
      expect(cleared.payloadText, staged.payloadText);
      expect(staged.copyWith(), staged);
    });

    test('matches the same code inside one session only (SCAN-14)', () {
      final first = _staged(id: 'one', count: 1);
      final again = _staged(id: 'two', count: 5);
      final other = _staged(id: 'three', sessionId: 'session-2');

      expect(again.duplicateKey, first.duplicateKey);
      expect(other.duplicateKey, isNot(first.duplicateKey));
    });

    test('toString leaves the payload out (PRIV-4)', () {
      expect(_staged().toString(), isNot(contains('4006381333931')));
    });
  });
}
