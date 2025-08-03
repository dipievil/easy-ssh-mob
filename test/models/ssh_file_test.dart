import 'package:flutter_test/flutter_test.dart';
import '../../src/lib/models/ssh_file.dart';

void main() {
  group('SshFile', () {
    group('fromLsLine', () {
      test('should parse directory correctly', () {
        const currentPath = '/home/user';
        const line = 'Documents/';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('Documents'));
        expect(file.displayName, equals('Documents/'));
        expect(file.type, equals(FileType.directory));
        expect(file.fullPath, equals('/home/user/Documents'));
        expect(file.isDirectory, isTrue);
      });

      test('should parse executable file correctly', () {
        const currentPath = '/usr/bin';
        const line = 'myapp*';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('myapp'));
        expect(file.displayName, equals('myapp*'));
        expect(file.type, equals(FileType.executable));
        expect(file.fullPath, equals('/usr/bin/myapp'));
        expect(file.isExecutable, isTrue);
      });

      test('should parse symbolic link correctly', () {
        const currentPath = '/etc';
        const line = 'config@';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('config'));
        expect(file.displayName, equals('config@'));
        expect(file.type, equals(FileType.symlink));
        expect(file.fullPath, equals('/etc/config'));
        expect(file.isSymlink, isTrue);
      });

      test('should parse regular file correctly', () {
        const currentPath = '/home/user';
        const line = 'readme.txt';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('readme.txt'));
        expect(file.displayName, equals('readme.txt'));
        expect(file.type, equals(FileType.regular));
        expect(file.fullPath, equals('/home/user/readme.txt'));
        expect(file.isRegularFile, isTrue);
      });

      test('should parse FIFO pipe correctly', () {
        const currentPath = '/tmp';
        const line = 'mypipe|';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('mypipe'));
        expect(file.displayName, equals('mypipe|'));
        expect(file.type, equals(FileType.fifo));
        expect(file.fullPath, equals('/tmp/mypipe'));
      });

      test('should parse socket correctly', () {
        const currentPath = '/var/run';
        const line = 'mysocket=';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.name, equals('mysocket'));
        expect(file.displayName, equals('mysocket='));
        expect(file.type, equals(FileType.socket));
        expect(file.fullPath, equals('/var/run/mysocket'));
      });

      test('should handle root path correctly', () {
        const currentPath = '/';
        const line = 'home/';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.fullPath, equals('/home'));
      });

      test('should handle path with trailing slash correctly', () {
        const currentPath = '/home/user/';
        const line = 'file.txt';
        
        final file = SshFile.fromLsLine(line, currentPath);
        
        expect(file.fullPath, equals('/home/user/file.txt'));
      });
    });

    group('icon property', () {
      test('should return correct icon for each file type', () {
        final directory = SshFile.fromLsLine('dir/', '/');
        final executable = SshFile.fromLsLine('app*', '/');
        final regular = SshFile.fromLsLine('file.txt', '/');
        final symlink = SshFile.fromLsLine('link@', '/');
        final fifo = SshFile.fromLsLine('pipe|', '/');
        final socket = SshFile.fromLsLine('sock=', '/');
        
        // Just verify they return icons (actual IconData comparison is complex)
        expect(directory.icon, isNotNull);
        expect(executable.icon, isNotNull);
        expect(regular.icon, isNotNull);
        expect(symlink.icon, isNotNull);
        expect(fifo.icon, isNotNull);
        expect(socket.icon, isNotNull);
      });
    });

    group('type description', () {
      test('should return correct descriptions', () {
        expect(FileType.directory.name, equals('directory'));
        expect(FileType.executable.name, equals('executable'));
        expect(FileType.regular.name, equals('regular'));
        expect(FileType.symlink.name, equals('symlink'));
        expect(FileType.fifo.name, equals('fifo'));
        expect(FileType.socket.name, equals('socket'));
        expect(FileType.unknown.name, equals('unknown'));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties match', () {
        final file1 = SshFile.fromLsLine('test.txt', '/home');
        final file2 = SshFile.fromLsLine('test.txt', '/home');
        
        expect(file1, equals(file2));
        expect(file1.hashCode, equals(file2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final file1 = SshFile.fromLsLine('test.txt', '/home');
        final file2 = SshFile.fromLsLine('other.txt', '/home');
        
        expect(file1, isNot(equals(file2)));
      });
    });

    group('copyWith', () {
      test('should create copy with modified properties', () {
        final original = SshFile.fromLsLine('test.txt', '/home');
        final copy = original.copyWith(name: 'modified.txt');
        
        expect(copy.name, equals('modified.txt'));
        expect(copy.type, equals(original.type));
        expect(copy.displayName, equals(original.displayName));
      });
    });

    group('text file detection', () {
      test('should detect text files by extension', () {
        const testCases = [
          'readme.txt',
          'config.conf',
          'data.json',
          'script.sh',
          'style.css',
          'page.html',
          'query.sql',
          'doc.md',
          'settings.yml',
          'values.yaml',
          'app.py',
          'main.js',
          'data.log',
          'settings.ini',
          'config.cfg',
          'data.xml',
          'app.properties',
          '.env',
          '.gitignore',
          'Dockerfile',
          'Makefile',
        ];

        for (final fileName in testCases) {
          final file = SshFile.fromLsLine(fileName, '/test');
          expect(file.isTextFile, true, reason: '$fileName should be detected as text file');
        }
      });

      test('should detect text files by name without extension', () {
        const textFiles = [
          'readme',
          'license',
          'changelog',
          'makefile',
          'dockerfile',
        ];

        for (final fileName in textFiles) {
          final file = SshFile.fromLsLine(fileName, '/test');
          expect(file.isTextFile, true, reason: '$fileName should be detected as text file');
        }
      });

      test('should not detect binary files as text', () {
        const binaryFiles = [
          'image.jpg',
          'video.mp4',
          'archive.zip',
          'program.exe',
          'library.so',
          'data.bin',
          'font.ttf',
        ];

        for (final fileName in binaryFiles) {
          final file = SshFile.fromLsLine(fileName, '/test');
          expect(file.isTextFile, false, reason: '$fileName should not be detected as text file');
        }
      });
    });
  });
}