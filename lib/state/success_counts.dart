import 'package:flutter/foundation.dart';

import '../core/store/key_value_store.dart';

/// The success counters behind ads and prompts (DATA-8).
///
/// A successful scan is one that reached a result screen, including Unknown and
/// a blocked link; a successful create is a created code's first render
/// (DATA-8). The counts decide when the Pro prompt is offered (PRO-4), and the
/// review flag keeps the Play review request to at most once per install
/// (SET-9).
///
/// Counting goes through [KeyValueStore.increment], which reads and writes in
/// one transaction, so two successes landing together both count. Like the
/// settings, a count is written before it changes in memory: if the write
/// throws, the count in memory is left as it was, no listener is told anything
/// changed, and the failure reaches the caller. The stored value the store
/// returns is what is kept, so a count that drifted from the database (a write
/// from another instance of the app, say) corrects itself on the next success.
///
/// The counts are stored on the device only (PRIV-8).
class SuccessCounts extends ChangeNotifier {
  SuccessCounts(KeyValueStore store) : _store = store;

  /// Stores the number of successful scans (DATA-8).
  static const String scansKey = 'counts.scans';

  /// Stores the number of successful creates (DATA-8).
  static const String createsKey = 'counts.creates';

  /// Stores whether the Play review has been requested (SET-9).
  static const String reviewPromptUsedKey = 'prompts.review_requested';

  /// How many successes the Pro prompt waits for (PRO-4).
  static const int proPromptThreshold = 5;

  final KeyValueStore _store;

  int _successfulScans = 0;
  int _successfulCreates = 0;
  bool _reviewPromptUsed = false;
  bool _isLoaded = false;

  /// Scans that reached a result screen, since the install (DATA-8).
  int get successfulScans => _successfulScans;

  /// Codes whose first render succeeded, since the install (DATA-8, GEN-13).
  int get successfulCreates => _successfulCreates;

  /// Successful scans and creates together, which is what the Pro prompt
  /// counts (PRO-4).
  int get totalSuccesses => _successfulScans + _successfulCreates;

  /// Whether [totalSuccesses] has reached the Pro prompt's threshold (PRO-4).
  /// Whether the prompt itself has been shown is tracked elsewhere.
  bool get hasReachedProPromptThreshold => totalSuccesses >= proPromptThreshold;

  /// Whether the Play review has already been requested on this install. Once
  /// true it stays true: the request happens at most once (SET-9).
  bool get reviewPromptUsed => _reviewPromptUsed;

  /// Whether [load] has finished. Until then the counts read 0 and the review
  /// prompt reads unused, so nothing is offered on the strength of a count that
  /// hasn't been read yet.
  bool get isLoaded => _isLoaded;

  /// Fills the counts from the store, then notifies once.
  ///
  /// A missing or unreadable count reads as 0 rather than throwing, so a
  /// hand-edited database or a restored backup only ever loses counts, never
  /// blocks the app (BAK-5).
  Future<void> load() async {
    final scans = await _store.getInt(scansKey);
    final creates = await _store.getInt(createsKey);
    final reviewUsed = await _store.getBool(reviewPromptUsedKey);

    _successfulScans = scans ?? 0;
    _successfulCreates = creates ?? 0;
    _reviewPromptUsed = reviewUsed ?? false;
    _isLoaded = true;
    notifyListeners();
  }

  /// Counts a scan that reached a result screen and returns the new count
  /// (DATA-8).
  Future<int> recordSuccessfulScan() async {
    final next = await _store.increment(scansKey);
    _successfulScans = next;
    notifyListeners();
    return next;
  }

  /// Counts a created code's first render and returns the new count (DATA-8,
  /// GEN-13).
  Future<int> recordSuccessfulCreate() async {
    final next = await _store.increment(createsKey);
    _successfulCreates = next;
    notifyListeners();
    return next;
  }

  /// Records that the Play review has been requested (SET-9).
  ///
  /// Calling it again writes nothing and notifies nobody, so the request can
  /// never be counted twice on one install.
  Future<void> markReviewPromptUsed() async {
    if (_reviewPromptUsed) {
      return;
    }
    await _store.setBool(reviewPromptUsedKey, value: true);
    _reviewPromptUsed = true;
    notifyListeners();
  }
}
