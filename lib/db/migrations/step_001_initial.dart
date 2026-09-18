import 'package:sqflite/sqflite.dart';

import '../../core/db/migration.dart';

/// Schema version 1: every table and index the app needs.
///
/// This step is merged and never edited: a change appends a new step, so an
/// upgrade never rewrites what a tester's phone already holds (`CLAUDE.md`).
/// That is why every statement here is spelled out in full, and none is built
/// from a model class, a store or any other constant that is free to change:
/// this file alone decides what a version-1 database holds.
///
/// Every field v1 uses lands now, including the ones no screen reads yet
/// (`docs/PRODUCT_RULES.md`, Roadmap impact): created-code content and style,
/// the batch session, the sensitive-field flag and the insert sequence.
class Step001Initial implements MigrationStep {
  const Step001Initial();

  @override
  int get version => 1;

  @override
  Future<void> up(DatabaseExecutor db) async {
    // Scanned and created codes (DATA-2, DATA-3, DATA-5, REC-1 to REC-4).
    // `seq` orders records written in the same second, and `deleted_at` is null
    // for every live record (DATE-1, DEL-1).
    await db.execute(
      'CREATE TABLE records ('
      'id TEXT PRIMARY KEY NOT NULL, '
      'seq INTEGER NOT NULL, '
      'kind TEXT NOT NULL, '
      'source TEXT NOT NULL, '
      'symbology TEXT NOT NULL, '
      'parsed_type TEXT NOT NULL, '
      'payload_text TEXT NOT NULL, '
      'payload_bytes BLOB, '
      "sensitive_fields TEXT NOT NULL DEFAULT '[]', "
      'label TEXT, '
      'favourite INTEGER NOT NULL DEFAULT 0, '
      'duplicate_count INTEGER NOT NULL DEFAULT 1, '
      'batch_session_id TEXT, '
      'content_json TEXT, '
      'style_json TEXT, '
      'created_at INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL, '
      'deleted_at INTEGER, '
      'last_seen_at INTEGER'
      ')',
    );

    // The History list reads live records newest first (HIS-1, DATE-1).
    //
    // The expression is the one `RecordDao.liveRecords` orders by, character
    // for character, so History is drawn straight from the index: an index on
    // `created_at` alone would leave every draw a full scan plus a sort, since
    // a duplicate scan moves a row by `last_seen_at` (HIS-5).
    await db.execute(
      'CREATE INDEX idx_records_live_order ON records '
      '(deleted_at, COALESCE(last_seen_at, created_at) DESC, seq DESC)',
    );

    // Duplicate matching looks up kind, format and payload (DATA-4).
    await db.execute(
      'CREATE INDEX idx_records_duplicate ON records '
      '(kind, symbology, payload_text)',
    );

    // A saved batch is one collapsible History row (HIS-6, SCAN-14).
    await db.execute(
      'CREATE INDEX idx_records_batch_session ON records (batch_session_id)',
    );

    // A batch session in progress, kept apart from History (DATA-7, SCAN-14).
    //
    // `duplicate_key` is what staging matches a code on, always written from
    // `StagedCode.duplicateKey`. It folds in the raw bytes, not just the text,
    // so two different non-UTF-8 codes whose lossy text reads the same stay
    // two codes and the session loses neither (DATA-2, DATA-4).
    await db.execute(
      'CREATE TABLE batch_staging ('
      'id TEXT PRIMARY KEY NOT NULL, '
      'session_id TEXT NOT NULL, '
      'symbology TEXT NOT NULL, '
      'parsed_type TEXT NOT NULL, '
      'payload_text TEXT NOT NULL, '
      'payload_bytes BLOB, '
      'duplicate_key TEXT NOT NULL, '
      'count INTEGER NOT NULL DEFAULT 1, '
      'first_seen_at INTEGER NOT NULL, '
      'last_seen_at INTEGER NOT NULL'
      ')',
    );

    await db.execute(
      'CREATE INDEX idx_batch_staging_session ON batch_staging (session_id)',
    );

    // One row per code per session: a code seen again raises its own count
    // instead of adding a row (SCAN-14). The uniqueness is on `duplicate_key`,
    // which `symbology` and `payload_text` are already part of, so it never
    // collapses two codes that only look alike as text (DATA-2, DATA-7).
    await db.execute(
      'CREATE UNIQUE INDEX idx_batch_staging_unique ON batch_staging '
      '(session_id, duplicate_key)',
    );

    // Settings, consent, Pro ownership and the success counts (DATA-8).
    //
    // Written out rather than taken from `SqfliteKeyValueStore`: that helper
    // builds its text from constants the store may rename, and a rename would
    // silently change what schema version 1 is. The store keeps the helper for
    // tests and later steps; `test/db/migration_upgrade_test.dart` holds the
    // two to the same column names.
    await db.execute(
      'CREATE TABLE app_state ('
      'key TEXT PRIMARY KEY NOT NULL, '
      'value TEXT NOT NULL'
      ')',
    );
  }
}
