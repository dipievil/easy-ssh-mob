import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ssh_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SshProvider(),
      child: MaterialApp(
        title: 'EasySSH',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: 'EasySSH - SSH Connection Manager'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commandController = TextEditingController();
  String _commandOutput = '';

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<SshProvider>(
        builder: (context, sshProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connection status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status da Conexão',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              sshProvider.isConnected
                                  ? Icons.cloud_done
                                  : sshProvider.isConnecting
                                      ? Icons.cloud_sync
                                      : Icons.cloud_off,
                              color: sshProvider.isConnected
                                  ? Colors.green
                                  : sshProvider.hasError
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(sshProvider.state.description),
                          ],
                        ),
                        if (sshProvider.hasError && sshProvider.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            sshProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        if (sshProvider.isConnected) ...[
                          const SizedBox(height: 8),
                          Text('Conectado em: ${sshProvider.currentHost}:${sshProvider.currentPort}'),
                          Text('Usuário: ${sshProvider.currentUsername}'),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Connection form
                if (!sshProvider.isConnected) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conexão SSH',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _hostController,
                            decoration: const InputDecoration(
                              labelText: 'Host',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _portController,
                            decoration: const InputDecoration(
                              labelText: 'Porta',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Usuário',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: sshProvider.isConnecting
                                  ? null
                                  : () async {
                                      final success = await sshProvider.connect(
                                        _hostController.text,
                                        _portController.text,
                                        _usernameController.text,
                                        _passwordController.text,
                                      );
                                      if (success) {
                                        _passwordController.clear();
                                      }
                                    },
                              child: sshProvider.isConnecting
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Conectando...'),
                                      ],
                                    )
                                  : const Text('Conectar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Command execution
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Executar Comando',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commandController,
                                  decoration: const InputDecoration(
                                    labelText: 'Comando',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _executeCommand(sshProvider),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _executeCommand(sshProvider),
                                child: const Text('Executar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => sshProvider.disconnect(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Desconectar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Command output
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saída do Comando',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _commandOutput.isEmpty 
                                        ? 'Nenhum comando executado ainda...' 
                                        : _commandOutput,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _executeCommand(SshProvider sshProvider) async {
    if (_commandController.text.trim().isEmpty) {
      return;
    }
    
    try {
      final output = await sshProvider.executeCommand(_commandController.text);
      setState(() {
        _commandOutput = '$ ${_commandController.text}\n$output\n\n$_commandOutput';
      });
      _commandController.clear();
    } catch (e) {
      setState(() {
        _commandOutput = '$ ${_commandController.text}\nERRO: $e\n\n$_commandOutput';
      });
    }
  }
}