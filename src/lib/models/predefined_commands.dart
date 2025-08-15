import 'package:flutter/material.dart';
import 'command_item.dart';

/// Contains all predefined commands organized by categories
class PredefinedCommands {
  static final Map<String, List<CommandItem>> commands = {
    'Informações': [
      CommandItem(
        'Sistema',
        'uname -a',
        Icons.desktop,
        'Informações do sistema operacional',
      ),
      CommandItem(
        'Usuário',
        'whoami',
        Icons.person,
        'Nome do usuário atual',
      ),
      CommandItem(
        'Diretório Atual',
        'pwd',
        Icons.folder,
        'Caminho do diretório atual',
      ),
      CommandItem(
        'Data/Hora',
        'date',
        Icons.access_time,
        'Data e hora atual do sistema',
      ),
      CommandItem(
        'Uptime',
        'uptime',
        Icons.trending_up,
        'Tempo de atividade do sistema',
      ),
    ],
    'Sistema': [
      CommandItem(
        'Espaço em Disco',
        'df -h',
        Icons.storage,
        'Uso do espaço em disco',
      ),
      CommandItem(
        'Tamanho Diretórios',
        'du -sh *',
        Icons.folder_open,
        'Tamanho dos diretórios',
      ),
      CommandItem(
        'Memória',
        'free -h',
        Icons.memory,
        'Uso da memória RAM',
      ),
      CommandItem(
        'Processos',
        'ps aux | head -20',
        Icons.checklist,
        'Lista de processos em execução',
      ),
      CommandItem(
        'Top Processos',
        'top -n 1 -b | head -20',
        Icons.speed,
        'Processos que mais consomem recursos',
      ),
    ],
    'Rede': [
      CommandItem(
        'Interfaces',
        'ip addr show',
        Icons.cable,
        'Interfaces de rede',
      ),
      CommandItem(
        'Rotas',
        'ip route show',
        Icons.route,
        'Tabela de rotas',
      ),
      CommandItem(
        'Conexões',
        'netstat -an | head -20',
        Icons.power,
        'Conexões de rede ativas',
      ),
      CommandItem(
        'Ping Google',
        'ping -c 4 8.8.8.8',
        Icons.satellite,
        'Teste de conectividade',
      ),
    ],
    'Logs': [
      CommandItem(
        'Syslog',
        'tail -20 /var/log/syslog',
        Icons.descriptionLines,
        'Últimas entradas do log do sistema',
      ),
      CommandItem(
        'Mensagens Kernel',
        'dmesg | tail -20',
        Icons.terminal,
        'Mensagens do kernel',
      ),
      CommandItem(
        'Auth Log',
        'tail -20 /var/log/auth.log',
        Icons.vpn_key,
        'Log de autenticações',
      ),
      CommandItem(
        'Últimos Logins',
        'last -10',
        Icons.rightToBracket,
        'Últimos logins no sistema',
      ),
    ],
  };

  /// Get all categories
  static List<String> get categories => commands.keys.toList();

  /// Get commands for a specific category
  static List<CommandItem> getCommandsForCategory(String category) {
    return commands[category] ?? [];
  }

  /// Get all commands as a flat list
  static List<CommandItem> get allCommands {
    return commands.values.expand((commands) => commands).toList();
  }

  /// Search commands by name or description
  static List<CommandItem> searchCommands(String query) {
    if (query.trim().isEmpty) return allCommands;

    final lowerQuery = query.toLowerCase();
    return allCommands.where((command) {
      return command.name.toLowerCase().contains(lowerQuery) ||
          command.command.toLowerCase().contains(lowerQuery) ||
          (command.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
