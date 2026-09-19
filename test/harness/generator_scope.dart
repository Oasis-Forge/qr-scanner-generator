import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart' show ParsedType;
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/state/generator_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

/// Provides a [GeneratorState] to [child], built the way `main.dart` builds
/// it: from the settings, success counts, records and services the test
/// shell (`pumpApp`) already provides — the same pattern `ScannerScope` uses
/// for [ScannerState].
///
/// `pumpApp` knows nothing about the generator, so a screen that reads
/// [GeneratorState] — the Create tab and everything under it — is pumped
/// inside one of these. The state is disposed with the tree when the test
/// ends.
///
/// Rendering answers at once with [fakeQrPng] and scratch files stay in
/// memory: real rendering and file I/O never finish under a widget test's
/// fake clock (`qr_renderer_test.dart` covers the real renderer).
///
/// * [imageDecoder] and [shareService] replace the ones [AppServices] would
///   hand over, so a test can seed the STY-5 check's result or a save
///   outcome without touching the whole service set.
/// * [now] pins the clock GeneratorState stamps history rows and file names
///   with (SAVE-4, DATE-1).
/// * [dao] passes a [RecordDao] a screen test built itself (a
///   `MemoryRecordDao`, say) instead of reading the one `pumpApp` already
///   provided.
/// * [initialType] switches the fresh state to that GEN-1 type before the
///   first frame, so a test of one type's form never has to drive the type
///   picker first — `GeneratorState` otherwise always starts on
///   [ParsedType.url].
/// * [onCreated] runs once the first frame is drawn, with the state, the
///   same hook `ScannerScope` offers for [ScannerState] — a harness entry
///   that needs a code already created (the created-code screen) drives
///   [GeneratorState.create] here the way the Create button would.
class GeneratorScope extends StatelessWidget {
  const GeneratorScope({
    required this.child,
    this.imageDecoder,
    this.shareService,
    this.now,
    this.dao,
    this.initialType,
    this.onCreated,
    super.key,
  });

  final Widget child;
  final ImageDecoder? imageDecoder;
  final ShareService? shareService;
  final DateTime Function()? now;
  final RecordDao? dao;
  final ParsedType? initialType;
  final Future<void> Function(GeneratorState state)? onCreated;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GeneratorState>(
      create: (BuildContext context) {
        final AppServices services = context.read<AppServices>();
        final GeneratorState state = GeneratorState(
          recordDao: dao ?? context.read<RecordDao>(),
          settings: context.read<SettingsState>(),
          successCounts: context.read<SuccessCounts>(),
          imageDecoder: imageDecoder ?? services.imageDecoder,
          shareService: shareService ?? services.share,
          now: now ?? DateTime.now,
          render: fakeQrRender,
          scratchFiles: MemoryScratchFiles(),
        );
        final ParsedType? type = initialType;
        if (type != null) {
          state.setType(type);
        }
        final Future<void> Function(GeneratorState state)? hook = onCreated;
        if (hook != null) {
          // Not while the tree is being built: the state notifies.
          WidgetsBinding.instance.addPostFrameCallback((Duration _) {
            unawaited(hook(state));
          });
        }
        return state;
      },
      child: child,
    );
  }
}

/// A 1 x 1 PNG standing in for a rendered code in widget tests.
final Uint8List fakeQrPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

/// A renderer that answers at once with [fakeQrPng].
Future<Uint8List> fakeQrRender(String payload) async => fakeQrPng;

/// [ScratchFiles] kept in memory, so `create()` finishes under a widget
/// test's fake clock.
class MemoryScratchFiles implements ScratchFiles {
  /// Every file written and not yet deleted, by path.
  final Map<String, Uint8List> files = <String, Uint8List>{};

  @override
  Future<String> write(Uint8List bytes, {required String name}) async {
    final String path = 'memory/$name.png';
    files[path] = bytes;
    return path;
  }

  @override
  Future<void> delete(String path) async => files.remove(path);
}
