# Fase 2: Navegação por Diretórios

## Issue 7: Ecrã do Explorador de Ficheiros

### Metadados
- **Título**: [Fase 2.1] Implementação do Ecrã do Explorador de Ficheiros
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #6 (issue anterior)

### Descrição

Criar a interface principal do explorador de ficheiros que será exibida após uma conexão SSH bem-sucedida, permitindo navegar no sistema de ficheiros remoto.

### Objetivos da Tarefa

Esta é a primeira tarefa da **Fase 2: Navegação por Diretórios**. O objetivo é criar a interface principal onde o utilizador irá interagir com o sistema de ficheiros remoto através de botões dinâmicos.

### Tarefas Específicas

#### 1. Criação do Widget FileExplorerScreen
- [ ] Criar arquivo `lib/screens/file_explorer_screen.dart`
- [ ] Implementar StatefulWidget para FileExplorerScreen
- [ ] Configurar Consumer<SshProvider> para reatividade

#### 2. Implementação da AppBar
- [ ] Mostrar caminho do diretório atual
- [ ] Botão "Home" para voltar ao diretório inicial
- [ ] Botão "Ferramentas" (menu de ações)
- [ ] Indicador de status da conexão

#### 3. Layout Principal
- [ ] Body com ListView para mostrar conteúdo do diretório
- [ ] FloatingActionButton para ações rápidas
- [ ] BottomNavigationBar ou BottomAppBar se necessário
- [ ] Loading indicator durante carregamento de diretórios

#### 4. Navegação e Estados
- [ ] Redirecionar para FileExplorerScreen após login bem-sucedido
- [ ] Manter histórico de navegação
- [ ] Botão "Voltar" no sistema
- [ ] Atualizar UI quando mudar de diretório

#### 5. Integração com SshProvider
- [ ] Escutar mudanças de estado da conexão
- [ ] Mostrar indicadores de carregamento
- [ ] Tratar desconexões inesperadas
- [ ] Atualizar caminho atual na AppBar

### Critérios de Aceitação

- ✅ FileExplorerScreen criado e funcional
- ✅ AppBar mostra caminho atual e botões de ação
- ✅ Layout responsivo e Material 3
- ✅ Navegação automática após login
- ✅ Integração com SshProvider funciona
- ✅ Estados de loading/error tratados

### Especificações de UI

```dart
class FileExplorerScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        actions: [
          IconButton(icon: Icon(Icons.home), onPressed: _goHome),
          IconButton(icon: Icon(Icons.settings), onPressed: _showTools),
        ],
      ),
      body: Consumer<SshProvider>(
        builder: (context, sshProvider, child) {
          // Lista de ficheiros será implementada na próxima issue
          return Center(child: Text('Diretório: $_currentPath'));
        },
      ),
    );
  }
}
```

### Funcionalidades da AppBar
- **Título**: Caminho completo do diretório atual
- **Botão Home**: Navegar para diretório home do utilizador  
- **Botão Ferramentas**: Abrir drawer/menu com comandos
- **Indicador de conexão**: Status visual da conexão SSH

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #8: Listar Conteúdo do Diretório**.

---

## Issue 8: Listar Conteúdo do Diretório

### Metadados
- **Título**: [Fase 2.2] Implementação da Listagem de Conteúdo do Diretório
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #7 (issue anterior)

### Descrição

Implementar a funcionalidade para listar o conteúdo de diretórios remotos via SSH, analisando a saída do comando `ls -F` e criando uma estrutura de dados organizada.

### Objetivos da Tarefa

Esta é a segunda tarefa da **Fase 2: Navegação por Diretórios**. O objetivo é criar a lógica para obter e organizar informações sobre ficheiros e diretórios remotos.

### Tarefas Específicas

#### 1. Criação da Classe SshFile
- [ ] Criar arquivo `lib/models/ssh_file.dart`
- [ ] Implementar classe SshFile com propriedades necessárias
- [ ] Enum FileType (directory, executable, regular, symlink, etc.)
- [ ] Métodos helper para análise de tipo

