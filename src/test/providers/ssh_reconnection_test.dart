import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/services/error_handler.dart';

void main() {
  group('SSH Reconnection Tests', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    test('should have reconnection properties initialized', () {
      expect(sshProvider.isReconnecting, false);
      expect(sshProvider.reconnectAttempts, 0);
    });

    test('should reset reconnection state correctly', () {
      sshProvider.resetReconnectionState();
      expect(sshProvider.isReconnecting, false);
      expect(sshProvider.reconnectAttempts, 0);
    });

    test('should detect connection lost error type', () {
      const stderr = 'Connection lost to remote host';
      const command = 'ls';
      final error = ErrorHandler.analyzeError(stderr, command);

      expect(error.type, ErrorType.connectionLost);
      expect(error.severity, ErrorSeverity.critical);
      expect(error.userFriendlyMessage, contains('SSH perdida'));
    });

    test('should handle connection patterns correctly', () {
      final testCases = [
        ('Connection lost to remote host', ErrorType.connectionLost),
        ('Connection closed by remote host', ErrorType.connectionLost),
        ('Connection refused', ErrorType.connectionLost),
        (
          'ssh: Connection timeout',
          ErrorType.timeout
        ), // This should be timeout based on current pattern matching
      ];

      for (final testCase in testCases) {
        final error = ErrorHandler.analyzeError(testCase.$1, 'test');
        expect(error.type, testCase.$2, reason: 'Failed for: ${testCase.$1}');
      }
    });
  });
}
