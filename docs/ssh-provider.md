# SshProvider - Documentação

## Visão Geral

O `SshProvider` é o provedor principal para gerenciamento de conexões SSH no EasySSH. Implementa todas as funcionalidades necessárias para conectar, executar comandos e gerenciar o estado da conexão SSH.

## Recursos Implementados

### Estados de Conexão

O provider utiliza o enum `SshConnectionState` para gerenciar estados:

- `disconnected` - Desconectado do servidor SSH
- `connecting` - Conectando ao servidor SSH
- `connected` - Conectado com sucesso
- `error` - Erro na conexão ou execução de comando

### Funcionalidades Principais

#### 1. Conexão SSH
```dart
Future<bool> connect({
  required String host,
  required int port,
  required String username,
  required String password,
  bool saveCredentials = false,
})
```

- Conecta ao servidor SSH usando dartssh2
- Suporte para autenticação por senha
- Opção para salvar credenciais de forma segura
- Tratamento de erros específicos

#### 2. Execução de Comandos
```dart
Future<String?> executeCommand(String command)
Future<Map<String, String>?> executeCommandDetailed(String command)
```

- Executa comandos no servidor SSH conectado
- Versão detalhada retorna stdout e stderr separados
- Verificação automática do estado de conexão
- Tratamento de erros durante execução

#### 3. Gerenciamento de Conexão
```dart
void disconnect()
Future<void> logout({bool forgetCredentials = false})
```

- Desconexão limpa com liberação de recursos
- Logout com opção de esquecer credenciais salvas
- Cleanup automático em caso de erro

### Tratamento de Erros

O provider inclui tratamento específico para diferentes tipos de erro SSH:

- Host inalcançável
- Falha de autenticação  
- Timeout de conexão
- Falha na troca de chaves
- Conexão recusada
- Sem rota para o host

### Compatibilidade

Mantém compatibilidade com código existente através de getters:
- `bool get isConnecting`
- `bool get isConnected`

## Testes

Testes unitários incluídos para:
- Estados iniciais
- Execução de comandos sem conexão
- Limpeza de erros
- Desconexão e logout
- Enum SshConnectionState e suas extensões

## Dependências

- `dartssh2: ^2.9.0` - Cliente SSH puro Dart
- `provider: ^6.0.5` - Gerenciamento de estado
- `flutter_secure_storage: ^9.0.0` - Armazenamento seguro

## Uso

```dart
// No main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) {
        final provider = SshProvider();
        provider.initialize();
        return provider;
      },
    ),
  ],
  child: MyApp(),
)

// Em uma tela
final sshProvider = Provider.of<SshProvider>(context);

// Conectar
await sshProvider.connect(
  host: 'servidor.com',
  port: 22,
  username: 'usuario',
  password: 'senha',
  saveCredentials: true,
);

// Executar comando
final result = await sshProvider.executeCommand('ls -la');

// Desconectar
await sshProvider.disconnect();
```

## Arquivos Relacionados

- `lib/providers/ssh_provider.dart` - Implementação principal
- `lib/models/ssh_connection_state.dart` - Estados de conexão
- `lib/models/ssh_credentials.dart` - Modelo de credenciais
- `lib/services/secure_storage_service.dart` - Armazenamento seguro
- `test/providers/ssh_provider_test.dart` - Testes do provider
- `test/models/ssh_connection_state_test.dart` - Testes dos estados