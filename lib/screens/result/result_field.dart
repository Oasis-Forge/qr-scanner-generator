import 'package:flutter/material.dart';

/// One labelled field in a result's content section (RES-4, RES-6, RES-7,
/// RES-9, RES-8): a small label above a selectable value.
///
/// [forceLtr] keeps a value that is a number, a code, a phone number or an
/// email address left to right even inside an Arabic screen (LANG-5); free
/// text (a name, a note) leaves [forceLtr] false, so Arabic content in it
/// reads right to left as any other Arabic text on the screen would.
class ResultField extends StatelessWidget {
  const ResultField({
    required this.label,
    required this.value,
    this.forceLtr = false,
    this.trailing,
    super.key,
  });

  final String label;
  final String value;
  final bool forceLtr;

  /// A control next to the value, such as RES-4's reveal-password button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool screenIsRtl = Directionality.of(context) == TextDirection.rtl;
    final Widget valueText = SelectableText(
      value,
      textDirection: forceLtr ? TextDirection.ltr : null,
      textAlign: forceLtr
          ? (screenIsRtl ? TextAlign.right : TextAlign.left)
          : null,
      style: theme.textTheme.bodyLarge,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          if (trailing == null)
            valueText
          else
            Row(
              children: <Widget>[
                Expanded(child: valueText),
                trailing!,
              ],
            ),
        ],
      ),
    );
  }
}

/// A one-line note next to a field: a WEP warning (RES-4), an all-day flag
/// (RES-6). Carries the words, not just an icon, so nothing here is said by
/// colour alone (A11Y-6).
class ResultNote extends StatelessWidget {
  const ResultNote({
    required this.message,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// The bordered box every result's content section sits in, matching the
/// one the base result screen has always drawn around the full decoded
/// content (RES-1).
class ResultContentBox extends StatelessWidget {
  const ResultContentBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: child,
      ),
    );
  }
}
