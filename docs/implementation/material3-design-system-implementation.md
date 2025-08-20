# Material 3 Design System - EasySSH

Esta documentação descreve a implementação completa do Material 3 design system no EasySSH, incluindo temas, componentes personalizados, sistema de ícones e animações.

## 📁 Estrutura dos Arquivos

```
lib/
├── themes/
│   └── app_theme.dart           # Configuração de temas Material 3
├── utils/
│   ├── file_icon_manager.dart   # Sistema avançado de ícones
│   ├── custom_animations.dart   # Animações personalizadas
│   └── responsive_breakpoints.dart # Sistema responsivo
└── widgets/
    └── custom_components.dart   # Componentes UI personalizados
```

## 🎨 Sistema de Temas

### Configuração Principal
- **Arquivo**: `lib/themes/app_theme.dart`
- **Temas**: Claro e escuro com alternância automática do sistema
- **Base**: Material 3 com ColorScheme.fromSeed()
- **Cores**: Azul Material como cor primária

### Classes de Cores

#### StateColors
- `success`: Verde para ações bem-sucedidas
- `warning`: Laranja para avisos
- `error`: Vermelho para erros
- `info`: Azul para informações

#### FileTypeColors
- `document`: Roxo para documentos
- `spreadsheet`: Verde para planilhas
- `presentation`: Laranja para apresentações
- `image`: Rosa para imagens
- `video`: Vermelho para vídeos
- `audio`: Roxo para áudio
- `archive`: Marrom para arquivos
- `code`: Azul para código
- `config`: Âmbar para configuração
- `executable`: Verde claro para executáveis
- `directory`: Azul para diretórios
- `symlink`: Roxo para links simbólicos

## 🎯 Sistema de Ícones

### FileIconManager
- **Arquivo**: `lib/utils/file_icon_manager.dart`
- **Suporte**: 100+ extensões de arquivo
- **Fallbacks**: Ícones inteligentes para tipos desconhecidos
- **Categorização**: Cores semânticas por tipo de arquivo

### Mapeamento de Extensões

#### Documentos
- `.pdf`, `.doc`, `.docx` → FontAwesome file icons
- `.txt`, `.md`, `.rtf` → Text file icons

#### Código
- `.py` → Python icon
- `.js`, `.ts` → JavaScript icon
- `.html` → HTML5 icon
- `.css` → CSS3 icon
- `.dart` → Code icon

#### Mídia
- `.jpg`, `.png`, `.gif` → Image icons
- `.mp4`, `.avi`, `.mkv` → Video icons
- `.mp3`, `.wav`, `.flac` → Audio icons

#### Arquivos
- `.zip`, `.rar`, `.tar` → Archive icons
- `.exe`, `.sh` → Executable icons

### Métodos Principais

```dart
// Obter ícone para arquivo
IconData icon = FileIconManager.getIconForFile(sshFile);

// Obter cor para arquivo
Color color = FileIconManager.getColorForFile(sshFile, context);

// Verificar tipo de arquivo
bool isImage = FileIconManager.isImageFile(fileName);
bool isCode = FileIconManager.isCodeFile(fileName);
```

## 🧩 Componentes Personalizados

### SshCard
Card personalizado com estilo SSH.

```dart
SshCard(
  onTap: () => action(),
  child: Text('Conteúdo'),
)
```

### GradientAppBar
AppBar com gradiente personalizado.

```dart
GradientAppBar(
  title: 'Título',
  actions: [IconButton(...)],
)
```

### SshLoadingIndicator
Indicador de loading temático.

```dart
SshLoadingIndicator(
  message: 'Carregando...',
  progress: 0.5, // opcional
)
```

### AnimatedSshFab
FAB com animações.

```dart
AnimatedSshFab(
  icon: Icons.add,
  onPressed: () => action(),
)
```

### StatusCard
Card para mostrar status com ícone.

```dart
StatusCard(
  title: 'Sucesso',
  subtitle: 'Operação concluída',
  type: StatusType.success,
)
```

### SshListTile
ListTile melhorado com estilo SSH.

```dart
SshListTile(
  leading: Icon(Icons.folder),
  title: Text('Item'),
  subtitle: Text('Descrição'),
  onTap: () => action(),
)
```

### SshTextField
Campo de texto estilizado.

```dart
SshTextField(
  labelText: 'Usuário',
  prefixIcon: Icons.person,
  controller: controller,
)
```

## 🎬 Animações

### Transições de Página

#### SlideRoute
```dart
Navigator.push(
  context,
  SlideRoute(
    page: NewScreen(),
    direction: AxisDirection.left,
  ),
);
```

#### FadeRoute
```dart
Navigator.push(
  context,
  FadeRoute(page: NewScreen()),
);
```

#### ScaleRoute
```dart
Navigator.push(
  context,
  ScaleRoute(page: NewScreen()),
);
```

### Animações de Widget

#### BouncyScale
```dart
BouncyScale(
  onTap: () => action(),
  child: Widget(),
)
```

