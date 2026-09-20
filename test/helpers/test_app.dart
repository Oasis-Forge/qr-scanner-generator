import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/l10n/app_localizations.dart';
import 'package:qrscanner/screens/settings_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/history_state.dart';
import 'package:qrscanner/state/pro_state.dart';
import 'package:qrscanner/state/settings_state.dart';
import 'package:qrscanner/state/success_counts.dart';

import 'fake_stores.dart';

/// The surface every screen test runs on: a phone, in logical pixels.
///
/// A11Y-4 and LANG-6 both say "on a phone-size screen", so this is the width a
/// translation at 2.0× text has to fit into. It is a small modern phone
/// (Pixel-class, 411 × 731 dp), the narrowest shape the app supports.
const Size phoneSurfaceSize = Size(411, 731);

/// The text sizes the harness renders every screen at: the system default, and
/// the 200% A11Y-4 and LANG-6 ask for.
const List<double> harnessTextScales = <double>[1, 2];

/// How far under [AppTheme.minTapTargetSize] a control may measure before it
/// counts as too small, to absorb floating-point rounding in layout.
const double _sizeTolerance = 0.01;

/// Every language the app ships, straight from the message files.
///
/// It reads `AppLocalizations.supportedLocales`, so a language a translation PR
/// adds joins the harness by itself, which is what LANG-6 asks for: the main
/// screens are rendered in *every* language, because how long a label runs is
/// exactly what differs between them.
List<Locale> get harnessLocales => AppLocalizations.supportedLocales;

/// The languages the accessibility harness runs (LANG-6, amended 2026-09-21).
///
/// What that harness checks — that every control has a screen-reader name and
/// a large enough target — is the same whatever language the app is in, so
/// running it in all twenty-one would re-check one fact twenty-one ways for
/// several minutes. English and Arabic keep a left-to-right and a
/// right-to-left layout in the set (LANG-5).
const List<Locale> accessibilityLocales = <Locale>[Locale('en'), Locale('ar')];

/// One screen the shared harness checks.
class HarnessScreen {
  const HarnessScreen({
    required this.name,
    required this.build,
    required this.readableText,
  });

  /// How the screen is named in a test name, e.g. `'the home screen'`.
  final String name;

  /// Builds the screen: a new instance per test, so nothing leaks between them.
  final Widget Function() build;

  /// A string the user must be able to read on this screen, named as the
  /// message it comes from rather than spelled out per language.
  ///
  /// It keeps the checks honest: a harness that pumped a blank frame would
  /// otherwise pass every one of them. Taking it from [AppLocalizations]
  /// means a new language needs nothing here — twenty-one languages across
  /// seventeen screens would be over three hundred strings to keep by hand,
  /// and every one of them a chance to drift from what the screen shows.
  final String Function(AppLocalizations l10n) readableText;

  /// The string this screen must show in [locale].
  String textIn(Locale locale) => readableText(lookupAppLocalizations(locale));
}

/// Every screen the app has today, for the accessibility and text-size
/// harnesses (A11Y-1, A11Y-2, A11Y-4, LANG-6).
///
/// A screen PR adds its screen here once and both harnesses cover it, in every
/// language at every text size.
final List<HarnessScreen> harnessScreens = <HarnessScreen>[
  HarnessScreen(
    name: 'the settings screen',
    build: () => const SettingsScreen(),
    readableText: (AppLocalizations l10n) =>
        l10n.settingsGroupGeneral.toUpperCase(),
  ),
];

/// The app shell a test pumped, and the state behind it.
class TestApp {
  const TestApp({
    required this.settings,
    required this.successCounts,
    required this.store,
    required this.records,
    required this.services,
  });

  /// The settings the shell watches (SET-1, LANG-1).
  final SettingsState settings;

  /// The success counters behind ads and prompts (DATA-8).
  final SuccessCounts successCounts;

  /// The store the harness built, and what the screen wrote to it.
  ///
  /// When a test passes its own `settings` or `successCounts` built on another
  /// store, this one holds only what the harness itself created.
  final FakeKeyValueStore store;

  /// The DAO the shell provides. Unless a test passes one from
  /// `openTestDatabase`, its database is never opened and any read throws.
  final RecordDao records;

  /// Every device capability, behind its interface (`CLAUDE.md`).
  final AppServices services;
}

