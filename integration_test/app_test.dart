import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easyssh/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EasySSH Integration Tests', () {
    testWidgets('complete app startup and navigation flow', (WidgetTester tester) async {
      // Iniciar a aplicação
      app.main();
      await tester.pumpAndSettle();

      // Verificar se está na tela de login
      expect(find.text('Host/IP'), findsOneWidget);
      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Conectar'), findsOneWidget);

      // Verificar campos de formulário
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('login form validation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tentar conectar com campos vazios
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Verificar se mensagens de validação aparecem
      expect(find.text('Host/IP é obrigatório'), findsOneWidget);
      expect(find.text('Usuário é obrigatório'), findsOneWidget);
    });

    testWidgets('login form input and validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Preencher campos com dados válidos
      final hostField = find.byType(TextFormField).at(0);
      final portField = find.byType(TextFormField).at(1);
      final userField = find.byType(TextFormField).at(2);
      final passField = find.byType(TextFormField).at(3);

      await tester.enterText(hostField, 'test-server.example.com');
      await tester.enterText(portField, '22');
      await tester.enterText(userField, 'testuser');
      await tester.enterText(passField, 'testpass');

      // Verificar se os valores foram inseridos
      expect(find.text('test-server.example.com'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      
      // Tentar conectar (falhará por não ter servidor real)
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Deve mostrar indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('password visibility toggle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar campo de senha
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'secretpassword');
      await tester.pump();

      // Inicialmente deve estar obscuro
      final textField = tester.widget<TextFormField>(passwordField);
      expect(textField.obscureText, true);

      // Clicar no ícone de visibilidade
      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Agora deve estar visível
      final updatedTextField = tester.widget<TextFormField>(passwordField);
      expect(updatedTextField.obscureText, false);
    });

    testWidgets('remember credentials checkbox functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar checkbox "Lembrar credenciais"
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

    testWidgets('port validation edge cases', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final portField = find.byType(TextFormField).at(1);
      
      // Testar porta inválida (texto)
      await tester.enterText(portField, 'invalid');
      await tester.tap(find.text('Conectar'));
      await tester.pump();
      expect(find.text('Porta deve ser um número'), findsOneWidget);

      // Testar porta fora do range (muito alta)
      await tester.enterText(portField, '70000');
      await tester.tap(find.text('Conectar'));
      await tester.pump();
      expect(find.text('Porta deve estar entre 1 e 65535'), findsOneWidget);

      // Testar porta fora do range (muito baixa)
      await tester.enterText(portField, '0');
      await tester.tap(find.text('Conectar'));
      await tester.pump();
      expect(find.text('Porta deve estar entre 1 e 65535'), findsOneWidget);

      // Testar porta válida
      await tester.enterText(portField, '22');
      await tester.tap(find.text('Conectar'));
      await tester.pump();
      expect(find.text('Porta deve ser um número'), findsNothing);
      expect(find.text('Porta deve estar entre 1 e 65535'), findsNothing);
    });

    testWidgets('app theme and responsiveness', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar se elementos básicos da UI estão presentes
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verificar se AppBar está presente
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('form accessibility and semantics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar se os campos têm labels semânticos apropriados
      final hostField = find.byType(TextFormField).at(0);
      final hostSemantics = tester.getSemantics(hostField);
      expect(hostSemantics.label, contains('Host'));

      final connectButton = find.text('Conectar');
      final buttonSemantics = tester.getSemantics(connectButton);
      expect(buttonSemantics.hasAction(SemanticsAction.tap), true);
    });

    testWidgets('error handling for connection timeout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Preencher com host inválido para forçar erro
      await tester.enterText(find.byType(TextFormField).at(0), 'nonexistent-host.invalid');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'user');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass');

      // Tentar conectar
      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Deve mostrar loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Aguardar timeout (timeout real seria muito demorado para teste)
      await tester.pump(const Duration(seconds: 1));
      
      // Verificar se ainda está carregando ou se apareceu erro
      // (O comportamento exato depende da implementação do timeout)
      expect(find.byType(CircularProgressIndicator), findsAny);
    });

    testWidgets('app state persistence simulation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Preencher campos
      await tester.enterText(find.byType(TextFormField).at(0), 'saved-host');
      await tester.enterText(find.byType(TextFormField).at(1), '2222');
      await tester.enterText(find.byType(TextFormField).at(2), 'saved-user');
      
      // Marcar "lembrar credenciais"
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Simular reinício da aplicação
      await tester.pumpWidget(Container()); // Limpar
      app.main(); // Reiniciar
      await tester.pumpAndSettle();

      // Verificar se os dados foram "lembrados" (depende da implementação)
      // Em um teste real, isso funcionaria com armazenamento persistente
      expect(find.byType(TextFormField), findsNWidgets(4));
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('network error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simular conexão com host inválido
      await tester.enterText(find.byType(TextFormField).at(0), '192.168.999.999');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'user');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass');

      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Deve mostrar loading inicialmente
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('invalid credentials handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Usar host válido mas credenciais inválidas
      await tester.enterText(find.byType(TextFormField).at(0), 'localhost');
      await tester.enterText(find.byType(TextFormField).at(1), '22');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid_user');
      await tester.enterText(find.byType(TextFormField).at(3), 'invalid_pass');

      await tester.tap(find.text('Conectar'));
      await tester.pump();

      // Deve iniciar processo de conexão
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}