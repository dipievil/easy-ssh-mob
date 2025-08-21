import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/utils/app_version.dart';
import 'notification_settings_screen.dart';
import 'notification_test_screen.dart';
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
                              '${l10n.host}: ${sshProvider.currentCredentials?.host ?? l10n.notAvailable}'),
                          subtitle: Text(
                              '${l10n.port}: ${sshProvider.currentCredentials?.port ?? l10n.notAvailable}'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.user),
                          title: Text(
                              '${l10n.user}: ${sshProvider.currentCredentials?.username ?? l10n.notAvailable}'),
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
            Expanded(
              child: ListView(
                children: [
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
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.circleInfo),
                    title: Text(l10n.aboutApp),
                    subtitle: Text(l10n.aboutAppSubtitle),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(),
                  if (true)
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.flask),
                      title: Text(l10n.notificationTest),
                      subtitle: Text(l10n.notificationTestSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationTestScreen(),
                          ),
                        );
                      },
                    ),
                  const Divider(),
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
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.rightFromBracket,
                      color: Colors.orange,
                    ),
                    title: Text(
                      l10n.logout,
                      style: const TextStyle(color: Colors.orange),
                    ),
                    subtitle: Text(l10n.disconnectFromServer),
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

  void _showAboutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appName = await AppVersion.getAppName();
    final versionString = await AppVersion.getVersionString();
    final buildNumber = await AppVersion.getBuildNumber();
    final packageName = await AppVersion.getPackageName();

    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: appName,
        applicationVersion: versionString,
        applicationIcon: const Icon(
          FontAwesomeIcons.terminal,
          size: 48,
          color: Colors.deepPurple,
        ),
        children: [
          Text(l10n.appDescription),
          const SizedBox(height: 16),
          Text(l10n.developedWithFlutter),
          const SizedBox(height: 12),
          Text(
            '${l10n.buildLabel}: $buildNumber',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '${l10n.packageLabel}: $packageName',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }
  }

  void _showClearCredentialsDialog(
      BuildContext context, SshProvider sshProvider) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCredentialsDialogTitle),
        content: Text(l10n.clearCredentialsDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await sshProvider.logout(forgetCredentials: true);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.credentialsRemovedSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutDialogTitle),
        content: Text(l10n.logoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final sshProvider =
                  Provider.of<SshProvider>(context, listen: false);
              sshProvider.disconnect();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
