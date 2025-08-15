import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_ssh_mob_new/services/file_icon_manager.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';
void main() {
  group('FileIconManager Tests', () {
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
        expect(
            FileIconManager.getIconForFile(directory), FontAwesomeIcons.folder);
        expect(FileIconManager.getIconForFile(executable),
            FontAwesomeIcons.terminal);
        expect(FileIconManager.getIconForFile(regular),
            FontAwesomeIcons.fileLines); 
        expect(FileIconManager.getIconForFile(symlink), FontAwesomeIcons.link);
      });
      test('should return specific icons for file extensions', () {
        final testCases = [
          ('document.pdf', FontAwesomeIcons.filePdf),
          ('text.md', FontAwesomeIcons.readme),
          ('sheet.xlsx', FontAwesomeIcons.fileExcel),
          ('text.txt', FontAwesomeIcons.fileLines),
          ('script.py', FontAwesomeIcons.python),
          ('web.html', FontAwesomeIcons.html5),
          ('style.css', FontAwesomeIcons.css3Alt),
          ('data.json', FontAwesomeIcons.fileCode),
          ('app.js', FontAwesomeIcons.js),
          ('photo.jpg', FontAwesomeIcons.fileImage),
          ('video.mp4', FontAwesomeIcons.fileVideo),
          ('song.mp3', FontAwesomeIcons.fileAudio),
          ('archive.zip', FontAwesomeIcons.fileZipper),
          ('system.log', FontAwesomeIcons.fileLines),
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
          ('Documents', FontAwesomeIcons.folder.codePoint),
          ('Downloads', FontAwesomeIcons.folder.codePoint),
          ('Pictures', FontAwesomeIcons.folder.codePoint),
          ('Music', FontAwesomeIcons.folder.codePoint),
          ('Videos', FontAwesomeIcons.folder.codePoint),
          ('Desktop', FontAwesomeIcons.folder.codePoint),
          ('.hidden', FontAwesomeIcons.folder.codePoint),
        ];
        for (final (dirName, expectedCodePoint) in specialDirs) {
          final dir = SshFile(
            name: dirName,
            fullPath: '/$dirName',
            type: FileType.directory,
            displayName: '$dirName/',
          );
          final actualIcon = FileIconManager.getIconForFile(dir);
          expect(
            actualIcon.codePoint,
            expectedCodePoint,
            reason:
                'Icon for directory $dirName should have codePoint 0x${expectedCodePoint.toRadixString(16).toUpperCase()}',
          );
        }
      });
      test('should return special icons for special file names', () {
        final specialFiles = [
          ('README', FontAwesomeIcons.readme.codePoint),
          (
            'LICENSE',
            FontAwesomeIcons.certificate.codePoint
          ), 
          ('CHANGELOG', FontAwesomeIcons.fileLines.codePoint),
          ('Makefile', FontAwesomeIcons.hammer.codePoint),
          ('Dockerfile', FontAwesomeIcons.docker.codePoint),
          (
            '.env',
            FontAwesomeIcons.gear.codePoint
          ), 
          (
            '.gitignore',
            FontAwesomeIcons.gitAlt.codePoint
          ), 
        ];
        for (final (fileName, expectedCodePoint) in specialFiles) {
          final file = SshFile(
            name: fileName,
            fullPath: '/$fileName',
            type: FileType.regular,
            displayName: fileName,
          );
          final actualIcon = FileIconManager.getIconForFile(file);
          expect(
            actualIcon.codePoint,
            expectedCodePoint,
            reason:
                'Icon for special file $fileName should have codePoint 0x${expectedCodePoint.toRadixString(16).toUpperCase()}',
          );
        }
      });
    });
    group('Color Selection', () {
      testWidgets('should return non-null colors for file types',
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
                const textFile = SshFile(
                  name: 'test.txt',
                  fullPath: '/test.txt',
                  type: FileType.regular,
                  displayName: 'test.txt',
                );
                final dirColor =
                    FileIconManager.getColorForFile(directory, context);
                final execColor =
                    FileIconManager.getColorForFile(executable, context);
                final textColor =
                    FileIconManager.getColorForFile(textFile, context);
                expect(dirColor, isNotNull);
                expect(execColor, isNotNull);
                expect(textColor, isNotNull);
                return Container();
              },
            ),
          ),
        );
      });
      testWidgets('should return colors for different themes',
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
                final lightColor =
                    FileIconManager.getColorForFile(file, context);
                expect(lightColor, isNotNull);
                return Container();
              },
            ),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                final darkColor =
                    FileIconManager.getColorForFile(file, context);
                expect(darkColor, isNotNull);
                return Container();
              },
            ),
          ),
        );
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
        expect(icon, FontAwesomeIcons.file); 
      });
      test('should handle files with multiple dots', () {
        const file = SshFile(
          name: 'file.backup.txt',
          fullPath: '/file.backup.txt',
          type: FileType.regular,
          displayName: 'file.backup.txt',
        );
        final icon = FileIconManager.getIconForFile(file);
        expect(icon,
            FontAwesomeIcons.fileLines); 
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
        expect(icon, FontAwesomeIcons.file);
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
        expect(icon1, FontAwesomeIcons.fileLines);
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
        expect(icon, FontAwesomeIcons.question); 
      });
    });
    group('Utility Methods', () {
      test('should correctly identify code files', () {
        expect(FileIconManager.isCodeFile('script.py'), isTrue);
        expect(FileIconManager.isCodeFile('app.js'), isTrue);
        expect(FileIconManager.isCodeFile('style.css'), isTrue);
        expect(FileIconManager.isCodeFile('document.pdf'), isFalse);
        expect(FileIconManager.isCodeFile('image.jpg'), isFalse);
      });
      test('should correctly identify image files', () {
        expect(FileIconManager.isImageFile('photo.jpg'), isTrue);
        expect(FileIconManager.isImageFile('logo.png'), isTrue);
        expect(FileIconManager.isImageFile('icon.svg'), isTrue);
        expect(FileIconManager.isImageFile('script.py'), isFalse);
        expect(FileIconManager.isImageFile('document.pdf'), isFalse);
      });
      test('should correctly identify video files', () {
        expect(FileIconManager.isVideoFile('movie.mp4'), isTrue);
        expect(FileIconManager.isVideoFile('clip.avi'), isTrue);
        expect(FileIconManager.isVideoFile('stream.mkv'), isTrue);
        expect(FileIconManager.isVideoFile('song.mp3'), isFalse);
        expect(FileIconManager.isVideoFile('photo.jpg'), isFalse);
      });
      test('should correctly identify audio files', () {
        expect(FileIconManager.isAudioFile('song.mp3'), isTrue);
        expect(FileIconManager.isAudioFile('track.wav'), isTrue);
        expect(FileIconManager.isAudioFile('audio.flac'), isTrue);
        expect(FileIconManager.isAudioFile('movie.mp4'), isFalse);
        expect(FileIconManager.isAudioFile('script.py'), isFalse);
      });
      test('should correctly identify archive files', () {
        expect(FileIconManager.isArchiveFile('data.zip'), isTrue);
        expect(FileIconManager.isArchiveFile('backup.tar'), isTrue);
        expect(FileIconManager.isArchiveFile('package.7z'), isTrue);
        expect(FileIconManager.isArchiveFile('document.pdf'), isFalse);
        expect(FileIconManager.isArchiveFile('script.py'), isFalse);
      });
    });
    group('Performance', () {
      test('should handle large number of files efficiently', () {
        final stopwatch = Stopwatch()..start();
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
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
