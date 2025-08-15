import 'package:flutter/material.dart';
import '../utils/icon_mapping.dart';
import '../services/error_handler.dart';
import '../services/notification_service.dart';

/// Customized SnackBar for displaying SSH errors
class ErrorSnackBar {
  /// Show error SnackBar with appropriate styling and actions
  static void show(BuildContext context, SshError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error.userFriendlyMessage)),
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
      ),
    );
  }

  /// Show detailed error dialog
  static void _showErrorDialog(BuildContext context, SshError error) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(error: error),
    );
  }

  /// Get appropriate icon for error type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.permissionDenied:
      case ErrorType.accessDenied:
        return Icons.lock;
      case ErrorType.fileNotFound:
        return Icons.descriptionCircleXmark;
      case ErrorType.operationNotPermitted:
        return Icons.block;
      case ErrorType.connectionLost:
        return Icons.wifi;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.commandNotFound:
        return Icons.terminal;
      case ErrorType.diskFull:
        return Icons.storage;
      case ErrorType.unknown:
        return Icons.warning;
    }
  }

  /// Get appropriate color for error severity
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

/// Detailed error dialog with technical information and suggestions
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

/// Enhanced CustomSnackBar for all notification types
class CustomSnackBar {
  static void show(
    BuildContext context,
    String message,
    NotificationType type, {
    VoidCallback? action,
    String? actionLabel,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getTypeIcon(type), color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
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
      ),
    );
  }

  /// Get appropriate icon for notification type
  static IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return IconMapping.getIcon('circleXmark');
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.critical:
        return FontAwesomeIcons.exclamation;
    }
  }

  /// Get appropriate color for notification type
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

    // Auto-dismiss
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
                    color: Colors.black.withOpacity(0.2),
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
            color: Colors.black.withOpacity(0.7),
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
