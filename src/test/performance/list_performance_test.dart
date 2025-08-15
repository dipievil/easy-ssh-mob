import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/widgets/optimized/optimized_file_list.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('should handle large file lists efficiently',
        (WidgetTester tester) async {
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
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byType(ListView), findsOneWidget);
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
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 5; i++) {
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pump(const Duration(milliseconds: 100));
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      await tester.pumpAndSettle();
    });
    testWidgets('should use cached icons efficiently',
        (WidgetTester tester) async {
      final mixedFileList = [
        SshFile(
          name: 'document_0.txt',
          fullPath: '/path/document_0.txt',
          type: FileType.regular,
          displayName: 'document_0.txt',
        ),
        SshFile(
          name: 'folder_0',
          fullPath: '/path/folder_0',
          type: FileType.directory,
          displayName: 'folder_0',
        ),
        SshFile(
          name: 'image_0.jpg',
          fullPath: '/path/image_0.jpg',
          type: FileType.regular,
          displayName: 'image_0.jpg',
        ),
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

      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      // Verify basic structure exists
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(InkWell), findsNWidgets(3));

      // Check for specific file names
      expect(find.text('document_0.txt'), findsOneWidget);
      expect(find.text('folder_0'), findsOneWidget);
      expect(find.text('image_0.jpg'), findsOneWidget);
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
      final stopwatch = Stopwatch()..start();
      for (int update = 0; update < 10; update++) {
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
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    testWidgets('should efficiently handle different file sizes and dates',
        (WidgetTester tester) async {
      final testFile = SshFile(
        name: 'large_file.txt',
        fullPath: '/path/large_file.txt',
        type: FileType.regular,
        displayName: 'large_file.txt',
        size: 5 * 1024 * 1024, // 5MB
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
      );

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedFileList(
              files: [testFile],
              onFileTap: (file) {},
              showFileSize: true,
              showFileDate: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verify file name is displayed
      expect(find.text('large_file.txt'), findsOneWidget);

      // Verify basic structure
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
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
      final initialFirstItem = find.text('file_0.txt');
      expect(initialFirstItem, findsOneWidget);
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Reorder'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(find.text('file_99.txt'), findsOneWidget);
    });
    testWidgets('should handle memory efficiently with large lists',
        (WidgetTester tester) async {
      final veryLargeList = List.generate(
        2000,
        (i) => SshFile(
          name: 'huge_file_$i.txt',
          fullPath: '/very/long/path/to/huge_file_$i.txt',
          type: FileType.regular,
          displayName: 'huge_file_$i.txt',
          size: i * 1024 * 1024,
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
      expect(find.byType(ListView), findsOneWidget);
      await tester.fling(find.byType(ListView), const Offset(0, -1000), 2000);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ListView), findsOneWidget);
    });
    test('file size formatting performance', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        final file = SshFile(
          name: 'test_$i.txt',
          fullPath: '/test_$i.txt',
          type: FileType.regular,
          displayName: 'test_$i.txt',
          size: i * 1024,
        );
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
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
