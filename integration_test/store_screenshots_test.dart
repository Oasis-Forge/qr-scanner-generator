// Renders the Play Store graphics on an Android device or emulator: six real
// screens with sample data, in every store language, each framed under a
// caption in that language, plus the 1024x500 feature graphic and the 512x512
// store icon. Android draws the text itself, so every script looks exactly as
// it does on a phone — which is the whole point of rendering these on a
// device rather than drawing them by hand.
//
//   adb shell rm -rf /sdcard/Download/store-screenshots
//   flutter test integration_test/store_screenshots_test.dart -d emulator-5554
//   adb pull /sdcard/Download/store-screenshots/<code> store/play/graphics
//
// --dart-define=ONLY=en-US,ar renders only those languages.
//
// Clear the folder first: the runner uninstalls the app when it finishes, and
// a new install cannot overwrite files the old one wrote. The captions are
// generated into store_captions.dart; the icon and feature graphic use the
// launcher mark's own painter, so the store and the phone never drift apart
// (ICON-1). Ported from the portfolio's expense app.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart' as bc;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/l10n/app_localizations.dart';
import 'package:qrscanner/l10n/languages.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/create_screen.dart';
import 'package:qrscanner/screens/history_screen.dart';
import 'package:qrscanner/screens/result_screen.dart';
import 'package:qrscanner/screens/scanner_screen.dart';
import 'package:qrscanner/screens/settings_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/scan_outcome.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../test/harness/generator_scope.dart';
import '../test/harness/scanner_scope.dart';
import '../test/helpers/fake_stores.dart';
import '../test/helpers/memory_record_dao.dart';
import '../test/screens/history/history_harness_data.dart';
import '../test/screens/settings/settings_scope.dart';
import '../tool/app_icon_painter.dart';
import 'store_captions.dart';

const String _only = String.fromEnvironment('ONLY');

/// The phone the screens are laid out on, in logical pixels.
const Size _phone = Size(412, 840);

/// Play's phone screenshot, and the ratio that fills it from [_phone].
const Size _canvas = Size(1080, 1920);
const double _ratio = 2.625;

/// The feature graphic, drawn at half size and saved at 1024x500.
const Size _featureSize = Size(512, 250);

/// The app's own colours (ICON-1, SET-1), so the frames around the
/// screenshots belong to the same object as the app inside them.
const Color _chassis = Color(0xFF0E0D0B);
const Color _chassisLift = Color(0xFF1C1A15);
const Color _signal = Color(0xFFC9F24D);

/// A Play listing language and the app language it shows.
typedef _Store = ({String code, String app});

const List<_Store> _stores = <_Store>[
  (code: 'en-US', app: 'en'),
  (code: 'ar', app: 'ar'),
  (code: 'bn-BD', app: 'bn'),
  (code: 'zh-CN', app: 'zh'),
  (code: 'nl-NL', app: 'nl'),
  (code: 'fr-FR', app: 'fr'),
  (code: 'de-DE', app: 'de'),
  (code: 'hi-IN', app: 'hi'),
  (code: 'id', app: 'id'),
  (code: 'it-IT', app: 'it'),
  (code: 'ja-JP', app: 'ja'),
  (code: 'ko-KR', app: 'ko'),
  (code: 'pl-PL', app: 'pl'),
  (code: 'pt-PT', app: 'pt'),
  (code: 'ru-RU', app: 'ru'),
  (code: 'es-ES', app: 'es'),
  (code: 'th', app: 'th'),
  (code: 'tr-TR', app: 'tr'),
  (code: 'ur', app: 'ur'),
  (code: 'vi', app: 'vi'),
];

/// One screenshot: the file it lands in, the screen it shows, and whether the
/// app is in its dark half. Five are dark, because the app opens on its own
/// chassis whatever the phone is set to (SET-1); Settings is light, so the
/// listing shows both halves exist.
typedef _Shot = ({String name, Widget Function() build, bool dark});

final List<_Shot> _shots = <_Shot>[
  (name: '1-scan', build: _liveScanner, dark: true),
  (name: '2-result', build: () => _linkResult(_cleanLink), dark: true),
  (name: '3-review', build: () => _linkResult(_riskyLink), dark: true),
  (name: '4-create', build: _createPicker, dark: true),
  (name: '5-history', build: _history, dark: true),
  (name: '6-settings', build: _settings, dark: false),
];

/// A plain link, and one carrying three of LINK-1's marks at once: a user name
/// hidden before the real host, an unusual port, and no encryption. The second
/// is what the review screen is for, and a listing that doesn't show it is
/// hiding the reason to install the app.
const String _cleanLink = 'https://oasisforge.example/menu/autumn';
const String _riskyLink =
    'http://secure-login.example.com@203.0.113.4:8081'
    '/account/verify?session=8f21c0';

// ------------------------------------------------------------- screens ----

