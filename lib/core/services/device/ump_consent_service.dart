import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart' as ump;

import '../consent_service.dart';

/// UMP's own status → this app's [ConsentStatus] (PRIV-1).
ConsentStatus mapConsentStatus(ump.ConsentStatus status) {
  switch (status) {
    case ump.ConsentStatus.notRequired:
      return ConsentStatus.notNeeded;
    case ump.ConsentStatus.obtained:
      return ConsentStatus.obtained;
    case ump.ConsentStatus.required:
      return ConsentStatus.formRequired;
    case ump.ConsentStatus.unknown:
      return ConsentStatus.unresolved;
  }
}

/// Whether Settings shows "Privacy options" for [status] (PRIV-2).
bool mapPrivacyOptionsRequired(ump.PrivacyOptionsRequirementStatus status) =>
    status == ump.PrivacyOptionsRequirementStatus.required;

/// Whether a personalised ad may be requested once [status] already allows
/// ads at all (ADS-5).
///
/// UMP's `ConsentStatus.obtained` means only that a region's required message
/// was answered, not what the user chose inside it: reading that choice needs
/// the IAB TCF strings UMP writes to on-device storage, which this app never
/// parses. So this stays conservative on top of what UMP itself reports: only
/// [ConsentStatus.notNeeded] (a region UMP says needs no message at all)
/// defaults to personalised; every region that had to be asked gets
/// non-personalised ads, answered or not.
bool personalizedAdsAllowedFor(ConsentStatus status) =>
    status == ConsentStatus.notNeeded;

/// Ad consent through Google's User Messaging Platform (PRIV-1, PRIV-2).
///
/// [refresh] only calls [ump.ConsentInformation.requestConsentInfoUpdate] and
/// reads the result back; it never loads or shows a form, so it stays silent
/// at every start (PRIV-1). [showFormIfRequired] is the one call that may put
/// UI on screen, and only shows anything when UMP itself says a message is
/// required. Both, and [showPrivacyOptions], leave [canRequestAds] as UMP's
/// own answer to "can this session request ads at all" (ADS-5); a failure to
/// resolve consent at all (offline, a plugin error) is read the same way as
/// UMP reporting no ads may be requested, per ADS-5.
///
/// Built only by the app's entry point.
class UmpConsentService implements ConsentService {
  UmpConsentService({ump.ConsentDebugSettings? debugSettings})
    : _debugSettings = debugSettings;

  /// Hardcodes a debug geography and test device ids in test requests.
  ///
  /// `null` in production; the entry point may pass one only in a debug
  /// build, so this reusable service never decides that for itself.
  final ump.ConsentDebugSettings? _debugSettings;

  ConsentStatus _status = ConsentStatus.unresolved;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  @override
  ConsentStatus get status => _status;

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  bool get personalizedAdsAllowed =>
      _canRequestAds && personalizedAdsAllowedFor(_status);

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  Future<ConsentStatus> refresh() async {
    final bool updated = await _requestConsentInfoUpdate();
    if (updated) {
      await _readResolvedState();
    } else {
      _markUnavailable();
    }
    return _status;
  }

  @override
  Future<ConsentStatus> showFormIfRequired() async {
    ump.FormError? dismissError;
    try {
      await ump.ConsentForm.loadAndShowConsentFormIfRequired((
        ump.FormError? error,
      ) {
        dismissError = error;
      });
    } on Object {
      dismissError = ump.FormError(errorCode: 0, message: 'load failed');
    }
    if (dismissError == null) {
      await _readResolvedState();
    } else {
      _markUnavailable();
    }
    return _status;
  }

  @override
  Future<void> showPrivacyOptions() async {
    await ump.ConsentForm.showPrivacyOptionsForm((ump.FormError? error) {});
    await _readResolvedState();
  }

  /// Wraps [ump.ConsentInformation.requestConsentInfoUpdate]'s success and
  /// failure callbacks into the one `bool` [refresh] needs: whether consent
  /// info is now current enough to read [_readResolvedState].
  Future<bool> _requestConsentInfoUpdate() async {
    bool succeeded = false;
    try {
      final Completer<void> done = Completer<void>();
      ump.ConsentInformation.instance.requestConsentInfoUpdate(
        ump.ConsentRequestParameters(consentDebugSettings: _debugSettings),
        () {
          succeeded = true;
          if (!done.isCompleted) {
            done.complete();
          }
        },
        (ump.FormError error) {
          succeeded = false;
          if (!done.isCompleted) {
            done.complete();
          }
        },
      );
      await done.future;
    } on Object {
      succeeded = false;
    }
    return succeeded;
  }

  Future<void> _readResolvedState() async {
    try {
      final ump.ConsentStatus raw = await ump.ConsentInformation.instance
          .getConsentStatus();
      final bool canRequest = await ump.ConsentInformation.instance
          .canRequestAds();
      final ump.PrivacyOptionsRequirementStatus privacyOptions = await ump
          .ConsentInformation
          .instance
          .getPrivacyOptionsRequirementStatus();
      _status = mapConsentStatus(raw);
      _canRequestAds = canRequest;
      _privacyOptionsRequired = mapPrivacyOptionsRequired(privacyOptions);
    } on Object {
      _markUnavailable();
    }
  }

  /// Consent couldn't be resolved this session (offline, a plugin error): no
  /// ad is requested at all, personalised or not (ADS-5).
  void _markUnavailable() {
    _status = ConsentStatus.unavailable;
    _canRequestAds = false;
  }
}
