import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:easy_ssh_mob_new/screens/login_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
@GenerateMocks([SshProvider])
import 'login_screen_test.mocks.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockSshProvider mockProvider;
    setUp(() {
      mockProvider = MockSshProvider();
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.disconnected);
      when(mockProvider.currentCredentials).thenReturn(null);
      when(mockProvider.isConnected).thenReturn(false);
      when(mockProvider.isConnecting).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn(null);
    });
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<SshProvider>.value(
          value: mockProvider,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display all required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Host/IP'), findsOneWidget);
      expect(find.text('Porta'), findsOneWidget);
      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('CONECTAR'), findsOneWidget);
    });

    testWidgets('should show loading state during connection',
        (WidgetTester tester) async {
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.connecting);
      when(mockProvider.isConnecting).thenReturn(true);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when connection fails',
        (WidgetTester tester) async {
      const errorMessage = 'Erro de conexão';
      when(mockProvider.connectionState).thenReturn(SshConnectionState.error);
      when(mockProvider.errorMessage).thenReturn(errorMessage);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
