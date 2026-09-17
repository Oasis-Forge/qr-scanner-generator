import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/services/crash_reporter.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/services/wifi_service.dart';

/// Every device capability the app uses, in one place.
///
/// A container and nothing else: it holds one implementation of each interface
/// and builds none of them itself, so nothing here can reach a plugin. Only the
/// app's entry point wires the real implementations; everything else, tests
/// included, takes an [AppServices] it was handed (`CLAUDE.md`).
class AppServices {
  const AppServices({
    required this.cameraScanner,
    required this.imageDecoder,
    required this.permissions,
    required this.clipboard,
    required this.share,
    required this.crashReporter,
    required this.ads,
    required this.consent,
    required this.billing,
    required this.linkOpener,
    required this.systemIntents,
    required this.wifi,
  });

  /// The no-op set: a fake for every capability, none of which does any I/O.
  ///
  /// This is the default for tests. It is a factory, not a `const` constructor,
  /// because each fake records the calls made to it and so must be a fresh,
  /// mutable instance per test; a shared instance would carry one test's calls
  /// into the next.
  factory AppServices.fakes() => AppServices(
    cameraScanner: NoopCameraScanner(),
    imageDecoder: NoopImageDecoder(),
    permissions: NoopPermissionService(),
    clipboard: NoopClipboardService(),
    share: NoopShareService(),
    crashReporter: NoopCrashReporter(),
    ads: NoopAdsService(),
    consent: NoopConsentService(),
    billing: NoopBillingService(),
    linkOpener: NoopLinkOpener(),
    systemIntents: NoopSystemIntents(),
    wifi: NoopWifiService(),
  );

  /// The live camera (SCAN, RUN).
  final CameraScanner cameraScanner;

  /// Codes in a picked or shared image (SCAN-11, ENTRY-2).
  final ImageDecoder imageDecoder;

  /// The camera permission (RUN-3 to RUN-6).
  final PermissionService permissions;

  /// Copy and paste (RES-1, SET-3).
  final ClipboardService clipboard;

  /// Share, and saving a file through the system picker (SAVE-1, SAVE-2, EXP-1).
  final ShareService share;

  /// Crash reports, off until the user opts in (PRIV-3).
  final CrashReporter crashReporter;

  /// Banner ads (ADS).
  final AdsService ads;

  /// Ad consent (PRIV-1, PRIV-2).
  final ConsentService consent;

  /// The one-time Pro purchase (PRO).
  final BillingService billing;

  /// Links, in Custom Tabs (LINK-8).
  final LinkOpener linkOpener;

  /// Hand-offs to the system's own apps (RES-4, RES-6, RES-7, RES-8).
  final SystemIntents systemIntents;

  /// Joining a scanned network (RES-5).
  final WifiService wifi;
}
