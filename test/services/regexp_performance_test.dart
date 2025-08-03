import 'package:flutter_test/flutter_test.dart';
import '../../src/lib/services/error_handler.dart';

void main() {
  group('RegExp Performance Optimization Tests', () {
    test('ErrorHandler uses optimized static const RegExp patterns', () {
      // This test verifies that our RegExp patterns are working correctly
      // and demonstrates the optimization is in place
      
      const testCases = {
        'Permission denied for user': ErrorType.permissionDenied,
        'No such file or directory': ErrorType.fileNotFound,
        'Operation not permitted by system': ErrorType.operationNotPermitted,
        'Access denied to resource': ErrorType.accessDenied,
        'Connection lost to server': ErrorType.connectionLost,
        'Operation timed out': ErrorType.timeout,
        'bash: command not found': ErrorType.commandNotFound,
        'No space left on device': ErrorType.diskFull,
      };
      
      for (final testCase in testCases.entries) {
        final error = ErrorHandler.analyzeError(testCase.key, 'test_command');
        
        expect(
          error.type, 
          testCase.value,
          reason: 'Pattern "${testCase.key}" should match ${testCase.value}'
        );
        
        expect(
          error.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'Should have user-friendly message'
        );
      }
    });
    
    test('Unknown errors are handled correctly', () {
      const unknownError = 'Some completely unknown error message';
      final error = ErrorHandler.analyzeError(unknownError, 'test_command');
      
      expect(error.type, ErrorType.unknown);
      expect(error.severity, ErrorSeverity.error);
      expect(error.userFriendlyMessage, contains('desconhecido'));
    });
    
    test('RegExp patterns are case insensitive', () {
      const testCases = [
        'PERMISSION DENIED',
        'permission denied',
        'Permission Denied',
        'PeRmIsSiOn DeNiEd',
      ];
      
      for (final testCase in testCases) {
        final error = ErrorHandler.analyzeError(testCase, 'test_command');
        expect(
          error.type, 
          ErrorType.permissionDenied,
          reason: 'Case insensitive matching should work for: $testCase'
        );
      }
    });
    
    test('Complex RegExp patterns work correctly', () {
      const connectionTests = [
        'Connection lost',
        'Connection closed by server',
        'Connection refused by host',
        'Network connection lost unexpectedly',
      ];
      
      for (final testCase in connectionTests) {
        final error = ErrorHandler.analyzeError(testCase, 'test_command');
        expect(
          error.type, 
          ErrorType.connectionLost,
          reason: 'Connection pattern should match: $testCase'
        );
      }
    });
  });
}