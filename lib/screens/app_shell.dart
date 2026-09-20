import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'create_screen.dart';
import 'history_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

/// The four places the bottom bar leads to, in its order (SCAN-1).
enum AppTab { scan, create, history, settings }

/// The app's home: it opens on the live scanner, and a bottom navigation bar
/// leads to Scan, Create, History and Settings, each with an icon and a label
/// (SCAN-1). History is given the callbacks that switch this shell's own
/// tab from its empty state (HIS-11).
///
/// Only the chosen tab is built. Leaving Scan disposes the scanner screen,
/// which leaves the scanner, so the camera and the torch stop (SCAN-6), and
/// coming back enters it again, which turns auto-zoom back on (SCAN-7).
///
/// Back on any other tab returns to Scan; back on Scan leaves the app, with
/// Android's own predictive-back animation. The selected tab is marked by the
/// bar's indicator and a filled icon, and announced as selected, never by
/// colour alone (A11Y-6).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// The Scan destination (SCAN-1).
  static const Key scanTabKey = Key('shell.tab.scan');

  /// The Create destination (SCAN-1).
  static const Key createTabKey = Key('shell.tab.create');

  /// The History destination (SCAN-1).
  static const Key historyTabKey = Key('shell.tab.history');

  /// The Settings destination (SCAN-1).
  static const Key settingsTabKey = Key('shell.tab.settings');

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.scan;

  void _select(AppTab tab) {
    if (tab != _tab) {
      setState(() => _tab = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: _tab == AppTab.scan,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _select(AppTab.scan);
        }
      },
      child: Scaffold(
        body: switch (_tab) {
          AppTab.scan => const ScannerScreen(),
          AppTab.create => const CreateScreen(),
          AppTab.history => HistoryScreen(
            onSwitchToScan: () => _select(AppTab.scan),
            onSwitchToCreate: () => _select(AppTab.create),
            onSwitchToSettings: () => _select(AppTab.settings),
          ),
          AppTab.settings => const SettingsScreen(),
        },
        bottomNavigationBar: _TabRail(
          selected: _tab,
          onSelected: _select,
          tabs: <_Tab>[
            _Tab(
              key: AppShell.scanTabKey,
              tab: AppTab.scan,
              icon: Icons.qr_code_scanner,
              label: l10n.navScan,
            ),
            _Tab(
              key: AppShell.createTabKey,
              tab: AppTab.create,
              icon: Icons.add_box_outlined,
              label: l10n.navCreate,
            ),
            _Tab(
              key: AppShell.historyTabKey,
              tab: AppTab.history,
              icon: Icons.history,
              label: l10n.navHistory,
            ),
            _Tab(
              key: AppShell.settingsTabKey,
              tab: AppTab.settings,
              icon: Icons.tune,
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}

/// One destination on the rail.
class _Tab {
  const _Tab({
    required this.key,
    required this.tab,
    required this.icon,
    required this.label,
  });

  final Key key;
  final AppTab tab;
  final IconData icon;
  final String label;
}

/// The bottom rail: a hairline with the chosen tab marked by a signal line
/// above it, instead of Material's pill (SET-1's own look).
///
/// The label is drawn in the app's mono voice and in capitals, while the
/// screen reader is given the word as it is written, since a reader may spell
/// capitals out letter by letter (A11Y-1).
class _TabRail extends StatelessWidget {
  const _TabRail({
    required this.selected,
    required this.onSelected,
    required this.tabs,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;
  final List<_Tab> tabs;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = AppColors.read(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            for (final _Tab tab in tabs)
              Expanded(
                child: _RailItem(
                  key: tab.key,
                  tab: tab,
                  isSelected: tab.tab == selected,
                  onTap: () => onSelected(tab.tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final _Tab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = AppColors.read(context);
    final Color foreground = isSelected
        ? colors.signalText
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: tab.label,
      selected: isSelected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isSelected ? colors.signal : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            // Only as tall as its icon and label: the rail sits at the foot
            // of the screen, and a column left to fill would take the whole
            // height and swallow taps meant for the screen above it.
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(tab.icon, size: 20, color: foreground),
              const SizedBox(height: 6),
              Text(
                tab.label.toUpperCase(),
                style: AppTheme.mono(size: 10, color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
