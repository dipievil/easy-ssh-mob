import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/services/file_icon_manager.dart';
import 'package:easy_ssh_mob_new/models/ssh_file.dart';

void main() {
  test('debug icon check', () {
    final dir = SshFile(
      name: 'Downloads',
      fullPath: '/Downloads',
      type: FileType.directory,
      displayName: 'Downloads/',
    );

    final icon = FileIconManager.getIconForFile(dir);
    print(
        'Downloads icon: 0x${icon.codePoint.toRadixString(16).toUpperCase()}');

    final licenseFile = SshFile(
      name: 'LICENSE',
      fullPath: '/LICENSE',
      type: FileType.regular,
      displayName: 'LICENSE',
    );

    final licenseIcon = FileIconManager.getIconForFile(licenseFile);
    print(
        'LICENSE icon: 0x${licenseIcon.codePoint.toRadixString(16).toUpperCase()}');

    print(
        'Icons.download: 0x${Icons.download.codePoint.toRadixString(16).toUpperCase()}');
    print(
        'Icons.gavel: 0x${Icons.gavel.codePoint.toRadixString(16).toUpperCase()}');
  });
}
