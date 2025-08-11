import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/ssh_credentials.dart';

class SecureStorageService {
  static const String _credentialsKey = 'ssh_credentials';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'EasySSH',
    ),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  /// Save SSH credentials securely
  static Future<bool> saveCredentials(SSHCredentials credentials) async {
    try {
      debugPrint('Attempting to save credentials for host: ${credentials.host}');
      
      if (!credentials.isValid()) {
        debugPrint('Error: Invalid credentials data - validation failed');
        throw ArgumentError('Invalid credentials data');
      }

      final jsonString = jsonEncode(credentials.toJson());
      debugPrint('Credentials JSON encoded successfully');
      
      await _secureStorage.write(key: _credentialsKey, value: jsonString);
      debugPrint('Credentials written to secure storage successfully');
      
      // Verify the write by reading back
      final verification = await _secureStorage.read(key: _credentialsKey);
      if (verification == null || verification != jsonString) {
        debugPrint('Error: Verification failed - credentials not properly saved');
        return false;
      }
      
      debugPrint('Credentials saved and verified successfully');
      return true;
    } catch (e) {
      // Log error in production, you might want to use a logging service
      debugPrint('Error saving credentials: $e');
      return false;
    }
  }

  /// Load SSH credentials from secure storage
  static Future<SSHCredentials?> loadCredentials() async {
    try {
      debugPrint('Attempting to load credentials from secure storage');
      
      final jsonString = await _secureStorage.read(key: _credentialsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('No credentials found in secure storage');
        return null;
      }

      debugPrint('Credentials JSON found, attempting to decode');
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final credentials = SSHCredentials.fromJson(jsonMap);
      
      debugPrint('Credentials loaded successfully for host: ${credentials.host}');
      return credentials;
    } catch (e) {
      // Log error in production
      debugPrint('Error loading credentials: $e');
      return null;
    }
  }

  /// Delete stored SSH credentials
  static Future<bool> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: _credentialsKey);
      return true;
    } catch (e) {
      // Log error in production
      debugPrint('Error deleting credentials: $e');
      return false;
    }
  }

  /// Check if credentials are stored
  static Future<bool> hasStoredCredentials() async {
    try {
      final value = await _secureStorage.read(key: _credentialsKey);
      return value != null && value.isNotEmpty;
    } catch (e) {
      // Log error in production
      debugPrint('Error checking stored credentials: $e');
      return false;
    }
  }

  /// Clear all stored data
  static Future<bool> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      // Log error in production
      debugPrint('Error clearing all storage: $e');
      return false;
    }
  }
}
