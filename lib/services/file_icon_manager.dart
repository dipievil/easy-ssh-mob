import 'package:flutter/material.dart';
import '../models/ssh_file.dart';

/// Service for managing file icons and colors efficiently with caching
class FileIconManager {
  static final Map<String, IconData> _iconCache = <String, IconData>{};
  static final Map<String, Color> _colorCache = <String, Color>{};
  
  /// Get appropriate icon for a file based on its type and extension
  static IconData getIconForFile(SshFile file) {
    final cacheKey = _createCacheKey(file);
    
    return _iconCache.putIfAbsent(cacheKey, () {
      return _determineIcon(file);
    });
  }
  
  /// Get appropriate color for a file based on its type and theme
  static Color getColorForFile(SshFile file, BuildContext context) {
    final theme = Theme.of(context);
    final cacheKey = '${_createCacheKey(file)}_${theme.brightness.name}';
    
    return _colorCache.putIfAbsent(cacheKey, () {
      return _determineColor(file, theme);
    });
  }
  
  /// Create cache key for file based on type and extension
  static String _createCacheKey(SshFile file) {
    final extension = _getFileExtension(file.name);
    return '${file.type.name}_$extension';
  }
  
  /// Determine the appropriate icon for a file
  static IconData _determineIcon(SshFile file) {
    switch (file.type) {
      case FileType.directory:
        return _getDirectoryIcon(file.name);
        
      case FileType.executable:
        return _getExecutableIcon(file.name);
        
      case FileType.symlink:
        return Icons.link;
        
      case FileType.fifo:
        return Icons.linear_scale;
        
      case FileType.socket:
        return Icons.electrical_services;
        
      case FileType.regular:
      case FileType.unknown:
      default:
        return _getRegularFileIcon(file.name);
    }
  }
  
  /// Determine the appropriate color for a file
  static Color _determineColor(SshFile file, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    switch (file.type) {
      case FileType.directory:
        return colorScheme.primary;
        
      case FileType.executable:
        return Colors.green.shade600;
        
      case FileType.symlink:
        return Colors.cyan.shade600;
        
      case FileType.fifo:
        return Colors.purple.shade600;
        
      case FileType.socket:
        return Colors.orange.shade600;
        
      case FileType.regular:
      case FileType.unknown:
      default:
        return _getRegularFileColor(file.name, colorScheme);
    }
  }
  
  /// Get icon for directory based on name
  static IconData _getDirectoryIcon(String name) {
    final lowerName = name.toLowerCase();
    
    // Diretórios especiais com ícones específicos
    if (lowerName == 'documents' || lowerName == 'documentos') {
      return Icons.folder_copy;
    }
    if (lowerName == 'downloads') {
      return Icons.download;
    }
    if (lowerName == 'pictures' || lowerName == 'images' || lowerName == 'imagens') {
      return Icons.photo_library;
    }
    if (lowerName == 'music' || lowerName == 'musicas') {
      return Icons.library_music;
    }
    if (lowerName == 'videos') {
      return Icons.video_library;
    }
    if (lowerName == 'desktop' || lowerName == 'area de trabalho') {
      return Icons.desktop_windows;
    }
    if (lowerName.startsWith('.')) {
      return Icons.folder_special; // Diretórios ocultos
    }
    
    return Icons.folder;
  }
  
  /// Get icon for executable file
  static IconData _getExecutableIcon(String name) {
    final extension = _getFileExtension(name);
    
    switch (extension) {
      case 'sh':
      case 'bash':
      case 'zsh':
        return Icons.terminal;
      case 'py':
        return Icons.code;
      case 'js':
      case 'ts':
        return Icons.javascript;
      case 'exe':
      case 'msi':
        return Icons.desktop_windows;
      case 'app':
      case 'dmg':
        return Icons.apps;
      default:
        return Icons.play_arrow;
    }
  }
  
