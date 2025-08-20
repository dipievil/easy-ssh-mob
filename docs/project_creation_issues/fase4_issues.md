# Fase 4: UI/UX e Funcionalidades Adicionais

## Issue 13: Botão "Home" e Menu de Ferramentas

### Metadados
- **Título**: [Fase 4.1] Implementação do Botão "Home" e Menu de Ferramentas
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #12 (issue anterior)

### Descrição

Implementar navegação rápida para o diretório home e criar um menu de ferramentas com comandos pré-definidos úteis para administração de sistemas via SSH.

### Objetivos da Tarefa

Esta é a primeira tarefa da **Fase 4: UI/UX e Funcionalidades Adicionais**. O objetivo é melhorar a experiência do utilizador com navegação rápida e acesso fácil a comandos comuns.

### Tarefas Específicas

#### 1. Implementação do Botão Home
- [ ] Adicionar IconButton na AppBar do FileExplorerScreen
- [ ] Ícone FontAwesome apropriado (home)
- [ ] Lógica para navegar para `$HOME` ou `~`
- [ ] Estado visual quando já estiver no home
- [ ] Tooltip explicativo

#### 2. Criação do Drawer de Ferramentas
- [ ] Implementar Drawer na FileExplorerScreen
- [ ] Header com informações da conexão
- [ ] Lista de comandos organizados por categoria
- [ ] Ícones apropriados para cada comando
- [ ] Estados de loading durante execução

#### 3. Comandos de Sistema Pré-definidos
- [ ] **Informações do Sistema**: `uname -a`, `whoami`, `pwd`
- [ ] **Espaço em Disco**: `df -h`, `du -sh *`
- [ ] **Processos**: `ps aux`, `top -n 1`
- [ ] **Rede**: `ifconfig`, `netstat -an`
- [ ] **Logs**: `tail /var/log/syslog`, `dmesg | tail`

#### 4. Categorização de Comandos
- [ ] Seção "Informações"
- [ ] Seção "Sistema"
- [ ] Seção "Rede"
- [ ] Seção "Logs"
- [ ] Seção "Personalizado" (comandos do utilizador)

#### 5. Gestão de Comandos Personalizados
- [ ] Permitir adicionar comandos favoritos
- [ ] Editar/remover comandos personalizados
- [ ] Armazenamento local de comandos personalizados
- [ ] Import/export de configurações

### Critérios de Aceitação

- ✅ Botão Home funciona e navega corretamente
- ✅ Drawer de ferramentas implementado e funcional
- ✅ Todos os comandos pré-definidos funcionam
- ✅ Comandos organizados por categoria
- ✅ Possível adicionar comandos personalizados
- ✅ Interface intuitiva e responsiva

### Especificações Técnicas

```dart
class ToolsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              children: [
                _buildCommandSection('Informações', _infoCommands),
                _buildCommandSection('Sistema', _systemCommands),
                _buildCommandSection('Rede', _networkCommands),
                _buildCommandSection('Logs', _logCommands),
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
```

### Comandos Pré-definidos

```dart
class PredefinedCommands {
  static final Map<String, List<CommandItem>> commands = {
    'Informações': [
      CommandItem('Sistema', 'uname -a', FontAwesomeIcons.desktop),
      CommandItem('Utilizador', 'whoami', FontAwesomeIcons.user),
      CommandItem('Diretório Atual', 'pwd', FontAwesomeIcons.folder),
      CommandItem('Data/Hora', 'date', FontAwesomeIcons.clock),
      CommandItem('Uptime', 'uptime', FontAwesomeIcons.chartLine),
    ],
    'Sistema': [
      CommandItem('Espaço em Disco', 'df -h', FontAwesomeIcons.hardDrive),
      CommandItem('Tamanho Diretórios', 'du -sh *', FontAwesomeIcons.folderOpen),
      CommandItem('Memória', 'free -h', FontAwesomeIcons.memory),
      CommandItem('Processos', 'ps aux | head -20', FontAwesomeIcons.tasks),
      CommandItem('Top Processos', 'top -n 1 -b | head -20', FontAwesomeIcons.tachometerAlt),
    ],
    'Rede': [
      CommandItem('Interfaces', 'ip addr show', FontAwesomeIcons.networkWired),
      CommandItem('Rotas', 'ip route show', FontAwesomeIcons.route),
      CommandItem('Conexões', 'netstat -an | head -20', FontAwesomeIcons.plug),
      CommandItem('Ping Google', 'ping -c 4 8.8.8.8', FontAwesomeIcons.satellite),
    ],
    'Logs': [
      CommandItem('Syslog', 'tail -20 /var/log/syslog', FontAwesomeIcons.fileAlt),
      CommandItem('Mensagens Kernel', 'dmesg | tail -20', FontAwesomeIcons.terminal),
      CommandItem('Auth Log', 'tail -20 /var/log/auth.log', FontAwesomeIcons.key),
      CommandItem('Últimos Logins', 'last -10', FontAwesomeIcons.signInAlt),
    ],
  };
}

class CommandItem {
  final String name;
  final String command;
  final IconData icon;
  final String? description;
  
  CommandItem(this.name, this.command, this.icon, [this.description]);
}
```

