/// Where consent stands for this session (PRIV-1).
enum ConsentStatus {
  /// Not resolved yet. No ad may be requested (ADS-5).
  unresolved,

  /// The user's region needs no consent form.
  notNeeded,

  /// A form is required and hasn't been answered. It is shown only when an ad
  /// screen is about to request an ad (PRIV-1), which can now be the install's
  /// first launch if the user's first move is one of ADS-1's three screens
  /// (ADS-6, dropped 26 September 2026).
  formRequired,

  /// The user has answered the form.
  obtained,

  /// Consent could not be resolved, for example offline. No ad shows this
  /// session (ADS-5).
  unavailable,
}

/// Ad consent, refreshed silently at each start (PRIV-1).
///
/// The choice is stored on the device only (PRIV-8).
abstract class ConsentService {
  /// Refreshes the status silently, with no form and no dialog (PRIV-1).
  Future<ConsentStatus> refresh();

  ConsentStatus get status;

  /// Shows the consent form if one is required, and returns the status
  /// afterwards.
  ///
  /// Called only when an ad screen (ADS-1) is about to request an ad (PRIV-1).
  Future<ConsentStatus> showFormIfRequired();

  /// Whether an ad may be requested at all this session (ADS-5).
  bool get canRequestAds;

  /// Whether a requested ad may be personalised. False where consent was
  /// refused, so only non-personalised ads are asked for (ADS-5).
  bool get personalizedAdsAllowed;

  /// Whether Settings shows "Privacy options" for this user's region (PRIV-2).
  bool get privacyOptionsRequired;

  /// Reopens the consent form from Settings → Privacy options (PRIV-2).
  Future<void> showPrivacyOptions();
}

/// A [ConsentService] that contacts nothing.
///
/// It starts [ConsentStatus.unresolved] and [refresh] reports [seededStatus],
/// which defaults to [ConsentStatus.unavailable] so tests behave like a session
/// where consent could not be resolved and no ad may be requested (ADS-5).
/// [calls] records what was asked.
class NoopConsentService implements ConsentService {
  NoopConsentService({
    this.seededStatus = ConsentStatus.unavailable,
    bool personalizedAllowed = false,
    bool privacyOptionsRequired = false,
  }) : _personalizedAllowed = personalizedAllowed,
       _privacyOptionsRequired = privacyOptionsRequired;

  /// Every call made, in order, such as `'refresh'`.
  final List<String> calls = <String>[];

  /// What [refresh] and [showFormIfRequired] settle on.
  final ConsentStatus seededStatus;

  final bool _personalizedAllowed;
  final bool _privacyOptionsRequired;

  ConsentStatus _status = ConsentStatus.unresolved;

  @override
  ConsentStatus get status => _status;

  @override
  Future<ConsentStatus> refresh() async {
    calls.add('refresh');
    _status = seededStatus;
    return _status;
  }

  @override
  Future<ConsentStatus> showFormIfRequired() async {
    calls.add('showFormIfRequired');
    if (_status == ConsentStatus.formRequired) {
      _status = ConsentStatus.obtained;
    }
    return _status;
  }

  @override
  bool get canRequestAds =>
      _status == ConsentStatus.notNeeded || _status == ConsentStatus.obtained;

  @override
  bool get personalizedAdsAllowed => canRequestAds && _personalizedAllowed;

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  Future<void> showPrivacyOptions() async {
    calls.add('showPrivacyOptions');
  }
}