#### 2. Extensão do SshProvider
- [ ] Adicionar propriedade `List<SshFile> currentFiles`
- [ ] Adicionar propriedade `String currentPath`
- [ ] Método `Future<void> listDirectory(String path)`
- [ ] Método `Future<void> navigateToDirectory(String path)`

#### 3. Análise do Comando ls -F
- [ ] Executar `ls -F` no diretório atual
- [ ] Parser para analisar output e identificar tipos:
  - `/` - Diretório
  - `*` - Executável
  - `@` - Link simbólico
  - `|` - FIFO (pipe)
  - `=` - Socket
  - (sem sufixo) - Arquivo regular

#### 4. Gestão de Caminhos
- [ ] Método para construir caminhos absolutos
- [ ] Normalização de paths (lidar com `..`, `.`, etc.)
- [ ] Validação de caminhos
- [ ] Histórico de navegação

#### 5. Tratamento de Erros
- [ ] Erros de permissão (Permission denied)
- [ ] Diretórios inexistentes
- [ ] Timeout de comandos
- [ ] Parsing de outputs inesperados

### Critérios de Aceitação

- ✅ Classe SshFile criada com todos os tipos suportados
- ✅ SshProvider pode listar conteúdo de diretórios
- ✅ Parser de `ls -F` funciona corretamente
- ✅ Navegação entre diretórios funciona
- ✅ Tratamento de erros robusto
- ✅ Histórico de navegação mantido

### Especificações Técnicas

```dart
enum FileType {
  directory,
  executable, 
  regular,
  symlink,
  fifo,
  socket,
  unknown
}

class SshFile {
  final String name;
  final String fullPath;
  final FileType type;
  final String displayName;
  
  SshFile({
    required this.name,
    required this.fullPath, 
    required this.type,
    required this.displayName,
  });
  
  factory SshFile.fromLsLine(String line, String currentPath);
  
  IconData get icon; // Retorna ícone apropriado para o tipo
  bool get isDirectory => type == FileType.directory;
  bool get isExecutable => type == FileType.executable;
}
```

### Parser do ls -F

```dart
// Extensão no SshProvider
Future<void> listDirectory(String path) async {
  try {
    _currentPath = path;
    final output = await executeCommand('ls -F "$path"');
    final files = <SshFile>[];
    
    for (String line in output.split('\n')) {
      if (line.trim().isNotEmpty) {
        files.add(SshFile.fromLsLine(line.trim(), path));
      }
    }
    
    _currentFiles = files;
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Erro ao listar diretório: $e';
    notifyListeners();
  }
}
```

### Tipos de Arquivo Suportados
- **Diretório** (`/`): Pasta navegável
- **Executável** (`*`): Script ou binário executável  
- **Regular**: Arquivo comum (texto, dados)
- **Link simbólico** (`@`): Link para outro arquivo
- **FIFO** (`|`): Named pipe
- **Socket** (`=`): Unix socket

### Próxima Tarefa
Após completar esta tarefa, prosseguir para a **Issue #9: Geração Dinâmica de Botões**.

---

## Issue 9: Geração Dinâmica de Botões

### Metadados
- **Título**: [Fase 2.3] Implementação da Geração Dinâmica de Botões
- **Labels**: enhancement
- **Milestone**: Primeira Versão
- **Assignee**: @Copilot
- **Relacionado com**: #8 (issue anterior)

### Descrição

Criar a interface dinâmica de botões que representa ficheiros e diretórios, permitindo navegação intuitiva e execução de ações através de cliques.

### Objetivos da Tarefa

Esta é a terceira e última tarefa da **Fase 2: Navegação por Diretórios**. O objetivo é criar uma interface visual intuitiva onde cada ficheiro/diretório é representado por um botão clicável.

### Tarefas Específicas

