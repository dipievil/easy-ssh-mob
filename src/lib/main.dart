import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/ssh_provider.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
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
      ),
    );
  }
}
