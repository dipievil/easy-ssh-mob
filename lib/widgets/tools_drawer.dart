import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/command_item.dart';
import '../models/predefined_commands.dart';
import '../providers/ssh_provider.dart';
import '../services/custom_commands_service.dart';
import '../screens/session_log_screen.dart';
import 'add_custom_command_dialog.dart';

class ToolsDrawer extends StatefulWidget {
  const ToolsDrawer({super.key});

  @override
  State<ToolsDrawer> createState() => _ToolsDrawerState();
}

class _ToolsDrawerState extends State<ToolsDrawer> {
  List<CommandItem> _customCommands = [];
  bool _isLoadingCustomCommands = false;

  @override
  void initState() {
    super.initState();
    _loadCustomCommands();
  }

  Future<void> _loadCustomCommands() async {
    setState(() {
      _isLoadingCustomCommands = true;
    });
    
    try {
      final commands = await CustomCommandsService.loadCustomCommands();
      setState(() {
        _customCommands = commands;
      });
    } catch (e) {
      debugPrint('Error loading custom commands: $e');
    } finally {
      setState(() {
        _isLoadingCustomCommands = false;
      });
    }
  }

  Widget _buildHeader() {
    return Consumer<SshProvider>(
      builder: (context, sshProvider, child) {
        return UserAccountsDrawerHeader(
          accountName: Text(sshProvider.currentCredentials?.username ?? 'Utilizador'),
          accountEmail: Text('${sshProvider.currentCredentials?.host ?? 'localhost'}:${sshProvider.currentCredentials?.port ?? 22}'),
          currentAccountPicture: const CircleAvatar(
            child: Icon(FontAwesomeIcons.server),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildSessionSection() {
    return Consumer<SshProvider>(
      builder: (context, sshProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
                child: const Text(
                  'Sessão',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.history, size: 20, color: Colors.blue),
                title: const Text('Histórico de Comandos'),
                subtitle: Text(
                  '${sshProvider.sessionLog.length} comandos registados',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: () {
                  Navigator.of(context).pop(); // Close drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SessionLogScreen(),
                    ),
                  );
                },
              ),
              if (sshProvider.sessionStartTime != null)
                ListTile(
                  leading: const Icon(FontAwesomeIcons.clock, size: 20, color: Colors.green),
                  title: const Text('Tempo de Sessão'),
                  subtitle: Text(
                    _formatSessionDuration(DateTime.now().difference(sshProvider.sessionStartTime!)),
                    style: const TextStyle(fontSize: 12),
                  ),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatSessionDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildCommandSection(String title, List<CommandItem> commands) {
    if (commands.isEmpty && title != 'Personalizado') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (title == 'Personalizado') ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.plus, size: 16),
                  onPressed: _addCustomCommand,
                  tooltip: 'Adicionar comando',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ],
          ),
        ),
        if (title == 'Personalizado' && _isLoadingCustomCommands)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (title == 'Personalizado' && commands.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(FontAwesomeIcons.plus, color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Nenhum comando personalizado',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addCustomCommand,
                  icon: const Icon(FontAwesomeIcons.plus, size: 16),
                  label: const Text('Adicionar comando'),
                ),
              ],
            ),
          )
        else
          ...commands.map((command) => _buildCommandTile(command, isCustom: title == 'Personalizado')),
      ],
    );
  }

  Widget _buildCommandTile(CommandItem command, {bool isCustom = false}) {
    return ListTile(
      leading: Icon(command.icon, size: 20),
      title: Text(command.name),
      subtitle: command.description != null 
          ? Text(
              command.description!,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isCustom 
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editCustomCommand(command);
                    break;
                  case 'delete':
                    _deleteCustomCommand(command);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.edit, size: 16),
                      SizedBox(width: 8),
                      const Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.trash, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )
          : const Icon(Icons.arrow_forward_ios, size: 12),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => _executeCommand(command),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportCommands,
                  icon: const Icon(FontAwesomeIcons.download, size: 16),
                  label: const Text('Exportar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importCommands,
                  icon: const Icon(FontAwesomeIcons.upload, size: 16),
                  label: const Text('Importar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Easy SSH Mob v1.0.0',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeCommand(CommandItem command) async {
    Navigator.of(context).pop(); // Close drawer
    
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    if (!sshProvider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Não conectado ao servidor SSH'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text('Executando: ${command.name}...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final result = await sshProvider.executeCommandWithResult(command.command);
      
      if (result != null && mounted) {
        _showCommandResultDialog(command, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao executar ${command.name}: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showCommandResultDialog(CommandItem command, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(command.icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                command.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: SelectableText(
              result.isEmpty ? 'Comando executado sem saída' : result,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Copy to clipboard functionality would go here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resultado copiado para a área de transferência')),
              );
            },
            icon: const Icon(FontAwesomeIcons.copy, size: 16),
            label: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomCommand() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddCustomCommandDialog(),
    );
    
    if (result == true) {
      _loadCustomCommands();
    }
  }

  Future<void> _editCustomCommand(CommandItem command) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddCustomCommandDialog(editCommand: command),
    );
    
    if (result == true) {
      _loadCustomCommands();
    }
  }

  Future<void> _deleteCustomCommand(CommandItem command) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o comando "${command.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CustomCommandsService.removeCustomCommand(command);
        _loadCustomCommands();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Comando excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir comando: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportCommands() async {
    Navigator.of(context).pop(); // Close drawer
    
    try {
      final exported = await CustomCommandsService.exportCustomCommands();
      // In a real app, you would use a file picker or share dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comandos exportados (funcionalidade de arquivo em desenvolvimento)'),
          action: SnackBarAction(
            label: 'Ver JSON',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Comandos Exportados'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: SingleChildScrollView(
                      child: SelectableText(exported),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importCommands() async {
    Navigator.of(context).pop(); // Close drawer
    
    // In a real app, you would use a file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('Funcionalidade de importação de arquivo em desenvolvimento'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSessionSection(),
                _buildCommandSection('Informações', PredefinedCommands.getCommandsForCategory('Informações')),
                _buildCommandSection('Sistema', PredefinedCommands.getCommandsForCategory('Sistema')),
                _buildCommandSection('Rede', PredefinedCommands.getCommandsForCategory('Rede')),
                _buildCommandSection('Logs', PredefinedCommands.getCommandsForCategory('Logs')),
                _buildCommandSection('Personalizado', _customCommands),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }
}