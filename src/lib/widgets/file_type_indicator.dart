import 'package:flutter/material.dart';
import '../models/ssh_file.dart';
import '../utils/file_icon_manager.dart';

/// Utility widget to display file type specific icons and information
class FileTypeIndicator extends StatelessWidget {
  final SshFile file;
  final bool showExecutionHint;
  
  const FileTypeIndicator({
    super.key,
    required this.file,
    this.showExecutionHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FileIconManager.getIconForFile(file),
          color: FileIconManager.getColorForFile(file, context),
        ),
        if (showExecutionHint && file.isExecutable) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.play_circle_outline,
            size: 16,
            color: Colors.green.withOpacity(0.7),
          ),
        ],
      ],
    );
  }

  // Removed _getIconColor method as it's now handled by FileIconManager
  // Removed _getRegularFileColor method as it's now handled by FileIconManager
}

/// Extension methods for SshFile to check if it might be executable
extension SshFileExecutable on SshFile {
  /// Check if file might be executable based on extension or name
  bool get mightBeExecutable {
    if (isExecutable) return true;
    
    final name = this.name.toLowerCase();
    return name.endsWith('.sh') || 
           name.endsWith('.py') || 
           name.endsWith('.pl') || 
           name.endsWith('.rb') || 
           name.endsWith('.js') ||
           name.endsWith('.bat') ||
           name.endsWith('.cmd');
  }
  
  /// Get execution hint text
  String get executionHint {
    if (isExecutable) return 'Clique para executar';
    if (mightBeExecutable) return 'Pode ser executável';
    return '';
  }
}