import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'notification_service.dart';
import 'audio_factory.dart';

/// Manager for notification sounds
class SoundManager {
  static const Map<NotificationType, String> _soundFiles = {
    NotificationType.info: 'sounds/info.mp3',
    NotificationType.warning: 'sounds/warning.mp3',
    NotificationType.error: 'sounds/error.mp3',
    NotificationType.success: 'sounds/success.mp3',
    NotificationType.critical: 'sounds/critical.mp3',
  };

  static AudioPlayer? _lazyPlayer;

  static Future<void> playNotificationSound(
    NotificationType type,
    double volume,
  ) async {
    try {
      final soundFile = _soundFiles[type];
      if (soundFile != null) {
        final player = _getOrCreatePlayer();
        await player.setVolume(volume);
        await player.play(AssetSource(soundFile));
      }
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
      await _playFallbackSound();
    }
  }

  static Future<void> _playFallbackSound() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Fallback sound also failed: $e');
    }
  }

  static Future<void> testAllSounds(double volume) async {
    debugPrint('Testing all notification sounds...');

    for (final type in NotificationType.values) {
      await playNotificationSound(type, volume);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    debugPrint('Sound test completed');
  }

  static AudioPlayer _getOrCreatePlayer() {
    _lazyPlayer ??= audioPlayerFactory.create();
    return _lazyPlayer!;
  }

  static Future<void> disposePlayer() async {
    try {
      await _lazyPlayer?.dispose();
    } catch (_) {}
    _lazyPlayer = null;
  }

  static bool hasSoundForType(NotificationType type) {
    return _soundFiles.containsKey(type);
  }

  static String? getSoundPath(NotificationType type) {
    return _soundFiles[type];
  }
}
