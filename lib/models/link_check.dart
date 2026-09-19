/// The on-device checks a `Link` (`lib/models/parsed_payload.dart`) result
/// runs before it lets the user open it (LINK-3).
///
/// Declared in the order LINK-3 lists them, which is also the order
/// [checkLink] reports them in, so a warning sheet built by iterating the
/// list needs no sort of its own (LINK-4).
enum LinkCheck {
  /// The host is a raw IP address (IPv4, or IPv6 whether or not the payload
  /// bracketed it), not a name.
  ipAddressHost,

  /// The URL carries userinfo (`user@host`), which can make a host look like
  /// something else at a glance.
  userinfo,

  /// The scheme is `http`, not `https`: the connection isn't encrypted.
  insecureScheme,

  /// The URL names a port other than the scheme's default (80 for `http`,
  /// 443 for `https`).
  nonDefaultPort,

  /// The URL is longer than 200 characters, which can hide its real
  /// destination off-screen.
  longUrl,
}

/// The scheme's default port, or null for a scheme with none (LINK-3).
const Map<String, int> _defaultPorts = <String, int>{'http': 80, 'https': 443};

/// An IPv4 octet, or an IPv6 hextet/separator: nothing a real host name ever
/// contains is missing from this, so anything else short-circuits
/// [_isIpAddressHost] to false without walking either shape.
final RegExp _ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');

/// Every LINK-3 check [uri] triggers, in [LinkCheck]'s declared (and LINK-3's
/// own) order.
///
/// Pure and offline: nothing here makes a network call, resolves a name or
/// follows a redirect (LINK-7 is a separate, explicit action). [uri] is the
/// link already parsed (`Link.uri`); [rawText] is the exact text the length
/// check counts, normally the same `Link`'s `url`, kept as its own parameter
/// so a caller is never tempted to count [uri]'s re-encoded, possibly
/// shorter or longer, string form instead.
///
/// A blocked scheme (LINK-5) is not this function's concern: `Link.isBlocked`
/// covers it, and the result screen shows the "blocked" message instead of
/// ever asking these checks about a `javascript:`, `data:`, `file:`,
/// `intent:` or `content:` link.
List<LinkCheck> checkLink(Uri uri, String rawText) {
  final List<LinkCheck> checks = <LinkCheck>[];
  if (_isIpAddressHost(uri.host)) {
    checks.add(LinkCheck.ipAddressHost);
  }
  if (uri.userInfo.isNotEmpty) {
    checks.add(LinkCheck.userinfo);
  }
  if (uri.scheme.toLowerCase() == 'http') {
    checks.add(LinkCheck.insecureScheme);
  }
  if (_hasNonDefaultPort(uri)) {
    checks.add(LinkCheck.nonDefaultPort);
  }
  if (rawText.length > 200) {
    checks.add(LinkCheck.longUrl);
  }
  return checks;
}

/// Whether [host] — as [Uri.host] reports it, brackets already stripped from
/// an IPv6 literal — is an IP address rather than a name.
///
/// IPv6 needs no full parse: a DNS name can never contain `:`, so any host
/// that does is one (`2001:db8::1`, `::1`). IPv4 is checked digit by digit,
/// since a name can otherwise look like four dot-separated numbers only when
/// every one of them is 0–255.
bool _isIpAddressHost(String host) {
  if (host.contains(':')) {
    return true;
  }
  final Match? match = _ipv4.firstMatch(host);
  if (match == null) {
    return false;
  }
  for (int i = 1; i <= 4; i++) {
    final int? octet = int.tryParse(match.group(i)!);
    if (octet == null || octet > 255) {
      return false;
    }
  }
  return true;
}

/// Whether [uri] names a port explicitly, and it isn't its scheme's default.
///
/// [Uri.port] itself already returns the default for a scheme with no
/// explicit one (80 for `http`, say), so telling that apart from an explicit
/// `:80` needs [Uri.hasPort] too, or the two would be indistinguishable and
/// every plain `http://host/` would wrongly trip this check.
bool _hasNonDefaultPort(Uri uri) {
  if (!uri.hasPort) {
    return false;
  }
  final int? defaultPort = _defaultPorts[uri.scheme.toLowerCase()];
  return defaultPort == null || uri.port != defaultPort;
}
