import 'package:flutter/material.dart';

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
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab.index,
          onDestinationSelected: (int index) => _select(AppTab.values[index]),
          destinations: <Widget>[
            NavigationDestination(
              key: AppShell.scanTabKey,
              icon: const Icon(Icons.qr_code_scanner),
              label: l10n.navScan,
            ),
            NavigationDestination(
              key: AppShell.createTabKey,
              icon: const Icon(Icons.add_box_outlined),
              selectedIcon: const Icon(Icons.add_box),
              label: l10n.navCreate,
            ),
            NavigationDestination(
              key: AppShell.historyTabKey,
              icon: const Icon(Icons.history),
              label: l10n.navHistory,
            ),
            NavigationDestination(
              key: AppShell.settingsTabKey,
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
