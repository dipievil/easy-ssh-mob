import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';
import '../providers/ssh_provider.dart';
import 'notification_settings_screen.dart';
import 'session_log_screen.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Connection Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<SshProvider>(
                  builder: (context, sshProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.server,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.currentConnection,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.desktop),
                          title: Text(
                              '${l10n.host}: ${sshProvider.currentCredentials?.host ?? 'N/A'}'),
                          subtitle: Text(
                              '${l10n.port}: ${sshProvider.currentCredentials?.port ?? 'N/A'}'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.user),
                          title: Text(
                              '${l10n.user}: ${sshProvider.currentCredentials?.username ?? 'N/A'}'),
                          subtitle: Text(
                            '${l10n.status}: ${sshProvider.isConnected ? l10n.connected : l10n.disconnected}',
                          ),
                          contentPadding: EdgeInsets.zero,
                          trailing: Icon(
                            sshProvider.isConnected
                                ? FontAwesomeIcons.wifi
                                : FontAwesomeIcons.xmark,
                            color: sshProvider.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings Options
            Expanded(
              child: ListView(
                children: [
                  // Notification Settings
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.bell),
                    title: Text(l10n.notifications),
                    subtitle: Text(l10n.notificationsSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Session Log
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.clockRotateLeft),
                    title: Text(l10n.sessionLog),
                    subtitle: Text(l10n.sessionLogSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SessionLogScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // App Info
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.circleInfo),
                    title: Text(l10n.aboutApp),
                    subtitle: Text(l10n.aboutAppSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAboutDialog(context),
                  ),

                  const Divider(),

                  // Clear Credentials
                  Consumer<SshProvider>(
                    builder: (context, sshProvider, child) {
                      return ListTile(
                        leading: const Icon(
                          FontAwesomeIcons.trash,
                          color: Colors.red,
                        ),
                        title: Text(
                          l10n.clearCredentials,
                          style: const TextStyle(color: Colors.red),
                        ),
                        subtitle: Text(l10n.clearCredentialsSubtitle),
                        onTap: () =>
                            _showClearCredentialsDialog(context, sshProvider),
                      );
                    },
                  ),

                  const Divider(),

                  // Logout
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.rightFromBracket,
                      color: Colors.orange,
                    ),
                    title: Text(
                      l10n.logout,
                      style: const TextStyle(color: Colors.orange),
                    ),
                    subtitle: const Text('Desconectar do servidor'),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EasySSH',
      applicationVersion: '1.0.1',
      applicationIcon: const Icon(
        FontAwesomeIcons.terminal,
        size: 48,
        color: Colors.deepPurple,
      ),
      children: [
        const Text('Cliente SSH simples e intuitivo para dispositivos móveis.'),
        const SizedBox(height: 16),
        const Text('Desenvolvido com Flutter 💙'),
      ],
    );
  }

  void _showClearCredentialsDialog(
      BuildContext context, SshProvider sshProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Credenciais'),
        content: const Text(
          'Tem certeza de que deseja esquecer todas as credenciais salvas? '
          'Você precisará inserir os dados de login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await sshProvider.logout(forgetCredentials: true);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credenciais removidas com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Deseja desconectar do servidor SSH? '
          'Você retornará à tela de login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final sshProvider =
                  Provider.of<SshProvider>(context, listen: false);
              sshProvider.disconnect();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
