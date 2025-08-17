import 'package:flutter/material.dart';
import '../models/ssh_file.dart';
import '../themes/app_theme.dart';

/// Advanced file icon management system with comprehensive file type support
class FileIconManager {
  /// Mapping of file extensions to specific Flutter Material icons
  static const Map<String, IconData> _extensionIcons = {
    // Documents
    '.pdf': Icons.picture_as_pdf,
    '.doc': Icons.description,
    '.docx': Icons.description,
    '.xls': Icons.table_chart,
    '.xlsx': Icons.table_chart,
    '.csv': Icons.table_chart,
    '.ppt': Icons.slideshow,
    '.pptx': Icons.slideshow,
    '.txt': Icons.description,
    '.rtf': Icons.description,
    '.odt': Icons.description,
    '.ods': Icons.table_chart,
    '.odp': Icons.slideshow,

    // Code files
    '.py': Icons.code,
    '.js': Icons.code,
    '.ts': Icons.code,
    '.html': Icons.web,
    '.htm': Icons.web,
    '.css': Icons.palette,
    '.scss': Icons.palette,
    '.sass': Icons.palette,
    '.less': Icons.palette,
    '.java': Icons.code,
    '.php': Icons.code,
    '.cpp': Icons.code,
    '.c': Icons.code,
    '.h': Icons.code,
    '.hpp': Icons.code,
    '.cs': Icons.code,
    '.sh': Icons.terminal,
    '.bash': Icons.terminal,
    '.zsh': Icons.terminal,
    '.fish': Icons.terminal,
    '.sql': Icons.storage,
    '.json': Icons.code,
    '.xml': Icons.code,
    '.yaml': Icons.code,
    '.yml': Icons.code,
    '.toml': Icons.code,
    '.ini': Icons.settings,
    '.cfg': Icons.settings,
    '.conf': Icons.settings,
    '.config': Icons.settings,
    '.rb': Icons.diamond,
    '.go': Icons.code,
    '.rust': Icons.code,
    '.rs': Icons.code,
    '.kt': Icons.code,
    '.swift': Icons.code,
    '.dart': Icons.code,
    '.vue': Icons.web,
    '.jsx': Icons.web,
    '.tsx': Icons.web,
    '.r': Icons.analytics,
    '.m': Icons.code,
    '.mm': Icons.code,
    '.pl': Icons.code,
    '.pm': Icons.code,
    '.scala': Icons.code,
    '.clj': Icons.code,
    '.lisp': Icons.code,
    '.hs': Icons.code,
    '.elm': Icons.code,
    '.lua': Icons.code,
    '.tcl': Icons.code,
    '.asm': Icons.memory,
    '.s': Icons.memory,

    // Images
    '.jpg': Icons.image,
    '.jpeg': Icons.image,
    '.png': Icons.image,
    '.gif': Icons.image,
    '.bmp': Icons.image,
    '.svg': Icons.image,
    '.webp': Icons.image,
    '.ico': Icons.image,
    '.tiff': Icons.image,
    '.tif': Icons.image,
    '.psd': Icons.image,
    '.ai': Icons.image,
    '.eps': Icons.image,
    '.raw': Icons.image,
    '.cr2': Icons.image,
    '.nef': Icons.image,
    '.orf': Icons.image,
    '.sr2': Icons.image,

    // Video files
    '.mp4': Icons.videocam,
    '.avi': Icons.videocam,
    '.mkv': Icons.videocam,
    '.mov': Icons.videocam,
    '.wmv': Icons.videocam,
    '.flv': Icons.videocam,
    '.webm': Icons.videocam,
    '.m4v': Icons.videocam,
    '.3gp': Icons.videocam,
    '.3g2': Icons.videocam,
    '.f4v': Icons.videocam,
    '.asf': Icons.videocam,
    '.rm': Icons.videocam,
    '.rmvb': Icons.videocam,
    '.vob': Icons.videocam,
    '.ogv': Icons.videocam,

    // Audio files
    '.mp3': Icons.audiotrack,
    '.wav': Icons.audiotrack,
    '.flac': Icons.audiotrack,
    '.ogg': Icons.audiotrack,
    '.m4a': Icons.audiotrack,
    '.aac': Icons.audiotrack,
    '.wma': Icons.audiotrack,
    '.opus': Icons.audiotrack,
    '.aiff': Icons.audiotrack,
    '.au': Icons.audiotrack,
    '.ra': Icons.audiotrack,
    '.3ga': Icons.audiotrack,
    '.amr': Icons.audiotrack,

    // Archive files
    '.zip': Icons.archive,
    '.rar': Icons.archive,
    '.tar': Icons.archive,
    '.gz': Icons.archive,
    '.bz2': Icons.archive,
    '.xz': Icons.archive,
    '.7z': Icons.archive,
    '.cab': Icons.archive,
    '.arj': Icons.archive,
    '.lzh': Icons.archive,
    '.ace': Icons.archive,
    '.iso': Icons.album,
    '.dmg': Icons.album,
    '.img': Icons.album,
    '.deb': Icons.inventory,
    '.rpm': Icons.inventory,
    '.pkg': Icons.inventory,
    '.msi': Icons.inventory,
    '.apk': Icons.android,
    '.ipa': Icons.phone_iphone,

    // System and config files
    '.log': Icons.description,
    '.env': Icons.settings,
    '.gitignore': Icons.source,
    '.gitconfig': Icons.source,
    '.gitmodules': Icons.source,
    '.gitattributes': Icons.source,
    '.editorconfig': Icons.settings,
    '.htaccess': Icons.dns,
    '.htpasswd': Icons.dns,
    '.nginx': Icons.dns,
    '.apache': Icons.dns,

    // Database files
    '.db': Icons.storage,
    '.sqlite': Icons.storage,
    '.sqlite3': Icons.storage,
    '.mdb': Icons.storage,
    '.accdb': Icons.storage,

    // Font files
    '.ttf': Icons.font_download,
    '.otf': Icons.font_download,
    '.woff': Icons.font_download,
    '.woff2': Icons.font_download,
    '.eot': Icons.font_download,

    // Certificate and key files
    '.pem': Icons.vpn_key,
    '.key': Icons.vpn_key,
    '.crt': Icons.verified,
    '.cer': Icons.verified,
    '.p12': Icons.verified,
    '.pfx': Icons.verified,
    '.jks': Icons.verified,
    '.pub': Icons.vpn_key,

    // Executable files (Windows)
    '.exe': Icons.terminal,
    '.bat': Icons.terminal,
    '.cmd': Icons.terminal,
    '.ps1': Icons.terminal,
    '.vbs': Icons.terminal,

    // Markup and documentation
    '.md': Icons.description,
    '.markdown': Icons.description,
    '.rst': Icons.description,
    '.adoc': Icons.description,
    '.tex': Icons.description,
    '.latex': Icons.description,
  };

