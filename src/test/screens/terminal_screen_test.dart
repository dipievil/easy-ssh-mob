import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/screens/terminal_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/execution_result.dart';
import '../test_helpers/platform_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerPlatformMocks();
  });

  group('TerminalScreen', () {
    testWidgets('should create TerminalScreen widget',
        (WidgetTester tester) async {
      final mockSshProvider = SshProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );

      expect(find.byType(TerminalScreen), findsOneWidget);
    });
  });

  group('TerminalEntry', () {
    test('should create TerminalEntry correctly', () {
      final timestamp = DateTime.now();
      final result = ExecutionResult(
        stdout: 'output',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: timestamp,
      );

      final entry = TerminalEntry(
        command: 'ls',
        result: result,
        timestamp: timestamp,
      );

      expect(entry.command, 'ls');
      expect(entry.result, result);
      expect(entry.timestamp, timestamp);
      expect(entry.isExecuting, false);
    });
  });
}
