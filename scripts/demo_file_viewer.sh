#!/bin/bash

# Script de demonstração do Visualizador de Ficheiros
# Este script cria ficheiros de exemplo para testar a funcionalidade

echo "=== Demonstração do Visualizador de Ficheiros ==="
echo

# Criar diretório de demonstração
DEMO_DIR="demo_files"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

echo "Criando ficheiros de demonstração..."
echo

# 1. Ficheiro de texto simples
cat > readme.txt << 'EOF'
# Easy SSH Mob - Visualizador de Ficheiros

Este é um ficheiro de demonstração para testar o visualizador de ficheiros.

## Funcionalidades Implementadas

1. **Detecção Automática de Ficheiros de Texto**
   - Suporte para extensões comuns (.txt, .log, .conf, .json, etc.)
   - Detecção de ficheiros sem extensão (README, LICENSE, etc.)

2. **Modos de Visualização**
   - Completo: ficheiros pequenos (< 1MB)
   - Head: primeiras 100 linhas de ficheiros grandes
   - Tail: últimas 100 linhas de ficheiros grandes

3. **Funcionalidades de Busca**
   - Busca de texto case-insensitive
   - Navegação entre resultados
   - Destaque de resultados encontrados

4. **Operações de Cópia**
   - Copiar todo o conteúdo
   - Seleção de texto específico

5. **Interface Intuitiva**
   - Ícones diferentes para tipos de ficheiro
   - Indicadores de status (carregamento, erros)
   - Menu de ações na AppBar

## Como Usar

1. Conecte-se ao servidor SSH
2. Navegue pelos diretórios
3. Clique em ficheiros de texto para visualizar
4. Use os ícones na AppBar para buscar, copiar ou atualizar
5. Use o menu de opções para ver início/final de ficheiros grandes

Teste clicando neste ficheiro no explorador de ficheiros!
EOF

echo "✓ Criado readme.txt (ficheiro de texto simples)"

# 2. Ficheiro de configuração
cat > config.conf << 'EOF'
# Configuração do servidor SSH
[server]
host=exemplo.com
port=22
timeout=30

[security]
enable_encryption=true
key_exchange=diffie-hellman
cipher=aes256

[logging]
level=info
file=/var/log/ssh.log
max_size=10MB
rotation=daily

[users]
admin=enabled
guest=disabled
backup=enabled

# Comentários são suportados
# Esta configuração é apenas para demonstração
EOF

echo "✓ Criado config.conf (ficheiro de configuração)"

# 3. Ficheiro JSON
cat > data.json << 'EOF'
{
  "aplicacao": "Easy SSH Mob",
  "versao": "1.0.0",
  "descricao": "Gerenciador de ficheiros SSH multiplataforma",
  "funcionalidades": [
    "Navegação de diretórios",
    "Execução de scripts",
    "Visualização de ficheiros de texto",
    "Terminal integrado"
  ],
  "suporte_ficheiros": {
    "texto": [
      ".txt", ".log", ".conf", ".json", ".xml", 
      ".yml", ".yaml", ".md", ".sh", ".py"
    ],
    "executaveis": [
      ".sh", ".py", ".pl", ".rb", ".js"
    ]
  },
  "configuracao": {
    "limite_tamanho": "1MB",
    "linhas_preview": 100,
    "encoding": "UTF-8"
  }
}
EOF

echo "✓ Criado data.json (ficheiro JSON)"