Widget _liveScanner() => ScannerScope(
  // Granted, or the shot is the permission gate rather than the viewfinder
  // (RUN-1 is a real screen, but it is not the one that sells the app).
  services: AppServices.fakes().copyWith(
    permissions: NoopPermissionService(
      initialState: CameraPermissionState.granted,
    ),
    cameraScanner: _PosterScanner(),
  ),
  child: const ScannerScreen(),
);

Widget _linkResult(String payload) => ResultScreen(
  outcome: ScanOutcome(
    record: aScanRecord(payloadText: payload),
    parsedType: ParsedType.url,
    symbology: Symbology.qr,
    source: RecordSource.camera,
    isSaved: true,
  ),
);

Widget _createPicker() =>
    GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen());

Widget _history() => ChangeNotifierProvider<HistoryState>(
  create: (BuildContext context) => HistoryState(
    records: StaticHistoryRecordDao(historyHarnessRecords()),
    settings: context.read<SettingsState>(),
  ),
  child: HistoryScreen(
    onSwitchToScan: () {},
    onSwitchToCreate: () {},
    onSwitchToSettings: () {},
  ),
);

Widget _settings() => const SettingsScope(child: SettingsScreen());

/// A camera that shows a poster with a real QR code on it, so the viewfinder
/// screenshot has something to be pointed at. The fake exists because the
/// camera is a device service behind an interface (`CLAUDE.md`); the emulator's
/// virtual scene is far too soft to photograph for a store listing.
class _PosterScanner extends NoopCameraScanner {
  @override
  Widget buildPreview({BoxFit fit = BoxFit.cover}) =>
      const CustomPaint(painter: _PosterPainter(), child: SizedBox.expand());
}

class _PosterPainter extends CustomPainter {
  const _PosterPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF2A2724), Color(0xFF14120F)],
        ).createShader(Offset.zero & size),
    );

    // The poster the code is printed on, square and centred, sized so it lands
    // inside the viewfinder's target.
    final double side = size.shortestSide * 0.52;
    final Rect card = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(10)),
      Paint()..color = const Color(0xFFF6F4EE),
    );

    final double quiet = side * 0.1;
    final double codeSide = side - 2 * quiet;
    final Paint ink = Paint()
      ..color = const Color(0xFF14120F)
      ..isAntiAlias = false;
    final bc.Barcode qr = bc.Barcode.qrCode(
      errorCorrectLevel: bc.BarcodeQRCorrectionLevel.medium,
    );
    for (final bc.BarcodeElement element in qr.make(
      _cleanLink,
      width: codeSide,
      height: codeSide,
    )) {
      if (element is bc.BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            card.left + quiet + element.left,
            card.top + quiet + element.top,
            element.width,
            element.height,
          ),
          ink,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PosterPainter oldDelegate) => false;
}

// -------------------------------------------------------------- frames ----

/// The app itself, with the providers `main.dart` builds, in [locale].
Widget _app({
  required Widget screen,
  required Locale locale,
  required bool dark,
}) {
  final FakeKeyValueStore store = FakeKeyValueStore(<String, String>{});
  final SettingsState settings = SettingsState(store);
  final SuccessCounts counts = SuccessCounts(store);
  final RecordDao records = MemoryRecordDao();
  final AppServices services = AppServices.fakes();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsState>.value(value: settings),
      ChangeNotifierProvider<SuccessCounts>.value(value: counts),
      Provider<RecordDao>.value(value: records),
      Provider<AppServices>.value(value: services),
      ChangeNotifierProvider<HistoryState>(
        create: (BuildContext context) =>
            HistoryState(records: records, settings: settings),
      ),
      ChangeNotifierProvider<ProState>(
        create: (BuildContext context) => ProState(
          billing: services.billing,
          store: store,
          successCounts: counts,
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: screen,
    ),
  );
}

/// One phone screenshot: a caption over the app in a phone.
Widget _frame({
  required String caption,
  required bool rtl,
  required Locale locale,
  required Widget app,
}) {
  final Size logical = _canvas / _ratio;
  const double top = 40;
  const double captionBox = 84;
  const double bottom = 18;
  const double bezel = 7;
  final double scale =
      (logical.height - top - captionBox - bottom - 2 * bezel) / _phone.height;

  // The largest size, up to 25, at which the caption still fits on two lines.
  TextStyle captionStyle(double size) => TextStyle(
    locale: locale,
    fontSize: size,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  double size = 25;
  while (size > 14) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: caption, style: captionStyle(size)),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: logical.width - 48);
    final bool fits = !painter.didExceedMaxLines;
    painter.dispose();
    if (fits) break;
    size -= 1;
  }

  return Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_chassisLift, _chassis],
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: top),
          SizedBox(
            height: captionBox,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: captionStyle(size),
                  ),
                ),
                const SizedBox(height: 10),
                // The signal rule, the same mark the app puts under a group
                // heading, so the frame reads as part of the instrument.
                Container(width: 44, height: 2, color: _signal),
              ],
            ),
          ),
          _device(app: app, width: _phone.width * scale, bezel: bezel),
        ],
      ),
    ),
  );
}

