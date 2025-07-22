# Sistema de Logging da Sessão SSH

Este documento descreve o sistema de logging implementado na **Fase 5.1** do projeto Easy SSH Mob.

## Visão Geral

O sistema de logging captura automaticamente todos os comandos executados durante uma sessão SSH, proporcionando auditoria completa, estatísticas detalhadas e funcionalidades de exportação.

## Funcionalidades Principais

### 1. Logging Automático
- **Captura automática**: Todos os comandos SSH são automaticamente registados
- **Categorização inteligente**: Comandos são classificados por tipo (navegação, execução, visualização, sistema)
- **Detalhes completos**: Timestamp, duração, saída (stdout/stderr), código de saída
- **Status de execução**: Sucesso, erro, timeout, cancelado, parcial

### 2. Interface de Visualização
- **Tela dedicada**: SessionLogScreen acessível pelo menu lateral
- **Lista cronológica**: Comandos mais recentes aparecem primeiro
- **Visualização compacta**: Preview de comandos com informações essenciais
- **Expansão de detalhes**: Clique para ver stdout/stderr completos

### 3. Filtros e Busca
- **Filtro por tipo**: Navegação, execução, visualização, sistema, customizado
- **Filtro por status**: Sucesso, erro, timeout, cancelado, parcial
- **Busca textual**: Procurar em comandos, stdout ou stderr
- **Filtros combinados**: Múltiplos filtros podem ser aplicados simultaneamente

### 4. Estatísticas da Sessão
- **Métricas básicas**: Total de comandos, sucessos, falhas
- **Taxa de sucesso**: Percentual de comandos bem-sucedidos
- **Duração**: Tempo total de execução e duração da sessão
- **Distribuição por tipo**: Quantos comandos de cada categoria
- **Comandos populares**: Lista dos 5 comandos mais utilizados

### 5. Exportação de Logs
- **Múltiplos formatos**: TXT (legível), JSON (estruturado), CSV (planilha)
- **Salvar no servidor**: Logs são salvos diretamente no servidor SSH
- **Localização**: Arquivos salvos em `/tmp/` com timestamp único
- **Confirmações**: Notificações de sucesso/erro da operação

## Como Usar

### Acesso ao Histórico
1. Conecte-se a um servidor SSH
2. Execute alguns comandos (ls, pwd, cat, etc.)
3. Abra o menu lateral (drawer)
4. Na seção "Sessão", clique em "Histórico de Comandos"

### Visualização e Filtros
1. Na tela de histórico, veja a lista de comandos executados
2. Use o ícone 🔍 para buscar por termos específicos
3. Use o ícone 🔧 para abrir filtros por tipo e status
4. Clique em qualquer comando para ver detalhes completos

### Estatísticas
1. Na tela de histórico, clique no menu ⋮ (três pontos)
2. Selecione "Estatísticas"
3. Veja métricas detalhadas da sua sessão

### Exportação
1. Na tela de histórico, clique no botão flutuante 💾
2. Ou use o menu ⋮ e selecione o formato desejado
3. O arquivo será salvo no servidor em `/tmp/`

## Estrutura Técnica

### Modelos de Dados

```dart
enum CommandType {
  navigation,    // cd, ls, pwd
  execution,     // Scripts, binários
  fileView,      // cat, tail, head
  system,        // ps, df, uname
  custom,        // Comandos do drawer
  unknown
}

enum CommandStatus {
  success,
  error,
  timeout,
  cancelled,
  partial
}

class LogEntry {
  final String id;
  final DateTime timestamp;
  final String command;
  final CommandType type;
  final String workingDirectory;
  final String stdout;
  final String stderr;
  final int? exitCode;
  final Duration duration;
  final CommandStatus status;
  final Map<String, dynamic>? metadata;
}
```

### Integração com SshProvider

O `SshProvider` foi estendido para incluir:
- Lista de `LogEntry` para histórico da sessão
- Logging automático no método `executeCommand()`
- Detecção automática de tipo de comando
- Métodos de filtro e estatísticas
- Configurações de logging

### Componentes de Interface

- **SessionLogScreen**: Tela principal do histórico
- **LogEntryTile**: Widget para exibir cada entrada de log
- **Filtros integrados**: Dropdowns e busca textual
- **Menu contextual**: Opções de estatísticas e exportação

## Configurações

### Ativar/Desativar Logging
```dart
sshProvider.setLoggingEnabled(false); // Desativa logging
sshProvider.setLoggingEnabled(true);  // Ativa logging
```

### Limitar Entradas
```dart
sshProvider.setMaxLogEntries(500); // Máximo 500 entradas
```

### Limpar Histórico
```dart
sshProvider.clearSessionLog(); // Remove todas as entradas
```

## Formatos de Exportação

### TXT (Texto)
Formato legível por humanos com todas as informações:
```
=== Command Execution Log ===
ID: log_1705315845123_0001
Timestamp: 2024-01-15 10:30:45
Command: ls -la
Type: Navigation
Working Directory: /home/user
Duration: 120ms
Status: Success
Exit Code: 0
--- STDOUT ---
total 12
drwxr-xr-x 2 user user 4096 Jan 15 10:30 .
drwxr-xr-x 3 root root 4096 Jan 15 10:00 ..
-rw-r--r-- 1 user user  220 Jan 15 10:30 .bashrc
```

### JSON (Estruturado)
Formato para processamento automático:
```json
[
  {
    "id": "log_1705315845123_0001",
    "timestamp": "2024-01-15T10:30:45.000Z",
    "command": "ls -la",
    "type": "CommandType.navigation",
    "workingDirectory": "/home/user",
    "stdout": "total 12\ndrwxr-xr-x 2 user user...",
    "stderr": "",
    "exitCode": 0,
    "durationMicros": 120000,
    "status": "CommandStatus.success"
  }
]
```

### CSV (Planilha)
Formato para análise em planilhas:
```csv
Timestamp,Command,Type,Status,Duration,Working Directory,Exit Code,STDOUT,STDERR
2024-01-15 10:30:45,ls -la,Navigation,Success,120ms,/home/user,0,"total 12...",""
```

## Boas Práticas

### Performance
- O histórico é limitado a 1000 entradas por padrão
- Comandos antigos são automaticamente removidos
- Filtros são aplicados na memória para resposta rápida

### Segurança
- Logs contêm apenas comandos e saídas públicas
- Não há captura de senhas ou dados sensíveis
- Exportação requer conexão SSH ativa

### Usabilidade
- Interface responsiva e intuitiva
- Feedback visual para todas as ações
- Confirmações para ações destrutivas (limpar histórico)

## Extensibilidade

### Adicionar Novos Tipos de Comando
```dart
// Em _detectCommandType() no SshProvider
const Map<String, CommandType> commandMap = {
  'git': CommandType.custom,
  'docker': CommandType.system,
  // ... novos comandos
};
```

### Customizar Formatos de Exportação
```dart
// Em exportSessionLog() no SshProvider
case 'xml':
  return _formatAsXml(logEntries);
```

### Adicionar Metadados
```dart
LogEntry(
  // ... outros campos
  metadata: {
    'server_type': 'production',
    'user_role': 'admin',
    'session_id': sessionId,
  },
);
```

---

Este sistema fornece uma auditoria completa e análise detalhada de todas as atividades SSH, melhorando significativamente a experiência do utilizador e a capacidade de debug/análise do aplicativo.