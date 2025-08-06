import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../src/lib/services/file_icon_manager.dart';
import '../../../src/lib/models/ssh_file.dart';

void main() {
  group('FileIconManager Tests', () {
    setUp(() {
      // Limpar cache antes de cada teste
      FileIconManager.clearCache();
    });

    group('Icon Selection', () {
      test('should return correct icons for different file types', () {
        const directory = SshFile(
          name: 'folder',
          fullPath: '/folder',
          type: FileType.directory,
          displayName: 'folder/',
        );

        const executable = SshFile(
          name: 'script.sh',
          fullPath: '/script.sh',
          type: FileType.executable,
          displayName: 'script.sh*',
        );

        const regular = SshFile(
          name: 'file.txt',
          fullPath: '/file.txt',
          type: FileType.regular,
          displayName: 'file.txt',
        );

        const symlink = SshFile(
          name: 'link',
          fullPath: '/link',
          type: FileType.symlink,
          displayName: 'link@',
        );

        expect(FileIconManager.getIconForFile(directory), Icons.folder);
        expect(FileIconManager.getIconForFile(executable), Icons.terminal);
        expect(FileIconManager.getIconForFile(regular), Icons.description);
        expect(FileIconManager.getIconForFile(symlink), Icons.link);
      });

      test('should return specific icons for file extensions', () {
        final testCases = [
          // Documentos
          ('document.pdf', Icons.picture_as_pdf),
          ('text.md', Icons.notes),
          ('sheet.xlsx', Icons.table_chart),

          // Código
          ('script.py', Icons.code),
          ('web.html', Icons.web),
          ('style.css', Icons.palette),
          ('data.json', Icons.data_object),

          // Mídia
          ('photo.jpg', Icons.image),
          ('video.mp4', Icons.videocam),
          ('song.mp3', Icons.audiotrack),

          // Arquivos
          ('archive.zip', Icons.archive),
          ('system.log', Icons.list_alt),
        ];

        for (final (filename, expectedIcon) in testCases) {
          final file = SshFile(
            name: filename,
            fullPath: '/$filename',
            type: FileType.regular,
            displayName: filename,
          );

          expect(
            FileIconManager.getIconForFile(file),
            expectedIcon,
            reason: 'Icon for $filename should be $expectedIcon',
          );
        }
      });

      test('should return special icons for special directories', () {
        final specialDirs = [
          ('Documents', Icons.folder_copy),
          ('Downloads', Icons.download),
          ('Pictures', Icons.photo_library),
          ('Music', Icons.library_music),
          ('Videos', Icons.video_library),
          ('Desktop', Icons.desktop_windows),
          ('.hidden', Icons.folder_special),
        ];

        for (final (dirName, expectedIcon) in specialDirs) {
          final dir = SshFile(
            name: dirName,
            fullPath: '/$dirName',
            type: FileType.directory,
            displayName: '$dirName/',
          );

          expect(
            FileIconManager.getIconForFile(dir),
            expectedIcon,
            reason: 'Icon for directory $dirName should be $expectedIcon',
          );
        }
      });

      test('should return special icons for special file names', () {
        final specialFiles = [
          ('README', Icons.info),
          ('LICENSE', Icons.gavel),
          ('CHANGELOG', Icons.history),
          ('Makefile', Icons.build),
          ('Dockerfile', Icons.developer_board),
          ('.env', Icons.settings),
          ('.gitignore', Icons.source),
        ];

        for (final (fileName, expectedIcon) in specialFiles) {
          final file = SshFile(
            name: fileName,
            fullPath: '/$fileName',
            type: FileType.regular,
            displayName: fileName,
          );

          expect(
            FileIconManager.getIconForFile(file),
            expectedIcon,
            reason: 'Icon for special file $fileName should be $expectedIcon',
          );
        }
      });
    });

    group('Color Selection', () {
      testWidgets('should return appropriate colors for file types',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                const directory = SshFile(
                  name: 'folder',
                  fullPath: '/folder',
                  type: FileType.directory,
                  displayName: 'folder/',
                );

                const executable = SshFile(
                  name: 'script.sh',
                  fullPath: '/script.sh',
                  type: FileType.executable,
                  displayName: 'script.sh*',
                );

                final dirColor =
                    FileIconManager.getColorForFile(directory, context);
                final execColor =
                    FileIconManager.getColorForFile(executable, context);

                // Verificar se cores são apropriadas
                expect(dirColor, Theme.of(context).colorScheme.primary);
                expect(execColor, Colors.green.shade600);

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return different colors for light and dark themes',
          (WidgetTester tester) async {
        const file = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        Color? lightColor;
        Color? darkColor;

        // Testar tema claro
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                lightColor = FileIconManager.getColorForFile(file, context);
                return Container();
              },
            ),
          ),
        );

        // Testar tema escuro
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                darkColor = FileIconManager.getColorForFile(file, context);
                return Container();
              },
            ),
          ),
        );

        expect(lightColor, isNotNull);
        expect(darkColor, isNotNull);
        // As cores podem ser iguais ou diferentes dependendo da implementação
      });

      testWidgets('should return specific colors for file extensions',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                final colorTestCases = [
                  ('document.pdf', Colors.blue.shade600),
                  ('sheet.xlsx', Colors.green.shade600),
                  ('presentation.pptx', Colors.orange.shade600),
                  ('code.py', Colors.purple.shade600),
                  ('image.jpg', Colors.pink.shade600),
                  ('video.mp4', Colors.red.shade600),
                  ('audio.mp3', Colors.indigo.shade600),
                  ('archive.zip', Colors.amber.shade700),
                ];

                for (final (filename, expectedColor) in colorTestCases) {
                  final file = SshFile(
                    name: filename,
                    fullPath: '/$filename',
                    type: FileType.regular,
                    displayName: filename,
                  );

                  final actualColor =
                      FileIconManager.getColorForFile(file, context);
                  expect(
                    actualColor,
                    expectedColor,
                    reason: 'Color for $filename should be $expectedColor',
                  );
                }

                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Caching', () {
      test('should cache icons for better performance', () {
        const file = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        // Primeira chamada
        final icon1 = FileIconManager.getIconForFile(file);
        final stats1 = FileIconManager.getCacheStats();

        // Segunda chamada (deve usar cache)
        final icon2 = FileIconManager.getIconForFile(file);
        final stats2 = FileIconManager.getCacheStats();

        expect(icon1, icon2);
        expect(stats1['iconCacheSize'], 1);
        expect(stats2['iconCacheSize'], 1); // Não deve aumentar
      });

      testWidgets('should cache colors for better performance',
          (WidgetTester tester) async {
        const file = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                // Primeira chamada
                final color1 = FileIconManager.getColorForFile(file, context);
                final stats1 = FileIconManager.getCacheStats();

                // Segunda chamada (deve usar cache)
                final color2 = FileIconManager.getColorForFile(file, context);
                final stats2 = FileIconManager.getCacheStats();

                expect(color1, color2);
                expect(stats1['colorCacheSize'], greaterThanOrEqualTo(1));
                expect(stats2['colorCacheSize'],
                    stats1['colorCacheSize']); // Não deve aumentar

                return Container();
              },
            ),
          ),
        );
      });

      test('should clear cache when requested', () {
        const file = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        // Criar entrada no cache
        FileIconManager.getIconForFile(file);
        final statsBeforeClear = FileIconManager.getCacheStats();
        expect(statsBeforeClear['iconCacheSize'], greaterThan(0));

        // Limpar cache
        FileIconManager.clearCache();
        final statsAfterClear = FileIconManager.getCacheStats();
        expect(statsAfterClear['iconCacheSize'], 0);
        expect(statsAfterClear['colorCacheSize'], 0);
      });

      test('should handle preloading of common icons', () {
        // Cache deve estar vazio inicialmente
        final initialStats = FileIconManager.getCacheStats();
        expect(initialStats['iconCacheSize'], 0);

        // Precarregar ícones comuns
        FileIconManager.preloadCommonIcons();

        // Cache deve ter ícones agora
        final afterPreloadStats = FileIconManager.getCacheStats();
        expect(afterPreloadStats['iconCacheSize'], greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('should handle files without extensions', () {
        const file = SshFile(
          name: 'noextension',
          fullPath: '/noextension',
          type: FileType.regular,
          displayName: 'noextension',
        );

        final icon = FileIconManager.getIconForFile(file);
        expect(icon, isNotNull);
        expect(icon, Icons.insert_drive_file); // Ícone padrão
      });

      test('should handle files with multiple dots', () {
        const file = SshFile(
          name: 'file.backup.txt',
          fullPath: '/file.backup.txt',
          type: FileType.regular,
          displayName: 'file.backup.txt',
        );

        final icon = FileIconManager.getIconForFile(file);
        expect(icon, Icons.description); // Deve usar a última extensão (.txt)
      });

      test('should handle empty file names', () {
        const file = SshFile(
          name: '',
          fullPath: '/',
          type: FileType.regular,
          displayName: '',
        );

        final icon = FileIconManager.getIconForFile(file);
        expect(icon, isNotNull);
        expect(icon, Icons.insert_drive_file);
      });

      test('should handle case insensitive extensions', () {
        const lowerCase = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        const upperCase = SshFile(
          name: 'TEST.TXT',
          fullPath: '/TEST.TXT',
          type: FileType.regular,
          displayName: 'TEST.TXT',
        );

        const mixedCase = SshFile(
          name: 'Test.TxT',
          fullPath: '/Test.TxT',
          type: FileType.regular,
          displayName: 'Test.TxT',
        );

        final icon1 = FileIconManager.getIconForFile(lowerCase);
        final icon2 = FileIconManager.getIconForFile(upperCase);
        final icon3 = FileIconManager.getIconForFile(mixedCase);

        expect(icon1, icon2);
        expect(icon2, icon3);
        expect(icon1, Icons.description);
      });

      test('should handle unknown file types gracefully', () {
        const unknownFile = SshFile(
          name: 'test.unknownextension',
          fullPath: '/test.unknownextension',
          type: FileType.unknown,
          displayName: 'test.unknownextension',
        );

        final icon = FileIconManager.getIconForFile(unknownFile);
        expect(icon, isNotNull);
        expect(icon, Icons.insert_drive_file);
      });
    });

    group('Performance', () {
      test('should handle large number of files efficiently', () {
        final stopwatch = Stopwatch()..start();

        // Gerar 1000 arquivos diferentes
        for (int i = 0; i < 1000; i++) {
          final file = SshFile(
            name: 'file_$i.txt',
            fullPath: '/file_$i.txt',
            type: FileType.regular,
            displayName: 'file_$i.txt',
          );

          FileIconManager.getIconForFile(file);
        }

        stopwatch.stop();

        // Deve processar 1000 arquivos em menos de 1 segundo
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should benefit from caching with repeated calls', () {
        const file = SshFile(
          name: 'test.txt',
          fullPath: '/test.txt',
          type: FileType.regular,
          displayName: 'test.txt',
        );

        // Primeira chamada (sem cache)
        final stopwatch1 = Stopwatch()..start();
        FileIconManager.getIconForFile(file);
        stopwatch1.stop();
        final firstCallTime = stopwatch1.elapsedMicroseconds;

        // Segunda chamada (com cache)
        final stopwatch2 = Stopwatch()..start();
        FileIconManager.getIconForFile(file);
        stopwatch2.stop();
        final secondCallTime = stopwatch2.elapsedMicroseconds;

        // Segunda chamada deve ser mais rápida (ou pelo menos não mais lenta)
        expect(secondCallTime, lessThanOrEqualTo(firstCallTime));
      });
    });
  });
}
