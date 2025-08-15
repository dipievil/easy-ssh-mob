import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_ssh_mob_new/services/secure_storage_service.dart';
import 'package:easy_ssh_mob_new/models/ssh_credentials.dart';
void main() {
  group('SecureStorageService Unit Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });
    tearDown(() async {
      await SecureStorageService.clearAll();
    });
    test('should save valid credentials successfully', () async {
      const credentials = SSHCredentials(
        host: 'localhost',
        port: 22,
        username: 'testuser',
        password: 'testpass',
      );
      final result = await SecureStorageService.saveCredentials(credentials);
      expect(result, true);
    });
    test('should not save invalid credentials', () async {
      const invalidCredentials = SSHCredentials(
        host: '', 
        port: 22,
        username: 'testuser',
        password: 'testpass',
      );
      final result =
          await SecureStorageService.saveCredentials(invalidCredentials);
      expect(result, false);
    });
    test('should load saved credentials correctly', () async {
      const originalCredentials = SSHCredentials(
        host: 'test-host',
        port: 2222,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(originalCredentials);
      final loadedCredentials = await SecureStorageService.loadCredentials();
      expect(loadedCredentials, isNotNull);
      expect(loadedCredentials!.host, originalCredentials.host);
      expect(loadedCredentials.port, originalCredentials.port);
      expect(loadedCredentials.username, originalCredentials.username);
      expect(loadedCredentials.password, originalCredentials.password);
    });
    test('should return null when no credentials are stored', () async {
      final credentials = await SecureStorageService.loadCredentials();
      expect(credentials, isNull);
    });
    test('should detect if credentials are stored', () async {
      expect(await SecureStorageService.hasStoredCredentials(), false);
      const credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      expect(await SecureStorageService.hasStoredCredentials(), true);
    });
    test('should delete credentials successfully', () async {
      const credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      expect(await SecureStorageService.hasStoredCredentials(), true);
      final result = await SecureStorageService.deleteCredentials();
      expect(result, true);
      expect(await SecureStorageService.hasStoredCredentials(), false);
      expect(await SecureStorageService.loadCredentials(), isNull);
    });
    test('should clear all storage successfully', () async {
      const credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      expect(await SecureStorageService.hasStoredCredentials(), true);
      final result = await SecureStorageService.clearAll();
      expect(result, true);
      expect(await SecureStorageService.hasStoredCredentials(), false);
      expect(await SecureStorageService.loadCredentials(), isNull);
    });
    test('should handle corrupted data gracefully', () async {
      const mockValues = {
        'ssh_credentials': 'invalid_json_data',
      };
      FlutterSecureStorage.setMockInitialValues(mockValues);
      final credentials = await SecureStorageService.loadCredentials();
      expect(credentials, isNull);
      expect(await SecureStorageService.hasStoredCredentials(), true);
    });
    test('should handle empty string data gracefully', () async {
      const mockValues = {
        'ssh_credentials': '',
      };
      FlutterSecureStorage.setMockInitialValues(mockValues);
      final credentials = await SecureStorageService.loadCredentials();
      expect(credentials, isNull);
      expect(await SecureStorageService.hasStoredCredentials(), false);
    });
    test('should save and load credentials with special characters', () async {
      const credentials = SSHCredentials(
        host: 'host-with-special.chars.com',
        port: 22,
        username: 'user@domain.com',
        password: 'p@ssw0rd!#\$%&*()_+{}:"<>?[]\\;\'.,/',
      );
      final saveResult =
          await SecureStorageService.saveCredentials(credentials);
      expect(saveResult, true);
      final loadedCredentials = await SecureStorageService.loadCredentials();
      expect(loadedCredentials, isNotNull);
      expect(loadedCredentials!.host, credentials.host);
      expect(loadedCredentials.port, credentials.port);
      expect(loadedCredentials.username, credentials.username);
      expect(loadedCredentials.password, credentials.password);
    });
    test('should save and load credentials with unicode characters', () async {
      const credentials = SSHCredentials(
        host: 'tëst-hōst.côm',
        port: 22,
        username: 'üser_名前',
        password: 'パスワード123',
      );
      final saveResult =
          await SecureStorageService.saveCredentials(credentials);
      expect(saveResult, true);
      final loadedCredentials = await SecureStorageService.loadCredentials();
      expect(loadedCredentials, isNotNull);
      expect(loadedCredentials!.host, credentials.host);
      expect(loadedCredentials.port, credentials.port);
      expect(loadedCredentials.username, credentials.username);
      expect(loadedCredentials.password, credentials.password);
    });
  });
}
