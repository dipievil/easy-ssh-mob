import 'package:flutter/material.dart';
import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/file_explorer_screen.dart';
import 'providers/ssh_provider.dart';
import 'themes/app_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
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

            provider.initialize();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'EasySSH',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
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
