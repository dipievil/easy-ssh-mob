import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../providers/ssh_provider.dart';
import '../widgets/log_entry_tile.dart';
import '../services/notification_service.dart';

/// Screen for viewing SSH session log history
class SessionLogScreen extends StatefulWidget {
  const SessionLogScreen({Key? key}) : super(key: key);

  @override
  State<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends State<SessionLogScreen> {
  String _searchTerm = '';
  CommandType? _filterType;
  CommandStatus? _filterStatus;
  bool _showFilters = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico da Sessão'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Buscar comandos',
          ),
          IconButton(
            icon: Icon(
              _showFilters ? FontAwesomeIcons.filterCircleXmark : FontAwesomeIcons.filter,
            ),
            onPressed: _toggleFilters,
            tooltip: 'Filtros',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.chartBar),
                  title: Text('Estatísticas'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'save_txt',
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.fileAlt),
                  title: Text('Salvar como TXT'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'save_json',
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.fileCode),
                  title: Text('Salvar como JSON'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'save_csv',
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.fileCsv),
                  title: Text('Salvar como CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.trash, color: Colors.red),
                  title: Text('Limpar Histórico', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterBar(),
          Expanded(child: _buildLogList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveLogToServer,
        tooltip: 'Salvar log no servidor',
        child: const Icon(FontAwesomeIcons.save),
      ),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<CommandType?>(
              value: _filterType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<CommandType?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...CommandType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(_formatCommandType(type)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _filterType = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<CommandStatus?>(
              value: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<CommandStatus?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...CommandStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_formatStatus(status)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.filterCircleXmark),
            onPressed: _clearFilters,
            tooltip: 'Limpar filtros',
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogList() {
    return Consumer<SshProvider>(
      builder: (context, sshProvider, child) {
        final filteredLog = sshProvider.filterSessionLog(
          type: _filterType,
          status: _filterStatus,
          searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
        );
        
        if (filteredLog.isEmpty && sshProvider.sessionLog.isEmpty) {
          return _buildEmptyState('Nenhum comando foi executado ainda');
        }
        
        if (filteredLog.isEmpty && sshProvider.sessionLog.isNotEmpty) {
          return _buildEmptyState('Nenhum comando corresponde aos filtros');
        }
        
        return ListView.builder(
          reverse: true, // Mais recentes primeiro
          itemCount: filteredLog.length,
          itemBuilder: (context, index) {
            final entry = filteredLog[filteredLog.length - 1 - index];
            return LogEntryTile(
              entry: entry,
              onTap: () => _showLogDetails(entry),
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_searchTerm.isNotEmpty || _filterType != null || _filterStatus != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Comandos'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Digite o termo de busca...',
            prefixIcon: Icon(FontAwesomeIcons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
          onSubmitted: (_) => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchTerm = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
  
  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }
  
  void _clearFilters() {
    setState(() {
      _searchTerm = '';
      _filterType = null;
      _filterStatus = null;
    });
  }
  
  void _showLogDetails(LogEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Comando'),
        content: SizedBox(
          width: double.maxFinite,
          child: LogEntryTile(
            entry: entry,
            showDetails: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'stats':
        _showSessionStats();
        break;
      case 'save_txt':
        _saveLogToServer(format: 'txt');
        break;
      case 'save_json':
        _saveLogToServer(format: 'json');
        break;
      case 'save_csv':
        _saveLogToServer(format: 'csv');
        break;
      case 'clear':
        _confirmClearHistory();
        break;
    }
  }
  
  void _showSessionStats() {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    final stats = sshProvider.getSessionStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas da Sessão'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total de comandos', '${stats['totalCommands']}'),
              _buildStatRow('Comandos bem-sucedidos', '${stats['successfulCommands']}'),
              _buildStatRow('Comandos com erro', '${stats['failedCommands']}'),
              _buildStatRow('Taxa de sucesso', '${(stats['successRate'] * 100).toStringAsFixed(1)}%'),
              _buildStatRow('Duração total', _formatDuration(stats['totalDuration'])),
              _buildStatRow('Duração da sessão', _formatDuration(stats['sessionDuration'])),
              
              const SizedBox(height: 16),
              const Text('Comandos por tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...((stats['commandsByType'] as Map<String, int>).entries.map(
                (entry) => _buildStatRow('  ${entry.key}', '${entry.value}'),
              )),
              
              const SizedBox(height: 16),
              const Text('Comandos mais usados:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...((stats['mostUsedCommands'] as List<String>).asMap().entries.map(
                (entry) => _buildStatRow('  ${entry.key + 1}. ${entry.value}', ''),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Tem certeza que deseja limpar todo o histórico de comandos? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<SshProvider>(context, listen: false).clearSessionLog();
              Navigator.pop(context);
              _showNotification('Histórico limpo com sucesso', NotificationType.info);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveLogToServer({String format = 'txt'}) async {
    try {
      final sshProvider = Provider.of<SshProvider>(context, listen: false);
      
      if (!sshProvider.isConnected) {
        _showNotification('Não conectado ao servidor SSH', NotificationType.error);
        return;
      }
      
      if (sshProvider.sessionLog.isEmpty) {
        _showNotification('Nenhum comando para salvar', NotificationType.warning);
        return;
      }
      
      final content = sshProvider.exportSessionLog(format: format);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'easyssh_log_$timestamp.$format';
      
      // Create temporary file content
      final tempCommand = '''
cat > /tmp/$fileName << 'EOF'
$content
EOF
      ''';
      
      await sshProvider.executeCommand(tempCommand);
      
      _showNotification(
        'Log salvo como /tmp/$fileName',
        NotificationType.success,
      );
    } catch (e) {
      _showNotification(
        'Erro ao salvar log: $e',
        NotificationType.error,
      );
    }
  }
  
  void _showNotification(String message, NotificationType type) {
    NotificationService().showNotification(
      message: message,
      type: type,
    );
  }
  
  String _formatCommandType(CommandType type) {
    switch (type) {
      case CommandType.navigation:
        return 'Navegação';
      case CommandType.execution:
        return 'Execução';
      case CommandType.fileView:
        return 'Visualização';
      case CommandType.system:
        return 'Sistema';
      case CommandType.custom:
        return 'Customizado';
      case CommandType.unknown:
        return 'Desconhecido';
    }
  }
  
  String _formatStatus(CommandStatus status) {
    switch (status) {
      case CommandStatus.success:
        return 'Sucesso';
      case CommandStatus.error:
        return 'Erro';
      case CommandStatus.timeout:
        return 'Timeout';
      case CommandStatus.cancelled:
        return 'Cancelado';
      case CommandStatus.partial:
        return 'Parcial';
    }
  }
}