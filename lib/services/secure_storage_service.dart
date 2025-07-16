import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/ssh_credentials.dart';

class SecureStorageService {
  // Secure storage instance with secure configuration
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _credentialsKey = 'ssh_credentials';
  static const String _rememberCredentialsKey = 'remember_credentials';

  /// Save SSH credentials securely
  static Future<void> saveCredentials(SSHCredentials credentials) async {
    try {
      final jsonString = credentials.toJsonString();
      await _storage.write(key: _credentialsKey, value: jsonString);
      await setRememberCredentials(true);
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  /// Load SSH credentials from secure storage
  static Future<SSHCredentials?> loadCredentials() async {
    try {
      final jsonString = await _storage.read(key: _credentialsKey);
      if (jsonString == null) return null;

      return SSHCredentials.fromJsonString(jsonString);
    } catch (e) {
      // If there's an error loading, return null and don't throw
      // This handles cases where stored data might be corrupted
      return null;
    }
  }

  /// Delete stored SSH credentials
  static Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _credentialsKey);
      await setRememberCredentials(false);
    } catch (e) {
      throw Exception('Failed to delete credentials: $e');
    }
  }

  /// Check if credentials should be remembered
  static Future<bool> shouldRememberCredentials() async {
    try {
      final rememberString = await _storage.read(key: _rememberCredentialsKey);
      return rememberString == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Set whether credentials should be remembered
  static Future<void> setRememberCredentials(bool remember) async {
    try {
      if (remember) {
        await _storage.write(key: _rememberCredentialsKey, value: 'true');
      } else {
        await _storage.delete(key: _rememberCredentialsKey);
      }
    } catch (e) {
      throw Exception('Failed to set remember credentials: $e');
    }
  }

  /// Check if credentials are stored
  static Future<bool> hasStoredCredentials() async {
    try {
      final jsonString = await _storage.read(key: _credentialsKey);
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Get all stored keys (for debugging purposes)
  static Future<Map<String, String>> getAllStoredData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }
}