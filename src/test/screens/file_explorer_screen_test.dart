import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/screens/file_explorer_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';

void main() {
  group('FileExplorerScreen', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    testWidgets('should create FileExplorerScreen widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      expect(find.byType(FileExplorerScreen), findsOneWidget);
    });

    testWidgets('should display AppBar with current path',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('/'), findsOneWidget); // Default path should be root
    });

    testWidgets('should have Home and Tools buttons in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display connection status indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      // Should show disconnected status by default
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should have FloatingActionButton for refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should show Tools bottom sheet when settings button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const FileExplorerScreen(),
          ),
        ),
      );

      // Tap the settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show the tools bottom sheet
      expect(find.text('Ferramentas'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Atualizar'), findsOneWidget);
    });
  });
}
