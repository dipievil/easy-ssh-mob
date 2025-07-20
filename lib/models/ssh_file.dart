import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Enum representing different file types based on ls -F output
enum FileType {
  directory,    // /
  executable,   // *
  regular,      // (no suffix)
  symlink,      // @
  fifo,         // |
  socket,       // =
  unknown
}

/// Model representing a file or directory from SSH server
class SshFile {
  final String name;
  final String fullPath;
  final FileType type;
  final String displayName;

  const SshFile({
    required this.name,
    required this.fullPath,
    required this.type,
    required this.displayName,
  });

  /// Factory constructor to create SshFile from ls -F output line
  factory SshFile.fromLsLine(String line, String currentPath) {
    String displayName = line.trim();
    String name = displayName;
    FileType type = FileType.regular;

    // Parse ls -F suffixes to determine file type
    if (displayName.endsWith('/')) {
      type = FileType.directory;
      name = displayName.substring(0, displayName.length - 1);
    } else if (displayName.endsWith('*')) {
      type = FileType.executable;
      name = displayName.substring(0, displayName.length - 1);
    } else if (displayName.endsWith('@')) {
      type = FileType.symlink;
      name = displayName.substring(0, displayName.length - 1);
    } else if (displayName.endsWith('|')) {
      type = FileType.fifo;
      name = displayName.substring(0, displayName.length - 1);
    } else if (displayName.endsWith('=')) {
      type = FileType.socket;
      name = displayName.substring(0, displayName.length - 1);
    }

    // Construct full path
    String fullPath = currentPath.endsWith('/')
        ? '$currentPath$name'
        : '$currentPath/$name';

    return SshFile(
      name: name,
      fullPath: fullPath,
      type: type,
      displayName: displayName,
    );
  }

  /// Get appropriate icon for file type
  IconData get icon {
    switch (type) {
      case FileType.directory:
        return FontAwesomeIcons.folder;
      case FileType.executable:
        return FontAwesomeIcons.terminal;
      case FileType.symlink:
        return FontAwesomeIcons.link;
      case FileType.fifo:
        return FontAwesomeIcons.arrowsAltH;
      case FileType.socket:
        return FontAwesomeIcons.plug;
      case FileType.regular:
        return FontAwesomeIcons.file;
      case FileType.unknown:
        return FontAwesomeIcons.question;
    }
  }

  /// Check if this is a directory
  bool get isDirectory => type == FileType.directory;

  /// Check if this is an executable file
  bool get isExecutable => type == FileType.executable;

  /// Check if this is a symbolic link
  bool get isSymlink => type == FileType.symlink;

  /// Check if this is a regular file
  bool get isRegularFile => type == FileType.regular;
  
  /// Check if this file can be viewed as text
  bool get isTextFile {
    // Known text file extensions
    final textExtensions = [
      '.txt', '.log', '.conf', '.cfg', '.ini', '.json', '.xml', '.yml', '.yaml',
      '.md', '.sh', '.py', '.js', '.css', '.html', '.sql', '.properties',
      '.env', '.gitignore', '.dockerfile', '.makefile', '.readme'
    ];
    
    final lowerName = name.toLowerCase();
    
    // Check extension
    for (String ext in textExtensions) {
      if (lowerName.endsWith(ext)) {
        return true;
      }
    }
    
    // Files without extension that are typically text
    final textFiles = ['readme', 'license', 'changelog', 'makefile', 'dockerfile'];
    if (textFiles.contains(lowerName)) {
      return true;
    }
    
    return false;
  }

  /// Get human-readable type description
  String get typeDescription {
    switch (type) {
      case FileType.directory:
        return 'Directory';
      case FileType.executable:
        return 'Executable';
      case FileType.regular:
        return 'File';
      case FileType.symlink:
        return 'Symbolic Link';
      case FileType.fifo:
        return 'FIFO Pipe';
      case FileType.socket:
        return 'Socket';
      case FileType.unknown:
        return 'Unknown';
    }
  }

  /// Create a copy with modified values
  SshFile copyWith({
    String? name,
    String? fullPath,
    FileType? type,
    String? displayName,
  }) {
    return SshFile(
      name: name ?? this.name,
      fullPath: fullPath ?? this.fullPath,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SshFile &&
        other.name == name &&
        other.fullPath == fullPath &&
        other.type == type &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return Object.hash(name, fullPath, type, displayName);
  }

  @override
  String toString() {
    return 'SshFile(name: $name, fullPath: $fullPath, type: $type)';
  }
}