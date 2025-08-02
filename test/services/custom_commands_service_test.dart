import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../src/lib/models/command_item.dart';
import '../../src/lib/services/custom_commands_service.dart';

void main() {
  group('CustomCommandsService', () {
    setUp(() async {
      // Clear any existing data before each test
      await CustomCommandsService.clearCustomCommands();
    });

    tearDown(() async {
      // Clean up after each test
      await CustomCommandsService.clearCustomCommands();
    });

    test('should start with empty custom commands', () async {
      final commands = await CustomCommandsService.loadCustomCommands();
      expect(commands, isEmpty);
    });

    test('should add and retrieve custom command', () async {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
        'Test description',
      );

      await CustomCommandsService.addCustomCommand(command);
      final commands = await CustomCommandsService.loadCustomCommands();

      expect(commands, hasLength(1));
      expect(commands.first.name, 'Test Command');
      expect(commands.first.command, 'echo "test"');
    });

    test('should not add duplicate commands', () async {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
      );

      await CustomCommandsService.addCustomCommand(command);
      
      // Try to add the same command again
      expect(
        () => CustomCommandsService.addCustomCommand(command),
        throwsException,
      );
    });

    test('should remove custom command', () async {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
      );

      await CustomCommandsService.addCustomCommand(command);
      await CustomCommandsService.removeCustomCommand(command);
      
      final commands = await CustomCommandsService.loadCustomCommands();
      expect(commands, isEmpty);
    });

    test('should update custom command', () async {
      const oldCommand = CommandItem(
        'Old Command',
        'echo "old"',
        FontAwesomeIcons.terminal,
      );
      const newCommand = CommandItem(
        'New Command',
        'echo "new"',
        FontAwesomeIcons.home,
      );

      await CustomCommandsService.addCustomCommand(oldCommand);
      await CustomCommandsService.updateCustomCommand(oldCommand, newCommand);
      
      final commands = await CustomCommandsService.loadCustomCommands();
      expect(commands, hasLength(1));
      expect(commands.first.name, 'New Command');
      expect(commands.first.command, 'echo "new"');
    });

    test('should export and import commands', () async {
      const command1 = CommandItem('Command 1', 'echo "1"', FontAwesomeIcons.terminal);
      const command2 = CommandItem('Command 2', 'echo "2"', FontAwesomeIcons.home);

      await CustomCommandsService.addCustomCommand(command1);
      await CustomCommandsService.addCustomCommand(command2);

      final exported = await CustomCommandsService.exportCustomCommands();
      expect(exported, isNotEmpty);

      // Clear and import
      await CustomCommandsService.clearCustomCommands();
      await CustomCommandsService.importCustomCommands(exported);

      final commands = await CustomCommandsService.loadCustomCommands();
      expect(commands, hasLength(2));
    });

    test('should check if has custom commands', () async {
      expect(await CustomCommandsService.hasCustomCommands(), isFalse);

      const command = CommandItem('Test', 'echo "test"', FontAwesomeIcons.terminal);
      await CustomCommandsService.addCustomCommand(command);

      expect(await CustomCommandsService.hasCustomCommands(), isTrue);
    });
  });
}