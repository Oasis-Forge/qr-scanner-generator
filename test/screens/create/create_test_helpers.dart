import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/services/camera_scanner.dart' show CodeDetection;
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/state/generator_state.dart';

import '../../harness/generator_scope.dart';
import '../../helpers/memory_record_dao.dart';
import '../../helpers/test_app.dart';

/// An [ImageDecoder] whose result can be changed after construction, the
/// same shape `generator_state_test.dart` uses for the identical need: STY-5's
/// check reads whatever [result] holds when `GeneratorState.create` calls it.
class SeedableImageDecoder implements ImageDecoder {
  ImageDecodeResult result = const ImageDecodeResult.noCodeFound();

  final List<String> calls = <String>[];

  /// While set and not completed, the check waits: a test sees the created
  /// code's progress state until it completes this.
  Completer<void>? hold;

  @override
  Future<ImageDecodeResult> decodeFile(String path) async {
    calls.add(path);
    await hold?.future;
    return result;
  }
}

/// Seeds [decoder] so STY-5's check passes for exactly [payload].
void seedMatchingCheck(SeedableImageDecoder decoder, String payload) {
  decoder.result = ImageDecodeResult(<CodeDetection>[
    CodeDetection(payload: payload, symbology: Symbology.qr.id),
  ]);
}

/// Pumps `CreateFormBody` (the fields for [type] plus the capacity meter and
/// Create) inside the shell every screen test uses, with a fresh
/// [GeneratorState] already switched to [type] — a test of one type's form
/// never has to drive the type picker first.
///
/// Wrapped in a bare [Scaffold], the same ancestor `create_screen.dart`
/// gives it in the real app, so its buttons and fields have the [Material]
/// they need.
///
/// A [MemoryRecordDao] backs it by default, so a Create tap completes inside
/// `testWidgets` (the real DAO's writes never do). [imageDecoder] seeds
/// STY-5's check for a test that taps Create.
Future<GeneratorState> pumpCreateForm(
  WidgetTester tester,
  ParsedType type, {
  ImageDecoder? imageDecoder,
  Locale? locale,
  double textScale = 1,
}) async {
  await pumpApp(
    tester,
    GeneratorScope(
      initialType: type,
      dao: MemoryRecordDao(),
      imageDecoder: imageDecoder,
      child: const Scaffold(body: CreateFormBody()),
    ),
    locale: locale,
    textScale: textScale,
  );
  return tester.element(find.byType(CreateFormBody)).read<GeneratorState>();
}
