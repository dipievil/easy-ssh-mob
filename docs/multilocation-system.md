# Sistema de Multilocalização

Este documento descreve como usar o sistema de multilocalização implementado no projeto EasySSH.

## Configuração

O sistema de multilocalização foi configurado usando o sistema oficial do Flutter com:

- **flutter_localizations**: SDK do Flutter para localização
- **intl**: Pacote para internacionalização
- Arquivos ARB para definir traduções
- Geração automática de classes Dart

## Idiomas Suportados

- **Português (Brasil)** - `pt_BR` (padrão)
- **Inglês (Estados Unidos)** - `en_US`

## Estrutura de Arquivos

```
lib/l10n/
├── app_en.arb              # Traduções em inglês (template)
├── app_pt.arb              # Traduções em português
├── app_localizations.dart  # Classe base abstrata
├── app_localizations_en.dart # Implementação em inglês
└── app_localizations_pt.dart # Implementação em português
```

## Como Usar

### 1. Acessar traduções em um Widget

```dart
import '../l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.appTitle); // "EasySSH"
  }
}
```

### 2. Usar o serviço de localização

```dart
import '../services/localization_service.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationService.of(context);
    
    return Text(l10n.settings); // "Configurações" ou "Settings"
  }
}
```

### 3. Validações localizadas

```dart
String? _validateHost(String? value) {
  final l10n = AppLocalizations.of(context)!;
  if (value == null || value.trim().isEmpty) {
    return l10n.hostIpRequired; // "Host/IP é obrigatório" ou "Host/IP is required"
  }
  return null;
}
```

## Adicionando Novas Traduções

### 1. Adicionar ao arquivo ARB em inglês (template)

Edite `lib/l10n/app_en.arb`:

```json
{
  "newKey": "English text",
  "@newKey": {
    "description": "Description of what this text is for"
  }
}
```

### 2. Adicionar ao arquivo ARB em português

Edite `lib/l10n/app_pt.arb`:

```json
{
  "newKey": "Texto em português"
}
```

### 3. Adicionar à classe abstrata

Edite `lib/l10n/app_localizations.dart`:

```dart
/// Description of what this text is for
///
/// In en, this message translates to:
/// **'English text'**
String get newKey;
```

### 4. Implementar nas classes específicas

Em `lib/l10n/app_localizations_en.dart`:
```dart
@override
String get newKey => 'English text';
```

Em `lib/l10n/app_localizations_pt.dart`:
```dart
@override
String get newKey => 'Texto em português';
```

## Geração Automática (Futuro)

O projeto está configurado para gerar automaticamente as classes quando o Flutter SDK estiver disponível:

```bash
flutter gen-l10n
```

## Mudança de Idioma

O aplicativo detecta automaticamente o idioma do sistema. Para implementar mudança manual de idioma, seria necessário:

1. Criar um provider de configurações
2. Salvar a preferência do usuário
3. Usar a propriedade `locale` do MaterialApp

## Strings Localizadas Disponíveis

### Interface Principal
- `appTitle`: Título da aplicação
- `loginTitle`: Título da tela de login
- `settings`: Configurações
- `connect`: Conectar
- `cancel`: Cancelar
- `save`: Salvar

### Campos de Formulário
- `host`: Host
- `port`: Porta
- `username`: Usuário/Username
- `password`: Senha/Password
- `rememberCredentials`: Lembrar credenciais

### Mensagens de Status
- `connecting`: Conectando...
- `connected`: Conectado
- `disconnected`: Desconectado
- `loading`: Carregando...

### Mensagens de Erro e Validação
- `hostIpRequired`: Host/IP é obrigatório
- `portRequired`: Porta é obrigatória
- `usernameRequired`: Usuário é obrigatório
- `passwordRequired`: Senha é obrigatória

### Outros
- `notifications`: Notificações
- `sessionLog`: Log da Sessão
- `fileExplorer`: Explorador de Arquivos
- `terminal`: Terminal

## Boas Práticas

1. **Sempre use contexto**: As traduções dependem do contexto do widget
2. **Descrições claras**: Adicione descrições nos arquivos ARB para facilitar traduções
3. **Consistência**: Use as mesmas strings para textos similares
4. **Validação**: Teste com diferentes idiomas para garantir que o layout não quebra
5. **Pluralização**: Para textos que variam com quantidade, use as funcionalidades avançadas do sistema intl

## Exemplo de Implementação Completa

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LocalizedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Column(
        children: [
          Text(l10n.currentConnection),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.connect),
          ),
        ],
      ),
    );
  }
}
```

Este sistema garante que toda a interface do usuário seja apresentada no idioma apropriado, melhorando a experiência do usuário em diferentes regiões.