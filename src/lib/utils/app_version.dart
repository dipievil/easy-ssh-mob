import 'package:package_info_plus/package_info_plus.dart';

/// Helper class to manage app version information
class AppVersion {
  static PackageInfo? _packageInfo;

  /// Get cached package info or load it
  static Future<PackageInfo> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  /// Get formatted version string (e.g., "1.1.0+6")
  static Future<String> getVersionString() async {
    final info = await getPackageInfo();
    return '${info.version}+${info.buildNumber}';
  }

  /// Get version only (e.g., "1.1.0")
  static Future<String> getVersion() async {
    final info = await getPackageInfo();
    return info.version;
  }

  /// Get build number only (e.g., "6")
  static Future<String> getBuildNumber() async {
    final info = await getPackageInfo();
    return info.buildNumber;
  }

  /// Get app name (e.g., "EasySSH")
  static Future<String> getAppName() async {
    final info = await getPackageInfo();
    return info.appName.isEmpty ? 'EasySSH' : info.appName;
  }

  /// Get package name (e.g., "com.example.app")
  static Future<String> getPackageName() async {
    final info = await getPackageInfo();
    return info.packageName;
  }

  /// Get all version info as a formatted string for debugging
  static Future<String> getFullVersionInfo() async {
    final info = await getPackageInfo();
    return '''
App: ${info.appName.isEmpty ? 'EasySSH' : info.appName}
Version: ${info.version}
Build: ${info.buildNumber}
Package: ${info.packageName}
''';
  }

  /// Clear cached package info (useful for testing)
  static void clearCache() {
    _packageInfo = null;
  }
}
