import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/screens/terminal_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/execution_result.dart';
void main() {
  group('TerminalScreen', () {
    late SshProvider mockSshProvider;
    setUp(() {
      mockSshProvider = SshProvider();
    });
    testWidgets('should display initial empty terminal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );
      expect(find.text('Terminal pronto. Digite um comando abaixo.'),
          findsOneWidget);
      expect(find.text('\$ '), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
    testWidgets('should display initial result when provided',
        (WidgetTester tester) async {
      final initialResult = ExecutionResult(
        stdout: 'Hello World',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: TerminalScreen(
              initialResult: initialResult,
              initialCommand: 'echo "Hello World"',
            ),
          ),
        ),
      );
      expect(find.text('echo "Hello World"'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Terminal pronto. Digite um comando abaixo.'),
          findsNothing);
    });
    testWidgets('should handle command input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'ls -la');
      expect(find.text('ls -la'), findsOneWidget);
    });
    testWidgets('should disable input during execution',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'sleep 5');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
    });
    testWidgets('should clear history when clear button is pressed',
        (WidgetTester tester) async {
      final initialResult = ExecutionResult(
        stdout: 'Hello World',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: TerminalScreen(
              initialResult: initialResult,
              initialCommand: 'echo "Hello World"',
            ),
          ),
        ),
      );
      expect(find.text('Hello World'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pump();
      expect(find.text('Hello World'), findsNothing);
      expect(find.text('Terminal pronto. Digite um comando abaixo.'),
          findsOneWidget);
    });
    testWidgets('should have proper styling for terminal theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.black);
      expect(appBar.foregroundColor, Colors.green);
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
    test('should support copyWith method', () {
      final timestamp = DateTime.now();
      final result = ExecutionResult(
        stdout: 'output',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: timestamp,
      );
      final original = TerminalEntry(
        command: 'ls',
        result: null,
        timestamp: timestamp,
        isExecuting: true,
      );
      final modified = original.copyWith(
        result: result,
        isExecuting: false,
      );
      expect(modified.command, 'ls'); 
      expect(modified.result, result); 
      expect(modified.timestamp, timestamp); 
      expect(modified.isExecuting, false); 
    });
  });
}
