// Exemplo de integração da funcionalidade de reconexão SSH
// em uma nova tela do aplicativo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import '../services/error_handler.dart';
import '../widgets/reconnection_dialog.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  SshProvider? _lastSshProvider;
  bool _reconnectionDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupErrorListener();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupErrorListener();
  }

  @override
  void dispose() {
    _lastSshProvider?.removeListener(_handleProviderChange);
    super.dispose();
  }

  /// Setup listener for SSH connection changes
  void _setupErrorListener() {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    if (_lastSshProvider != sshProvider) {
      _lastSshProvider?.removeListener(_handleProviderChange);
      _lastSshProvider = sshProvider;
      sshProvider.addListener(_handleProviderChange);
    }
  }

  /// Handle SSH provider state changes
  void _handleProviderChange() {
    final sshProvider = _lastSshProvider;
    if (sshProvider == null || !mounted) return;

    // Check if we need to show reconnection dialog
    if (sshProvider.connectionState.hasError && 
        sshProvider.lastError?.type == ErrorType.connectionLost &&
        !sshProvider.isReconnecting &&
        !_reconnectionDialogShown) {
      
      _reconnectionDialogShown = true;
      
      // Show reconnection dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ReconnectionDialog.show(context).then((_) {
            _reconnectionDialogShown = false;
          });
        }
      });
      return;
    }

    // Reset dialog flag when connection is restored
    if (sshProvider.isConnected) {
      _reconnectionDialogShown = false;
    }

    // Handle other error types normally
    if (sshProvider.lastError != null && 
        sshProvider.lastError?.type != ErrorType.connectionLost) {
      _showErrorSnackBar(sshProvider.lastError!);
    }
  }

  /// Show error notification for non-connection-lost errors
  void _showErrorSnackBar(SshError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userFriendlyMessage),
        backgroundColor: Colors.red,
        action: error.suggestion != null
            ? SnackBarAction(
                label: 'Dica',
                textColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sugestão'),
                      content: Text(error.suggestion!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: Consumer<SshProvider>(
        builder: (context, sshProvider, child) {
          return Column(
            children: [
              // Connection status indicator
              Container(
                padding: const EdgeInsets.all(16),
                color: _getConnectionStatusColor(sshProvider),
                child: Row(
                  children: [
                    Icon(
                      _getConnectionStatusIcon(sshProvider),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getConnectionStatusText(sshProvider),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sshProvider.isReconnecting) ...[
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tentativa ${sshProvider.reconnectAttempts}/3',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Exemplo de tela com\nreconexão SSH automática',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      if (sshProvider.isConnected)
                        ElevatedButton(
                          onPressed: () => _simulateConnectionLoss(sshProvider),
                          child: const Text('Simular Perda de Conexão'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get connection status color
  Color _getConnectionStatusColor(SshProvider sshProvider) {
    if (sshProvider.isConnected) return Colors.green;
    if (sshProvider.isConnecting || sshProvider.isReconnecting) return Colors.orange;
    if (sshProvider.connectionState.hasError) return Colors.red;
    return Colors.grey;
  }

  /// Get connection status icon
  IconData _getConnectionStatusIcon(SshProvider sshProvider) {
    if (sshProvider.isConnected) return Icons.wifi;
    if (sshProvider.isConnecting || sshProvider.isReconnecting) return Icons.wifi_find;
    if (sshProvider.connectionState.hasError) return Icons.wifi_off;
    return Icons.wifi_off;
  }

  /// Get connection status text
  String _getConnectionStatusText(SshProvider sshProvider) {
    if (sshProvider.isReconnecting) return 'Reconectando...';
    return sshProvider.connectionState.description;
  }

  /// Simulate connection loss for testing
  void _simulateConnectionLoss(SshProvider sshProvider) {
    // This would normally be handled by the actual SSH operations
    // Here we just simulate it for demonstration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulação'),
        content: const Text(
          'Em uma situação real, a perda de conexão seria detectada '
          'automaticamente durante operações SSH (comandos, navegação, etc.)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}