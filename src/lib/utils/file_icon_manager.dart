import 'package:flutter/material.dart';
import '../utils/icon_mapping.dart';
import '../models/ssh_file.dart';
import '../themes/app_theme.dart';

/// Advanced file icon management system with comprehensive file type support
class FileIconManager {
  /// Mapping of file extensions to specific FontAwesome icons
  static const Map<String, IconData> _extensionIcons = {
    // Documents
    '.pdf': Icons.descriptionPdf,
    '.doc': Icons.descriptionWord,
    '.docx': Icons.descriptionWord,
    '.xls': Icons.descriptionExcel,
    '.xlsx': Icons.descriptionExcel,
    '.csv': Icons.descriptionExcel,
    '.ppt': Icons.descriptionPowerpoint,
    '.pptx': Icons.descriptionPowerpoint,
    '.txt': Icons.descriptionLines,
    '.rtf': Icons.descriptionLines,
    '.odt': Icons.descriptionLines,
    '.ods': Icons.descriptionExcel,
    '.odp': Icons.descriptionPowerpoint,

    // Code files
    '.py': Icons.code,
    '.js': FontAwesomeIcons.js,
    '.ts': FontAwesomeIcons.js,
    '.html': FontAwesomeIcons.html5,
    '.htm': FontAwesomeIcons.html5,
    '.css': FontAwesomeIcons.css3Alt,
    '.scss': FontAwesomeIcons.sass,
    '.sass': FontAwesomeIcons.sass,
    '.less': FontAwesomeIcons.css3Alt,
    '.java': Icons.code,
    '.php': Icons.code,
    '.cpp': Icons.descriptionCode,
    '.c': Icons.descriptionCode,
    '.h': Icons.descriptionCode,
    '.hpp': Icons.descriptionCode,
    '.cs': Icons.descriptionCode,
    '.sh': Icons.terminal,
    '.bash': Icons.terminal,
    '.zsh': Icons.terminal,
    '.fish': Icons.terminal,
    '.sql': Icons.storage,
    '.json': Icons.descriptionCode,
    '.xml': Icons.descriptionCode,
    '.yaml': Icons.descriptionCode,
    '.yml': Icons.descriptionCode,
    '.toml': Icons.descriptionCode,
    '.ini': Icons.settings,
    '.cfg': Icons.settings,
    '.conf': Icons.settings,
    '.config': Icons.settings,
    '.rb': Icons.diamond,
    '.go': Icons.descriptionCode,
    '.rust': Icons.descriptionCode,
    '.rs': Icons.descriptionCode,
    '.kt': Icons.descriptionCode,
    '.swift': Icons.descriptionCode,
    '.dart': Icons.descriptionCode,
    '.vue': FontAwesomeIcons.vuejs,
    '.jsx': FontAwesomeIcons.react,
    '.tsx': FontAwesomeIcons.react,
    '.r': Icons.trending_up,
    '.m': Icons.descriptionCode,
    '.mm': Icons.descriptionCode,
    '.pl': Icons.descriptionCode,
    '.pm': Icons.descriptionCode,
    '.scala': Icons.descriptionCode,
    '.clj': Icons.descriptionCode,
    '.lisp': Icons.descriptionCode,
    '.hs': Icons.descriptionCode,
    '.elm': Icons.descriptionCode,
    '.lua': Icons.descriptionCode,
    '.tcl': Icons.descriptionCode,
    '.asm': Icons.memory,
    '.s': Icons.memory,

    // Images
    '.jpg': Icons.descriptionImage,
    '.jpeg': Icons.descriptionImage,
    '.png': Icons.descriptionImage,
    '.gif': Icons.descriptionImage,
    '.bmp': Icons.descriptionImage,
    '.svg': Icons.descriptionImage,
    '.webp': Icons.descriptionImage,
    '.ico': Icons.descriptionImage,
    '.tiff': Icons.descriptionImage,
    '.tif': Icons.descriptionImage,
    '.psd': Icons.descriptionImage,
    '.ai': Icons.descriptionImage,
    '.eps': Icons.descriptionImage,
    '.raw': Icons.descriptionImage,
    '.cr2': Icons.descriptionImage,
    '.nef': Icons.descriptionImage,
    '.orf': Icons.descriptionImage,
    '.sr2': Icons.descriptionImage,

    // Video files
    '.mp4': Icons.descriptionVideo,
    '.avi': Icons.descriptionVideo,
    '.mkv': Icons.descriptionVideo,
    '.mov': Icons.descriptionVideo,
    '.wmv': Icons.descriptionVideo,
    '.flv': Icons.descriptionVideo,
    '.webm': Icons.descriptionVideo,
    '.m4v': Icons.descriptionVideo,
    '.3gp': Icons.descriptionVideo,
    '.3g2': Icons.descriptionVideo,
    '.f4v': Icons.descriptionVideo,
    '.asf': Icons.descriptionVideo,
    '.rm': Icons.descriptionVideo,
    '.rmvb': Icons.descriptionVideo,
    '.vob': Icons.descriptionVideo,
    '.ogv': Icons.descriptionVideo,

    // Audio files
    '.mp3': Icons.descriptionAudio,
    '.wav': Icons.descriptionAudio,
    '.flac': Icons.descriptionAudio,
    '.ogg': Icons.descriptionAudio,
    '.m4a': Icons.descriptionAudio,
    '.aac': Icons.descriptionAudio,
    '.wma': Icons.descriptionAudio,
    '.opus': Icons.descriptionAudio,
    '.aiff': Icons.descriptionAudio,
    '.au': Icons.descriptionAudio,
    '.ra': Icons.descriptionAudio,
    '.3ga': Icons.descriptionAudio,
    '.amr': Icons.descriptionAudio,

    // Archive files
    '.zip': Icons.descriptionZipper,
    '.rar': Icons.descriptionZipper,
    '.tar': Icons.descriptionZipper,
    '.gz': Icons.descriptionZipper,
    '.bz2': Icons.descriptionZipper,
    '.xz': Icons.descriptionZipper,
    '.7z': Icons.descriptionZipper,
    '.cab': Icons.descriptionZipper,
    '.arj': Icons.descriptionZipper,
    '.lzh': Icons.descriptionZipper,
    '.ace': Icons.descriptionZipper,
    '.iso': FontAwesomeIcons.compactDisc,
    '.dmg': FontAwesomeIcons.compactDisc,
    '.img': FontAwesomeIcons.compactDisc,
    '.deb': FontAwesomeIcons.box,
    '.rpm': FontAwesomeIcons.box,
    '.pkg': FontAwesomeIcons.box,
    '.msi': FontAwesomeIcons.box,
    '.apk': FontAwesomeIcons.android,
    '.ipa': FontAwesomeIcons.apple,

    // System and config files
    '.log': Icons.descriptionLines,
    '.env': Icons.settings,
    '.gitignore': FontAwesomeIcons.gitAlt,
    '.gitconfig': FontAwesomeIcons.gitAlt,
    '.gitmodules': FontAwesomeIcons.gitAlt,
    '.gitattributes': FontAwesomeIcons.gitAlt,
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
    '.ttf': FontAwesomeIcons.font,
    '.otf': FontAwesomeIcons.font,
    '.woff': FontAwesomeIcons.font,
    '.woff2': FontAwesomeIcons.font,
    '.eot': FontAwesomeIcons.font,

    // Certificate and key files
    '.pem': Icons.vpn_key,
    '.key': Icons.vpn_key,
    '.crt': Icons.security,
    '.cer': Icons.security,
    '.p12': Icons.security,
    '.pfx': Icons.security,
    '.jks': Icons.security,
    '.pub': Icons.vpn_key,

    // Executable files (Windows)
    '.exe': Icons.terminal,
    '.bat': Icons.terminal,
    '.cmd': Icons.terminal,
    '.ps1': Icons.terminal,
    '.vbs': Icons.terminal,

    // Markup and documentation
    '.md': Icons.info,
    '.markdown': Icons.info,
    '.rst': Icons.info,
    '.adoc': Icons.info,
    '.tex': Icons.descriptionLines,
    '.latex': Icons.descriptionLines,
  };

