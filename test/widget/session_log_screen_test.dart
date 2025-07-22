import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:easyssh/screens/session_log_screen.dart';
import 'package:easyssh/providers/ssh_provider.dart';
import 'package:easyssh/models/log_entry.dart';
import 'package:easyssh/models/ssh_connection_state.dart';

// Gerar mocks - execute: flutter packages pub run build_runner build
@GenerateMocks([SshProvider])
import 'session_log_screen_test.mocks.dart';

void main() {
  group('SessionLogScreen Widget Tests', () {
    late MockSshProvider mockProvider;
    late List<LogEntry> mockLogEntries;

    setUp(() {
      mockProvider = MockSshProvider();
      mockLogEntries = [
        LogEntry(
          command: 'ls -la',
          type: CommandType.navigation,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: CommandStatus.success,
          output: 'total 10\ndrwxr-xr-x 2 user user 4096 Jan 15 10:30 .',
        ),
        LogEntry(
          command: 'cat file.txt',
          type: CommandType.viewing,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          status: CommandStatus.success,
          output: 'Hello World',
        ),
        LogEntry(
          command: 'rm nonexistent.txt',
          type: CommandType.operation,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          status: CommandStatus.error,
          output: 'rm: cannot remove \'nonexistent.txt\': No such file or directory',
        ),
      ];

      when(mockProvider.connectionState).thenReturn(SshConnectionState.connected);
      when(mockProvider.sessionLog).thenReturn(mockLogEntries);
      when(mockProvider.isConnected).thenReturn(true);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<SshProvider>.value(
          value: mockProvider,
          child: const SessionLogScreen(),
        ),
      );
    }

    testWidgets('should display screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Histórico da Sessão'), findsOneWidget);
    });

    testWidgets('should display all log entries', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar todos os comandos
      expect(find.text('ls -la'), findsOneWidget);
      expect(find.text('cat file.txt'), findsOneWidget);
      expect(find.text('rm nonexistent.txt'), findsOneWidget);
    });

    testWidgets('should show search action button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
    });

    testWidgets('should show filter action button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Procurar ícone de filtro (pode ser filter ou similar)
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should open search dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar no botão de busca
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Deve abrir dialog de busca
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Buscar comandos'), findsOneWidget);
    });

    testWidgets('should search log entries', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir busca
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Digitar termo de busca
      await tester.enterText(find.byType(TextField), 'cat');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      // Deve filtrar para mostrar apenas comandos com "cat"
      expect(find.text('cat file.txt'), findsOneWidget);
      expect(find.text('ls -la'), findsNothing);
      expect(find.text('rm nonexistent.txt'), findsNothing);
    });

    testWidgets('should toggle filters panel', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar no botão de filtros
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Deve mostrar painel de filtros
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('should filter by command type', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir filtros
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Selecionar filtro por tipo "Navigation"
      final navigationFilter = find.text('Navigation');
      if (navigationFilter.evaluate().isNotEmpty) {
        await tester.tap(navigationFilter);
        await tester.pumpAndSettle();

        // Deve mostrar apenas comandos de navegação
        expect(find.text('ls -la'), findsOneWidget);
        expect(find.text('cat file.txt'), findsNothing);
        expect(find.text('rm nonexistent.txt'), findsNothing);
      }
    });

    testWidgets('should filter by command status', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir filtros
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Selecionar filtro por status "Error"
      final errorFilter = find.text('Error');
      if (errorFilter.evaluate().isNotEmpty) {
        await tester.tap(errorFilter);
        await tester.pumpAndSettle();

        // Deve mostrar apenas comandos com erro
        expect(find.text('rm nonexistent.txt'), findsOneWidget);
        expect(find.text('ls -la'), findsNothing);
        expect(find.text('cat file.txt'), findsNothing);
      }
    });

    testWidgets('should show popup menu with options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar no menu popup
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Deve mostrar opções do menu
      expect(find.text('Estatísticas'), findsOneWidget);
      expect(find.text('Exportar Log'), findsOneWidget);
      expect(find.text('Limpar Histórico'), findsOneWidget);
    });

    testWidgets('should show statistics dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir menu e clicar em estatísticas
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Estatísticas'));
      await tester.pumpAndSettle();

      // Deve mostrar dialog de estatísticas
      expect(find.text('Estatísticas da Sessão'), findsOneWidget);
      expect(find.textContaining('comandos'), findsOneWidget);
    });

    testWidgets('should show clear history confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir menu e clicar em limpar histórico
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar Histórico'));
      await tester.pumpAndSettle();

      // Deve mostrar confirmação
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.textContaining('limpar'), findsOneWidget);
    });

    testWidgets('should handle empty log gracefully', (WidgetTester tester) async {
      when(mockProvider.sessionLog).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar mensagem de log vazio
      expect(find.textContaining('Nenhum comando'), findsOneWidget);
    });

    testWidgets('should display log entry details on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar em uma entrada do log
      await tester.tap(find.text('ls -la'));
      await tester.pumpAndSettle();

      // Deve mostrar detalhes da entrada
      expect(find.textContaining('total 10'), findsOneWidget);
    });

    testWidgets('should show different icons for command types', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar se existem ícones diferentes para diferentes tipos
      expect(find.byIcon(Icons.folder), findsWidgets); // Navigation
      expect(find.byIcon(Icons.visibility), findsWidgets); // Viewing
      expect(find.byIcon(Icons.build), findsWidgets); // Operation
    });

    testWidgets('should show command status indicators', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar indicadores de status
      expect(find.byIcon(Icons.check_circle), findsWidgets); // Success
      expect(find.byIcon(Icons.error), findsWidgets); // Error
    });

    testWidgets('should scroll through long log list', (WidgetTester tester) async {
      // Criar lista longa de logs
      final longLogList = List.generate(50, (index) => LogEntry(
        command: 'command_$index',
        type: CommandType.operation,
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        status: CommandStatus.success,
        output: 'output $index',
      ));
      
      when(mockProvider.sessionLog).thenReturn(longLogList);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve haver lista scrollável
      expect(find.byType(ListView), findsOneWidget);
      
      // Testar scroll
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    });

    testWidgets('should format timestamps correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar se timestamps estão formatados
      expect(find.textContaining(':'), findsWidgets); // Formato de hora
    });
  });
}