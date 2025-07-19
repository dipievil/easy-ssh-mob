import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ssh_file.dart';

/// Custom widget to display SSH files and directories as interactive tiles
class SshFileListTile extends StatelessWidget {
  final SshFile file;
  final VoidCallback onTap;
  final bool isLoading;

  const SshFileListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.isLoading = false,
  });

  /// Get icon color based on file type
  Color _getIconColor() {
    switch (file.type) {
      case FileType.directory:
        return Colors.blue;
      case FileType.executable:
        return Colors.green;
      case FileType.regular:
        return Colors.grey;
      case FileType.symlink:
        return Colors.purple;
      case FileType.fifo:
        return Colors.orange;
      case FileType.socket:
        return Colors.teal;
      case FileType.unknown:
        return Colors.grey.shade400;
    }
  }

  /// Get appropriate subtitle text
  String _getSubtitle() {
    return file.typeDescription;
  }

  /// Get trailing icon based on file type
  IconData? _getTrailingIcon() {
    if (file.isDirectory) {
      return Icons.arrow_forward_ios;
    }
    return null;
  }

  /// Check if this file is a script based on common script extensions
  bool _isScript() {
    final scriptExtensions = ['.sh', '.py', '.js', '.rb', '.pl', '.php'];
    return scriptExtensions.any((ext) => file.name.toLowerCase().endsWith(ext));
  }

  /// Get enhanced icon for file type with script detection
  IconData _getEnhancedIcon() {
    if (_isScript()) {
      return FontAwesomeIcons.fileCode;
    }
    return file.icon;
  }

  /// Get enhanced icon color with script detection
  Color _getEnhancedIconColor() {
    if (_isScript()) {
      return Colors.orange;
    }
    return _getIconColor();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getEnhancedIcon(),
        color: _getEnhancedIconColor(),
        size: 20,
      ),
      title: Text(
        file.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _getSubtitle(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_getTrailingIcon(), size: 16, color: Colors.grey.shade400),
      onTap: isLoading ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }
}