#### 1. Criação do Widget SshFileListTile
- [ ] Criar arquivo `lib/widgets/ssh_file_list_tile.dart`
- [ ] Implementar widget personalizado para representar SshFile
- [ ] Ícones dinâmicos baseados no tipo de ficheiro
- [ ] Estados visuais (normal, pressionado, carregando)

#### 2. Implementação do ListView.builder
- [ ] Atualizar FileExplorerScreen com ListView.builder
- [ ] Renderizar lista de SshFile como botões
- [ ] Loading states durante carregamento
- [ ] Empty states quando diretório vazio

#### 3. Lógica de Navegação
- [ ] Clique em diretório navega para subdiretório
- [ ] Botão "Voltar" (ou item `..`) para diretório pai
- [ ] Breadcrumb navigation na AppBar
- [ ] Histórico de navegação

#### 4. Interação com Ficheiros
- [ ] Clique em executável → preparar para execução (Fase 3)
- [ ] Clique em ficheiro regular → preparar para visualização (Fase 3) 
- [ ] Clique em link simbólico → seguir link
- [ ] Feedback visual para ações

#### 5. UI/UX Enhancements
- [ ] Ícones FontAwesome para diferentes tipos
- [ ] Animações suaves de transição
- [ ] Pull-to-refresh para atualizar diretório
- [ ] Long press para opções contextuais

### Critérios de Aceitação

- ✅ ListView.builder renderiza SshFile como botões
- ✅ Navegação para subdiretórios funciona
- ✅ Botão "Voltar" implementado
- ✅ Ícones apropriados para cada tipo de ficheiro
- ✅ Estados de loading/empty/error tratados
- ✅ Interface responsiva e fluida

### Especificações de UI

```dart
class SshFileListTile extends StatelessWidget {
  final SshFile file;
  final VoidCallback onTap;
  final bool isLoading;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(file.icon, color: _getIconColor()),
      title: Text(file.displayName),
      subtitle: Text(_getSubtitle()),
      trailing: isLoading 
        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
        : Icon(_getTrailingIcon()),
      onTap: onTap,
    );
  }
}
```

### Ícones por Tipo de Ficheiro
- **Diretório**: `FontAwesomeIcons.folder` (azul)
- **Executável**: `FontAwesomeIcons.terminal` (verde)
- **Arquivo regular**: `FontAwesomeIcons.file` (cinza)
- **Link simbólico**: `FontAwesomeIcons.link` (púrpura)
- **Script**: `FontAwesomeIcons.fileCode` (laranja)

### Navegação no FileExplorerScreen

```dart
// No FileExplorerScreen
Widget _buildFileList() {
  final sshProvider = Provider.of<SshProvider>(context);
  
  if (sshProvider.isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  
  if (sshProvider.currentFiles.isEmpty) {
    return Center(child: Text('Diretório vazio'));
  }
  
  return ListView.builder(
    itemCount: sshProvider.currentFiles.length + 1, // +1 para botão voltar
    itemBuilder: (context, index) {
      if (index == 0 && sshProvider.currentPath != '/') {
        return _buildBackButton();
      }
      
      final fileIndex = sshProvider.currentPath != '/' ? index - 1 : index;
      final file = sshProvider.currentFiles[fileIndex];
      
      return SshFileListTile(
        file: file,
        onTap: () => _handleFileTap(file),
      );
    },
  );
}
```

### Ações de Clique
- **Diretório**: `sshProvider.navigateToDirectory(file.fullPath)`
- **Executável**: Preparar para execução (implementado na Fase 3)
- **Arquivo regular**: Preparar para visualização (implementado na Fase 3)
- **Botão Voltar**: Navegar para diretório pai

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () => sshProvider.refreshCurrentDirectory(),
  child: _buildFileList(),
)
```

### Próxima Fase
Após completar esta tarefa, a **Fase 2** estará completa. Prosseguir para a **Fase 3: Interação com Ficheiros e Execução** com a **Issue #10: Execução de Scripts e Binários**.