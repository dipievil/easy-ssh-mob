import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'command_item.dart';

/// Contains all predefined commands organized by categories
class PredefinedCommands {
  static final Map<String, List<CommandItem>> commands = {
    'Informações': [
      CommandItem(
        'Sistema',
        'uname -a',
        FontAwesomeIcons.desktop,
        'Informações do sistema operacional',
      ),
      CommandItem(
        'Usuário',
        'whoami',
        FontAwesomeIcons.user,
        'Nome do usuário atual',
      ),
      CommandItem(
        'Diretório Atual',
        'pwd',
        FontAwesomeIcons.folder,
        'Caminho do diretório atual',
      ),
      CommandItem(
        'Data/Hora',
        'date',
        FontAwesomeIcons.clock,
        'Data e hora atual do sistema',
      ),
      CommandItem(
        'Uptime',
        'uptime',
        FontAwesomeIcons.chartLine,
        'Tempo de atividade do sistema',
      ),
    ],
    'Sistema': [
      CommandItem(
        'Espaço em Disco',
        'df -h',
        FontAwesomeIcons.hardDrive,
        'Uso do espaço em disco',
      ),
      CommandItem(
        'Tamanho Diretórios',
        'du -sh *',
        FontAwesomeIcons.folderOpen,
        'Tamanho dos diretórios',
      ),
      CommandItem(
        'Memória',
        'free -h',
        FontAwesomeIcons.memory,
        'Uso da memória RAM',
      ),
      CommandItem(
        'Processos',
        'ps aux | head -20',
        FontAwesomeIcons.listCheck,
        'Lista de processos em execução',
      ),
      CommandItem(
        'Top Processos',
        'top -n 1 -b | head -20',
        FontAwesomeIcons.gaugeHigh,
        'Processos que mais consomem recursos',
      ),
    ],
    'Rede': [
      CommandItem(
        'Interfaces',
        'ip addr show',
        FontAwesomeIcons.networkWired,
        'Interfaces de rede',
      ),
      CommandItem(
        'Rotas',
        'ip route show',
        FontAwesomeIcons.route,
        'Tabela de rotas',
      ),
      CommandItem(
        'Conexões',
        'netstat -an | head -20',
        FontAwesomeIcons.plug,
        'Conexões de rede ativas',
      ),
      CommandItem(
        'Ping Google',
        'ping -c 4 8.8.8.8',
        FontAwesomeIcons.satellite,
        'Teste de conectividade',
      ),
    ],
    'Logs': [
      CommandItem(
        'Syslog',
        'tail -20 /var/log/syslog',
        FontAwesomeIcons.fileLines,
        'Últimas entradas do log do sistema',
      ),
      CommandItem(
        'Mensagens Kernel',
        'dmesg | tail -20',
        FontAwesomeIcons.terminal,
        'Mensagens do kernel',
      ),
      CommandItem(
        'Auth Log',
        'tail -20 /var/log/auth.log',
        FontAwesomeIcons.key,
        'Log de autenticações',
      ),
      CommandItem(
        'Últimos Logins',
        'last -10',
        FontAwesomeIcons.rightToBracket,
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
