// Builds lib/l10n/app_<code>.arb for a new language from a flat file of
// translations (LANG-7), so a language is added without anyone retyping the
// template's structure.
//
//   dart tool/new_language.dart <code> <translations.json>
//
// The input is only the text: {"appTitle": "...", "navScan": "...", ...}.
// The file is written by walking lib/l10n/app_en.arb line by line and
// swapping each message's value, so the keys, their order, the English
// descriptions translators read, and even the blank lines that group the
// template are reproduced exactly: a new language cannot drift from it. Use
// tool/add_messages.dart afterwards for ordinary edits across every file.
//
// Nothing is written unless every check passes: one translation per message,
// no extras, every placeholder still used, ICU plurals still plural, and
// apostrophes doubled for `use-escaping: true`. Run `flutter gen-l10n` after.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: dart tool/new_language.dart <code> <file.json>');
    exit(64);
  }
  final String code = args.first;
  final File template = File('lib/l10n/app_en.arb');
  final Map<String, dynamic> english =
      jsonDecode(template.readAsStringSync()) as Map<String, dynamic>;
  final Object? decoded = jsonDecode(File(args[1]).readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    exitWith(<String>['The input must be a JSON object of key to text.']);
  }
  final Map<String, dynamic> translations = decoded;

  final List<String> messageKeys = english.keys
      .where((String key) => !key.startsWith('@'))
      .toList(growable: false);

  final List<String> problems = check(english, translations, messageKeys);
  if (problems.isNotEmpty) {
    exitWith(problems);
  }

  // Walk the template and swap the values, so everything else about the file
  // — key order, the @ blocks, the blank lines between groups — is carried
  // over untouched. Every value in app_en.arb sits on one line, which a test
  // holds to.
  final String source = template.readAsStringSync();
  final String newline = source.contains('\r\n') ? '\r\n' : '\n';
  final RegExp message = RegExp(r'^(  )"([A-Za-z][A-Za-z0-9_]*)": (".*")(,?)$');
  final List<String> out = <String>[];
  int swapped = 0;

  for (final String line in source.split(RegExp(r'\r?\n'))) {
    if (line.trimLeft().startsWith('"@@locale"')) {
      out.add(line.replaceFirst('"en"', jsonEncode(code)));
      continue;
    }
    final RegExpMatch? match = message.firstMatch(line);
    // A "description" inside an @ block looks the same but for its indent, so
    // the key has to be one the template declares at the top level.
    if (match == null || !translations.containsKey(match.group(2))) {
      out.add(line);
      continue;
    }
    final String key = match.group(2)!;
    out.add(
      '${match.group(1)}"$key": ${jsonEncode(translations[key])}'
      '${match.group(4)}',
    );
    swapped++;
  }

  if (swapped != messageKeys.length) {
    exitWith(<String>[
      'matched $swapped message lines but app_en.arb has '
          '${messageKeys.length} messages; the template is not line-per-value',
    ]);
  }

  final File file = File('lib/l10n/app_$code.arb');
  file.writeAsStringSync(out.join(newline));
  stdout.writeln('$swapped messages written to ${file.path}.');
}

/// Everything wrong with [translations], checked against the template.
List<String> check(
  Map<String, dynamic> english,
  Map<String, dynamic> translations,
  List<String> messageKeys,
) {
  final List<String> problems = <String>[];
  final Set<String> extra = translations.keys.toSet()
    ..removeAll(messageKeys.toSet());
  for (final String key in extra) {
    problems.add('$key: not a message in app_en.arb');
  }

  for (final String key in messageKeys) {
    final Object? text = translations[key];
    if (text is! String || text.trim().isEmpty) {
      problems.add('$key: no text');
      continue;
    }
    final String source = english[key] as String;

    // Every placeholder the English text uses has to survive translation, or
    // gen-l10n generates a method whose argument is never shown (LANG-2).
    for (final RegExpMatch match in RegExp(r'\{(\w+)[},]').allMatches(source)) {
      final String name = match.group(1)!;
      if (!RegExp('\\{$name[},]').hasMatch(text)) {
        problems.add('$key: does not use {$name}');
      }
    }

    // An ICU plural that loses its shape reads as a literal brace on screen.
    // Only "other" is required: the categories a language actually has vary
    // (Japanese and Chinese have "other" alone; Arabic and Russian have more
    // than English), and demanding "one" everywhere would force a wrong
    // plural into the languages that don't inflect.
    if (source.contains(', plural,')) {
      if (!text.contains(', plural,')) {
        problems.add('$key: the English is a plural and this is not');
      } else if (!RegExp(r'(?<![a-z])other\s*\{').hasMatch(text)) {
        problems.add('$key: the plural has no "other" form');
      }
    }

    // `use-escaping: true` (see tool/add_messages.dart).
    if (RegExp("(?<!')'(?!')").hasMatch(text)) {
      problems.add('$key: single apostrophe; double it');
    }
  }
  return problems;
}

Never exitWith(List<String> problems) {
  stderr.writeln(
    'Nothing written: ${problems.length} problems\n'
    '${problems.take(40).join('\n')}'
    '${problems.length > 40 ? '\n…and ${problems.length - 40} more' : ''}',
  );
  exit(1);
}
