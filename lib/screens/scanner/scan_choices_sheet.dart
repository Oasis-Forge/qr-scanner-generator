import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/scan_outcome.dart';
import 'code_labels.dart';
import 'payload_text.dart';
import 'scanner_keys.dart';
import 'scanner_sheet.dart';

/// SCAN-13: one detection pass found two or more codes, so the app lists them
/// instead of guessing, and the chosen one opens its result.
///
/// Each row shows the type icon, the first 40 characters of the payload
/// (ended with an ellipsis when cut), and the type and format in words, so the
/// type is never told by the icon alone (A11Y-6). A binary payload reads
/// "Binary data, N bytes" (RES-13). Payloads stay left to right in Arabic
/// (LANG-5).
///
/// Presentational: the rows come from `ScannerState.choices`, a tap goes to
/// [onChoose] and the close button to [onClose].
class ScanChoicesSheet extends StatelessWidget {
  const ScanChoicesSheet({
    required this.choices,
    required this.onChoose,
    required this.onClose,
    super.key,
  });

  final List<ScanChoice> choices;
  final ValueChanged<ScanChoice> onChoose;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ScannerSheet(
      key: ScannerKeys.choicesSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScannerSheetHeader(
            title: l10n.scanChoicesTitle(choices.length),
            subtitle: l10n.scanChoicesHint,
            icon: Icons.qr_code_2,
            closeKey: ScannerKeys.closeChoices,
            onClose: onClose,
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsetsDirectional.only(bottom: 8),
              itemCount: choices.length,
              itemBuilder: (BuildContext context, int index) {
                final ScanChoice choice = choices[index];
                return _ChoiceRow(
                  key: ScannerKeys.choice(index),
                  choice: choice,
                  onTap: () => onChoose(choice),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// One code in the list (SCAN-13).
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.choice, required this.onTap, super.key});

  final ScanChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Widget title = choice.isBinary
        ? Text(l10n.scanBinaryData(choice.byteCount ?? 0))
        : PayloadText(
            choice.isPreviewTruncated ? '${choice.preview}…' : choice.preview,
            type: choice.parsedType,
          );
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
      leading: Icon(parsedTypeIcon(choice.parsedType)),
      title: title,
      subtitle: Text(l10n.typeAndFormat(choice.parsedType, choice.symbology)),
      onTap: onTap,
    );
  }
}
