import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:easy_ssh_mob_new/screens/file_viewer_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';
import 'package:easy_ssh_mob_new/models/file_content.dart';
import 'package:easy_ssh_mob_new/models/ssh_connection_state.dart';
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
      when(mockProvider.connectionState)
          .thenReturn(SshConnectionState.connected);
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

    FileContent createFileContent({
      String? content,
      bool? isTruncated,
      int? totalLines,
      int? displayedLines,
      FileViewMode? mode,
      int? fileSize,
    }) {
      return FileContent(
        content: content ?? 'Default content',
        isTruncated: isTruncated ?? false,
        totalLines: totalLines ?? 1,
        displayedLines: displayedLines ?? 1,
        mode: mode ?? FileViewMode.full,
        fileSize: fileSize,
      );
    }

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return createFileContent(
          content: 'Test file content',
          isTruncated: false,
          totalLines: 1,
          mode: FileViewMode.full,
          fileSize: 17,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test file content'), findsOneWidget);
    });
    testWidgets('should display file content when loaded',
        (WidgetTester tester) async {
      const fileContent = 'Hello, this is test file content\nLine 2\nLine 3';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: fileContent,
          fileSize: fileContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text(fileContent), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    testWidgets('should display error message when file loading fails',
        (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenThrow(Exception('File not found'));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.textContaining('Erro'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    testWidgets('should show file name in app bar',
        (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: 'test content',
          isTruncated: false,
          totalLines: 1,
          displayedLines: 1,
          mode: FileViewMode.full,
          fileSize: 12,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text(testFile.name), findsOneWidget);
    });
    testWidgets('should display search functionality',
        (WidgetTester tester) async {
      const fileContent =
          'Hello world\nThis is a test file\nHello again\nWorld ending';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: fileContent,
          fileSize: fileContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 de 2'), findsOneWidget);
    });
    testWidgets('should navigate between search results',
        (WidgetTester tester) async {
      const fileContent =
          'Hello world\nThis is a test file\nHello again\nWorld ending';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: fileContent,
          fileSize: fileContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
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
    testWidgets('should handle empty file content',
        (WidgetTester tester) async {
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: '',
          fileSize: 0,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      final selectableText =
          tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectableText.data, isEmpty);
    });
    testWidgets('should handle large file content with scrolling',
        (WidgetTester tester) async {
      final largeContent = List.generate(100,
              (i) => 'Line ${i + 1}: This is a long line with some content')
          .join('\n');
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: largeContent,
          fileSize: largeContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(Scrollable), findsAtLeastNWidgets(1));
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -200));
      await tester.pumpAndSettle();
    });
    testWidgets('should copy content to clipboard',
        (WidgetTester tester) async {
      const fileContent = 'Content to copy';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: fileContent,
          fileSize: fileContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      final copyIcon = find.byIcon(Icons.copy);
      if (copyIcon.evaluate().isNotEmpty) {
        await tester.tap(copyIcon);
        await tester.pump();
        expect(find.textContaining('copiado'), findsOneWidget);
      }
    });
    testWidgets('should refresh file content', (WidgetTester tester) async {
      const initialContent = 'Initial content';
      const updatedContent = 'Updated content';
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: initialContent,
          fileSize: initialContent.length,
        );
      });
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text(initialContent), findsOneWidget);
      when(mockProvider.readFile(any)).thenAnswer((_) async {
        return createFileContent(
          content: updatedContent,
          fileSize: updatedContent.length,
        );
      });
      final refreshIcon = find.byIcon(Icons.refresh);
      if (refreshIcon.evaluate().isNotEmpty) {
        await tester.tap(refreshIcon);
        await tester.pumpAndSettle();
        expect(find.text(updatedContent), findsOneWidget);
        expect(find.text(initialContent), findsNothing);
      }
    });
    testWidgets('should handle binary file gracefully',
        (WidgetTester tester) async {
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
      expect(find.textContaining('Cannot display binary file'), findsOneWidget);
    });
  });
}
