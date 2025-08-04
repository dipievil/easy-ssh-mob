import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/notification_service.dart';
import '../widgets/error_widgets.dart';
import 'notification_settings_screen.dart';

/// Demo screen showing how to use the new notification system
class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Notificações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.gear),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demonstração do Sistema de Notificações',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // SnackBar Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SnackBars',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            FontAwesomeIcons.circleInfo,
                            size: 16,
                          ),
                          label: const Text('Info'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            CustomSnackBar.show(
                              context,
                              'Esta é uma informação importante',
                              NotificationType.info,
                            );
                            _notificationService.showNotification(
                              message: 'Esta é uma informação importante',
                              type: NotificationType.info,
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            FontAwesomeIcons.circleCheck,
                            size: 16,
                          ),
                          label: const Text('Sucesso'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            CustomSnackBar.show(
                              context,
                              'Operação realizada com sucesso!',
                              NotificationType.success,
                            );
                            _notificationService.showNotification(
                              message: 'Operação realizada com sucesso!',
                              type: NotificationType.success,
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            FontAwesomeIcons.triangleExclamation,
                            size: 16,
                          ),
                          label: const Text('Aviso'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () {
                            CustomSnackBar.show(
                              context,
                              'Atenção: Esta ação pode ter consequências',
                              NotificationType.warning,
                            );
                            _notificationService.showNotification(
                              message:
                                  'Atenção: Esta ação pode ter consequências',
                              type: NotificationType.warning,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            FontAwesomeIcons.circleXmark,
                            size: 16,
                          ),
                          label: const Text('Erro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            CustomSnackBar.show(
                              context,
                              'Erro ao processar solicitação',
                              NotificationType.error,
                              action: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ação de retry executada'),
                                  ),
                                );
                              },
                              actionLabel: 'RETRY',
                            );
                            _notificationService.showNotification(
                              message: 'Erro ao processar solicitação',
                              type: NotificationType.error,
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            FontAwesomeIcons.exclamation,
                            size: 16,
                          ),
                          label: const Text('Crítico'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                          ),
                          onPressed: () {
                            CustomSnackBar.show(
                              context,
                              'CRÍTICO: Falha grave do sistema',
                              NotificationType.critical,
                            );
                            _notificationService.showNotification(
                              message: 'CRÍTICO: Falha grave do sistema',
                              type: NotificationType.critical,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dialog Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diálogos de Notificação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.windowMaximize),
                      label: const Text('Mostrar Diálogo de Erro'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CustomNotificationDialog(
                            title: 'Erro de Conexão',
                            message:
                                'Não foi possível conectar ao servidor SSH',
                            type: NotificationType.error,
                            details:
                                'Timeout: Connection to 192.168.1.100:22 timed out after 30 seconds.\nPlease check your network connection and server status.',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Toast Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Toast Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.message),
                      label: const Text('Mostrar Toast'),
                      onPressed: () {
                        ToastNotification.show(
                          context,
                          'Esta é uma notificação toast não-intrusiva',
                          NotificationType.info,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading Overlay Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loading Overlay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.spinner),
                      label: const Text('Mostrar Loading'),
                      onPressed: () {
                        LoadingOverlay.show(
                          context,
                          'Processando comando...',
                          onCancel: () {
                            LoadingOverlay.hide();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Operação cancelada'),
                              ),
                            );
                          },
                        );

                        // Simular operação
                        Future.delayed(const Duration(seconds: 3), () {
                          LoadingOverlay.hide();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
