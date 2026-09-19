import '../models/parsed_payload.dart';
import 'text_encoding.dart';

/// Parses everything after a `WIFI:` header (case already matched by the
/// caller) into a [Wifi] (RES-4).
///
/// Fields: `S:` the network name, `T:` the security, `P:` the password and
/// `H:true` for a hidden network, escaped as [parseEscapedFields] describes.
/// Called for any `WIFI:`-prefixed payload, so an [ssid] can be empty when
/// the payload carried no `S:` field — this never falls back to another
/// type, matching `classifyPayload`, which classifies the header alone.
Wifi parseWifi(String body) {
  String? ssid;
  String? securityRaw;
  String? password;
  bool hidden = false;
  for (final EscapedField field in parseEscapedFields(body)) {
    switch (field.key.trim().toUpperCase()) {
      case 'S':
        ssid = field.value;
      case 'T':
        securityRaw = field.value;
      case 'P':
        password = field.value;
      case 'H':
        hidden = field.value.trim().toLowerCase() == 'true';
    }
  }
  final String? nonEmptyPassword = (password == null || password.isEmpty)
      ? null
      : password;
  return Wifi(
    ssid: ssid ?? '',
    security: _securityOf(securityRaw, hasPassword: nonEmptyPassword != null),
    password: nonEmptyPassword,
    hidden: hidden,
  );
}

/// Reads the `T:` field into a [WifiSecurity]. An empty or unrecognised
/// value falls back to [WifiSecurity.wpa] when a password was read (the
/// common case for a generator this build doesn't specifically know) or
/// [WifiSecurity.none] otherwise, rather than adding a value no generator
/// writes (RES-4).
WifiSecurity _securityOf(String? raw, {required bool hasPassword}) {
  final String value = (raw ?? '').trim().toUpperCase();
  return switch (value) {
    'WPA' => WifiSecurity.wpa,
    'WPA2' => WifiSecurity.wpa2,
    'WPA3' => WifiSecurity.wpa3,
    'WEP' => WifiSecurity.wep,
    'NOPASS' || '' => hasPassword ? WifiSecurity.wpa : WifiSecurity.none,
    _ => hasPassword ? WifiSecurity.wpa : WifiSecurity.none,
  };
}
