import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';
import 'package:easy_ssh_mob_new/models/log_entry.dart';
import 'package:easy_ssh_mob_new/models/execution_result.dart';
import '../test_helpers/platform_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    registerPlatformMocks();
  });

  group('SshProvider Coverage Tests', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    tearDown(() {
      sshProvider.dispose();
    });

    group('Basic Getters and Properties', () {
      test('should have correct initial state for all properties', () {
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
        expect(sshProvider.errorMessage, null);
        expect(sshProvider.currentCredentials, null);
        expect(sshProvider.currentFiles, isEmpty);
        expect(sshProvider.currentPath, '');
        expect(sshProvider.navigationHistory, isEmpty);
        expect(sshProvider.lastError, null);
        expect(sshProvider.shouldPlayErrorSound, true);
        expect(sshProvider.sessionLog, isEmpty);
        expect(sshProvider.loggingEnabled, true);
        expect(sshProvider.maxLogEntries, 1000);
        expect(sshProvider.sessionStartTime, null);
        expect(sshProvider.isConnecting, false);
        expect(sshProvider.isConnected, false);
      });

      test('should handle isConnecting state correctly', () {
        expect(sshProvider.isConnecting, false);
        expect(sshProvider.connectionState.isConnecting, false);
      });

      test('should handle isConnected state correctly', () {
        expect(sshProvider.isConnected, false);
        expect(sshProvider.connectionState.isConnected, false);
      });
    });

    group('Error Handling', () {
      test('clearError should reset error state properly', () async {
        // Primeiro, simular um erro executando comando sem conexão
        await sshProvider.executeCommand('ls');
        expect(sshProvider.errorMessage, isNotNull);
        
        // Limpar erro
        sshProvider.clearError();
        expect(sshProvider.errorMessage, null);
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });

      test('should handle error sound settings', () {
        expect(sshProvider.shouldPlayErrorSound, true);
        
        // Test that the property exists and can be accessed
        final soundSetting = sshProvider.shouldPlayErrorSound;
        expect(soundSetting, isA<bool>());
      });

      test('should handle last error property', () {
        expect(sshProvider.lastError, null);
        expect(sshProvider.lastError, isA<SshError?>());
      });
    });

    group('File Operations', () {
      test('should handle empty file list correctly', () {
        expect(sshProvider.currentFiles, isEmpty);
        expect(sshProvider.currentFiles, isA<List<SshFile>>());
      });

      test('should handle current path correctly', () {
        expect(sshProvider.currentPath, '');
        expect(sshProvider.currentPath, isA<String>());
      });

      test('listDirectory should fail when not connected', () async {
        await sshProvider.listDirectory('/test/path');
        expect(sshProvider.errorMessage, isNotNull);
        expect(sshProvider.connectionState, SshConnectionState.error);
      });
    });

    group('Navigation History', () {
      test('should have empty navigation history initially', () {
        expect(sshProvider.navigationHistory, isEmpty);
        expect(sshProvider.navigationHistory, isA<List<String>>());
      });

      test('navigation history should be unmodifiable', () {
        final history = sshProvider.navigationHistory;
        expect(() => history.add('test'), throwsUnsupportedError);
      });

      test('navigateToDirectory should fail when not connected', () async {
        await sshProvider.navigateToDirectory('/test/path');
        expect(sshProvider.errorMessage, isNotNull);
      });

      test('navigateBack should fail when not connected', () async {
        await sshProvider.navigateBack();
        expect(sshProvider.errorMessage, isNotNull);
      });
    });

    group('Session Logging', () {
      test('should have correct initial logging settings', () {
        expect(sshProvider.loggingEnabled, true);
        expect(sshProvider.maxLogEntries, 1000);
        expect(sshProvider.sessionLog, isEmpty);
        expect(sshProvider.sessionStartTime, null);
      });

      test('session log should be unmodifiable', () {
        final log = sshProvider.sessionLog;
        expect(() => log.add(LogEntry(
          timestamp: DateTime.now(),
          command: 'test',
          output: 'test output',
          type: LogEntryType.command,
        )), throwsUnsupportedError);
      });

      test('should provide session statistics when no session active', () {
        final stats = sshProvider.getSessionStats();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalCommands'], 0);
        expect(stats['successfulCommands'], 0);
        expect(stats['failedCommands'], 0);
        expect(stats['totalDuration'], Duration.zero);
        expect(stats['sessionDuration'], Duration.zero);
      });
    });

    group('Command Operations', () {
      test('executeCommand should fail gracefully when not connected', () async {
        final result = await sshProvider.executeCommand('ls');
        expect(result, null);
        expect(sshProvider.errorMessage, isNotNull);
        expect(sshProvider.connectionState, SshConnectionState.error);
      });

      test('executeCommandWithResult should fail when not connected', () async {
        final result = await sshProvider.executeCommandWithResult('ls');
        expect(result, null);
        expect(sshProvider.errorMessage, isNotNull);
      });

      test('refreshCurrentDirectory should fail when not connected', () async {
        await sshProvider.refreshCurrentDirectory();
        expect(sshProvider.errorMessage, isNotNull);
      });

      test('executeFile should fail when not connected', () async {
        final mockFile = SshFile(
          name: 'test.sh',
          isDirectory: false,
          size: 100,
          permissions: 'rwxr-xr-x',
          lastModified: DateTime.now(),
          owner: 'user',
          group: 'group',
          fullPath: '/test/test.sh',
        );

        final result = await sshProvider.executeFile(mockFile);
        expect(result, isNull);
        expect(sshProvider.errorMessage, isNotNull);
      });
    });

    group('File Reading Operations', () {
      test('readFile should fail when not connected', () async {
        final mockFile = SshFile(
          name: 'test.txt',
          isDirectory: false,
          size: 100,
          permissions: 'rw-r--r--',
          lastModified: DateTime.now(),
          owner: 'user',
          group: 'group',
          fullPath: '/test/test.txt',
        );

        final result = await sshProvider.readFile(mockFile);
        expect(result, isNotNull); // Should return an error content
        expect(result.content, contains('not_connected_to_ssh_server'));
      });

      test('readFileWithMode should fail when not connected', () async {
        final mockFile = SshFile(
          name: 'test.txt',
          isDirectory: false,
          size: 100,
          permissions: 'rw-r--r--',
          lastModified: DateTime.now(),
          owner: 'user',
          group: 'group',
          fullPath: '/test/test.txt',
        );

        final result = await sshProvider.readFileWithMode(
          mockFile, 
          FileViewMode.head
        );
        expect(result, isNotNull);
        expect(result.content, contains('not_connected_to_ssh_server'));
      });
    });

    group('Configuration and Settings', () {
      test('should handle logging configuration', () {
        expect(sshProvider.loggingEnabled, true);
        expect(sshProvider.maxLogEntries, 1000);
      });

      test('should handle audio settings', () {
        expect(sshProvider.shouldPlayErrorSound, true);
      });

      test('should handle session start time', () {
        expect(sshProvider.sessionStartTime, null);
      });
    });

    group('Connection Management', () {
      test('disconnect should work without active connection', () async {
        await sshProvider.disconnect();
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });

      test('initialize should work without errors', () async {
        await sshProvider.initialize();
        // Should not throw any errors
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });
    });

    group('Utility Methods', () {
      test('should handle currentCredentials property', () {
        expect(sshProvider.currentCredentials, null);
        expect(sshProvider.currentCredentials, isA<SSHCredentials?>());
      });

      test('should handle lastError property', () {
        expect(sshProvider.lastError, null);
        expect(sshProvider.lastError, isA<SshError?>());
      });
    });

    group('Advanced File Operations', () {
      test('logout should work without active connection', () async {
        await sshProvider.logout();
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });

      test('logout with forgetCredentials should work', () async {
        await sshProvider.logout(forgetCredentials: true);
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });

      test('hasSavedCredentials should return correct value', () async {
        final result = await sshProvider.hasSavedCredentials();
        expect(result, isA<bool>());
      });

      test('clearSavedCredentials should work', () async {
        await sshProvider.clearSavedCredentials();
        // Should not throw any errors
        expect(sshProvider.connectionState, SshConnectionState.disconnected);
      });
    });

    group('Directory Operations', () {
      test('navigateToParent should fail when not connected', () async {
        await sshProvider.navigateToParent();
        expect(sshProvider.errorMessage, isNotNull);
      });

      test('navigateToHome should fail when not connected', () async {
        await sshProvider.navigateToHome();
        expect(sshProvider.errorMessage, isNotNull);
      });
    });
  });
}