# Fase 3: Interação com Ficheiros e Execução

## Issue 10: Execução de Scripts e Binários

### Metadados
- **Título**: [Fase 3.1] Implementação da Execução de Scripts e Binários
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #9 (issue anterior)

### Descrição

Implementar a funcionalidade para executar scripts e binários através de cliques nos ficheiros executáveis, exibindo a saída dos comandos de forma clara e intuitiva.

### Objetivos da Tarefa

Esta é a primeira tarefa da **Fase 3: Interação com Ficheiros e Execução**. O objetivo é dar vida aos botões, permitindo que o utilizador execute comandos remotos e visualize os resultados.

### Tarefas Específicas

#### 1. Criação do Widget ExecutionResultDialog
- [ ] Criar arquivo `lib/widgets/execution_result_dialog.dart`
- [ ] Dialog customizado para mostrar stdout e stderr
- [ ] Separação visual entre saída normal e erros
- [ ] Scroll para outputs longos
- [ ] Botões para copiar output ou fechar

#### 2. Criação da Tela Terminal (Opcional)
- [ ] Criar arquivo `lib/screens/terminal_screen.dart`
- [ ] Tela dedicada para outputs longos
- [ ] Interface tipo terminal com texto monospace
- [ ] Histórico de comandos executados
- [ ] Opção para executar novos comandos

#### 3. Extensão do SshProvider para Execução
- [ ] Método `Future<ExecutionResult> executeFile(SshFile file)`
- [ ] Classe ExecutionResult(stdout, stderr, exitCode, duration)
- [ ] Tratamento de timeouts para comandos longos
- [ ] Queue de execução para múltiplos comandos

#### 4. Integração com SshFileListTile
- [ ] Atualizar onTap para ficheiros executáveis
- [ ] Estados visuais durante execução
- [ ] Indicador de progresso (CircularProgressIndicator)
- [ ] Feedback imediato ao utilizador

#### 5. Tratamento de Diferentes Tipos de Executáveis
- [ ] Scripts shell (.sh, sem extensão com shebang)
- [ ] Binários nativos
- [ ] Scripts Python (.py)
- [ ] Scripts com argumentos opcionais
- [ ] Executáveis que requerem interação

### Critérios de Aceitação

- ✅ Clique em executável executa o ficheiro
- ✅ Output (stdout/stderr) é exibido claramente
- ✅ ExecutionResultDialog funcional e intuitivo
- ✅ Estados de loading durante execução
- ✅ Timeout configurável para comandos longos
- ✅ Tratamento de erros robusto

### Especificações Técnicas

```dart
class ExecutionResult {
  final String stdout;
  final String stderr;
  final int? exitCode;
  final Duration duration;
  final DateTime timestamp;
  
  ExecutionResult({
    required this.stdout,
    required this.stderr,
    this.exitCode,
    required this.duration,
    required this.timestamp,
  });
  
  bool get hasError => stderr.isNotEmpty || (exitCode != null && exitCode != 0);
  bool get isEmpty => stdout.isEmpty && stderr.isEmpty;
}
```

### Extensão do SshProvider

```dart
// Adicionar ao SshProvider
Future<ExecutionResult> executeFile(SshFile file) async {
  final startTime = DateTime.now();
  
  try {
    String command;
    if (file.type == FileType.executable) {
      command = '"${file.fullPath}"'; // Executar binário
    } else {
      // Detectar tipo de script e usar interpretador apropriado
      command = _buildScriptCommand(file);
    }
    
    final output = await executeCommand(command);
    
    return ExecutionResult(
      stdout: output,
      stderr: '', // Implementar captura separada de stderr
      exitCode: 0,
      duration: DateTime.now().difference(startTime),
      timestamp: startTime,
    );
  } catch (e) {
    return ExecutionResult(
      stdout: '',
      stderr: e.toString(),
      exitCode: -1,
      duration: DateTime.now().difference(startTime),
      timestamp: startTime,
    );
  }
}
```

### ExecutionResultDialog

```dart
class ExecutionResultDialog extends StatelessWidget {
  final ExecutionResult result;
  final String fileName;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Execução: $fileName'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.stdout.isNotEmpty) ...[
              Text('Saída:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    result.stdout,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
            if (result.stderr.isNotEmpty) ...[
              Divider(),
              Text('Erros:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    result.stderr,
                    style: TextStyle(fontFamily: 'monospace', color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _copyToClipboard(result.stdout),
          child: Text('Copiar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fechar'),
        ),
      ],
    );
  }
}
```

