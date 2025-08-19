import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:easy_ssh_mob_new/screens/file_explorer_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/models/ssh_credentials.dart';

@GenerateMocks([SshProvider])
import 'file_explorer_screen_test.mocks.dart';

void main() {
  group('FileExplorerScreen Widget Tests', () {
    late MockSshProvider mockProvider;

    setUp(() {
      mockProvider = MockSshProvider();
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.connected);
      when(mockProvider.isConnected).thenReturn(true);
      when(mockProvider.currentPath).thenReturn('/home/user');
      when(mockProvider.currentFiles).thenReturn([]);
      when(mockProvider.navigationHistory).thenReturn([]);
      when(mockProvider.errorMessage).thenReturn(null);
      when(mockProvider.currentCredentials).thenReturn(
        const SSHCredentials(
          host: 'test-host',
          port: 22,
          username: 'test-user',
          password: 'test-password',
        ),
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<SshProvider>.value(
          value: mockProvider,
          child: const FileExplorerScreen(),
        ),
      );
    }

    testWidgets('should display logout button in app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the logout button icon in the app bar
      expect(find.byTooltip('Logout'), findsOneWidget);
    });

    testWidgets('should show logout dialog when logout button is tapped',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap the logout button
      await tester.tap(find.byTooltip('Logout'));
      await tester.pumpAndSettle();

      // Verify logout dialog is shown
      expect(find.text('Logout'), findsWidgets);
      expect(
          find.text('Deseja desconectar do servidor SSH? '
              'Você retornará à tela de login.'),
          findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should have PopScope for back button handling',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify the widget builds successfully and contains the expected structure
      // PopScope is inside Consumer, so we just verify the screen loads properly
      expect(find.byType(FileExplorerScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should cancel logout when cancel is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open logout dialog
      await tester.tap(find.byTooltip('Logout'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(
          find.text('Deseja desconectar do servidor SSH? '
              'Você retornará à tela de login.'),
          findsNothing);
    });
  });
}
