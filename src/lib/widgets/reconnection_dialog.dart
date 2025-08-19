import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import '../screens/login_screen.dart';

/// Dialog widget shown when SSH connection is lost and auto-reconnection fails
class ReconnectionDialog extends StatelessWidget {
  const ReconnectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => const ReconnectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SshProvider>(
      builder: (context, sshProvider, child) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Conexão SSH Perdida'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A conexão SSH foi perdida e a reconexão automática falhou.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (sshProvider.reconnectAttempts > 0)
                Text(
                  'Tentativas de reconexão: ${sshProvider.reconnectAttempts}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Escolha uma das opções abaixo:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            // Reconnect button
            TextButton.icon(
              onPressed: sshProvider.isReconnecting 
                  ? null 
                  : () => _handleReconnect(context, sshProvider),
              icon: sshProvider.isReconnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(sshProvider.isReconnecting ? 'Reconectando...' : 'Tentar Novamente'),
            ),
            
            // Go to login button
            TextButton.icon(
              onPressed: () => _handleGoToLogin(context, sshProvider),
              icon: const Icon(Icons.login),
              label: const Text('Ir para Login'),
            ),
            
            // Exit app button
            TextButton.icon(
              onPressed: () => _handleExitApp(context),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Sair da App'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle reconnection attempt
  Future<void> _handleReconnect(BuildContext context, SshProvider sshProvider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final success = await sshProvider.attemptManualReconnection();
      
      if (success) {
        navigator.pop(); // Close dialog
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Reconectado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Falha na reconexão. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro na reconexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle navigation to login screen
  void _handleGoToLogin(BuildContext context, SshProvider sshProvider) {
    sshProvider.resetReconnectionState();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Handle app exit
  void _handleExitApp(BuildContext context) {
    final navigator = Navigator.of(context);
    
    // Show confirmation dialog first
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // Exit the app
        navigator.pop(); // Close reconnection dialog
        navigator.pop(); // Go back to previous screen or exit
      }
    });
  }
}