### Detecção de Tipo de Script
- Shebang (`#!/bin/bash`, `#!/usr/bin/python`, etc.)
- Extensão de ficheiro (.sh, .py, .pl, etc.)
- Permissões de execução
- Conteúdo do ficheiro (se necessário)

### Timeout e Performance
- Timeout padrão: 30 segundos
- Timeout configurável por tipo de comando
- Cancelamento de comandos longos
- Progress indicator para comandos que demoram

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #11: Visualizador de Ficheiros**.

---

## Issue 11: Visualizador de Ficheiros

### Metadados
- **Título**: [Fase 3.2] Implementação do Visualizador de Ficheiros
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #10 (issue anterior)

### Descrição

Implementar a funcionalidade para visualizar o conteúdo de ficheiros de texto e logs através de comandos como `cat` e `tail`, exibindo o conteúdo em uma interface de leitura adequada.

### Objetivos da Tarefa

Esta é a segunda tarefa da **Fase 3: Interação com Ficheiros e Execução**. O objetivo é permitir que o utilizador visualize facilmente o conteúdo de ficheiros de texto sem precisar de conhecimentos avançados de SSH.

### Tarefas Específicas

#### 1. Criação da Tela FileViewerScreen
- [ ] Criar arquivo `lib/screens/file_viewer_screen.dart`
- [ ] Tela dedicada para visualização de ficheiros
- [ ] AppBar com nome do ficheiro e ações
- [ ] ScrollView para conteúdo longo
- [ ] Texto monospace para preservar formatação

#### 2. Detecção de Tipos de Ficheiro
- [ ] Método para identificar ficheiros de texto
- [ ] Suporte para extensões comuns (.txt, .log, .conf, .json, etc.)
- [ ] Detecção de ficheiros binários (evitar visualização)
- [ ] Limite de tamanho para visualização
- [ ] Verificação de permissões de leitura

#### 3. Comandos de Visualização
- [ ] `cat` para ficheiros pequenos (< 1MB)
- [ ] `head -100` para começar de ficheiros grandes  
- [ ] `tail -100` para final de ficheiros grandes
- [ ] `tail -f` para logs em tempo real (opcional)
- [ ] Paginação para ficheiros muito grandes

#### 4. Interface de Visualização
- [ ] Barra de progresso para carregamento
- [ ] Indicador de ficheiro truncado
- [ ] Botões para carregar mais conteúdo
- [ ] Busca no texto (Ctrl+F like)
- [ ] Cópia de texto selecionado

#### 5. Extensão do SshProvider
- [ ] Método `Future<FileContent> readFile(SshFile file)`
- [ ] Classe FileContent para dados do ficheiro
- [ ] Cache de conteúdo para ficheiros recentemente visualizados
- [ ] Gestão de memória para ficheiros grandes

### Critérios de Aceitação

- ✅ Clique em ficheiro de texto abre FileViewerScreen
- ✅ Conteúdo é carregado e exibido corretamente
- ✅ Interface preserva formatação original
- ✅ Ficheiros grandes são tratados adequadamente
- ✅ Busca no texto funciona
- ✅ Copy/paste de conteúdo

### Especificações Técnicas

```dart
class FileContent {
  final String content;
  final bool isTruncated;
  final int totalLines;
  final int displayedLines;
  final FileViewMode mode;
  
  FileContent({
    required this.content,
    required this.isTruncated,
    required this.totalLines,
    required this.displayedLines,
    required this.mode,
  });
}

enum FileViewMode {
  full,      // Ficheiro completo
  head,      // Primeiras linhas
  tail,      // Últimas linhas
  truncated  // Ficheiro truncado por tamanho
}
```

### FileViewerScreen

```dart
class FileViewerScreen extends StatefulWidget {
  final SshFile file;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.displayName),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyAllContent,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(value: 'refresh', child: Text('Atualizar')),
              PopupMenuItem(value: 'head', child: Text('Ver início')),
              PopupMenuItem(value: 'tail', child: Text('Ver final')),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
```

### Detecção de Tipos de Ficheiro

```dart
bool _isTextFile(SshFile file) {
  final textExtensions = [
    '.txt', '.log', '.conf', '.cfg', '.ini', '.json', '.xml', '.yml', '.yaml',
    '.md', '.sh', '.py', '.js', '.css', '.html', '.sql', '.properties'
  ];
  
  // Verificar extensão
  for (String ext in textExtensions) {
    if (file.name.toLowerCase().endsWith(ext)) {
      return true;
    }
  }
  
  // Ficheiros sem extensão que podem ser texto
  final textFiles = ['README', 'LICENSE', 'CHANGELOG', 'Makefile'];
  if (textFiles.contains(file.name.toUpperCase())) {
    return true;
  }
  
  return false;
}
```

