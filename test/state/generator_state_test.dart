import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/generator/file_naming.dart';
import 'package:qrscanner/generator/generator_form.dart';
import 'package:qrscanner/generator/qr_capacity.dart';
import 'package:qrscanner/models/parsed_payload.dart' show WifiSecurity;
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/state/generator_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../helpers/database.dart';
import '../helpers/fake_stores.dart';

/// An [ImageDecoder] whose result can be changed after construction, unlike
/// [NoopImageDecoder]'s fixed one — so one instance, built once in `setUp`,
/// can be seeded differently by each test without losing whatever the form
/// already holds by the time it needs to seed the check.
class _SeedableImageDecoder implements ImageDecoder {
  ImageDecodeResult result = const ImageDecodeResult.noCodeFound();

  final List<String> calls = <String>[];

  @override
  Future<ImageDecodeResult> decodeFile(String path) async {
    calls.add(path);
    return result;
  }
}

/// A [RecordDao] whose scan writes all fail, as a full or locked database
/// would — the same shape `scanner_state_test.dart` uses for the identical
/// scenario.
class _FailingRecordDao extends RecordDao {
  _FailingRecordDao(super.database);

  int attempts = 0;

  @override
  Future<RecordWrite> recordScan({
    required RecordKind kind,
    required RecordSource source,
    required Symbology symbology,
    required ParsedType parsedType,
    required String payloadText,
    Uint8List? payloadBytes,
    List<String> sensitiveFields = const <String>[],
    String? batchSessionId,
    String? contentJson,
    String? styleJson,
    DateTime? at,
  }) async {
    attempts++;
    throw StateError('the database refused the write');
  }
}