  /// Mapping of file types to their icons
  static const Map<FileType, IconData> _typeIcons = {
    FileType.directory: Icons.folder,
    FileType.executable: Icons.terminal,
    FileType.symlink: Icons.link,
    FileType.fifo: Icons.swap_horiz,
    FileType.socket: Icons.electrical_services,
    FileType.regular: Icons.description,
    FileType.unknown: Icons.help,
  };

  /// Special file names that get specific icons
  static const Map<String, IconData> _specialFiles = {
    'README': Icons.description,
    'readme': Icons.description,
    'README.md': Icons.description,
    'readme.md': Icons.description,
    'LICENSE': Icons.verified,
    'license': Icons.verified,
    'CHANGELOG': Icons.description,
    'changelog': Icons.description,
    'Makefile': Icons.build,
    'makefile': Icons.build,
    'Dockerfile': Icons.developer_board,
    'dockerfile': Icons.developer_board,
    'docker-compose.yml': Icons.developer_board,
    'docker-compose.yaml': Icons.developer_board,
    '.dockerignore': Icons.developer_board,
    'composer.json': Icons.code,
    'requirements.txt': Icons.code,
    'Pipfile': Icons.code,
    'setup.py': Icons.code,
    'Cargo.toml': Icons.code,
    'go.mod': Icons.code,
    'pubspec.yaml': Icons.code,
    'gemfile': Icons.diamond,
    'Gemfile': Icons.diamond,
    'pom.xml': Icons.code,
    'build.gradle': Icons.code,
    'CMakeLists.txt': Icons.build,
    'configure': Icons.settings,
    'install': Icons.download,
    'INSTALL': Icons.download,
  };

