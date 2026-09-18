import '../../core/db/migration.dart';
import 'step_001_initial.dart';

export 'step_001_initial.dart';

/// The app's schema history, in order.
///
/// A schema change appends a step here and never edits a merged one, so an
/// upgrade only adds what is new to a database a tester already has
/// (`CLAUDE.md`). The last step's version is the schema version a backup file is
/// checked against on restore (BAK-5).
const List<MigrationStep> migrationSteps = <MigrationStep>[Step001Initial()];
