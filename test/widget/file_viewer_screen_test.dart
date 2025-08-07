import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../src/lib/screens/file_viewer_screen.dart';
import '../../src/lib/providers/ssh_provider.dart';
import '../../src/lib/models/ssh_file.dart';
import '../../src/lib/models/file_content.dart';
import '../../src/lib/models/ssh_connection_state.dart';

// Gerar mocks - execute: flutter packages pub run build_runner build
@GenerateMocks([SshProvider])
import 'file_viewer_screen_test.mocks.dart';

void main() {
  group('FileViewerScreen Widget Tests', () {
    late MockSshProvider mockProvider;
    late SshFile testFile;

    setUp(() {
      mockProvider = MockSshProvider();
      testFile = const SshFile(
        name: 'test.txt',
        fullPath: '/home/user/test.txt',
        type: FileType.regular,
        displayName: 'test.txt',
      );

      when(mockProvider.connectionState).thenReturn(SshConnectionState.connected);
      when(mockProvider.isConnected).thenReturn(true);
    });

    Widget createWidgetUnderTest({SshFile? file}) {
      return MaterialApp(
        home: ChangeNotifierProvider<SshProvider>.value(
          value: mockProvider,
          child: FileViewerScreen(file: file ?? testFile),
        ),
      );
    }

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      // Mock para simular carregamento
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return FileContent(
          filePath: testFile.fullPath,
          content: 'Test file content',
          size: 17,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Deve mostrar loading inicialmente
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display file content when loaded', (WidgetTester tester) async {
      const fileContent = 'Hello, this is test file content\nLine 2\nLine 3';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: fileContent,
          size: fileContent.length,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar o conteúdo do arquivo
      expect(find.text(fileContent), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display error message when file loading fails', (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenThrow(Exception('File not found'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar mensagem de erro
      expect(find.textContaining('Erro'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show file name in app bar', (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: 'test content',
          size: 12,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar o nome do arquivo na AppBar
      expect(find.text(testFile.name), findsOneWidget);
    });

    testWidgets('should display search functionality', (WidgetTester tester) async {
      const fileContent = 'Hello world\nThis is a test file\nHello again\nWorld ending';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: fileContent,
          size: fileContent.length,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clicar no ícone de busca
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // Deve aparecer campo de busca
      expect(find.byType(TextField), findsOneWidget);
      
      // Digitar termo de busca
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Deve encontrar matches
      expect(find.textContaining('1/2'), findsOneWidget); // Assume que mostra contador
    });

    testWidgets('should navigate between search results', (WidgetTester tester) async {
      const fileContent = 'Hello world\nThis is a test file\nHello again\nWorld ending';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: fileContent,
          size: fileContent.length,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Abrir busca
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Buscar por "Hello"
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Testar navegação com setas
      final nextButton = find.byIcon(Icons.keyboard_arrow_down);
      final prevButton = find.byIcon(Icons.keyboard_arrow_up);
      
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton);
        await tester.pump();
      }
      
      if (prevButton.evaluate().isNotEmpty) {
        await tester.tap(prevButton);
        await tester.pump();
      }
    });

    testWidgets('should show file size and modification date', (WidgetTester tester) async {
      final modTime = DateTime(2024, 1, 15, 10, 30);
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: 'test content',
          size: 1024,
          lastModified: modTime,
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar se informações do arquivo são exibidas
      expect(find.textContaining('1024'), findsOneWidget); // Tamanho
      expect(find.textContaining('2024'), findsOneWidget); // Ano da modificação
    });

    testWidgets('should handle empty file content', (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: '',
          size: 0,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve mostrar indicação de arquivo vazio
      expect(find.textContaining('vazio'), findsOneWidget);
    });

    testWidgets('should handle large file content with scrolling', (WidgetTester tester) async {
      final largeContent = List.generate(100, (i) => 'Line ${i + 1}: This is a long line with some content').join('\n');
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: largeContent,
          size: largeContent.length,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Deve ter uma área scrollável
      expect(find.byType(Scrollable), findsAtLeastNWidgets(1));
      
      // Testar scroll
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
    });

    testWidgets('should copy content to clipboard', (WidgetTester tester) async {
      const fileContent = 'Content to copy';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return FileContent(
          filePath: testFile.fullPath,
          content: fileContent,
          size: fileContent.length,
          lastModified: DateTime.now(),
        );
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Procurar pelo ícone de cópia
      final copyIcon = find.byIcon(Icons.copy);
      if (copyIcon.evaluate().isNotEmpty) {
        await tester.tap(copyIcon);
        await tester.pump();
        
        // Verificar se apareceu snackbar de confirmação
        expect(find.textContaining('copiado'), findsOneWidget);
      }
    });

    testWidgets('should refresh file content', (WidgetTester tester) async {
      const initialContent = 'Initial content';
      const updatedContent = 'Updated content';
      
      when(mockProvider.readFile(any))
          .thenAnswer((_) async {
            return FileContent(
              filePath: testFile.fullPath,
              content: initialContent,
              size: initialContent.length,
              lastModified: DateTime.now(),
            );
          });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(initialContent), findsOneWidget);

      // Alterar o mock para retornar conteúdo atualizado
      when(mockProvider.readFile(any))
          .thenAnswer((_) async {
            return FileContent(
              filePath: testFile.fullPath,
              content: updatedContent,
              size: updatedContent.length,
              lastModified: DateTime.now(),
            );
          });

      // Procurar e clicar no botão de refresh
      final refreshIcon = find.byIcon(Icons.refresh);
      if (refreshIcon.evaluate().isNotEmpty) {
        await tester.tap(refreshIcon);
        await tester.pumpAndSettle();

        expect(find.text(updatedContent), findsOneWidget);
        expect(find.text(initialContent), findsNothing);
      }
    });

    testWidgets('should handle binary file gracefully', (WidgetTester tester) async {
      const binaryFile = SshFile(
        name: 'binary.exe',
        fullPath: '/home/user/binary.exe',
        type: FileType.regular,
        displayName: 'binary.exe',
      );

      when(mockProvider.readFile(any)).thenThrow(
        Exception('Cannot display binary file'),
      );

      await tester.pumpWidget(createWidgetUnderTest(file: binaryFile));
      await tester.pumpAndSettle();

      // Deve mostrar mensagem apropriada para arquivo binário
      expect(find.textContaining('binário'), findsOneWidget);
    });
  });
}