/// A network's security, as encoded in a Wi-Fi code (RES-4, GEN-5).
enum WifiSecurity {
  /// No password (RES-4: no password row at all).
  open,

  /// Labelled insecure, and Android can't join one from an app (RES-4).
  wep,

  /// WPA or WPA2.
  wpa2,

  wpa3,
}

/// What became of a join attempt (RES-5).
enum WifiJoinOutcome {
  joined,

  /// Nothing came back within the 6 s budget, so the screen says so and falls
  /// back to "Copy password" and "Open Wi-Fi settings" (RES-5).
  timedOut,

  failed,

  /// This build can't join networks at all — WEP, or spike S5 didn't pass — so
  /// RES-4's flow stays.
  unsupported,
}

/// Joining a Wi-Fi network from a scanned code (RES-5).
///
/// RES-5 ships only once spike S5 passes and the permissions it adds pass RUN-2;
/// until then [canJoinNetworks] is false everywhere and the result screen keeps
/// RES-4's "Open Wi-Fi settings" flow. Nothing is joined without a tap (RES-2).
abstract class WifiService {
  /// Whether this build can join a network at all (spike S5, RUN-2).
  Future<bool> canJoinNetworks();

  /// Joins [ssid], giving up after [timeout] (RES-5's 6 s).
  ///
  /// [password] is `null` for an open network. A WEP network is
  /// [WifiJoinOutcome.unsupported] (RES-4).
  Future<WifiJoinOutcome> join({
    required String ssid,
    required WifiSecurity security,
    String? password,
    bool hidden = false,
    Duration timeout = const Duration(seconds: 6),
  });
}

/// A [WifiService] that joins nothing.
///
/// [canJoinNetworks] is false by default, which is how the app ships until spike
/// S5 passes, so a test sees RES-4's flow unless it seeds otherwise. [calls]
/// records each attempt, without the password, so a test can assert what was
/// asked without a secret leaking into a failure message.
class NoopWifiService implements WifiService {
  NoopWifiService({
    this.canJoin = false,
    this.outcome = WifiJoinOutcome.joined,
  });

  /// Every call made, in order, such as `'join: Home (wpa2, hidden: false)'`.
  final List<String> calls = <String>[];

  /// What [canJoinNetworks] reports.
  final bool canJoin;

  /// What [join] reports when joining is supported.
  final WifiJoinOutcome outcome;

  @override
  Future<bool> canJoinNetworks() async {
    calls.add('canJoinNetworks');
    return canJoin;
  }

  @override
  Future<WifiJoinOutcome> join({
    required String ssid,
    required WifiSecurity security,
    String? password,
    bool hidden = false,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    calls.add('join: $ssid (${security.name}, hidden: $hidden)');
    if (!canJoin || security == WifiSecurity.wep) {
      return WifiJoinOutcome.unsupported;
    }
    return outcome;
  }
}
