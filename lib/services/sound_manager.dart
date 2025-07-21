import 'package:audioplayers/audioplayers.dart';
import 'notification_service.dart';

/// Manager for notification sounds
class SoundManager {
  static const Map<NotificationType, String> _soundFiles = {
    NotificationType.info: 'sounds/info.mp3',
    NotificationType.warning: 'sounds/warning.mp3',
    NotificationType.error: 'sounds/error.mp3',
    NotificationType.success: 'sounds/success.mp3',
    NotificationType.critical: 'sounds/critical.mp3',
  };
  
  /// Play notification sound for the specified type
  static Future<void> playNotificationSound(
    NotificationType type,
    double volume,
  ) async {
    try {
      final soundFile = _soundFiles[type];
      if (soundFile != null) {
        final player = AudioPlayer();
        await player.setVolume(volume);
        await player.play(AssetSource(soundFile));
        
        // Release the player after playing
        player.dispose();
      }
    } catch (e) {
      print('Error playing notification sound: $e');
      // Fallback to system beep or default notification sound
      await _playFallbackSound();
    }
  }
  
  /// Play fallback sound when asset sounds fail
  static Future<void> _playFallbackSound() async {
    try {
      // Try to play a simple beep using system sounds
      final player = AudioPlayer();
      await player.setVolume(0.5);
      // This will create a simple beep sound programmatically
      await player.play(AssetSource('sounds/error_beep.mp3'));
      player.dispose();
    } catch (e) {
      print('Fallback sound also failed: $e');
      // At this point, we just fail silently
    }
  }
  
  /// Test all notification sounds
  static Future<void> testAllSounds(double volume) async {
    for (final type in NotificationType.values) {
      await playNotificationSound(type, volume);
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }
  
  /// Check if sound file exists for the given type
  static bool hasSoundForType(NotificationType type) {
    return _soundFiles.containsKey(type);
  }
  
  /// Get sound file path for the given type
  static String? getSoundPath(NotificationType type) {
    return _soundFiles[type];
  }
}