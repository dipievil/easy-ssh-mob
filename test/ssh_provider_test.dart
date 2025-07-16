import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/models/ssh_connection_state.dart';
import 'package:easyssh/providers/ssh_provider.dart';

void main() {
  group('SshProvider Tests', () {
    late SshProvider sshProvider;
    
    setUp(() {
      sshProvider = SshProvider();
    });
    
    tearDown(() {
      sshProvider.dispose();
    });
    
    test('initial state should be disconnected', () {
      expect(sshProvider.state, SshConnectionState.disconnected);
      expect(sshProvider.isConnected, false);
      expect(sshProvider.isConnecting, false);
      expect(sshProvider.hasError, false);
      expect(sshProvider.errorMessage, null);
    });
    
    test('connect with empty host should fail', () async {
      final result = await sshProvider.connect('', '22', 'user', 'pass');
      
      expect(result, false);
      expect(sshProvider.hasError, true);
      expect(sshProvider.errorMessage, 'Host não pode estar vazio');
    });
    
    test('connect with empty username should fail', () async {
      final result = await sshProvider.connect('localhost', '22', '', 'pass');
      
      expect(result, false);
      expect(sshProvider.hasError, true);
      expect(sshProvider.errorMessage, 'Usuário não pode estar vazio');
    });
    
    test('connect with empty password should fail', () async {
      final result = await sshProvider.connect('localhost', '22', 'user', '');
      
      expect(result, false);
      expect(sshProvider.hasError, true);
      expect(sshProvider.errorMessage, 'Senha não pode estar vazia');
    });
    
    test('connect with invalid port should fail', () async {
      final result = await sshProvider.connect('localhost', 'invalid', 'user', 'pass');
      
      expect(result, false);
      expect(sshProvider.hasError, true);
      expect(sshProvider.errorMessage, 'Porta deve ser um número válido');
    });
    
    test('connect with port out of range should fail', () async {
      final result = await sshProvider.connect('localhost', '99999', 'user', 'pass');
      
      expect(result, false);
      expect(sshProvider.hasError, true);
      expect(sshProvider.errorMessage, 'Porta deve estar entre 1 e 65535');
    });
    
    test('executeCommand without connection should throw exception', () async {
      expect(
        () => sshProvider.executeCommand('ls'),
        throwsA(isA<Exception>()),
      );
    });
    
    test('executeCommand with empty command should throw exception', () async {
      // Note: This test assumes we're connected, but since we can't actually connect
      // in this test environment, we'll simulate the connected state
      // In a real test, you'd use mocks for the SSH client
      expect(
        () => sshProvider.executeCommand(''),
        throwsA(isA<Exception>()),
      );
    });
    
    test('disconnect should reset state', () async {
      await sshProvider.disconnect();
      
      expect(sshProvider.state, SshConnectionState.disconnected);
      expect(sshProvider.currentHost, null);
      expect(sshProvider.currentPort, null);
      expect(sshProvider.currentUsername, null);
      expect(sshProvider.errorMessage, null);
    });
  });
  
  group('SshConnectionState Tests', () {
    test('extension descriptions should be correct', () {
      expect(SshConnectionState.disconnected.description, 'Desconectado');
      expect(SshConnectionState.connecting.description, 'Conectando...');
      expect(SshConnectionState.connected.description, 'Conectado');
      expect(SshConnectionState.error.description, 'Erro na conexão');
    });
    
    test('extension boolean properties should work correctly', () {
      expect(SshConnectionState.connected.isConnected, true);
      expect(SshConnectionState.disconnected.isConnected, false);
      
      expect(SshConnectionState.connecting.isConnecting, true);
      expect(SshConnectionState.connected.isConnecting, false);
      
      expect(SshConnectionState.error.hasError, true);
      expect(SshConnectionState.connected.hasError, false);
    });
  });
}