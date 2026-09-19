import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/parsers/text_encoding.dart';

void main() {
  group('parseEscapedFields', () {
    test('splits key:value pairs on unescaped semicolons', () {
      final List<EscapedField> fields = parseEscapedFields(
        'T:WPA;S:Home;P:secret;;',
      );
      expect(fields.map((EscapedField f) => f.key), <String>['T', 'S', 'P']);
      expect(fields.map((EscapedField f) => f.value), <String>[
        'WPA',
        'Home',
        'secret',
      ]);
    });

    test('unescapes \\; \\, \\: \\" and \\\\ inside a value', () {
      final List<EscapedField> fields = parseEscapedFields(
        r'S:My\;Net\,work;P:p\:a\"ss\\word;;',
      );
      expect(fields[0].value, 'My;Net,work');
      expect(fields[1].value, r'p:a"ss\word');
    });

    test('a field with no unescaped colon is dropped', () {
      expect(parseEscapedFields('garbage;;'), isEmpty);
    });

    test('an empty body has no fields', () {
      expect(parseEscapedFields(''), isEmpty);
    });

    test('keeps duplicate keys as separate fields, in order', () {
      final List<EscapedField> fields = parseEscapedFields(
        'TEL:1;TEL:2;TEL:3;;',
      );
      expect(fields.map((EscapedField f) => f.value), <String>['1', '2', '3']);
    });
  });

  group('indexOfUnescaped', () {
    test('finds the first unescaped occurrence', () {
      // a, \, :, b, : — the escaped colon is at 2, the first plain one at 4.
      expect(indexOfUnescaped(r'a\:b:c', ':'), 4);
    });

    test('-1 when every occurrence is escaped, or there is none', () {
      expect(indexOfUnescaped(r'a\:b\:c', ':'), -1);
      expect(indexOfUnescaped('abc', ':'), -1);
    });
  });

  group('splitUnescaped', () {
    test('splits on every unescaped separator', () {
      expect(splitUnescaped('Family;Given;Middle', ';'), <String>[
        'Family',
        'Given',
        'Middle',
      ]);
    });

    test('keeps an escaped separator inside its part', () {
      expect(splitUnescaped(r'Fam\;ily;Given', ';'), <String>[
        r'Fam\;ily',
        'Given',
      ]);
    });
  });

  group('unfoldLines', () {
    test('joins a continuation line, dropping its one leading space', () {
      // RFC 5545 3.1: the line break and the one space after it both go, so
      // encoders fold mid-word and a space in the text survives the fold.
      expect(
        unfoldLines('SUMMARY:Long ti\n tle he\n re'),
        'SUMMARY:Long title here',
      );
      expect(unfoldLines('SUMMARY:Long\n title'), 'SUMMARY:Longtitle');
    });

    test('normalises CRLF and bare CR to LF first', () {
      expect(unfoldLines('A:1\r\nB:2\rC:3'), 'A:1\nB:2\nC:3');
    });

    test('a line starting with a tab also continues the one before it', () {
      expect(unfoldLines('A:1\n\tmore'), 'A:1more');
    });

    test('leaves an unfolded payload unchanged', () {
      expect(unfoldLines('A:1\nB:2'), 'A:1\nB:2');
    });
  });

  group('parsePropertyLine', () {
    test('splits name, parameters and value', () {
      final PropertyLine? line = parsePropertyLine(
        'DTSTART;TZID=Europe/London:20261113T090000',
      );
      expect(line, isNotNull);
      expect(line!.name, 'DTSTART');
      expect(line.params, <String, String>{'TZID': 'Europe/London'});
      expect(line.value, '20261113T090000');
    });

    test('a bare property has no parameters', () {
      final PropertyLine? line = parsePropertyLine('FN:Ada Lovelace');
      expect(line!.name, 'FN');
      expect(line.params, isEmpty);
      expect(line.value, 'Ada Lovelace');
    });

    test('a value with its own colon is kept whole (a tel: URI value)', () {
      final PropertyLine? line = parsePropertyLine(
        'TEL;VALUE=uri:tel:+15551234567',
      );
      expect(line!.value, 'tel:+15551234567');
    });

    test('null when there is no unescaped colon', () {
      expect(parsePropertyLine('not a property line'), isNull);
    });
  });

  group('unescapeIcsText', () {
    test('turns \\n and \\N into a real newline', () {
      expect(
        unescapeIcsText(r'Line one\nLine two\NLine three'),
        'Line one\nLine two\nLine three',
      );
    });

    test('turns \\, and \\; into literal characters', () {
      expect(
        unescapeIcsText(r'Coffee\, tea\; or milk'),
        'Coffee, tea; or milk',
      );
    });

    test('turns \\\\ into one backslash', () {
      expect(unescapeIcsText(r'C:\\Users'), r'C:\Users');
    });
  });
}
