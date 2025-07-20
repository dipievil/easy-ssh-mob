import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/error_handler.dart';

/// Customized SnackBar for displaying SSH errors
class ErrorSnackBar {
  /// Show error SnackBar with appropriate styling and actions
  static void show(BuildContext context, SshError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.userFriendlyMessage)),
          ],
        ),
        backgroundColor: _getErrorColor(error.severity),
        duration: Duration(seconds: error.severity == ErrorSeverity.critical ? 10 : 4),
        action: error.suggestion != null
          ? SnackBarAction(
              label: 'AJUDA',
              textColor: Colors.white,
              onPressed: () => _showErrorDialog(context, error),
            )
          : null,
      ),
    );
  }
  
  /// Show detailed error dialog
  static void _showErrorDialog(BuildContext context, SshError error) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(error: error),
    );
  }
  
  /// Get appropriate icon for error type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.permissionDenied:
      case ErrorType.accessDenied:
        return FontAwesomeIcons.lock;
      case ErrorType.fileNotFound:
        return FontAwesomeIcons.fileCircleXmark;
      case ErrorType.operationNotPermitted:
        return FontAwesomeIcons.ban;
      case ErrorType.connectionLost:
        return FontAwesomeIcons.wifiSlash;
      case ErrorType.timeout:
        return FontAwesomeIcons.clock;
      case ErrorType.commandNotFound:
        return FontAwesomeIcons.terminal;
      case ErrorType.diskFull:
        return FontAwesomeIcons.hardDrive;
      case ErrorType.unknown:
        return FontAwesomeIcons.triangleExclamation;
    }
  }
  
  /// Get appropriate color for error severity
  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

/// Detailed error dialog with technical information and suggestions
class ErrorDialog extends StatelessWidget {
  final SshError error;
  
  const ErrorDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(ErrorSnackBar._getErrorIcon(error.type)),
          const SizedBox(width: 8),
          const Text('Erro de Operação'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage),
          if (error.suggestion != null) ...[
            const SizedBox(height: 12),
            const Text('Sugestão:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(error.suggestion!),
          ],
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Detalhes técnicos'),
            children: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  error.originalMessage,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}