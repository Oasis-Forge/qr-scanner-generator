import 'package:flutter/material.dart';

/// A tab whose feature ships in a later test build: Create and History until
/// their PRs land (SCAN-1).
///
/// It says so plainly, in the app's language, rather than showing an empty
/// screen or a control that does nothing. It holds no ad (ADS-1 allows one on
/// the History list and the Create type picker, not here).
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  /// The tab's name, as the bottom bar spells it.
  final String title;

  /// What is coming and when, from the message files (LANG-2).
  final String message;

  /// Drawn above the message, which says the same thing in words (A11Y-6).
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 64
                      ? constraints.maxHeight - 64
                      : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
