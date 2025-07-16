import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/models/ssh_credentials.dart';

void main() {
  group('SSHCredentials Tests', () {
    test('should create valid credentials', () {
      final credentials = SSHCredentials(
        host: 'example.com',
        port: 22,
        username: 'user',
        password: 'password',
      );

      expect(credentials.host, equals('example.com'));
      expect(credentials.port, equals(22));
      expect(credentials.username, equals('user'));
      expect(credentials.password, equals('password'));
      expect(credentials.isValid(), isTrue);
    });

    test('should convert to and from JSON', () {
      final original = SSHCredentials(
        host: 'test.com',
        port: 2222,
        username: 'testuser',
        password: 'testpass',
      );

      final json = original.toJson();
      final restored = SSHCredentials.fromJson(json);

      expect(restored, equals(original));
    });

    test('should convert to and from JSON string', () {
      final original = SSHCredentials(
        host: 'test.com',
        port: 2222,
        username: 'testuser',
        password: 'testpass',
      );

      final jsonString = original.toJsonString();
      final restored = SSHCredentials.fromJsonString(jsonString);

      expect(restored, equals(original));
    });

    test('should validate credentials correctly', () {
      final validCredentials = SSHCredentials(
        host: 'example.com',
        port: 22,
        username: 'user',
        password: 'password',
      );
      expect(validCredentials.isValid(), isTrue);

      final emptyHost = SSHCredentials(
        host: '',
        port: 22,
        username: 'user',
        password: 'password',
      );
      expect(emptyHost.isValid(), isFalse);

      final invalidPort = SSHCredentials(
        host: 'example.com',
        port: 0,
        username: 'user',
        password: 'password',
      );
      expect(invalidPort.isValid(), isFalse);

      final emptyUsername = SSHCredentials(
        host: 'example.com',
        port: 22,
        username: '',
        password: 'password',
      );
      expect(emptyUsername.isValid(), isFalse);

      final emptyPassword = SSHCredentials(
        host: 'example.com',
        port: 22,
        username: 'user',
        password: '',
      );
      expect(emptyPassword.isValid(), isFalse);
    });

    test('should create copy with updated fields', () {
      final original = SSHCredentials(
        host: 'original.com',
        port: 22,
        username: 'user',
        password: 'password',
      );

      final updated = original.copyWith(host: 'updated.com', port: 2222);

      expect(updated.host, equals('updated.com'));
      expect(updated.port, equals(2222));
      expect(updated.username, equals('user'));
      expect(updated.password, equals('password'));
    });
  });
}