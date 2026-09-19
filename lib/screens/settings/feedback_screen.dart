import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../services/app_version_info.dart';
import '../../services/system_intents.dart';
import 'settings_rows.dart';

/// The address every feedback email goes to: the one on the Play listing,
/// never a personal address (SET-8).
const String feedbackSupportEmail = 'oasisforge.support@gmail.com';

/// The five things feedback can be about (SET-8).
enum FeedbackCategory { scanning, results, creatingCodes, ads, other }

/// Settings → Feedback (SET-8): a category, a message, and a Send button that
/// opens the user's email app prefilled. The app itself sends nothing.
///
/// Presentational only (`CLAUDE.md`): the only device call is
/// [SystemIntents.composeEmail], read from [AppServices]; the category and the
/// typed text are this screen's own local state, never written anywhere.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({this.versionDetails, super.key});

  /// Already-loaded versions, so this screen doesn't ask [AppVersionInfo]
  /// again when the caller (Settings → About) already has them. `null` makes
  /// this screen load its own.
  final AppVersionDetails? versionDetails;

  /// The category chips (SET-8).
  static const Key scanningCategoryKey = Key('feedback.category.scanning');
  static const Key resultsCategoryKey = Key('feedback.category.results');
  static const Key creatingCodesCategoryKey = Key(
    'feedback.category.creating_codes',
  );
  static const Key adsCategoryKey = Key('feedback.category.ads');
  static const Key otherCategoryKey = Key('feedback.category.other');

  /// The typed message.
  static const Key messageFieldKey = Key('feedback.message');

  /// The largest button on the screen, and the only real action (`CLAUDE.md`).
  static const Key sendButtonKey = Key('feedback.send');

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _messageController = TextEditingController();
  FeedbackCategory? _category;
  AppVersionDetails? _details;

  @override
  void initState() {
    super.initState();
    _details = widget.versionDetails;
    if (_details == null) {
      unawaited(_loadDetails());
    }
  }

  Future<void> _loadDetails() async {
    final AppVersionDetails details = await context
        .read<AppServices>()
        .versionInfo
        .load();
    if (!mounted) {
      return;
    }
    setState(() => _details = details);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFeedback)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  l10n.feedbackCategoryLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final (Key key, FeedbackCategory value, String label)
                      in <(Key, FeedbackCategory, String)>[
                        (
                          FeedbackScreen.scanningCategoryKey,
                          FeedbackCategory.scanning,
                          l10n.feedbackCategoryScanning,
                        ),
                        (
                          FeedbackScreen.resultsCategoryKey,
                          FeedbackCategory.results,
                          l10n.feedbackCategoryResults,
                        ),
                        (
                          FeedbackScreen.creatingCodesCategoryKey,
                          FeedbackCategory.creatingCodes,
                          l10n.feedbackCategoryCreatingCodes,
                        ),
                        (
                          FeedbackScreen.adsCategoryKey,
                          FeedbackCategory.ads,
                          l10n.feedbackCategoryAds,
                        ),
                        (
                          FeedbackScreen.otherCategoryKey,
                          FeedbackCategory.other,
                          l10n.feedbackCategoryOther,
                        ),
                      ])
                    ToggleChoiceButton(
                      key: key,
                      label: label,
                      selected: _category == value,
                      onPressed: () => setState(() => _category = value),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                key: FeedbackScreen.messageFieldKey,
                controller: _messageController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: l10n.feedbackMessageHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // The largest button is always the real action (`CLAUDE.md`).
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: FeedbackScreen.sendButtonKey,
                  onPressed: _category == null
                      ? null
                      : () => unawaited(_send(context)),
                  child: Text(l10n.feedbackSendButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send(BuildContext context) async {
    final FeedbackCategory? category = _category;
    if (category == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SystemIntents systemIntents = context
        .read<AppServices>()
        .systemIntents;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppVersionDetails? details = _details;

    final String subject = l10n.feedbackEmailSubject(
      l10n.appTitle,
      details?.version ?? '',
      details?.buildNumber ?? '',
      details?.androidVersion ?? '',
    );
    final String body =
        '[${_categoryLabel(l10n, category)}]\n\n${_messageController.text}';

    final SystemHandOffOutcome outcome = await systemIntents.composeEmail(
      to: <String>[feedbackSupportEmail],
      subject: subject,
      body: body,
    );
    if (outcome != SystemHandOffOutcome.handedOff && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.feedbackSendNoHandler)),
      );
    }
  }

  String _categoryLabel(AppLocalizations l10n, FeedbackCategory category) =>
      switch (category) {
        FeedbackCategory.scanning => l10n.feedbackCategoryScanning,
        FeedbackCategory.results => l10n.feedbackCategoryResults,
        FeedbackCategory.creatingCodes => l10n.feedbackCategoryCreatingCodes,
        FeedbackCategory.ads => l10n.feedbackCategoryAds,
        FeedbackCategory.other => l10n.feedbackCategoryOther,
      };
}
