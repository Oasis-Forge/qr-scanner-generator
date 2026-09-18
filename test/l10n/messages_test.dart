import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The CI guard behind the message files themselves (LANG-2), read from disk
/// rather than through the generated class, so a rule that lives in an ARB
/// description is actually enforced.
///
/// LANG-2 says CI fails on a missing message or mismatched placeholders, and
/// RUN-1 caps the camera reason at 70 characters in every language. Neither can
/// be checked through `AppLocalizations`: a key missing from a translation
/// silently falls back to English there, and the 70-character limit is written
/// only in a description. So this test reads every `app_*.arb` file and compares
/// the translations against the English template.
///
/// Every failure names the key and the file, so the next language PR (LANG-7)
/// can act on the message without opening a debugger.
void main() {
  final List<_MessageFile> files = _readMessageFiles();
  final _MessageFile template = files.firstWhere(
    (_MessageFile file) => file.name == templateFileName,
    orElse: () => throw StateError(
      'No $templateFileName in $arbDirectoryPath. `flutter test` runs from the '
      'package root, so that is where this test looks.',
    ),
  );
  final List<_MessageFile> translations = files
      .where((_MessageFile file) => file.name != template.name)
      .toList();

  group('message files', () {
    test('LANG-7: the languages the app ships today are all checked here', () {
      expect(
        files.map((_MessageFile file) => file.name),
        containsAll(<String>[templateFileName, 'app_ar.arb']),
        reason:
            'LANG-7 ships English and Arabic today. This test found '
            '${files.map((_MessageFile file) => file.name).toList()} in '
            '$arbDirectoryPath; a file it cannot see is a file it cannot check.',
      );
      for (final _MessageFile file in files) {
        expect(
          file.locale,
          file.localeFromName,
          reason:
              '${file.name} declares @@locale "${file.locale}" but its name '
              'says "${file.localeFromName}". gen-l10n reads the name, so the '
              'two must agree.',
        );
      }
    });

    test('RUN-1: the camera reason is at most $cameraReasonLimit characters in '
        'every language', () {
      for (final _MessageFile file in files) {
        expect(
          file.messages,
          contains(cameraReasonKey),
          reason:
              '${file.name} has no $cameraReasonKey. RUN-1 says the scanner '
              'placeholder shows one reason before the camera is allowed.',
        );
        final String reason = file.messages[cameraReasonKey]!;
        expect(
          reason.runes.length,
          lessThanOrEqualTo(cameraReasonLimit),
          reason:
              '$cameraReasonKey in ${file.name} is ${reason.runes.length} '
              'characters: "$reason". RUN-1 allows at most '
              '$cameraReasonLimit, so the reason stays one short line and '
              'the "Allow camera" button stays the largest control on the '
              'placeholder. Shorten the translation.',
        );
      }
    });

    test('LANG-2: every language has exactly the keys $templateFileName has', () {
      for (final _MessageFile file in translations) {
        final List<String> missing =
            template.keys.difference(file.keys).toList()..sort();
        final List<String> extra = file.keys.difference(template.keys).toList()
          ..sort();
        expect(
          missing,
          isEmpty,
          reason:
              '${file.name} is missing $missing. A key missing from a '
              'translation shows English to a user reading another language, '
              'so CI fails instead (LANG-2).',
        );
        expect(
          extra,
          isEmpty,
          reason:
              '${file.name} has $extra, which $templateFileName does not. '
              'gen-l10n generates nothing for them, so they would never reach '
              'a screen: add them to $templateFileName or drop them.',
        );
      }
    });

    test('LANG-2: every key declares and uses the same placeholders in every '
        'language', () {
      for (final String key in template.keys) {
        final Map<String, String> declared = template.placeholders(key);
        for (final _MessageFile file in files) {
          if (!file.keys.contains(key)) {
            // The key test above names it; this one would only repeat that.
            continue;
          }
          if (file.name != template.name) {
            expect(
              file.placeholders(key),
              declared,
              reason:
                  '$key declares $declared in $templateFileName but '
                  '${file.placeholders(key)} in ${file.name}. gen-l10n builds '
                  'one method signature from the template, so a placeholder '
                  'that differs in name, type or format fails the build '
                  '(LANG-2).',
            );
          }
          for (final String placeholder in declared.keys) {
            expect(
              _usesPlaceholder(file.messages[key]!, placeholder),
              isTrue,
              reason:
                  '$key in ${file.name} never uses {$placeholder}: '
                  '"${file.messages[key]}". The value the caller passes would '
                  'be dropped, so the user would read a sentence with a number '
                  'or a name missing from it (LANG-2).',
            );
          }
        }
      }
    });

    test('LANG-2: every message in $templateFileName has a description', () {
      for (final String key in template.keys) {
        expect(
          template.description(key)?.trim() ?? '',
          isNotEmpty,
          reason:
              '$key has no description in $templateFileName. The description '
              'is what a translator and the next reader of the generated code '
              'have to go on, and it is where the rule ID lives.',
        );
      }
    });
  });
}

