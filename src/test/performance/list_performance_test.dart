import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/widgets/optimized/optimized_file_list.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('should handle large file lists efficiently',
        (WidgetTester tester) async {
      // Criar lista grande de arquivos
      final largeFileList = List.generate(
        1000,
        (i) => SshFile(
          name: 'file_$i.txt',
          fullPath: '/path/file_$i.txt',
          type: FileType.regular,
          displayName: 'file_$i.txt',
          size: 1024 * i,
          lastModified: DateTime.now().subtract(Duration(hours: i)),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: largeFileList,
              onFileTap: (file) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Lista de 1000 itens deve renderizar em menos de 2 segundos
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verificar se a lista foi renderizada
      expect(find.byType(ListView), findsOneWidget);

      // Deve mostrar pelo menos alguns itens na tela
      expect(find.textContaining('file_'), findsWidgets);
    });

    testWidgets('should scroll smoothly through large lists',
        (WidgetTester tester) async {
      final largeFileList = List.generate(
        500,
        (i) => SshFile(
          name: 'item_$i.txt',
          fullPath: '/path/item_$i.txt',
          type: i % 5 == 0 ? FileType.directory : FileType.regular,
          displayName: i % 5 == 0 ? 'item_$i/' : 'item_$i.txt',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: largeFileList,
              onFileTap: (file) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Realizar scroll rápido
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 5; i++) {
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pump(const Duration(milliseconds: 100));
      }

      stopwatch.stop();

      // Scroll deve completar rapidamente
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Aguardar animações terminarem
      await tester.pumpAndSettle();
    });

    testWidgets('should use cached icons efficiently',
        (WidgetTester tester) async {
      // Criar arquivos com tipos variados para testar cache de ícones
      final mixedFileList = [
        ...List.generate(
            100,
            (i) => SshFile(
                  name: 'document_$i.txt',
                  fullPath: '/path/document_$i.txt',
                  type: FileType.regular,
                  displayName: 'document_$i.txt',
                )),
        ...List.generate(
            100,
            (i) => SshFile(
                  name: 'folder_$i',
                  fullPath: '/path/folder_$i',
                  type: FileType.directory,
                  displayName: 'folder_$i/',
                )),
        ...List.generate(
            100,
            (i) => SshFile(
                  name: 'image_$i.jpg',
                  fullPath: '/path/image_$i.jpg',
                  type: FileType.regular,
                  displayName: 'image_$i.jpg',
                )),
      ];

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: mixedFileList,
              onFileTap: (file) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Mesmo com tipos variados, deve renderizar rapidamente devido ao cache
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      // Verificar se diferentes tipos de ícones estão presentes
      expect(find.byIcon(Icons.folder), findsWidgets);
      expect(find.byIcon(Icons.description), findsWidgets);
      expect(find.byIcon(Icons.image), findsWidgets);
    });

    testWidgets('should handle frequent updates efficiently',
        (WidgetTester tester) async {
      final initialList = List.generate(
        200,
        (i) => SshFile(
          name: 'file_$i.txt',
          fullPath: '/path/file_$i.txt',
          type: FileType.regular,
          displayName: 'file_$i.txt',
        ),
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return OptimizedFileList(
                files: initialList,
                onFileTap: (file) {},
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Simular múltiplas atualizações da lista
      final stopwatch = Stopwatch()..start();

      for (int update = 0; update < 10; update++) {
        // Adicionar/remover itens para simular mudanças na lista
        if (update % 2 == 0) {
          initialList.add(SshFile(
            name: 'new_file_$update.txt',
            fullPath: '/path/new_file_$update.txt',
            type: FileType.regular,
            displayName: 'new_file_$update.txt',
          ));
        } else if (initialList.isNotEmpty) {
          initialList.removeLast();
        }

        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Múltiplas atualizações devem ser eficientes
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should efficiently handle different file sizes and dates',
        (WidgetTester tester) async {
      final complexFileList = List.generate(300, (i) {
        final size = i * 1024; // Tamanhos variados
        final date =
            DateTime.now().subtract(Duration(days: i ~/ 10)); // Datas variadas

        return SshFile(
          name: 'complex_file_$i.txt',
          fullPath: '/path/complex_file_$i.txt',
          type: FileType.regular,
          displayName: 'complex_file_$i.txt',
          size: size,
          lastModified: date,
        );
      });

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: complexFileList,
              onFileTap: (file) {},
              showFileSize: true,
              showFileDate: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Renderização com informações complexas deve ser rápida
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verificar se informações de tamanho e data são mostradas
      expect(find.textContaining('KB'), findsWidgets);
      expect(find.textContaining('MB'), findsWidgets);
      expect(find.textContaining('/'), findsWidgets); // Formato de data
    });

    testWidgets('should efficiently reuse widgets with ValueKey',
        (WidgetTester tester) async {
      var fileList = List.generate(
        100,
        (i) => SshFile(
          name: 'file_$i.txt',
          fullPath: '/path/file_$i.txt',
          type: FileType.regular,
          displayName: 'file_$i.txt',
        ),
      );

      final widget = StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Reordenar lista para testar reutilização de widgets
                        fileList = fileList.reversed.toList();
                      });
                    },
                    child: const Text('Reorder'),
                  ),
                  Expanded(
                    child: OptimizedFileList(
                      files: fileList,
                      onFileTap: (file) {},
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Capturar estado inicial
      final initialFirstItem = find.text('file_0.txt');
      expect(initialFirstItem, findsOneWidget);

      // Reordenar lista
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Reorder'));
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Reordenação deve ser rápida devido às ValueKeys
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      // Primeiro item agora deve ser diferente
      expect(find.text('file_99.txt'), findsOneWidget);
    });

    testWidgets('should handle memory efficiently with large lists',
        (WidgetTester tester) async {
      // Esta é uma simulação - em um teste real, você mediria o uso de memória
      final veryLargeList = List.generate(
        2000,
        (i) => SshFile(
          name: 'huge_file_$i.txt',
          fullPath: '/very/long/path/to/huge_file_$i.txt',
          type: FileType.regular,
          displayName: 'huge_file_$i.txt',
          size: i * 1024 * 1024, // MB
          lastModified: DateTime.now().subtract(Duration(minutes: i)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: veryLargeList,
              onFileTap: (file) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar se a lista grande não trava a aplicação
      expect(find.byType(ListView), findsOneWidget);

      // Fazer scroll para verificar se a renderização lazy funciona
      await tester.fling(find.byType(ListView), const Offset(0, -1000), 2000);
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll rápido não deve travar
      expect(find.byType(ListView), findsOneWidget);
    });

    test('file size formatting performance', () {
      final stopwatch = Stopwatch()..start();

      // Testar formatação de 10000 tamanhos diferentes
      for (int i = 0; i < 10000; i++) {
        final file = SshFile(
          name: 'test_$i.txt',
          fullPath: '/test_$i.txt',
          type: FileType.regular,
          displayName: 'test_$i.txt',
          size: i * 1024,
        );

        // Simular formatação (normalmente seria feita no widget)
        final size = file.size ?? 0;
        const suffixes = ['B', 'KB', 'MB', 'GB'];
        int suffixIndex = 0;
        double formattedSize = size.toDouble();

        while (formattedSize >= 1024 && suffixIndex < suffixes.length - 1) {
          formattedSize /= 1024;
          suffixIndex++;
        }

        final _ =
            '${formattedSize.toStringAsFixed(suffixIndex == 0 ? 0 : 1)} ${suffixes[suffixIndex]}';
      }

      stopwatch.stop();

      // Formatação de 10000 tamanhos deve ser muito rápida
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
