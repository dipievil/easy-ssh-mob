import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/models/execution_result.dart';
import 'package:easy_ssh_mob_new/widgets/execution_result_dialog.dart';

void main() {
  group('ExecutionResultDialog', () {
    late ExecutionResult successResult;
    late ExecutionResult errorResult;
    late ExecutionResult emptyResult;
    setUp(() {
      successResult = ExecutionResult(
        stdout: 'Hello World\nSecond line',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 250),
        timestamp: DateTime.now(),
      );
      errorResult = ExecutionResult(
        stdout: 'Some output\nAnother line',
        stderr: 'Error occurred\nSecond error line',
        exitCode: 1,
        duration: const Duration(milliseconds: 500),
        timestamp: DateTime.now(),
      );
      emptyResult = ExecutionResult(
        stdout: '',
        stderr: '',
        exitCode: 0,
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );
    });
    testWidgets('should display success dialog correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExecutionResultDialog(
                    result: successResult,
                    fileName: 'test.sh',
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Execução: test.sh'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Tempo: 250ms'), findsOneWidget);
      expect(find.text('Hello World\nSecond line'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
    });
    testWidgets('should display error dialog with tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExecutionResultDialog(
                    result: errorResult,
                    fileName: 'error.sh',
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Failed (exit code: 1)'), findsOneWidget);
      expect(find.text('Saída (2 linhas)'), findsOneWidget);
      expect(find.text('Erros (2 linhas)'), findsOneWidget);
      expect(find.text('Some output\nAnother line'), findsOneWidget);
      await tester.tap(find.text('Erros (2 linhas)'));
      await tester.pumpAndSettle();
      expect(find.text('Error occurred\nSecond error line'), findsOneWidget);
    });
    testWidgets('should display empty result dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExecutionResultDialog(
                    result: emptyResult,
                    fileName: 'empty.sh',
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Sem saída'), findsOneWidget);
      expect(find.text('Copiar'), findsNothing);
      expect(find.text('Fechar'), findsOneWidget);
    });
    testWidgets('should close dialog when close button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExecutionResultDialog(
                    result: successResult,
                    fileName: 'test.sh',
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Execução: test.sh'), findsOneWidget);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Execução: test.sh'), findsNothing);
    });
    testWidgets('should handle long file names with ellipsis',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExecutionResultDialog(
                    result: successResult,
                    fileName:
                        'very_long_file_name_that_should_be_truncated_with_ellipsis.sh',
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(
          find.textContaining('Execução: very_long_file_name'), findsOneWidget);
    });
  });
}
