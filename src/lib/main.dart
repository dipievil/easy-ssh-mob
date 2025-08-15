import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/file_explorer_screen.dart';
import 'providers/ssh_provider.dart';
import 'themes/app_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(SentryWidget(child: const MyApp())),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = SshProvider();
            // Initialize the provider to load saved credentials
            // Note: This is fire-and-forget, but the provider will notify listeners when ready
            provider.initialize();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'EasySSH',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            ThemeMode.system, // Automatically switch based on system preference
        home: const LoginScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/file-explorer': (context) => const FileExplorerScreen(),
        },
      ),
    );
  }
}
