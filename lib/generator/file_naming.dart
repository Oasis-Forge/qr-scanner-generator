import '../models/record_enums.dart' show ParsedType;
import 'generator_form.dart';

/// The extension every saved or shared code carries (SAVE-2): a plain PNG,
/// no styling in this PR (STY-1).
const String generatorFileExtension = '.png';

/// SAVE-4: `<type>-<name>-<YYYYMMDD-HHmmss>.png`, ASCII only, at most 60
/// characters. [name] comes only from [GeneratorForm.nonSecretName] — never
/// a password, number, email address or message — transliterated to ASCII;
/// a type with no such field, or one whose name sanitises to nothing (an
/// SSID that is entirely Arabic or emoji, say), uses the type alone, exactly
/// as SAVE-4's own example does for phone (`phone-20261016-101500.png`).
///
/// The type and the timestamp are never shortened: only the name, and only
/// as far as it takes to fit the 60-character limit, so a very long network
/// name or contact name still produces a valid file name rather than one
/// SAVE-4 forbids.
String generatorFileName({
  required ParsedType type,
  required GeneratorForm form,
  required DateTime at,
}) {
  final String typeId = type.id;
  final String timestamp = _timestampOf(at);
  final int fixedLength =
      typeId.length +
      1 + // the dash before the timestamp
      timestamp.length +
      generatorFileExtension.length;

  String stem = typeId;
  final String? name = _sanitisedName(form.nonSecretName);
  if (name != null) {
    final int available = 60 - fixedLength - 1; // the dash before the name
    if (available > 0) {
      final String fitted = name.length > available
          ? name.substring(0, available)
          : name;
      final String trimmed = fitted.replaceAll(RegExp(r'-+$'), '');
      if (trimmed.isNotEmpty) {
        stem = '$typeId-$trimmed';
      }
    }
  }
  return '$stem-$timestamp$generatorFileExtension';
}

/// `YYYYMMDD-HHmmss`, in [at]'s local time zone, matching SAVE-4's own
/// example exactly.
String _timestampOf(DateTime at) {
  final DateTime local = at.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  final String date =
      '${local.year.toString().padLeft(4, '0')}${two(local.month)}${two(local.day)}';
  final String time =
      '${two(local.hour)}${two(local.minute)}${two(local.second)}';
  return '$date-$time';
}

/// Every run of characters outside `A-Za-z0-9` in [raw] collapsed to one
/// dash, with a leading, trailing or doubled dash trimmed away — dropping
/// non-ASCII (SAVE-4) rather than attempting a per-script transliteration,
/// since a network, contact or host name can be any script or carry emoji.
/// Null for a null [raw], or for one that sanitises to nothing at all (an
/// SSID with no ASCII letters or digits in it), which [generatorFileName]
/// then treats the same as a type with no name field.
String? _sanitisedName(String? raw) {
  if (raw == null) {
    return null;
  }
  final String dashed = raw.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
  final String trimmed = dashed.replaceAll(RegExp(r'^-+|-+$'), '');
  return trimmed.isEmpty ? null : trimmed;
}