/// Pumps [screen] inside the app shell that ships: the providers, the message
/// files with their delegates, the themes, and a phone-size surface.
///
/// A screen test then drives the tree the user gets, not a bare widget. The
/// shell watches [SettingsState] the way `main.dart` does, so tapping a setting
/// in a test repaints the app.
///
/// * [locale] pins the app language, as if the user had chosen it (LANG-1);
///   leave it out and the app follows the settings, which follow the device.
/// * [themeMode] pins the theme the same way (SET-1).
/// * [textScale] is the system text size: 2 is the 200% A11Y-4 and LANG-6 ask
///   for.
/// * [stored] seeds the key-value rows the state loads from, keyed by
///   `SettingsState.themeModeKey` and friends.
/// * [settings], [successCounts], [store], [dao] and [services] each replace
///   what the harness would have built, for a test that needs to look behind the
///   screen or to hand it a real database.
///
/// Everything a test may want to inspect comes back in the returned [TestApp].
Future<TestApp> pumpApp(
  WidgetTester tester,
  Widget screen, {
  Locale? locale,
  ThemeMode? themeMode,
  double textScale = 1,
  SettingsState? settings,
  AppServices? services,
  RecordDao? dao,
  FakeKeyValueStore? store,
  Map<String, String>? stored,
  SuccessCounts? successCounts,
  Size surfaceSize = phoneSurfaceSize,
}) async {
  final FakeKeyValueStore appStore = store ?? FakeKeyValueStore(stored);
  final SettingsState appSettings = settings ?? SettingsState(appStore);
  if (settings == null) {
    await appSettings.load();
  }
  final SuccessCounts appCounts = successCounts ?? SuccessCounts(appStore);
  if (successCounts == null) {
    await appCounts.load();
  }
  final RecordDao appRecords = dao ?? _unopenedDao();
  final AppServices appServices = services ?? AppServices.fakes();

  // A phone, at one logical pixel per physical pixel, so every size a test
  // measures is already in dp.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = surfaceSize;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsState>.value(value: appSettings),
        ChangeNotifierProvider<SuccessCounts>.value(value: appCounts),
        Provider<RecordDao>.value(value: appRecords),
        Provider<AppServices>.value(value: appServices),
        // History (HIS-1), over the same records and settings, as the app
        // provides it, so a screen that opens the History tab finds it.
        ChangeNotifierProvider<HistoryState>(
          create: (BuildContext context) =>
              HistoryState(records: appRecords, settings: appSettings),
        ),
        // Pro (PRO-7), over the same store and billing fake, as the app
        // provides it, so a screen with the Pro prompt or a banner slot finds
        // it. A free user unless the test seeds ownership.
        ChangeNotifierProvider<ProState>(
          create: (BuildContext context) {
            final ProState pro = ProState(
              billing: appServices.billing,
              store: appStore,
              successCounts: appCounts,
            );
            unawaited(pro.load());
            return pro;
          },
        ),
      ],
      child: _TestShell(
        screen: screen,
        locale: locale,
        themeMode: themeMode,
        textScale: textScale,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return TestApp(
    settings: appSettings,
    successCounts: appCounts,
    store: appStore,
    records: appRecords,
    services: appServices,
  );
}

/// Fails naming every icon-only control a screen reader would announce with no
/// name (A11Y-1).
///
/// A control is icon-only when the node a screen reader lands on holds an [Icon]
/// or [ImageIcon] and carries neither a label nor a tooltip. A control that also
/// shows text passes, because that text is the name the screen reader reads; a
/// decorative icon in nothing tappable passes too, since A11Y-1 is about
/// controls.
///
/// The fixes, in this app's order of preference: a visible text label next to
/// the icon, `IconButton(tooltip:)`, `Icon(semanticLabel:)`, or a `Semantics`
/// label that merges into the control.
Future<void> expectEveryIconHasALabel(WidgetTester tester) async {
  final List<String> unlabelled = <String>[];
  await _withSemantics(tester, () {
    for (final _Control control in _controlsOf(tester)) {
      if (!control.isControl || control.isNamed) {
        continue;
      }
      final Widget? icon = control.icon;
      if (icon == null) {
        continue;
      }
      unlabelled.add('${_describeIcon(icon)} in ${control.name}');
    }
  });

  if (unlabelled.isEmpty) {
    return;
  }
  fail(
    'A11Y-1: ${unlabelled.length} icon-only control(s) have no screen-reader '
    'name:\n${_bullets(unlabelled)}\n'
    'Give each one a visible label, an IconButton(tooltip:), an '
    'Icon(semanticLabel:), or a Semantics label that merges into the control.',
  );
}

