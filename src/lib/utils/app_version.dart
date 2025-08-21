import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';

/// Helper class to manage app version information
class AppVersion {
  static PackageInfo? _packageInfo;
  static late AppLocalizations l10n;
  static bool _isInitialized = false;

  /// Initialize the app version info (call this once at app startup)
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _packageInfo = await PackageInfo.fromPlatform();
      _isInitialized = true;
    }
  }

  /// Get cached package info (ensure initialize() was called first)
  static PackageInfo get packageInfo {
    if (!_isInitialized || _packageInfo == null) {
      throw StateError(
          'AppVersion not initialized. Call AppVersion.initialize() first.');
    }
    return _packageInfo!;
  }

  /// Get formatted version string (e.g., "1.1.0+6")
  static String get versionString {
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  /// Get version only (e.g., "1.1.0")
  static String get version {
    return packageInfo.version;
  }

  /// Get build number only (e.g., "6")
  static String get buildNumber {
    return packageInfo.buildNumber;
  }

  /// Get app name (e.g., "EasySSH")
  static String get appName {
    return _getAppNameWithFallback(packageInfo.appName);
  }

  /// Get package name (e.g., "com.example.app")
  static String get packageName {
    return packageInfo.packageName;
  }

  /// Clear cached package info (useful for testing)
  static void clearCache() {
    _packageInfo = null;
    _isInitialized = false;
  }

  static String _getAppNameWithFallback(String appName) {
    return appName.isEmpty ? l10n.appTitle : appName;
  }
}