### Gestão de Ficheiros Grandes

```dart
Future<FileContent> readFile(SshFile file) async {
  try {
    // Verificar tamanho do ficheiro primeiro
    final sizeOutput = await executeCommand('stat -f%z "${file.fullPath}" 2>/dev/null || stat -c%s "${file.fullPath}"');
    final fileSize = int.tryParse(sizeOutput.trim()) ?? 0;
    
    if (fileSize > 1024 * 1024) { // > 1MB
      // Ficheiro grande - mostrar apenas parte
      return _readFilePart(file, FileViewMode.head);
    } else {
      // Ficheiro pequeno - ler completo
      final content = await executeCommand('cat "${file.fullPath}"');
      final lines = content.split('\n');
      
      return FileContent(
        content: content,
        isTruncated: false,
        totalLines: lines.length,
        displayedLines: lines.length,
        mode: FileViewMode.full,
      );
    }
  } catch (e) {
    throw Exception('Erro ao ler ficheiro: $e');
  }
}
```

### Interface de Busca
- Dialog com campo de texto para busca
- Highlight de resultados encontrados
- Navegação entre resultados (próximo/anterior)
- Case sensitive/insensitive toggle
- Regex support (opcional)

### Ações da AppBar
- **Buscar**: Abrir dialog de busca
- **Copiar**: Copiar todo o conteúdo
- **Atualizar**: Recarregar ficheiro
- **Ver início**: Carregar primeiras linhas
- **Ver final**: Carregar últimas linhas

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #12: Tratamento de Erros de Permissão**.

---

## Issue 12: Tratamento de Erros de Permissão

### Metadados
- **Título**: [Fase 3.3] Implementação do Tratamento de Erros de Permissão
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #11 (issue anterior)

### Descrição

Implementar um sistema robusto de tratamento de erros de permissão SSH, analisando stderr e proporcionando feedback claro ao utilizador sobre problemas de acesso.

### Objetivos da Tarefa

Esta é a terceira e última tarefa da **Fase 3: Interação com Ficheiros e Execução**. O objetivo é tornar a aplicação resiliente a erros de permissão e fornecer feedback útil ao utilizador.

### Tarefas Específicas

#### 1. Criação da Classe ErrorHandler
- [ ] Criar arquivo `lib/services/error_handler.dart`
- [ ] Análise de patterns de erro comuns
- [ ] Categorização de tipos de erro
- [ ] Métodos para gerar mensagens de erro amigáveis
- [ ] Sugestões de resolução quando possível

#### 2. Análise de stderr SSH
- [ ] Parser para "Permission denied"
- [ ] Parser para "No such file or directory"
- [ ] Parser para "Operation not permitted"
- [ ] Parser para "Access denied"
- [ ] Parser para timeouts e desconexões

#### 3. Widgets de Notificação de Erro
- [ ] SnackBar customizado para erros rápidos
- [ ] AlertDialog detalhado para erros complexos
- [ ] ErrorScreen para erros críticos
- [ ] Toast notifications para feedback não-intrusivo

#### 4. Integração com SshProvider
- [ ] Captura separada de stdout e stderr
- [ ] Análise automática de erros em todos os comandos
- [ ] Estados de erro específicos no Provider
- [ ] Recuperação automática quando possível

#### 5. Feedback Visual e Sonoro
- [ ] Ícones de erro diferenciados por tipo
- [ ] Cores apropriadas para severidade
- [ ] Som de alerta configurável (audioplayers)
- [ ] Animações de erro (shake, fade, etc.)

### Critérios de Aceitação

- ✅ Erros de permissão são detectados automaticamente
- ✅ Mensagens de erro são claras e úteis
- ✅ Diferentes tipos de erro têm tratamentos específicos
- ✅ Feedback visual e sonoro apropriado
- ✅ Utilizador sempre sabe o que aconteceu e porquê
- ✅ Recuperação graciosa de erros quando possível

### Especificações Técnicas

```dart
enum ErrorType {
  permissionDenied,
  fileNotFound,
  operationNotPermitted,
  accessDenied,
  connectionLost,
  timeout,
  commandNotFound,
  diskFull,
  unknown
}

class SshError {
  final ErrorType type;
  final String originalMessage;
  final String userFriendlyMessage;
  final String? suggestion;
  final ErrorSeverity severity;
  
  SshError({
    required this.type,
    required this.originalMessage,
    required this.userFriendlyMessage,
    this.suggestion,
    required this.severity,
  });
}

enum ErrorSeverity { info, warning, error, critical }
```

