import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/notification_service.dart';
import '../widgets/error_widgets.dart';

/// Test screen for improved notification system
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  int _notificationCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Notificações Melhoradas'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card about improvements
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.circleInfo,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Melhorias Implementadas',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('✅ Botão de fechar em todas as notificações'),
                    const Text('✅ Som sincronizado com aparição visual'),
                    const Text('✅ Notificações anteriores são removidas'),
                    const Text('✅ Timing melhorado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Single notification tests
            Text(
              'Teste Individual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton(
                  'Sucesso',
                  Colors.green,
                  FontAwesomeIcons.circleCheck,
                  () => _showSingle(NotificationType.success),
                ),
                _buildTestButton(
                  'Info',
                  Colors.blue,
                  FontAwesomeIcons.circleInfo,
                  () => _showSingle(NotificationType.info),
                ),
                _buildTestButton(
                  'Aviso',
                  Colors.orange,
                  FontAwesomeIcons.triangleExclamation,
                  () => _showSingle(NotificationType.warning),
                ),
                _buildTestButton(
                  'Erro',
                  Colors.red,
                  FontAwesomeIcons.circleXmark,
                  () => _showSingle(NotificationType.error),
                ),
                _buildTestButton(
                  'Crítico',
                  Colors.red.shade900,
                  FontAwesomeIcons.skull,
                  () => _showSingle(NotificationType.critical),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Rapid fire test
            Text(
              'Teste de Acúmulo (Problema Anterior)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _testRapidFire,
              icon: const FaIcon(FontAwesomeIcons.bolt),
              label: const Text('Disparar 5 Notificações Rápidas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Antes: Sons tocavam antes das notificações aparecerem\n'
              'Agora: Som e visual sincronizados, apenas a última é mostrada',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Close test
            Text(
              'Teste de Botão Fechar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _testLongNotification,
              icon: const FaIcon(FontAwesomeIcons.clock),
              label: const Text('Notificação Longa (10s)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Clique no X para fechar antes do tempo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showSingle(NotificationType type) {
    _notificationCount++;

    CustomSnackBar.showWithClear(
      context,
      'Notificação ${type.name} #$_notificationCount',
      type,
      action: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação executada!')),
        );
      },
      actionLabel: 'AÇÃO',
    );
  }

  void _testRapidFire() {
    // Disparar 5 notificações em sequência rápida
    // Apenas a última deve aparecer e tocar som

    final types = [
      NotificationType.info,
      NotificationType.success,
      NotificationType.warning,
      NotificationType.error,
      NotificationType.critical,
    ];

    for (int i = 0; i < types.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          CustomSnackBar.showWithClear(
            context,
            'Disparo rápido ${i + 1}/5 - ${types[i].name}',
            types[i],
          );
        }
      });
    }
  }

  void _testLongNotification() {
    CustomSnackBar.showWithClear(
      context,
      'Esta notificação dura 10 segundos. Use o X para fechar!',
      NotificationType.warning,
      duration: const Duration(seconds: 10),
      action: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação da notificação longa!')),
        );
      },
      actionLabel: 'EXECUTAR',
    );
  }
}
