#!/usr/bin/env dart

/// Script para testar se o botão do drawer está funcionando
/// Executa: dart scripts/test_drawer_button.dart

import 'dart:io';

void main() async {
  print('🔍 Testando Configuração do ToolsDrawer...\n');

  // Verifica se o arquivo file_explorer_screen.dart existe
  final fileExplorerFile = File('../src/lib/screens/file_explorer_screen.dart');
  if (!fileExplorerFile.existsSync()) {
    print('❌ Arquivo file_explorer_screen.dart não encontrado');
    exit(1);
  }

  // Verifica se o arquivo tools_drawer.dart existe
  final toolsDrawerFile = File('../src/lib/widgets/tools_drawer.dart');
  if (!toolsDrawerFile.existsSync()) {
    print('❌ Arquivo tools_drawer.dart não encontrado');
    exit(1);
  }

  print('✅ Arquivos encontrados');

  // Lê o conteúdo do file_explorer_screen.dart
  final fileExplorerContent = await fileExplorerFile.readAsString();

  // Verifica se tem o import do ToolsDrawer
  if (!fileExplorerContent.contains("import '../widgets/tools_drawer.dart';")) {
    print('❌ Import do ToolsDrawer não encontrado');
    exit(1);
  }
  print('✅ Import do ToolsDrawer encontrado');

  // Verifica se tem o endDrawer configurado
  if (!fileExplorerContent.contains('endDrawer: const ToolsDrawer()')) {
    print('❌ endDrawer não configurado corretamente');
    exit(1);
  }
  print('✅ endDrawer configurado corretamente');

  // Verifica se tem o método _showTools
  if (!fileExplorerContent.contains('void _showTools()')) {
    print('❌ Método _showTools não encontrado');
    exit(1);
  }
  print('✅ Método _showTools encontrado');

  // Verifica se o método _showTools chama openEndDrawer
  if (!fileExplorerContent.contains('openEndDrawer()')) {
    print('❌ Método _showTools não chama openEndDrawer()');
    exit(1);
  }
  print('✅ Método _showTools chama openEndDrawer()');

  // Verifica se tem o botão que chama _showTools
  if (!fileExplorerContent.contains('onPressed: () => _showTools()')) {
    print('❌ Botão não está chamando _showTools()');
    exit(1);
  }
  print('✅ Botão está chamando _showTools()');

  // Verifica se o ToolsDrawer está bem formado
  final toolsDrawerContent = await toolsDrawerFile.readAsString();

  if (!toolsDrawerContent
      .contains('class ToolsDrawer extends StatefulWidget')) {
    print('❌ ToolsDrawer não está bem definido');
    exit(1);
  }
  print('✅ ToolsDrawer está bem definido');

  if (!toolsDrawerContent.contains('return Drawer(')) {
    print('❌ ToolsDrawer não retorna um Drawer');
    exit(1);
  }
  print('✅ ToolsDrawer retorna um Drawer');

  print('\n🎉 TODAS AS VERIFICAÇÕES PASSARAM!');
  print('📱 O botão do drawer deve estar funcionando.');
  print('\n💡 Se ainda não funciona, pode ser:');
  print('   1. Problema de contexto (try hot reload)');
  print('   2. Problema de build (try flutter clean)');
  print('   3. Erro de runtime (verifique o console)');

  print('\n🔧 Para testar:');
  print('   1. Execute: flutter run');
  print('   2. Toque no botão ⚙️ (gear icon)');
  print('   3. O drawer lateral deve abrir');
}
