import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Accessibility Tests', () {
    testWidgets('Basic accessibility test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test App'),
            ),
            body: const Column(
              children: [
                Text('Hello World'),
                ElevatedButton(
                  onPressed: null,
                  child: Text('Test Button'),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
    testWidgets('Semantics test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Semantics(
                  label: 'Test label',
                  button: true,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Click me'),
                  ),
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Input field',
                    hintText: 'Enter text here',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Click me'), findsOneWidget);
      expect(find.text('Input field'), findsOneWidget);
      await tester.tap(find.text('Click me'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Test input');
      expect(find.text('Test input'), findsOneWidget);
    });
    testWidgets('Accessibility with different text scales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Column(
                children: [
                  const Text('Scaled text'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Scaled button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Scaled text'), findsOneWidget);
      expect(find.text('Scaled button'), findsOneWidget);
    });
  });
}
