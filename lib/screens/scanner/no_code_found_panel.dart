import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'scanner_keys.dart';
import 'scanner_layout.dart';
import 'scanner_sheet.dart';

/// SCAN-11: the picked photo held no code.
///
/// "No code found", one hint, then "Try another photo", the largest control,
/// and "Type a code". It says what happened and what to do next, and nothing
/// counts as a successful scan (DATA-8).
///
/// Presentational: it shows while `ScannerState.showsNoCodeFound` is true, and
/// every tap goes back up through a callback.
class NoCodeFoundPanel extends StatelessWidget {
  const NoCodeFoundPanel({
    required this.busy,
    required this.onTryAnotherPhoto,
    required this.onTypeCode,
    required this.onClose,
    super.key,
  });

  /// Whether a photo is being read, so a second tap does nothing.
  final bool busy;

  final VoidCallback onTryAnotherPhoto;
  final VoidCallback onTypeCode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ScannerSheet(
      key: ScannerKeys.noCodeFound,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScannerSheetHeader(
            title: l10n.noCodeFoundTitle,
            subtitle: l10n.noCodeFoundHint,
            icon: Icons.image_search,
            closeKey: ScannerKeys.closeNoCodeFound,
            onClose: onClose,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    key: ScannerKeys.tryAnotherPhoto,
                    onPressed: busy ? null : onTryAnotherPhoto,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        ScannerLayout.primaryActionHeight,
                      ),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.tryAnotherPhotoButton),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: ScannerKeys.noCodeTypeCode,
                    onPressed: busy ? null : onTypeCode,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppTheme.minTapTargetSize,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_outlined),
                    label: Text(l10n.typeCodeButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