  /// Get icon for regular file based on extension
  static IconData _getRegularFileIcon(String name) {
    final extension = _getFileExtension(name);
    
    switch (extension) {
      // Documentos de texto
      case 'txt':
      case 'rtf':
        return Icons.description;
      case 'md':
      case 'markdown':
        return Icons.notes;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      
      // Código e configuração
      case 'html':
      case 'htm':
        return Icons.web;
      case 'css':
        return Icons.palette;
      case 'js':
      case 'ts':
        return Icons.javascript;
      case 'json':
        return Icons.data_object;
      case 'xml':
        return Icons.code;
      case 'yaml':
      case 'yml':
        return Icons.settings;
      case 'ini':
      case 'conf':
      case 'config':
        return Icons.settings;
      case 'sql':
        return Icons.storage;
      case 'py':
        return Icons.code;
      case 'java':
      case 'kt':
      case 'swift':
      case 'dart':
      case 'go':
      case 'rust':
      case 'cpp':
      case 'c':
      case 'h':
        return Icons.code;
      
      // Imagens
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'svg':
      case 'webp':
        return Icons.image;
      case 'ico':
        return Icons.image;
      
      // Vídeos
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'webm':
        return Icons.videocam;
      
      // Áudio
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
      case 'm4a':
        return Icons.audiotrack;
      
      // Arquivos comprimidos
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'bz2':
      case 'xz':
        return Icons.archive;
      
      // Logs e dados
      case 'log':
        return Icons.list_alt;
      case 'csv':
        return Icons.table_chart;
      case 'db':
      case 'sqlite':
        return Icons.storage;
      
      // Arquivos de sistema
      case 'so':
      case 'dll':
        return Icons.extension;
      case 'iso':
        return Icons.album;
      
      // Certificados e chaves
      case 'pem':
      case 'key':
      case 'cert':
      case 'crt':
        return Icons.security;
      
      // Arquivos especiais por nome
      default:
        return _getIconBySpecialName(name);
    }
  }
  
  /// Get color for regular file based on extension
  static Color _getRegularFileColor(String name, ColorScheme colorScheme) {
    final extension = _getFileExtension(name);
    
    switch (extension) {
      // Documentos - azul
      case 'txt':
      case 'md':
      case 'pdf':
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      
      // Planilhas - verde
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green.shade600;
      
      // Apresentações - laranja
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      
      // Código - roxo
      case 'html':
      case 'css':
      case 'js':
      case 'ts':
      case 'json':
      case 'xml':
      case 'py':
      case 'java':
      case 'dart':
        return Colors.purple.shade600;
      
      // Imagens - rosa
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
        return Colors.pink.shade600;
      
      // Vídeos - vermelho
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Colors.red.shade600;
      
      // Áudio - índigo
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.indigo.shade600;
      
      // Arquivos - amarelo escuro
      case 'zip':
      case 'rar':
      case 'tar':
      case 'gz':
        return Colors.amber.shade700;
      
      // Logs - cinza
      case 'log':
        return Colors.grey.shade600;
      
      default:
        return colorScheme.onSurface.withOpacity(0.7);
    }
  }
  
  /// Get icon for special file names (without extension)
  static IconData _getIconBySpecialName(String name) {
    final lowerName = name.toLowerCase();
    
    if (lowerName == 'readme' || lowerName == 'leiame') {
      return Icons.info;
    }
    if (lowerName == 'license' || lowerName == 'licenca') {
      return Icons.gavel;
    }
    if (lowerName == 'changelog' || lowerName == 'changes') {
      return Icons.history;
    }
    if (lowerName == 'makefile') {
      return Icons.build;
    }
    if (lowerName == 'dockerfile') {
      return Icons.developer_board;
    }
    if (lowerName.startsWith('.env')) {
      return Icons.settings;
    }
    if (lowerName == '.gitignore' || lowerName == '.gitattributes') {
      return Icons.source;
    }
    
    return Icons.insert_drive_file;
  }
  
  /// Extract file extension from filename
  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }
  
  /// Clear all caches (useful when theme changes)
  static void clearCache() {
    _iconCache.clear();
    _colorCache.clear();
  }
  
  /// Get cache statistics for debugging
  static Map<String, int> getCacheStats() {
    return {
      'iconCacheSize': _iconCache.length,
      'colorCacheSize': _colorCache.length,
    };
  }
  
  /// Preload common icons to improve performance
  static void preloadCommonIcons() {
    final commonFiles = [
      SshFile(name: 'folder', fullPath: '/folder', type: FileType.directory, displayName: 'folder/'),
      SshFile(name: 'file.txt', fullPath: '/file.txt', type: FileType.regular, displayName: 'file.txt'),
      SshFile(name: 'script.sh', fullPath: '/script.sh', type: FileType.executable, displayName: 'script.sh*'),
      SshFile(name: 'link', fullPath: '/link', type: FileType.symlink, displayName: 'link@'),
      SshFile(name: 'image.jpg', fullPath: '/image.jpg', type: FileType.regular, displayName: 'image.jpg'),
      SshFile(name: 'video.mp4', fullPath: '/video.mp4', type: FileType.regular, displayName: 'video.mp4'),
      SshFile(name: 'audio.mp3', fullPath: '/audio.mp3', type: FileType.regular, displayName: 'audio.mp3'),
      SshFile(name: 'archive.zip', fullPath: '/archive.zip', type: FileType.regular, displayName: 'archive.zip'),
      SshFile(name: 'code.py', fullPath: '/code.py', type: FileType.regular, displayName: 'code.py'),
      SshFile(name: 'data.json', fullPath: '/data.json', type: FileType.regular, displayName: 'data.json'),
    ];
    
    for (final file in commonFiles) {
      getIconForFile(file);
    }
  }
}