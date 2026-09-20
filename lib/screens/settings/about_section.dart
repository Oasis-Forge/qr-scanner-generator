import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/link_opener.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../services/app_version_info.dart';
import 'feedback_screen.dart';
import 'settings_rows.dart';

/// The published privacy policy Settings → Privacy policy opens (SET-6).
///
/// A GitHub Pages site the user turns on separately; this only names the
/// published address.
const String privacyPolicyUrl =
    'https://oasis-forge.github.io/qr-scanner-generator/privacy/';

/// Settings' fourth group: feedback, privacy policy, open-source licences and
/// the version (SET-5, SET-6, SET-7, SET-8).
///
/// Presentational only (`CLAUDE.md`): it reads [AppVersionInfo] once, for the
/// version row and for [FeedbackScreen]'s subject line, and opens the privacy
/// policy through [AppServices.linkOpener] (LINK-8) and the licences page
/// through Flutter's own [showLicensePage].
class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  /// The row that opens [FeedbackScreen] (SET-8).
  static const Key feedbackKey = Key('settings.feedback');

  /// The row that opens [privacyPolicyUrl] in Custom Tabs (SET-6).
  static const Key privacyPolicyKey = Key('settings.privacy_policy');

  /// The row that opens Flutter's own licence page (SET-7).
  static const Key licencesKey = Key('settings.licences');

  /// The version row (SET-5).
  static const Key versionKey = Key('settings.version');

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  AppVersionDetails? _details;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDetails());
  }

  Future<void> _loadDetails() async {
    final AppVersionInfo info = context.read<AppServices>().versionInfo;
    final AppVersionDetails details = await info.load();
    if (!mounted) {
      return;
    }
    setState(() => _details = details);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppVersionDetails? details = _details;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingsSectionHeader(title: l10n.settingsGroupAbout),
        SettingsNavRow(
          rowKey: AboutSection.feedbackKey,
          title: l10n.settingsFeedback,
          onTap: () => _openFeedback(context, details),
        ),
        SettingsNavRow(
          rowKey: AboutSection.privacyPolicyKey,
          title: l10n.settingsPrivacyPolicy,
          onTap: () => unawaited(_openPrivacyPolicy(context)),
        ),
        SettingsNavRow(
          rowKey: AboutSection.licencesKey,
          title: l10n.settingsOpenSourceLicences,
          onTap: () => _openLicences(context, l10n.appTitle, details),
        ),
        SettingsNavRow(
          rowKey: AboutSection.versionKey,
          title: l10n.settingsVersion,
          trailingText: details == null
              ? null
              : l10n.settingsVersionValue(details.version, details.buildNumber),
        ),
      ],
    );
  }

  void _openFeedback(BuildContext context, AppVersionDetails? details) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              FeedbackScreen(versionDetails: details),
        ),
      ),
    );
  }

  /// Opens [privacyPolicyUrl] in Custom Tabs, falling back to the default
  /// browser, and says so when neither could (SET-6, LINK-8).
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final LinkOpener linkOpener = context.read<AppServices>().linkOpener;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failed = AppLocalizations.of(context).settingsLinkOpenFailed;
    final LinkOpenOutcome outcome = await linkOpener.open(
      Uri.parse(privacyPolicyUrl),
    );
    if (outcome == LinkOpenOutcome.noHandler ||
        outcome == LinkOpenOutcome.failed) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  /// Flutter's own licence page, including the credits LINK-6's bundled
  /// sources add to it (SET-7).
  void _openLicences(
    BuildContext context,
    String appTitle,
    AppVersionDetails? details,
  ) {
    showLicensePage(
      context: context,
      applicationName: appTitle,
      applicationVersion: details?.version,
    );
  }
}
