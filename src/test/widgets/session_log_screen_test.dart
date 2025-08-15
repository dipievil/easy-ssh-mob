import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:easy_ssh_mob_new/screens/session_log_screen.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import '../test_helpers/platform_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerPlatformMocks();
  });

  group('SessionLogScreen', () {
    late SshProvider sshProvider;

    setUp(() {
      sshProvider = SshProvider();
    });

    testWidgets('should create SessionLogScreen widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const SessionLogScreen(),
          ),
        ),
      );

      // Apenas verifica se o widget existe
      expect(find.byType(SessionLogScreen), findsOneWidget);
    });

    testWidgets('should display basic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: sshProvider,
            child: const SessionLogScreen(),
          ),
        ),
      );

      // Verifica estrutura básica sem elementos específicos
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
