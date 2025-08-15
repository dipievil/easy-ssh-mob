import 'package:flutter/material.dart';
import '../utils/icon_mapping.dart';
import '../models/command_item.dart';
import '../services/custom_commands_service.dart';

class AddCustomCommandDialog extends StatefulWidget {
  final CommandItem? editCommand;

  const AddCustomCommandDialog({super.key, this.editCommand});

  @override
  State<AddCustomCommandDialog> createState() => _AddCustomCommandDialogState();
}

class _AddCustomCommandDialogState extends State<AddCustomCommandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  final _descriptionController = TextEditingController();

  IconData _selectedIcon = Icons.terminal;
  bool _isLoading = false;

  // Common icons for commands
  final List<IconData> _availableIcons = [
    Icons.terminal,
    Icons.settings,
    Icons.play_arrow,
    Icons.stop,
    Icons.folder,
    Icons.description,
    Icons.download,
    Icons.upload,
    Icons.search,
    Icons.edit,
    Icons.delete,
    Icons.copy,
    Icons.cut,
    Icons.paste,
    Icons.save,
    Icons.print,
    Icons.visibility,
    Icons.storage,
    Icons.dns,
    Icons.cable,
    Icons.wifi,
    Icons.storage,
    Icons.memory,
    Icons.memory,
    Icons.speed,
    Icons.trending_up,
    Icons.list,
    Icons.checklist,
    Icons.access_time,
    Icons.calendar_today,
    Icons.person,
    Icons.persons,
    Icons.vpn_key,
    Icons.lock,
    Icons.lock_open,
    Icons.security,
    Icons.bug_report,
    Icons.build,
    Icons.build,
    Icons.build,
    Icons.buildWrench,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editCommand != null) {
      _nameController.text = widget.editCommand!.name;
      _commandController.text = widget.editCommand!.command;
      _descriptionController.text = widget.editCommand!.description ?? '';
      _selectedIcon = widget.editCommand!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCommand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final command = CommandItem(
        _nameController.text.trim(),
        _commandController.text.trim(),
        _selectedIcon,
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (widget.editCommand != null) {
        await CustomCommandsService.updateCustomCommand(
          widget.editCommand!,
          command,
        );
      } else {
        await CustomCommandsService.addCustomCommand(command);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editCommand != null
                  ? 'Comando atualizado com sucesso!'
                  : 'Comando adicionado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Ícone'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = icon == _selectedIcon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : null,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : null,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.editCommand != null
            ? 'Editar Comando'
            : 'Adicionar Comando Personalizado',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _showIconPicker,
                      icon: Icon(_selectedIcon),
                      tooltip: 'Escolher ícone',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Ex: Verificar Logs',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        if (value.trim().length < 2) {
                          return 'Nome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commandController,
                decoration: const InputDecoration(
                  labelText: 'Comando',
                  hintText: 'Ex: tail -f /var/log/syslog',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Comando é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Comando deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Ex: Monitora logs do sistema em tempo real',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCommand,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.editCommand != null ? 'Atualizar' : 'Adicionar'),
        ),
      ],
    );
  }
}
