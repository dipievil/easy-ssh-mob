import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/notification_service.dart';
import '../widgets/error_widgets.dart';

/// Screen for configuring notification settings
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationService _notificationService;
  bool _soundEnabled = true;
  double _soundVolume = 0.7;
  bool _vibrateEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _notificationService.initialize();
    setState(() {
      _soundEnabled = _notificationService.soundEnabled;
      _soundVolume = _notificationService.soundVolume;
      _vibrateEnabled = _notificationService.vibrateEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await _notificationService.updateSoundSettings(enabled: value);
  }

  Future<void> _setSoundVolume(double value) async {
    setState(() => _soundVolume = value);
    await _notificationService.updateSoundSettings(volume: value);
  }

  Future<void> _toggleVibrate(bool value) async {
    setState(() => _vibrateEnabled = value);
    await _notificationService.updateVibrateSettings(value);
  }

  Future<void> _showTestNotifications() async {
    final types = [
      NotificationType.info,
      NotificationType.success,
      NotificationType.warning,
      NotificationType.error,
      NotificationType.critical,
    ];

    for (int i = 0; i < types.length; i++) {
      final type = types[i];
      await _notificationService.showNotification(
        message: _getTestMessage(type),
        type: type,
      );

      // Show visual notification
      if (mounted) {
        CustomSnackBar.show(context, _getTestMessage(type), type);
      }

      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  String _getTestMessage(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return 'Esta é uma notificação informativa';
      case NotificationType.success:
        return 'Operação realizada com sucesso!';
      case NotificationType.warning:
        return 'Atenção: isto é um aviso';
      case NotificationType.error:
        return 'Ocorreu um erro na operação';
      case NotificationType.critical:
        return 'CRÍTICO: Falha grave do sistema';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações de Notificação')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sound Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.volumeHigh,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Configurações de Som',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Sons de Alerta'),
                    subtitle: const Text('Tocar sons para notificações'),
                    value: _soundEnabled,
                    onChanged: _toggleSound,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_soundEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Volume dos Alertas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: _soundVolume,
                      onChanged: _setSoundVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_soundVolume * 100).round()}%',
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vibration Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.mobileScreen,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Configurações de Vibração',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Vibração'),
                    subtitle: const Text('Vibrar para alertas importantes'),
                    value: _vibrateEnabled,
                    onChanged: _toggleVibrate,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Test Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.flask,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Testar Notificações',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Testar Todos os Tipos'),
                    subtitle: const Text(
                      'Demonstra diferentes tipos de alerta',
                    ),
                    trailing: const Icon(FontAwesomeIcons.play),
                    onTap: _showTestNotifications,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.circleInfo,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tipos de Notificação',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationTypeInfo(
                    'Info',
                    'Informações gerais',
                    Colors.blue,
                    FontAwesomeIcons.circleInfo,
                  ),
                  _buildNotificationTypeInfo(
                    'Sucesso',
                    'Operações bem-sucedidas',
                    Colors.green,
                    FontAwesomeIcons.circleCheck,
                  ),
                  _buildNotificationTypeInfo(
                    'Aviso',
                    'Situações que requerem atenção',
                    Colors.orange,
                    FontAwesomeIcons.triangleExclamation,
                  ),
                  _buildNotificationTypeInfo(
                    'Erro',
                    'Problemas durante operações',
                    Colors.red,
                    FontAwesomeIcons.circleXmark,
                  ),
                  _buildNotificationTypeInfo(
                    'Crítico',
                    'Falhas graves do sistema',
                    Colors.red.shade900,
                    FontAwesomeIcons.exclamation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeInfo(
    String name,
    String description,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            '$name: ',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
