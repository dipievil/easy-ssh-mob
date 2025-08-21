# Funcionalidade de Reconexão SSH Automática

## Visão Geral

Esta implementação adiciona reconexão SSH automática ao app Easy SSH Mobile quando a conexão é perdida durante o uso normal.

## Como Funciona

### 1. Detecção Automática
- O `ErrorHandler` detecta padrões de conexão perdida:
  - "Connection lost"
  - "Connection closed" 
  - "Connection refused"
  - "Connection timeout"

### 2. Reconexão Automática
Quando uma conexão perdida é detectada:
- Inicia automaticamente tentativas de reconexão
- Máximo de **3 tentativas**
- **2 segundos** de delay entre tentativas
- Usa as credenciais salvas da conexão atual

### 3. Interface do Usuário

Se a reconexão automática falhar, mostra um diálogo com opções:

#### Opções Disponíveis:
1. **Tentar Novamente** - Nova tentativa manual de reconexão
2. **Ir para Login** - Volta para tela de login mantendo credenciais
3. **Sair da App** - Fecha a aplicação (com confirmação)

## Fluxo de Reconexão

```
Conexão Perdida Detectada
         ↓
Tentativa Automática (1/3)
         ↓
    [Sucesso?] → Sim → Conectado ✓
         ↓ Não
Tentativa Automática (2/3)
         ↓
    [Sucesso?] → Sim → Conectado ✓
         ↓ Não  
Tentativa Automática (3/3)
         ↓
    [Sucesso?] → Sim → Conectado ✓
         ↓ Não
   Mostrar Diálogo
         ↓
  [Usuário Escolhe]
    ↓       ↓       ↓
Reconectar  Login  Sair
```

## Estados da Conexão

- `disconnected` - Desconectado
- `connecting` - Conectando (inclui reconexão)
- `connected` - Conectado com sucesso  
- `error` - Erro de conexão

### Propriedades de Reconexão

```dart
bool get isReconnecting     // Se está tentando reconectar
int get reconnectAttempts   // Número de tentativas realizadas
```

## Integração com Telas

### FileExplorerScreen
- Escuta mudanças no `SshProvider`
- Detecta quando mostrar diálogo de reconexão
- Evita mostrar diálogo múltiplas vezes

### Outras Telas
Para integrar em outras telas, adicione o listener:

```dart
void _setupErrorListener() {
  final sshProvider = Provider.of<SshProvider>(context, listen: false);
  sshProvider.addListener(_handleProviderChange);
}

void _handleProviderChange() {
  final sshProvider = Provider.of<SshProvider>(context, listen: false);
  
  if (sshProvider.connectionState.hasError && 
      sshProvider.lastError?.type == ErrorType.connectionLost &&
      !sshProvider.isReconnecting &&
      !_reconnectionDialogShown) {
    
    _reconnectionDialogShown = true;
    ReconnectionDialog.show(context);
  }
}
```

## Configurações

### Timeouts e Tentativas
```dart
static const int _maxReconnectAttempts = 3;
static const Duration _reconnectDelay = Duration(seconds: 2);
```

### Padrões de Detecção
O `ErrorHandler` usa regex patterns para detectar conexão perdida:
```dart
static final RegExp _connectionLostPattern = RegExp(
  r'Connection.*(lost|closed|refused)',
  caseSensitive: false,
);
```

## Testes

### Casos de Teste Implementados
- Inicialização das propriedades de reconexão
- Reset do estado de reconexão
- Detecção de padrões de conexão perdida
- Análise de diferentes mensagens de erro

### Executar Testes
```bash
flutter test test/providers/ssh_reconnection_test.dart
```

## Benefícios

1. **Experiência do Usuário**
   - Reconexão transparente na maioria dos casos
   - Opções claras quando falha
   - Feedback visual durante processo

2. **Robustez**
   - Não perde credenciais durante desconexão
   - Múltiplas tentativas automáticas
   - Fallback manual disponível

3. **Flexibilidade**
   - Usuário pode escolher sair ou ir para login
   - Configurações ajustáveis
   - Fácil integração em novas telas