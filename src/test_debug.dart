import 'lib/services/file_icon_manager.dart';
import 'lib/models/ssh_file.dart';
import 'package:flutter/material.dart';

void main() {
  final file = SshFile(
    name: 'Downloads',
    fullPath: '/Downloads',
    type: FileType.directory,
    displayName: 'Downloads/',
  );

  final icon = FileIconManager.getIconForFile(file);
  print('Icon codePoint: 0x${icon.codePoint.toRadixString(16).toUpperCase()}');
  print(
      'Expected (Icons.download): 0x${Icons.download.codePoint.toRadixString(16).toUpperCase()}');
}
