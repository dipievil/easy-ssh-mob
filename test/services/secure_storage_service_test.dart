import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easyssh/services/secure_storage_service.dart';
import 'package:easyssh/models/ssh_credentials.dart';

void main() {
  group('SecureStorageService Unit Tests', () {
    setUp(() {
      // Configurar mock inicial values para o FlutterSecureStorage
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('should save valid credentials successfully', () async {
      final credentials = SSHCredentials(
        host: 'localhost',
        port: 22,
        username: 'testuser',
        password: 'testpass',
      );

      final result = await SecureStorageService.saveCredentials(credentials);
      
      expect(result, true);
    });

    test('should not save invalid credentials', () async {
      final invalidCredentials = SSHCredentials(
        host: '', // Host vazio = inválido
        port: 22,
        username: 'testuser',
        password: 'testpass',
      );

      final result = await SecureStorageService.saveCredentials(invalidCredentials);
      
      expect(result, false);
    });

    test('should load saved credentials correctly', () async {
      final originalCredentials = SSHCredentials(
        host: 'test-host',
        port: 2222,
        username: 'test-user',
        password: 'test-pass',
      );

      // Salvar primeiro
      await SecureStorageService.saveCredentials(originalCredentials);
      
      // Carregar
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
      // Inicialmente não deve ter credenciais
      expect(await SecureStorageService.hasStoredCredentials(), false);
      
      // Salvar credenciais
      final credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      
      // Agora deve detectar que tem credenciais
      expect(await SecureStorageService.hasStoredCredentials(), true);
    });

    test('should delete credentials successfully', () async {
      // Salvar credenciais primeiro
      final credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      
      // Verificar que estão salvas
      expect(await SecureStorageService.hasStoredCredentials(), true);
      
      // Deletar
      final result = await SecureStorageService.deleteCredentials();
      expect(result, true);
      
      // Verificar que foram deletadas
      expect(await SecureStorageService.hasStoredCredentials(), false);
      expect(await SecureStorageService.loadCredentials(), isNull);
    });

    test('should clear all storage successfully', () async {
      // Salvar credenciais primeiro
      final credentials = SSHCredentials(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
      );
      await SecureStorageService.saveCredentials(credentials);
      
      // Verificar que estão salvas
      expect(await SecureStorageService.hasStoredCredentials(), true);
      
      // Limpar tudo
      final result = await SecureStorageService.clearAll();
      expect(result, true);
      
      // Verificar que tudo foi limpo
      expect(await SecureStorageService.hasStoredCredentials(), false);
      expect(await SecureStorageService.loadCredentials(), isNull);
    });

    test('should handle corrupted data gracefully', () async {
      // Simular dados corrompidos no storage
      const mockValues = {
        'ssh_credentials': 'invalid_json_data',
      };
      FlutterSecureStorage.setMockInitialValues(mockValues);

      // Tentar carregar deve retornar null sem crash
      final credentials = await SecureStorageService.loadCredentials();
      expect(credentials, isNull);
      
      // hasStoredCredentials ainda deve retornar true pois há dados (mesmo corrompidos)
      expect(await SecureStorageService.hasStoredCredentials(), true);
    });

    test('should handle empty string data gracefully', () async {
      // Simular string vazia no storage
      const mockValues = {
        'ssh_credentials': '',
      };
      FlutterSecureStorage.setMockInitialValues(mockValues);

      // Deve retornar null para string vazia
      final credentials = await SecureStorageService.loadCredentials();
      expect(credentials, isNull);
      
      // hasStoredCredentials deve retornar false para string vazia
      expect(await SecureStorageService.hasStoredCredentials(), false);
    });

    test('should save and load credentials with special characters', () async {
      final credentials = SSHCredentials(
        host: 'host-with-special.chars.com',
        port: 22,
        username: 'user@domain.com',
        password: 'p@ssw0rd!#\$%&*()_+{}:"<>?[]\\;\'.,/',
      );

      // Salvar
      final saveResult = await SecureStorageService.saveCredentials(credentials);
      expect(saveResult, true);
      
      // Carregar
      final loadedCredentials = await SecureStorageService.loadCredentials();
      
      expect(loadedCredentials, isNotNull);
      expect(loadedCredentials!.host, credentials.host);
      expect(loadedCredentials.port, credentials.port);
      expect(loadedCredentials.username, credentials.username);
      expect(loadedCredentials.password, credentials.password);
    });

    test('should save and load credentials with unicode characters', () async {
      final credentials = SSHCredentials(
        host: 'tëst-hōst.côm',
        port: 22,
        username: 'üser_名前',
        password: 'パスワード123',
      );

      // Salvar
      final saveResult = await SecureStorageService.saveCredentials(credentials);
      expect(saveResult, true);
      
      // Carregar
      final loadedCredentials = await SecureStorageService.loadCredentials();
      
      expect(loadedCredentials, isNotNull);
      expect(loadedCredentials!.host, credentials.host);
      expect(loadedCredentials.port, credentials.port);
      expect(loadedCredentials.username, credentials.username);
      expect(loadedCredentials.password, credentials.password);
    });
  });
}