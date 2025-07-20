import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/command_item.dart';

/// Service for managing custom commands
class CustomCommandsService {
  static const String _storageKey = 'custom_commands';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Load custom commands from secure storage
  static Future<List<CommandItem>> loadCustomCommands() async {
    try {
      final commandsJson = await _storage.read(key: _storageKey);
      
      if (commandsJson == null || commandsJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> commandsList = jsonDecode(commandsJson);
      return commandsList.map((json) => CommandItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading custom commands: $e');
      return [];
    }
  }
  
  /// Save custom commands to secure storage
  static Future<void> saveCustomCommands(List<CommandItem> commands) async {
    try {
      final commandsJson = jsonEncode(commands.map((c) => c.toJson()).toList());
      await _storage.write(key: _storageKey, value: commandsJson);
    } catch (e) {
      print('Error saving custom commands: $e');
      throw Exception('Erro ao salvar comandos personalizados');
    }
  }
  
  /// Add a new custom command
  static Future<void> addCustomCommand(CommandItem command) async {
    try {
      final commands = await loadCustomCommands();
      
      // Check if command already exists
      if (commands.any((c) => c.name == command.name || c.command == command.command)) {
        throw Exception('Comando já existe');
      }
      
      commands.add(command);
      await saveCustomCommands(commands);
    } catch (e) {
      print('Error adding custom command: $e');
      rethrow;
    }
  }
  
  /// Remove a custom command
  static Future<void> removeCustomCommand(CommandItem command) async {
    try {
      final commands = await loadCustomCommands();
      commands.removeWhere((c) => c.name == command.name && c.command == command.command);
      await saveCustomCommands(commands);
    } catch (e) {
      print('Error removing custom command: $e');
      throw Exception('Erro ao remover comando personalizado');
    }
  }
  
  /// Update a custom command
  static Future<void> updateCustomCommand(CommandItem oldCommand, CommandItem newCommand) async {
    try {
      final commands = await loadCustomCommands();
      final index = commands.indexWhere((c) => c.name == oldCommand.name && c.command == oldCommand.command);
      
      if (index != -1) {
        commands[index] = newCommand;
        await saveCustomCommands(commands);
      } else {
        throw Exception('Comando não encontrado');
      }
    } catch (e) {
      print('Error updating custom command: $e');
      rethrow;
    }
  }
  
  /// Check if custom commands exist
  static Future<bool> hasCustomCommands() async {
    final commands = await loadCustomCommands();
    return commands.isNotEmpty;
  }
  
  /// Clear all custom commands
  static Future<void> clearCustomCommands() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (e) {
      print('Error clearing custom commands: $e');
      throw Exception('Erro ao limpar comandos personalizados');
    }
  }
  
  /// Export custom commands as JSON string
  static Future<String> exportCustomCommands() async {
    try {
      final commands = await loadCustomCommands();
      return jsonEncode(commands.map((c) => c.toJson()).toList());
    } catch (e) {
      print('Error exporting custom commands: $e');
      throw Exception('Erro ao exportar comandos personalizados');
    }
  }
  
  /// Import custom commands from JSON string
  static Future<void> importCustomCommands(String jsonString, {bool replaceExisting = false}) async {
    try {
      final List<dynamic> commandsList = jsonDecode(jsonString);
      final importedCommands = commandsList.map((json) => CommandItem.fromJson(json)).toList();
      
      List<CommandItem> existingCommands = [];
      if (!replaceExisting) {
        existingCommands = await loadCustomCommands();
      }
      
      // Merge commands, avoiding duplicates
      final Set<String> existingNames = existingCommands.map((c) => c.name).toSet();
      final Set<String> existingCommands_set = existingCommands.map((c) => c.command).toSet();
      
      for (final command in importedCommands) {
        if (!existingNames.contains(command.name) && !existingCommands_set.contains(command.command)) {
          existingCommands.add(command);
        }
      }
      
      await saveCustomCommands(existingCommands);
    } catch (e) {
      print('Error importing custom commands: $e');
      throw Exception('Erro ao importar comandos personalizados');
    }
  }
}