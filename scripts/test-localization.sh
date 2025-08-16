#!/bin/bash

# Script para testar a localização do EasySSH
# Este script verifica se as strings foram traduzidas corretamente

echo "🌍 Teste de Localização - EasySSH"
echo "================================="
echo

# Verifica se os arquivos ARB existem
echo "📁 Verificando arquivos de localização..."

if [ -f "lib/l10n/app_en.arb" ]; then
    echo "✅ Arquivo inglês encontrado: lib/l10n/app_en.arb"
else
    echo "❌ Arquivo inglês não encontrado"
    exit 1
fi

if [ -f "lib/l10n/app_pt.arb" ]; then
    echo "✅ Arquivo português encontrado: lib/l10n/app_pt.arb"
else
    echo "❌ Arquivo português não encontrado"
    exit 1
fi

echo

# Conta quantas strings estão definidas
EN_STRINGS=$(grep -c '"[a-zA-Z]' lib/l10n/app_en.arb)
PT_STRINGS=$(grep -c '"[a-zA-Z]' lib/l10n/app_pt.arb)

echo "📊 Estatísticas de tradução:"
echo "   Inglês (EN): $EN_STRINGS strings"
echo "   Português (PT): $PT_STRINGS strings"

if [ "$EN_STRINGS" -eq "$PT_STRINGS" ]; then
    echo "✅ Mesmo número de strings nos dois idiomas"
else
    echo "⚠️  Número diferente de strings - algumas traduções podem estar faltando"
fi

echo

# Mostra algumas strings traduzidas como exemplo
echo "🔍 Exemplos de strings traduzidas:"
echo "   settings:"
echo "     EN: $(grep '"settings"' lib/l10n/app_en.arb | cut -d'"' -f4)"
echo "     PT: $(grep '"settings"' lib/l10n/app_pt.arb | cut -d'"' -f4)"
echo
echo "   notifications:"
echo "     EN: $(grep '"notifications"' lib/l10n/app_en.arb | cut -d'"' -f4)"
echo "     PT: $(grep '"notifications"' lib/l10n/app_pt.arb | cut -d'"' -f4)"
echo
echo "   currentConnection:"
echo "     EN: $(grep '"currentConnection"' lib/l10n/app_en.arb | cut -d'"' -f4)"
echo "     PT: $(grep '"currentConnection"' lib/l10n/app_pt.arb | cut -d'"' -f4)"

echo
echo "✨ Teste de localização concluído!"
echo "Para ver a localização em ação, execute o app em dispositivos"
echo "configurados com idiomas diferentes (PT-BR e EN)."