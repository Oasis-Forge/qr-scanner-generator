import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A sheet over the scanner, anchored to the bottom edge: the list of codes
/// (SCAN-13) and "No code found" (SCAN-11).
///
/// It is drawn in the scanner's own tree from `ScannerState`, not pushed as a
/// route, so it can never outlive the state that opened it: when the state
/// clears the list or the message, the sheet is gone with it.
///
/// It never grows past [maxHeightFraction] of the space it is given, and its
/// content scrolls inside it, so nothing is clipped at 200% text (A11Y-4).
class ScannerSheet extends StatelessWidget {
  const ScannerSheet({required this.child, super.key});

  /// The largest share of the scanner area the sheet may cover.
  static const double maxHeightFraction = 0.85;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight * maxHeightFraction,
          ),
          child: Material(
            color: theme.colorScheme.surfaceContainerLow,
            elevation: 3,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(top: false, child: child),
          ),
        );
      },
    );
  }
}

/// The top of a [ScannerSheet]: a heading, one line under it, and a close
/// button that carries its name for a screen reader (A11Y-1).
class ScannerSheetHeader extends StatelessWidget {
  const ScannerSheetHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.closeKey,
    required this.onClose,
    super.key,
  });

  final String title;
  final String subtitle;

  /// Drawn beside the heading, which says the same thing in words, so the
  /// icon is never the only cue (A11Y-6).
  final IconData icon;

  final Key closeKey;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 12, end: 12),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          IconButton(
            key: closeKey,
            tooltip: AppLocalizations.of(context).actionClose,
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
