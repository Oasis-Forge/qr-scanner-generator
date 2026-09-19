import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qrscanner/services/app_version_info.dart';

/// The real [AppVersionInfo]: the app's version from `package_info_plus`
/// and the Android release from `device_info_plus` (SET-5, SET-8).
///
/// Both are read once and kept, since neither changes while the app runs.
class PlatformAppVersionInfo implements AppVersionInfo {
  PlatformAppVersionInfo();

  Future<AppVersionDetails>? _details;

  @override
  Future<AppVersionDetails> load() => _details ??= _read();

  Future<AppVersionDetails> _read() async {
    final (PackageInfo package, AndroidDeviceInfo device) = await (
      PackageInfo.fromPlatform(),
      DeviceInfoPlugin().androidInfo,
    ).wait;
    return AppVersionDetails(
      version: package.version,
      buildNumber: package.buildNumber,
      androidVersion: 'Android ${device.version.release}',
    );
  }
}
