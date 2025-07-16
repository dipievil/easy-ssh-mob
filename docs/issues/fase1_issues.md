# Fase 1: Fundação e Conexão Principal

## Issue 3: Configuração do Projeto

### Metadados
- **Título**: [Fase 1.1] Configuração do Projeto Flutter
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #1 (issue anterior)

### Descrição

Criar a estrutura base do projeto Flutter EasySSH e configurar todas as dependências necessárias conforme especificado no [IMPLEMENTATION_PLAN.md](/docs/implementation/IMPLEMENTATION_PLAN.md).

### Objetivos da Tarefa

Esta é a primeira tarefa da **Fase 1: Fundação e Conexão Principal**. O objetivo é estabelecer a base técnica do projeto com todas as dependências necessárias para o desenvolvimento da aplicação.

### Tarefas Específicas

#### 1. Criação do Projeto Flutter
- [ ] Executar `flutter create easyssh` na raiz do repositório
- [ ] Verificar se a estrutura de pastas foi criada corretamente
- [ ] Confirmar que o projeto compila sem erros

#### 2. Configuração das Dependências no pubspec.yaml
- [ ] Adicionar dependência `dartssh2` - Para comunicação SSH pura em Dart
- [ ] Adicionar dependência `provider` - Para gestão de estado reativa
- [ ] Adicionar dependência `flutter_secure_storage` - Para armazenamento seguro de credenciais
- [ ] Adicionar dependência `font_awesome_flutter` - Para biblioteca de ícones

#### 3. Configuração do Ambiente
- [ ] Configurar Material 3 (`useMaterial3: true`) no ThemeData
- [ ] Verificar compatibilidade com Android e iOS
- [ ] Testar compilação em modo debug

### Critérios de Aceitação

- ✅ Projeto Flutter criado com sucesso
- ✅ Todas as dependências adicionadas ao pubspec.yaml
- ✅ Projeto compila sem erros em modo debug
- ✅ Estrutura de pastas está correta (lib/, android/, ios/, etc.)
- ✅ Material 3 configurado
- ✅ Testes básicos passam

### Referências Técnicas

