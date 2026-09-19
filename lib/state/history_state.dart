import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../db/record_dao.dart';
import '../models/record_enums.dart';
import '../models/scan_record.dart';
import 'settings_state.dart';

/// All / Scanned / Created (HIS-1): tap-only segments the screen draws as
/// tabs, never swipeable pages, so a swipe always reaches the row underneath
/// it (DEL-2). Type chips (Link, Wi-Fi, ...) combine with the segment but
/// ship later; this build only ever filters by [HistorySegment].
enum HistorySegment {
  /// Every live record.
  all,

  /// Records whose [RecordKind] is [RecordKind.scan].
  scanned,

  /// Records whose [RecordKind] is [RecordKind.created].
  created,
}

/// What a [HistoryHeader] names (HIS-3, DATE-2). The screen turns this, plus
/// [HistoryHeader.day], into text in the app's language (LANG-3); nothing
/// here is ever shown as-is.
enum HistoryHeaderKind {
  /// The local calendar day [HistoryState.refresh] (or any rebuild) was run
  /// on.
  today,

  /// The local calendar day before [today].
  yesterday,

  /// 2 to 6 local calendar days before [today]: the screen names it by
  /// weekday ("the weekday name within 7 days", HIS-3).
  weekday,

  /// 7 or more local calendar days before [today]: the screen shows the
  /// date.
  date,
}

/// A History date header (HIS-3): what it names, and the local calendar day
/// it names (DATE-2). Deliberately data, not a string — the screen is what
/// knows how "Today", a weekday name or a date look in the user's language
/// (LANG-3).
@immutable
class HistoryHeader {
  const HistoryHeader._(this.kind, this.day);

  /// The header a record last seen or created at [at] falls under, worked
  /// out against the calendar day [now] falls on (HIS-3, DATE-2).
  ///
  /// Both instants are read in local time and only their calendar day is
  /// compared — never the raw [Duration] between them — so a DST day of 23
  /// or 25 hours never moves a record into the wrong header (DEL-4's same
  /// concern, for headers).
  factory HistoryHeader.of(DateTime at, DateTime now) {
    final DateTime day = localCalendarDayOf(at);
    final DateTime today = localCalendarDayOf(now);
    final int age = today.difference(day).inDays;
    final HistoryHeaderKind kind;
    if (age <= 0) {
      kind = HistoryHeaderKind.today;
    } else if (age == 1) {
      kind = HistoryHeaderKind.yesterday;
    } else if (age < 7) {
      kind = HistoryHeaderKind.weekday;
    } else {
      kind = HistoryHeaderKind.date;
    }
    return HistoryHeader._(kind, day);
  }

  /// What this header names.
  final HistoryHeaderKind kind;

  /// The local calendar day this header names, as a date with no time of day
  /// (DATE-2). Carries no time zone the screen should read anything into:
  /// format it by its year, month and day only.
  final DateTime day;

  @override
  bool operator ==(Object other) =>
      other is HistoryHeader && other.kind == kind && other.day == day;

  @override
  int get hashCode => Object.hash(kind, day);

  @override
  String toString() => 'HistoryHeader(${kind.name}, ${day.toIso8601String()})';
}

/// One run of rows under a [HistoryHeader] (HIS-3), in the same order
/// [RecordDao.liveRecords] gives them (HIS-1, HIS-5).
@immutable
class HistoryGroup {
  const HistoryGroup(this.header, this.records);

  /// The header these [records] are grouped under.
  final HistoryHeader header;

  /// The rows under [header], newest first. Unmodifiable.
  final List<ScanRecord> records;

  static const ListEquality<ScanRecord> _recordsEquality =
      ListEquality<ScanRecord>();

  @override
  bool operator ==(Object other) =>
      other is HistoryGroup &&
      other.header == header &&
      _recordsEquality.equals(other.records, records);

  @override
  int get hashCode => Object.hash(header, _recordsEquality.hash(records));

  @override
  String toString() => 'HistoryGroup($header, ${records.length} records)';
}

/// A failure the History screen reports, then clears with
/// [HistoryState.clearError]. Both are writes that land in the database
/// first (`CLAUDE.md`): on either, nothing here has changed yet, so there is
/// nothing to roll back beyond leaving the rows exactly as they were.
enum HistoryError {
  /// [HistoryState.delete] could not write to the database; the rows it
  /// would have moved to Trash are still shown.
  deleteFailed,

