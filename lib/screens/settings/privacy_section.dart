import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/consent_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../state/settings_state.dart';
import 'settings_rows.dart';

/// Whether Settings shows the "Send crash reports" row at all.
///
/// Firebase is not wired into this app yet — no `google-services.json`, and
/// `CrashReporter` stays the no-op fake everywhere (`PRIV-3`, `PRIV-8`) — so a
/// switch that would send nothing must never appear to promise otherwise.
/// Flip this once a real `CrashReporter` is built and wired in `main.dart`.
const bool crashReportsAvailable = false;

/// Settings' second group: save history, send crash reports (while
/// [crashReportsAvailable]) and privacy options (SET-5, HIS-8, PRIV-2,
/// PRIV-3).
///
/// Presentational only (`CLAUDE.md`): it reads [SettingsState] with
/// `context.watch`, reads [AppServices] for the consent SDK's own
/// `privacyOptionsRequired` flag (PRIV-2), and touches no store, no database
/// and no other device service.
class PrivacySection extends StatelessWidget {
  const PrivacySection({super.key});

  /// The save-history switch (HIS-8).
  static const Key saveHistoryKey = Key('settings.save_history');

  /// The send-crash-reports switch, present only while
  /// [crashReportsAvailable] (PRIV-3).
  static const Key sendCrashReportsKey = Key('settings.send_crash_reports');

  /// The row that reopens the consent form (PRIV-2).
  static const Key privacyOptionsKey = Key('settings.privacy_options');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SettingsState settings = context.watch<SettingsState>();
    final ConsentService consent = context.read<AppServices>().consent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingsSectionHeader(title: l10n.settingsGroupPrivacy),
        SettingsSwitchRow(
          switchKey: saveHistoryKey,
          label: l10n.settingsSaveHistory,
          value: settings.saveHistory,
          onChanged: (bool enabled) =>
              context.read<SettingsState>().setSaveHistory(enabled: enabled),
        ),
        if (crashReportsAvailable)
          SettingsSwitchRow(
            switchKey: sendCrashReportsKey,
            label: l10n.settingsSendCrashReports,
            value: settings.sendCrashReports,
            onChanged: (bool enabled) => context
                .read<SettingsState>()
                .setSendCrashReports(enabled: enabled),
          ),
        if (consent.privacyOptionsRequired)
          SettingsNavRow(
            rowKey: privacyOptionsKey,
            title: l10n.settingsPrivacyOptions,
            onTap: () => unawaited(consent.showPrivacyOptions()),
          ),
      ],
    );
  }
}
