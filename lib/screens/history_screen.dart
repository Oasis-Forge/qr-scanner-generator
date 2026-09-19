import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/scan_record.dart';
import '../state/history_state.dart';
import '../state/scan_outcome.dart';
import 'history/history_date_header.dart';
import 'history/history_empty_state.dart';
import 'history/history_row.dart';
import 'result_screen.dart';

/// The History tab (HIS-1, HIS-3, HIS-4, HIS-5, HIS-7, HIS-11): every live
/// scanned and created code, newest first, grouped under date headers, and
/// filtered by All / Scanned / Created.
///
/// Presentational (`CLAUDE.md`): every row comes from [HistoryState] and
/// every write — delete, undo — calls back into it; this screen owns only
/// which rows are selected, which is UI state, never written anywhere.
///
/// **Reload.** [HistoryState.refresh] is called once from [initState]. Since
/// `AppShell` builds only the selected tab, leaving History disposes this
/// screen and returning to it creates a fresh one, which is what makes a scan
/// taken on another tab show up here (see `HistoryState`'s own class doc).
///
/// **Delete and undo (DEL-2).** A row swiped toward the start edge (mirrored
/// in right-to-left languages by [Dismissible] resolving against the ambient
/// [Directionality], LANG-5), or a delete from multi-select, both call
/// [HistoryState.delete] with no confirmation, then offer Undo in a snackbar
/// for [HistoryState.undoWindow]. A failed delete or undo leaves the rows
/// exactly as they were and reports [HistoryState.error] instead.
///
/// **Tab switching.** The empty state's "Scan a code", "Create a code" and
/// "Go to Settings" (HIS-11) reach `AppShell`'s own tab through the three
/// callbacks this widget takes; this screen never imports `AppShell`.
///
/// No ad appears here in this PR (ADS-1 adds one on this screen later).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    required this.onSwitchToScan,
    required this.onSwitchToCreate,
    required this.onSwitchToSettings,
    super.key,
  });

  /// Switches `AppShell` to the Scan tab (HIS-11).
  final VoidCallback onSwitchToScan;

  /// Switches `AppShell` to the Create tab (HIS-11).
  final VoidCallback onSwitchToCreate;

  /// Switches `AppShell` to the Settings tab, offered on the empty state
  /// while "Save history" is off (HIS-8, HIS-11).
  final VoidCallback onSwitchToSettings;

  /// The All / Scanned / Created control (HIS-1).
  static const Key segmentedControlKey = Key('history.segmented');

  /// Leaves selection mode without deleting anything (DEL-2).
  static const Key cancelSelectionKey = Key('history.selection.cancel');

  /// Deletes every selected row (DEL-2).
  static const Key deleteSelectedKey = Key('history.selection.delete');

  /// One row, by its record id.
  static Key rowKey(String id) => Key('history.row.$id');

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  /// Read once: this screen enters and leaves History's lifetime, and must
  /// still reach it in [dispose], where the tree can no longer be read.
  late final HistoryState _history;

  /// The selected row ids, or null outside selection mode (DEL-2). Purely
  /// this screen's own UI state: never written anywhere (`CLAUDE.md`).
  Set<String>? _selectedIds;

  @override
  void initState() {
    super.initState();
    _history = context.read<HistoryState>();
    _history.addListener(_onHistoryChanged);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_history.refresh());
  }

  /// Back in the foreground, History is read again: scans taken meanwhile
  /// appear, and the date headers are worked out against the day it is now,
  /// so "Today" can't go stale past midnight (DATE-2).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_history.refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _history.removeListener(_onHistoryChanged);
    super.dispose();
  }

  /// Reports a failed delete or undo; nothing shown has changed either way
  /// (`CLAUDE.md`'s write-lands-first rollback).
  void _onHistoryChanged() {
    if (!mounted) {
      return;
    }
    final HistoryError? error = _history.error;
    if (error == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (error) {
            HistoryError.deleteFailed => l10n.historyDeleteFailed,
            HistoryError.undoFailed => l10n.historyUndoFailed,
            HistoryError.loadFailed => l10n.historyLoadFailed,
          }),
        ),
      );
    _history.clearError();
  }

  void _startSelection(String id) {
    setState(() => _selectedIds = <String>{...?_selectedIds, id});
  }

  void _toggleSelected(String id) {
    setState(() {
      final Set<String> ids = <String>{...?_selectedIds};
      if (!ids.remove(id)) {
        ids.add(id);
      }
      _selectedIds = ids;
    });
  }

  void _exitSelection() => setState(() => _selectedIds = null);

  Future<void> _deleteSelected() async {
    final List<String> ids = List<String>.of(_selectedIds ?? const <String>{});
    setState(() => _selectedIds = null);
    if (ids.isEmpty) {
      return;
    }
    final String? token = await _history.delete(ids);
    if (!mounted || token == null) {
      return;
    }
    _showUndoSnackbar(token, count: ids.length);
  }

  /// [Dismissible.confirmDismiss]: performs the actual delete and only tells
  /// the row to finish its own swipe-away animation once that write
  /// succeeded; on failure the row springs back and nothing here changed.
  Future<bool> _swipeDelete(ScanRecord record) async {
    final String? token = await _history.delete(<String>[record.id]);
    if (!mounted || token == null) {
      return false;
    }
    _showUndoSnackbar(token, count: 1);
    return true;
  }

  void _showUndoSnackbar(String token, {required int count}) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar();
    // Undo works exactly as long as it is offered: the token ends when this
    // snackbar closes, however it closes (DEL-2).
    unawaited(
      messenger
          .showSnackBar(
            SnackBar(
              duration: HistoryState.undoWindow,
              content: Text(l10n.historyDeletedSnackbar(count)),
              action: SnackBarAction(
                label: l10n.historyUndoButton,
                onPressed: () => unawaited(_history.undo(token)),
              ),
            ),
          )
          .closed
          .then((SnackBarClosedReason _) => _history.endUndo(token)),
    );
  }

  /// Reopens [record] on the result screen (RES-3): nothing here edits
  /// `result_screen.dart`, only its public constructor.
  Future<void> _open(ScanRecord record) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          ResultScreen(outcome: ScanOutcome.reopened(record), isReopened: true),
    ),
  );

  void _onRowTap(ScanRecord record) {
    if (_selectedIds != null) {
      _toggleSelected(record.id);
    } else {
      unawaited(_open(record));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final HistoryState history = context.watch<HistoryState>();
    final Set<String>? selectedIds = _selectedIds;
    final bool selectionMode = selectedIds != null;

    return PopScope(
      canPop: !selectionMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _exitSelection();
        }
      },
      child: Scaffold(
        appBar: selectionMode
            ? _selectionAppBar(l10n, selectedIds)
            : AppBar(title: Text(l10n.navHistory)),
        body: SafeArea(
          top: false,
          child: _body(l10n, history, selectionMode, selectedIds),
        ),
      ),
    );
  }

  AppBar _selectionAppBar(AppLocalizations l10n, Set<String> selectedIds) {
    return AppBar(
      leading: IconButton(
        key: HistoryScreen.cancelSelectionKey,
        tooltip: l10n.historyCancelSelectionButton,
        icon: const Icon(Icons.close),
        onPressed: _exitSelection,
      ),
      title: Text(l10n.historySelectedCount(selectedIds.length)),
      actions: <Widget>[
        IconButton(
          key: HistoryScreen.deleteSelectedKey,
          tooltip: l10n.historyDeleteSelectedButton,
          icon: const Icon(Icons.delete_outline),
          onPressed: selectedIds.isEmpty
              ? null
              : () => unawaited(_deleteSelected()),
        ),
      ],
    );
  }

  Widget _body(
    AppLocalizations l10n,
    HistoryState history,
    bool selectionMode,
    Set<String>? selectedIds,
  ) {
    if (!history.isLoaded) {
      // HistoryState.isLoaded is what tells "nothing read yet" apart from
      // HIS-11's "History has no records"; this is the former.
      return Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.historyLoading),
      );
    }
    if (history.isEmpty) {
      return HistoryEmptyState(
        saveHistory: history.saveHistory,
        onScan: widget.onSwitchToScan,
        onCreate: widget.onSwitchToCreate,
        onSettings: widget.onSwitchToSettings,
      );
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
          child: SegmentedButton<HistorySegment>(
            key: HistoryScreen.segmentedControlKey,
            style: _segmentStyle,
            segments: <ButtonSegment<HistorySegment>>[
              ButtonSegment<HistorySegment>(
                value: HistorySegment.all,
                label: Text(l10n.historySegmentAll),
              ),
              ButtonSegment<HistorySegment>(
                value: HistorySegment.scanned,
                label: Text(l10n.historySegmentScanned),
              ),
              ButtonSegment<HistorySegment>(
                value: HistorySegment.created,
                label: Text(l10n.historySegmentCreated),
              ),
            ],
            selected: <HistorySegment>{history.segment},
            onSelectionChanged: (Set<HistorySegment> selection) =>
                history.setSegment(selection.first),
          ),
        ),
        Expanded(
          // A live record exists somewhere (history.isEmpty is false above),
          // just none in this segment: not HIS-11's empty state, so this
          // reuses historyCodeCount(0)'s "No codes" rather than a second
          // empty-state message.
          child: history.groups.isEmpty
              ? Center(child: Text(l10n.historyCodeCount(0)))
              : ListView(
                  children: _items(history.groups, selectionMode, selectedIds),
                ),
        ),
      ],
    );
  }

  List<Widget> _items(
    List<HistoryGroup> groups,
    bool selectionMode,
    Set<String>? selectedIds,
  ) {
    final List<Widget> items = <Widget>[];
    for (final HistoryGroup group in groups) {
      items.add(
        HistoryDateHeader(
          key: ValueKey<String>(
            'history.header.${group.header.day.millisecondsSinceEpoch}.'
            '${group.header.kind.name}',
          ),
          header: group.header,
        ),
      );
      for (final ScanRecord record in group.records) {
        items.add(_row(record, selectionMode, selectedIds));
      }
    }
    return items;
  }

  Widget _row(ScanRecord record, bool selectionMode, Set<String>? selectedIds) {
    final Widget row = HistoryRow(
      key: HistoryScreen.rowKey(record.id),
      record: record,
      isSelectionMode: selectionMode,
      isSelected: selectedIds?.contains(record.id) ?? false,
      onTap: () => _onRowTap(record),
      onLongPress: () => _startSelection(record.id),
    );
    if (selectionMode) {
      return row;
    }
    // DEL-2, LANG-5: toward the start edge. `endToStart` is resolved against
    // the ambient Directionality by Dismissible itself, so this one line
    // already mirrors in right-to-left languages; nothing here reads
    // Directionality directly.
    return Dismissible(
      key: ValueKey<String>('history.dismiss.${record.id}'),
      direction: DismissDirection.endToStart,
      background: const _SwipeDeleteBackground(),
      confirmDismiss: (DismissDirection direction) => _swipeDelete(record),
      child: row,
    );
  }

  static const ButtonStyle _segmentStyle = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(
      Size(64, AppTheme.minTapTargetSize),
    ),
  );
}

/// Revealed behind a row as it is swiped away (DEL-2): decorative, so it
/// carries no semantic label of its own (A11Y-1 is about controls, and
/// nothing here is tappable).
class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.errorContainer,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
    );
  }
}
