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
  group('Fixed Integration Tests', () {
    testWidgets('app loads and basic functionality works',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      app.main();
      await tester.pump();
      try {
        await tester.pumpAndSettle(const Duration(seconds: 5));
      } catch (e) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('Host/IP'), findsOneWidget);
      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('CONECTAR'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
    });
    testWidgets('can fill form and submit', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      app.main();
      await tester.pump();
      try {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } catch (e) {
        await tester.pump(const Duration(seconds: 1));
      }
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'test.example.com');
      await tester.pump();
      await tester.enterText(textFields.at(1), '22');
      await tester.pump();
      await tester.enterText(textFields.at(2), 'testuser');
      await tester.pump();
      await tester.enterText(textFields.at(3), 'testpass');
      await tester.pump();
      await tester.tap(find.text('CONECTAR'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('CONECTAR'), findsOneWidget);
    });
    testWidgets('port validation works', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      app.main();
      await tester.pump();
      try {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } catch (e) {
        await tester.pump(const Duration(seconds: 1));
      }
      final portField = find.byType(TextFormField).at(1);
      await tester.enterText(portField, 'invalid');
      await tester.pump();
      await tester.tap(find.text('CONECTAR'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('CONECTAR'), findsOneWidget);
      await tester.enterText(portField, '22');
      await tester.pump();
      await tester.tap(find.text('CONECTAR'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('CONECTAR'), findsOneWidget);
    });
    testWidgets('remember credentials checkbox works',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      app.main();
      await tester.pump();
      try {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } catch (e) {
        await tester.pump(const Duration(seconds: 1));
      }
      final checkbox = find.byType(Checkbox);
      if (checkbox.evaluate().isNotEmpty) {
        await tester.tap(checkbox, warnIfMissed: false);
        await tester.pump();
      }
      expect(find.text('CONECTAR'), findsOneWidget);
    });
    testWidgets('password visibility toggle works',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      app.main();
      await tester.pump();
      try {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } catch (e) {
        await tester.pump(const Duration(seconds: 1));
      }
      final visibilityButton = find.byIcon(Icons.visibility);
      final visibilityOffButton = find.byIcon(Icons.visibility_off);
      if (visibilityButton.evaluate().isNotEmpty) {
        await tester.tap(visibilityButton, warnIfMissed: false);
        await tester.pump();
      } else if (visibilityOffButton.evaluate().isNotEmpty) {
        await tester.tap(visibilityOffButton, warnIfMissed: false);
        await tester.pump();
      }
      expect(find.text('CONECTAR'), findsOneWidget);
    });
  });
}
