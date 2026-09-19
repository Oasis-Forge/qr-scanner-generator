import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/models/link_check.dart';

/// [checkLink] with [text] used both as the URL to parse and as the raw
/// text the length check counts, matching how a [Link]'s own `uri` and
/// `url` normally agree.
List<LinkCheck> _check(String text) => checkLink(Uri.parse(text), text);

/// A URL of exactly [length] characters: `https://example.com/` (20 chars)
/// padded with `a`s, so it trips nothing but the length check (LINK-3).
String _urlOfLength(int length) => 'https://example.com/${'a' * (length - 20)}';

void main() {
  group('checkLink (LINK-3)', () {
    test('a plain https URL triggers nothing', () {
      expect(_check('https://example.com'), isEmpty);
      expect(_check('https://example.com/path?q=1#top'), isEmpty);
    });

    group('ipAddressHost', () {
      test('an IPv4 host', () {
        expect(_check('https://192.168.1.1/'), <LinkCheck>[
          LinkCheck.ipAddressHost,
        ]);
      });

      test('a bracketed IPv6 host', () {
        expect(_check('https://[2001:db8::1]/'), <LinkCheck>[
          LinkCheck.ipAddressHost,
        ]);
        expect(_check('https://[::1]/'), <LinkCheck>[LinkCheck.ipAddressHost]);
      });

      test('a name that merely looks numeric is not an IP host', () {
        // Four dot-separated groups, but the second is out of range for an
        // octet, so this is a (syntactically valid) domain name, not an IP.
        expect(_check('https://1.999.1.1/'), isEmpty);
      });
    });

    test('userinfo', () {
      expect(_check('https://user@example.com'), <LinkCheck>[
        LinkCheck.userinfo,
      ]);
      expect(_check('https://user:pass@example.com'), <LinkCheck>[
        LinkCheck.userinfo,
      ]);
    });

    group('insecureScheme', () {
      test('http, not https, triggers it', () {
        expect(_check('http://example.com/'), <LinkCheck>[
          LinkCheck.insecureScheme,
        ]);
      });

      test('https does not, and neither does an upper-case http scheme '
          'once parsed', () {
        expect(_check('https://example.com/'), isEmpty);
        expect(
          checkLink(Uri.parse('HTTP://example.com/'), 'HTTP://example.com/'),
          <LinkCheck>[LinkCheck.insecureScheme],
        );
      });
    });

    group('nonDefaultPort', () {
      test('a port other than the scheme default', () {
        expect(_check('http://example.com:8080/'), <LinkCheck>[
          LinkCheck.insecureScheme,
          LinkCheck.nonDefaultPort,
        ]);
        expect(_check('https://example.com:8443/'), <LinkCheck>[
          LinkCheck.nonDefaultPort,
        ]);
      });

      test('the scheme default port, spelled out explicitly, does not '
          'trigger it', () {
        expect(_check('http://example.com:80/'), <LinkCheck>[
          LinkCheck.insecureScheme,
        ]);
        expect(_check('https://example.com:443/'), isEmpty);
      });

      test('no explicit port at all does not trigger it', () {
        expect(_check('https://example.com/'), isEmpty);
      });
    });

    group('longUrl', () {
      test('200 characters does not trigger it, 201 does', () {
        expect(_urlOfLength(200).length, 200);
        expect(_check(_urlOfLength(200)), isEmpty);
        expect(_check(_urlOfLength(201)), <LinkCheck>[LinkCheck.longUrl]);
      });

      test('counts rawText, not a re-encoded form of uri', () {
        // uri itself is short; only the second, longer argument should
        // decide the length check.
        final List<LinkCheck> checks = checkLink(
          Uri.parse('https://example.com/'),
          _urlOfLength(201),
        );
        expect(checks, <LinkCheck>[LinkCheck.longUrl]);
      });
    });

    test('every check together, in the stable order LINK-3 lists them', () {
      final String longUserinfoIpPort =
          'http://user@192.168.1.1:8080/${'a' * 180}';
      expect(_check(longUserinfoIpPort), <LinkCheck>[
        LinkCheck.ipAddressHost,
        LinkCheck.userinfo,
        LinkCheck.insecureScheme,
        LinkCheck.nonDefaultPort,
        LinkCheck.longUrl,
      ]);
    });

    test('a real-world combination: IP host, http and a non-default port '
        '(LINK-3)', () {
      expect(_check('http://192.168.1.1:8080/x'), <LinkCheck>[
        LinkCheck.ipAddressHost,
        LinkCheck.insecureScheme,
        LinkCheck.nonDefaultPort,
      ]);
    });

    test('no network call: an unreachable host is checked exactly like a '
        'reachable one, since nothing here resolves it', () {
      expect(
        _check('http://this-host-does-not-exist.invalid:8080/'),
        <LinkCheck>[LinkCheck.insecureScheme, LinkCheck.nonDefaultPort],
      );
    });
  });
}
