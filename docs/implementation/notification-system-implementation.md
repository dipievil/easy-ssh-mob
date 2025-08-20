# Sistema de Notificação - Easy SSH Mob

Este documento descreve como usar o novo sistema unificado de notificações implementado na Fase 4.2.

## Visão Geral

O sistema de notificação fornece uma forma centralizada de gerenciar todas as notificações da aplicação com alertas visuais e sonoros consistentes.

## Componentes Principais

### 1. NotificationService

Serviço singleton que centraliza todas as notificações:

```dart
final notificationService = NotificationService();
await notificationService.initialize();

// Mostrar notificação simples
await notificationService.showNotification(
  message: 'Operação concluída com sucesso',
  type: NotificationType.success,
);

// Notificação com detalhes e ação
await notificationService.showNotification(
  message: 'Erro ao conectar ao servidor',
  type: NotificationType.error,
  title: 'Erro de Conexão',
  details: 'Timeout após 30 segundos...',
  action: () => reconnect(),
  actionLabel: 'TENTAR NOVAMENTE',
);
```

### 2. Tipos de Notificação

```dart
enum NotificationType {
  info,      // Informações gerais (azul)
  warning,   // Avisos (laranja)  
  error,     // Erros (vermelho)
  success,   // Sucessos (verde)
  critical   // Críticos (vermelho escuro)
}
```

### 3. Widgets de Notificação

#### CustomSnackBar
```dart
CustomSnackBar.show(
  context,
  'Arquivo salvo com sucesso',
  NotificationType.success,
  action: () => openFile(),
  actionLabel: 'ABRIR',
);
```

#### CustomNotificationDialog
```dart
showDialog(
  context: context,
  builder: (context) => CustomNotificationDialog(
    title: 'Erro de Conexão',
    message: 'Não foi possível conectar ao servidor',
    type: NotificationType.error,
    details: 'Connection timeout after 30 seconds',
    onRetry: () => retry(),
  ),
);
```

#### ToastNotification
```dart
ToastNotification.show(
  context,
  'Comando executado',
  NotificationType.info,
  duration: Duration(seconds: 2),
);
```

#### LoadingOverlay
```dart
// Mostrar
LoadingOverlay.show(
  context,
  'Processando comando...',
  onCancel: () => cancelOperation(),
);

// Esconder
LoadingOverlay.hide();
```

### 4. Sistema de Sons

Cada tipo de notificação tem seu próprio som:
- `info.mp3` - Som suave para informações
- `warning.mp3` - Som médio para avisos
- `error.mp3` - Som alto para erros
- `success.mp3` - Som positivo para sucessos
- `critical.mp3` - Som urgente para críticos

```dart
// Testar todos os sons
await SoundManager.testAllSounds(0.7);

// Tocar som específico
await SoundManager.playNotificationSound(
  NotificationType.error, 
  0.8
);
```

### 5. Configurações do Usuário

Acesse a tela de configurações para:
- Habilitar/desabilitar sons
- Ajustar volume dos alertas
- Configurar vibração
- Testar todos os tipos de notificação

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NotificationSettingsScreen(),
  ),
);
```

## Integração com Código Existente

### No SSH Provider

```dart
class SshProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  void _handleSshError(SshError error) {
    // Notificação automática
    _notificationService.showNotification(
      message: error.userFriendlyMessage,
      type: _mapErrorToNotificationType(error.severity),
      title: 'Erro SSH',
      details: error.originalMessage,
    );
  }
}
```

### Em Telas e Widgets

```dart
class MyScreen extends StatefulWidget {
  void _handleSuccess() {
    NotificationService().showNotification(
      message: 'Operação realizada com sucesso!',
      type: NotificationType.success,
    );
    
    // Também mostrar visualmente
    CustomSnackBar.show(
      context,
      'Operação realizada com sucesso!',
      NotificationType.success,
    );
  }
}
```

## Configuração de Assets

Certifique-se de que os arquivos de som estão incluídos no `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/sounds/
    - assets/sounds/info.mp3
    - assets/sounds/warning.mp3
    - assets/sounds/error.mp3
    - assets/sounds/success.mp3
    - assets/sounds/critical.mp3
```

## Boas Práticas

1. **Use o NotificationService para sons e configurações**
2. **Use os widgets visuais para feedback imediato**
3. **Combine ambos para experiência completa**
4. **Respeite as configurações do usuário**
5. **Use tipos apropriados para cada situação**

## Exemplo Completo

```dart
Future<void> executeCommand(String command) async {
  // Mostrar loading
  LoadingOverlay.show(context, 'Executando comando...');
  
  try {
    final result = await sshClient.execute(command);
    
    // Esconder loading
    LoadingOverlay.hide();
    
    if (result.exitCode == 0) {
      // Sucesso
      NotificationService().showNotification(
        message: 'Comando executado com sucesso',
        type: NotificationType.success,
      );
      
      CustomSnackBar.show(
        context,
        'Comando executado com sucesso',
        NotificationType.success,
      );
    } else {
      // Erro
      NotificationService().showNotification(
        message: 'Erro ao executar comando',
        type: NotificationType.error,
        details: result.stderr,
      );
      
      showDialog(
        context: context,
        builder: (context) => CustomNotificationDialog(
          title: 'Erro de Execução',
          message: 'O comando falhou',
          type: NotificationType.error,
          details: result.stderr,
          onRetry: () => executeCommand(command),
        ),
      );
    }
  } catch (e) {
    LoadingOverlay.hide();
    
    NotificationService().showNotification(
      message: 'Falha crítica na execução',
      type: NotificationType.critical,
      details: e.toString(),
    );
  }
}
```

## Personalização

### Cores e Ícones por Tipo

| Tipo | Cor | Ícone | Som |
|------|-----|-------|-----|
| Info | Azul | info-circle | Suave |
| Warning | Laranja | exclamation-triangle | Médio |
| Error | Vermelho | times-circle | Alto |
| Success | Verde | check-circle | Positivo |
| Critical | Vermelho escuro | exclamation | Urgente |

### Duração Padrão

- Info/Success: 3-4 segundos
- Warning: 4-5 segundos
- Error: 5-6 segundos
- Critical: 8-10 segundos (ou persistente)