### AppBar com Botão Home

```dart
AppBar(
  title: Text(_currentPath),
  actions: [
    IconButton(
      icon: Icon(FontAwesomeIcons.home),
      tooltip: 'Ir para Home',
      onPressed: _isAtHome ? null : _navigateToHome,
    ),
    Builder(
      builder: (context) => IconButton(
        icon: Icon(FontAwesomeIcons.tools),
        tooltip: 'Ferramentas',
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      ),
    ),
  ],
)
```

### Drawer Header

```dart
Widget _buildHeader() {
  return Consumer<SshProvider>(
    builder: (context, sshProvider, child) {
      return UserAccountsDrawerHeader(
        accountName: Text(sshProvider.username ?? 'Utilizador'),
        accountEmail: Text('${sshProvider.host}:${sshProvider.port}'),
        currentAccountPicture: CircleAvatar(
          child: Icon(FontAwesomeIcons.server),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      );
    },
  );
}
```

### Execução de Comandos do Drawer

```dart
void _executeDrawerCommand(CommandItem command) async {
  Navigator.of(context).pop(); // Fechar drawer
  
  try {
    _showLoadingSnackBar('Executando: ${command.name}');
    
    final result = await Provider.of<SshProvider>(context, listen: false)
        .executeCommand(command.command);
    
    _showCommandResultDialog(command, result);
  } catch (e) {
    _showErrorSnackBar('Erro ao executar ${command.name}: $e');
  }
}
```

### Comandos Personalizados

```dart
class CustomCommandsService {
  static const String _storageKey = 'custom_commands';
  
  static Future<List<CommandItem>> loadCustomCommands() async {
    final storage = FlutterSecureStorage();
    final commandsJson = await storage.read(key: _storageKey);
    
    if (commandsJson == null) return [];
    
    final List<dynamic> commandsList = jsonDecode(commandsJson);
    return commandsList.map((json) => CommandItem.fromJson(json)).toList();
  }
  
  static Future<void> saveCustomCommands(List<CommandItem> commands) async {
    final storage = FlutterSecureStorage();
    final commandsJson = jsonEncode(commands.map((c) => c.toJson()).toList());
    await storage.write(key: _storageKey, value: commandsJson);
  }
  
  static Future<void> addCustomCommand(CommandItem command) async {
    final commands = await loadCustomCommands();
    commands.add(command);
    await saveCustomCommands(commands);
  }
}
```

### Dialog para Adicionar Comando Personalizado

```dart
class AddCustomCommandDialog extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Comando Personalizado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Nome'),
            controller: _nameController,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Comando'),
            controller: _commandController,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Descrição (opcional)'),
            controller: _descriptionController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCommand,
          child: Text('Adicionar'),
        ),
      ],
    );
  }
}
```

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #14: Sistema de Notificação de Erros**.

---

## Issue 14: Sistema de Notificação de Erros

### Metadados
- **Título**: [Fase 4.2] Implementação do Sistema de Notificação de Erros
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #13 (issue anterior)

### Descrição

Criar um sistema unificado e reutilizável de notificação de erros com alertas visuais e sonoros, proporcionando feedback consistente ao utilizador.

### Objetivos da Tarefa

Esta é a segunda tarefa da **Fase 4: UI/UX e Funcionalidades Adicionais**. O objetivo é centralizar e padronizar todas as notificações de erro da aplicação para melhorar a experiência do utilizador.

### Tarefas Específicas

