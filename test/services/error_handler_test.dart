import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/services/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    test('should detect permission denied error', () {
      const stderr = 'bash: permission denied: /test/file.sh';
      const command = '/test/file.sh';
      
      final error = ErrorHandler.analyzeError(stderr, command);
      
      expect(error.type, ErrorType.permissionDenied);
      expect(error.severity, ErrorSeverity.warning);
      expect(error.suggestion, isNotNull);
      expect(error.userFriendlyMessage, contains('permissão'));
    });

    test('should detect file not found error', () {
      const stderr = 'ls: cannot access \'/nonexistent\': No such file or directory';
      const command = 'ls /nonexistent';
      
      final error = ErrorHandler.analyzeError(stderr, command);
      
      expect(error.type, ErrorType.fileNotFound);
      expect(error.severity, ErrorSeverity.warning);
      expect(error.userFriendlyMessage, contains('não encontrado'));
    });

    test('should detect timeout error', () {
      const stderr = 'Connection timed out after 30 seconds';
      const command = 'ping example.com';
      
      final error = ErrorHandler.analyzeError(stderr, command);
      
      expect(error.type, ErrorType.timeout);
      expect(error.severity, ErrorSeverity.warning);
      expect(error.userFriendlyMessage, contains('demorou'));
    });

    test('should handle unknown errors', () {
      const stderr = 'Some unknown error message';
      const command = 'unknown_command';
      
      final error = ErrorHandler.analyzeError(stderr, command);
      
      expect(error.type, ErrorType.unknown);
      expect(error.severity, ErrorSeverity.error);
      expect(error.userFriendlyMessage, contains('desconhecido'));
    });

    test('should detect connection lost error', () {
      const stderr = 'Connection lost to remote host';
      const command = 'ls';
      
      final error = ErrorHandler.analyzeError(stderr, command);
      
      expect(error.type, ErrorType.connectionLost);
      expect(error.severity, ErrorSeverity.critical);
      expect(error.userFriendlyMessage, contains('SSH perdida'));
    });
  });
}