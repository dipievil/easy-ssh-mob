#!/bin/bash

echo "🔧 Testando navegação do botão de configurações..."

# Verificar se as telas existem
echo "📁 Verificando arquivos..."
if [ -f "lib/screens/settings_screen.dart" ]; then
    echo "✅ SettingsScreen encontrada"
else
    echo "❌ SettingsScreen não encontrada"
fi

if [ -f "lib/screens/file_explorer_screen.dart" ]; then
    echo "✅ FileExplorerScreen encontrada"
else
    echo "❌ FileExplorerScreen não encontrada"
fi

# Verificar se as rotas estão configuradas
echo "🛠️ Verificando rotas..."
if grep -q "/settings" lib/main.dart; then
    echo "✅ Rota /settings configurada"
else
    echo "❌ Rota /settings não encontrada"
fi

# Verificar se o botão está implementado
echo "🔘 Verificando botão..."
if grep -q "_showTools" lib/screens/file_explorer_screen.dart; then
    echo "✅ Método _showTools encontrado"
else
    echo "❌ Método _showTools não encontrado"
fi

if grep -q "pushNamed.*settings" lib/screens/file_explorer_screen.dart; then
    echo "✅ Navegação para settings implementada"
else
    echo "❌ Navegação para settings não encontrada"
fi

echo "🚀 Teste de navegação completo!"
