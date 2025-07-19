import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import 'login_screen.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  String _currentPath = '/';
  bool _isLoading = false;
  List<String> _navigationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadInitialDirectory();
  }

  Future<void> _loadInitialDirectory() async {
    setState(() {
      _isLoading = true;
    });
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    // Try to get home directory, fallback to root
    try {
      final homeResult = await sshProvider.executeCommand('pwd');
      if (homeResult != null && homeResult.trim().isNotEmpty) {
        setState(() {
          _currentPath = homeResult.trim();
        });
      }
    } catch (e) {
      // Log the error and show feedback to the user
      print('Error executing SSH command: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load initial directory.')),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _goHome() async {
    setState(() {
      _isLoading = true;
    });
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    try {
      // Get home directory
      final homeResult = await sshProvider.executeCommand('cd && pwd');
      if (homeResult != null && homeResult.trim().isNotEmpty) {
        _navigationHistory.add(_currentPath);
        setState(() {
          _currentPath = homeResult.trim();
        });
      } else {
        _showErrorMessage('Failed to retrieve home directory.');
      }
    } catch (e) {
      _showErrorMessage('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTools() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ferramentas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Atualizar'),
              onTap: () {
                Navigator.pop(context);
                _loadInitialDirectory();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Deseja desconectar e esquecer as credenciais salvas?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Logout sem esquecer'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Logout e esquecer'),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      final sshProvider = Provider.of<SshProvider>(context, listen: false);
      await sshProvider.logout(forgetCredentials: result);
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _goHome,
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
          IconButton(
            onPressed: _showTools,
            icon: const Icon(Icons.settings),
            tooltip: 'Ferramentas',
          ),
          // Connection status indicator
          Consumer<SshProvider>(
            builder: (context, sshProvider, child) {
              if (sshProvider.isConnected) {
                return const Icon(
                  Icons.wifi,
                  color: Colors.green,
                );
              } else if (sshProvider.isConnecting) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              } else {
                return const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<SshProvider>(
        builder: (context, sshProvider, child) {
          // Handle connection errors
          if (sshProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro de Conexão',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sshProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      sshProvider.clearError();
                      _loadInitialDirectory();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          // Handle disconnection
          if (!sshProvider.isConnected && !sshProvider.isConnecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Desconectado',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A conexão SSH foi perdida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Loading state
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando diretório...'),
                ],
              ),
            );
          }

          // Main content - placeholder for file list (to be implemented in next phase)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Diretório: $_currentPath',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A lista de ficheiros será implementada na próxima fase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (_navigationHistory.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_navigationHistory.isNotEmpty) {
                        setState(() {
                          _currentPath = _navigationHistory.removeLast();
                        });
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadInitialDirectory,
        tooltip: 'Atualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}