### ErrorHandler Service

```dart
class ErrorHandler {
  static final Map<RegExp, ErrorType> _errorPatterns = {
    RegExp(r'Permission denied'): ErrorType.permissionDenied,
    RegExp(r'No such file or directory'): ErrorType.fileNotFound,
    RegExp(r'Operation not permitted'): ErrorType.operationNotPermitted,
    RegExp(r'Access denied'): ErrorType.accessDenied,
    RegExp(r'Connection.*(lost|closed|refused)'): ErrorType.connectionLost,
    RegExp(r'Timeout|timed out'): ErrorType.timeout,
    RegExp(r'command not found'): ErrorType.commandNotFound,
    RegExp(r'No space left on device'): ErrorType.diskFull,
  };
  
  static SshError analyzeError(String stderr, String command) {
    for (var pattern in _errorPatterns.entries) {
      if (pattern.key.hasMatch(stderr)) {
        return _createErrorFromType(pattern.value, stderr, command);
      }
    }
    
    return SshError(
      type: ErrorType.unknown,
      originalMessage: stderr,
      userFriendlyMessage: 'Erro desconhecido ao executar comando',
      severity: ErrorSeverity.error,
    );
  }
  
  static SshError _createErrorFromType(ErrorType type, String stderr, String command) {
    switch (type) {
      case ErrorType.permissionDenied:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Sem permissão para executar esta ação',
          suggestion: 'Verifique se tem permissões de acesso ao ficheiro/diretório',
          severity: ErrorSeverity.warning,
        );
      // ... outros cases
    }
  }
}
```

### Integração com SshProvider

```dart
// Modificar executeCommand para capturar stderr separadamente
Future<String> executeCommand(String command) async {
  try {
    final session = await _client!.execute(command);
    
    final stdout = await session.stdout.transform(utf8.decoder).join();
    final stderr = await session.stderr.transform(utf8.decoder).join();
    
    if (stderr.isNotEmpty) {
      final error = ErrorHandler.analyzeError(stderr, command);
      _handleSshError(error);
    }
    
    return stdout;
  } catch (e) {
    final error = SshError(
      type: ErrorType.unknown,
      originalMessage: e.toString(),
      userFriendlyMessage: 'Erro de conexão SSH',
      severity: ErrorSeverity.critical,
    );
    _handleSshError(error);
    rethrow;
  }
}

void _handleSshError(SshError error) {
  _lastError = error;
  notifyListeners();
  
  // Log para debug
  print('SSH Error: ${error.type} - ${error.originalMessage}');
  
  // Tocar som de alerta se configurado
  if (_shouldPlayErrorSound(error.severity)) {
    _playErrorSound();
  }
}
```

### Widgets de Erro

```dart
class ErrorSnackBar {
  static void show(BuildContext context, SshError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(error.userFriendlyMessage)),
          ],
        ),
        backgroundColor: _getErrorColor(error.severity),
        duration: Duration(seconds: error.severity == ErrorSeverity.critical ? 10 : 4),
        action: error.suggestion != null
          ? SnackBarAction(
              label: 'AJUDA',
              onPressed: () => _showErrorDialog(context, error),
            )
          : null,
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final SshError error;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getErrorIcon(error.type)),
          SizedBox(width: 8),
          Text('Erro de Permissão'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage),
          if (error.suggestion != null) ...[
            SizedBox(height: 12),
            Text('Sugestão:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(error.suggestion!),
          ],
          SizedBox(height: 12),
          ExpansionTile(
            title: Text('Detalhes técnicos'),
            children: [
              SelectableText(error.originalMessage),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    );
  }
}
```

### Tipos de Erro e Mensagens

| Tipo de Erro | Mensagem para Utilizador | Sugestão |
|--------------|--------------------------|----------|
| Permission denied | Sem permissão para executar esta ação | Verifique se tem permissões de acesso |
| File not found | Ficheiro ou diretório não encontrado | Verifique se o caminho está correto |
| Operation not permitted | Operação não permitida pelo sistema | Contacte o administrador do sistema |
| Connection lost | Conexão SSH perdida | Verifique a conexão de rede |
| Timeout | Comando demorou muito tempo | Tente novamente ou use um comando mais simples |

### Som de Alerta
- Usar audioplayers para tocar som curto
- Configurável nas definições
- Diferentes sons para diferentes severidades
- Volume ajustável

### Próxima Fase
Após completar esta tarefa, a **Fase 3** estará completa. Prosseguir para a **Fase 4: UI/UX e Funcionalidades Adicionais** com a **Issue #13: Botão "Home" e Menu de Ferramentas**.