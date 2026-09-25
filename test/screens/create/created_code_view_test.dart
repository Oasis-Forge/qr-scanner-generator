import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/interstitial_session.dart';
import 'package:qrscanner/generator/file_naming.dart';
import 'package:qrscanner/generator/generator_form.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/created_code_view.dart';
import 'package:qrscanner/state/generator_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../../harness/generator_scope.dart';
import '../../helpers/fake_stores.dart';
import '../../helpers/memory_record_dao.dart';
import '../../helpers/test_app.dart';
import 'create_test_helpers.dart';

/// A [RecordDao] whose scan writes all fail, the same shape
/// `generator_state_test.dart` uses for the identical scenario (GEN-13).
class _FailingRecordDao extends MemoryRecordDao {
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
    throw StateError('the database refused the write');
  }
}

/// A [ShareService] whose [shareFile] always throws, to drive SAVE-1's
/// share-failure snackbar; [saveFile] and [shareText] are never called by
/// these tests.
class _ThrowingShareService implements ShareService {
  @override
  Future<void> shareText(String text, {String? subject}) async {}

  @override
  Future<void> shareFile({
    required String path,
    required String mimeType,
    String? text,
  }) async {
    throw StateError('sharing failed');
  }

  @override
  Future<SaveResult> saveFile({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  }) async => const SaveResult(outcome: SaveOutcome.saved);
}

