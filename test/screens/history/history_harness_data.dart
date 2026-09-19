import 'package:qrscanner/core/db/app_database.dart';
import 'package:qrscanner/core/db/migration.dart';
import 'package:qrscanner/db/migrations/migrations.dart';
import 'package:qrscanner/db/record_dao.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/models/scan_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fake_stores.dart';

/// A [RecordDao] whose [liveRecords] returns a fixed list held in memory and
/// never opens a database.
///
/// `HarnessScreen.build` (`test/harness/harness_screens.dart`) is a plain
/// synchronous function, so the History entries there cannot `await
/// database.open()` the way a normal test's `setUp` can; this sidesteps that
/// by never touching one. Every other [RecordDao] method is unreachable from
/// the History screen's read-only harness scenarios and is left unoverridden,
/// so calling one throws loudly instead of touching the unopened database.
class StaticHistoryRecordDao extends RecordDao {
  StaticHistoryRecordDao(this._live) : super(_unopenedDatabase());

  final List<ScanRecord> _live;

  @override
  Future<List<ScanRecord>> liveRecords({int? limit, int? offset}) async =>
      _live;
}

AppDatabase _unopenedDatabase() => AppDatabase(
  directory: 'history-harness-unopened',
  runner: MigrationRunner(migrationSteps),
  // Never opened, so no native library is loaded.
  databaseFactory: databaseFactoryFfi,
);

/// Two live records for the "History screen, with rows" harness entry
/// (HIS-4): a plain link, and a Wi-Fi network seen more than once, so both
/// the masked password (HIS-7, DATA-5) and "×N" (HIS-5) are on screen at
/// once. Timestamps are relative to now, so they always land under "Today"
/// (DATE-2) whenever the harness runs.
List<ScanRecord> historyHarnessRecords() {
  final DateTime now = DateTime.now().toUtc();
  return <ScanRecord>[
    aScanRecord(
      id: 'harness-link',
      seq: 2,
      payloadText: 'https://example.com/harness',
      createdAt: now.subtract(const Duration(minutes: 5)),
      lastSeenAt: now.subtract(const Duration(minutes: 5)),
    ),
    aScanRecord(
      id: 'harness-wifi',
      seq: 1,
      parsedType: ParsedType.wifi,
      payloadText: 'WIFI:T:WPA;S:Harness Network;P:supersecret;;',
      sensitiveFields: const <String>[SensitiveFieldKeys.wifiPassword],
      duplicateCount: 3,
      createdAt: now.subtract(const Duration(hours: 2)),
      lastSeenAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}
