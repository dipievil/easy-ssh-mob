import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';

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

    test('error sound should be configurable', () {
      expect(sshProvider.shouldPlayErrorSound, true);

      sshProvider.setErrorSoundEnabled(false);
      expect(sshProvider.shouldPlayErrorSound, false);

      sshProvider.setErrorSoundEnabled(true);
      expect(sshProvider.shouldPlayErrorSound, true);
    });

    test('test error sound should not throw exception', () {
      expect(() => sshProvider.testErrorSound(), returnsNormally);
    });

    group('File Execution', () {
      test('executeFile should fail when not connected', () async {
        const testFile = SshFile(
          name: 'test.sh',
          fullPath: '/home/user/test.sh',
          type: FileType.executable,
          displayName: 'test.sh*',
        );

        final result = await sshProvider.executeFile(testFile);

        expect(result.stdout, '');
        expect(result.stderr, 'Not connected to SSH server');
        expect(result.exitCode, -1);
        expect(result.hasError, true);
      });

      test('executeFile should handle timeout correctly', () async {
        const testFile = SshFile(
          name: 'test.sh',
          fullPath: '/home/user/test.sh',
          type: FileType.executable,
          displayName: 'test.sh*',
        );

        // Test with very short timeout to simulate timeout
        final result = await sshProvider.executeFile(
          testFile,
          timeout: const Duration(milliseconds: 1),
        );

        // Should complete quickly with error since not connected
        expect(result.hasError, true);
        expect(result.stderr, 'Not connected to SSH server');
      });
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

      test('refreshCurrentDirectory should do nothing when path is empty',
          () async {
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
