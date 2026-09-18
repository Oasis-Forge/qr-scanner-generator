import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/models/staged_code.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A UUID v4: 8-4-4-4-12 hex digits, with the version and variant nibbles the
/// standard fixes (REC-2).
final RegExp _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// Bytes no UTF-8 payload can hold (DATA-2).
final Uint8List _binary = Uint8List.fromList(<int>[0xff, 0xfe, 0x00, 0x41]);
final Uint8List _otherBinary = Uint8List.fromList(<int>[
  0xff,
  0xfe,
  0x00,
  0x42,
]);

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase app;
  late RecordDao dao;
  late DateTime clock;

  setUp(() async {
    app = AppDatabase.inMemory(
      runner: MigrationRunner(migrationSteps),
      databaseFactory: databaseFactoryFfi,
    );
    await app.open();
    clock = DateTime.utc(2026, 9, 17, 10, 30, 15);
    dao = RecordDao(app, now: () => clock);
  });

  tearDown(() => app.close());

  /// Moves the clock on, so a later write lands in another second (DATE-1).
  void tick([int seconds = 60]) {
    clock = clock.add(Duration(seconds: seconds));
  }

  Future<ScanRecord> insertLink(String payload) {
    return dao.insert(
      kind: RecordKind.scan,
      source: RecordSource.camera,
      symbology: Symbology.qr,
      parsedType: ParsedType.url,
      payloadText: payload,
    );
  }

  Future<RecordWrite> scanLink(
    String payload, {
    RecordKind kind = RecordKind.scan,
    RecordSource source = RecordSource.camera,
    Symbology symbology = Symbology.qr,
    Uint8List? payloadBytes,
    String? batchSessionId,
  }) {
    return dao.recordScan(
      kind: kind,
      source: source,
      symbology: symbology,
      parsedType: ParsedType.url,
      payloadText: payload,
      payloadBytes: payloadBytes,
      batchSessionId: batchSessionId,
    );
  }

  Future<List<String>> livePayloads() async {
    final live = await dao.liveRecords();
    return live.map((record) => record.payloadText).toList(growable: false);
  }

  group('insert', () {
    test('gives every record a UUID v4 (REC-2)', () async {
      final first = await insertLink('https://example.com');
      final second = await insertLink('https://example.org');

      expect(first.id, matches(_uuidV4));
      expect(second.id, matches(_uuidV4));
      expect(second.id, isNot(first.id));
    });

    test('stores the record the caller reads back', () async {
      final record = await dao.insert(
        kind: RecordKind.scan,
        source: RecordSource.manual,
        symbology: Symbology.qr,
        parsedType: ParsedType.wifi,
        payloadText: 'WIFI:T:WPA;S:Home;P:hunter2;;',
        sensitiveFields: SensitiveFieldKeys.all,
      );

      expect(await dao.findById(record.id), record);
      final row = (await app.database.query('records')).single;
      expect(row['source'], 'manual');
      expect(row['parsed_type'], 'wifi');
      expect(row['sensitive_fields'], '["wifi.password"]');
      expect(row['payload_text'], 'WIFI:T:WPA;S:Home;P:hunter2;;');
    });

    test('sets created_at, updated_at and last_seen_at to the write time '
        '(REC-1, HIS-1)', () async {
      final record = await insertLink('https://example.com');

      expect(record.createdAt, clock);
      expect(record.updatedAt, clock);
      expect(record.lastSeenAt, clock);
      final row = (await app.database.query('records')).single;
      expect(row['created_at'], utcSecondsOf(clock));
      expect(row['updated_at'], utcSecondsOf(clock));
      expect(row['last_seen_at'], utcSecondsOf(clock));
    });

    test('orders two records written in the same second by seq '
        '(DATE-1)', () async {
      final first = await insertLink('first');
      final second = await insertLink('second');

      expect(second.createdAt, first.createdAt);
      expect(<int>[first.seq, second.seq], <int>[1, 2]);
      expect(await livePayloads(), <String>['second', 'first']);
    });

    test('keeps a created code as content and style, never an image '
        '(DATA-3)', () async {
      final record = await dao.insert(
        kind: RecordKind.created,
        source: RecordSource.created,
        symbology: Symbology.qr,
        parsedType: ParsedType.url,
        payloadText: 'https://example.com',
        contentJson: '{"url":"https://example.com"}',
        styleJson: '{"foreground":"#000000"}',
      );

      final stored = await dao.findById(record.id);
      expect(stored?.contentJson, '{"url":"https://example.com"}');
      expect(stored?.styleJson, '{"foreground":"#000000"}');
      expect(stored?.kind, RecordKind.created);
    });

    test('keeps a payload UTF-8 text cannot hold (DATA-2)', () async {
      final record = await dao.insert(
        kind: RecordKind.scan,
        source: RecordSource.camera,
        symbology: Symbology.dataMatrix,
        parsedType: ParsedType.unknown,
        payloadText: '',
        payloadBytes: _binary,
      );

      expect((await dao.findById(record.id))?.payloadBytes, _binary);
    });
  });

  group('recordScan (DATA-4)', () {
    test('bumps a live duplicate and leaves created_at and source '
        'alone', () async {
      final first = await scanLink('https://example.com');
      tick();

      final again = await scanLink(
        'https://example.com',
        source: RecordSource.manual,
      );

      expect(first.isDuplicate, isFalse);
      expect(again.isDuplicate, isTrue);
      expect(again.record.id, first.record.id);
      expect(again.record.duplicateCount, 2);
      expect(again.record.lastSeenAt, clock);
      expect(again.record.updatedAt, clock);
      expect(again.record.createdAt, first.record.createdAt);
      expect(again.record.source, RecordSource.camera);
      expect(await dao.findById(first.record.id), again.record);
      expect(await dao.liveRecords(), hasLength(1));
    });

    test('moves the row it bumped to the top of History (HIS-5)', () async {
      await scanLink('https://first.example');
      tick();
      await scanLink('https://second.example');
      tick();

      await scanLink('https://first.example');

      expect(await livePayloads(), <String>[
        'https://first.example',
        'https://second.example',
      ]);
    });

    test('keeps the label and the star of the row it bumps (HIS-5)', () async {
      final first = await scanLink('https://example.com');
      await dao.updateLabel(first.record.id, label: 'Work login');
      await dao.setFavourite(first.record.id, favourite: true);
      tick();

      final again = await scanLink('https://example.com');

      expect(again.record.label, 'Work login');
      expect(again.record.favourite, isTrue);
      expect(again.record.duplicateCount, 2);
    });

    test('writes a new record when only a deleted one matches '
        '(DEL-1)', () async {
      final first = await scanLink('https://example.com');
      await dao.softDelete(first.record.id);
      tick();

      final second = await scanLink('https://example.com');

      expect(second.isDuplicate, isFalse);
      expect(second.record.id, isNot(first.record.id));
      expect(second.record.duplicateCount, 1);
      expect((await dao.findById(first.record.id))?.isDeleted, isTrue);
      expect(await dao.liveRecords(), hasLength(1));
    });

    test('gives the row it bumps a fresh seq, so it outranks a record written '
        'in the same second (DATE-1, HIS-5)', () async {
      final first = await scanLink('https://first.example');
      final second = await scanLink('https://second.example');

      final again = await scanLink('https://first.example');

      expect(again.isDuplicate, isTrue);
      // Same second, so only the sequence can put the bumped row on top.
      expect(again.record.lastSeenAt, second.record.lastSeenAt);
      expect(again.record.seq, greaterThan(second.record.seq));
      expect((await dao.findById(first.record.id))?.seq, again.record.seq);
      expect(await livePayloads(), <String>[
        'https://first.example',
        'https://second.example',
      ]);
    });

    test('merges two created codes carrying the same content', () async {
      final made = await scanLink(
        'https://example.com',
        kind: RecordKind.created,
        source: RecordSource.created,
      );
      tick();

      final again = await scanLink(
        'https://example.com',
        kind: RecordKind.created,
        source: RecordSource.created,
      );

      expect(again.isDuplicate, isTrue);
      expect(again.record.id, made.record.id);
      expect(again.record.duplicateCount, 2);
      expect(again.record.kind, RecordKind.created);
      expect(again.record.createdAt, made.record.createdAt);
      expect(await dao.liveRecords(), hasLength(1));
    });

    test('never merges a scan with a created code', () async {
      await scanLink('https://example.com');
      tick();

      final made = await scanLink(
        'https://example.com',
        kind: RecordKind.created,
        source: RecordSource.created,
      );

      expect(made.isDuplicate, isFalse);
      expect(await dao.liveRecords(), hasLength(2));
    });

    test('never merges two formats carrying the same text', () async {
      await scanLink('4006381333931', symbology: Symbology.ean13);
      tick();

      final other = await scanLink(
        '4006381333931',
        symbology: Symbology.code128,
      );

      expect(other.isDuplicate, isFalse);
      expect(await dao.liveRecords(), hasLength(2));
    });

    test('never merges codes counted in different batches (SCAN-14)', () async {
      await scanLink('https://example.com', batchSessionId: 'session-1');
      tick();

      final other = await scanLink(
        'https://example.com',
        batchSessionId: 'session-2',
      );

      expect(other.isDuplicate, isFalse);
      expect(await dao.liveRecords(), hasLength(2));
    });

    test('merges a code seen again inside its own batch (SCAN-14)', () async {
      final first = await scanLink(
        'https://example.com',
        batchSessionId: 'session-1',
      );
      tick();

      final again = await scanLink(
        'https://example.com',
        batchSessionId: 'session-1',
      );

      expect(again.isDuplicate, isTrue);
      expect(again.record.id, first.record.id);
      expect(again.record.duplicateCount, 2);
    });

    test('never merges a batch code with a single scan (SCAN-14)', () async {
      await scanLink('https://example.com');
      tick();
      final batched = await scanLink(
        'https://example.com',
        batchSessionId: 'session-1',
      );
      tick();

      final single = await scanLink('https://example.com');

      expect(batched.isDuplicate, isFalse);
      expect(single.isDuplicate, isTrue);
      expect(single.record.batchSessionId, isNull);
      expect(await dao.liveRecords(), hasLength(2));
    });

    test('never merges payloads whose raw bytes differ (DATA-2)', () async {
      final first = await scanLink('', payloadBytes: _binary);
      tick();

      final other = await scanLink('', payloadBytes: _otherBinary);
      final same = await scanLink('', payloadBytes: _binary);

      expect(other.isDuplicate, isFalse);
      expect(same.isDuplicate, isTrue);
      expect(same.record.id, first.record.id);
      expect(await dao.liveRecords(), hasLength(2));
    });
  });

  group('Trash', () {
    test('a delete sets deleted_at and bumps updated_at (DEL-1)', () async {
      final record = await insertLink('https://example.com');
      tick();

      final deleted = await dao.softDelete(record.id);

      expect(deleted?.deletedAt, clock);
      expect(deleted?.updatedAt, clock);
      expect(deleted?.isDeleted, isTrue);
      expect(deleted?.createdAt, record.createdAt);
    });

    test('a deleted record is absent from the live list (DEL-1)', () async {
      final record = await insertLink('https://example.com');
      await insertLink('https://kept.example');

      await dao.softDelete(record.id);

      expect(await livePayloads(), <String>['https://kept.example']);
      expect(await dao.findById(record.id), isNotNull);
    });

    test('a restore clears deleted_at and bumps updated_at (REC-4)', () async {
      final record = await insertLink('https://example.com');
      await dao.softDelete(record.id);
      tick();

      final restored = await dao.restore(record.id);

      expect(restored?.deletedAt, isNull);
      expect(restored?.isDeleted, isFalse);
      expect(restored?.updatedAt, clock);
      expect(await livePayloads(), <String>['https://example.com']);
    });

    test('several records go in one write, with the count (DEL-2)', () async {
      final first = await insertLink('https://first.example');
      final second = await insertLink('https://second.example');
      await insertLink('https://kept.example');

      final changed = await dao.softDeleteAll(<String>[first.id, second.id]);

      expect(changed, 2);
      expect(await livePayloads(), <String>['https://kept.example']);
      expect(await dao.restoreAll(<String>[first.id, second.id]), 2);
      expect(await dao.liveRecords(), hasLength(3));
    });

    test('a record already in Trash is not touched again (REC-3)', () async {
      final record = await insertLink('https://example.com');
      final deleted = await dao.softDelete(record.id);
      tick();

      expect(await dao.softDelete(record.id), isNull);
      expect((await dao.findById(record.id))?.updatedAt, deleted?.updatedAt);
    });

    test('a record that is not in Trash is not restored (REC-3)', () async {
      final record = await insertLink('https://example.com');
      tick();

      expect(await dao.restore(record.id), isNull);
      expect((await dao.findById(record.id))?.updatedAt, record.updatedAt);
    });

    test('an unknown ID changes nothing', () async {
      await insertLink('https://example.com');

      expect(await dao.softDelete('no-such-record'), isNull);
      expect(await dao.restore('no-such-record'), isNull);
      expect(await dao.softDeleteAll(const <String>[]), 0);
      expect(await dao.liveRecords(), hasLength(1));
    });
  });

  group('label and star (HIS-9)', () {
    test('a label is set, then cleared, and updated_at follows '
        '(REC-3)', () async {
      final record = await insertLink('https://example.com');
      tick();

      final labelled = await dao.updateLabel(record.id, label: 'Work login');
      tick();
      final cleared = await dao.updateLabel(record.id, label: null);

      expect(labelled?.label, 'Work login');
      expect(cleared?.label, isNull);
      expect(cleared?.updatedAt, clock);
      expect((await app.database.query('records')).single['label'], isNull);
    });

    test('a star is stored as 1 and 0', () async {
      final record = await insertLink('https://example.com');

      final starred = await dao.setFavourite(record.id, favourite: true);
      expect(starred?.favourite, isTrue);
      expect((await app.database.query('records')).single['favourite'], 1);

      final unstarred = await dao.setFavourite(record.id, favourite: false);
      expect(unstarred?.favourite, isFalse);
      expect((await app.database.query('records')).single['favourite'], 0);
    });

    test('a label leaves the content alone (REC-3)', () async {
      final record = await insertLink('https://example.com');
      tick();

      final labelled = await dao.updateLabel(record.id, label: 'Work login');

      expect(labelled?.payloadText, record.payloadText);
      expect(labelled?.symbology, record.symbology);
      expect(labelled?.parsedType, record.parsedType);
      expect(labelled?.source, record.source);
      expect(labelled?.createdAt, record.createdAt);
    });

    test('a record that does not exist reads back as null', () async {
      expect(await dao.updateLabel('no-such-record', label: 'x'), isNull);
      expect(await dao.setFavourite('no-such-record', favourite: true), isNull);
      expect(await dao.findById('no-such-record'), isNull);
    });
  });

  group('batch staging (DATA-7)', () {
    Future<StagedCode> stage(String payload, {String sessionId = 'session-1'}) {
      return dao.stageCode(
        sessionId: sessionId,
        symbology: Symbology.ean13,
        parsedType: ParsedType.product,
        payloadText: payload,
      );
    }

    /// Stages a code UTF-8 cannot hold: the text is the lossy decoding every
    /// such code shares, so only the raw bytes tell two of them apart (DATA-2).
    Future<StagedCode> stageBinary(Uint8List bytes) {
      return dao.stageCode(
        sessionId: 'session-1',
        symbology: Symbology.dataMatrix,
        parsedType: ParsedType.unknown,
        payloadText: utf8.decode(bytes, allowMalformed: true),
        payloadBytes: bytes,
      );
    }

    test('stages a code, then raises the count of the one already there '
        '(SCAN-14)', () async {
      final first = await dao.stageCode(
        sessionId: 'session-1',
        symbology: Symbology.ean13,
        parsedType: ParsedType.product,
        payloadText: '4006381333931',
      );
      tick(10);

      final again = await dao.stageCode(
        sessionId: 'session-1',
        symbology: Symbology.ean13,
        parsedType: ParsedType.product,
        payloadText: '4006381333931',
      );

      expect(first.count, 1);
      expect(again.id, first.id);
      expect(again.count, 2);
      expect(again.lastSeenAt, clock);
      expect(again.firstSeenAt, first.firstSeenAt);
      final staged = await dao.stagedCodes('session-1');
      expect(staged.single, again);
    });

    test('lists the codes of a session in the order they were first '
        'seen', () async {
      await stage('first');
      tick(5);
      await stage('second');
      tick(5);
      await stage('third');

      final staged = await dao.stagedCodes('session-1');

      expect(staged.map((code) => code.payloadText).toList(), <String>[
        'first',
        'second',
        'third',
      ]);
    });

    test('keeps two binary codes whose lossy text is the same apart '
        '(DATA-2, DATA-4)', () async {
      final firstBytes = Uint8List.fromList(<int>[0xff, 0x41]);
      final secondBytes = Uint8List.fromList(<int>[0xfe, 0x41]);
      expect(
        utf8.decode(secondBytes, allowMalformed: true),
        utf8.decode(firstBytes, allowMalformed: true),
      );

      final first = await stageBinary(firstBytes);
      final second = await stageBinary(secondBytes);
      final firstAgain = await stageBinary(firstBytes);

      expect(second.id, isNot(first.id));
      expect(firstAgain.id, first.id);
      expect(firstAgain.count, 2);
      final staged = await dao.stagedCodes('session-1');
      expect(staged, hasLength(2));
      expect(
        staged.map((code) => code.payloadBytes?.toList()).toList(),
        containsAll(<List<int>>[
          <int>[0xff, 0x41],
          <int>[0xfe, 0x41],
        ]),
      );
      expect(staged.map((code) => code.count).toList()..sort(), <int>[1, 2]);
    });

    test('keeps two codes staged in the same second apart (SCAN-14)', () async {
      final first = await stage('4006381333931');
      final second = await stage('5901234123457');

      expect(second.firstSeenAt, first.firstSeenAt);
      final staged = await dao.stagedCodes('session-1');
      expect(staged.map((code) => code.payloadText).toSet(), <String>{
        '4006381333931',
        '5901234123457',
      });
      expect(staged.map((code) => code.count).toList(), <int>[1, 1]);
    });

    test('keeps two sessions apart', () async {
      await stage('4006381333931');
      await stage('4006381333931', sessionId: 'session-2');

      expect(await dao.stagedCodes('session-1'), hasLength(1));
      expect(await dao.stagedCodes('session-2'), hasLength(1));
      expect((await dao.stagedCodes('session-1')).single.count, 1);
    });

    test('staged codes never reach History', () async {
      await insertLink('https://example.com');

      await stage('4006381333931');

      expect(await livePayloads(), <String>['https://example.com']);
    });

    test('hard-deletes a session once it is saved or discarded', () async {
      await stage('first');
      await stage('second');
      await stage('other', sessionId: 'session-2');

      expect(await dao.deleteStagedSession('session-1'), 2);

      expect(await dao.stagedCodes('session-1'), isEmpty);
      expect(await dao.stagedCodes('session-2'), hasLength(1));
      expect(await dao.stagedSessionIds(), <String>['session-2']);
    });

    test('lists the sessions an interrupted batch left behind, oldest first '
        '(SCAN-14)', () async {
      // The IDs run the other way round alphabetically, so this order can only
      // come from when each session started.
      await stage('first', sessionId: 'zulu-session');
      tick(30);
      await stage('other', sessionId: 'alpha-session');

      expect(await dao.stagedSessionIds(), <String>[
        'zulu-session',
        'alpha-session',
      ]);
    });
  });
}