#### 1. Criação do NotificationService
- [ ] Criar arquivo `lib/services/notification_service.dart`
- [ ] Singleton para gestão centralizada de notificações
- [ ] Queue de notificações para evitar sobreposição
- [ ] Configurações de duração e prioridade
- [ ] Integration com audioplayers para alertas sonoros

#### 2. Widgets de Notificação Reutilizáveis
- [ ] CustomSnackBar para notificações rápidas
- [ ] CustomDialog para erros detalhados
- [ ] ToastNotification para feedback não-intrusivo
- [ ] ErrorBanner para erros persistentes
- [ ] LoadingOverlay para operações longas

#### 3. Sistema de Sons de Alerta
- [ ] Adicionar dependência audioplayers
- [ ] Sons diferenciados por tipo de erro
- [ ] Volume configurável
- [ ] Opção para desabilitar sons
- [ ] Fallback para vibração em dispositivos móveis

#### 4. Tipos de Notificação
- [ ] Info (azul, som suave)
- [ ] Warning (laranja, som médio)
- [ ] Error (vermelho, som alto)
- [ ] Success (verde, som positivo)
- [ ] Critical (vermelho piscante, som urgente)

#### 5. Configurações do Utilizador
- [ ] Tela de configurações de notificações
- [ ] Toggle para habilitar/desabilitar sons
- [ ] Slider para volume de alertas
- [ ] Seleção de duração de notificações
- [ ] Tema de cores para daltonismo

### Critérios de Aceitação

- ✅ NotificationService centraliza todas as notificações
- ✅ Widgets de notificação são reutilizáveis e consistentes
- ✅ Sons de alerta funcionam apropriadamente
- ✅ Configurações de notificação são persistentes
- ✅ Interface é acessível e inclusiva
- ✅ Performance não é afetada por notificações

### Especificações Técnicas

```dart
enum NotificationType {
  info,
  warning,
  error,
  success,
  critical
}

class NotificationConfig {
  final NotificationType type;
  final Duration duration;
  final bool playSound;
  final bool vibrate;
  final bool persistent;
  
  const NotificationConfig({
    required this.type,
    this.duration = const Duration(seconds: 4),
    this.playSound = true,
    this.vibrate = false,
    this.persistent = false,
  });
}
```

### NotificationService

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Queue<NotificationItem> _notificationQueue = Queue();
  bool _isShowingNotification = false;
  
  // Configurações do utilizador
  bool soundEnabled = true;
  double soundVolume = 0.7;
  bool vibrateEnabled = true;
  
  Future<void> showNotification({
    required String message,
    required NotificationType type,
    String? title,
    String? details,
    VoidCallback? action,
    String? actionLabel,
    NotificationConfig? config,
  }) async {
    final item = NotificationItem(
      message: message,
      type: type,
      title: title,
      details: details,
      action: action,
      actionLabel: actionLabel,
      config: config ?? NotificationConfig(type: type),
    );
    
    _notificationQueue.add(item);
    _processQueue();
  }
  
  Future<void> _processQueue() async {
    if (_isShowingNotification || _notificationQueue.isEmpty) return;
    
    _isShowingNotification = true;
    final item = _notificationQueue.removeFirst();
    
    await _displayNotification(item);
    
    _isShowingNotification = false;
    
    // Processar próxima notificação
    if (_notificationQueue.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 500));
      _processQueue();
    }
  }
  
  Future<void> _displayNotification(NotificationItem item) async {
    // Tocar som se habilitado
    if (item.config.playSound && soundEnabled) {
      await _playNotificationSound(item.type);
    }
    
    // Vibrar se habilitado
    if (item.config.vibrate && vibrateEnabled) {
      await _vibrate();
    }
    
    // Mostrar notificação visual
    await _showVisualNotification(item);
  }
}
```

### Widgets de Notificação

```dart
class CustomSnackBar {
  static void show(
    BuildContext context,
    String message,
    NotificationType type, {
    VoidCallback? action,
    String? actionLabel,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getTypeIcon(type), color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _getTypeColor(type),
        duration: duration ?? Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: action,
            )
          : null,
      ),
    );
  }
}

class CustomErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            FontAwesomeIcons.exclamationTriangle,
            color: Colors.red,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            SizedBox(height: 16),
            ExpansionTile(
              title: Text('Detalhes técnicos'),
              children: [
                SelectableText(details!),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text('TENTAR NOVAMENTE'),
          ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    );
  }
}
```

### Sistema de Sons

```dart
class SoundManager {
  static const Map<NotificationType, String> _soundFiles = {
    NotificationType.info: 'assets/sounds/info.mp3',
    NotificationType.warning: 'assets/sounds/warning.mp3',
    NotificationType.error: 'assets/sounds/error.mp3',
    NotificationType.success: 'assets/sounds/success.mp3',
    NotificationType.critical: 'assets/sounds/critical.mp3',
  };
  
  static Future<void> playNotificationSound(
    NotificationType type,
    double volume,
  ) async {
    try {
      final soundFile = _soundFiles[type];
      if (soundFile != null) {
        final player = AudioPlayer();
        await player.setVolume(volume);
        await player.play(AssetSource(soundFile));
      }
    } catch (e) {
      print('Erro ao tocar som: $e');
    }
  }
}
```

### Configurações de Notificação

```dart
class NotificationSettingsScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações de Notificação')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text('Sons de Alerta'),
            subtitle: Text('Tocar sons para notificações'),
            value: _soundEnabled,
            onChanged: _toggleSound,
          ),
          if (_soundEnabled) ...[
            ListTile(
              title: Text('Volume dos Alertas'),
              subtitle: Slider(
                value: _soundVolume,
                onChanged: _setSoundVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(_soundVolume * 100).round()}%',
              ),
            ),
          ],
          SwitchListTile(
            title: Text('Vibração'),
            subtitle: Text('Vibrar para alertas importantes'),
            value: _vibrateEnabled,
            onChanged: _toggleVibrate,
          ),
          ListTile(
            title: Text('Testar Notificações'),
            subtitle: Text('Testar diferentes tipos de alerta'),
            trailing: Icon(Icons.play_arrow),
            onTap: _showTestNotifications,
          ),
        ],
      ),
    );
  }
}
```

### Integração com Aplicação

```dart
// Uso simplificado em qualquer lugar da app
NotificationService().showNotification(
  message: 'Comando executado com sucesso',
  type: NotificationType.success,
);

NotificationService().showNotification(
  message: 'Erro ao conectar ao servidor',
  type: NotificationType.error,
  title: 'Erro de Conexão',
  details: 'Timeout após 30 segundos...',
  action: () => _retry(),
  actionLabel: 'TENTAR NOVAMENTE',
);
```

### Cores e Ícones por Tipo

| Tipo | Cor | Ícone | Som |
|------|-----|-------|-----|
| Info | Azul | info-circle | Suave |
| Warning | Laranja | exclamation-triangle | Médio |
| Error | Vermelho | times-circle | Alto |
| Success | Verde | check-circle | Positivo |
| Critical | Vermelho intenso | exclamation | Urgente |

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #15: Design e Ícones**.

---

## Issue 15: Design e Ícones

### Metadados
- **Título**: [Fase 4.3] Implementação do Design e Sistema de Ícones
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #14 (issue anterior)

### Descrição

Implementar Material 3 design system e criar um sistema consistente de ícones usando font_awesome_flutter para diferenciar visualmente tipos de ficheiros e ações.

### Objetivos da Tarefa

Esta é a terceira e última tarefa da **Fase 4: UI/UX e Funcionalidades Adicionais**. O objetivo é elevar a qualidade visual da aplicação e proporcionar uma experiência moderna e intuitiva.

### Tarefas Específicas

#### 1. Configuração do Material 3
- [ ] Habilitar `useMaterial3: true` no ThemeData
- [ ] Configurar ColorScheme personalizado
- [ ] Implementar Dynamic Color (cores do sistema)
- [ ] Configurar Typography apropriada
- [ ] Definir formas e elevações consistentes

#### 2. Sistema de Ícones para Tipos de Ficheiro
- [ ] Mapeamento de extensões para ícones específicos
- [ ] Ícones FontAwesome para diferentes categorias
- [ ] Cores consistentes por tipo de ficheiro
- [ ] Tamanhos apropriados para diferentes contextos
- [ ] Fallback para tipos desconhecidos

#### 3. Paleta de Cores Temática
- [ ] Tema claro (light theme)
- [ ] Tema escuro (dark theme)
- [ ] Cores de estado (erro, sucesso, warning, info)
- [ ] Cores semânticas para tipos de ficheiro
- [ ] Suporte para daltonismo

#### 4. Componentes UI Personalizados
- [ ] Botões com design consistente
- [ ] Cards para agrupamento de informações
- [ ] AppBars com gradientes sutis
- [ ] Loading indicators temáticos
- [ ] Floating Action Buttons contextuais

#### 5. Animações e Transições
- [ ] Transições suaves entre telas
- [ ] Animações de carregamento
- [ ] Micro-interações (ripple effects, etc.)
- [ ] Animações de feedback para ações
- [ ] Page transitions customizadas

### Critérios de Aceitação

- ✅ Material 3 implementado e funcional
- ✅ Sistema de ícones consistente e intuitivo
- ✅ Temas claro e escuro funcionam perfeitamente
- ✅ Todos os tipos de ficheiro têm ícones apropriados
- ✅ Interface é moderna e responsiva
- ✅ Animações melhoram a experiência sem prejudicar performance

### Especificações Técnicas

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), // Material Blue
      brightness: Brightness.light,
    ),
    typography: Typography.material2021(),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.dark,
    ),
    typography: Typography.material2021(),
  );
}
```