/// The app inside a phone [width] logical pixels wide.
Widget _device({
  required Widget app,
  required double width,
  required double bezel,
}) {
  final double scale = width / _phone.width;
  final Radius radius = Radius.circular(26 * scale);
  return Container(
    padding: EdgeInsets.all(bezel),
    decoration: BoxDecoration(
      color: const Color(0xFF070706),
      borderRadius: BorderRadius.all(radius + Radius.circular(bezel)),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.all(radius),
      child: SizedBox(
        width: width,
        height: _phone.height * scale,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: _phone.width,
            height: _phone.height,
            child: app,
          ),
        ),
      ),
    ),
  );
}

/// The 1024x500 feature graphic: the mark and the app's name beside a phone.
Widget _feature({
  required String title,
  required String tagline,
  required bool rtl,
  required Locale locale,
  required Widget app,
}) {
  TextStyle style(double size, FontWeight weight, Color color) => TextStyle(
    locale: locale,
    fontSize: size,
    height: 1.2,
    fontWeight: weight,
    color: color,
  );
  return Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_chassisLift, _chassis],
        ),
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            start: 36,
            top: 0,
            bottom: 0,
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The mark alone, with no chassis behind it: the graphic is
                // already the chassis, and a filled square on top of it reads
                // as a sticker rather than as the app's own mark.
                const SizedBox.square(
                  dimension: 64,
                  child: CustomPaint(painter: AppIconPainter(scale: 1)),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  style: style(24, FontWeight.bold, Colors.white),
                ),
                const SizedBox(height: 8),
                Container(width: 40, height: 2, color: _signal),
                const SizedBox(height: 8),
                Text(
                  tagline,
                  maxLines: 3,
                  style: style(14, FontWeight.w500, const Color(0xDDFFFFFF)),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: 40,
            top: 30,
            child: _device(app: app, width: 170, bezel: 5),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------- main ----

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final List<_Store> stores = _only.isEmpty
      ? _stores
      : _stores.where((_Store s) => _only.split(',').contains(s.code)).toList();

  for (final _Store store in stores) {
    testWidgets('graphics for ${store.code}', (WidgetTester tester) async {
      final List<String> captions = storeCaptions[store.code]!;
      final String title = storeTitles[store.code]!;
      final Locale locale = Locale(store.app);
      final bool rtl = rightToLeftLanguages.contains(store.app);

      tester.view
        ..physicalSize = _canvas
        ..devicePixelRatio = _ratio;
      addTearDown(tester.view.reset);
      // Tests draw an outline in place of every shadow; a screenshot wants the
      // real thing.
      final bool shadows = debugDisableShadows;
      debugDisableShadows = false;
      // Downloads outlives the app, which the runner uninstalls.
      final Directory dir = Directory(
        '/sdcard/Download/store-screenshots/${store.code}',
      )..createSync(recursive: true);

      for (final (int i, _Shot shot) in _shots.indexed) {
        await _save(
          tester,
          '${dir.path}/${shot.name}.png',
          _frame(
            caption: captions[i],
            rtl: rtl,
            locale: locale,
            app: _app(screen: shot.build(), locale: locale, dark: shot.dark),
          ),
          ratio: _ratio,
        );
      }

      tester.view
        ..physicalSize = _featureSize * 2
        ..devicePixelRatio = 2;
      await _save(
        tester,
        '${dir.path}/feature-graphic.png',
        _feature(
          title: title,
          tagline: captions.last,
          rtl: rtl,
          locale: locale,
          app: _app(screen: _shots.first.build(), locale: locale, dark: true),
        ),
        ratio: 2,
      );

      // The store icon is the same in every language, so it is drawn once.
      if (store.code == 'en-US') {
        tester.view
          ..physicalSize = const Size.square(512)
          ..devicePixelRatio = 1;
        await _save(
          tester,
          '/sdcard/Download/store-screenshots/icon-512.png',
          const CustomPaint(
            painter: AppIconPainter(scale: 0.55, background: true),
            size: Size.square(512),
          ),
          ratio: 1,
        );
      }
      debugDisableShadows = shadows;
      // Eight images at 1080x1920 take 20 to 27 seconds a language on the
      // emulator, and the default per-test timeout is 30. Left at the
      // default, a run of all twenty dies partway through with "did not
      // complete" once the device has warmed up and slowed down (2026-09-21).
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
}

Future<void> _save(
  WidgetTester tester,
  String path,
  Widget picture, {
  required double ratio,
}) async {
  final GlobalKey boundary = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: boundary, child: picture));
  // Pumped rather than settled: the viewfinder animates for ever, so
  // pumpAndSettle would never return.
  for (int f = 0; f < 8; f++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.runAsync(() async {
    final RenderRepaintBoundary render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await render.toImage(pixelRatio: ratio);
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    File(path).writeAsBytesSync(png!.buffer.asUint8List());
    image.dispose();
  });
  await tester.pumpWidget(const SizedBox());
}
