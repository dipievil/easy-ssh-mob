import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/widgets/error_widgets.dart';
import 'package:easyssh/services/notification_service.dart';

void main() {
  group('CustomSnackBar Tests', () {
    testWidgets('should show snackbar with correct content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  'Test message',
                  NotificationType.info,
                );
              },
              child: const Text('Show Snackbar'),
            ),
          ),
        ),
      ));
      
      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      
      expect(find.text('Test message'), findsOneWidget);
    });
    
    testWidgets('should show snackbar with action', (WidgetTester tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  'Test message',
                  NotificationType.warning,
                  action: () => actionCalled = true,
                  actionLabel: 'ACTION',
                );
              },
              child: const Text('Show Snackbar'),
            ),
          ),
        ),
      ));
      
      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      
      expect(find.text('ACTION'), findsOneWidget);
      
      await tester.tap(find.text('ACTION'));
      expect(actionCalled, isTrue);
    });
  });
  
  group('CustomNotificationDialog Tests', () {
    testWidgets('should display dialog with correct content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const CustomNotificationDialog(
          title: 'Test Title',
          message: 'Test Message',
          type: NotificationType.error,
          details: 'Test Details',
        ),
      ));
      
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('Detalhes técnicos'), findsOneWidget);
    });
    
    testWidgets('should show retry button when provided', (WidgetTester tester) async {
      bool retryCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        home: CustomNotificationDialog(
          title: 'Test Title',
          message: 'Test Message',
          type: NotificationType.error,
          onRetry: () => retryCalled = true,
        ),
      ));
      
      expect(find.text('TENTAR NOVAMENTE'), findsOneWidget);
      
      await tester.tap(find.text('TENTAR NOVAMENTE'));
      expect(retryCalled, isTrue);
    });
  });
  
  group('ToastNotification Tests', () {
    testWidgets('should create and animate toast notification', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ToastNotification(
          message: 'Toast message',
          type: NotificationType.success,
          duration: Duration(milliseconds: 100),
        ),
      ));
      
      expect(find.text('Toast message'), findsOneWidget);
      
      // Test animation
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
  
  group('LoadingOverlay Tests', () {
    testWidgets('should display loading overlay with message', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoadingOverlay(
          message: 'Loading...',
          isVisible: true,
        ),
      ));
      
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should show cancel button when provided', (WidgetTester tester) async {
      bool cancelCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        home: LoadingOverlay(
          message: 'Loading...',
          isVisible: true,
          onCancel: () => cancelCalled = true,
        ),
      ));
      
      expect(find.text('CANCELAR'), findsOneWidget);
      
      await tester.tap(find.text('CANCELAR'));
      expect(cancelCalled, isTrue);
    });
  });
}