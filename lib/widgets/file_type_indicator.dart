import 'package:flutter/material.dart';
import '../models/ssh_file.dart';

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
          file.icon,
          color: _getIconColor(),
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

  Color _getIconColor() {
    switch (file.type) {
      case FileType.directory:
        return Colors.blue;
      case FileType.executable:
        return Colors.green;
      case FileType.symlink:
        return Colors.purple;
      case FileType.regular:
        return _getRegularFileColor();
      default:
        return Colors.grey;
    }
  }

  Color _getRegularFileColor() {
    final name = file.name.toLowerCase();
    
    // Script files that might be executable
    if (name.endsWith('.sh') || 
        name.endsWith('.py') || 
        name.endsWith('.pl') || 
        name.endsWith('.rb') || 
        name.endsWith('.js')) {
      return Colors.orange;
    }
    
    // Text files
    if (name.endsWith('.txt') || 
        name.endsWith('.md') || 
        name.endsWith('.log')) {
      return Colors.grey[600]!;
    }
    
    // Config files
    if (name.endsWith('.conf') || 
        name.endsWith('.cfg') || 
        name.endsWith('.ini') ||
        name.endsWith('.json') ||
        name.endsWith('.yaml') ||
        name.endsWith('.yml')) {
      return Colors.teal;
    }
    
    return Colors.grey;
  }
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