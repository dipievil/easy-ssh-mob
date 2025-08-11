import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:easy_ssh_mob_new/screens/login_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/models/ssh_credentials.dart';

// Gerar mocks - execute: flutter packages pub run build_runner build
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
      await tester.pumpAndSettle();

      // Verificar se os campos estão presentes
      expect(find.byType(TextFormField), findsNWidgets(4));

      // Procurar por texto específico ou hint text dos campos
      expect(find.text('Host/IP'), findsOneWidget);
      expect(find.text('Porta'), findsOneWidget);
      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      // Verificar se o botão conectar está presente
      expect(find.text('Conectar'), findsOneWidget);
    });

    testWidgets('should validate required fields on connect',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tentar conectar com campos vazios
      final connectButton = find.text('Conectar');
      await tester.tap(connectButton);
      await tester.pump();

      // Deve mostrar mensagens de validação
      expect(find.text('Host/IP é obrigatório'), findsOneWidget);
      expect(find.text('Usuário é obrigatório'), findsOneWidget);
    });

    testWidgets('should validate port field correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontrar o campo de porta
      final portField = find.byType(TextFormField).at(1);

      // Limpar o campo de porta
      await tester.enterText(portField, '');
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      expect(find.text('Porta é obrigatória'), findsOneWidget);

      // Testar porta inválida
      await tester.enterText(portField, 'abc');
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      expect(find.text('Porta deve ser um número'), findsOneWidget);

      // Testar porta fora do range
      await tester.enterText(portField, '70000');
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      expect(find.text('Porta deve estar entre 1 e 65535'), findsOneWidget);
    });

    testWidgets('should show/hide password correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontrar o campo de senha
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'testpassword');
      await tester.pump();

      // Clicar no ícone para mostrar senha
      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Verificar se o ícone mudou
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should show loading state during connection',
        (WidgetTester tester) async {
      // Configurar o mock para estar conectando
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.connecting);
      when(mockProvider.isConnecting).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // O botão deve estar desabilitado
      final connectButton = find.text('Conectar');
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: connectButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should show error message when connection fails',
        (WidgetTester tester) async {
      const errorMessage = 'Erro de conexão';
      when(mockProvider.connectionState).thenReturn(SshConnectionState.error);
      when(mockProvider.errorMessage).thenReturn(errorMessage);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar mensagem de erro
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should load saved credentials if available',
        (WidgetTester tester) async {
      const credentials = SSHCredentials(
        host: 'saved-host',
        port: 2222,
        username: 'saved-user',
        password: 'saved-pass',
      );
      when(mockProvider.currentCredentials).thenReturn(credentials);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar se os campos foram preenchidos
      expect(find.text('saved-host'), findsOneWidget);
      expect(find.text('2222'), findsOneWidget);
      expect(find.text('saved-user'), findsOneWidget);
    });

    testWidgets('should handle remember credentials checkbox',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontrar e clicar no checkbox "Lembrar credenciais"
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Inicialmente deve estar desmarcado
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, false);

      // Clicar para marcar
      await tester.tap(checkbox);
      await tester.pump();

      // Agora deve estar marcado
      final updatedCheckbox = tester.widget<Checkbox>(checkbox);
      expect(updatedCheckbox.value, true);
    });

    testWidgets('should call connect method with correct parameters',
        (WidgetTester tester) async {
      when(mockProvider.connect(
              host: anyNamed('host'),
              port: anyNamed('port'),
              username: anyNamed('username'),
              password: anyNamed('password'),
              saveCredentials: anyNamed('saveCredentials')))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preencher os campos
      final hostField = find.byType(TextFormField).at(0);
      final portField = find.byType(TextFormField).at(1);
      final userField = find.byType(TextFormField).at(2);
      final passField = find.byType(TextFormField).at(3);

      await tester.enterText(hostField, 'test-host');
      await tester.enterText(portField, '22');
      await tester.enterText(userField, 'test-user');
      await tester.enterText(passField, 'test-pass');

      // Marcar "lembrar credenciais"
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Conectar
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Verificar se o método connect foi chamado com os parâmetros corretos
      verify(mockProvider.connect(
        host: 'test-host',
        port: 22,
        username: 'test-user',
        password: 'test-pass',
        saveCredentials: true,
      )).called(1);
    });
  });
}
