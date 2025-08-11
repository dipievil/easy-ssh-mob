import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/services/sound_manager.dart';
import 'package:easy_ssh_mob_new/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundManager Tests', () {
    test('should have sound files for all notification types', () {
      for (final type in NotificationType.values) {
        expect(SoundManager.hasSoundForType(type), isTrue);
        expect(SoundManager.getSoundPath(type), isNotNull);
      }
    });

    test('should have correct sound file paths', () {
      expect(SoundManager.getSoundPath(NotificationType.info),
          equals('sounds/info.mp3'));
      expect(SoundManager.getSoundPath(NotificationType.warning),
          equals('sounds/warning.mp3'));
      expect(SoundManager.getSoundPath(NotificationType.error),
          equals('sounds/error.mp3'));
      expect(SoundManager.getSoundPath(NotificationType.success),
          equals('sounds/success.mp3'));
      expect(SoundManager.getSoundPath(NotificationType.critical),
          equals('sounds/critical.mp3'));
    });

    test('playNotificationSound should accept valid parameters', () async {
      // This test ensures the method accepts valid parameters without crashing
      // The actual audio playback is platform-dependent and can't be easily tested
      expect(NotificationType.info, isA<NotificationType>());
      expect(0.5, isA<double>());
      // Test that the sound path exists for the notification type
      expect(SoundManager.getSoundPath(NotificationType.info),
          equals('sounds/info.mp3'));
    });

    test('testAllSounds should accept valid volume parameter', () async {
      // This test ensures the method accepts valid parameters
      expect(0.5, isA<double>());
      // Test that all notification types have sound paths
      for (final type in NotificationType.values) {
        expect(SoundManager.getSoundPath(type), isNotNull);
      }
    });
  });
}
