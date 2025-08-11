import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/models/log_entry.dart';

void main() {
  group('LogEntry', () {
    group('constructor and basic properties', () {
      test('should create LogEntry with all properties', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30, 0);
        const duration = Duration(milliseconds: 250);

        final entry = LogEntry(
          id: 'test_001',
          timestamp: timestamp,
          command: 'ls -la',
          type: CommandType.navigation,
          workingDirectory: '/home/user',
          stdout: 'total 12\ndrwxr-xr-x 2 user user 4096 Jan 15 10:30 .',
          stderr: '',
          exitCode: 0,
          duration: duration,
          status: CommandStatus.success,
        );

        expect(entry.id, equals('test_001'));
        expect(entry.command, equals('ls -la'));
        expect(entry.type, equals(CommandType.navigation));
        expect(entry.workingDirectory, equals('/home/user'));
        expect(entry.stdout, contains('total 12'));
        expect(entry.stderr, equals(''));
        expect(entry.exitCode, equals(0));
        expect(entry.duration, equals(duration));
        expect(entry.status, equals(CommandStatus.success));
      });

      test('should handle error command correctly', () {
        final entry = LogEntry(
          id: 'test_002',
          timestamp: DateTime(2024, 1, 15, 10, 30, 0),
          command: 'cat /nonexistent',
          type: CommandType.fileView,
          workingDirectory: '/home/user',
          stdout: '',
          stderr: 'cat: /nonexistent: No such file or directory',
          exitCode: 1,
          duration: const Duration(milliseconds: 50),
          status: CommandStatus.error,
        );

        expect(entry.hasError, isTrue);
        expect(entry.wasSuccessful, isFalse);
        expect(entry.stderr, isNotEmpty);
        expect(entry.exitCode, equals(1));
      });
    });

    group('serialization', () {
      test('should convert to and from JSON correctly', () {
        final originalEntry = LogEntry(
          id: 'test_003',
          timestamp: DateTime(2024, 1, 15, 10, 30, 0),
          command: 'pwd',
          type: CommandType.navigation,
          workingDirectory: '/home/user',
          stdout: '/home/user',
          stderr: '',
          exitCode: 0,
          duration: const Duration(milliseconds: 15),
          status: CommandStatus.success,
          metadata: {'test': 'value'},
        );

        final json = originalEntry.toJson();
        final restoredEntry = LogEntry.fromJson(json);

        expect(restoredEntry.id, equals(originalEntry.id));
        expect(restoredEntry.timestamp, equals(originalEntry.timestamp));
        expect(restoredEntry.command, equals(originalEntry.command));
        expect(restoredEntry.type, equals(originalEntry.type));
        expect(restoredEntry.workingDirectory,
            equals(originalEntry.workingDirectory));
        expect(restoredEntry.stdout, equals(originalEntry.stdout));
        expect(restoredEntry.stderr, equals(originalEntry.stderr));
        expect(restoredEntry.exitCode, equals(originalEntry.exitCode));
        expect(restoredEntry.duration, equals(originalEntry.duration));
        expect(restoredEntry.status, equals(originalEntry.status));
        expect(restoredEntry.metadata, equals(originalEntry.metadata));
      });
    });

    group('formatting methods', () {
      test('should format duration correctly', () {
        final fastEntry = LogEntry(
          id: 'fast',
          timestamp: DateTime.now(),
          command: 'pwd',
          type: CommandType.navigation,
          workingDirectory: '/home',
          stdout: '/home',
          stderr: '',
          duration: const Duration(milliseconds: 150),
          status: CommandStatus.success,
        );

        expect(fastEntry.durationFormatted, equals('150ms'));

        final slowEntry = LogEntry(
          id: 'slow',
          timestamp: DateTime.now(),
          command: 'find /',
          type: CommandType.navigation,
          workingDirectory: '/home',
          stdout: 'many results...',
          stderr: '',
          duration: const Duration(seconds: 2, milliseconds: 500),
          status: CommandStatus.success,
        );

        expect(slowEntry.durationFormatted, equals('2.500s'));
      });

      test('should create short command for display', () {
        final shortEntry = LogEntry(
          id: 'short',
          timestamp: DateTime.now(),
          command: 'ls',
          type: CommandType.navigation,
          workingDirectory: '/home',
          stdout: '',
          stderr: '',
          duration: const Duration(milliseconds: 50),
          status: CommandStatus.success,
        );

        expect(shortEntry.shortCommand, equals('ls'));

        const longCommand =
            'find /home/user -type f -name "*.log" -exec grep "error" {} \\; | head -20';
        final longEntry = LogEntry(
          id: 'long',
          timestamp: DateTime.now(),
          command: longCommand,
          type: CommandType.fileView,
          workingDirectory: '/home',
          stdout: '',
          stderr: '',
          duration: const Duration(milliseconds: 1000),
          status: CommandStatus.success,
        );

        expect(longEntry.shortCommand.length, equals(50));
        expect(longEntry.shortCommand, endsWith('...'));
      });

      test('should create stdout and stderr previews', () {
        final entry = LogEntry(
          id: 'preview_test',
          timestamp: DateTime.now(),
          command: 'cat large_file.txt',
          type: CommandType.fileView,
          workingDirectory: '/home',
          stdout:
              'This is a very long line that should be truncated in preview because it exceeds the maximum length allowed for preview display',
          stderr:
              'Warning: file is large and may take time to process completely',
          duration: const Duration(seconds: 1),
          status: CommandStatus.partial,
        );

        expect(entry.stdoutPreview.length, lessThanOrEqualTo(100));
        expect(entry.stdoutPreview, endsWith('...'));

        expect(entry.stderrPreview.length, lessThanOrEqualTo(100));
        expect(entry.stderrPreview, contains('Warning'));
      });
    });

    group('CSV formatting', () {
      test('should format as CSV row correctly', () {
        final entry = LogEntry(
          id: 'csv_test',
          timestamp: DateTime(2024, 1, 15, 10, 30, 45),
          command: 'ls -la',
          type: CommandType.navigation,
          workingDirectory: '/home/user',
          stdout: 'total 8\ndrwxr-xr-x 2 user user',
          stderr: '',
          exitCode: 0,
          duration: const Duration(milliseconds: 120),
          status: CommandStatus.success,
        );

        final csvRow = entry.toCsvRow();
        final fields = csvRow.split(',');

        expect(fields[0], equals('2024-01-15 10:30:45')); // timestamp
        expect(fields[1], equals('ls -la')); // command
        expect(fields[2], equals('Navigation')); // type
        expect(fields[3], equals('Success')); // status
        expect(fields[4], equals('120ms')); // duration
        expect(fields[5], equals('/home/user')); // working directory
        expect(fields[6], equals('0')); // exit code
      });

      test('should escape CSV fields with commas', () {
        final entry = LogEntry(
          id: 'csv_escape_test',
          timestamp: DateTime(2024, 1, 15, 10, 30, 45),
          command: 'echo "hello, world"',
          type: CommandType.execution,
          workingDirectory: '/home/user',
          stdout: 'hello, world',
          stderr: '',
          exitCode: 0,
          duration: const Duration(milliseconds: 10),
          status: CommandStatus.success,
        );

        final csvRow = entry.toCsvRow();
        expect(csvRow,
            contains('"echo ""hello, world"""')); // command should be escaped
        expect(csvRow, contains('"hello, world"')); // stdout should be escaped
      });
    });

    group('text formatting', () {
      test('should format as text with all sections', () {
        final entry = LogEntry(
          id: 'text_test',
          timestamp: DateTime(2024, 1, 15, 10, 30, 45),
          command: 'ps aux',
          type: CommandType.system,
          workingDirectory: '/home/user',
          stdout: 'USER PID %CPU %MEM\nroot 1 0.0 0.1',
          stderr: '',
          exitCode: 0,
          duration: const Duration(milliseconds: 200),
          status: CommandStatus.success,
          metadata: {'category': 'system_info'},
        );

        final textFormat = entry.toTextFormat();

        expect(textFormat, contains('=== Command Execution Log ==='));
        expect(textFormat, contains('ID: text_test'));
        expect(textFormat, contains('Command: ps aux'));
        expect(textFormat, contains('Type: System'));
        expect(textFormat, contains('Status: Success'));
        expect(textFormat, contains('Duration: 200ms'));
        expect(textFormat, contains('--- STDOUT ---'));
        expect(textFormat, contains('USER PID %CPU'));
        expect(textFormat, contains('--- METADATA ---'));
        expect(textFormat, contains('category'));
      });
    });

    group('CommandType and CommandStatus enums', () {
      test('should have all expected CommandType values', () {
        expect(CommandType.values, hasLength(6));
        expect(CommandType.values, contains(CommandType.navigation));
        expect(CommandType.values, contains(CommandType.execution));
        expect(CommandType.values, contains(CommandType.fileView));
        expect(CommandType.values, contains(CommandType.system));
        expect(CommandType.values, contains(CommandType.custom));
        expect(CommandType.values, contains(CommandType.unknown));
      });

      test('should have all expected CommandStatus values', () {
        expect(CommandStatus.values, hasLength(5));
        expect(CommandStatus.values, contains(CommandStatus.success));
        expect(CommandStatus.values, contains(CommandStatus.error));
        expect(CommandStatus.values, contains(CommandStatus.timeout));
        expect(CommandStatus.values, contains(CommandStatus.cancelled));
        expect(CommandStatus.values, contains(CommandStatus.partial));
      });
    });
  });
}