# 4. Log de exemplo
cat > aplicacao.log << 'EOF'
2024-01-20 10:00:01 [INFO] Aplicação iniciada
2024-01-20 10:00:02 [DEBUG] Carregando configurações...
2024-01-20 10:00:03 [INFO] Conexão SSH estabelecida com servidor
2024-01-20 10:00:05 [DEBUG] Navegando para diretório home
2024-01-20 10:00:10 [INFO] Listando conteúdo do diretório /home/user
2024-01-20 10:00:15 [DEBUG] Encontrados 25 ficheiros
2024-01-20 10:00:20 [INFO] Usuário clicou em ficheiro readme.txt
2024-01-20 10:00:21 [DEBUG] Verificando se ficheiro é de texto...
2024-01-20 10:00:22 [INFO] Abrindo visualizador de ficheiros
2024-01-20 10:00:23 [DEBUG] Lendo conteúdo do ficheiro
2024-01-20 10:00:24 [INFO] Ficheiro carregado com sucesso (1234 bytes)
2024-01-20 10:00:30 [INFO] Usuário realizou busca por "configuração"
2024-01-20 10:00:31 [DEBUG] Encontrados 3 resultados
2024-01-20 10:00:35 [INFO] Usuário copiou conteúdo para área de transferência
2024-01-20 10:01:00 [INFO] Sessão finalizada

Este é um exemplo de ficheiro de log que pode ser visualizado
no aplicativo. Logs são úteis para debugging e monitoramento.
EOF

echo "✓ Criado aplicacao.log (ficheiro de log)"

# 5. Script shell
cat > script_exemplo.sh << 'EOF'
#!/bin/bash

# Script de exemplo para demonstrar detecção de executáveis
echo "Este é um script executável!"
echo "Data atual: $(date)"
echo "Usuário: $(whoami)"
echo "Diretório atual: $(pwd)"

# O aplicativo detecta este ficheiro como executável
# e permite tanto executar quanto visualizar o conteúdo
EOF

chmod +x script_exemplo.sh
echo "✓ Criado script_exemplo.sh (script executável)"

# 6. Ficheiro markdown
cat > documentacao.md << 'EOF'
# Documentação do Visualizador de Ficheiros

## Visão Geral

O **Visualizador de Ficheiros** é uma funcionalidade do Easy SSH Mob que permite 
visualizar o conteúdo de ficheiros de texto diretamente na aplicação, sem 
necessidade de conhecimentos avançados de SSH.

## Tipos de Ficheiro Suportados

### Extensões Automaticamente Detectadas

- **Texto**: `.txt`, `.log`, `.md`
- **Configuração**: `.conf`, `.cfg`, `.ini`, `.properties`
- **Dados**: `.json`, `.xml`, `.yml`, `.yaml`
- **Scripts**: `.sh`, `.py`, `.js`, `.rb`, `.pl`
- **Web**: `.html`, `.css`, `.sql`

### Ficheiros Sem Extensão

- `README`, `LICENSE`, `CHANGELOG`
- `Makefile`, `Dockerfile`
- `.gitignore`, `.env`

## Interface do Utilizador

### AppBar Actions

1. **🔍 Buscar**: Encontrar texto no ficheiro
2. **📋 Copiar**: Copiar todo o conteúdo
3. **⋮ Menu**: Opções adicionais
   - 🔄 Atualizar
   - ⬆️ Ver início
   - ⬇️ Ver final

### Indicadores de Status

- **🔵 Azul**: Ficheiro de texto (clique para visualizar)
- **🟢 Verde**: Ficheiro executável (clique para executar)
- **🔗 Roxo**: Link simbólico
- **📁 Azul**: Diretório (clique para navegar)

## Limitações

- Ficheiros maiores que 1MB são truncados
- Apenas ficheiros de texto são suportados
- Binários não podem ser visualizados

---

**Desenvolvido com ❤️ para simplificar o gerenciamento SSH**
EOF

echo "✓ Criado documentacao.md (ficheiro markdown)"

echo
echo "=== Ficheiros de Demonstração Criados ==="
echo "Diretório: $(pwd)"
echo "Total de ficheiros: $(ls -1 | wc -l)"
echo
echo "Para testar:"
echo "1. Conecte-se ao servidor SSH através da aplicação"
echo "2. Navegue até este diretório ($PWD)"
echo "3. Clique nos ficheiros .txt, .conf, .json, .log, .md para visualizar"
echo "4. Teste as funcionalidades de busca e cópia"
echo "5. Compare o comportamento entre ficheiros pequenos e grandes"
echo
echo "Ficheiros criados:"
ls -la

cd ..
echo
echo "Demonstração configurada com sucesso!"