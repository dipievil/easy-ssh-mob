import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/main.dart' as app;
import 'test_helpers/platform_mocks.dart';

void main() {
  setUpAll(() {
    registerPlatformMocks();
  });
  group('Simple App Tests', () {
    testWidgets('app loads and shows basic structure',
        (WidgetTester tester) async {
      app.main();
      await tester.pump();
      
      // Verify basic structure exists
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('can find basic UI elements', (WidgetTester tester) async {
      app.main();
      await tester.pump();
      
      // Check for form fields and buttons
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(FilledButton), findsWidgets);
    });
  });
}
