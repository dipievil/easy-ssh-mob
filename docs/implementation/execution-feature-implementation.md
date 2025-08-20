# Execução de Scripts e Binários - Fase 3.1

## Visão Geral

Esta implementação adiciona suporte completo para execução de scripts e binários remotos através da interface SSH, fornecendo feedback imediato e interfaces intuitivas para visualizar resultados.

## Funcionalidades Implementadas

### 1. Execução de Ficheiros

- **Clique para executar**: Ficheiros executáveis podem ser executados com um simples clique
- **Detecção automática**: Suporte para executáveis marcados e scripts (.sh, .py, .pl, .rb, .js)
- **Timeout configurável**: Prevenção de travamento com timeout padrão de 30 segundos
- **Tratamento de erros**: Captura separada de stdout, stderr e exit codes

### 2. Interface do Utilizador

#### ExecutionResultDialog
- Dialog modal para exibir resultados de execução
- Separação visual entre stdout e stderr com tabs
- Indicadores de sucesso/erro com cores e ícones
- Botões para copiar saída e abrir terminal
- Scroll para outputs longos

#### FileExplorerScreen Melhorado
- Indicadores visuais durante execução
- Progress indicators nos items executando
- Feedback imediato via SnackBar
- Desabilitação de interação durante execução

#### Terminal Interativo
- Interface terminal completa com tema escuro
- Execução de comandos customizados
- Histórico de comandos
- Scroll automático e clear history

### 3. Componentes Técnicos

#### ExecutionResult Model
```dart
class ExecutionResult {
  final String stdout;
  final String stderr;
  final int? exitCode;
  final Duration duration;
  final DateTime timestamp;
  
  bool get hasError;
  bool get isEmpty;
  String get combinedOutput;
  String get statusDescription;
}
```

#### SshProvider Extensions
- `executeFile(SshFile file, {Duration timeout})` - Execução principal
- `_buildScriptCommand(SshFile file)` - Detecção de interpretador
- `_executeCommandWithTimeout(String command, Duration timeout)` - Execução com timeout

### 4. Detecção de Executáveis

#### Métodos Suportados
1. **Ficheiros marcados**: `ls -F` mostra `*` para executáveis
2. **Extensões conhecidas**: .sh, .py, .pl, .rb, .js, .bat, .cmd
3. **Shebang detection**: Leitura da primeira linha para `#!/path/to/interpreter`

#### Interpretadores Suportados
- **Bash**: `bash "file.sh"`
- **Python**: `python3 "file.py"`
- **Perl**: `perl "file.pl"`
- **Ruby**: `ruby "file.rb"`
- **Node.js**: `node "file.js"`
- **Shebang custom**: Extrai interpretador da linha shebang

### 5. Indicadores Visuais

#### FileTypeIndicator Widget
- Cores específicas por tipo de ficheiro:
  - 🟦 Azul: Diretórios
  - 🟩 Verde: Executáveis
  - 🟪 Roxo: Links simbólicos
  - 🟧 Laranja: Scripts potencialmente executáveis
  - 🔵 Azul-petróleo: Ficheiros de configuração
  - ⚫ Cinza: Ficheiros regulares

## Fluxo de Utilização

### Execução Básica
1. Utilizador navega pelo sistema de ficheiros
2. Clica num ficheiro executável (marcado com ícone play)
3. Loading indicator aparece durante execução
4. ExecutionResultDialog exibe resultados
5. Opções para copiar output ou abrir terminal

### Terminal Avançado
1. Acesso via menu "Ferramentas" → "Terminal"
2. Interface de linha de comando completa
3. Execução de comandos arbitrários
4. Histórico persistente durante sessão
5. Tema escuro com fonte monospace

## Tratamento de Erros

### Cenários Cobertos
- **Conexão perdida**: Mensagem clara no ExecutionResult
- **Timeout de comando**: Captura e reporta timeout específico
- **Exit codes não-zero**: Identificação automática como erro
- **Ficheiros inexistentes**: Tratamento via try/catch
- **Permissões negadas**: Captura de stderr

### Feedback ao Utilizador
- SnackBar para feedback imediato
- Indicadores visuais de erro no dialog
- Cores diferenciadas para stdout vs stderr
- Mensagens de status descritivas

## Testes

### Cobertura Implementada
- **ExecutionResult**: Testes unitários completos
- **SshProvider**: Testes para executeFile quando desconectado
- **ExecutionResultDialog**: Testes de widget com diferentes cenários
- **TerminalScreen**: Testes de interface e interação
- **FileTypeIndicator**: Testes de rendering

### Cenários Testados
- Execução bem-sucedida vs com erro
- Outputs vazios vs com conteúdo
- Timeout de comandos
- Navegação entre dialog e terminal
- Clear de histórico terminal

## Arquitetura

### Padrões Utilizados
- **Provider Pattern**: State management via SshProvider
- **Widget Composition**: Componentes reutilizáveis e modulares
- **Separation of Concerns**: Models separados para dados
- **Error Handling**: Try/catch sistemático com feedback

### Extensibilidade
- Fácil adição de novos interpretadores em `_buildScriptCommand`
- Widget system permite customização visual
- Terminal pode ser expandido com mais funcionalidades
- Model ExecutionResult é extensível para novos campos

## Próximos Passos Sugeridos

1. **Melhorias de Performance**
   - Cache de resultados de execução
   - Execução assíncrona em background
   - Cancelamento de comandos longos

2. **Funcionalidades Avançadas**
   - Execução com argumentos customizados
   - Upload e execução de scripts locais
   - Agendamento de execuções
   - Logs persistentes

3. **Interface Avançada**
   - Syntax highlighting no terminal
   - Auto-complete de comandos
   - Shortcuts de teclado
   - Themes customizáveis

## Compatibilidade

- **Flutter**: >=2.19.0
- **Dart**: >=2.19.0
- **Dependências**: dartssh2, provider, flutter_secure_storage
- **Plataformas**: Android, iOS, Web, Desktop (via Flutter)