#### SlideInAnimation
```dart
SlideInAnimation(
  delay: Duration(milliseconds: 100),
  direction: AxisDirection.up,
  child: Widget(),
)
```

#### StaggeredListAnimation
```dart
StaggeredListAnimation(
  children: [Widget1(), Widget2(), Widget3()],
  itemDelay: Duration(milliseconds: 100),
)
```

#### ShimmerAnimation
```dart
ShimmerAnimation(
  child: Container(
    width: 200,
    height: 20,
    color: Colors.grey,
  ),
)
```

## 📱 Sistema Responsivo

### ResponsiveBreakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 1024px
- **Desktop**: 1024px - 1440px
- **Large Desktop**: > 1440px

### Métodos Utilitários

```dart
// Verificar tamanho da tela
bool isMobile = ResponsiveBreakpoints.isMobile(context);
bool isTablet = ResponsiveBreakpoints.isTablet(context);
bool isDesktop = ResponsiveBreakpoints.isDesktop(context);

// Obter colunas para grid
int columns = ResponsiveBreakpoints.getGridColumns(context);

// Obter padding responsivo
EdgeInsets padding = ResponsiveBreakpoints.getScreenPadding(context);

// Obter espaçamento responsivo
double spacing = ResponsiveBreakpoints.getSpacing(context);
```

### Widgets Responsivos

#### ResponsiveBuilder
```dart
ResponsiveBuilder(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

#### ResponsiveContainer
```dart
ResponsiveContainer(
  child: Widget(),
  applyPadding: true,
  constrainWidth: true,
)
```

#### ResponsiveGrid
```dart
ResponsiveGrid(
  children: [...],
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
)
```

#### ResponsiveText
```dart
ResponsiveText(
  'Texto',
  mobileScale: 1.0,
  tabletScale: 1.1,
  desktopScale: 1.2,
)
```

## 🚀 Como Usar

### 1. Importar Temas
```dart
import 'package:easyssh/themes/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

### 2. Usar Componentes
```dart
import 'package:easyssh/widgets/custom_components.dart';
import 'package:easyssh/utils/custom_animations.dart';

// Em suas telas
SshCard(
  child: SshListTile(
    title: Text('Item'),
    onTap: () => action(),
  ),
)
```

### 3. Aplicar Responsividade
```dart
import 'package:easyssh/utils/responsive_breakpoints.dart';

ResponsiveContainer(
  child: ResponsiveGrid(
    children: items.map((item) => ItemWidget(item)).toList(),
  ),
)
```

### 4. Adicionar Animações
```dart
import 'package:easyssh/utils/custom_animations.dart';

SlideInAnimation(
  child: MyWidget(),
  delay: Duration(milliseconds: 100),
)
```

## 🎯 Exemplo Completo

```dart
import 'package:flutter/material.dart';
import 'package:easyssh/widgets/custom_components.dart';
import 'package:easyssh/utils/custom_animations.dart';
import 'package:easyssh/utils/responsive_breakpoints.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Exemplo',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => refresh(),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: StaggeredListAnimation(
          children: [
            SshCard(
              child: SshListTile(
                leading: Icon(Icons.folder),
                title: Text('Pasta'),
                subtitle: Text('Descrição'),
                onTap: () => openFolder(),
              ),
            ),
            StatusCard(
              title: 'Status',
              subtitle: 'Tudo funcionando',
              type: StatusType.success,
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSshFab(
        icon: Icons.add,
        onPressed: () => addItem(),
      ),
    );
  }
}
```

## 🔧 Personalização

### Alterar Cores Primárias
```dart
// Em app_theme.dart
static const Color _primarySeedColor = Color(0xFF2196F3); // Sua cor
```

### Adicionar Novos Ícones
```dart
// Em file_icon_manager.dart
static const Map<String, IconData> _extensionIcons = {
  '.newext': FontAwesomeIcons.newIcon,
  // ...
};
```

### Criar Novos Componentes
```dart
// Em custom_components.dart
class MyCustomWidget extends StatelessWidget {
  // Implementação
}
```

## 📋 Checklist de Implementação

- [x] ✅ Material 3 themes (claro/escuro)
- [x] ✅ Sistema de ícones (100+ extensões)
- [x] ✅ Componentes UI personalizados
- [x] ✅ Animações e transições
- [x] ✅ Sistema responsivo
- [x] ✅ Cores semânticas por tipo
- [x] ✅ FileExplorerScreen atualizada
- [x] ✅ Documentação completa

## 🚀 Próximos Passos

1. Aplicar componentes em outras telas
2. Adicionar mais animações específicas
3. Implementar Dynamic Color (Android 12+)
4. Expandir sistema de ícones
5. Adicionar testes para componentes

---

Esta implementação fornece uma base sólida e moderna para a interface do EasySSH, seguindo as melhores práticas do Material 3 e proporcionando uma experiência de usuário consistente e intuitiva.