  /// [HistoryState.undo] could not write to the database; the rows it would
  /// have restored stay out of the list, and Undo can be tried again while
  /// its 5 seconds last.
  undoFailed,

  /// [HistoryState.refresh] could not read the database; the rows already
  /// shown stay.
  loadFailed,
}

/// The local calendar day [at] falls on, in local time, as a date-only,
/// UTC-tagged instant (midnight of that day).
///
/// Anchoring the day itself in UTC — rather than keeping [at]'s own local
/// instant — is what makes day arithmetic exact across a DST change: two such
/// anchors are ordinary UTC instants a whole number of days apart, with no
/// 23- or 25-hour day between them, so subtracting them counts calendar days,
/// never real elapsed hours (DATE-2, DEL-4).
@visibleForTesting
DateTime localCalendarDayOf(DateTime at) {
  final DateTime local = at.toLocal();
  return DateTime.utc(local.year, local.month, local.day);
}

/// The History state: live records newest first (HIS-1, HIS-5), filtered by
/// [segment] and grouped under date headers (HIS-3, DATE-2); deleting with
/// Undo (DEL-2); purging Trash past its 30-day window (DEL-4); and whether
/// "Save history" is on, for the empty state (HIS-8, HIS-11).
///
/// Screens stay presentational (`CLAUDE.md`): they read [groups], [segment],
/// [saveHistory], [isLoaded] and [error], and call [refresh], [setSegment],
/// [delete], [undo] and [clearError]. Nothing here reaches a device service
/// beyond [RecordDao].
///
/// **Reload.** This state does not listen for the scanner's writes: nothing
/// pushes them here. The screen calls [refresh] every time History comes on
/// screen (for instance from `initState` and again whenever the History tab
/// is selected), which is what makes a scan taken on another tab show up.
///
/// **Writes land first (`CLAUDE.md`).** [delete] and [undo] write to
/// [RecordDao] before changing anything in memory; if that write throws, the
/// rows shown are exactly the rows shown before the call, [error] is set, and
/// nothing is rolled back because nothing was changed ahead of the write.
///
/// **Masking (HIS-7, DATA-5).** A record's [ScanRecord.sensitiveFields] flows
/// through untouched; masking a Wi-Fi password in a row or a share preview is
/// the screen's job, done from that flag.
class HistoryState extends ChangeNotifier {
  /// [now] is the clock behind date headers (DATE-2), the 30-day Trash window
  /// (DEL-4) and Undo's 5-second timer (DEL-2); tests pass a fake one.
  HistoryState({
    required RecordDao records,
    required SettingsState settings,
    DateTime Function() now = DateTime.now,
  }) : _records = records,
       _settings = settings,
       _now = now {
    _settings.addListener(_onSettingsChanged);
  }

  /// How long the Undo snackbar is shown after [delete] (DEL-2).
  static const Duration undoWindow = Duration(seconds: 5);

  /// The longest a token lives. Undo works for as long as the screen offers
  /// it — until [endUndo], which the screen calls when its snackbar closes —
  /// so a snackbar that stays up longer than [undoWindow] (it finishes
  /// appearing after the delete, and with TalkBack a snackbar with an action
  /// stays until dismissed) never shows an Undo that does nothing. This cap
  /// only keeps a token the screen never ended from living on.
  static const Duration undoLimit = Duration(minutes: 1);

  /// How many local calendar days a deleted record spends in Trash before it
  /// is purged (DEL-4).
  static const int trashWindowDays = 30;

  final RecordDao _records;
  final SettingsState _settings;
  final DateTime Function() _now;

  List<ScanRecord> _live = <ScanRecord>[];
  HistorySegment _segment = HistorySegment.all;
  List<HistoryGroup> _groups = const <HistoryGroup>[];
  bool _isLoaded = false;
  HistoryError? _error;

  int _nextTokenId = 0;
  final Map<String, _PendingUndo> _pendingUndos = <String, _PendingUndo>{};

  /// All / Scanned / Created, tap-only (HIS-1).
  HistorySegment get segment => _segment;

  /// The rows to draw, newest group first and newest row first within a
  /// group (HIS-1, HIS-5), grouped under date headers computed fresh from
  /// [_now] every time this is rebuilt (HIS-3, DATE-2). Reflects [segment].
  List<HistoryGroup> get groups => _groups;