### Sistema de Ícones para Ficheiros

```dart
class FileIconManager {
  static const Map<String, IconData> _extensionIcons = {
    // Documentos
    '.pdf': FontAwesomeIcons.filePdf,
    '.doc': FontAwesomeIcons.fileWord,
    '.docx': FontAwesomeIcons.fileWord,
    '.xls': FontAwesomeIcons.fileExcel,
    '.xlsx': FontAwesomeIcons.fileExcel,
    '.ppt': FontAwesomeIcons.filePowerpoint,
    '.pptx': FontAwesomeIcons.filePowerpoint,
    '.txt': FontAwesomeIcons.fileAlt,
    '.rtf': FontAwesomeIcons.fileAlt,
    
    // Código
    '.py': FontAwesomeIcons.python,
    '.js': FontAwesomeIcons.jsSquare,
    '.html': FontAwesomeIcons.html5,
    '.css': FontAwesomeIcons.css3Alt,
    '.java': FontAwesomeIcons.java,
    '.php': FontAwesomeIcons.php,
    '.cpp': FontAwesomeIcons.fileCode,
    '.c': FontAwesomeIcons.fileCode,
    '.sh': FontAwesomeIcons.terminal,
    '.sql': FontAwesomeIcons.database,
    '.json': FontAwesomeIcons.fileCode,
    '.xml': FontAwesomeIcons.fileCode,
    '.yaml': FontAwesomeIcons.fileCode,
    '.yml': FontAwesomeIcons.fileCode,
    
    // Imagens
    '.jpg': FontAwesomeIcons.fileImage,
    '.jpeg': FontAwesomeIcons.fileImage,
    '.png': FontAwesomeIcons.fileImage,
    '.gif': FontAwesomeIcons.fileImage,
    '.bmp': FontAwesomeIcons.fileImage,
    '.svg': FontAwesomeIcons.fileImage,
    '.webp': FontAwesomeIcons.fileImage,
    
    // Vídeo
    '.mp4': FontAwesomeIcons.fileVideo,
    '.avi': FontAwesomeIcons.fileVideo,
    '.mkv': FontAwesomeIcons.fileVideo,
    '.mov': FontAwesomeIcons.fileVideo,
    '.wmv': FontAwesomeIcons.fileVideo,
    '.flv': FontAwesomeIcons.fileVideo,
    
    // Áudio
    '.mp3': FontAwesomeIcons.fileAudio,
    '.wav': FontAwesomeIcons.fileAudio,
    '.flac': FontAwesomeIcons.fileAudio,
    '.ogg': FontAwesomeIcons.fileAudio,
    '.m4a': FontAwesomeIcons.fileAudio,
    
    // Arquivos
    '.zip': FontAwesomeIcons.fileArchive,
    '.rar': FontAwesomeIcons.fileArchive,
    '.tar': FontAwesomeIcons.fileArchive,
    '.gz': FontAwesomeIcons.fileArchive,
    '.7z': FontAwesomeIcons.fileArchive,
    '.bz2': FontAwesomeIcons.fileArchive,
    
    // Sistema
    '.log': FontAwesomeIcons.fileAlt,
    '.conf': FontAwesomeIcons.cog,
    '.cfg': FontAwesomeIcons.cog,
    '.ini': FontAwesomeIcons.cog,
    '.env': FontAwesomeIcons.cog,
  };
  
  static const Map<FileType, IconData> _typeIcons = {
    FileType.directory: FontAwesomeIcons.folder,
    FileType.executable: FontAwesomeIcons.terminal,
    FileType.symlink: FontAwesomeIcons.link,
    FileType.fifo: FontAwesomeIcons.exchangeAlt,
    FileType.socket: FontAwesomeIcons.plug,
    FileType.regular: FontAwesomeIcons.file,
    FileType.unknown: FontAwesomeIcons.question,
  };
  
  static IconData getIconForFile(SshFile file) {
    // Primeiro, verificar por tipo especial
    if (file.type != FileType.regular) {
      return _typeIcons[file.type] ?? FontAwesomeIcons.file;
    }
    
    // Depois, verificar por extensão
    final extension = _getFileExtension(file.name).toLowerCase();
    if (_extensionIcons.containsKey(extension)) {
      return _extensionIcons[extension]!;
    }
    
    // Verificar nomes especiais
    final specialFiles = {
      'README': FontAwesomeIcons.readme,
      'LICENSE': FontAwesomeIcons.certificate,
      'Makefile': FontAwesomeIcons.hammer,
      'Dockerfile': FontAwesomeIcons.docker,
      '.gitignore': FontAwesomeIcons.gitAlt,
    };
    
    if (specialFiles.containsKey(file.name.toUpperCase())) {
      return specialFiles[file.name.toUpperCase()]!;
    }
    
    // Fallback
    return FontAwesomeIcons.file;
  }
  
  static Color getColorForFile(SshFile file, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (file.type) {
      case FileType.directory:
        return colorScheme.primary;
      case FileType.executable:
        return Colors.green;
      case FileType.symlink:
        return Colors.purple;
      default:
        return _getColorByExtension(file.name, colorScheme);
    }
  }
}
```