void main() {
  late TestDatabase db;
  late FakeKeyValueStore store;
  late SettingsState settings;
  late SuccessCounts counts;
  late _SeedableImageDecoder imageDecoder;
  late NoopShareService shareService;
  late DateTime clock;
  late GeneratorState state;

  /// A [GeneratorState] wired to the fakes above, with a real temp
  /// directory (the host's own — `path_provider` needs a platform channel
  /// this test process doesn't have, but STY-5's own scratch file needs no
  /// plugin at all: `dart:io` writes it directly).
  GeneratorState buildState({RecordDao? recordDao}) => GeneratorState(
    recordDao: recordDao ?? db.records,
    settings: settings,
    successCounts: counts,
    imageDecoder: imageDecoder,
    shareService: shareService,
    now: () => clock,
    tempDirectory: () async => Directory.systemTemp,
  );

  /// Seeds [imageDecoder] so STY-5's check passes for exactly [payload].
  void seedMatchingCheck(String payload) {
    imageDecoder.result = ImageDecodeResult(<CodeDetection>[
      CodeDetection(payload: payload, symbology: Symbology.qr.id),
    ]);
  }

  setUp(() async {
    clock = fixtureTime;
    db = await openTestDatabase(now: () => clock);
    store = FakeKeyValueStore();
    settings = SettingsState(store);
    await settings.load();
    counts = SuccessCounts(store);
    await counts.load();
    imageDecoder = _SeedableImageDecoder();
    shareService = NoopShareService();
    state = buildState();
  });

  tearDown(() {
    state.dispose();
    settings.dispose();
    counts.dispose();
  });

  group('starting state (GEN-1)', () {
    test('opens on URL with a blank, invalid form', () {
      expect(state.type, ParsedType.url);
      expect(state.form, isA<UrlForm>());
      expect(state.fieldErrors, isNotEmpty);
      expect(state.canCreate, isFalse);
      expect(state.renderedPng, isNull);
      expect(state.checkError, isNull);
      expect(state.canSaveOrShare, isFalse);
    });
  });

  group('setType (GEN-1)', () {
    test('switches to a blank form of the new type', () {
      state.setType(ParsedType.wifi);

      expect(state.type, ParsedType.wifi);
      expect(state.form, isA<WifiForm>());
    });

    test('does nothing when the type is already selected', () {
      state.updateUrl('example.com');
      state.setType(ParsedType.url);

      expect((state.form as UrlForm).rawInput, 'example.com');
    });

    test('notifies listeners', () {
      int notifications = 0;
      state.addListener(() => notifications++);

      state.setType(ParsedType.text);

      expect(notifications, 1);
    });

    test(
      'clears a code create() had rendered, since it was the old type',
      () async {
        state.setType(ParsedType.text);
        state.updateText('hello');
        seedMatchingCheck('hello');
        await state.create();
        expect(state.canSaveOrShare, isTrue);

        state.setType(ParsedType.url);

        expect(state.renderedPng, isNull);
        expect(state.checkError, isNull);
        expect(state.canSaveOrShare, isFalse);
      },
    );

    test('picking the same type again after a create returns to its form, '
        'fields kept (GEN-1)', () async {
      state.setType(ParsedType.text);
      state.updateText('hello');
      seedMatchingCheck('hello');
      await state.create();
      expect(state.renderedPng, isNotNull);

      state.setType(ParsedType.text);

      expect(state.renderedPng, isNull);
      expect(state.checkError, isNull);
      expect((state.form as TextForm).text, 'hello');
    });
  });

  group('backToForm (GEN-1)', () {
    test('leaves a created code for its form, fields kept', () async {
      state.setType(ParsedType.text);
      state.updateText('hello');
      seedMatchingCheck('hello');
      await state.create();

      state.backToForm();

      expect(state.renderedPng, isNull);
      expect(state.canSaveOrShare, isFalse);
      expect((state.form as TextForm).text, 'hello');
    });

    test('leaves a failed create for its form', () async {
      state.setType(ParsedType.text);
      state.updateText('hello');
      await state.create();
      expect(state.checkError, QrCreateError.decodeFailed);

      state.backToForm();

      expect(state.checkError, isNull);
      expect((state.form as TextForm).text, 'hello');
    });

    test('does nothing and notifies nobody on a form', () {
      int notifications = 0;
      state.addListener(() => notifications++);

      state.backToForm();

      expect(notifications, 0);
    });
  });

  group('update* setters', () {
    test('updateUrl fills the URL form', () {
      state.updateUrl('example.com');
      expect((state.form as UrlForm).rawInput, 'example.com');
      expect(state.canCreate, isTrue);
    });

    test('updateWifiSsid, updateWifiSecurity, updateWifiPassword and '
        'updateWifiHidden all fill the Wi-Fi form (GEN-5)', () {
      state.setType(ParsedType.wifi);
      state.updateWifiSsid('Home');
      state.updateWifiSecurity(WifiSecurity.wep);
      state.updateWifiPassword('secret');
      state.updateWifiHidden(hidden: true);

      final WifiForm form = state.form as WifiForm;
      expect(form.ssid, 'Home');
      expect(form.security, WifiSecurity.wep);
      expect(form.password, 'secret');
      expect(form.hidden, isTrue);
    });

    test('updateContact* fields all fill the Contact form (GEN-6)', () {
      state.setType(ParsedType.contact);
      state.updateContactName('Ada');
      state.updateContactPhone('+12025550102');
      state.updateContactEmail('ada@example.com');
      state.updateContactOrganisation('Analytical Engines');

      final ContactForm form = state.form as ContactForm;
      expect(form.name, 'Ada');
      expect(form.phone, '+12025550102');
      expect(form.email, 'ada@example.com');
      expect(form.organisation, 'Analytical Engines');
    });

    test('updateEmailTo/Subject/Body fill the Email form (GEN-8)', () {
      state.setType(ParsedType.email);
      state.updateEmailTo('a@example.com');
      state.updateEmailSubject('Hi');
      state.updateEmailBody('Body text');

      final EmailForm form = state.form as EmailForm;
      expect(form.to, 'a@example.com');
      expect(form.subject, 'Hi');
      expect(form.body, 'Body text');
    });

    test('updateSmsNumber/Message fill the SMS form (GEN-8)', () {
      state.setType(ParsedType.sms);
      state.updateSmsNumber('+12025550102');
      state.updateSmsMessage('hi there');

      final SmsForm form = state.form as SmsForm;
      expect(form.number, '+12025550102');
      expect(form.message, 'hi there');
    });

    test('updatePhoneNumber fills the Phone form (GEN-7)', () {
      state.setType(ParsedType.phone);
      state.updatePhoneNumber('+12025550102');

      expect((state.form as PhoneForm).number, '+12025550102');
    });

    test('updateText fills the Text form', () {
      state.setType(ParsedType.text);
      state.updateText('hello');

      expect((state.form as TextForm).text, 'hello');
    });
  });

  group('capacity (GEN-12)', () {
    test('below 80% shows no meter', () {
      state.setType(ParsedType.text);
      state.updateText('x' * (qrMaxCapacityBytes ~/ 2));

      expect(state.showsCapacityMeter, isFalse);
      expect(state.isOverCapacity, isFalse);
      expect(state.canCreate, isTrue);
    });

    test('above 80% shows the meter but still allows Create', () {
      state.setType(ParsedType.text);
      state.updateText('x' * (qrMaxCapacityBytes * 9 ~/ 10));

      expect(state.showsCapacityMeter, isTrue);
      expect(state.isOverCapacity, isFalse);
      expect(state.canCreate, isTrue);
    });

    test('over the limit blocks Create', () {
      state.setType(ParsedType.text);
      state.updateText('x' * (qrMaxCapacityBytes + 1));

      expect(state.isOverCapacity, isTrue);
      expect(state.canCreate, isFalse);
    });

    test('content is never truncated: over the limit still reports the '
        'full length, not a shortened one', () {
      final String longText = 'x' * (qrMaxCapacityBytes + 500);
      state.setType(ParsedType.text);
      state.updateText(longText);

      expect(state.encodedPayload, longText);
      expect(state.payloadByteLength, qrMaxCapacityBytes + 500);
      expect(state.isOverCapacity, isTrue);
      expect(state.canCreate, isFalse);
    });

    test('an invalid form reports zero bytes, not a stale payload', () {
      state.setType(ParsedType.wifi); // SSID required, currently empty
      expect(state.payloadByteLength, 0);
      expect(state.capacityRatio, 0);
    });
  });

  group('create (GEN-13, STY-1, STY-5, DATA-8)', () {
    test('does nothing while canCreate is false', () async {
      await state.create();

      expect(state.renderedPng, isNull);
      expect(await db.records.liveRecords(), isEmpty);
      expect(counts.successfulCreates, 0);
    });

    test('renders a checked PNG and writes History when Save history is on '
        '(HIS-8)', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');

      await state.create();

      expect(state.renderedPng, isNotNull);
      expect(state.checkError, isNull);
      expect(state.canSaveOrShare, isTrue);
      expect(state.historyWriteFailed, isFalse);

      final List<ScanRecord> records = await db.records.liveRecords();
      expect(records, hasLength(1));
      final ScanRecord record = records.single;
      expect(record.kind, RecordKind.created);
      expect(record.source, RecordSource.created);
      expect(record.symbology, Symbology.qr);
      expect(record.parsedType, ParsedType.text);
      expect(record.payloadText, 'hello world');
      expect(jsonDecode(record.contentJson!), <String, Object?>{
        'text': 'hello world',
      });
      expect(counts.successfulCreates, 1);
    });

    test('renders and counts, but writes nothing, when Save history is off '
        '(HIS-8, DATA-6, DATA-8)', () async {
      await settings.setSaveHistory(enabled: false);
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');

      await state.create();

      expect(state.canSaveOrShare, isTrue);
      expect(await db.records.liveRecords(), isEmpty);
      expect(counts.successfulCreates, 1);
    });

    test('flags a Wi-Fi password as sensitive on the written record '
        '(DATA-5)', () async {
      state.setType(ParsedType.wifi);
      state.updateWifiSsid('Home');
      state.updateWifiPassword('secret123');
      seedMatchingCheck(state.form.encode());

      await state.create();

      final ScanRecord record = (await db.records.liveRecords()).single;
      expect(record.sensitiveFields, <String>[SensitiveFieldKeys.wifiPassword]);
    });

    test('a mismatch (STY-5) blocks save/share but still writes History and '
        'counts the create', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      imageDecoder.result = const ImageDecodeResult(<CodeDetection>[
        CodeDetection(payload: 'something else', symbology: 'qr'),
      ]);

      await state.create();

      expect(state.checkError, QrCreateError.mismatch);
      expect(state.canSaveOrShare, isFalse);
      expect(await db.records.liveRecords(), hasLength(1));
      expect(counts.successfulCreates, 1);
    });

    test('no code found (STY-5) reports decodeFailed', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      // imageDecoder's default result is "no code found".

      await state.create();

      expect(state.checkError, QrCreateError.decodeFailed);
      expect(state.canSaveOrShare, isFalse);
    });

    test('a failed history write leaves the render showing and only sets '
        'historyWriteFailed (GEN-13)', () async {
      final _FailingRecordDao failing = _FailingRecordDao(db.database);
      state.dispose();
      state = buildState(recordDao: failing);
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');

      await state.create();

      expect(failing.attempts, 1);
      expect(state.historyWriteFailed, isTrue);
      expect(state.checkError, isNull);
      expect(state.canSaveOrShare, isTrue, reason: 'the render itself is fine');
      expect(counts.successfulCreates, 1, reason: 'DATA-8 counts either way');
    });

    test('isCreating is true only while the call is in flight', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');
      expect(state.isCreating, isFalse);

      final Future<void> future = state.create();
      expect(state.isCreating, isTrue);
      await future;

      expect(state.isCreating, isFalse);
    });

    test('a second call while one is running does nothing', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');

      final Future<void> first = state.create();
      final Future<void> second = state.create();
      await Future.wait(<Future<void>>[first, second]);

      expect(await db.records.liveRecords(), hasLength(1));
      expect(counts.successfulCreates, 1);
    });

    test('notifies listeners', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');
      int notifications = 0;
      state.addListener(() => notifications++);

      await state.create();

      expect(notifications, greaterThan(0));
    });
  });

  group('create with no temporary storage', () {
    test('fails like an encoder failure instead of spinning forever', () async {
      final GeneratorState noStorage = GeneratorState(
        recordDao: db.records,
        settings: settings,
        successCounts: counts,
        imageDecoder: imageDecoder,
        shareService: shareService,
        now: () => clock,
        tempDirectory: () async =>
            Directory('${Directory.systemTemp.path}/qr-create-no-such-folder'),
      );
      addTearDown(noStorage.dispose);
      noStorage.setType(ParsedType.text);
      noStorage.updateText('hello');

      await noStorage.create();

      expect(noStorage.isCreating, isFalse);
      expect(noStorage.checkError, QrCreateError.renderFailed);
      expect(noStorage.renderedPng, isNull);
      expect(noStorage.canCreate, isTrue);
    });
  });

  group('save (SAVE-1, SAVE-2, SAVE-4)', () {
    test('reports failed and writes nothing before any create()', () async {
      final SaveResult result = await state.save();

      expect(result.outcome, SaveOutcome.failed);
      expect(shareService.calls, isEmpty);
    });

    test('reports failed while the STY-5 check has not passed', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      // No matching detection seeded: the check fails.

      await state.create();
      final SaveResult result = await state.save();

      expect(result.outcome, SaveOutcome.failed);
      expect(shareService.calls, isEmpty);
    });

    test('writes the checked PNG under SAVE-4\'s file name once STY-5 has '
        'passed', () async {
      state.setType(ParsedType.wifi);
      state.updateWifiSsid('Home Network');
      seedMatchingCheck(state.form.encode());
      await state.create();

      final SaveResult result = await state.save();

      expect(result.outcome, SaveOutcome.saved);
      expect(shareService.calls, hasLength(1));
      final String expectedName = generatorFileName(
        type: ParsedType.wifi,
        form: state.form,
        at: clock,
      );
      expect(
        shareService.calls.single,
        'saveFile: $expectedName (image/png, ${state.renderedPng!.length} bytes)',
      );
    });
  });

  group('share (SAVE-1, SAVE-5)', () {
    test('does nothing before any create()', () async {
      await state.share();

      expect(shareService.calls, isEmpty);
    });

    test('does nothing while the STY-5 check has not passed', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      await state.create(); // no matching detection: check fails

      await state.share();

      expect(shareService.calls, isEmpty);
    });

    test('shares the exact PNG file create() checked, as image/png '
        '(SAVE-5)', () async {
      state.setType(ParsedType.text);
      state.updateText('hello world');
      seedMatchingCheck('hello world');
      await state.create();

      await state.share();

      expect(shareService.calls, hasLength(1));
      expect(shareService.calls.single, contains('(image/png)'));
      expect(shareService.calls.single, contains('.png'));
    });
  });
}
