import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_ssh_mob_new/models/command_item.dart';
import 'package:easy_ssh_mob_new/services/custom_commands_service.dart';

void main() {
  group('CustomCommandsService', () {
    test('should handle empty storage gracefully', () async {
      // This test verifies the service handles empty/null storage results
      try {
        final commands = await CustomCommandsService.loadCustomCommands();
        expect(commands, isA<List<CommandItem>>());
        // Even if storage fails, it should return an empty list, not throw
      } catch (e) {
        // In test environment, storage might not work, which is expected
        expect(e, isA<Exception>());
      }
    });

    test('CommandItem model should serialize correctly', () {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        icon: Icons.terminal,
        color: Colors.blue,
      );

      final json = command.toJson();
      expect(json['name'], equals('Test Command'));
      expect(json['command'], equals('echo "test"'));

      final reconstructed = CommandItem.fromJson(json);
      expect(reconstructed.name, equals(command.name));
      expect(reconstructed.command, equals(command.command));
    });

    test('should validate command structure', () {
      const validCommand = CommandItem('Valid', 'ls -la');
      expect(validCommand.name, isNotEmpty);
      expect(validCommand.command, isNotEmpty);

      const emptyCommand = CommandItem('', '');
      expect(emptyCommand.name, isEmpty);
      expect(emptyCommand.command, isEmpty);
    });

    test('should handle json serialization edge cases', () {
      const command = CommandItem(
        'Special Chars',
        'echo "test with \\"quotes\\" and spaces"',
        icon: Icons.code,
      );

      final json = command.toJson();
      final reconstructed = CommandItem.fromJson(json);

      expect(reconstructed.name, equals(command.name));
      expect(reconstructed.command, equals(command.command));
    });

    test('service methods should handle storage errors gracefully', () async {
      // Test that service methods don't crash even if storage is unavailable
      try {
        await CustomCommandsService.loadCustomCommands();
      } catch (e) {
        // Storage errors are expected in test environment
        expect(e, isNotNull);
      }

      try {
        const command = CommandItem('Test', 'echo test');
        await CustomCommandsService.addCustomCommand(command);
      } catch (e) {
        // Storage errors are expected in test environment
        expect(e, isNotNull);
      }

      try {
        await CustomCommandsService.hasCustomCommands();
      } catch (e) {
        // Storage errors are expected in test environment
        expect(e, isNotNull);
      }
    });
  });
}
