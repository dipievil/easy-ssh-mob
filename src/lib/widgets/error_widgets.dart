import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/error_handler.dart';
import '../services/notification_service.dart';
import '../services/sound_manager.dart';

/// Customized SnackBar for displaying SSH errors
class ErrorSnackBar {
  static void show(BuildContext context, SshError error) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_getErrorIcon(error.type), color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(error.userFriendlyMessage)),
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getErrorColor(error.severity),
      duration: Duration(
        seconds: error.severity == ErrorSeverity.critical ? 10 : 4,
      ),
      action: error.suggestion != null
          ? SnackBarAction(
              label: 'AJUDA',
              textColor: Colors.white,
              onPressed: () => _showErrorDialog(context, error),
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _playErrorSound(error.severity);
  }

  static Future<void> _playErrorSound(ErrorSeverity severity) async {
    try {
      final notificationService = NotificationService();
      if (notificationService.soundEnabled) {
        NotificationType soundType;
        switch (severity) {
          case ErrorSeverity.info:
            soundType = NotificationType.info;
            break;
          case ErrorSeverity.warning:
            soundType = NotificationType.warning;
            break;
          case ErrorSeverity.error:
            soundType = NotificationType.error;
            break;
          case ErrorSeverity.critical:
            soundType = NotificationType.critical;
            break;
        }

        await SoundManager.playNotificationSound(
          soundType,
          notificationService.soundVolume,
        );
      }
    } catch (e) {
      debugPrint('Error playing error sound: $e');
    }
  }

  static void _showErrorDialog(BuildContext context, SshError error) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(error: error),
    );
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.permissionDenied:
      case ErrorType.accessDenied:
        return FontAwesomeIcons.lock;
      case ErrorType.fileNotFound:
        return FontAwesomeIcons.fileCircleXmark;
      case ErrorType.operationNotPermitted:
        return FontAwesomeIcons.ban;
      case ErrorType.connectionLost:
        return FontAwesomeIcons.wifi;
      case ErrorType.timeout:
        return FontAwesomeIcons.clock;
      case ErrorType.commandNotFound:
        return FontAwesomeIcons.terminal;
      case ErrorType.diskFull:
        return FontAwesomeIcons.hardDrive;
      case ErrorType.unknown:
        return FontAwesomeIcons.triangleExclamation;
    }
  }

  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

class ErrorDialog extends StatelessWidget {
  final SshError error;

  const ErrorDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(ErrorSnackBar._getErrorIcon(error.type)),
          const SizedBox(width: 8),
          const Text('Erro de Operação'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.userFriendlyMessage),
          if (error.suggestion != null) ...[
            const SizedBox(height: 12),
            const Text(
              'Sugestão:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(error.suggestion!),
          ],
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Detalhes técnicos'),
            children: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  error.originalMessage,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message,
    NotificationType type, {
    VoidCallback? action,
    String? actionLabel,
    Duration? duration,
    bool playSound = true,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_getTypeIcon(type), color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getTypeColor(type),
      duration: duration ?? const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: action != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: action,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (playSound) {
      _playNotificationSound(type);
    }
  }

  static void showWithClear(
    BuildContext context,
    String message,
    NotificationType type, {
    VoidCallback? action,
    String? actionLabel,
    Duration? duration,
  }) {
    show(
      context,
      message,
      type,
      action: action,
      actionLabel: actionLabel,
      duration: duration,
      playSound: true,
    );
  }

  static Future<void> _playNotificationSound(NotificationType type) async {
    try {
      final notificationService = NotificationService();
      if (notificationService.soundEnabled) {
        await SoundManager.playNotificationSound(
          type,
          notificationService.soundVolume,
        );
      }
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  static IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return FontAwesomeIcons.circleInfo;
      case NotificationType.warning:
        return FontAwesomeIcons.triangleExclamation;
      case NotificationType.error:
        return FontAwesomeIcons.circleXmark;
      case NotificationType.success:
        return FontAwesomeIcons.circleCheck;
      case NotificationType.critical:
        return FontAwesomeIcons.exclamation;
    }
  }

  static Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.critical:
        return Colors.red.shade900;
    }
  }
}

/// Enhanced error dialog for all notification types
class CustomNotificationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final NotificationType type;
  final VoidCallback? onRetry;

  const CustomNotificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            CustomSnackBar._getTypeIcon(type),
            color: CustomSnackBar._getTypeColor(type),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Detalhes técnicos'),
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    details!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('TENTAR NOVAMENTE')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Toast-style notification for non-intrusive feedback
class ToastNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;

  const ToastNotification({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
  });

  static void show(
    BuildContext context,
    String message,
    NotificationType type, {
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: ToastNotification(
            message: message,
            type: type,
            duration: duration ?? const Duration(seconds: 3),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration ?? const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomSnackBar._getTypeColor(widget.type),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    CustomSnackBar._getTypeIcon(widget.type),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Loading overlay for long operations
class LoadingOverlay extends StatefulWidget {
  final String message;
  final bool isVisible;
  final VoidCallback? onCancel;

  const LoadingOverlay({
    super.key,
    required this.message,
    required this.isVisible,
    this.onCancel,
  });

  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onCancel,
  }) {
    hide(); // Remove any existing overlay

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) =>
          LoadingOverlay(message: message, isVisible: true, onCancel: onCancel),
    );

    overlay.insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.onCancel != null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: widget.onCancel,
                          child: const Text('CANCELAR'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
