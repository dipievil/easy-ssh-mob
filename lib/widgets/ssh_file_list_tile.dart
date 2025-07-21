import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ssh_file.dart';
import '../utils/file_icon_manager.dart';
import '../widgets/custom_components.dart';
import '../utils/custom_animations.dart';

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

  /// Get icon color based on file type using advanced color system
  Color _getIconColor(BuildContext context) {
    return FileIconManager.getColorForFile(widget.file, context);
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

  /// Get enhanced icon for file type with improved detection
  IconData _getEnhancedIcon() {
    return FileIconManager.getIconForFile(widget.file);
  }

  /// Get enhanced icon color with improved detection
  Color _getEnhancedIconColor(BuildContext context) {
    return FileIconManager.getColorForFile(widget.file, context);
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return BouncyScale(
      onTap: widget.isLoading ? null : widget.onTap,
      child: SshListTile(
        leading: Icon(
          _getEnhancedIcon(),
          color: _getEnhancedIconColor(context),
          size: 20,
        ),
        title: Text(
          widget.file.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _getSubtitle(),
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
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
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
        onTap: widget.isLoading ? null : widget.onTap,
        onLongPress: widget.isLoading ? null : widget.onLongPress,
        dense: true,
      ),
    );
  }