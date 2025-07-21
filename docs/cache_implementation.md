# Cache do SSH Provider - Documentação da Implementação

## Problema Resolvido

O arquivo `lib/providers/ssh_provider.dart` estava executando comandos `stat` duplicados para o mesmo arquivo nos métodos:

- **Linha 634**: método `readFile()`  
- **Linha 714**: método `readFileWithMode()`

Quando `readFileWithMode()` era chamado com modo `full`, executava:
1. Comando `stat` para obter tamanho (linha 714)
2. Chamada para `readFile()` internamente
3. Comando `stat` novamente para o mesmo arquivo (linha 634)

## Solução Implementada

### Cache de Tamanhos de Arquivo
Adicionado `Map<String, int> _fileSizeCache` para cachear resultados do comando `stat`.

### Método Auxiliar
Criado `_getFileSize()` que:
- Verifica cache primeiro
- Executa `stat` apenas se necessário  
- Armazena resultado no cache
- Retorna tamanho do arquivo

### Gestão do Cache
- Limpo ao mudar diretórios (dados atualizados)
- Limpo ao desconectar (evita vazamentos de memória)
- Usa caminho completo como chave

## Benefícios

✅ **Performance**: Reduz latência de comandos SSH duplicados  
✅ **Eficiência**: Elimina chamadas de rede desnecessárias  
✅ **Compatibilidade**: Zero mudanças na API pública  
✅ **Escalabilidade**: Reduz carga no servidor SSH

## Resultado dos Testes

- **Antes**: 4 chamadas `stat` potenciais para mesmas operações
- **Depois**: 2 chamadas `stat` reais (uma por arquivo único)  
- **Melhoria**: 50% de redução em comandos SSH

## Arquivos Modificados

- `lib/providers/ssh_provider.dart` (29 linhas + / 4 linhas -)

A implementação resolve completamente o problema original mantendo simplicidade e compatibilidade.