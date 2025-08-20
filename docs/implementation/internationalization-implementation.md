# Multi-localização / Internationalization

Este projeto agora suporta multi-localização usando o pacote oficial de internacionalização do Flutter.

## Idiomas Suportados

- 🇧🇷 Português Brasileiro (pt)
- 🇺🇸 Inglês (en)

## Como Funciona

O app detecta automaticamente o idioma do sistema do usuário e exibe as strings na linguagem correspondente. Se o idioma do sistema não for suportado, o app usa inglês como padrão.

## Estrutura de Arquivos

```
lib/l10n/
├── app_en.arb    # Strings em inglês (template)
└── app_pt.arb    # Strings em português brasileiro
```

## Como Usar nas Telas

Para usar uma string localizada em qualquer widget:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MinhaTela extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // Usará "Settings" em EN ou "Configurações" em PT
      ),
      body: Text(l10n.notifications), // Usará "Notifications" em EN ou "Notificações" em PT
    );
  }
}
```

## Como Adicionar Novas Strings

1. Adicione a string no arquivo `lib/l10n/app_en.arb`:
```json
{
  "novaString": "New String",
  "@novaString": {
    "description": "Description of what this string is for"
  }
}
```

2. Adicione a tradução no arquivo `lib/l10n/app_pt.arb`:
```json
{
  "novaString": "Nova String"
}
```

3. Execute `flutter gen-l10n` para regenerar os arquivos de localização.

4. Use a string no código:
```dart
Text(l10n.novaString)
```

## Como Adicionar um Novo Idioma

Para adicionar suporte a espanhol (es), por exemplo:

1. Crie o arquivo `lib/l10n/app_es.arb` com as traduções
2. Adicione o locale no `main.dart`:
```dart
supportedLocales: const [
  Locale('en'),
  Locale('pt'),
  Locale('es'), // Novo idioma
],
```

## Strings Já Localizadas

As seguintes telas já têm suas strings principais localizadas:

- **SettingsScreen**: Título, seções de conexão, menus de configuração
- **NotificationSettingsScreen**: Título, tipos de notificação, descrições

## Testando Diferentes Idiomas

Para testar o app em diferentes idiomas:

### No simulador iOS:
1. Settings > General > Language & Region > iPhone Language
2. Escolha o idioma desejado

### No emulador Android:
1. Settings > System > Languages & input > Languages
2. Adicione e/ou reordene os idiomas

### No código (para debug):
```dart
MaterialApp(
  locale: Locale('pt'), // Força português
  // ou
  locale: Locale('en'), // Força inglês
  // ...
)
```