  /// Get appropriate icon for a file
  static IconData getIconForFile(SshFile file) {
    // First, check for special file types
    if (file.type != FileType.regular) {
      return _typeIcons[file.type] ?? Icons.description;
    }

    // Check for special file names
    if (_specialFiles.containsKey(file.name)) {
      return _specialFiles[file.name]!;
    }

    // Check by file extension
    final extension = _getFileExtension(file.name).toLowerCase();
    if (_extensionIcons.containsKey(extension)) {
      return _extensionIcons[extension]!;
    }

    // Check for files without extension but common names
    final lowerName = file.name.toLowerCase();
    final noExtensionFiles = {
      'readme': Icons.description,
      'license': Icons.verified,
      'changelog': Icons.description,
      'makefile': Icons.build,
      'dockerfile': Icons.developer_board,
      'gemfile': Icons.diamond,
      'vagrantfile': Icons.dns,
      'jenkinsfile': Icons.settings,
      'gulpfile': Icons.code,
      'gruntfile': Icons.code,
      'webpack': Icons.code,
      'rollup': Icons.code,
      'babel': Icons.code,
      'eslint': Icons.code,
      'prettier': Icons.code,
      'travis': Icons.settings,
      'appveyor': Icons.settings,
      'circleci': Icons.settings,
    };

    for (final entry in noExtensionFiles.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback to generic file icon
    return Icons.description;
  }

  /// Get color for a file based on its type and extension
  static Color getColorForFile(SshFile file, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (file.type) {
      case FileType.directory:
        return FileTypeColors.directory;
      case FileType.executable:
        return FileTypeColors.executable;
      case FileType.symlink:
        return FileTypeColors.symlink;
      case FileType.fifo:
      case FileType.socket:
        return colorScheme.secondary;
      default:
        return _getColorByExtension(file.name, colorScheme);
    }
  }

  /// Get color by file extension category
  static Color _getColorByExtension(String fileName, ColorScheme colorScheme) {
    final extension = _getFileExtension(fileName).toLowerCase();

    // Define color categories
    final Map<List<String>, Color> categoryColors = {
      // Code files - Blue
      [
        '.py',
        '.js',
        '.ts',
        '.html',
        '.css',
        '.java',
        '.php',
        '.cpp',
        '.c',
        '.sh',
        '.dart',
        '.go',
        '.rs',
        '.rb',
        '.swift',
        '.kt',
      ]: FileTypeColors.code,

      // Documents - Purple
      ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.md']:
          FileTypeColors.document,

      // Spreadsheets - Green
      ['.xls', '.xlsx', '.csv', '.ods']: FileTypeColors.spreadsheet,

      // Presentations - Orange
      ['.ppt', '.pptx', '.odp']: FileTypeColors.presentation,

      // Images - Pink
      [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.bmp',
        '.svg',
        '.webp',
        '.ico',
        '.tiff',
        '.psd',
      ]: FileTypeColors.image,

      // Videos - Red
      ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v']:
          FileTypeColors.video,

      // Audio - Purple
      ['.mp3', '.wav', '.flac', '.ogg', '.m4a', '.aac', '.wma']:
          FileTypeColors.audio,

      // Archives - Brown
      ['.zip', '.rar', '.tar', '.gz', '.7z', '.bz2', '.xz', '.iso', '.dmg']:
          FileTypeColors.archive,

      // Configuration - Amber
      [
        '.conf',
        '.cfg',
        '.ini',
        '.env',
        '.json',
        '.xml',
        '.yaml',
        '.yml',
        '.toml',
      ]: FileTypeColors.config,

      // Logs - Grey
      ['.log']: FileTypeColors.log,
    };

    for (final category in categoryColors.entries) {
      if (category.key.contains(extension)) {
        return category.value;
      }
    }

    // Check for special file names
    final lowerName = fileName.toLowerCase();
    if (lowerName.contains('readme') ||
        lowerName.contains('license') ||
        lowerName.contains('changelog')) {
      return FileTypeColors.document;
    }

    if (lowerName.contains('makefile') ||
        lowerName.contains('dockerfile') ||
        lowerName.contains('package.json')) {
      return FileTypeColors.config;
    }

    // Default color
    return FileTypeColors.unknown;
  }

  /// Extract file extension from filename
  static String _getFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  /// Check if file is a code file
  static bool isCodeFile(String fileName) {
    final codeExtensions = [
      '.py',
      '.js',
      '.ts',
      '.html',
      '.css',
      '.java',
      '.php',
      '.cpp',
      '.c',
      '.h',
      '.cs',
      '.sh',
      '.sql',
      '.json',
      '.xml',
      '.yaml',
      '.yml',
      '.rb',
      '.go',
      '.rs',
      '.dart',
      '.swift',
      '.kt',
      '.scala',
      '.clj',
      '.hs',
      '.lua',
      '.r',
      '.m',
      '.pl',
    ];

    final extension = _getFileExtension(fileName).toLowerCase();
    return codeExtensions.contains(extension);
  }

  /// Check if file is an image file
  static bool isImageFile(String fileName) {
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.svg',
      '.webp',
      '.ico',
      '.tiff',
      '.psd',
    ];

    final extension = _getFileExtension(fileName).toLowerCase();
    return imageExtensions.contains(extension);
  }

  /// Check if file is a video file
  static bool isVideoFile(String fileName) {
    final videoExtensions = [
      '.mp4',
      '.avi',
      '.mkv',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
    ];

    final extension = _getFileExtension(fileName).toLowerCase();
    return videoExtensions.contains(extension);
  }

  /// Check if file is an audio file
  static bool isAudioFile(String fileName) {
    final audioExtensions = [
      '.mp3',
      '.wav',
      '.flac',
      '.ogg',
      '.m4a',
      '.aac',
      '.wma',
    ];

    final extension = _getFileExtension(fileName).toLowerCase();
    return audioExtensions.contains(extension);
  }

  /// Check if file is an archive
  static bool isArchiveFile(String fileName) {
    final archiveExtensions = [
      '.zip',
      '.rar',
      '.tar',
      '.gz',
      '.7z',
      '.bz2',
      '.xz',
      '.iso',
      '.dmg',
    ];

    final extension = _getFileExtension(fileName).toLowerCase();
    return archiveExtensions.contains(extension);
  }
}