/// Where the message files live, relative to the package root, which is the
/// directory `flutter test` runs in.
const String arbDirectoryPath = 'lib/l10n';

/// The template every translation is checked against (`l10n.yaml`).
const String templateFileName = 'app_en.arb';

/// RUN-1's cap on the camera reason, in characters, in every language.
const int cameraReasonLimit = 70;

/// The key holding that reason.
const String cameraReasonKey = 'cameraPermissionReason';

/// Whether [message] actually substitutes `{name}`.
///
/// It matches the placeholder only where ICU would read one — `{name}` or
/// `{name, plural, ...}` — so the words inside a plural branch are not mistaken
/// for placeholders.
bool _usesPlaceholder(String message, String name) =>
    RegExp('\\{\\s*${RegExp.escape(name)}\\s*[,}]').hasMatch(message);

/// Reads every `.arb` file in [arbDirectoryPath], sorted by name so a failure
/// reads the same way twice.
List<_MessageFile> _readMessageFiles() {
  final Directory directory = Directory(arbDirectoryPath);
  if (!directory.existsSync()) {
    throw StateError(
      'No $arbDirectoryPath directory. `flutter test` runs from the package '
      'root, so that is where this test looks for the message files.',
    );
  }
  final List<File> arbFiles =
      directory
          .listSync()
          .whereType<File>()
          .where((File file) => file.path.endsWith('.arb'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));
  return arbFiles.map(_MessageFile.read).toList();
}

/// One message file, as this test needs to see it.
class _MessageFile {
  const _MessageFile._({
    required this.name,
    required this.messages,
    required this.attributes,
    required this.locale,
  });

  /// Reads [file] and splits its resources from their `@` attributes.
  factory _MessageFile.read(File file) {
    final Object? decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('${file.path} is not a JSON object');
    }
    final Map<String, String> messages = <String, String>{};
    final Map<String, Map<String, dynamic>> attributes =
        <String, Map<String, dynamic>>{};
    for (final MapEntry<String, dynamic> entry in decoded.entries) {
      if (entry.key.startsWith('@@')) {
        continue;
      }
      if (entry.key.startsWith('@')) {
        final Object? value = entry.value;
        attributes[entry.key.substring(1)] = value is Map<String, dynamic>
            ? value
            : <String, dynamic>{};
        continue;
      }
      messages[entry.key] = '${entry.value}';
    }
    return _MessageFile._(
      name: file.uri.pathSegments.last,
      messages: messages,
      attributes: attributes,
      locale: '${decoded['@@locale'] ?? ''}',
    );
  }

  /// The file's own name, such as `app_ar.arb`.
  final String name;

  /// Every resource: key to the message a user reads.
  final Map<String, String> messages;

  /// Every resource's `@` attributes, keyed without the `@`.
  final Map<String, Map<String, dynamic>> attributes;

  /// The language the file declares in `@@locale`.
  final String locale;

  /// The language the file's name says it holds: `app_ar.arb` is `ar`.
  String get localeFromName =>
      name.replaceFirst(RegExp(r'^app_'), '').replaceFirst('.arb', '');

  /// Every key the file holds.
  Set<String> get keys => messages.keys.toSet();

  /// The description [key] carries, or `null` when it has none.
  String? description(String key) {
    final Object? value = attributes[key]?['description'];
    return value is String ? value : null;
  }

  /// [key]'s declared placeholders, as name to `type/format`.
  ///
  /// Only what gen-l10n turns into a method signature is compared: the example
  /// and the description are a translator's business and may differ by
  /// language.
  Map<String, String> placeholders(String key) {
    final Object? declared = attributes[key]?['placeholders'];
    if (declared is! Map<String, dynamic>) {
      return <String, String>{};
    }
    final List<String> names = declared.keys.toList()..sort();
    return <String, String>{
      for (final String name in names) name: _signature(declared[name]),
    };
  }

  static String _signature(Object? placeholder) {
    if (placeholder is! Map<String, dynamic>) {
      return 'Object';
    }
    final Object? type = placeholder['type'];
    final Object? format = placeholder['format'];
    return format == null ? '$type' : '$type/$format';
  }
}
