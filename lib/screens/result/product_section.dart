import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';
import 'result_labels.dart';

/// A retail product code — EAN-13, EAN-8, UPC-A, UPC-E or ISBN (RES-9): the
/// number and its format. The primary action, "Search the web", opens a
/// plain web search with the engine chosen in Settings (SET-4); no shopping
/// action, no product database, no warning.
class ProductSection extends StatelessWidget {
  const ProductSection({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResultState state = context.watch<ResultState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultField(
                label: l10n.resultProductNumberLabel,
                value: product.code,
                forceLtr: true,
              ),
              ResultField(
                label: l10n.resultProductFormatLabel,
                value: l10n.productFormatLabel(product.format),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultProductSearchButton,
          icon: Icons.search,
          onPressed: state.canSearchTheWeb
              ? () => performLinkHandOff(context, state.searchTheWeb)
              : null,
          unavailableReason: l10n.resultUnavailableBrowser,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ResultSecondaryButton(
              label: l10n.resultCopyButton,
              icon: Icons.copy,
              onPressed: () => copyContent(context),
            ),
            ResultSecondaryButton(
              label: l10n.resultShareButton,
              icon: Icons.share,
              onPressed: () => shareContent(context),
            ),
          ],
        ),
      ],
    );
  }
}
