import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    
    setUp(() {
      notificationService = NotificationService();
    });
    
    test('should be a singleton', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      expect(instance1, equals(instance2));
    });
    
    test('should have default settings', () {
      expect(notificationService.soundEnabled, isTrue);
      expect(notificationService.soundVolume, equals(0.7));
      expect(notificationService.vibrateEnabled, isTrue);
    });
    
    test('should update sound settings', () async {
      await notificationService.updateSoundSettings(
        enabled: false,
        volume: 0.5,
      );
      
      expect(notificationService.soundEnabled, isFalse);
      expect(notificationService.soundVolume, equals(0.5));
    });
    
    test('should update vibration settings', () async {
      await notificationService.updateVibrateSettings(false);
      expect(notificationService.vibrateEnabled, isFalse);
    });
    
    test('should clamp volume between 0 and 1', () async {
      await notificationService.updateSoundSettings(volume: 1.5);
      expect(notificationService.soundVolume, equals(1.0));
      
      await notificationService.updateSoundSettings(volume: -0.5);
      expect(notificationService.soundVolume, equals(0.0));
    });
    
    test('NotificationConfig should have correct defaults', () {
      const config = NotificationConfig(type: NotificationType.info);
      
      expect(config.type, equals(NotificationType.info));
      expect(config.duration, equals(const Duration(seconds: 4)));
      expect(config.playSound, isTrue);
      expect(config.vibrate, isFalse);
      expect(config.persistent, isFalse);
    });
    
    test('NotificationItem should use provided config or create default', () {
      // With custom config
      const customConfig = NotificationConfig(
        type: NotificationType.error,
        duration: Duration(seconds: 10),
      );
      
      final itemWithConfig = NotificationItem(
        message: 'Test message',
        type: NotificationType.error,
        config: customConfig,
      );
      
      expect(itemWithConfig.config, equals(customConfig));
      
      // Without config (should create default)
      final itemWithoutConfig = NotificationItem(
        message: 'Test message',
        type: NotificationType.warning,
      );
      
      expect(itemWithoutConfig.config.type, equals(NotificationType.warning));
      expect(itemWithoutConfig.config.duration, equals(const Duration(seconds: 4)));
    });
    
    test('should track pending notifications', () {
      expect(notificationService.pendingNotifications, equals(0));
      
      // Note: We can't easily test the queue behavior without mocking
      // the async operations, but we can test the initial state
    });
    
    test('should clear notification queue', () {
      notificationService.clearQueue();
      expect(notificationService.pendingNotifications, equals(0));
    });
  });
  
  group('NotificationType Tests', () {
    test('should have all required types', () {
      expect(NotificationType.values.length, equals(5));
      expect(NotificationType.values, contains(NotificationType.info));
      expect(NotificationType.values, contains(NotificationType.warning));
      expect(NotificationType.values, contains(NotificationType.error));
      expect(NotificationType.values, contains(NotificationType.success));
      expect(NotificationType.values, contains(NotificationType.critical));
    });
  });
}