  /// Whether History holds no live records at all, regardless of [segment]:
  /// HIS-11's empty state (`isLoaded` is what tells it apart from "not
  /// refreshed yet").
  bool get isEmpty => _live.isEmpty;

  /// Whether [refresh] has completed at least once. Until then [groups] and
  /// [isEmpty] read as freshly constructed and empty, not as "History has no
  /// records" (HIS-11).
  bool get isLoaded => _isLoaded;

  /// Whether new scans and created codes are being written (HIS-8); the
  /// empty state says so when this is false (HIS-11). A pass-through of
  /// [SettingsState.saveHistory], kept here so the screen reads History's own
  /// state instead of a second one for the same message.
  bool get saveHistory => _settings.saveHistory;

  /// The failure to report, or null.
  HistoryError? get error => _error;

  /// Reads every live record from [RecordDao] and rebuilds [groups] (HIS-1).
  /// The screen calls this each time History comes on screen; see the class
  /// doc for why that is what makes the scanner's writes show up here.
  Future<void> refresh() async {
    final List<ScanRecord> live;
    try {
      live = await _records.liveRecords();
    } on Object {
      _error = HistoryError.loadFailed;
      _isLoaded = true;
      notifyListeners();
      return;
    }
    _live = live.toList(growable: true);
    _isLoaded = true;
    _rebuildGroups();
    notifyListeners();
  }

  /// Changes [segment] and rebuilds [groups] from the records already held;
  /// no database read (HIS-1).
  void setSegment(HistorySegment segment) {
    if (segment == _segment) {
      return;
    }
    _segment = segment;
    _rebuildGroups();
    notifyListeners();
  }

  /// Moves [ids] to Trash (DEL-1) and removes them from [groups] (DEL-2).
  ///
  /// The write lands first: only once [RecordDao.softDeleteAll] has
  /// succeeded are the rows taken out of [groups]. Returns a token
  /// [undo] can restore them with for [undoWindow], or null when [ids] was
  /// empty or the write failed, in which case [error] is set to
  /// [HistoryError.deleteFailed] and nothing shown changes.
  Future<String?> delete(Iterable<String> ids) async {
    _dropExpiredUndos();
    final List<String> uniqueIds = ids.toSet().toList(growable: false);
    if (uniqueIds.isEmpty) {
      return null;
    }
    try {
      await _records.softDeleteAll(uniqueIds, at: _now());
    } on Object {
      _error = HistoryError.deleteFailed;
      notifyListeners();
      return null;
    }
    final Set<String> idSet = uniqueIds.toSet();
    final List<ScanRecord> removed = _live
        .where((ScanRecord record) => idSet.contains(record.id))
        .toList(growable: false);
    _live.removeWhere((ScanRecord record) => idSet.contains(record.id));
    final String token = 'history-undo-${_nextTokenId++}';
    _pendingUndos[token] = _PendingUndo(
      records: removed,
      expiresAt: _now().add(undoLimit),
    );
    _error = null;
    _rebuildGroups();
    notifyListeners();
    return token;
  }

  /// Undoes the [delete] that returned [token] (DEL-2, REC-4): restores its
  /// records in [RecordDao] and puts them back into [groups] in order.
  ///
  /// Does nothing, and returns false, once the offer has ended ([endUndo]) or
  /// [undoLimit] has passed — including when [token] is unknown or was
  /// already used. The
  /// write lands first: on a failed [RecordDao.restoreAll], the rows stay out
  /// of [groups], [error] is set to [HistoryError.undoFailed], and false is
  /// returned.
  Future<bool> undo(String token) async {
    _dropExpiredUndos();
    // Looked up, not removed: a restore that fails can be tried again while
    // its window lasts. It is removed only once the write has landed.
    final _PendingUndo? pending = _pendingUndos[token];
    if (pending == null) {
      return false;
    }
    final List<String> ids = pending.records
        .map((ScanRecord record) => record.id)
        .toList(growable: false);
    try {
      await _records.restoreAll(ids, at: _now());
    } on Object {
      _error = HistoryError.undoFailed;
      notifyListeners();
      return false;
    }
    _pendingUndos.remove(token);
    _live.addAll(pending.records);
    _live.sort(_compareLive);
    _error = null;
    _rebuildGroups();
    notifyListeners();
    return true;
  }

