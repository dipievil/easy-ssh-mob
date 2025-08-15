import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easy_ssh_mob_new/main.dart' as app;
import '../test_helpers/platform_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerPlatformMocks();
  });
  group('EasySSH Integration Tests', () {
    testWidgets('complete app startup and navigation flow',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Host/IP'), findsOneWidget);
      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('CONECTAR'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
    });
    testWidgets('login form validation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.text('Host/IP é obrigatório'), findsOneWidget);
      expect(find.text('Usuário é obrigatório'), findsOneWidget);
    });
    testWidgets('login form input and validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final hostField = find.byType(TextFormField).at(0);
      final portField = find.byType(TextFormField).at(1);
      final userField = find.byType(TextFormField).at(2);
      final passField = find.byType(TextFormField).at(3);
      await tester.enterText(hostField, 'test-server.example.com');
      await tester.enterText(portField, '22');
      await tester.enterText(userField, 'testuser');
      await tester.enterText(passField, 'testpass');
      expect(find.text('test-server.example.com'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('password visibility toggle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'secretpassword');
      await tester.pump();
      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
    testWidgets('remember credentials checkbox functionality',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, false);
      await tester.tap(checkbox);
      await tester.pump();
      final updatedCheckbox = tester.widget<Checkbox>(checkbox);
      expect(updatedCheckbox.value, true);
    });
    testWidgets('port validation edge cases', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final portField = find.byType(TextFormField).at(1);
      await tester.enterText(portField, 'invalid');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.text('Porta deve ser um número'), findsOneWidget);
      await tester.enterText(portField, '70000');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.text('Porta deve estar entre 1 e 65535'), findsOneWidget);
      await tester.enterText(portField, '0');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.text('Porta deve estar entre 1 e 65535'), findsOneWidget);
      await tester.enterText(portField, '22');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.text('Porta deve ser um número'), findsNothing);
      expect(find.text('Porta deve estar entre 1 e 65535'), findsNothing);
    });
    testWidgets('app theme and responsiveness', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
    testWidgets('error handling for connection timeout',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextFormField).at(0), 'nonexistent-host.invalid');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'user');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsAny);
    });
    testWidgets('app state persistence simulation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'saved-host');
      await tester.enterText(find.byType(TextFormField).at(1), '2222');
      await tester.enterText(find.byType(TextFormField).at(2), 'saved-user');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.pumpWidget(Container());
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(4));
    });
  });
  group('Error Handling Integration Tests', () {
    testWidgets('network error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextFormField).at(0), '192.168.999.999');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'user');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('invalid credentials handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'localhost');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid_user');
      await tester.enterText(find.byType(TextFormField).at(3), 'invalid_pass');
      await tester.tap(find.text('CONECTAR'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
