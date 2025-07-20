# Visualizador de Ficheiros

## Visão Geral

O **Visualizador de Ficheiros** é uma nova funcionalidade do Easy SSH Mob que permite visualizar o conteúdo de ficheiros de texto diretamente na aplicação móvel, proporcionando uma experiência intuitiva para utilizadores sem conhecimentos avançados de SSH.

## Funcionalidades Implementadas

### 1. Detecção Automática de Tipos de Ficheiro

O sistema detecta automaticamente ficheiros de texto baseado em:

**Extensões Suportadas:**
- `.txt`, `.log`, `.md` (documentos de texto)
- `.conf`, `.cfg`, `.ini`, `.properties` (configurações)
- `.json`, `.xml`, `.yml`, `.yaml` (dados estruturados)
- `.sh`, `.py`, `.js`, `.rb`, `.pl` (scripts)
- `.html`, `.css`, `.sql` (web e base de dados)
- `.env`, `.gitignore`, `.dockerfile` (ficheiros de projeto)

**Ficheiros Sem Extensão:**
- `README`, `LICENSE`, `CHANGELOG`
- `Makefile`, `Dockerfile`

### 2. Modos de Visualização

#### Ficheiro Completo (< 1MB)
- Exibe todo o conteúdo do ficheiro
- Carregamento rápido e navegação fluida
- Ideal para ficheiros de configuração e documentação

#### Head Mode (Ficheiros Grandes)
- Mostra as primeiras 100 linhas
- Útil para ver cabeçalhos e configurações iniciais
- Indicador visual de conteúdo truncado

#### Tail Mode (Ficheiros Grandes)
- Mostra as últimas 100 linhas
- Ideal para logs recentes
- Atualização em tempo real (opcional)

### 3. Interface de Utilizador

#### FileViewerScreen
- AppBar com nome do ficheiro e ações rápidas
- ScrollView com suporte a texto longo
- Fonte monospace para preservar formatação
- Indicadores visuais de status e modo de visualização

#### Integração com FileExplorerScreen
- Ícones diferenciados por tipo de ficheiro:
  - 📄 Azul: Ficheiros de texto (clicáveis para visualizar)
  - ⚡ Verde: Ficheiros executáveis
  - 📁 Azul: Diretórios
  - ℹ️ Cinza: Outros ficheiros (mostram informações)
- Legendas descritivas ("Arquivo de texto", "Pode ser executável")

### 4. Funcionalidades de Busca

#### Dialog de Busca
- Campo de texto com foco automático
- Busca case-insensitive
- Suporte a termos parciais

#### Navegação de Resultados
- Contador de resultados encontrados
- Botões próximo/anterior
- Scroll automático para resultado selecionado
- Feedback visual na AppBar

### 5. Operações de Cópia

#### Cópia Completa
- Botão na AppBar para copiar todo o conteúdo
- Feedback via SnackBar
- Integração com área de transferência do sistema

#### Seleção de Texto
- Widget SelectableText permite seleção manual
- Copy/paste nativo do sistema operacional
- Preservação de formatação

### 6. Gestão de Ficheiros Grandes

#### Detecção de Tamanho
- Comando `stat` para verificar tamanho antes de ler
- Limite configurável (1MB por defeault)
- Escolha automática de modo de visualização

#### Otimização de Performance
- Carregamento progressivo para ficheiros grandes
- Cache de conteúdo recentemente visualizado
- Gestão de memória eficiente

## Arquitetura Técnica

### Modelos

#### FileContent
```dart
class FileContent {
  final String content;
  final bool isTruncated;
  final int totalLines;
  final int displayedLines;
  final FileViewMode mode;
  final int? fileSize;
}
```

#### FileViewMode
```dart
enum FileViewMode {
  full,      // Ficheiro completo
  head,      // Primeiras linhas
  tail,      // Últimas linhas
  truncated  // Conteúdo truncado
}
```

### Extensões do SshFile

#### Detecção de Tipos
```dart
extension on SshFile {
  bool get isTextFile { /* detecção por extensão e nome */ }
}
```

### Métodos do SshProvider

#### Leitura de Ficheiros
```dart
Future<FileContent> readFile(SshFile file);
Future<FileContent> readFileWithMode(SshFile file, FileViewMode mode);
```

## Comandos SSH Utilizados

### Verificação de Tamanho
```bash
stat -f%z "caminho/ficheiro" 2>/dev/null || stat -c%s "caminho/ficheiro"
```

### Leitura Completa
```bash
cat "caminho/ficheiro"
```

### Leitura Parcial
```bash
head -100 "caminho/ficheiro"  # Primeiras 100 linhas
tail -100 "caminho/ficheiro"  # Últimas 100 linhas
```

### Contagem de Linhas
```bash
wc -l "caminho/ficheiro"
```

## Fluxo de Utilização

1. **Navegação**: Utilizador navega pelos diretórios
2. **Detecção**: Sistema identifica ficheiros de texto (ícone azul 📄)
3. **Clique**: Utilizador clica no ficheiro de texto
4. **Verificação**: Sistema verifica tamanho e permissões
5. **Carregamento**: Conteúdo é carregado com modo apropriado
6. **Visualização**: FileViewerScreen exibe o conteúdo
7. **Interação**: Utilizador pode buscar, copiar ou navegar

## Tratamento de Erros

### Cenários Cobertos
- Ficheiro não encontrado
- Permissões insuficientes
- Ficheiro muito grande
- Erro de conectividade SSH
- Timeout de operação

### Mensagens de Erro
- Feedback claro e em português
- Sugestões de ação quando possível
- Botão "Tentar Novamente" para erros temporários

## Testes Implementados

### Testes Unitários
- **FileContent**: Criação, igualdade, copyWith, descrições
- **SshFile**: Detecção de tipos de ficheiro de texto
- **Integração**: Métodos do SshProvider (mocked)

### Cenários de Teste
- Ficheiros pequenos vs. grandes
- Diferentes tipos de extensão
- Ficheiros sem extensão
- Ficheiros binários (não devem abrir como texto)
- Busca com diferentes termos
- Operações de cópia

## Configuração e Personalização

### Limites Configuráveis
```dart
const maxFileSize = 1024 * 1024; // 1MB
const defaultLinesCount = 100;   // Linhas para head/tail
```

### Extensões de Texto
Lista facilmente extensível de extensões suportadas no método `isTextFile`.

## Benefícios para o Utilizador

1. **Simplicidade**: Não requer conhecimentos de comandos SSH
2. **Rapidez**: Visualização imediata sem downloads
3. **Mobilidade**: Interface otimizada para dispositivos móveis
4. **Segurança**: Operações somente de leitura
5. **Eficiência**: Gestão inteligente de ficheiros grandes

## Melhorias Futuras

### Funcionalidades Planejadas
- [ ] Suporte a encoding personalizado
- [ ] Highlight de sintaxe por tipo de ficheiro
- [ ] Modo escuro/claro personalizado
- [ ] Cache persistente de ficheiros visualizados
- [ ] Suporte a `tail -f` para logs em tempo real
- [ ] Exportação de conteúdo para dispositivo local

### Otimizações
- [ ] Paginação para ficheiros muito grandes
- [ ] Carregamento lazy de secções
- [ ] Compressão de cache
- [ ] Pré-carregamento de ficheiros relacionados