import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/error_handler.dart';
import '../widgets/error_widgets.dart';

/// Debug screen for testing error handling system
class ErrorTestScreen extends StatelessWidget {
  const ErrorTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste do Sistema de Erros'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Teste dos diferentes tipos de erro SSH:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildErrorTestCard(
                    context,
                    'Permissão Negada',
                    'Testa erro de permissão de acesso',
                    Icons.lock,
                    () => _showTestError(context, ErrorType.permissionDenied),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Arquivo Não Encontrado',
                    'Testa erro de arquivo inexistente',
                    FontAwesomeIcons.fileCircleXmark,
                    () => _showTestError(context, ErrorType.fileNotFound),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Operação Não Permitida',
                    'Testa erro de operação restrita',
                    FontAwesomeIcons.ban,
                    () => _showTestError(
                      context,
                      ErrorType.operationNotPermitted,
                    ),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Conexão Perdida',
                    'Testa erro de conexão SSH perdida',
                    FontAwesomeIcons.wifi,
                    () => _showTestError(context, ErrorType.connectionLost),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Timeout',
                    'Testa erro de timeout de comando',
                    FontAwesomeIcons.clock,
                    () => _showTestError(context, ErrorType.timeout),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Comando Não Encontrado',
                    'Testa erro de comando inexistente',
                    FontAwesomeIcons.terminal,
                    () => _showTestError(context, ErrorType.commandNotFound),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Disco Cheio',
                    'Testa erro de espaço em disco',
                    FontAwesomeIcons.hardDrive,
                    () => _showTestError(context, ErrorType.diskFull),
                  ),
                  _buildErrorTestCard(
                    context,
                    'Erro Desconhecido',
                    'Testa erro genérico',
                    FontAwesomeIcons.triangleExclamation,
                    () => _showTestError(context, ErrorType.unknown),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTestCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  void _showTestError(BuildContext context, ErrorType errorType) {
    final error = _createTestError(errorType);

    // Show both SnackBar and Dialog for demonstration
    ErrorSnackBar.show(context, error);

    // Also show dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(error: error),
        );
      }
    });
  }

  SshError _createTestError(ErrorType errorType) {
    const command = 'test_command';

    switch (errorType) {
      case ErrorType.permissionDenied:
        return ErrorHandler.analyzeError('Permission denied', command);
      case ErrorType.fileNotFound:
        return ErrorHandler.analyzeError('No such file or directory', command);
      case ErrorType.operationNotPermitted:
        return ErrorHandler.analyzeError('Operation not permitted', command);
      case ErrorType.accessDenied:
        return ErrorHandler.analyzeError('Access denied', command);
      case ErrorType.connectionLost:
        return ErrorHandler.analyzeError(
          'Connection lost to remote host',
          command,
        );
      case ErrorType.timeout:
        return ErrorHandler.analyzeError('Connection timed out', command);
      case ErrorType.commandNotFound:
        return ErrorHandler.analyzeError('command not found', command);
      case ErrorType.diskFull:
        return ErrorHandler.analyzeError('No space left on device', command);
      case ErrorType.unknown:
        return ErrorHandler.analyzeError('Unknown error occurred', command);
    }
  }
}