/// Fails naming every control a finger can hit that is smaller than
/// [AppTheme.minTapTargetSize] square (A11Y-2).
///
/// It measures the box behind each tappable node, which is the area that takes
/// the tap — the padding Material puts around a small button included — so it
/// checks what A11Y-2 is about rather than the painted shape.
Future<void> expectTapTargetsAtLeast48dp(WidgetTester tester) async {
  final List<_Control> tappable = <_Control>[];
  await _withSemantics(tester, () {
    for (final _Control control in _controlsOf(tester)) {
      if (control.isTappable && !control.isHidden) {
        tappable.add(control);
      }
    }
  });

  final List<String> tooSmall = <String>[];
  for (final _Control control in tappable) {
    final Size? size = control.size;
    if (size == null) {
      continue;
    }
    final bool narrow = size.width < AppTheme.minTapTargetSize - _sizeTolerance;
    final bool short = size.height < AppTheme.minTapTargetSize - _sizeTolerance;
    if (narrow || short) {
      tooSmall.add('${control.name} taps as ${_dp(size)}');
    }
  }

  if (tooSmall.isEmpty) {
    return;
  }
  final String minimum = _number(AppTheme.minTapTargetSize);
  fail(
    'A11Y-2: ${tooSmall.length} control(s) are smaller than '
    '$minimum x $minimum dp:\n${_bullets(tooSmall)}\n'
    'Give each one a minimumSize of AppTheme.minTapTargetSize, or put it in a '
    'box that size.',
  );
}

/// Fails naming every render box that overflowed, which is content or an action
/// the user cannot see (A11Y-4, LANG-6).
///
/// It reads the laid-out render tree rather than waiting for a painted overflow
/// stripe, so a row that overflows out of sight inside a scroll view is caught
/// too. Text a screen shortens on purpose — an ellipsis on a long payload — is
/// not overflow and is not reported.
void expectNoOverflow(WidgetTester tester) {
  final Set<RenderObject> seen = <RenderObject>{};
  final List<String> overflowing = <String>[];
  for (final Element element in _elementsOf(tester)) {
    final RenderObject? renderObject = element.renderObject;
    if (renderObject == null || !seen.add(renderObject)) {
      continue;
    }
    // RenderFlex (Row, Column, Flex) and RenderConstraintsTransformBox
    // (OverflowBox, UnconstrainedBox) say so in their own short description as
    // soon as their children did not fit.
    if (!renderObject.toStringShort().contains('OVERFLOWING')) {
      continue;
    }
    overflowing.add(_describeOverflow(renderObject));
  }

  if (overflowing.isEmpty) {
    return;
  }
  fail(
    'A11Y-4, LANG-6: ${overflowing.length} box(es) overflowed on a '
    '${_dp(_screenSize(tester))} screen:\n${_bullets(overflowing)}\n'
    'Nothing may be clipped at this text size or in this language: let the '
    'content wrap, let it scroll, or shorten it.',
  );
}

/// The [MaterialApp] a test drives: the shipping shell, with the screen under
/// test as its first route and the system text size the test asked for.
class _TestShell extends StatelessWidget {
  const _TestShell({
    required this.screen,
    required this.locale,
    required this.themeMode,
    required this.textScale,
  });

  final Widget screen;
  final Locale? locale;
  final ThemeMode? themeMode;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = context.watch<SettingsState>();
    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? settings.localeOverride,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode ?? settings.themeMode,
      // Inside the app, so a dialog, a sheet and a snackbar are scaled too.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child ?? const SizedBox.shrink(),
      ),
      home: screen,
    );
  }
}

/// A semantics node and the render object that owns it.
class _SemanticsOwner {
  const _SemanticsOwner(this.node, this.renderObject);

  final SemanticsNode node;
  final RenderObject renderObject;
}

/// One node of the semantics tree: what a screen reader reads, the box behind
/// it, and the widgets that built it, so a failure can name something a
/// developer recognises.
class _Control {
  _Control(this.owner) : data = owner.node.getSemanticsData();

  final _SemanticsOwner owner;

  /// Read while semantics are on, so every check can use it afterwards.
  final SemanticsData data;

  /// Every widget merged into this node, outermost first.
  final List<Element> candidates = <Element>[];

  /// Whether a finger can tap it.
  bool get isTappable => data.hasAction(SemanticsAction.tap);

  /// Whether it is off screen, e.g. scrolled out of the viewport.
  bool get isHidden => data.flagsCollection.isHidden;

  /// Whether it is a control at all: tappable, or announced as a button or a
  /// link, which covers a control that is currently disabled.
  bool get isControl =>
      isTappable ||
      data.flagsCollection.isButton ||
      data.flagsCollection.isLink;

