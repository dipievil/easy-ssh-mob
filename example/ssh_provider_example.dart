import 'package:flutter/material.dart';
import '../lib/providers/ssh_provider.dart';
import '../lib/models/ssh_connection_state.dart';

/// Example demonstrating how to use SshProvider
/// 
/// This example shows the basic usage patterns for:
/// - Connecting to SSH server
/// - Executing commands
/// - Handling errors
/// - Managing connection state
void main() async {
  await sshProviderExample();
}

Future<void> sshProviderExample() async {
  print('=== SSH Provider Example ===');
  
  // Create provider instance
  final sshProvider = SshProvider();
  
  // Listen to state changes
  sshProvider.addListener(() {
    print('Estado mudou para: ${sshProvider.state.description}');
    if (sshProvider.hasError) {
      print('Erro: ${sshProvider.errorMessage}');
    }
  });
  
  try {
    print('\n1. Estado inicial:');
    print('   Estado: ${sshProvider.state.description}');
    print('   Conectado: ${sshProvider.isConnected}');
    
    print('\n2. Testando validação de parâmetros:');
    
    // Test empty host
    var result = await sshProvider.connect('', '22', 'user', 'pass');
    print('   Conexão com host vazio: $result');
    print('   Erro: ${sshProvider.errorMessage}');
    
    // Test invalid port
    result = await sshProvider.connect('localhost', 'invalid', 'user', 'pass');
    print('   Conexão com porta inválida: $result');
    print('   Erro: ${sshProvider.errorMessage}');
    
    // Test empty username
    result = await sshProvider.connect('localhost', '22', '', 'pass');
    print('   Conexão com usuário vazio: $result');
    print('   Erro: ${sshProvider.errorMessage}');
    
    // Test empty password
    result = await sshProvider.connect('localhost', '22', 'user', '');
    print('   Conexão com senha vazia: $result');
    print('   Erro: ${sshProvider.errorMessage}');
    
    print('\n3. Tentando conexão real (falhará sem servidor SSH):');
    result = await sshProvider.connect('localhost', '22', 'testuser', 'testpass');
    print('   Resultado da conexão: $result');
    if (sshProvider.hasError) {
      print('   Erro esperado: ${sshProvider.errorMessage}');
    }
    
    print('\n4. Testando execução de comando sem conexão:');
    try {
      await sshProvider.executeCommand('ls');
    } catch (e) {
      print('   Erro esperado: $e');
    }
    
    print('\n5. Testando desconexão:');
    await sshProvider.disconnect();
    print('   Estado após desconexão: ${sshProvider.state.description}');
    
    print('\n6. Propriedades do provider:');
    print('   Host atual: ${sshProvider.currentHost}');
    print('   Porta atual: ${sshProvider.currentPort}');
    print('   Usuário atual: ${sshProvider.currentUsername}');
    
  } finally {
    // Clean up
    sshProvider.dispose();
    print('\n=== Exemplo finalizado ===');
  }
}

/// Example showing state management patterns
class SshProviderWidget extends StatefulWidget {
  const SshProviderWidget({super.key});
  
  @override
  State<SshProviderWidget> createState() => _SshProviderWidgetState();
}

class _SshProviderWidgetState extends State<SshProviderWidget> {
  late SshProvider _sshProvider;
  
  @override
  void initState() {
    super.initState();
    _sshProvider = SshProvider();
    _sshProvider.addListener(_onStateChanged);
  }
  
  @override
  void dispose() {
    _sshProvider.removeListener(_onStateChanged);
    _sshProvider.dispose();
    super.dispose();
  }
  
  void _onStateChanged() {
    // React to state changes
    if (mounted) {
      setState(() {
        // Update UI based on new state
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Connection status indicator
        Container(
          padding: const EdgeInsets.all(8),
          color: _getStatusColor(),
          child: Text(
            'Status: ${_sshProvider.state.description}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        
        // Error display
        if (_sshProvider.hasError) 
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red,
            child: Text(
              'Erro: ${_sshProvider.errorMessage}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        
        // Connection info
        if (_sshProvider.isConnected) 
          Text('Conectado em: ${_sshProvider.currentHost}:${_sshProvider.currentPort}'),
        
        // Action buttons
        Row(
          children: [
            ElevatedButton(
              onPressed: _sshProvider.isConnecting ? null : _connect,
              child: _sshProvider.isConnecting 
                  ? const CircularProgressIndicator()
                  : const Text('Conectar'),
            ),
            ElevatedButton(
              onPressed: _sshProvider.isConnected ? _disconnect : null,
              child: const Text('Desconectar'),
            ),
          ],
        ),
      ],
    );
  }
  
  Color _getStatusColor() {
    switch (_sshProvider.state) {
      case SshConnectionState.connected:
        return Colors.green;
      case SshConnectionState.connecting:
        return Colors.orange;
      case SshConnectionState.error:
        return Colors.red;
      case SshConnectionState.disconnected:
        return Colors.grey;
    }
  }
  
  Future<void> _connect() async {
    await _sshProvider.connect('localhost', '22', 'user', 'pass');
  }
  
  Future<void> _disconnect() async {
    await _sshProvider.disconnect();
  }
}