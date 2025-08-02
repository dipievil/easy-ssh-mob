import 'package:flutter_test/flutter_test.dart';
import '../../src/lib/models/execution_result.dart';

void main() {
  group('ExecutionResult', () {
    test('should create ExecutionResult with required parameters', () {
      final timestamp = DateTime.now();
      const duration = Duration(milliseconds: 500);
      
      final result = ExecutionResult(
        stdout: 'Hello World',
        stderr: '',
        exitCode: 0,
        duration: duration,
        timestamp: timestamp,
      );
      
      expect(result.stdout, 'Hello World');
      expect(result.stderr, '');
      expect(result.exitCode, 0);
      expect(result.duration, duration);
      expect(result.timestamp, timestamp);
    });

    test('should correctly identify error conditions', () {
      // Test stderr present
      final errorResult1 = ExecutionResult(
        stdout: '',
        stderr: 'Error message',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(errorResult1.hasError, true);

      // Test non-zero exit code
      final errorResult2 = ExecutionResult(
        stdout: 'Some output',
        stderr: '',
        exitCode: 1,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(errorResult2.hasError, true);

      // Test success case
      final successResult = ExecutionResult(
        stdout: 'Success output',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(successResult.hasError, false);

      // Test null exit code (should not be error if no stderr)
      final nullExitResult = ExecutionResult(
        stdout: 'Output',
        stderr: '',
        exitCode: null,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(nullExitResult.hasError, false);
    });

    test('should correctly identify empty results', () {
      final emptyResult = ExecutionResult(
        stdout: '',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(emptyResult.isEmpty, true);

      final nonEmptyResult = ExecutionResult(
        stdout: 'Output',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(nonEmptyResult.isEmpty, false);
    });

    test('should generate correct combined output', () {
      final result = ExecutionResult(
        stdout: 'Standard output',
        stderr: 'Error output',
        exitCode: 1,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      
      expect(result.combinedOutput, 'Standard output\n--- STDERR ---\nError output');

      // Test stdout only
      final stdoutOnlyResult = ExecutionResult(
        stdout: 'Only stdout',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(stdoutOnlyResult.combinedOutput, 'Only stdout');

      // Test stderr only
      final stderrOnlyResult = ExecutionResult(
        stdout: '',
        stderr: 'Only stderr',
        exitCode: 1,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(stderrOnlyResult.combinedOutput, 'Only stderr');

      // Test empty
      final emptyResult = ExecutionResult(
        stdout: '',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(emptyResult.combinedOutput, '');
    });

    test('should generate correct status descriptions', () {
      final successResult = ExecutionResult(
        stdout: 'Success',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(successResult.statusDescription, 'Success');

      final errorResult = ExecutionResult(
        stdout: '',
        stderr: 'Error',
        exitCode: 1,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(errorResult.statusDescription, 'Failed (exit code: 1)');

      final errorNoCodeResult = ExecutionResult(
        stdout: '',
        stderr: 'Error',
        exitCode: null,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      expect(errorNoCodeResult.statusDescription, 'Failed');
    });

    test('should support copyWith method', () {
      final original = ExecutionResult(
        stdout: 'Original stdout',
        stderr: 'Original stderr',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );

      final modified = original.copyWith(
        stdout: 'Modified stdout',
        exitCode: 1,
      );

      expect(modified.stdout, 'Modified stdout');
      expect(modified.stderr, 'Original stderr'); // Unchanged
      expect(modified.exitCode, 1);
      expect(modified.duration, original.duration); // Unchanged
      expect(modified.timestamp, original.timestamp); // Unchanged
    });

    test('should support equality comparison', () {
      final timestamp = DateTime.now();
      const duration = Duration(milliseconds: 100);

      final result1 = ExecutionResult(
        stdout: 'Output',
        stderr: '',
        exitCode: 0,
        duration: duration,
        timestamp: timestamp,
      );

      final result2 = ExecutionResult(
        stdout: 'Output',
        stderr: '',
        exitCode: 0,
        duration: duration,
        timestamp: timestamp,
      );

      final result3 = ExecutionResult(
        stdout: 'Different output',
        stderr: '',
        exitCode: 0,
        duration: duration,
        timestamp: timestamp,
      );

      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });

    test('should generate informative toString', () {
      final result = ExecutionResult(
        stdout: 'Hello World',
        stderr: 'Some error',
        exitCode: 0,
        duration: const Duration(milliseconds: 250),
        timestamp: DateTime.now(),
      );

      final str = result.toString();
      expect(str, contains('ExecutionResult'));
      expect(str, contains('11 chars')); // stdout length
      expect(str, contains('10 chars')); // stderr length
      expect(str, contains('exitCode: 0'));
      expect(str, contains('250ms'));
    });
  });
}