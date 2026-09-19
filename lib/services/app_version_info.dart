/// The app and Android versions shown in Settings → About → Version (SET-5)
/// and in a feedback email's subject (SET-8).
///
/// A real implementation reads `package_info_plus` and `device_info_plus`;
/// built only by the app's entry point (`CLAUDE.md`), the same as every other
/// device capability.
abstract class AppVersionInfo {
  /// Reads the versions. Cheap enough to call every time the About section or
  /// the feedback screen builds; a caller that wants to ask once keeps the
  /// result itself.
  Future<AppVersionDetails> load();
}

/// What [AppVersionInfo.load] resolves to.
class AppVersionDetails {
  const AppVersionDetails({
    required this.version,
    required this.buildNumber,
    required this.androidVersion,
  });

  /// The app's SemVer name, e.g. `'1.4.0'`, straight from `pubspec.yaml`'s
  /// `version` field (before the `+`) (SET-5).
  final String version;

  /// The build number, e.g. `'27'`, from the same `pubspec.yaml` field (after
  /// the `+`) (SET-5).
  final String buildNumber;

  /// The device's Android release, e.g. `'Android 14'` (SET-8).
  final String androidVersion;
}

/// An [AppVersionInfo] that reaches no plugin.
///
/// [details] is a fixed, obviously-fake set of versions, so a test that
/// forgets to check for it fails loudly instead of matching a real-looking
/// value by coincidence. [calls] records every [load].
class NoopAppVersionInfo implements AppVersionInfo {
  NoopAppVersionInfo({
    this.details = const AppVersionDetails(
      version: '0.0.0-test',
      buildNumber: '0',
      androidVersion: 'Android 0 (test)',
    ),
  });

  final AppVersionDetails details;

  /// Every call made, in order: `'load'` each time.
  final List<String> calls = <String>[];

  @override
  Future<AppVersionDetails> load() async {
    calls.add('load');
    return details;
  }
}
