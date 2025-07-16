# EasySSH - SSH Connection Manager

Uma aplicação multiplataforma (Android e iOS) que permitirá aos usuários conectarem-se a um servidor SSH e navegar no seu sistema de arquivos através de uma interface de utilizador gráfica baseada em botões. A aplicação irá simplificar a execução de scripts, visualização de arquivos e execução de comandos básicos de forma intuitiva.

## Arquitetura

### SshProvider

O `SshProvider` é o componente principal responsável por gerenciar o estado da conexão SSH e todas as operações relacionadas. Implementa `ChangeNotifier` para notificar a UI sobre mudanças de estado.

#### Estados de Conexão

- **disconnected**: Sem conexão ativa
- **connecting**: Tentando conectar
- **connected**: Conectado com sucesso  
- **error**: Erro na conexão

#### Funcionalidades Principais

- `connect(host, port, username, password)`: Estabelece conexão SSH
- `disconnect()`: Encerra conexão de forma limpa
- `executeCommand(command)`: Executa comandos remotos
- Validação de parâmetros de entrada
- Tratamento robusto de erros
- Timeout configurável para conexões e comandos

#### Recursos de Segurança

- Validação rigorosa de parâmetros
- Timeout para evitar travamentos
- Limpeza automática de recursos
- Tratamento específico de erros de autenticação

## Dependências

- **dartssh2**: Cliente SSH puro em Dart
- **provider**: Gerenciamento de estado reativo
- **flutter_secure_storage**: Armazenamento seguro de credenciais
- **font_awesome_flutter**: Biblioteca de ícones

## Como Usar

```dart
// Configurar o provider
ChangeNotifierProvider(
  create: (context) => SshProvider(),
  child: MyApp(),
)

// Usar na UI
Consumer<SshProvider>(
  builder: (context, sshProvider, child) {
    return Column(
      children: [
        Text('Status: ${sshProvider.state.description}'),
        if (sshProvider.hasError)
          Text('Erro: ${sshProvider.errorMessage}'),
        ElevatedButton(
          onPressed: () => sshProvider.connect(host, port, user, pass),
          child: Text('Conectar'),
        ),
      ],
    );
  },
)
```

## Tratamento de Erros

- **Erros de rede**: Host inacessível, timeout
- **Erros de autenticação**: Credenciais inválidas
- **Erros de comando**: Comando não encontrado, permissões
- **Desconexões inesperadas**: Perda de conexão

Todos os erros são capturados e expostos através do `errorMessage` com mensagens em português para melhor experiência do usuário.
