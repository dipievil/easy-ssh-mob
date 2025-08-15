import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/widgets/ssh_file_list_tile.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';

void main() {
  group('SshFileListTile', () {
    testWidgets('should display directory file correctly',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_dir',
        fullPath: '/home/test_dir',
        type: FileType.directory,
        displayName: 'test_dir/',
      );
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.text('test_dir/'), findsOneWidget);
      expect(find.text('Directory'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      await tester.tap(find.byType(SshFileListTile));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
    testWidgets('should display executable file correctly',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_exec',
        fullPath: '/home/test_exec',
        type: FileType.executable,
        displayName: 'test_exec*',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('test_exec*'), findsOneWidget);
      expect(find.text('Executable'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });
    testWidgets('should display regular file correctly',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test.txt',
        fullPath: '/home/test.txt',
        type: FileType.regular,
        displayName: 'test.txt',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('test.txt'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
    });
    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_dir',
        fullPath: '/home/test_dir',
        type: FileType.directory,
        displayName: 'test_dir/',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });
    testWidgets('should detect script files and show appropriate icon',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'script.sh',
        fullPath: '/home/script.sh',
        type: FileType.regular,
        displayName: 'script.sh',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('script.sh'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
    });
    testWidgets('should disable tap when loading', (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_dir',
        fullPath: '/home/test_dir',
        type: FileType.directory,
        displayName: 'test_dir/',
      );
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () => tapped = true,
              isLoading: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(SshFileListTile));
      await tester.pump();
      expect(tapped, isFalse);
    });
    testWidgets('should show scale animation on tap',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_dir',
        fullPath: '/home/test_dir',
        type: FileType.directory,
        displayName: 'test_dir/',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Transform), findsWidgets);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });
    testWidgets('should handle long press', (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_file',
        fullPath: '/home/test_file',
        type: FileType.regular,
        displayName: 'test_file',
      );
      bool longPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );
      await tester.longPress(find.byType(SshFileListTile));
      await tester.pumpAndSettle();
      expect(longPressed, isTrue);
    });
    testWidgets('should disable long press when loading',
        (WidgetTester tester) async {
      const file = SshFile(
        name: 'test_file',
        fullPath: '/home/test_file',
        type: FileType.regular,
        displayName: 'test_file',
      );
      bool longPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SshFileListTile(
              file: file,
              onTap: () {},
              onLongPress: () => longPressed = true,
              isLoading: true,
            ),
          ),
        ),
      );
      await tester.longPress(find.byType(SshFileListTile));
      await tester.pump();
      expect(longPressed, isFalse);
    });
  });
}
