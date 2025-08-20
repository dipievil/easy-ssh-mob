# FileExplorerScreen - Interface Implementada

## Estrutura da Tela

### AppBar
- **Título**: Mostra o caminho atual do diretório (ex: `/home/user`)
- **Botão Home** (🏠): Navega para o diretório home do usuário
- **Botão Ferramentas** (⚙️): Abre menu com opções:
  - Logout (com opções de esquecer credenciais)
  - Atualizar diretório
- **Indicador de Status**: 
  - 📶 Verde = Conectado
  - 📶 Vermelho = Desconectado  
  - ⏳ = Conectando

### Body Principal
**Estado Conectado:**
```
📁 [Ícone grande de pasta]

Diretório: /home/user

A lista de ficheiros será implementada na próxima fase.

[Botão Voltar] (se houver histórico)
```

**Estado Loading:**
```
⏳ [Spinner de carregamento]

Carregando diretório...
```

**Estado de Erro:**
```
⚠️ [Ícone de erro]

Erro de Conexão

[Mensagem específica do erro]

[Botão: Tentar Novamente]
```

**Estado Desconectado:**
```
📶❌ [Ícone wifi off]

Desconectado

A conexão SSH foi perdida.
```

### FloatingActionButton
- **Ícone**: 🔄 (Refresh)
- **Função**: Atualiza o diretório atual

## Funcionalidades Implementadas

✅ StatefulWidget reativo ao SshProvider
✅ AppBar dinâmica com caminho atual
✅ Botões Home e Ferramentas funcionais
✅ Indicadores visuais de status da conexão
✅ Estados de loading, error e desconexão
✅ Histórico de navegação básico
✅ Menu de ferramentas com logout
✅ Integração SSH para comandos de navegação
✅ FloatingActionButton para atualizar
✅ Layout responsivo Material 3

## Navegação Implementada

1. **Login bem-sucedido** → Redireciona para FileExplorerScreen
2. **Botão Home** → Executa `cd && pwd` via SSH
3. **Botão Voltar** → Volta para diretório anterior no histórico
4. **Logout** → Volta para LoginScreen com opções de esquecer credenciais

## Integração com SshProvider

- Escuta mudanças de estado da conexão via Consumer
- Executa comandos SSH para navegação (`pwd`, `cd && pwd`)
- Trata erros de conexão automaticamente
- Atualiza UI em tempo real conforme estado da conexão