void main() {
  final DateTime clock = DateTime.utc(2026, 9, 17, 10, 30, 15);

  /// Builds a [GeneratorState] with [text] as the Text form's content,
  /// already switched to that type, ready for [create] to be awaited on it
  /// directly — no widget tree needed for that part.
  /// The scratch files the last [buildState] wrote to.
  late MemoryScratchFiles scratch;

  GeneratorState buildState({
    required SeedableImageDecoder imageDecoder,
    NoopShareService? shareService,
    ShareService? throwingShareService,
    RecordDao? dao,
    String text = 'hello',
  }) {
    scratch = MemoryScratchFiles();
    final GeneratorState state = GeneratorState(
      recordDao: dao ?? MemoryRecordDao(now: () => clock),
      settings: SettingsState(FakeKeyValueStore()),
      successCounts: SuccessCounts(FakeKeyValueStore()),
      imageDecoder: imageDecoder,
      shareService: throwingShareService ?? shareService ?? NoopShareService(),
      now: () => clock,
      render: fakeQrRender,
      scratchFiles: scratch,
    );
    state.setType(ParsedType.text);
    state.updateText(text);
    addTearDown(state.dispose);
    return state;
  }

  Future<void> pumpCreated(WidgetTester tester, GeneratorState state) async {
    await pumpApp(
      tester,
      ChangeNotifierProvider<GeneratorState>.value(
        value: state,
        child: const Scaffold(body: CreatedCodeView()),
      ),
    );
  }

  group('the created-code screen (STY-1, SAVE-1)', () {
    testWidgets('shows the code, its type and its content once the check '
        'passes', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(imageDecoder: decoder);
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);

      expect(find.byKey(CreatedCodeView.imageKey), findsOneWidget);
      expect(find.text('TEXT · QR CODE'), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.byKey(CreatedCodeView.checkFailedKey), findsNothing);

      final FilledButton save = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.saveButtonKey),
      );
      final FilledButton share = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.shareButtonKey),
      );
      expect(save.onPressed, isNotNull);
      expect(share.onPressed, isNotNull);
    });

    testWidgets('STY-5: a mismatch says so and keeps Save and Share '
        'disabled', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(imageDecoder: decoder);
      seedMatchingCheck(decoder, 'something else entirely');
      await state.create();

      await pumpCreated(tester, state);

      expect(
        find.text(
          'This code did not match what you entered. Save and '
          'Share are turned off.',
        ),
        findsOneWidget,
      );
      final FilledButton save = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.saveButtonKey),
      );
      final FilledButton share = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.shareButtonKey),
      );
      expect(save.onPressed, isNull);
      expect(share.onPressed, isNull);
    });

    testWidgets('STY-5: no code found at all is also a failure, disabling '
        'both buttons', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(imageDecoder: decoder);
      // decoder.result defaults to noCodeFound.
      await state.create();

      await pumpCreated(tester, state);

      expect(
        find.text(
          'This code could not be checked. Save and Share are turned off.',
        ),
        findsOneWidget,
      );
      final FilledButton save = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.saveButtonKey),
      );
      expect(save.onPressed, isNull);
    });

    testWidgets('masks a Wi-Fi password in the content (DATA-5)', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(imageDecoder: decoder);
      state.setType(ParsedType.wifi);
      state.updateWifiSsid('Cafe');
      state.updateWifiPassword('secret123');
      seedMatchingCheck(decoder, state.encodedPayload!);
      await state.create();

      await pumpCreated(tester, state);

      expect(find.textContaining('secret123'), findsNothing);
      expect(find.text('WIFI:T:WPA;S:Cafe;P:••••••;;'), findsOneWidget);
    });

    testWidgets('shows progress while the check is running', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(imageDecoder: decoder);
      seedMatchingCheck(decoder, 'hello');

      decoder.hold = Completer<void>();

      await pumpCreated(tester, state);
      final Future<void> creating = state.create();
      await tester.pump();

      expect(find.byKey(CreatedCodeView.progressKey), findsOneWidget);
      expect(find.byKey(CreatedCodeView.saveButtonKey), findsNothing);

      decoder.hold!.complete();
      await creating;
      await tester.pumpAndSettle();
      expect(find.byKey(CreatedCodeView.progressKey), findsNothing);
      expect(find.byKey(CreatedCodeView.saveButtonKey), findsOneWidget);
    });

    testWidgets('GEN-13: a failed History write is noted, without blocking '
        'Save or Share', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        dao: _FailingRecordDao(),
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);

      expect(find.byKey(CreatedCodeView.notSavedKey), findsOneWidget);
      expect(
        find.text('This code could not be saved to History.'),
        findsOneWidget,
      );
      final FilledButton save = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.saveButtonKey),
      );
      expect(save.onPressed, isNotNull);
    });

    testWidgets('SAVE-1, SAVE-4: Save writes through ShareService with the '
        'SAVE-4 name and the rendered bytes, and confirms it', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopShareService shareService = NoopShareService();
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        shareService: shareService,
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();
      final int pngLength = state.renderedPng!.length;
      final String expectedName = generatorFileName(
        type: ParsedType.text,
        form: const TextForm(text: 'hello'),
        at: clock,
      );

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(
        shareService.calls,
        contains('saveFile: $expectedName (image/png, $pngLength bytes)'),
      );
      expect(find.text('Saved as $expectedName'), findsOneWidget);

      // Let the snackbar time out, so no timer is left pending.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('SAVE-2: without a file name back from the picker, the '
        'confirmation says the code was saved', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        throwingShareService: _ThrowingShareService(),
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Code saved'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('SAVE-1: a cancelled save shows nothing', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopShareService shareService = NoopShareService(
        saveOutcome: SaveOutcome.cancelled,
      );
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        shareService: shareService,
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('ADS-9: a saved code is followed by the one interstitial', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopAdsService ads = NoopAdsService(interstitialLoads: true);
      // Consent is resolved for the session before any ad may be asked for
      // (ADS-5). main() does this at startup (PRIV-1); a test has to.
      final NoopConsentService consent = NoopConsentService(
        seededStatus: ConsentStatus.notNeeded,
      );
      await consent.refresh();
      final InterstitialSession session = InterstitialSession();
      final SuccessCounts counts = SuccessCounts(FakeKeyValueStore());
      await counts.load();
      addTearDown(counts.dispose);
      final GeneratorState state = buildState(imageDecoder: decoder);
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpApp(
        tester,
        ChangeNotifierProvider<GeneratorState>.value(
          value: state,
          child: const Scaffold(body: CreatedCodeView()),
        ),
        services: AppServices.fakes().copyWith(ads: ads, consent: consent),
        successCounts: counts,
        interstitialSession: session,
      );
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(ads.calls, contains('showInterstitial'));
      expect(session.shown, isTrue);
      // The save still said what it did: the ad follows the confirmation, it
      // does not replace it (ADS-9).
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('ADS-9: a cancelled save is not finished work, so no ad is '
        'even requested', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopAdsService ads = NoopAdsService(interstitialLoads: true);
      // Consent is resolved for the session before any ad may be asked for
      // (ADS-5). main() does this at startup (PRIV-1); a test has to.
      final NoopConsentService consent = NoopConsentService(
        seededStatus: ConsentStatus.notNeeded,
      );
      await consent.refresh();
      final InterstitialSession session = InterstitialSession();
      final SuccessCounts counts = SuccessCounts(FakeKeyValueStore());
      await counts.load();
      await counts.recordSuccessfulScan();
      addTearDown(counts.dispose);
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        shareService: NoopShareService(saveOutcome: SaveOutcome.cancelled),
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpApp(
        tester,
        ChangeNotifierProvider<GeneratorState>.value(
          value: state,
          child: const Scaffold(body: CreatedCodeView()),
        ),
        services: AppServices.fakes().copyWith(ads: ads, consent: consent),
        successCounts: counts,
        interstitialSession: session,
      );
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(ads.calls, isEmpty);
      expect(session.shown, isFalse);
    });

    testWidgets('SAVE-1: a failed save is confirmed with a message', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopShareService shareService = NoopShareService(
        saveOutcome: SaveOutcome.failed,
      );
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        shareService: shareService,
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.saveButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Nothing was saved. Try again.'), findsOneWidget);

      // Let the snackbar time out, so no timer is left pending.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('SAVE-1, SAVE-5: Share hands off the exact file Save would '
        'write', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final NoopShareService shareService = NoopShareService();
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        shareService: shareService,
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.shareButtonKey));
      await tester.pumpAndSettle();

      expect(shareService.calls, hasLength(1));
      final String call = shareService.calls.single;
      expect(call, startsWith('shareFile: '));
      expect(call, endsWith('(image/png)'));
      final String path = call.substring(
        'shareFile: '.length,
        call.length - ' (image/png)'.length,
      );
      expect(scratch.files[path], state.renderedPng);
    });

    testWidgets('SAVE-1: a failed share is confirmed with a message', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      final GeneratorState state = buildState(
        imageDecoder: decoder,
        throwingShareService: _ThrowingShareService(),
      );
      seedMatchingCheck(decoder, 'hello');
      await state.create();

      await pumpCreated(tester, state);
      await tester.tap(find.byKey(CreatedCodeView.shareButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Could not open sharing. Try again.'), findsOneWidget);

      // Let the snackbar time out, so no timer is left pending.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
