import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generator/generator_form.dart';
import '../../l10n/app_localizations.dart';
import '../../models/parsed_payload.dart' show WifiSecurity;
import '../../state/generator_state.dart';
import '../result/result_labels.dart' show ResultLabels;
import 'create_text_field.dart';
import 'field_messages.dart';

/// GEN-5's Wi-Fi form: network name (required), security, password (masked
/// with a reveal button) and a hidden-network switch.
class WifiFormFields extends StatefulWidget {
  const WifiFormFields({super.key});

  static const Key ssidFieldKey = Key('create.wifi.ssid');
  static const Key securityFieldKey = Key('create.wifi.security');
  static const Key passwordFieldKey = Key('create.wifi.password');
  static const Key revealPasswordKey = Key('create.wifi.reveal_password');
  static const Key hiddenSwitchKey = Key('create.wifi.hidden');

  @override
  State<WifiFormFields> createState() => _WifiFormFieldsState();
}

class _WifiFormFieldsState extends State<WifiFormFields> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final GeneratorState state = context.watch<GeneratorState>();
    final WifiForm form = state.form as WifiForm;
    final GeneratorState generator = context.read<GeneratorState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CreateTextField(
          fieldKey: WifiFormFields.ssidFieldKey,
          initialValue: form.ssid,
          onChanged: generator.updateWifiSsid,
          label: l10n.createWifiSsidLabel,
          errorText: l10n.generatorFieldErrorMessage(
            state.fieldErrors[WifiForm.fieldSsid],
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<WifiSecurity>(
          key: WifiFormFields.securityFieldKey,
          initialValue: form.security,
          // The label wraps instead of overflowing at 200% text (A11Y-4).
          isExpanded: true,
          itemHeight: null,
          decoration: InputDecoration(
            labelText: l10n.createWifiSecurityLabel,
            border: const OutlineInputBorder(),
          ),
          items: <DropdownMenuItem<WifiSecurity>>[
            for (final WifiSecurity security in wifiSecurityChoices)
              DropdownMenuItem<WifiSecurity>(
                value: security,
                child: Text(_securityLabel(l10n, security)),
              ),
          ],
          onChanged: (WifiSecurity? security) {
            if (security != null) {
              generator.updateWifiSecurity(security);
            }
          },
        ),
        if (form.security != WifiSecurity.none) ...<Widget>[
          const SizedBox(height: 16),
          CreateTextField(
            fieldKey: WifiFormFields.passwordFieldKey,
            initialValue: form.password,
            onChanged: generator.updateWifiPassword,
            label: l10n.createWifiPasswordLabel,
            obscureText: !_revealed,
            suffixIcon: IconButton(
              key: WifiFormFields.revealPasswordKey,
              tooltip: _revealed
                  ? l10n.resultWifiHidePasswordTooltip
                  : l10n.resultWifiRevealPasswordTooltip,
              icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _revealed = !_revealed),
            ),
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          key: WifiFormFields.hiddenSwitchKey,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.createWifiHiddenLabel),
          value: form.hidden,
          onChanged: (bool hidden) =>
              generator.updateWifiHidden(hidden: hidden),
        ),
      ],
    );
  }

  /// GEN-5: every security choice reuses the label RES-4 shows, except WEP —
  /// labelled insecure here, unlike the plain "WEP" a result shows next to
  /// its own separate warning line.
  String _securityLabel(AppLocalizations l10n, WifiSecurity security) =>
      switch (security) {
        WifiSecurity.wpa => l10n.createWifiSecurityWpaWpa2,
        WifiSecurity.wep => l10n.createWifiSecurityWepInsecure,
        _ => l10n.wifiSecurityLabel(security),
      };
}
