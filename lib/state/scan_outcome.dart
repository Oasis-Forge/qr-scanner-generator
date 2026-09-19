import 'package:flutter/foundation.dart';

import '../models/payload_classifier.dart';
import '../models/record_enums.dart';
import '../models/scan_record.dart';
import '../services/camera_scanner.dart';

/// Everything the result screen needs for one scanned code (RES-1, RES-3).
///
/// One result screen serves every source (RES-3), so the camera, a photo, a
/// typed entry, a pick from the multi-code list and a History reopen all hand
/// it one of these.
///
/// [record] is the record as stored when [isSaved], or an unsaved record built
/// in memory when "Save history" is off (HIS-8, DATA-6) or the write failed
/// ([saveFailed]). An unsaved record has the id [unsavedRecordId] and nothing
/// in the database refers to it, so a result screen offers no star or label
/// for it (HIS-9).
@immutable
class ScanOutcome {
  const ScanOutcome({
    required this.record,
    required this.parsedType,
    required this.symbology,
    required this.source,
    required this.isSaved,
    this.isDuplicate = false,
    this.saveFailed = false,
  });

  /// A record reopened from History, which the result screen shows the same
  /// way as a fresh scan (RES-3). Its type, format and source are the ones it
  /// was stored with (REC-3).
  factory ScanOutcome.reopened(ScanRecord record) => ScanOutcome(
    record: record,
    parsedType: record.parsedType,
    symbology: record.symbology,
    source: record.source,
    isSaved: true,
  );

  /// The id an unsaved, in-memory record carries (DATA-6). No stored record
  /// has it: stored ids are UUID v4 (REC-2).
  static const String unsavedRecordId = '';

  /// The stored record, or the in-memory one when [isSaved] is false.
  ///
  /// For a duplicate scan this is the existing row, bumped (DATA-4, HIS-5):
  /// its `source`, `created_at` and `parsed_type` stay the ones it was first
  /// written with (REC-3), so read this scan's own values from [parsedType],
  /// [symbology] and [source].
  final ScanRecord record;

  /// What this scan's payload was classified as, which picks the result screen
  /// (RES-4 to RES-13). See `classifyPayload`.
  final ParsedType parsedType;

  /// The format this scan was read in (SCAN-9), [Symbology.unknown] for typed
  /// text (SCAN-12).
  final Symbology symbology;

  /// How this scan arrived: `camera`, `image` or `manual` (DATA-2, SCAN-11,
  /// SCAN-12), whatever the stored record's own source is.
  final RecordSource source;

  /// Whether [record] is in History. False while "Save history" is off (HIS-8,
  /// DATA-6) and after a failed write ([saveFailed]).
  final bool isSaved;

  /// Whether the scan matched a live record, which was bumped instead of a new
  /// one written (DATA-4, HIS-5).
  final bool isDuplicate;

  /// Whether "Save history" was on but the write failed. The result still
  /// shows, from an unsaved record; the screen says it couldn't be saved.
  final bool saveFailed;

  /// The decoded text (DATA-2). Best effort when [isBinary].
  String get payloadText => record.payloadText;

  /// The raw bytes, set only when the payload isn't valid UTF-8 (DATA-2).
  Uint8List? get payloadBytes => record.payloadBytes;

  /// Whether the payload is binary, which the result shows as "Binary data, N
  /// bytes" with [byteCount] (RES-13).
  bool get isBinary => record.payloadBytes != null;

  /// How many raw bytes a binary payload holds, or null for text (RES-13).
  int? get byteCount => record.payloadBytes?.length;

  @override
  bool operator ==(Object other) =>
      other is ScanOutcome &&
      other.record == record &&
      other.parsedType == parsedType &&
      other.symbology == symbology &&
      other.source == source &&
      other.isSaved == isSaved &&
      other.isDuplicate == isDuplicate &&
      other.saveFailed == saveFailed;

  @override
  int get hashCode => Object.hash(
    record,
    parsedType,
    symbology,
    source,
    isSaved,
    isDuplicate,
    saveFailed,
  );

  /// Leaves the payload out: nothing scanned may reach a crash report
  /// (PRIV-4).
  @override
  String toString() =>
      'ScanOutcome(${parsedType.id}, ${symbology.id}, ${source.id}, '
      'saved: $isSaved, duplicate: $isDuplicate, saveFailed: $saveFailed)';
}

/// One row of the multi-code list: a code from a detection pass that found two
/// or more (SCAN-13).
///
/// The list shows a type icon from [parsedType] and [preview], the first
/// [previewLength] characters; for a binary payload ([isBinary]) the row reads
/// "Binary data, N bytes" from [byteCount] instead (RES-13). Picking a row
/// opens that code's result; nothing is guessed.
@immutable
class ScanChoice {
  const ScanChoice._({
    required this.detection,
    required this.symbology,
    required this.parsedType,
    required this.preview,
    required this.isPreviewTruncated,
  });

  /// Classifies [detection] the same way a single scan would be (SCAN-12,
  /// RES-3).
  factory ScanChoice.of(CodeDetection detection) {
    final Symbology symbology = symbologyFromDecoderName(detection.symbology);
    final ParsedType parsedType = classifyPayload(
      detection.payload,
      symbology: symbology,
      isBinary: !detection.isValidUtf8,
    );
    // DATA-5: a Wi-Fi password never shows in a list row.
    final String oneLine = maskSensitive(
      detection.payload,
      parsedType,
    ).replaceAll(RegExp(r'\s+'), ' ').trim();
    final List<int> runes = oneLine.runes.toList(growable: false);
    final bool truncated = runes.length > previewLength;
    return ScanChoice._(
      detection: detection,
      symbology: symbology,
      parsedType: parsedType,
      preview: truncated
          ? String.fromCharCodes(runes.take(previewLength))
          : oneLine,
      isPreviewTruncated: truncated,
    );
  }

  /// How many characters of a payload the list shows (SCAN-13).
  static const int previewLength = 40;

  /// The code as the decoder reported it.
  final CodeDetection detection;

  /// Its format (SCAN-9).
  final Symbology symbology;

  /// Its type, for the row's icon (SCAN-13).
  final ParsedType parsedType;

  /// The payload on one line, whitespace runs folded to single spaces, cut to
  /// [previewLength] characters. Shown left to right in Arabic (LANG-5).
  final String preview;

  /// Whether [preview] was cut, so the row can end it with an ellipsis.
  final bool isPreviewTruncated;

  /// Whether the payload is binary (RES-13).
  bool get isBinary => !detection.isValidUtf8;

  /// How many raw bytes a binary payload holds, or null (RES-13).
  int? get byteCount => isBinary ? detection.rawBytes?.length : null;

  @override
  bool operator ==(Object other) =>
      other is ScanChoice && other.detection == detection;

  @override
  int get hashCode => detection.hashCode;

  /// Leaves the payload out (PRIV-4).
  @override
  String toString() => 'ScanChoice(${parsedType.id}, ${symbology.id})';
}