  /// Whether a screen reader has something to read out for it.
  bool get isNamed =>
      data.label.trim().isNotEmpty || data.tooltip.trim().isNotEmpty;

  /// The icon it draws, or null when it draws none.
  Widget? get icon {
    for (final Element element in candidates) {
      final Widget widget = element.widget;
      if (widget is Icon || widget is ImageIcon) {
        return widget;
      }
    }
    return null;
  }

  /// The box that takes the tap, or null when the node is not a box.
  Size? get size {
    final RenderObject renderObject = owner.renderObject;
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    return renderObject.size;
  }

  /// The keyed widget behind the control when there is one — a later PR can act
  /// on the key — else the outermost widget that built it.
  String get name {
    final Element named = candidates.firstWhere(
      (Element element) => element.widget.key != null,
      orElse: () => candidates.first,
    );
    return _describe(named);
  }
}

/// A DAO whose database is never opened, for a screen that reads no records.
///
/// A screen that does read records is handed a DAO from `openTestDatabase`; this
/// one throws a [StateError] naming the unopened database if it is ever read,
/// rather than quietly answering nothing.
RecordDao _unopenedDao() => RecordDao(
  AppDatabase(
    directory: 'unopened-in-a-widget-test',
    runner: MigrationRunner(migrationSteps),
    // Never opened, so no native library is loaded.
    databaseFactory: databaseFactoryFfi,
  ),
);

/// Turns semantics on for the length of [body], which is what fills in the tree
/// these checks read, and turns it off again afterwards.
Future<void> _withSemantics(WidgetTester tester, void Function() body) async {
  final SemanticsHandle handle = tester.ensureSemantics();
  // One frame, so the semantics tree is built before it is read.
  await tester.pump();
  try {
    body();
  } finally {
    handle.dispose();
  }
}

/// Every semantics node on screen, with the widgets merged into it. Only valid
/// while semantics are on, so call it inside [_withSemantics].
Iterable<_Control> _controlsOf(WidgetTester tester) {
  final Map<SemanticsNode, _Control> controls = <SemanticsNode, _Control>{};
  for (final Element element in _elementsOf(tester)) {
    final _SemanticsOwner? owner = _enclosingSemantics(element);
    if (owner == null) {
      continue;
    }
    controls
        .putIfAbsent(owner.node, () => _Control(owner))
        .candidates
        .add(element);
  }
  return controls.values;
}

/// Every element in the pumped tree, offstage ones included, as a list: the walk
/// is lazy, and these checks read the tree while it must not change.
List<Element> _elementsOf(WidgetTester tester) =>
    tester.allElements.toList(growable: false);

/// The semantics node a screen reader would announce for [element]: its own, or
/// the ancestor node it was merged into.
_SemanticsOwner? _enclosingSemantics(Element element) {
  RenderObject? renderObject = element.findRenderObject();
  SemanticsNode? node = renderObject?.debugSemantics;
  while (renderObject != null && (node == null || node.isMergedIntoParent)) {
    renderObject = renderObject.parent;
    node = renderObject?.debugSemantics;
  }
  if (renderObject == null || node == null) {
    return null;
  }
  return _SemanticsOwner(node, renderObject);
}

/// [element] and the widgets above it, e.g.
/// `_ChoiceButton-[<'home.theme.dark'>] ← MergeSemantics ← Semantics ← Wrap`.
String _describe(Element element) => element.debugGetCreatorChain(4);

/// The icon itself, so a failure says which one is missing its name.
String _describeIcon(Widget widget) => switch (widget) {
  final Icon icon => 'Icon(${icon.icon})',
  final ImageIcon icon => 'ImageIcon(${icon.image})',
  _ => widget.toStringShort(),
};

/// The overflowing box, named by the widget that built it and by its size.
String _describeOverflow(RenderObject renderObject) {
  final Object? creator = renderObject.debugCreator;
  final String where = creator is DebugCreator
      ? _describe(creator.element)
      : renderObject.toStringShort();
  if (renderObject is RenderBox && renderObject.hasSize) {
    return '$where, laid out ${_dp(renderObject.size)}';
  }
  return where;
}

/// The screen the test is running on, in logical pixels.
Size _screenSize(WidgetTester tester) =>
    tester.view.physicalSize / tester.view.devicePixelRatio;

String _bullets(List<String> lines) =>
    lines.map((String line) => '  - $line').join('\n');

String _dp(Size size) => '${_number(size.width)} x ${_number(size.height)} dp';

String _number(double value) => value.toStringAsFixed(1);
