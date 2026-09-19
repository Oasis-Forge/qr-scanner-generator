import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'scanner/scanner_layout.dart';

/// "Type a code" (SCAN-12): a multi-line field and a Scan button.
///
/// Presentational: it only collects the text. Scan closes the screen and hands
/// the text back to the scanner, which runs it through the same parsers as a
/// camera scan and opens the same result screen, with source `manual`
/// (SCAN-12, RES-3).
///
/// Scan is the largest control and stays disabled while the field holds
/// nothing but whitespace. The text is typed left to right, as codes are, even
/// in Arabic, while the label and the hint follow the app's direction
/// (LANG-5).
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  /// The route the scanner opens typed entry with; it completes with the text
  /// to scan, or null when the user backs out.
  static Route<String> route() => MaterialPageRoute<String>(
    builder: (BuildContext context) => const ManualEntryScreen(),
  );

  /// The field the code is typed into.
  static const Key fieldKey = Key('manual_entry.field');

  /// Scan, the largest control.
  static const Key scanKey = Key('manual_entry.scan');

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  /// Redraws the button as the field fills or empties.
  void _onTextChanged() => setState(() {});

  bool get _hasText => _controller.text.trim().isNotEmpty;

  void _scan() {
    if (_hasText) {
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualEntryTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
          children: <Widget>[
            TextField(
              key: ManualEntryScreen.fieldKey,
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: l10n.manualEntryFieldLabel,
                hintText: l10n.manualEntryFieldHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: ManualEntryScreen.scanKey,
              onPressed: _hasText ? _scan : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  ScannerLayout.primaryActionHeight,
                ),
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.manualEntryScanButton),
            ),
          ],
        ),
      ),
    );
  }
}
