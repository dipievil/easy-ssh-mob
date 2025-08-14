#!/bin/bash

echo "🔧 Verificando implementação da Fase 4..."

echo ""
echo "📋 CHECKLIST DE IMPLEMENTAÇÃO:"

echo ""
echo "=== Issue 13: Botão Home e Menu de Ferramentas ==="

# Botão Home
if grep -q "_isAtHome" src/lib/screens/file_explorer_screen.dart; then
    echo "✅ Botão Home: Lógica de detecção implementada"
else
    echo "❌ Botão Home: Lógica de detecção não encontrada"
fi

if grep -q "FontAwesomeIcons.house" src/lib/screens/file_explorer_screen.dart; then
    echo "✅ Botão Home: Ícone correto implementado"
else
    echo "❌ Botão Home: Ícone não encontrado"
fi

# Tools Drawer
if grep -q "endDrawer.*ToolsDrawer" src/lib/screens/file_explorer_screen.dart; then
    echo "✅ Tools Drawer: Configurado no Scaffold"
else
    echo "❌ Tools Drawer: Não configurado no Scaffold"
fi

if grep -q "Scaffold.of(context).openEndDrawer" src/lib/screens/file_explorer_screen.dart; then
    echo "✅ Botão Ferramentas: Abre drawer corretamente"
else
    echo "❌ Botão Ferramentas: Não abre drawer (pode navegar para settings)"
fi

# Comandos pré-definidos
if [ -f "src/lib/models/predefined_commands.dart" ]; then
    echo "✅ Comandos Pré-definidos: Arquivo existe"
    if grep -q "Informações.*Sistema.*Rede.*Logs" src/lib/models/predefined_commands.dart; then
        echo "✅ Comandos Pré-definidos: Categorias implementadas"
    else
        echo "⚠️ Comandos Pré-definidos: Verificar categorias"
    fi
else
    echo "❌ Comandos Pré-definidos: Arquivo não encontrado"
fi

# Comandos personalizados
if [ -f "src/lib/widgets/add_custom_command_dialog.dart" ]; then
    echo "✅ Comandos Personalizados: Dialog implementado"
else
    echo "❌ Comandos Personalizados: Dialog não encontrado"
fi

if [ -f "src/lib/services/custom_commands_service.dart" ]; then
    echo "✅ Comandos Personalizados: Service implementado"
else
    echo "❌ Comandos Personalizados: Service não encontrado"
fi

echo ""
echo "=== Issue 14: Sistema de Notificação ==="

if [ -f "src/lib/services/notification_service.dart" ]; then
    echo "✅ NotificationService: Implementado"
else
    echo "❌ NotificationService: Não encontrado"
fi

if [ -f "src/lib/screens/notification_settings_screen.dart" ]; then
    echo "✅ Tela de Configurações de Notificação: Implementada"
else
    echo "❌ Tela de Configurações de Notificação: Não encontrada"
fi

echo ""
echo "=== Issue 15: Design e Ícones ==="

if grep -q "useMaterial3.*true" src/lib/themes/app_theme.dart; then
    echo "✅ Material 3: Habilitado"
else
    echo "❌ Material 3: Não habilitado"
fi

if [ -f "src/lib/widgets/file_type_indicator.dart" ]; then
    echo "✅ Sistema de Ícones de Arquivos: Implementado"
else
    echo "❌ Sistema de Ícones de Arquivos: Não encontrado"
fi

echo ""
echo "=== PROBLEMAS IDENTIFICADOS ==="

# Verificar se o botão está navegando para settings em vez de abrir drawer
if grep -q "Navigator.pushNamed.*settings" src/lib/screens/file_explorer_screen.dart; then
    echo "🚨 CRÍTICO: Botão de ferramentas navega para settings em vez de abrir drawer!"
fi

echo ""
echo "=== RESUMO ==="
echo "Fase 4 parcialmente implementada."
echo "Principais problemas:"
echo "1. Botão de ferramentas deve abrir drawer, não navegar"
echo "2. Verificar se comandos SSH estão executando"
echo "3. Testar funcionalidade completa do ToolsDrawer"

echo ""
echo "🔧 Execute 'flutter run' e teste:"
echo "1. Toque no botão ⚙️ - deve abrir drawer lateral"
echo "2. Execute comandos no drawer"
echo "3. Adicione comandos personalizados"
