import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/scanner_state.dart';
import 'scanner_keys.dart';
import 'scanner_layout.dart';

/// The scanner area while there is no live camera: RUN-1's placeholder, and
/// what follows a denial (RUN-4, RUN-6) or a camera that didn't start.
///
/// Presentational (`CLAUDE.md`): [phase] and [offersPhotoAndTyping] come from
/// `ScannerState`, and every tap goes back up through a callback.
///
/// * [ScannerPhase.needsPermission]: one reason of at most 70 characters and
///   "Allow camera", the largest control (RUN-1). Nothing else asks (RUN-3).
/// * [ScannerPhase.denied]: the same, plus "Scan a photo" and "Type a code",
///   always visible (RUN-4).
/// * [ScannerPhase.permanentlyDenied]: as denied, but the button is "Open
///   settings" (RUN-6).
/// * [ScannerPhase.cameraUnavailable]: says the camera couldn't start and
///   offers "Scan a photo" and "Type a code"; there is nothing to allow.
///
/// It scrolls rather than clips, so at 200% text every control stays
/// reachable (A11Y-4).
class PermissionPlaceholder extends StatelessWidget {
  const PermissionPlaceholder({
    required this.phase,
    required this.offersPhotoAndTyping,
    required this.busy,
    required this.onAllowCamera,
    required this.onOpenSettings,
    required this.onScanPhoto,
    required this.onTypeCode,
    super.key,
  });

  final ScannerPhase phase;

  /// `ScannerState.offersPhotoAndTyping` (RUN-4).
  final bool offersPhotoAndTyping;

  /// Whether a photo is being read, so a second tap does nothing (SCAN-11).
  final bool busy;

  final VoidCallback onAllowCamera;
  final VoidCallback onOpenSettings;
  final VoidCallback onScanPhoto;
  final VoidCallback onTypeCode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool unavailable = phase == ScannerPhase.cameraUnavailable;

    final Widget? primary = switch (phase) {
      ScannerPhase.needsPermission || ScannerPhase.denied => _PrimaryButton(
        buttonKey: ScannerKeys.allowCamera,
        label: l10n.cameraAllowButton,
        onPressed: onAllowCamera,
      ),
      ScannerPhase.permanentlyDenied => _PrimaryButton(
        buttonKey: ScannerKeys.openSettings,
        label: l10n.cameraOpenSettingsButton,
        onPressed: onOpenSettings,
      ),
      ScannerPhase.cameraUnavailable ||
      ScannerPhase.checking ||
      ScannerPhase.granted => null,
    };

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const EdgeInsetsDirectional padding =
                EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 32);
            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(
                    0,
                    constraints.maxHeight - padding.vertical,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      unavailable
                          ? Icons.no_photography_outlined
                          : Icons.photo_camera_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      unavailable
                          ? l10n.scanCameraUnavailable
                          : l10n.cameraPermissionReason,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ?primary,
                    if (offersPhotoAndTyping) ...<Widget>[
                      if (primary != null) const SizedBox(height: 12),
                      _SecondaryButton(
                        buttonKey: ScannerKeys.scanPhoto,
                        icon: Icons.photo_library_outlined,
                        label: l10n.scanFromPhotoButton,
                        onPressed: busy ? null : onScanPhoto,
                      ),
                      const SizedBox(height: 12),
                      _SecondaryButton(
                        buttonKey: ScannerKeys.typeCode,
                        icon: Icons.keyboard_outlined,
                        label: l10n.typeCodeButton,
                        onPressed: busy ? null : onTypeCode,
                      ),
                    ],
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

/// The one real action: full width and [ScannerLayout.primaryActionHeight]
/// tall, so it is the largest control on the placeholder (RUN-1).
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: buttonKey,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(ScannerLayout.primaryActionHeight),
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

/// "Scan a photo" and "Type a code": outlined, [AppTheme.minTapTargetSize]
/// tall, and always with their text next to the icon (A11Y-1).
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: buttonKey,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTheme.minTapTargetSize),
      ),
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}