### Cores por Categoria de Ficheiro

```dart
static Color _getColorByExtension(String fileName, ColorScheme colorScheme) {
  final extension = _getFileExtension(fileName).toLowerCase();
  
  // Cores categorizadas
  final Map<List<String>, Color> categoryColors = {
    // Código - Azul
    ['.py', '.js', '.html', '.css', '.java', '.php', '.cpp', '.c', '.sh']: Colors.blue,
    
    // Documentos - Cinza
    ['.pdf', '.doc', '.docx', '.txt', '.rtf']: Colors.blueGrey,
    
    // Planilhas - Verde
    ['.xls', '.xlsx', '.csv']: Colors.green,
    
    // Apresentações - Laranja
    ['.ppt', '.pptx']: Colors.orange,
    
    // Imagens - Rosa
    ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg']: Colors.pink,
    
    // Vídeo - Vermelho
    ['.mp4', '.avi', '.mkv', '.mov']: Colors.red,
    
    // Áudio - Púrpura
    ['.mp3', '.wav', '.flac', '.ogg']: Colors.purple,
    
    // Arquivos - Marrom
    ['.zip', '.rar', '.tar', '.gz', '.7z']: Colors.brown,
    
    // Configuração - Âmbar
    ['.conf', '.cfg', '.ini', '.env', '.json', '.xml', '.yaml']: Colors.amber,
    
    // Logs - Cinza escuro
    ['.log']: Colors.grey,
  };
  
  for (var category in categoryColors.entries) {
    if (category.key.contains(extension)) {
      return category.value;
    }
  }
  
  return colorScheme.onSurface.withOpacity(0.6);
}
```

### Componentes UI Customizados

```dart
class SshCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: AppBar(
        title: Text(title),
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
      ),
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
```

### Animações Customizadas

```dart
class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;
  
  SlideRoute({required this.page, this.direction = AxisDirection.left})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = _getOffset(direction);
            final tween = Tween(begin: offset, end: Offset.zero);
            final offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
  
  static Offset _getOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return Offset(0, 1);
      case AxisDirection.down:
        return Offset(0, -1);
      case AxisDirection.left:
        return Offset(1, 0);
      case AxisDirection.right:
        return Offset(-1, 0);
    }
  }
}
```

### Loading Indicators Temáticos

```dart
class SshLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? progress;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

### Responsividade e Adaptabilidade

```dart
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}
```

### Próxima Fase
Após completar esta tarefa, a **Fase 4** estará completa. Prosseguir para a **Fase 5: Logging e Finalização** com a **Issue #16: Logging da Sessão**.