import 'dart:io';

/// Turns a release's notes into the one block Play wants: every listing
/// language, each in its own language tag, ready to paste into the release's
/// "Release notes" field.
///
///   dart tool/build_release_notes.dart \
///     store/play/source/release-notes/0.12.3.txt store/play
///
/// The source is edited by hand, one block per language, in the same shape as
/// the listing's source. Play counts 500 characters per language and rejects
/// the whole paste if one language is over, naming none of them, so this
/// refuses to write anything until every language fits.
void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: build_release_notes.dart <notes.txt> <out dir>');
    exit(2);
  }

  // Play's locale codes for this app's listing, in the order the store shows
  // them. A language missing here is a language whose testers read English.
  const List<String> locales = <String>[
    'en-US',
    'ar',
    'bn-BD',
    'zh-CN',
    'nl-NL',
    'fr-FR',
    'de-DE',
    'hi-IN',
    'id',
    'it-IT',
    'ja-JP',
    'ko-KR',
    'pl-PL',
    'pt-PT',
    'ru-RU',
    'es-ES',
    'th',
    'tr-TR',
    'ur',
    'vi',
  ];

  final File source = File(args[0]);
  if (!source.existsSync()) {
    stderr.writeln('${source.path}: no such file');
    exit(1);
  }
  final String version = source.uri.pathSegments.last.replaceAll('.txt', '');

  final Map<String, String> notes = <String, String>{};
  for (final String block in source.readAsStringSync().split(
    RegExp(r'^=== ', multiLine: true),
  )) {
    if (block.trim().isEmpty) continue;
    final int head = block.indexOf('\n');
    final String code = block.substring(0, head).split(' | ')[0].trim();
    notes[code] = block.substring(head + 1).trim();
  }

  bool ok = true;
  for (final String code in locales) {
    final String? note = notes[code];
    if (note == null || note.isEmpty) {
      ok = false;
      stdout.writeln('X ${code.padRight(6)} missing');
      continue;
    }
    // Counted in runes: Play counts characters, and a Dart string's length is
    // UTF-16 units, which overcounts every emoji and every Hindi matra.
    final int n = note.runes.length;
    if (n > 500) ok = false;
    stdout.writeln('${n > 500 ? 'X' : ' '} ${code.padRight(6)} $n/500');
  }
  final Iterable<String> extra = notes.keys.where(
    (String c) => !locales.contains(c),
  );
  for (final String code in extra) {
    ok = false;
    stdout.writeln('X ${code.padRight(6)} not a listing language');
  }
  if (!ok) {
    stderr.writeln('\nNothing written: fix the lines marked X in ${args[0]}.');
    exit(1);
  }

  final Directory out = Directory('${args[1]}/release-notes')
    ..createSync(recursive: true);
  final StringBuffer paste = StringBuffer();
  for (final String code in locales) {
    paste.writeln('<$code>');
    paste.writeln(notes[code]);
    paste.writeln('</$code>');
  }
  final File file = File('${out.path}/$version.txt')
    ..writeAsStringSync(paste.toString());
  stdout.writeln('${locales.length} languages written to ${file.path}');
}
