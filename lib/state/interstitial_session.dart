/// Whether this run of the app has already shown its one interstitial (ADS-9).
///
/// ADS-9 allows one for each time the app is opened, whatever else is saved or
/// shared, so the count has to outlive the screen that triggers it. It is not a
/// `ChangeNotifier`: nothing on screen changes when the flag flips, and a
/// notifier would rebuild every watcher for a fact none of them draw.
///
/// Provided app-wide by `main.dart`, and freshly by the test harness, so a test
/// starts every case with the session's interstitial unspent.
class InterstitialSession {
  bool _shown = false;

  /// Whether the one interstitial for this session has been shown.
  bool get shown => _shown;

  /// Records that it has. There is no way back: the next one waits for the
  /// next time the app is opened.
  void markShown() {
    _shown = true;
  }
}
