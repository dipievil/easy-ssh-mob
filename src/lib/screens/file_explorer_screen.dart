import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/ssh_provider.dart';
import '../models/ssh_file.dart';
import '../widgets/ssh_file_list_tile.dart';
import '../widgets/execution_result_dialog.dart';
import '../widgets/file_type_indicator.dart';
import '../widgets/error_widgets.dart';
import '../widgets/tools_drawer.dart';
import '../widgets/custom_components.dart';
import '../utils/custom_animations.dart';
import '../utils/responsive_breakpoints.dart';
import 'terminal_screen.dart';
import 'file_viewer_screen.dart';
import 'login_screen.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _isLoading = false;
  String _loadingFilePath = '';
  final Map<String, bool> _executingFiles = {};
  SshProvider? _lastSshProvider;

  @override
  void initState() {
    super.initState();
    _loadInitialDirectory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupErrorListener();
  }
  
  void _setupErrorListener() {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    if (_lastSshProvider != sshProvider) {
      _lastSshProvider?.removeListener(_handleProviderChange);
      _lastSshProvider = sshProvider;
      sshProvider.addListener(_handleProviderChange);
    }
  }
  
  void _handleProviderChange() {
    final sshProvider = _lastSshProvider;
    if (sshProvider?.lastError != null && mounted) {
      // Show error notification
      ErrorSnackBar.show(context, sshProvider!.lastError!);
    }
  }

  @override
  void dispose() {
    _lastSshProvider?.removeListener(_handleProviderChange);
    super.dispose();
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

    return ResponsiveContainer(
      child: RefreshIndicator(
        onRefresh: () => sshProvider.refreshCurrentDirectory(),
        child: ListView.builder(
          itemCount: totalItems,
          padding: ResponsiveBreakpoints.getScreenPadding(context),
          itemBuilder: (context, index) {
            // Show back button as first item if not at root
            if (hasBackButton && index == 0) {
              return _buildBackButton();
            }
            
            // Calculate file index
            final fileIndex = hasBackButton ? index - 1 : index;
            final file = sshProvider.currentFiles[fileIndex];
            
            return SlideInAnimation(
              delay: Duration(milliseconds: index * 50),
              child: SshCard(
                padding: const EdgeInsets.all(0),
                onTap: () => _handleFileTap(file),
                child: SshFileListTile(
                  file: file,
                  isLoading: _loadingFilePath == file.fullPath,
                  onTap: () => _handleFileTap(file),
                  onLongPress: () => _showFileOptions(context, file),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build the back button as a list item
  Widget _buildBackButton() {
    return SlideInAnimation(
      delay: Duration.zero,
      child: SshCard(
        padding: const EdgeInsets.all(0),
        onTap: () => _navigateToParent(),
        child: SshListTile(
          leading: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          title: const Text(
            '..',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Voltar'),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          onTap: () => _navigateToParent(),
          dense: true,
        ),
      ),
    );
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
      _showErrorMessage('Erro ao navegar para home: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isAtHome() {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    final currentPath = sshProvider.currentPath;
    final username = sshProvider.currentCredentials?.username;
    
    // Check if we're at root home directories
    if (currentPath == '/' || currentPath == '/home' || currentPath == '/root') {
      return true;
    }
    
    // Check if we're at user home directory
    if (username != null && currentPath == '/home/$username') {
      return true;
    }
    
    return false;
  }

  void _showTools() {
    // Open the drawer instead of showing a modal bottom sheet
    Scaffold.of(context).openEndDrawer();
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

  void _openFileViewer(SshFile file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(file: file),
      ),
    );
  }

  void _showFileInfo(SshFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${file.typeDescription}'),
            Text('Caminho: ${file.fullPath}'),
            const SizedBox(height: 8),
            const Text(
              'Este arquivo não pode ser executado ou visualizado diretamente.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build breadcrumb navigation for the AppBar
  Widget _buildBreadcrumb(String currentPath) {
    if (currentPath.isEmpty) {
      return const Text('Easy SSH');
    }

    // Split path into components
    final components = currentPath.split('/').where((c) => c.isNotEmpty).toList();
    
    if (components.isEmpty) {
      return GestureDetector(
        onTap: () => _navigateToDirectory('/'),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home, size: 18),
            SizedBox(width: 4),
            Text('/', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Home icon
          GestureDetector(
            onTap: () => _navigateToDirectory('/'),
            child: const Icon(Icons.home, size: 18),
          ),
          
          // Path components
          for (int i = 0; i < components.length; i++) ...[
            const Icon(Icons.chevron_right, size: 16),
            GestureDetector(
              onTap: () {
                final targetPath = '/${components.take(i + 1).join('/')}';
                _navigateToDirectory(targetPath);
              },
              child: Text(
                components[i],
                style: TextStyle(
                  fontWeight: i == components.length - 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build simple breadcrumb text for the AppBar title
  String _buildBreadcrumbText(String currentPath) {
    if (currentPath.isEmpty || currentPath == '/') {
      return 'EasySSH';
    }

    final components = currentPath.split('/').where((c) => c.isNotEmpty).toList();
    if (components.isEmpty) {
      return 'EasySSH';
    }

    // Show only the last two components to save space
    if (components.length <= 2) {
      return '/${components.join('/')}';
    } else {
      return '.../${components[components.length - 2]}/${components.last}';
    }
  }

  /// Show file options context menu
  void _showFileOptions(BuildContext context, SshFile file) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${file.typeDescription}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                'Caminho: ${file.fullPath}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Divider(height: 24),
              // Directory options
              if (file.isDirectory) ...[
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Abrir'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleFileTap(file);
                  },
                ),
              ],
              // Executable options
              if (file.isExecutable) ...[
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.green),
                  title: const Text('Executar'),
                  subtitle: const Text('(Disponível na Fase 3)'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Execução será implementada na Fase 3');
                  },
                ),
              ],
              // Regular file options
              if (file.isRegularFile) ...[
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Visualizar'),
                  subtitle: const Text('(Disponível na Fase 3)'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Visualização será implementada na Fase 3');
                  },
                ),
                if (_isScript(file)) ...[
                  ListTile(
                    leading: const Icon(Icons.code, color: Colors.orange),
                    title: const Text('Executar Script'),
                    subtitle: const Text('(Disponível na Fase 3)'),
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage('Execução de scripts será implementada na Fase 3');
                    },
                  ),
                ],
              ],
              // Symlink options
              if (file.isSymlink) ...[
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.purple),
                  title: const Text('Seguir Link'),
                  subtitle: const Text('(Disponível na Fase 3)'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Seguir links será implementado na Fase 3');
                  },
                ),
              ],
              // Common options for all files
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Propriedades'),
                subtitle: const Text('(Disponível na Fase 3)'),
                onTap: () {
                  Navigator.pop(context);
                  _showMessage('Propriedades serão implementadas na Fase 3');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Check if file is a script
  bool _isScript(SshFile file) {
    final scriptExtensions = ['.sh', '.py', '.js', '.rb', '.pl', '.php'];
    return scriptExtensions.any((ext) => file.name.toLowerCase().endsWith(ext));
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Handle file tap based on file type
  void _handleFileTap(SshFile file) {
    if (file.isDirectory) {
      _navigateToDirectory(file.fullPath);
    } else if (file.isTextFile) {
      _openFileViewer(file);
    } else if (file.isExecutable || file.mightBeExecutable) {
      _executeFile(file);
    } else {
      // Show info for non-executable, non-text files
      _showFileInfo(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SshProvider>(
      builder: (context, sshProvider, child) {
        return Scaffold(
          appBar: GradientAppBar(
            title: _buildBreadcrumbText(sshProvider.currentPath),
            actions: [
              // Back navigation button
              if (sshProvider.navigationHistory.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await sshProvider.navigateBack();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  icon: const Icon(FontAwesomeIcons.arrowLeft),
                  tooltip: 'Voltar',
                ),
              
              // Refresh button
              IconButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await sshProvider.refreshCurrentDirectory();
                  setState(() {
                    _isLoading = false;
                  });
                },
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(FontAwesomeIcons.arrowsRotate),
                tooltip: 'Atualizar',
              ),
              
              // Terminal button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRoute(
                      page: const TerminalScreen(),
                      direction: AxisDirection.left,
                    ),
                  );
                },
                icon: const Icon(FontAwesomeIcons.terminal),
                tooltip: 'Terminal',
              ),
            ],
          ),
      endDrawer: const ToolsDrawer(),
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
            return const ResponsiveContainer(
              child: SshLoadingIndicator(
                message: 'Carregando diretório...',
              ),
            );
          }

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
                      file.isTextFile
                          ? '${file.typeDescription} • Arquivo de texto'
                          : file.isExecutable || file.mightBeExecutable
                              ? '${file.typeDescription} • ${file.executionHint}'
                              : file.typeDescription,
                    ),
                    trailing: file.isDirectory 
                        ? const Icon(Icons.arrow_forward_ios)
                        : file.isTextFile
                            ? const Icon(Icons.description, color: Colors.blue)
                            : (file.isExecutable || file.mightBeExecutable)
                                ? Icon(
                                    Icons.play_arrow,
                                    color: isExecuting ? Colors.grey : Colors.green,
                                  )
                                : const Icon(Icons.info_outline, color: Colors.grey),
                    onTap: isExecuting
                        ? null // Disable tap while executing
                        : () => _handleFileTap(file),
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
      },
    );
  }
}