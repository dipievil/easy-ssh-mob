import 'package:flutter/widgets.dart';

/// Represents a command item that can be executed in the SSH terminal
class CommandItem {
  final String name;
  final String command;
  final IconData icon;
  final String? description;

  const CommandItem(
    this.name,
    this.command,
    this.icon, [
    this.description,
  ]);

  /// Create CommandItem from JSON (for custom commands storage)
  factory CommandItem.fromJson(Map<String, dynamic> json) {
    return CommandItem(
      json['name'] as String,
      json['command'] as String,
      IconData(json['iconCodePoint'] as int, fontFamily: json['iconFontFamily'] as String?),
      json['description'] as String?,
    );
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