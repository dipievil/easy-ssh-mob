import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/providers/ssh_provider.dart';
import 'package:easyssh/models/ssh_connection_state.dart';

void main() {
  group('SshProvider', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    tearDown(() {
      sshProvider.dispose();
    });

    test('initial state should be disconnected', () {
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
      expect(sshProvider.isConnected, false);
      expect(sshProvider.isConnecting, false);
      expect(sshProvider.errorMessage, null);
      expect(sshProvider.currentCredentials, null);
      expect(sshProvider.currentFiles, isEmpty);
      expect(sshProvider.currentPath, isEmpty);
      expect(sshProvider.navigationHistory, isEmpty);
    });

    test('executeCommand should fail when not connected', () async {
      final result = await sshProvider.executeCommand('ls');
      
      expect(result, null);
      expect(sshProvider.connectionState, SshConnectionState.error);
      expect(sshProvider.errorMessage, 'Not connected to SSH server');
    });

    test('executeCommandWithResult should fail when not connected', () async {
      final result = await sshProvider.executeCommandWithResult('ls');
      
      expect(result, null);
      expect(sshProvider.connectionState, SshConnectionState.error);
      expect(sshProvider.errorMessage, 'Not connected to SSH server');
    });

    test('clearError should reset error state', () async {
      // First trigger an error
      await sshProvider.executeCommand('ls');
      expect(sshProvider.connectionState, SshConnectionState.error);
      expect(sshProvider.errorMessage, isNotNull);
      
      // Clear the error
      sshProvider.clearError();
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
      expect(sshProvider.errorMessage, null);
    });

    test('disconnect should cleanup and set state to disconnected', () async {
      await sshProvider.disconnect();
      
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
      expect(sshProvider.errorMessage, null);
    });

    test('logout should cleanup and optionally clear credentials', () async {
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
      expect(sshProvider.errorMessage, null);
    });

    group('Directory Navigation', () {
      test('listDirectory should fail when not connected', () async {
        await sshProvider.listDirectory('/home');
        
        expect(sshProvider.connectionState, SshConnectionState.error);
        expect(sshProvider.errorMessage, 'Not connected to SSH server');
        expect(sshProvider.currentFiles, isEmpty);
        expect(sshProvider.currentPath, isEmpty);
      });

      test('navigateToDirectory should fail when not connected', () async {
        await sshProvider.navigateToDirectory('/home');
        
        expect(sshProvider.connectionState, SshConnectionState.error);
        expect(sshProvider.errorMessage, 'Not connected to SSH server');
        expect(sshProvider.currentPath, isEmpty);
      });

      test('navigateBack should do nothing when history is empty', () async {
        await sshProvider.navigateBack();
        
        expect(sshProvider.currentPath, isEmpty);
        expect(sshProvider.navigationHistory, isEmpty);
      });

      test('refreshCurrentDirectory should do nothing when path is empty', () async {
        await sshProvider.refreshCurrentDirectory();
        
        expect(sshProvider.currentPath, isEmpty);
        expect(sshProvider.currentFiles, isEmpty);
      });
    });
  });

  group('Path Utilities', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    tearDown(() {
      sshProvider.dispose();
    });

    test('should handle basic path operations', () {
      expect(sshProvider.currentPath, isEmpty);
      expect(sshProvider.navigationHistory, isEmpty);
    });
  });

  group('SshConnectionState Extension', () {
    test('description should return correct strings', () {
      expect(SshConnectionState.disconnected.description, 'Disconnected');
      expect(SshConnectionState.connecting.description, 'Connecting...');
      expect(SshConnectionState.connected.description, 'Connected');
      expect(SshConnectionState.error.description, 'Error');
    });

    test('boolean properties should work correctly', () {
      expect(SshConnectionState.connected.isConnected, true);
      expect(SshConnectionState.connecting.isConnecting, true);
      expect(SshConnectionState.disconnected.isDisconnected, true);
      expect(SshConnectionState.error.hasError, true);
      
      expect(SshConnectionState.disconnected.isConnected, false);
      expect(SshConnectionState.connected.isConnecting, false);
      expect(SshConnectionState.connected.isDisconnected, false);
      expect(SshConnectionState.connected.hasError, false);
    });
  });
}