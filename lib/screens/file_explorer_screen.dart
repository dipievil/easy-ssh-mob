import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import '../models/ssh_file.dart';
import '../models/execution_result.dart';
import '../widgets/execution_result_dialog.dart';
import '../widgets/file_type_indicator.dart';
import '../screens/terminal_screen.dart';
import 'login_screen.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _isLoading = false;
  final Map<String, bool> _executingFiles = {};

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
    
    try {
      // Use the new navigation system - home directory is loaded automatically after connection
      if (sshProvider.currentPath.isEmpty) {
        await sshProvider.navigateToHome();
      } else {
        await sshProvider.refreshCurrentDirectory();
      }
    } catch (e) {
      // Error handling is done by the provider
      print('Error loading directory: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goHome() async {
    setState(() {
      _isLoading = true;
    });
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    try {
      await sshProvider.navigateToHome();
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
              leading: const Icon(Icons.terminal),
              title: const Text('Terminal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TerminalScreen(),
                  ),
                );
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

  Future<void> _executeFile(SshFile file) async {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    // Mark file as executing
    setState(() {
      _executingFiles[file.fullPath] = true;
    });
    
    try {
      // Show immediate feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Executando ${file.name}...'),
          duration: const Duration(seconds: 1),
        ),
      );
      
      // Execute the file
      final result = await sshProvider.executeFile(file);
      
      // Show results in dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ExecutionResultDialog(
            result: result,
            fileName: file.name,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro ao executar ${file.name}: $e');
      }
    } finally {
      // Remove from executing list
      setState(() {
        _executingFiles.remove(file.fullPath);
      });
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SshProvider>(
          builder: (context, sshProvider, child) {
            return Text(sshProvider.currentPath.isNotEmpty 
                ? sshProvider.currentPath 
                : 'Easy SSH');
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Back navigation button
          Consumer<SshProvider>(
            builder: (context, sshProvider, child) {
              if (sshProvider.navigationHistory.isNotEmpty) {
                return IconButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await sshProvider.navigateBack();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Voltar',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Parent directory button
          Consumer<SshProvider>(
            builder: (context, sshProvider, child) {
              if (sshProvider.currentPath.isNotEmpty && sshProvider.currentPath != '/') {
                return IconButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await sshProvider.navigateToParent();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Diretório pai',
                );
              }
              return const SizedBox.shrink();
            },
          ),
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

          // Main content - show files list
          if (sshProvider.currentFiles.isNotEmpty) {
            return ListView.builder(
              itemCount: sshProvider.currentFiles.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final file = sshProvider.currentFiles[index];
                final isExecuting = _executingFiles[file.fullPath] == true;
                
                return Card(
                  child: ListTile(
                    leading: isExecuting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : FileTypeIndicator(
                            file: file,
                            showExecutionHint: true,
                          ),
                    title: Text(file.name),
                    subtitle: Text(
                      file.isExecutable || file.mightBeExecutable
                          ? '${file.typeDescription} • ${file.executionHint}'
                          : file.typeDescription,
                    ),
                    trailing: file.isDirectory 
                        ? const Icon(Icons.arrow_forward_ios)
                        : (file.isExecutable || file.mightBeExecutable)
                            ? Icon(
                                Icons.play_arrow,
                                color: isExecuting ? Colors.grey : Colors.green,
                              )
                            : null,
                    onTap: isExecuting
                        ? null // Disable tap while executing
                        : file.isDirectory 
                            ? () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await sshProvider.navigateToDirectory(file.fullPath);
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            : (file.isExecutable || file.mightBeExecutable)
                                ? () => _executeFile(file)
                                : null,
                  ),
                );
              },
            );
          }

          // Empty directory
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
                Consumer<SshProvider>(
                  builder: (context, sshProvider, child) {
                    return Text(
                      'Diretório: ${sshProvider.currentPath}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Diretório vazio',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Consumer<SshProvider>(
                  builder: (context, sshProvider, child) {
                    if (sshProvider.navigationHistory.isNotEmpty) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await sshProvider.navigateBack();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          final sshProvider = Provider.of<SshProvider>(context, listen: false);
          await sshProvider.refreshCurrentDirectory();
          setState(() {
            _isLoading = false;
          });
        },
        tooltip: 'Atualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}