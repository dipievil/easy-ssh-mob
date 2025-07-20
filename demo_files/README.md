# Ficheiros de Demonstração - Visualizador de Ficheiros

Este diretório contém ficheiros de exemplo criados para demonstrar e testar as funcionalidades do **Visualizador de Ficheiros** do Easy SSH Mob.

## Como Usar

1. **Execute o aplicativo Easy SSH Mob**
2. **Conecte-se ao seu servidor SSH**
3. **Navegue até este diretório** (`demo_files/`)
4. **Clique nos ficheiros de texto** para abrir no visualizador

## Ficheiros Incluídos

### 📄 `readme.txt`
- **Tipo**: Ficheiro de texto simples
- **Conteúdo**: Descrição das funcionalidades implementadas
- **Teste**: Navegação básica, busca de texto

### ⚙️ `config.conf`
- **Tipo**: Ficheiro de configuração
- **Conteúdo**: Configurações de exemplo de servidor SSH
- **Teste**: Detecção automática de tipo, formatação preservada

### 📊 `data.json`
- **Tipo**: Dados estruturados JSON
- **Conteúdo**: Metadados da aplicação em formato JSON
- **Teste**: Formatação de JSON, busca em dados estruturados

### 📋 `aplicacao.log`
- **Tipo**: Ficheiro de log
- **Conteúdo**: Logs de exemplo da aplicação
- **Teste**: Visualização de logs, busca de eventos específicos

### ⚡ `script_exemplo.sh`
- **Tipo**: Script executável
- **Conteúdo**: Script bash de demonstração
- **Teste**: Detecção como executável E visualização de conteúdo
- **Nota**: Este ficheiro pode ser tanto executado quanto visualizado

### 📚 `documentacao.md`
- **Tipo**: Markdown/Documentação
- **Conteúdo**: Documentação detalhada do visualizador
- **Teste**: Formatação de markdown, busca em documentação

## Cenários de Teste Recomendados

### 1. Detecção Automática de Tipos
- **Ação**: Observe os ícones diferentes para cada tipo
- **Esperado**: 📄 azul para ficheiros de texto, ⚡ verde para executáveis

### 2. Abertura de Ficheiros
- **Ação**: Clique em qualquer ficheiro de texto
- **Esperado**: Abertura imediata no FileViewerScreen

### 3. Funcionalidade de Busca
- **Ação**: Abra `readme.txt` → clique no ícone 🔍 → busque "funcionalidades"
- **Esperado**: Resultados destacados, navegação entre resultados

### 4. Cópia de Conteúdo
- **Ação**: Abra qualquer ficheiro → clique no ícone 📋
- **Esperado**: Conteúdo copiado para área de transferência

### 5. Menu de Opções
- **Ação**: Abra qualquer ficheiro → clique no menu ⋮
- **Esperado**: Opções "Atualizar", "Ver início", "Ver final"

### 6. Seleção de Texto
- **Ação**: Abra qualquer ficheiro → selecione texto manualmente
- **Esperado**: Possibilidade de copiar texto específico

### 7. Comportamento com Executáveis
- **Ação**: Clique em `script_exemplo.sh`
- **Esperado**: Opção de executar OU visualizar conteúdo

## Comandos de Teste Manual

Se conectado via terminal SSH, você pode testar os comandos que o aplicativo usa:

```bash
# Verificar tamanho dos ficheiros
stat -c%s *.txt *.conf *.json

# Simular leitura completa
cat readme.txt

# Simular leitura parcial (primeiras linhas)
head -10 aplicacao.log

# Simular leitura parcial (últimas linhas)  
tail -10 aplicacao.log

# Contar linhas
wc -l *
```

## Regenerar Ficheiros

Para recriar todos os ficheiros de demonstração:

```bash
cd /caminho/para/projeto
./scripts/demo_file_viewer.sh
```

## Estrutura de Teste

```
demo_files/
├── readme.txt          # Texto simples
├── config.conf         # Configuração
├── data.json           # Dados JSON
├── aplicacao.log       # Logs de aplicação
├── script_exemplo.sh   # Script executável
├── documentacao.md     # Documentação markdown
└── README.md          # Este ficheiro
```

## Resolução de Problemas

### Ficheiro não abre como texto
- **Causa**: Tipo não detectado como texto
- **Solução**: Verifique se a extensão está na lista suportada

### Erro ao carregar ficheiro
- **Causa**: Permissões ou conectividade
- **Solução**: Verifique permissões SSH e conexão

### Busca não funciona
- **Causa**: Ficheiro vazio ou busca case-sensitive
- **Solução**: Tente termos diferentes, busca é case-insensitive

---

**Criado automaticamente pelo script `scripts/demo_file_viewer.sh`**