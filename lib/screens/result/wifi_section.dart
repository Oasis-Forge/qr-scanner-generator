import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart';
import '../../models/payload_classifier.dart' show maskedSecret;
import '../../state/result_state.dart';
import 'result_actions.dart';
import 'result_field.dart';
import 'result_labels.dart';

/// A Wi-Fi network (RES-4): network name, security, and the password masked
/// with a reveal button; no password row for an open network. The primary
/// action is "Open Wi-Fi settings", with "Copy password" beside it, plus the
/// Copy and Share every result gets (RES-1).
class WifiSection extends StatelessWidget {
  const WifiSection({required this.wifi, super.key});

  final Wifi wifi;

  static const Key revealPasswordKey = Key('result.wifi.reveal_password');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResultState state = context.watch<ResultState>();
    final bool revealed = state.isWifiPasswordRevealed;
    final String? password = wifi.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ResultContentBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ResultField(
                label: l10n.resultWifiNetworkNameLabel,
                value: wifi.ssid,
              ),
              ResultField(
                label: l10n.resultWifiSecurityLabel,
                value: l10n.wifiSecurityLabel(wifi.security),
              ),
              if (password != null)
                ResultField(
                  label: l10n.resultWifiPasswordLabel,
                  value: revealed ? password : maskedSecret,
                  forceLtr: true,
                  trailing: IconButton(
                    key: revealPasswordKey,
                    tooltip: revealed
                        ? l10n.resultWifiHidePasswordTooltip
                        : l10n.resultWifiRevealPasswordTooltip,
                    icon: Icon(
                      revealed ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: state.toggleWifiPasswordRevealed,
                  ),
                ),
              if (wifi.security == WifiSecurity.wep)
                ResultNote(message: l10n.resultWifiWepNotice),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ResultPrimaryButton(
          label: l10n.resultWifiPrimaryButton,
          icon: Icons.wifi,
          onPressed: state.canOpenWifiSettings
              ? () => performHandOff(context, state.openWifiSettings)
              : null,
          unavailableReason: l10n.resultUnavailableWifiSettings,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (password != null)
              ResultSecondaryButton(
                label: l10n.resultWifiCopyPasswordButton,
                icon: Icons.key,
                onPressed: () => copyWifiPassword(context),
              ),
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
