import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/payload_classifier.dart' show maskSensitive;
import '../../models/record_enums.dart' show Symbology;
import '../../state/generator_state.dart';
import '../scanner/code_labels.dart';
import '../scanner/scanner_layout.dart';
import 'create_actions.dart';

/// STY-1, STY-5, SAVE-1's created-code screen: the plain code, what it
/// contains, and Save and Share as the two largest buttons, equal in size,
/// with nothing else competing (no ad, no upsell, ADS-1).
///
/// While `GeneratorState.isCreating` is true (STY-5's own check is running),
/// this shows progress instead. Once it finishes, a mismatch says so and
/// keeps Save and Share disabled (`GeneratorState.canSaveOrShare`); a
/// failed History write (GEN-13) is noted too, but never blocks either
/// button.
class CreatedCodeView extends StatelessWidget {
  const CreatedCodeView({super.key});

  static const Key progressKey = Key('create.created.progress');
  static const Key imageKey = Key('create.created.image');
  static const Key checkFailedKey = Key('create.created.check_failed');
  static const Key notSavedKey = Key('create.created.not_saved_history');
  static const Key saveButtonKey = Key('create.created.save');
  static const Key shareButtonKey = Key('create.created.share');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();

    if (state.isCreating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(
              key: progressKey,
              semanticsLabel: l10n.createCheckingMessage,
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(l10n.createCheckingMessage),
            ),
          ],
        ),
      );
    }

    final Uint8List? png = state.renderedPng;
    final QrCreateError? error = state.checkError;
    final String? payload = state.encodedPayload;
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.typeAndFormat(state.type, Symbology.qr).toUpperCase(),
            style: AppTheme.mono(
              size: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (png != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.light.paper,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppTheme.radius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(20),
                child: Center(
                  child: Image.memory(
                    png,
                    key: imageKey,
                    width: 240,
                    height: 240,
                    semanticLabel: l10n.createCodeImageLabel,
                  ),
                ),
              ),
            ),
          if (payload != null) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              l10n.createContentLabel.toUpperCase(),
              style: AppTheme.mono(
                size: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            // A Wi-Fi password stays masked here too (DATA-5).
            SelectableText(
              maskSensitive(payload, state.type),
              textDirection: TextDirection.ltr,
              style: AppTheme.mono(
                size: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          if (error != null) ...<Widget>[
            const SizedBox(height: 16),
            _Notice(key: checkFailedKey, message: _messageFor(l10n, error)),
          ],
          if (state.historyWriteFailed) ...<Widget>[
            const SizedBox(height: 12),
            _Notice(key: notSavedKey, message: l10n.createNotSavedToHistory),
          ],
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  key: saveButtonKey,
                  onPressed: state.canSaveOrShare
                      ? () => unawaited(saveCreatedCode(context))
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      ScannerLayout.primaryActionHeight,
                    ),
                  ),
                  icon: const Icon(Icons.save_alt),
                  label: Text(l10n.createSaveButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: shareButtonKey,
                  onPressed: state.canSaveOrShare
                      ? () => unawaited(shareCreatedCode(context))
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      ScannerLayout.primaryActionHeight,
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: Text(l10n.createShareButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _messageFor(AppLocalizations l10n, QrCreateError error) =>
      switch (error) {
        QrCreateError.renderFailed => l10n.createCheckFailedRenderFailed,
        QrCreateError.decodeFailed => l10n.createCheckFailedDecodeFailed,
        QrCreateError.mismatch => l10n.createCheckFailedMismatch,
      };
}

/// A one-line note with an icon, never colour alone (A11Y-6): STY-5's
/// mismatch message and GEN-13's failed-history-write note.
class _Notice extends StatelessWidget {
  const _Notice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.error_outline, color: theme.colorScheme.error),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
