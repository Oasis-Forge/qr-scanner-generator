import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/state/result_state.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/settings_state.dart';

import '../../helpers/fake_stores.dart';
import '../../helpers/test_app.dart';

/// A saved camera scan of [text] (RES-3), for a section test that only cares
/// about the payload.
ScanOutcome outcomeFor(
  String text, {
  required ParsedType parsedType,
  Symbology symbology = Symbology.qr,
}) => ScanOutcome(
  record: aScanRecord(
    payloadText: text,
    parsedType: parsedType,
    symbology: symbology,
  ),
  parsedType: parsedType,
  symbology: symbology,
  source: RecordSource.camera,
  isSaved: true,
);

/// A [ResultState] for [outcome], every service defaulting to a fresh no-op
/// fake, so a section test overrides only the one it is checking.
ResultState resultStateFor(
  ScanOutcome outcome, {
  ClipboardService? clipboard,
  ShareService? share,
  SystemIntents? systemIntents,
  LinkOpener? linkOpener,
  SearchEngine searchEngine = SearchEngine.google,
}) => ResultState(
  outcome: outcome,
  isReopened:
      true, // Section tests drive taps directly; SET-3 has its own tests.
  copyOnScan: false,
  searchEngine: searchEngine,
  clipboard: clipboard ?? NoopClipboardService(),
  share: share ?? NoopShareService(),
  systemIntents: systemIntents ?? NoopSystemIntents(),
  linkOpener: linkOpener ?? NoopLinkOpener(),
);

/// Pumps [section] with [state] already available to it (`context.watch`),
/// inside the app shell, so a section test sees the same message files,
/// theme and directionality the real result screen gives it.
Future<void> pumpSection(
  WidgetTester tester,
  ResultState state,
  Widget section, {
  Locale? locale,
  double textScale = 1,
}) => pumpApp(
  tester,
  ChangeNotifierProvider<ResultState>.value(
    value: state,
    child: Scaffold(body: SingleChildScrollView(child: section)),
  ),
  locale: locale,
  textScale: textScale,
);
