import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ssh_file.dart';
import '../models/file_content.dart';
import '../providers/ssh_provider.dart';
import '../widgets/error_widgets.dart';

class FileViewerScreen extends StatefulWidget {
  final SshFile file;
  
  const FileViewerScreen({
    super.key,
    required this.file,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  FileContent? _fileContent;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  List<int> _searchMatches = [];
  int _currentMatchIndex = -1;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  SshProvider? _lastSshProvider;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
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
    _searchController.dispose();
    _scrollController.dispose();
    _lastSshProvider?.removeListener(_handleProviderChange);
    super.dispose();
  }

  Future<void> _loadFileContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sshProvider = Provider.of<SshProvider>(context, listen: false);
      final content = await sshProvider.readFile(widget.file);
      
      setState(() {
        _fileContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFileWithMode(FileViewMode mode) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sshProvider = Provider.of<SshProvider>(context, listen: false);
      final content = await sshProvider.readFileWithMode(widget.file, mode);
      
      setState(() {
        _fileContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar no Arquivo'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Digite o texto para buscar...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty || _fileContent == null) return;

    setState(() {
      _searchQuery = query;
      _searchMatches.clear();
      _currentMatchIndex = -1;
    });

    final content = _fileContent!.content.toLowerCase();
    final searchQuery = query.toLowerCase();
    int startIndex = 0;

    while (true) {
      final index = content.indexOf(searchQuery, startIndex);
      if (index == -1) break;
      
      _searchMatches.add(index);
      startIndex = index + 1;
    }

    if (_searchMatches.isNotEmpty) {
      setState(() {
        _currentMatchIndex = 0;
      });
      _scrollToMatch();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_searchMatches.length} resultados encontrados'),
          action: SnackBarAction(
            label: 'Próximo',
            onPressed: _nextMatch,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum resultado encontrado')),
      );
    }
  }

  void _nextMatch() {
    if (_searchMatches.isEmpty) return;
    
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _searchMatches.length;
    });
    _scrollToMatch();
  }

  void _previousMatch() {
    if (_searchMatches.isEmpty) return;
    
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _searchMatches.length) % _searchMatches.length;
    });
    _scrollToMatch();
  }

  void _scrollToMatch() {
    // Simple scroll to top for now - could be enhanced to scroll to specific line
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _copyAllContent() {
    if (_fileContent == null) return;
    
    Clipboard.setData(ClipboardData(text: _fileContent!.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conteúdo copiado para a área de transferência')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _loadFileContent();
        break;
      case 'head':
        _loadFileWithMode(FileViewMode.head);
        break;
      case 'tail':
        _loadFileWithMode(FileViewMode.tail);
        break;
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando arquivo...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
              'Erro ao Carregar Arquivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFileContent,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_fileContent == null) {
      return const Center(
        child: Text('Nenhum conteúdo disponível'),
      );
    }

    return Column(
      children: [
        // File info header
        if (_fileContent!.isTruncated)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_fileContent!.modeDescription} (${_fileContent!.fileSizeDescription})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        
        // Search results info
        if (_searchMatches.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Text('${_currentMatchIndex + 1} de ${_searchMatches.length} resultados'),
                const Spacer(),
                IconButton(
                  onPressed: _previousMatch,
                  icon: const Icon(Icons.keyboard_arrow_up),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: _nextMatch,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              _fileContent!.content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_searchMatches.isNotEmpty) ...[
            IconButton(
              onPressed: _previousMatch,
              icon: const Icon(Icons.keyboard_arrow_up),
              tooltip: 'Resultado anterior',
            ),
            IconButton(
              onPressed: _nextMatch,
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: 'Próximo resultado',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyAllContent,
            tooltip: 'Copiar tudo',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Atualizar'),
                ),
              ),
              const PopupMenuItem(
                value: 'head',
                child: ListTile(
                  leading: Icon(Icons.vertical_align_top),
                  title: Text('Ver início'),
                ),
              ),
              const PopupMenuItem(
                value: 'tail',
                child: ListTile(
                  leading: Icon(Icons.vertical_align_bottom),
                  title: Text('Ver final'),
                ),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}