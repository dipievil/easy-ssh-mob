import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import '../models/ssh_file.dart';
import '../widgets/ssh_file_list_tile.dart';
import 'login_screen.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _isLoading = false;
  String _loadingFilePath = '';

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

  /// Build the file list with RefreshIndicator
  Widget _buildFileList() {
    final sshProvider = Provider.of<SshProvider>(context);
    
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
    
    if (sshProvider.currentFiles.isEmpty) {
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
              'Diretório: ${sshProvider.currentPath}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Diretório vazio',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (sshProvider.navigationHistory.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _navigateBack(sshProvider),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
          ],
        ),
      );
    }

    // Calculate total items: files + back button (if not root)
    final hasBackButton = sshProvider.currentPath != '/' && sshProvider.currentPath.isNotEmpty;
    final totalItems = sshProvider.currentFiles.length + (hasBackButton ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => sshProvider.refreshCurrentDirectory(),
      child: ListView.builder(
        itemCount: totalItems,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          // Show back button as first item if not at root
          if (hasBackButton && index == 0) {
            return _buildBackButton();
          }
          
          // Calculate file index
          final fileIndex = hasBackButton ? index - 1 : index;
          final file = sshProvider.currentFiles[fileIndex];
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: SshFileListTile(
              file: file,
              isLoading: _loadingFilePath == file.fullPath,
              onTap: () => _handleFileTap(file),
            ),
          );
        },
      ),
    );
  }

  /// Build the back button as a list item
  Widget _buildBackButton() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ListTile(
        leading: const Icon(
          Icons.arrow_back,
          color: Colors.blue,
          size: 20,
        ),
        title: const Text(
          '..',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Diretório pai',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () => _navigateToParent(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
      ),
    );
  }

  /// Handle file/directory tap
  Future<void> _handleFileTap(SshFile file) async {
    if (file.isDirectory) {
      await _navigateToDirectory(file.fullPath);
    } else {
      // For now, just show a message for non-directory files
      // This will be expanded in Phase 3
      _showMessage('Arquivo: ${file.name} (${file.typeDescription})');
    }
  }

  /// Navigate to directory with loading state
  Future<void> _navigateToDirectory(String path) async {
    setState(() {
      _loadingFilePath = path;
    });
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    try {
      await sshProvider.navigateToDirectory(path);
    } catch (e) {
      _showErrorMessage('Erro ao navegar: $e');
    } finally {
      setState(() {
        _loadingFilePath = '';
      });
    }
  }

  /// Navigate to parent directory
  Future<void> _navigateToParent() async {
    setState(() {
      _isLoading = true;
    });
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    try {
      await sshProvider.navigateToParent();
    } catch (e) {
      _showErrorMessage('Erro ao navegar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigate back in history
  Future<void> _navigateBack(SshProvider sshProvider) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await sshProvider.navigateBack();
    } catch (e) {
      _showErrorMessage('Erro ao voltar: $e');
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

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          return _buildFileList();
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