  /// Mapping of file types to their icons
  static const Map<FileType, IconData> _typeIcons = {
    FileType.directory: Icons.folder,
    FileType.executable: Icons.terminal,
    FileType.symlink: Icons.link,
    FileType.fifo: Icons.swap_horiz,
    FileType.socket: Icons.power,
    FileType.regular: Icons.description,
    FileType.unknown: Icons.help,
  };

  /// Special file names that get specific icons
  static const Map<String, IconData> _specialFiles = {
    'README': Icons.info,
    'readme': Icons.info,
    'README.md': Icons.info,
    'readme.md': Icons.info,
    'LICENSE': Icons.security,
    'license': Icons.security,
    'CHANGELOG': Icons.descriptionLines,
    'changelog': Icons.descriptionLines,
    'Makefile': Icons.build,
    'makefile': Icons.build,
    'Dockerfile': Icons.dns,
    'dockerfile': Icons.dns,
    'docker-compose.yml': Icons.dns,
    'docker-compose.yaml': Icons.dns,
    '.dockerignore': Icons.dns,
    'package.json': Icons.javascript,
    'yarn.lock': Icons.javascript,
    'composer.json': Icons.code,
    'requirements.txt': Icons.code,
    'Pipfile': Icons.code,
    'setup.py': Icons.code,
    'Cargo.toml': Icons.descriptionCode,
    'go.mod': Icons.descriptionCode,
    'pubspec.yaml': Icons.descriptionCode,
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
      'readme': Icons.info,
      'license': Icons.security,
      'changelog': Icons.descriptionLines,
      'makefile': Icons.build,
      'dockerfile': Icons.dns,
      'gemfile': Icons.diamond,
      'vagrantfile': Icons.dns,
      'jenkinsfile': Icons.settings,
      'gulpfile': Icons.descriptionCode,
      'gruntfile': Icons.descriptionCode,
      'webpack': Icons.descriptionCode,
      'rollup': Icons.descriptionCode,
      'babel': Icons.descriptionCode,
      'eslint': Icons.descriptionCode,
      'prettier': Icons.descriptionCode,
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
