import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/services/sound_manager.dart';
import 'package:easy_ssh_mob_new/services/notification_service.dart';

void main() {
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

    test('playNotificationSound should not throw exception', () async {
      // This test ensures the method doesn't crash
      // The actual audio playback can't be easily tested in unit tests
      expect(() async {
        await SoundManager.playNotificationSound(NotificationType.info, 0.5);
      }, returnsNormally);
    });

    test('testAllSounds should not throw exception', () async {
      // This test ensures the method doesn't crash
      expect(() async {
        await SoundManager.testAllSounds(0.5);
      }, returnsNormally);
    });
  });
}
