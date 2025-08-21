import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';
import 'package:easy_ssh_mob_new/models/file_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SshProvider Simple Coverage Tests', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    tearDown(() {
      sshProvider.dispose();
    });

    test('basic getters should have correct initial values', () {
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

    test('navigation history should be unmodifiable', () {
      final history = sshProvider.navigationHistory;
      expect(() => history.add('test'), throwsUnsupportedError);
    });

    test('session log should be unmodifiable', () {
      final log = sshProvider.sessionLog;
      expect(() => log.clear(), throwsUnsupportedError);
    });

    test('getSessionStats should return correct structure when no session', () {
      final stats = sshProvider.getSessionStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('totalCommands'), true);
      expect(stats.containsKey('successfulCommands'), true);
      expect(stats.containsKey('failedCommands'), true);
      expect(stats.containsKey('totalDuration'), true);
      expect(stats.containsKey('sessionDuration'), true);
      expect(stats['totalCommands'], 0);
      expect(stats['successfulCommands'], 0);
      expect(stats['failedCommands'], 0);
      expect(stats['totalDuration'], Duration.zero);
      expect(stats['sessionDuration'], Duration.zero);
    });

    test('clearError should reset error state', () async {
      // Trigger an error first
      await sshProvider.executeCommand('ls');
      expect(sshProvider.errorMessage, isNotNull);
      
      // Clear the error
      sshProvider.clearError();
      expect(sshProvider.errorMessage, null);
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('disconnect should work even when not connected', () async {
      await sshProvider.disconnect();
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('initialize should work without throwing', () async {
      await sshProvider.initialize();
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('executeCommand should fail gracefully when not connected', () async {
      final result = await sshProvider.executeCommand('ls');
      expect(result, null);
      expect(sshProvider.errorMessage, isNotNull);
      expect(sshProvider.connectionState, SshConnectionState.error);
    });

    test('executeCommandWithResult should fail when not connected', () async {
      final result = await sshProvider.executeCommandWithResult('pwd');
      expect(result, null);
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('listDirectory should fail when not connected', () async {
      await sshProvider.listDirectory('/test');
      expect(sshProvider.errorMessage, isNotNull);
      expect(sshProvider.connectionState, SshConnectionState.error);
    });

    test('navigateToDirectory should fail when not connected', () async {
      await sshProvider.navigateToDirectory('/home');
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('navigateBack should fail when not connected', () async {
      await sshProvider.navigateBack();
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('navigateToParent should fail when not connected', () async {
      await sshProvider.navigateToParent();
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('navigateToHome should fail when not connected', () async {
      await sshProvider.navigateToHome();
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('refreshCurrentDirectory should fail when not connected', () async {
      await sshProvider.refreshCurrentDirectory();
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('readFile should return error content when not connected', () async {
      final mockFile = SshFile(
        name: 'test.txt',
        fullPath: '/test/test.txt',
        type: FileType.regular,
        displayName: 'test.txt',
        size: 100,
        lastModified: DateTime.now(),
      );

      final result = await sshProvider.readFile(mockFile);
      expect(result, isA<FileContent>());
      expect(result.content, isNotEmpty);
    });

    test('readFileWithMode should return error content when not connected', () async {
      final mockFile = SshFile(
        name: 'test.txt',
        fullPath: '/test/test.txt',
        type: FileType.regular,
        displayName: 'test.txt',
        size: 100,
        lastModified: DateTime.now(),
      );

      final result = await sshProvider.readFileWithMode(mockFile, FileViewMode.head);
      expect(result, isA<FileContent>());
      expect(result.content, isNotEmpty);
    });

    test('executeFile should fail when not connected', () async {
      final mockFile = SshFile(
        name: 'test.sh',
        fullPath: '/test/test.sh',
        type: FileType.executable,
        displayName: 'test.sh*',
        size: 100,
        lastModified: DateTime.now(),
      );

      final result = await sshProvider.executeFile(mockFile);
      expect(result, isNull);
      expect(sshProvider.errorMessage, isNotNull);
    });

    test('logout should work even when not connected', () async {
      await sshProvider.logout();
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('logout with forgetCredentials should work', () async {
      await sshProvider.logout(forgetCredentials: true);
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('hasSavedCredentials should return boolean', () async {
      final result = await sshProvider.hasSavedCredentials();
      expect(result, isA<bool>());
    });

    test('clearSavedCredentials should work without errors', () async {
      await sshProvider.clearSavedCredentials();
      expect(sshProvider.connectionState, SshConnectionState.disconnected);
    });

    test('connection state booleans should be consistent', () {
      expect(sshProvider.isConnected, sshProvider.connectionState.isConnected);
      expect(sshProvider.isConnecting, sshProvider.connectionState.isConnecting);
    });

    test('properties should have correct types', () {
      expect(sshProvider.sessionLog, isA<List>());
      expect(sshProvider.navigationHistory, isA<List>());
      expect(sshProvider.currentFiles, isA<List>());
      expect(sshProvider.currentPath, isA<String>());
      expect(sshProvider.loggingEnabled, isA<bool>());
      expect(sshProvider.maxLogEntries, isA<int>());
      expect(sshProvider.shouldPlayErrorSound, isA<bool>());
    });
  });
}