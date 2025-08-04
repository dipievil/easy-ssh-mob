import 'package:flutter/material.dart';

/// Represents a command item that can be executed in the SSH terminal
class CommandItem {
  final String name;
  final String command;
  final IconData icon;
  final String? description;

  const CommandItem(this.name, this.command, this.icon, [this.description]);

  /// Create CommandItem from JSON (for custom commands storage)
  factory CommandItem.fromJson(Map<String, dynamic> json) {
    // Use a safer approach for icon recreation from JSON
    final iconCodePoint =
        json['iconCodePoint'] as int? ?? Icons.terminal.codePoint;
    final iconFontFamily = json['iconFontFamily'] as String?;

    return CommandItem(
      json['name'] as String,
      json['command'] as String,
      _getIconFromCodePoint(iconCodePoint, iconFontFamily),
      json['description'] as String?,
    );
  }

  /// Helper method to safely recreate IconData
  static IconData _getIconFromCodePoint(int codePoint, String? fontFamily) {
    // Use common Material icons to avoid tree shaking issues
    switch (codePoint) {
      case 0xe5c3:
        return Icons.terminal;
      case 0xe145:
        return Icons.folder;
      case 0xe2c7:
        return Icons.file_copy;
      case 0xe8b6:
        return Icons.settings;
      case 0xe8e8:
        return Icons.sync;
      case 0xe8f4:
        return Icons.system_update;
      case 0xe2c8:
        return Icons.file_download;
      case 0xe2c9:
        return Icons.file_upload;
      case 0xe86f:
        return Icons.refresh;
      case 0xe5d2:
        return Icons.folder_open;
      default:
        return Icons.terminal; // Default fallback
    }
  }

  /// Convert CommandItem to JSON (for custom commands storage)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'command': command,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          command == other.command;

  @override
  int get hashCode => name.hashCode ^ command.hashCode;

  @override
  String toString() {
    return 'CommandItem{name: $name, command: $command, description: $description}';
  }
}
