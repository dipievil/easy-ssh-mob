# Sistema de Tratamento de Erros SSH

Este documento descreve o sistema implementado para tratamento robusto de erros SSH na aplicação EasySSH.

## Visão Geral

O sistema detecta automaticamente erros em operações SSH e fornece feedback claro e útil ao utilizador, incluindo:

- **Análise automática** de stderr das operações SSH
- **Categorização** de 8 tipos de erro comuns
- **Feedback visual** com ícones e cores apropriadas
- **Sugestões** de resolução quando aplicável
- **Som de alerta** configurável

## Tipos de Erro Detectados

| Tipo | Mensagem Original | Mensagem para Utilizador | Severidade |
|------|-------------------|---------------------------|------------|
| `permissionDenied` | "Permission denied" | "Sem permissão para executar esta ação" | Warning |
| `fileNotFound` | "No such file or directory" | "Ficheiro ou diretório não encontrado" | Warning |
| `operationNotPermitted` | "Operation not permitted" | "Operação não permitida pelo sistema" | Error |
| `accessDenied` | "Access denied" | "Acesso negado ao recurso" | Warning |
| `connectionLost` | "Connection lost/closed/refused" | "Conexão SSH perdida" | Critical |
| `timeout` | "Timeout/timed out" | "Comando demorou muito tempo" | Warning |
| `commandNotFound` | "command not found" | "Comando não encontrado no sistema" | Error |
| `diskFull` | "No space left on device" | "Sem espaço disponível no disco" | Critical |

## Componentes do Sistema

### 1. ErrorHandler Service (`lib/services/error_handler.dart`)

- **`ErrorType`**: Enum com tipos de erro
- **`ErrorSeverity`**: Enum com níveis de severidade
- **`SshError`**: Classe para representar erros estruturados
- **`ErrorHandler.analyzeError()`**: Método principal para análise

### 2. Widgets de Erro (`lib/widgets/error_widgets.dart`)

- **`ErrorSnackBar`**: Notificação rápida com ação de ajuda
- **`ErrorDialog`**: Diálogo detalhado com informações técnicas

### 3. SshProvider Atualizado (`lib/providers/ssh_provider.dart`)

- **Captura separada** de stdout/stderr em todas as operações
- **Análise automática** de erros em tempo real
- **Sistema de som** configurável para alertas
- **Estado de erro** integrado no provider

## Integração nas Telas

### Listener Automático

Todas as telas principais têm listener automático para mostrar erros:

```dart
void _setupErrorListener() {
  final sshProvider = Provider.of<SshProvider>(context, listen: false);
  sshProvider.addListener(_handleProviderChange);
}

void _handleProviderChange() {
  final sshProvider = _lastSshProvider;
  if (sshProvider?.lastError != null && mounted) {
    ErrorSnackBar.show(context, sshProvider!.lastError!);
  }
}
```

### Telas Integradas

- **TerminalScreen**: Mostra erros de comandos executados
- **FileExplorerScreen**: Mostra erros de navegação e listagem
- **FileViewerScreen**: Mostra erros de leitura de ficheiros

## Uso do Sistema

### Para Desenvolvedores

1. **Execução de comandos**: O sistema analisa automaticamente stderr
2. **Configuração de som**: `sshProvider.setErrorSoundEnabled(true/false)`
3. **Teste de erros**: Use `ErrorTestScreen` para validar diferentes tipos

### Para Utilizadores

1. **Feedback imediato**: SnackBar aparece automaticamente
2. **Detalhes técnicos**: Clique em "AJUDA" para ver dialog completo
3. **Sugestões**: Sistema fornece dicas de resolução quando possível

## Exemplos de Uso

### Detecção Automática

```dart
// No SshProvider, stderr é automaticamente analisado
final session = await _sshClient!.execute(command);
final stderr = await session.stderr.transform(utf8.decoder).join();

if (stderr.isNotEmpty) {
  final error = ErrorHandler.analyzeError(stderr, command);
  _handleSshError(error);
}
```

### Mostrar Erro Manualmente

```dart
final error = SshError(
  type: ErrorType.permissionDenied,
  originalMessage: 'Permission denied',
  userFriendlyMessage: 'Sem permissão para executar esta ação',
  severity: ErrorSeverity.warning,
);

ErrorSnackBar.show(context, error);
```

## Testes

### Testes Unitários

Execute os testes do ErrorHandler:
```bash
flutter test test/services/error_handler_test.dart
```

### Teste Manual

Use a tela de teste para validar todos os tipos:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ErrorTestScreen()),
);
```

### Script de Teste SSH

Execute o script para simular erros reais:
```bash
./scripts/test_error_handler.sh
```

## Configuração de Som

O sistema suporta alertas sonoros configuráveis:

1. **Estrutura implementada** para audioplayers
2. **Configuração por severidade** (info não toca, critical sempre toca)
3. **Toggle global** para ativar/desativar sons
4. **Fallback gracioso** se ficheiros de som não existirem

## Futuras Melhorias

- [ ] Adicionar ficheiros de som reais (.wav)
- [ ] Implementar retry automático para alguns tipos de erro
- [ ] Adicionar métricas de erros para diagnóstico
- [ ] Suporte a idiomas múltiplos nas mensagens
- [ ] Sistema de cache para evitar múltiplas notificações do mesmo erro

## Conclusão

O sistema fornece uma experiência robusta e utilizador-amigável para tratamento de erros SSH, com feedback claro e sugestões úteis para resolução de problemas.