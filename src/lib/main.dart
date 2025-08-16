import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/file_explorer_screen.dart';
import 'providers/ssh_provider.dart';
import 'themes/app_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  // Load environment file if present. If missing, catch the error so the app
  // doesn't crash on startup when running on a device without the file.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Keep startup silent but log to console for debugging.
    // This is expected when running an installed build that doesn't include
    // the local .env file.
    // ignore: avoid_print
    print('No .env file found: $e');
  }

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
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('pt'),
        ],
        home: const LoginScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/file-explorer': (context) => const FileExplorerScreen(),
        },
      ),
    );
  }
}