- [Flutter Documentation - Create App](https://docs.flutter.dev/get-started/test-drive)
- [dartssh2 Package](https://pub.dev/packages/dartssh2)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter)

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #4: Ecrã de Conexão (Login)**.

---

## Issue 4: Ecrã de Conexão (Login)

### Metadados
- **Título**: [Fase 1.2] Implementação do Ecrã de Conexão (Login)
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #3 (issue anterior)

### Descrição

Criar a interface de utilizador para conexão SSH, permitindo ao utilizador inserir as credenciais e conectar-se ao servidor remoto.

### Objetivos da Tarefa

Esta é a segunda tarefa da **Fase 1: Fundação e Conexão Principal**. O objetivo é criar uma interface intuitiva para que o utilizador possa inserir as credenciais SSH e iniciar a conexão.

### Tarefas Específicas

#### 1. Criação do Widget LoginScreen
- [ ] Criar arquivo `lib/screens/login_screen.dart`
- [ ] Implementar StatefulWidget para LoginScreen
- [ ] Adicionar scaffold com AppBar apropriada

#### 2. Implementação dos Campos de Entrada
- [ ] Campo **Host** (TextField) - Endereço do servidor SSH
- [ ] Campo **Porta** (TextField) - Porta SSH (padrão: 22)
- [ ] Campo **Usuário** (TextField) - Nome de utilizador SSH
- [ ] Campo **Senha** (TextField) - Palavra-passe com obscureText: true

#### 3. Validação dos Campos
- [ ] Validação de campos obrigatórios
- [ ] Validação de formato da porta (numérico)
- [ ] Validação de formato do host (não vazio)
- [ ] Feedback visual para campos inválidos

#### 4. Botão de Conexão
- [ ] Botão "Conectar" estilizado
- [ ] Mostrar CircularProgressIndicator durante conexão
- [ ] Desabilitar botão durante processo de conexão
- [ ] Feedback visual do estado de carregamento

#### 5. Layout e Design
- [ ] Layout responsivo usando Column/Padding
- [ ] Espaçamento adequado entre campos
- [ ] Ícones apropriados para cada campo
- [ ] Seguir Material 3 design guidelines

### Critérios de Aceitação

- ✅ LoginScreen criado e funcional
- ✅ Todos os campos de entrada implementados
- ✅ Validação de entrada funciona
- ✅ Botão conectar com estados visuais (normal, carregando, desabilitado)
- ✅ Design responsivo e acessível
- ✅ Interface segue padrões Material 3

### Especificações de UI

```dart
// Estrutura sugerida do layout
Column(
  children: [
    TextField(decoration: InputDecoration(labelText: 'Host')),
    TextField(decoration: InputDecoration(labelText: 'Porta')),
    TextField(decoration: InputDecoration(labelText: 'Usuário')),
    TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
    ElevatedButton(onPressed: _connect, child: Text('Conectar')),
  ],
)
```

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #5: Lógica de Armazenamento Seguro**.

---

## Issue 5: Lógica de Armazenamento Seguro

### Metadados
- **Título**: [Fase 1.3] Implementação da Lógica de Armazenamento Seguro
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #4 (issue anterior)

### Descrição

Implementar a funcionalidade de armazenamento seguro para salvar e recuperar dados de conexão SSH (exceto senha) usando flutter_secure_storage.

### Objetivos da Tarefa

Esta é a terceira tarefa da **Fase 1: Fundação e Conexão Principal**. O objetivo é permitir que a aplicação lembre das credenciais de conexão do utilizador (exceto a senha por segurança) para facilitar reconexões.

### Tarefas Específicas

#### 1. Criação do Serviço de Armazenamento
- [ ] Criar arquivo `lib/services/storage_service.dart`
- [ ] Implementar classe StorageService
- [ ] Configurar FlutterSecureStorage com opções apropriadas

#### 2. Métodos de Armazenamento
- [ ] Método `saveConnectionData(host, port, username)` 
- [ ] Método `loadConnectionData()` retornando Map<String, String>
- [ ] Método `clearConnectionData()` para limpar dados salvos
- [ ] Método `hasStoredConnection()` para verificar se existem dados

#### 3. Integração com LoginScreen
- [ ] Carregar dados salvos ao inicializar LoginScreen
- [ ] Preencher campos automaticamente se dados existirem
- [ ] Salvar dados após conexão bem-sucedida (exceto senha)
- [ ] Opção para "Lembrar dados de conexão"

#### 4. Gestão de Erros
- [ ] Tratamento de erros de leitura/escrita
- [ ] Fallback para caso o secure storage não esteja disponível
- [ ] Logs apropriados para debug

#### 5. Segurança e Privacidade
- [ ] **NUNCA** armazenar senhas
- [ ] Usar chaves descriptivas para os dados
- [ ] Implementar método para limpar dados ao desinstalar

### Critérios de Aceitação

- ✅ StorageService criado e funcional
- ✅ Dados de conexão salvos automaticamente (host, porta, usuário)
- ✅ Senha NUNCA é armazenada
- ✅ LoginScreen carrega dados salvos automaticamente
- ✅ Opção para limpar dados armazenados
- ✅ Tratamento de erros implementado

### Especificações Técnicas

```dart
class StorageService {
  static const String _hostKey = 'ssh_host';
  static const String _portKey = 'ssh_port';
  static const String _usernameKey = 'ssh_username';
  
  Future<void> saveConnectionData(String host, String port, String username);
  Future<Map<String, String?>> loadConnectionData();
  Future<void> clearConnectionData();
  Future<bool> hasStoredConnection();
}
```

### Chaves de Armazenamento
- `ssh_host` - Endereço do servidor
- `ssh_port` - Porta de conexão
- `ssh_username` - Nome de utilizador

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #6: Serviço de Conexão SSH (Provider)**.

---

## Issue 6: Serviço de Conexão SSH (Provider)

### Metadados
- **Título**: [Fase 1.4] Implementação do Serviço de Conexão SSH (Provider)
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #5 (issue anterior)

### Descrição

Criar o serviço principal de conexão SSH usando Provider para gestão de estado, implementando as funcionalidades core de conexão, desconexão e execução de comandos.

### Objetivos da Tarefa

Esta é a quarta e última tarefa da **Fase 1: Fundação e Conexão Principal**. O objetivo é criar a camada de serviço que gerenciará toda a comunicação SSH e o estado da aplicação.

### Tarefas Específicas

#### 1. Criação da Classe SshProvider
- [ ] Criar arquivo `lib/providers/ssh_provider.dart`
- [ ] Implementar classe SshProvider extends ChangeNotifier
- [ ] Configurar cliente dartssh2

#### 2. Gestão de Estados
- [ ] Enum SshConnectionState (disconnected, connecting, connected, error)
- [ ] Propriedades para estado atual, mensagens de erro, info da conexão
- [ ] Métodos getter para acessar estados
- [ ] notifyListeners() em todas as mudanças de estado

#### 3. Funcionalidades Core
```dart
// Métodos principais a implementar:
Future<bool> connect(String host, String port, String username, String password);
Future<void> disconnect();
Future<String> executeCommand(String command);
```

#### 4. Gestão de Conexão
- [ ] Validação de parâmetros de conexão
- [ ] Timeout configurável para conexões
- [ ] Tratamento de erros de rede
- [ ] Cleanup automático de recursos

#### 5. Execução de Comandos
- [ ] Método executeCommand que retorna stdout
- [ ] Captura de stderr separadamente
- [ ] Timeout para comandos longos
- [ ] Queue de comandos se necessário

#### 6. Integração com LoginScreen
- [ ] Conectar Provider com LoginScreen
- [ ] Atualizar UI baseado nos estados
- [ ] Navegar para próxima tela após conexão bem-sucedida

### Critérios de Aceitação

- ✅ SshProvider criado e funcional
- ✅ Estados de conexão gerenciados corretamente
- ✅ Método connect() estabelece conexão SSH
- ✅ Método disconnect() encerra conexão limpa
- ✅ Método executeCommand() executa comandos remotos
- ✅ Tratamento de erros robusto
- ✅ Provider integrado com LoginScreen
- ✅ Notificações de mudança de estado funcionam

### Especificações Técnicas

```dart
class SshProvider extends ChangeNotifier {
  SshConnectionState _state = SshConnectionState.disconnected;
  SSHClient? _client;
  String? _errorMessage;
  
  SshConnectionState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _state == SshConnectionState.connected;
  
  Future<bool> connect(String host, String port, String username, String password);
  Future<void> disconnect();
  Future<String> executeCommand(String command);
}
```

### Estados de Conexão
- `disconnected` - Sem conexão ativa
- `connecting` - Tentando conectar
- `connected` - Conectado com sucesso
- `error` - Erro na conexão

### Tratamento de Erros
- Erros de rede (host inacessível, timeout)
- Erros de autenticação (credenciais inválidas)
- Erros de comando (comando não encontrado, permissões)
- Desconexões inesperadas

### Próxima Fase
Após completar esta tarefa, a **Fase 1** estará completa. Prosseguir para a **Fase 2: Navegação por Diretórios** com a **Issue #7: Ecrã do Explorador de Ficheiros**.

### Configuração do Provider na App
```dart
// Em main.dart
ChangeNotifierProvider(
  create: (context) => SshProvider(),
  child: MyApp(),
)
```