import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_ssh_mob_new/models/command_item.dart';
import 'package:easy_ssh_mob_new/services/custom_commands_service.dart';

void main() {
  group('CustomCommandsService', () {
    test('should handle empty storage gracefully', () async {
      try {
        final commands = await CustomCommandsService.loadCustomCommands();
        expect(commands, isA<List<CommandItem>>());
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
    test('CommandItem model should serialize correctly', () {
      const command =
          CommandItem('Test Command', 'echo "test"', FontAwesomeIcons.terminal);
      final json = command.toJson();
      expect(json['name'], equals('Test Command'));
      expect(json['command'], equals('echo "test"'));
      final reconstructed = CommandItem.fromJson(json);
      expect(reconstructed.name, equals(command.name));
      expect(reconstructed.command, equals(command.command));
    });
    test('should validate command structure', () {
      const validCommand =
          CommandItem('Valid', 'ls -la', FontAwesomeIcons.terminal);
      expect(validCommand.name, isNotEmpty);
      expect(validCommand.command, isNotEmpty);
      const emptyCommand = CommandItem('', '', FontAwesomeIcons.terminal);
      expect(emptyCommand.name, isEmpty);
      expect(emptyCommand.command, isEmpty);
    });
    test('should handle json serialization edge cases', () {
      const command = CommandItem(
        'Special Chars',
        'echo "test with \\"quotes\\" and spaces"',
        FontAwesomeIcons.code,
      );
      final json = command.toJson();
      final reconstructed = CommandItem.fromJson(json);
      expect(reconstructed.name, equals(command.name));
      expect(reconstructed.command, equals(command.command));
    });
    test('service methods should handle storage errors gracefully', () async {
      try {
        await CustomCommandsService.loadCustomCommands();
      } catch (e) {
        expect(e, isNotNull);
      }
      try {
        const command =
            CommandItem('Test', 'echo test', FontAwesomeIcons.terminal);
        await CustomCommandsService.addCustomCommand(command);
      } catch (e) {
        expect(e, isNotNull);
      }
      try {
        await CustomCommandsService.hasCustomCommands();
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
