import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'ads/ad_banner_slot.dart';
import 'pro/pro_prompt.dart';
import 'settings/about_section.dart';
import 'settings/general_section.dart';
import 'settings/pro_section.dart';
import 'settings/privacy_section.dart';
import '../state/ads_state.dart';

/// The Settings tab (SCAN-1, SET-5).
///
/// Four groups, in order: General (SET-1, SET-2, SET-3, LANG-1), Privacy
/// (HIS-8, PRIV-2, PRIV-3), Pro (PRO-1, PRO-4, PRO-5, PRO-6) and About (SET-6,
/// SET-7, SET-8). The one Pro prompt (PRO-4) sits above them, and the ADS-1
/// banner slot is fixed at the bottom of this screen only — never inside the
/// scrolling groups (ADS-3).
///
/// Presentational only (`CLAUDE.md`): each group reads its own slice of state
/// with `context.read`/`context.watch` and touches no store, no database and
/// no device service directly; this screen itself lays them out and nothing
/// more.
///
/// Every string comes from the message files (LANG-2) and every edge inset is
/// directional, so Arabic mirrors the whole screen (LANG-5). The back gesture
/// belongs to the app shell, which returns to Scan before it leaves the app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: const SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ProPrompt(),
                    GeneralSection(),
                    SizedBox(height: 32),
                    PrivacySection(),
                    SizedBox(height: 32),
                    ProSection(),
                    SizedBox(height: 32),
                    AboutSection(),
                  ],
                ),
              ),
            ),
            // Fixed and non-scrolling, separated from the groups above by its
            // own divider, and clear of the app shell's bottom navigation bar
            // below (ADS-1, ADS-3).
            AdBannerSlot(slot: AdSlots.settings),
          ],
        ),
      ),
    );
  }
}
