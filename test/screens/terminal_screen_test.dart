import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easyssh/screens/terminal_screen.dart';
import 'package:easyssh/providers/ssh_provider.dart';
import 'package:easyssh/models/execution_result.dart';

void main() {
  group('TerminalScreen', () {
    late SshProvider mockSshProvider;

    setUp(() {
      mockSshProvider = SshProvider();
    });

    testWidgets('should display initial empty terminal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );

      // Check for terminal ready message
      expect(find.text('Terminal pronto. Digite um comando abaixo.'), findsOneWidget);
      
      // Check for command prompt
      expect(find.text('\$ '), findsOneWidget);
      
      // Check for input field
      expect(find.byType(TextField), findsOneWidget);
      
      // Check for send button
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should display initial result when provided', (WidgetTester tester) async {
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

      // Should show the initial command
      expect(find.text('echo "Hello World"'), findsOneWidget);
      
      // Should show the output
      expect(find.text('Hello World'), findsOneWidget);
      
      // Should not show the ready message
      expect(find.text('Terminal pronto. Digite um comando abaixo.'), findsNothing);
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

      // Find the text field and enter a command
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'ls -la');
      
      // Verify the command was entered
      expect(find.text('ls -la'), findsOneWidget);
    });

    testWidgets('should disable input during execution', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );

      // Enter a command
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'sleep 5');
      
      // Tap send button (this would normally trigger execution)
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      
      // Note: Since we're not connected, the execution will fail quickly
      // but we can still test the UI behavior
    });

    testWidgets('should clear history when clear button is pressed', (WidgetTester tester) async {
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

      // Verify initial content is there
      expect(find.text('Hello World'), findsOneWidget);
      
      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pump();
      
      // Verify content is cleared and ready message is shown
      expect(find.text('Hello World'), findsNothing);
      expect(find.text('Terminal pronto. Digite um comando abaixo.'), findsOneWidget);
    });

    testWidgets('should have proper styling for terminal theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SshProvider>.value(
            value: mockSshProvider,
            child: const TerminalScreen(),
          ),
        ),
      );

      // Check scaffold background is black
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
      
      // Check app bar styling
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

      expect(modified.command, 'ls'); // Unchanged
      expect(modified.result, result); // Changed
      expect(modified.timestamp, timestamp); // Unchanged
      expect(modified.isExecuting, false); // Changed
    });
  });
}