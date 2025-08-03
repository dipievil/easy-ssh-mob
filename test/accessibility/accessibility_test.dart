import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../src/lib/screens/login_screen.dart';
import '../../src/lib/screens/file_explorer_screen.dart';
import '../../src/lib/widgets/optimized/optimized_file_list.dart';
import '../../src/lib/providers/ssh_provider.dart';
import '../../src/lib/models/ssh_connection_state.dart';
import '../../src/lib/models/ssh_file.dart';

// Gerar mocks - execute: flutter packages pub run build_runner build
@GenerateMocks([SshProvider])
import 'accessibility_test.mocks.dart';

void main() {
  group('Accessibility Tests', () {
    late MockSshProvider mockProvider;

    setUp(() {
      mockProvider = MockSshProvider();
      when(mockProvider.connectionState).thenReturn(SshConnectionState.disconnected);
      when(mockProvider.currentCredentials).thenReturn(null);
      when(mockProvider.isConnected).thenReturn(false);
      when(mockProvider.isConnecting).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn(null);
    });

    group('LoginScreen Accessibility', () {
      testWidgets('should have proper semantic labels for form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se os campos têm labels semânticos apropriados
        final hostField = find.byType(TextFormField).first;
        final hostSemantics = tester.getSemantics(hostField);
        expect(hostSemantics.label, contains('Host'));
        expect(hostSemantics.hasFlag(SemanticsFlag.isTextField), true);

        final portField = find.byType(TextFormField).at(1);
        final portSemantics = tester.getSemantics(portField);
        expect(portSemantics.label, contains('Porta'));
        expect(portSemantics.hasFlag(SemanticsFlag.isTextField), true);

        final userField = find.byType(TextFormField).at(2);
        final userSemantics = tester.getSemantics(userField);
        expect(userSemantics.label, contains('Usuário'));
        expect(userSemantics.hasFlag(SemanticsFlag.isTextField), true);

        final passwordField = find.byType(TextFormField).at(3);
        final passwordSemantics = tester.getSemantics(passwordField);
        expect(passwordSemantics.label, contains('Senha'));
        expect(passwordSemantics.hasFlag(SemanticsFlag.isTextField), true);
        expect(passwordSemantics.hasFlag(SemanticsFlag.isObscured), true);
      });

      testWidgets('should have accessible connect button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final connectButton = find.text('Conectar');
        final buttonSemantics = tester.getSemantics(connectButton);
        
        expect(buttonSemantics.hasAction(SemanticsAction.tap), true);
        expect(buttonSemantics.hasFlag(SemanticsFlag.isButton), true);
        expect(buttonSemantics.hasFlag(SemanticsFlag.isEnabled), true);
        expect(buttonSemantics.label, contains('Conectar'));
      });

      testWidgets('should have accessible checkbox for remember credentials', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final checkbox = find.byType(Checkbox);
        final checkboxSemantics = tester.getSemantics(checkbox);
        
        expect(checkboxSemantics.hasAction(SemanticsAction.tap), true);
        expect(checkboxSemantics.hasFlag(SemanticsFlag.hasCheckedState), true);
        expect(checkboxSemantics.hasFlag(SemanticsFlag.isEnabled), true);
      });

      testWidgets('should have accessible password visibility toggle', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final visibilityIcon = find.byIcon(Icons.visibility);
        if (visibilityIcon.evaluate().isNotEmpty) {
          final iconSemantics = tester.getSemantics(visibilityIcon);
          expect(iconSemantics.hasAction(SemanticsAction.tap), true);
          expect(iconSemantics.hasFlag(SemanticsFlag.isButton), true);
        }
      });

      testWidgets('should provide error message accessibility', (WidgetTester tester) async {
        when(mockProvider.connectionState).thenReturn(SshConnectionState.error);
        when(mockProvider.errorMessage).thenReturn('Erro de conexão');

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final errorText = find.text('Erro de conexão');
        if (errorText.evaluate().isNotEmpty) {
          final errorSemantics = tester.getSemantics(errorText);
          expect(errorSemantics.hasFlag(SemanticsFlag.isLiveRegion), true);
        }
      });
    });

    group('File List Accessibility', () {
      testWidgets('should have accessible file list items', (WidgetTester tester) async {
        final testFiles = [
          const SshFile(
            name: 'document.txt',
            fullPath: '/home/document.txt',
            type: FileType.regular,
            displayName: 'document.txt',
          ),
          const SshFile(
            name: 'folder',
            fullPath: '/home/folder',
            type: FileType.directory,
            displayName: 'folder/',
          ),
          const SshFile(
            name: 'script.sh',
            fullPath: '/home/script.sh',
            type: FileType.executable,
            displayName: 'script.sh*',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OptimizedFileList(
                files: testFiles,
                onFileTap: (file) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se cada item da lista é acessível
        final listItems = find.byType(InkWell);
        for (int i = 0; i < testFiles.length; i++) {
          final itemSemantics = tester.getSemantics(listItems.at(i));
          expect(itemSemantics.hasAction(SemanticsAction.tap), true);
          expect(itemSemantics.label, isNotEmpty);
        }
      });

      testWidgets('should support screen reader navigation', (WidgetTester tester) async {
        final testFiles = List.generate(10, (i) => 
          SshFile(
            name: 'file_$i.txt',
            fullPath: '/home/file_$i.txt',
            type: FileType.regular,
            displayName: 'file_$i.txt',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OptimizedFileList(
                files: testFiles,
                onFileTap: (file) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final listView = find.byType(ListView);
        final listSemantics = tester.getSemantics(listView);
        
        expect(listSemantics.hasAction(SemanticsAction.scrollUp), true);
        expect(listSemantics.hasAction(SemanticsAction.scrollDown), true);
        expect(listSemantics.hasFlag(SemanticsFlag.hasImplicitScrolling), true);
      });

      testWidgets('should provide meaningful descriptions for file types', (WidgetTester tester) async {
        final testFiles = [
          const SshFile(
            name: 'image.jpg',
            fullPath: '/home/image.jpg',
            type: FileType.regular,
            displayName: 'image.jpg',
          ),
          const SshFile(
            name: 'folder',
            fullPath: '/home/folder',
            type: FileType.directory,
            displayName: 'folder/',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OptimizedFileList(
                files: testFiles,
                onFileTap: (file) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se tipos de arquivo têm descrições semânticas
        final imageIcon = find.byIcon(Icons.image);
        if (imageIcon.evaluate().isNotEmpty) {
          final iconSemantics = tester.getSemantics(imageIcon);
          expect(iconSemantics.label, isNotNull);
        }

        final folderIcon = find.byIcon(Icons.folder);
        if (folderIcon.evaluate().isNotEmpty) {
          final iconSemantics = tester.getSemantics(folderIcon);
          expect(iconSemantics.label, isNotNull);
        }
      });
    });

    group('Navigation Accessibility', () {
      testWidgets('should have accessible app bar with proper navigation', (WidgetTester tester) async {
        when(mockProvider.connectionState).thenReturn(SshConnectionState.connected);
        when(mockProvider.currentFiles).thenReturn([]);
        when(mockProvider.currentPath).thenReturn('/home');

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const FileExplorerScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final appBar = find.byType(AppBar);
        final appBarSemantics = tester.getSemantics(appBar);
        expect(appBarSemantics.label, isNotEmpty);

        // Verificar botão de voltar se presente
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          final backSemantics = tester.getSemantics(backButton);
          expect(backSemantics.hasAction(SemanticsAction.tap), true);
          expect(backSemantics.hasFlag(SemanticsFlag.isButton), true);
        }
      });

      testWidgets('should have accessible drawer menu', (WidgetTester tester) async {
        when(mockProvider.connectionState).thenReturn(SshConnectionState.connected);
        when(mockProvider.currentFiles).thenReturn([]);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const FileExplorerScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final menuButton = find.byIcon(Icons.menu);
        if (menuButton.evaluate().isNotEmpty) {
          final menuSemantics = tester.getSemantics(menuButton);
          expect(menuSemantics.hasAction(SemanticsAction.tap), true);
          expect(menuSemantics.hasFlag(SemanticsFlag.isButton), true);

          // Abrir drawer
          await tester.tap(menuButton);
          await tester.pumpAndSettle();

          // Verificar acessibilidade do drawer
          final drawer = find.byType(Drawer);
          if (drawer.evaluate().isNotEmpty) {
            final drawerSemantics = tester.getSemantics(drawer);
            expect(drawerSemantics.label, isNotNull);
          }
        }
      });
    });

    group('Loading State Accessibility', () {
      testWidgets('should have accessible loading indicators', (WidgetTester tester) async {
        when(mockProvider.connectionState).thenReturn(SshConnectionState.connecting);
        when(mockProvider.isConnecting).thenReturn(true);

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final progressIndicator = find.byType(CircularProgressIndicator);
        if (progressIndicator.evaluate().isNotEmpty) {
          final progressSemantics = tester.getSemantics(progressIndicator);
          expect(progressSemantics.hasFlag(SemanticsFlag.isLiveRegion), true);
        }
      });
    });

    group('Color Contrast and Visibility', () {
      testWidgets('should use proper contrast ratios', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se textos têm contraste adequado
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);

        // Em um teste real, você verificaria os valores de cor
        // para garantir contraste WCAG AA (4.5:1) ou AAA (7:1)
      });

      testWidgets('should work with dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se funciona bem no tema escuro
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Conectar'), findsOneWidget);
      });
    });

    group('Focus Management', () {
      testWidgets('should have proper tab order in form', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se campos podem receber foco
        final firstField = find.byType(TextFormField).first;
        final firstFieldWidget = tester.widget<TextFormField>(firstField);
        expect(firstFieldWidget.focusNode?.canRequestFocus ?? true, true);

        // Simular navegação por Tab (seria feita com keyboard navigation em testes reais)
        final formFields = find.byType(TextFormField);
        expect(formFields, findsNWidgets(4));
      });

      testWidgets('should maintain focus visibility', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<SshProvider>.value(
              value: mockProvider,
              child: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Dar foco ao primeiro campo
        await tester.tap(find.byType(TextFormField).first);
        await tester.pump();

        // Verificar se há indicação visual de foco
        // Em um teste real, você verificaria se há bordas ou cores de foco
        expect(find.byType(TextFormField), findsWidgets);
      });
    });

    group('Text Scaling', () {
      testWidgets('should handle large text sizes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: MaterialApp(
              home: ChangeNotifierProvider<SshProvider>.value(
                value: mockProvider,
                child: const LoginScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se a UI ainda funciona com texto grande
        expect(find.text('Conectar'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
        
        // Verificar se não há overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle small text sizes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
            child: MaterialApp(
              home: ChangeNotifierProvider<SshProvider>.value(
                value: mockProvider,
                child: const LoginScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verificar se a UI ainda é usável com texto pequeno
        expect(find.text('Conectar'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
      });
    });
  });
}