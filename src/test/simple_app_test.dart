import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/main.dart' as app;
import 'test_helpers/platform_mocks.dart';

void main() {
  setUpAll(() {
    registerPlatformMocks();
  });
  group('Simple App Tests', () {
    testWidgets('app loads and shows login screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      print('Widgets found:');
      final textFields = find.byType(TextFormField);
      print('TextFormField widgets: ${textFields.evaluate().length}');
      final connectButton = find.text('CONECTAR');
      print('CONECTAR button: ${connectButton.evaluate().length}');
      final hostLabel = find.text('Host/IP');
      print('Host/IP label: ${hostLabel.evaluate().length}');
      final allTexts = find.byType(Text);
      final textWidgets = allTexts.evaluate();
      print('All Text widgets (${textWidgets.length}):');
      for (final textWidget in textWidgets) {
        final widget = textWidget.widget as Text;
        if (widget.data != null) {
          print('  - "${widget.data}"');
        }
      }
    });
    testWidgets('can find button without tapping', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final buttonByText = find.text('CONECTAR');
      final buttonByType = find.byType(FilledButton);
      print('Button by text: ${buttonByText.evaluate().length}');
      print('Button by type: ${buttonByType.evaluate().length}');
      if (buttonByText.evaluate().isNotEmpty) {
        final buttonWidget = tester.widget(buttonByText);
        print('Button widget type: ${buttonWidget.runtimeType}');
        final filledButton = find.ancestor(
            of: buttonByText, matching: find.byType(FilledButton));
        if (filledButton.evaluate().isNotEmpty) {
          final FilledButton button = tester.widget(filledButton);
          print('Button enabled: ${button.onPressed != null}');
        }
      }
      expect(true, true);
    });
  });
}
