#!/bin/bash

# Script de teste para validar funcionalidade de execução remota
# Este script pode ser usado para testar a funcionalidade de execução implementada

echo "=== Teste de Execução Easy SSH Mob ==="
echo "Timestamp: $(date)"
echo "Usuário: $(whoami)"
echo "Diretório atual: $(pwd)"
echo "Sistema: $(uname -a)"

echo ""
echo "=== Testes de Saída ==="
echo "Stdout: Esta é a saída padrão"
echo "Testando caracteres especiais: @#$%^&*()"
echo "Linha com\ttab"
echo "Linha com    espaços múltiplos"

echo ""
echo "=== Teste de Múltiplas Linhas ==="
for i in {1..5}; do
    echo "Linha $i de saída"
    sleep 0.1
done

echo ""
echo "=== Teste de Stderr ==="
echo "Esta mensagem vai para stderr" >&2

echo ""
echo "=== Teste de Comandos ==="
echo "Listando arquivos do diretório atual:"
ls -la

echo ""
echo "=== Informações do Sistema ==="
echo "Espaço em disco:"
df -h . 2>/dev/null || echo "df não disponível"

echo "Memória:"
free -h 2>/dev/null || echo "free não disponível"

echo ""
echo "=== Finalizando Teste ==="
echo "Teste concluído com sucesso!"
echo "Exit code será: 0"

exit 0