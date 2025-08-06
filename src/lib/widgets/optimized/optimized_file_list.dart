import 'package:flutter/material.dart';
import '../../models/ssh_file.dart';
import '../../services/file_icon_manager.dart';

/// Optimized file list widget for handling large numbers of files efficiently
class OptimizedFileList extends StatelessWidget {
  final List<SshFile> files;
  final Function(SshFile) onFileTap;
  final Function(SshFile)? onFileSecondaryTap;
  final ScrollController? scrollController;
  final bool showFileSize;
  final bool showFileDate;

  const OptimizedFileList({
    super.key,
    required this.files,
    required this.onFileTap,
    this.onFileSecondaryTap,
    this.scrollController,
    this.showFileSize = true,
    this.showFileDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: files.length,
      // Cache extent para pre-renderizar mais itens fora da tela
      cacheExtent: 1000,
      // Usar itemExtent fixo se possível para melhor performance
      itemExtent: 72.0,
      itemBuilder: (context, index) {
        final file = files[index];

        return OptimizedFileListTile(
          key: ValueKey(file.fullPath),
          file: file,
          onTap: () => onFileTap(file),
          onSecondaryTap: onFileSecondaryTap != null
              ? () => onFileSecondaryTap!(file)
              : null,
          showFileSize: showFileSize,
          showFileDate: showFileDate,
        );
      },
    );
  }
}

/// Optimized file list tile with cached icons and minimal rebuilds
class OptimizedFileListTile extends StatelessWidget {
  final SshFile file;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final bool showFileSize;
  final bool showFileDate;

  const OptimizedFileListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onSecondaryTap,
    this.showFileSize = true,
    this.showFileDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usar o FileIconManager para obter ícone e cor
    final icon = FileIconManager.getIconForFile(file);
    final color = FileIconManager.getColorForFile(file, context);

    return InkWell(
      onTap: onTap,
      onSecondaryTap: onSecondaryTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Ícone do arquivo
            SizedBox(
              width: 32,
              height: 32,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),

            // Informações do arquivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nome do arquivo
                  Text(
                    file.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: file.isDirectory
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Informações secundárias (tamanho, data)
                  if (showFileSize || showFileDate) const SizedBox(height: 2),

                  if (showFileSize || showFileDate)
                    Row(
                      children: [
                        if (showFileSize && !file.isDirectory)
                          Text(
                            _formatFileSize(file.size),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        if (showFileSize && showFileDate && !file.isDirectory)
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        if (showFileDate)
                          Text(
                            _formatFileDate(file.lastModified),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // Indicador de tipo de arquivo
            if (file.isDirectory)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  String _formatFileDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 365) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
