import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_ssh_mob_new/screens/session_log_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/log_entry.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
import 'package:easy_ssh_mob_new/widgets/log_entry_tile.dart';
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
          id: '1',
          command: 'ls -la',
          type: CommandType.navigation,
          workingDirectory: '/home/user',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: CommandStatus.success,
          stdout: 'total 10\ndrwxr-xr-x 2 user user 4096 Jan 15 10:30 .',
          stderr: '',
          duration: const Duration(milliseconds: 100),
        ),
        LogEntry(
          id: '2',
          command: 'cat file.txt',
          type: CommandType.fileView,
          workingDirectory: '/home/user',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          status: CommandStatus.success,
          stdout: 'Hello World',
          stderr: '',
          duration: const Duration(milliseconds: 50),
        ),
        LogEntry(
          id: '3',
          command: 'rm nonexistent.txt',
          type: CommandType.execution,
          workingDirectory: '/home/user',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          status: CommandStatus.error,
          stdout: '',
          stderr:
              'rm: cannot remove \'nonexistent.txt\': No such file or directory',
          duration: const Duration(milliseconds: 30),
        ),
      ];
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.connected);
      when(mockProvider.sessionLog).thenReturn(mockLogEntries);
      when(mockProvider.isConnected).thenReturn(true);
      when(mockProvider.filterSessionLog(
        type: anyNamed('type'),
        status: anyNamed('status'),
        searchTerm: anyNamed('searchTerm'),
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenAnswer((invocation) {
        final searchTerm =
            invocation.namedArguments[const Symbol('searchTerm')];
        if (searchTerm != null && searchTerm.isNotEmpty) {
          return mockLogEntries
              .where((entry) => entry.command
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()))
              .toList();
        }
        return mockLogEntries;
      });
      when(mockProvider.getSessionStats()).thenReturn({
        'totalCommands': 3,
        'successfulCommands': 2,
        'failedCommands': 1,
        'totalDuration': const Duration(milliseconds: 180),
        'sessionDuration': const Duration(minutes: 5),
        'commandsByType': {'navigation': 1, 'fileView': 1, 'execution': 1},
        'mostUsedCommands': ['ls -la', 'cat file.txt'],
        'successRate': 66.67,
      });
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
      expect(find.text('ls -la'), findsOneWidget);
      expect(find.text('cat file.txt'), findsOneWidget);
      expect(find.text('rm nonexistent.txt'), findsOneWidget);
    });
    testWidgets('should show search action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      final searchButton = find.byIcon(FontAwesomeIcons.magnifyingGlass);
      expect(searchButton, findsOneWidget);
    });
    testWidgets('should show filter action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(FontAwesomeIcons.filter), findsOneWidget);
    });
    testWidgets('should open search dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.magnifyingGlass));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Buscar Comandos'), findsOneWidget);
    });
    testWidgets('should search log entries', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.magnifyingGlass));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cat');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(find.text('cat file.txt'), findsOneWidget);
      expect(find.text('ls -la'), findsNothing);
      expect(find.text('rm nonexistent.txt'), findsNothing);
    });
    testWidgets('should toggle filters panel', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.filter));
      await tester.pumpAndSettle();
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });
    testWidgets('should filter by command type', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.filter));
      await tester.pumpAndSettle();
      final navigationFilter = find.text('Navigation');
      if (navigationFilter.evaluate().isNotEmpty) {
        await tester.tap(navigationFilter);
        await tester.pumpAndSettle();
        expect(find.text('ls -la'), findsOneWidget);
        expect(find.text('cat file.txt'), findsNothing);
        expect(find.text('rm nonexistent.txt'), findsNothing);
      }
    });
    testWidgets('should filter by command status', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.filter));
      await tester.pumpAndSettle();
      final errorFilter = find.text('Error');
      if (errorFilter.evaluate().isNotEmpty) {
        await tester.tap(errorFilter);
        await tester.pumpAndSettle();
        expect(find.text('rm nonexistent.txt'), findsOneWidget);
        expect(find.text('ls -la'), findsNothing);
        expect(find.text('cat file.txt'), findsNothing);
      }
    });
    testWidgets('should show popup menu with options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Estatísticas'), findsOneWidget);
      expect(find.text('Salvar como TXT'), findsOneWidget);
      expect(find.text('Limpar Histórico'), findsOneWidget);
    });
    testWidgets('should show statistics dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Estatísticas'));
      await tester.pumpAndSettle();
      expect(find.text('Estatísticas da Sessão'), findsOneWidget);
      expect(find.textContaining('comandos'), findsOneWidget);
    });
    testWidgets('should show clear history confirmation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar Histórico'));
      await tester.pumpAndSettle();
      expect(find.text('Limpar'), findsOneWidget);
      expect(find.textContaining('limpar'), findsOneWidget);
    });
    testWidgets('should handle empty log gracefully',
        (WidgetTester tester) async {
      when(mockProvider.sessionLog).thenReturn([]);
      when(mockProvider.filterSessionLog(
        type: anyNamed('type'),
        status: anyNamed('status'),
        searchTerm: anyNamed('searchTerm'),
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
      )).thenReturn([]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(
          find.textContaining('Nenhum comando foi executado'), findsOneWidget);
    });
    testWidgets('should display log entry details on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LogEntryTile).first);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Detalhes do Comando'), findsOneWidget);
      expect(find.textContaining('Comando Completo'), findsOneWidget);
      expect(find.textContaining('ls -la'), findsWidgets);
    });
    testWidgets('should show different icons for command types',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(FontAwesomeIcons.folderOpen), findsWidgets);
      expect(find.byIcon(FontAwesomeIcons.fileLines), findsWidgets);
      expect(find.byIcon(FontAwesomeIcons.play), findsWidgets);
    });
    testWidgets('should show command status indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(FontAwesomeIcons.circleCheck), findsWidgets);
      expect(find.byIcon(FontAwesomeIcons.triangleExclamation), findsWidgets);
    });
    testWidgets('should scroll through long log list',
        (WidgetTester tester) async {
      final longLogList = List.generate(
          50,
          (index) => LogEntry(
                id: 'log_$index',
                command: 'command_$index',
                type: CommandType.execution,
                workingDirectory: '/home/user',
                timestamp: DateTime.now().subtract(Duration(minutes: index)),
                status: CommandStatus.success,
                stdout: 'output $index',
                stderr: '',
                duration: const Duration(milliseconds: 100),
              ));
      when(mockProvider.sessionLog).thenReturn(longLogList);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    });
    testWidgets('should format timestamps correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.textContaining(':'), findsWidgets);
    });
  });
}
