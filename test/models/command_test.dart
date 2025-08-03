import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../src/lib/models/command_item.dart';
import '../../src/lib/models/predefined_commands.dart';

void main() {
  group('CommandItem', () {
    test('should create CommandItem correctly', () {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
        'Test description',
      );

      expect(command.name, 'Test Command');
      expect(command.command, 'echo "test"');
      expect(command.icon, FontAwesomeIcons.terminal);
      expect(command.description, 'Test description');
    });

    test('should convert to/from JSON correctly', () {
      const command = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
        'Test description',
      );

      final json = command.toJson();
      final restored = CommandItem.fromJson(json);

      expect(restored.name, command.name);
      expect(restored.command, command.command);
      expect(restored.description, command.description);
      expect(restored.icon.codePoint, command.icon.codePoint);
    });

    test('should handle equality correctly', () {
      const command1 = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.terminal,
      );
      const command2 = CommandItem(
        'Test Command',
        'echo "test"',
        FontAwesomeIcons.home,
      );

      expect(command1, command2); // Should be equal based on name and command
    });
  });

  group('PredefinedCommands', () {
    test('should have all required categories', () {
      final categories = PredefinedCommands.categories;
      
      expect(categories, contains('Informações'));
      expect(categories, contains('Sistema'));
      expect(categories, contains('Rede'));
      expect(categories, contains('Logs'));
    });

    test('should have commands in each category', () {
      for (final category in PredefinedCommands.categories) {
        final commands = PredefinedCommands.getCommandsForCategory(category);
        expect(commands, isNotEmpty, reason: 'Category $category should have commands');
      }
    });

    test('should find commands when searching', () {
      final results = PredefinedCommands.searchCommands('sistema');
      expect(results, isNotEmpty);
      
      final noResults = PredefinedCommands.searchCommands('nonexistent');
      expect(noResults, isEmpty);
    });

    test('should return all commands when searching empty query', () {
      final allCommands = PredefinedCommands.allCommands;
      final searchResults = PredefinedCommands.searchCommands('');
      
      expect(searchResults.length, allCommands.length);
    });

    test('should have specific required commands', () {
      final infoCommands = PredefinedCommands.getCommandsForCategory('Informações');
      final systemCommands = PredefinedCommands.getCommandsForCategory('Sistema');
      final networkCommands = PredefinedCommands.getCommandsForCategory('Rede');
      final logCommands = PredefinedCommands.getCommandsForCategory('Logs');

      // Check for some specific commands mentioned in the requirements
      expect(infoCommands.any((c) => c.command.contains('uname')), isTrue);
      expect(infoCommands.any((c) => c.command.contains('whoami')), isTrue);
      expect(systemCommands.any((c) => c.command.contains('df')), isTrue);
      expect(systemCommands.any((c) => c.command.contains('ps')), isTrue);
      expect(networkCommands.any((c) => c.command.contains('ip')), isTrue);
      expect(logCommands.any((c) => c.command.contains('syslog')), isTrue);
    });
  });
}