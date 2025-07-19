import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ssh_file.dart';

/// Custom widget to display SSH files and directories as interactive tiles
class SshFileListTile extends StatefulWidget {
  final SshFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isLoading;

  const SshFileListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.isLoading = false,
  });

  @override
  State<SshFileListTile> createState() => _SshFileListTileState();
}

class _SshFileListTileState extends State<SshFileListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get icon color based on file type
  Color _getIconColor() {
    switch (widget.file.type) {
      case FileType.directory:
        return Colors.blue;
      case FileType.executable:
        return Colors.green;
      case FileType.regular:
        return Colors.grey;
      case FileType.symlink:
        return Colors.purple;
      case FileType.fifo:
        return Colors.orange;
      case FileType.socket:
        return Colors.teal;
      case FileType.unknown:
        return Colors.grey.shade400;
    }
  }

  /// Get appropriate subtitle text
  String _getSubtitle() {
    return widget.file.typeDescription;
  }

  /// Get trailing icon based on file type
  IconData? _getTrailingIcon() {
    if (widget.file.isDirectory) {
      return Icons.arrow_forward_ios;
    }
    return null;
  }

  /// Check if this file is a script based on common script extensions
  bool _isScript() {
    final scriptExtensions = ['.sh', '.py', '.js', '.rb', '.pl', '.php'];
    return scriptExtensions.any((ext) => widget.file.name.toLowerCase().endsWith(ext));
  }

  /// Get enhanced icon for file type with script detection
  IconData _getEnhancedIcon() {
    if (_isScript()) {
      return FontAwesomeIcons.fileCode;
    }
    return widget.file.icon;
  }

  /// Get enhanced icon color with script detection
  Color _getEnhancedIconColor() {
    if (_isScript()) {
      return Colors.orange;
    }
    return _getIconColor();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isLoading ? null : widget.onTap,
            onLongPress: widget.isLoading ? null : widget.onLongPress,
            child: ListTile(
              leading: Icon(
                _getEnhancedIcon(),
                color: _getEnhancedIconColor(),
                size: 20,
              ),
              title: Text(
                widget.file.displayName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _getSubtitle(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              trailing: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _getTrailingIcon(),
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
            ),
          ),
        );
      },
    );
  }