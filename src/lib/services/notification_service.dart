import 'dart:collection';
import 'package:flutter/services.dart';
import 'sound_manager.dart';
import 'secure_storage_service.dart';

/// Types of notifications
enum NotificationType {
  info,
  warning,
  error,
  success,
  critical
}

/// Configuration for notifications
class NotificationConfig {
  final NotificationType type;
  final Duration duration;
  final bool playSound;
  final bool vibrate;
  final bool persistent;
  
  const NotificationConfig({
    required this.type,
    this.duration = const Duration(seconds: 4),
    this.playSound = true,
    this.vibrate = false,
    this.persistent = false,
  });
}

/// Item representing a notification in the queue
class NotificationItem {
  final String message;
  final NotificationType type;
  final String? title;
  final String? details;
  final VoidCallback? action;
  final String? actionLabel;
  final NotificationConfig config;
  
  NotificationItem({
    required this.message,
    required this.type,
    this.title,
    this.details,
    this.action,
    this.actionLabel,
    NotificationConfig? config,
  }) : config = config ?? NotificationConfig(type: type);
}

/// Centralized notification service for the application
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final Queue<NotificationItem> _notificationQueue = Queue();
  bool _isShowingNotification = false;
  
  // User configuration settings
  bool soundEnabled = true;
  double soundVolume = 0.7;
  bool vibrateEnabled = true;
  
  late final SecureStorageService _storage;
  
  /// Initialize the service and load user preferences
  Future<void> initialize() async {
    _storage = SecureStorageService();
    await _loadUserPreferences();
  }
  
  /// Load user preferences from storage
  Future<void> _loadUserPreferences() async {
    try {
      final soundEnabledStr = await _storage.read('notification_sound_enabled');
      if (soundEnabledStr != null) {
        soundEnabled = soundEnabledStr.toLowerCase() == 'true';
      }
      
      final soundVolumeStr = await _storage.read('notification_sound_volume');
      if (soundVolumeStr != null) {
        soundVolume = double.tryParse(soundVolumeStr) ?? 0.7;
      }
      
      final vibrateEnabledStr = await _storage.read('notification_vibrate_enabled');
      if (vibrateEnabledStr != null) {
        vibrateEnabled = vibrateEnabledStr.toLowerCase() == 'true';
      }
    } catch (e) {
      print('Error loading notification preferences: $e');
    }
  }
  
  /// Save user preferences to storage
  Future<void> saveUserPreferences() async {
    try {
      await _storage.write('notification_sound_enabled', soundEnabled.toString());
      await _storage.write('notification_sound_volume', soundVolume.toString());
      await _storage.write('notification_vibrate_enabled', vibrateEnabled.toString());
    } catch (e) {
      print('Error saving notification preferences: $e');
    }
  }
  
  /// Show a notification with the specified parameters
  Future<void> showNotification({
    required String message,
    required NotificationType type,
    String? title,
    String? details,
    VoidCallback? action,
    String? actionLabel,
    NotificationConfig? config,
  }) async {
    final item = NotificationItem(
      message: message,
      type: type,
      title: title,
      details: details,
      action: action,
      actionLabel: actionLabel,
      config: config,
    );
    
    _notificationQueue.add(item);
    _processQueue();
  }
  
  /// Process the notification queue
  Future<void> _processQueue() async {
    if (_isShowingNotification || _notificationQueue.isEmpty) return;
    
    _isShowingNotification = true;
    final item = _notificationQueue.removeFirst();
    
    await _displayNotification(item);
    
    _isShowingNotification = false;
    
    // Process next notification with a small delay
    if (_notificationQueue.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      _processQueue();
    }
  }
  
  /// Display a single notification
  Future<void> _displayNotification(NotificationItem item) async {
    // Play sound if enabled
    if (item.config.playSound && soundEnabled) {
      await SoundManager.playNotificationSound(item.type, soundVolume);
    }
    
    // Vibrate if enabled
    if (item.config.vibrate && vibrateEnabled) {
      await _vibrate();
    }
    
    // Show visual notification - this will be handled by the UI layer
    // The actual display logic will be in the widgets
  }
  
  /// Trigger device vibration
  Future<void> _vibrate() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Vibration not supported: $e');
    }
  }
  
  /// Clear all pending notifications
  void clearQueue() {
    _notificationQueue.clear();
  }
  
  /// Get the number of pending notifications
  int get pendingNotifications => _notificationQueue.length;
  
  /// Update sound settings
  Future<void> updateSoundSettings({
    bool? enabled,
    double? volume,
  }) async {
    if (enabled != null) soundEnabled = enabled;
    if (volume != null) soundVolume = volume.clamp(0.0, 1.0);
    await saveUserPreferences();
  }
  
  /// Update vibration settings
  Future<void> updateVibrateSettings(bool enabled) async {
    vibrateEnabled = enabled;
    await saveUserPreferences();
  }
}