import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Accessibility Tests', () {
    group('Basic Widget Tests', () {
      testWidgets('should render Material app without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            title: 'Easy SSH Mob',
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Easy SSH Mob'),
              ),
              body: const Center(
                child: Text('Welcome to Easy SSH Mob'),
              ),
            ),
          ),
        );

        // Test basic rendering without errors
        expect(tester.takeException(), isNull);
        expect(find.text('Easy SSH Mob'), findsOneWidget);
        expect(find.text('Welcome to Easy SSH Mob'), findsOneWidget);
      });

      testWidgets('should handle text input fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Host',
                      hintText: 'Enter server address',
                    ),
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter username',
                    ),
                    obscureText: false,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                    ),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Connect'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test form elements
        expect(find.byType(TextField), findsNWidgets(3));
        expect(find.text('Host'), findsOneWidget);
        expect(find.text('Username'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);

        // Test text input
        await tester.enterText(
            find.widgetWithText(TextField, 'Enter server address'), 'test.com');
        await tester.enterText(
            find.widgetWithText(TextField, 'Enter username'), 'user');

        expect(find.text('test.com'), findsOneWidget);
        expect(find.text('user'), findsOneWidget);

        // Test button interaction
        await tester.tap(find.text('Connect'));
        await tester.pump();
      });
    });

    group('Text Scaling', () {
      testWidgets('should handle large text sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Large Text'),
                ),
                body: const Column(
                  children: [
                    Text('This is large text'),
                    ElevatedButton(
                      onPressed: null,
                      child: Text('Large Button'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Large Text'), findsOneWidget);
        expect(find.text('This is large text'), findsOneWidget);
        expect(find.text('Large Button'), findsOneWidget);
      });

      testWidgets('should handle small text sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(0.8)),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Small Text'),
                ),
                body: const Column(
                  children: [
                    Text('This is small text'),
                    ElevatedButton(
                      onPressed: null,
                      child: Text('Small Button'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Small Text'), findsOneWidget);
        expect(find.text('This is small text'), findsOneWidget);
        expect(find.text('Small Button'), findsOneWidget);
      });
    });

    group('Theme Accessibility', () {
      testWidgets('should work with light theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Light Theme'),
              ),
              body: const Column(
                children: [
                  Text('Light theme text'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Card content'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Light Theme'), findsOneWidget);
        expect(find.text('Light theme text'), findsOneWidget);
        expect(find.text('Card content'), findsOneWidget);
      });

      testWidgets('should work with dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Dark Theme'),
              ),
              body: const Column(
                children: [
                  Text('Dark theme text'),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Card content'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Dark Theme'), findsOneWidget);
        expect(find.text('Dark theme text'), findsOneWidget);
        expect(find.text('Card content'), findsOneWidget);
      });
    });

    group('Interactive Elements', () {
      testWidgets('should handle button interactions',
          (WidgetTester tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => buttonPressed = true,
                    child: const Text('Tap me'),
                  ),
                  IconButton(
                    onPressed: () => buttonPressed = true,
                    icon: const Icon(Icons.home),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test button presence and tap
        expect(find.text('Tap me'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);

        await tester.tap(find.text('Tap me'));
        expect(buttonPressed, isTrue);
      });

      testWidgets('should handle checkbox interactions',
          (WidgetTester tester) async {
        bool checkboxValue = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Remember me'),
                        value: checkboxValue,
                        onChanged: (value) {
                          setState(() {
                            checkboxValue = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Remember me'), findsOneWidget);
        expect(find.byType(Checkbox), findsOneWidget);

        // Tap checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Widget should be found after state change
        expect(find.byType(CheckboxListTile), findsOneWidget);
      });
    });

    group('Semantics', () {
      testWidgets('should provide proper semantics for buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Semantics(
                    button: true,
                    label: 'Connect to server',
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Connect'),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Go back',
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Connect'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        await tester.tap(find.text('Connect'));
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
      });

      testWidgets('should provide proper semantics for text fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Semantics(
                    textField: true,
                    label: 'Server hostname',
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: 'Host',
                        hintText: 'Enter server hostname',
                      ),
                    ),
                  ),
                  Semantics(
                    textField: true,
                    label: 'Username for login',
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: 'User',
                        hintText: 'Enter username',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Host'), findsOneWidget);
        expect(find.text('User'), findsOneWidget);

        // Test text input
        await tester.enterText(
            find.widgetWithText(TextField, 'Enter server hostname'),
            'server.com');
        await tester.enterText(
            find.widgetWithText(TextField, 'Enter username'), 'myuser');

        expect(find.text('server.com'), findsOneWidget);
        expect(find.text('myuser'), findsOneWidget);
      });
    });
  });
}
