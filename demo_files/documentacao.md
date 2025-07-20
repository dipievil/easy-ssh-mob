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
