# Guia para Criação das Issues no GitHub

Este documento contém instruções detalhadas para criar todas as issues do projeto EasySSH no GitHub, seguindo as especificações do problema original.

## Metadados Obrigatórios

Para **TODAS** as issues, usar:
- **Label**: `enhancement`
- **Milestone**: `Primeira Versão`
- **Assignee**: `@Copilot`
- **Relacionamento**: Sempre referenciar a issue anterior com "Related to #X"

## Sequência de Criação das Issues

### Issues da Fase 1: Fundação e Conexão Principal

#### Issue #3: [Fase 1.1] Configuração do Projeto Flutter
```
Título: [Fase 1.1] Configuração do Projeto Flutter
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #1

[Copiar o conteúdo da Issue 3 do arquivo fase1_issues.md]
```

#### Issue #4: [Fase 1.2] Implementação do Ecrã de Conexão (Login)
```
Título: [Fase 1.2] Implementação do Ecrã de Conexão (Login)
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #3

[Copiar o conteúdo da Issue 4 do arquivo fase1_issues.md]
```

#### Issue #5: [Fase 1.3] Implementação da Lógica de Armazenamento Seguro
```
Título: [Fase 1.3] Implementação da Lógica de Armazenamento Seguro
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #4

[Copiar o conteúdo da Issue 5 do arquivo fase1_issues.md]
```

#### Issue #6: [Fase 1.4] Implementação do Serviço de Conexão SSH (Provider)
```
Título: [Fase 1.4] Implementação do Serviço de Conexão SSH (Provider)
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #5

[Copiar o conteúdo da Issue 6 do arquivo fase1_issues.md]
```

### Issues da Fase 2: Navegação por Diretórios

#### Issue #7: [Fase 2.1] Implementação do Ecrã do Explorador de Ficheiros
```
Título: [Fase 2.1] Implementação do Ecrã do Explorador de Ficheiros
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #6

[Copiar o conteúdo da Issue 7 do arquivo fase2_issues.md]
```

#### Issue #8: [Fase 2.2] Implementação da Listagem de Conteúdo do Diretório
```
Título: [Fase 2.2] Implementação da Listagem de Conteúdo do Diretório
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #7

[Copiar o conteúdo da Issue 8 do arquivo fase2_issues.md]
```

#### Issue #9: [Fase 2.3] Implementação da Geração Dinâmica de Botões
```
Título: [Fase 2.3] Implementação da Geração Dinâmica de Botões
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #8

[Copiar o conteúdo da Issue 9 do arquivo fase2_issues.md]
```

### Issues da Fase 3: Interação com Ficheiros e Execução

#### Issue #10: [Fase 3.1] Implementação da Execução de Scripts e Binários
```
Título: [Fase 3.1] Implementação da Execução de Scripts e Binários
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #9

[Copiar o conteúdo da Issue 10 do arquivo fase3_issues.md]
```

#### Issue #11: [Fase 3.2] Implementação do Visualizador de Ficheiros
```
Título: [Fase 3.2] Implementação do Visualizador de Ficheiros
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #10

[Copiar o conteúdo da Issue 11 do arquivo fase3_issues.md]
```

#### Issue #12: [Fase 3.3] Implementação do Tratamento de Erros de Permissão
```
Título: [Fase 3.3] Implementação do Tratamento de Erros de Permissão
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #11

[Copiar o conteúdo da Issue 12 do arquivo fase3_issues.md]
```

### Issues da Fase 4: UI/UX e Funcionalidades Adicionais

#### Issue #13: [Fase 4.1] Implementação do Botão "Home" e Menu de Ferramentas
```
Título: [Fase 4.1] Implementação do Botão "Home" e Menu de Ferramentas
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #12

[Copiar o conteúdo da Issue 13 do arquivo fase4_issues.md]
```

#### Issue #14: [Fase 4.2] Implementação do Sistema de Notificação de Erros
```
Título: [Fase 4.2] Implementação do Sistema de Notificação de Erros
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #13

[Copiar o conteúdo da Issue 14 do arquivo fase4_issues.md]
```

#### Issue #15: [Fase 4.3] Implementação do Design e Sistema de Ícones
```
Título: [Fase 4.3] Implementação do Design e Sistema de Ícones
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #14

[Copiar o conteúdo da Issue 15 do arquivo fase4_issues.md]
```

### Issues da Fase 5: Logging e Finalização

#### Issue #16: [Fase 5.1] Implementação do Sistema de Logging da Sessão
```
Título: [Fase 5.1] Implementação do Sistema de Logging da Sessão
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #15

[Copiar o conteúdo da Issue 16 do arquivo fase5_issues.md]
```

#### Issue #17: [Fase 5.2] Implementação de Testes e Refinamento Final
```
Título: [Fase 5.2] Implementação de Testes e Refinamento Final
Labels: enhancement
Milestone: Primeira Versão
Assignee: @Copilot
Related to: #16

[Copiar o conteúdo da Issue 17 do arquivo fase5_issues.md]
```

## Verificações Antes de Criar

Antes de criar cada issue, verificar:

1. **Milestone "Primeira Versão" existe**: Se não existir, criar primeiro
2. **Label "enhancement" existe**: Normalmente já existe por padrão
3. **Usuário @Copilot pode ser atribuído**: Verificar se o usuário está disponível no repositório

## Comandos CLI Alternativos (se aplicável)

Se tiver acesso ao GitHub CLI (`gh`), pode usar os seguintes comandos:

```bash
# Criar issue #3
gh issue create \
  --title "[Fase 1.1] Configuração do Projeto Flutter" \
  --body-file docs/issues/fase1_issue3_body.md \
  --label "enhancement" \
  --milestone "Primeira Versão" \
  --assignee "Copilot"

# Repetir para todas as issues...
```

## Ordem de Prioridade

As issues devem ser criadas na ordem sequencial (3, 4, 5, ..., 17) pois cada uma referencia a anterior. Isso mantém a estrutura de dependências correta.

## Estrutura dos Arquivos de Referência

- `docs/issues/fase1_issues.md` - Issues 3, 4, 5, 6
- `docs/issues/fase2_issues.md` - Issues 7, 8, 9  
- `docs/issues/fase3_issues.md` - Issues 10, 11, 12
- `docs/issues/fase4_issues.md` - Issues 13, 14, 15
- `docs/issues/fase5_issues.md` - Issues 16, 17

## Validação Final

Após criar todas as issues, verificar:

1. ✅ Todas têm label "enhancement"
2. ✅ Todas têm milestone "Primeira Versão"  
3. ✅ Todas têm assignee "@Copilot"
4. ✅ Cada issue referencia a anterior (exceto #3 que referencia #1)
5. ✅ Numeração sequencial está correta (3-17)
6. ✅ Conteúdo de cada issue está completo e detalhado

## Milestone "Primeira Versão"

Se o milestone não existir, criar com:
- **Título**: Primeira Versão
- **Descrição**: Implementação completa da primeira versão do EasySSH conforme IMPLEMENTATION_PLAN.md
- **Data de conclusão**: (opcional, mas recomendado definir uma meta)

## Contato e Suporte

Se houver problemas na criação das issues:
1. Verificar permissões no repositório
2. Confirmar que todos os metadados estão corretos  
3. Verificar se o conteúdo está formatado corretamente em Markdown
4. Consultar a documentação do GitHub sobre criação de issues

---

**Total de Issues a Criar**: 15 (Issues #3 a #17)
**Tempo Estimado**: 1-2 horas para criar todas manualmente
**Dependências**: Issue #1 (já existe), Milestone "Primeira Versão"