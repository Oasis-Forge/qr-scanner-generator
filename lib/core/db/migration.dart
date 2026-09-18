import 'package:sqflite/sqflite.dart';

/// One step in the schema's ordered history.
///
/// A merged step is never edited: a change appends a new step (see `CLAUDE.md`).
/// `version` is the schema version the step upgrades the database *to*, so the
/// first step is version 1.
abstract class MigrationStep {
  const MigrationStep();

  int get version;

  Future<void> up(DatabaseExecutor db);
}

/// Runs an ordered list of [MigrationStep]s on open, whether the database is
/// new or older than the current schema.
///
/// The steps must be numbered 1..n without gaps, and there must be at least
/// one: both are checked when the runner is built, so a schema that could never
/// be created is refused before a database is touched.
class MigrationRunner {
  MigrationRunner(List<MigrationStep> steps)
    : steps = List<MigrationStep>.unmodifiable(
        steps.toList()..sort((a, b) => a.version.compareTo(b.version)),
      ) {
    if (steps.isEmpty) {
      throw ArgumentError.value(
        steps,
        'steps',
        'a schema needs at least one migration step: an empty history would '
            'stamp a new database at version 1 while creating nothing, and the '
            'real steps would then never run on it',
      );
    }
    var expected = 1;
    for (final step in this.steps) {
      if (step.version != expected) {
        throw ArgumentError(
          'migration steps must be numbered 1..n without gaps; '
          'found ${step.version} where $expected was expected',
        );
      }
      expected++;
    }
  }

  final List<MigrationStep> steps;

  /// The schema version the steps add up to. Never 0: the constructor refuses
  /// an empty history.
  int get targetVersion => steps.last.version;

  /// Runs every step above [from] and up to and including [to].
  Future<void> upgrade(
    DatabaseExecutor db, {
    required int from,
    required int to,
  }) async {
    for (final step in steps) {
      if (step.version > from && step.version <= to) {
        await step.up(db);
      }
    }
  }
}