  /// Ends the Undo offer for [token]: the screen calls it when the Undo
  /// snackbar closes, whatever closed it (DEL-2). A later [undo] with it does
  /// nothing.
  void endUndo(String token) => _pendingUndos.remove(token);

  /// Forgets undo entries past [undoLimit], so deletes that were
  /// never undone don't pile up for the life of the screen (DEL-2).
  void _dropExpiredUndos() {
    final DateTime now = _now();
    _pendingUndos.removeWhere(
      (String _, _PendingUndo pending) => !now.isBefore(pending.expiresAt),
    );
  }

  /// Clears [error] once the screen has reported it.
  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  /// Hard-deletes Trash records past DEL-4's 30-day window. Called once at
  /// app start; safe to call more than once. Never changes [groups]: a
  /// record in Trash is never live, so purging it changes nothing this state
  /// shows (DEL-1).
  ///
  /// A failure is swallowed and 0 is returned: purging is maintenance the
  /// user never asked for and never sees, not something worth failing
  /// startup or a screen over.
  Future<int> purgeExpiredTrash() async {
    try {
      return await _records.purgeTrashDeletedBefore(trashCutoffFor(_now()));
    } on Object {
      return 0;
    }
  }

  /// The instant DEL-4's 30-day Trash window ends, against the calendar day
  /// [now] falls on: local midnight, [trashWindowDays] local calendar days
  /// before it. A record whose `deleted_at` is at or after this instant is
  /// kept; strictly before it, [RecordDao.purgeTrashDeletedBefore] removes
  /// it — so a record deleted exactly [trashWindowDays] days ago is kept.
  ///
  /// Computed from local calendar days, not `trashWindowDays * 24` hours, so
  /// a DST day of 23 or 25 hours never shifts the cutoff by more than the
  /// calendar days it actually spans (DEL-4).
  @visibleForTesting
  static DateTime trashCutoffFor(DateTime now) {
    final DateTime today = localCalendarDayOf(now);
    final DateTime cutoffDay = today.subtract(
      const Duration(days: trashWindowDays),
    );
    return DateTime(cutoffDay.year, cutoffDay.month, cutoffDay.day).toUtc();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => notifyListeners();

  void _rebuildGroups() {
    final DateTime now = _now();
    final List<ScanRecord> filtered = _live
        .where((ScanRecord record) => _matchesSegment(record, _segment))
        .toList(growable: false);
    final List<HistoryGroup> groups = <HistoryGroup>[];
    HistoryHeader? currentHeader;
    List<ScanRecord> currentRecords = <ScanRecord>[];
    for (final ScanRecord record in filtered) {
      final DateTime at = record.lastSeenAt ?? record.createdAt;
      final HistoryHeader header = HistoryHeader.of(at, now);
      if (currentHeader != header) {
        if (currentHeader != null) {
          groups.add(
            HistoryGroup(
              currentHeader,
              List<ScanRecord>.unmodifiable(currentRecords),
            ),
          );
        }
        currentHeader = header;
        currentRecords = <ScanRecord>[];
      }
      currentRecords.add(record);
    }
    if (currentHeader != null) {
      groups.add(
        HistoryGroup(
          currentHeader,
          List<ScanRecord>.unmodifiable(currentRecords),
        ),
      );
    }
    _groups = List<HistoryGroup>.unmodifiable(groups);
  }

  bool _matchesSegment(ScanRecord record, HistorySegment segment) =>
      switch (segment) {
        HistorySegment.all => true,
        HistorySegment.scanned => record.kind == RecordKind.scan,
        HistorySegment.created => record.kind == RecordKind.created,
      };

  /// The order [RecordDao.liveRecords] gives rows in (HIS-1, HIS-5): newest
  /// `last_seen_at` (falling back to `created_at`) first, then newest `seq`
  /// first.
  int _compareLive(ScanRecord a, ScanRecord b) {
    final DateTime aTime = a.lastSeenAt ?? a.createdAt;
    final DateTime bTime = b.lastSeenAt ?? b.createdAt;
    final int byTime = bTime.compareTo(aTime);
    if (byTime != 0) {
      return byTime;
    }
    return b.seq.compareTo(a.seq);
  }
}

/// A [HistoryState.delete] waiting for [HistoryState.undo] or expiry.
class _PendingUndo {
  const _PendingUndo({required this.records, required this.expiresAt});

  final List<ScanRecord> records;
  final DateTime expiresAt;
}
