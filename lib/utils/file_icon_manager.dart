import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ssh_file.dart';
import '../themes/app_theme.dart';

/// Advanced file icon management system with comprehensive file type support
class FileIconManager {
  /// Mapping of file extensions to specific FontAwesome icons
  static const Map<String, IconData> _extensionIcons = {
    // Documents
    '.pdf': FontAwesomeIcons.filePdf,
    '.doc': FontAwesomeIcons.fileWord,
    '.docx': FontAwesomeIcons.fileWord,
    '.xls': FontAwesomeIcons.fileExcel,
    '.xlsx': FontAwesomeIcons.fileExcel,
    '.csv': FontAwesomeIcons.fileExcel,
    '.ppt': FontAwesomeIcons.filePowerpoint,
    '.pptx': FontAwesomeIcons.filePowerpoint,
    '.txt': FontAwesomeIcons.fileAlt,
    '.rtf': FontAwesomeIcons.fileAlt,
    '.odt': FontAwesomeIcons.fileAlt,
    '.ods': FontAwesomeIcons.fileExcel,
    '.odp': FontAwesomeIcons.filePowerpoint,
    
    // Code files
    '.py': FontAwesomeIcons.python,
    '.js': FontAwesomeIcons.js,
    '.ts': FontAwesomeIcons.js,
    '.html': FontAwesomeIcons.html5,
    '.htm': FontAwesomeIcons.html5,
    '.css': FontAwesomeIcons.css3Alt,
    '.scss': FontAwesomeIcons.sass,
    '.sass': FontAwesomeIcons.sass,
    '.less': FontAwesomeIcons.css3Alt,
    '.java': FontAwesomeIcons.java,
    '.php': FontAwesomeIcons.php,
    '.cpp': FontAwesomeIcons.fileCode,
    '.c': FontAwesomeIcons.fileCode,
    '.h': FontAwesomeIcons.fileCode,
    '.hpp': FontAwesomeIcons.fileCode,
    '.cs': FontAwesomeIcons.fileCode,
    '.sh': FontAwesomeIcons.terminal,
    '.bash': FontAwesomeIcons.terminal,
    '.zsh': FontAwesomeIcons.terminal,
    '.fish': FontAwesomeIcons.terminal,
    '.sql': FontAwesomeIcons.database,
    '.json': FontAwesomeIcons.fileCode,
    '.xml': FontAwesomeIcons.fileCode,
    '.yaml': FontAwesomeIcons.fileCode,
    '.yml': FontAwesomeIcons.fileCode,
    '.toml': FontAwesomeIcons.fileCode,
    '.ini': FontAwesomeIcons.cog,
    '.cfg': FontAwesomeIcons.cog,
    '.conf': FontAwesomeIcons.cog,
    '.config': FontAwesomeIcons.cog,
    '.rb': FontAwesomeIcons.gem,
    '.go': FontAwesomeIcons.fileCode,
    '.rust': FontAwesomeIcons.fileCode,
    '.rs': FontAwesomeIcons.fileCode,
    '.kt': FontAwesomeIcons.fileCode,
    '.swift': FontAwesomeIcons.fileCode,
    '.dart': FontAwesomeIcons.fileCode,
    '.vue': FontAwesomeIcons.vuejs,
    '.jsx': FontAwesomeIcons.react,
    '.tsx': FontAwesomeIcons.react,
    '.r': FontAwesomeIcons.chartLine,
    '.m': FontAwesomeIcons.fileCode,
    '.mm': FontAwesomeIcons.fileCode,
    '.pl': FontAwesomeIcons.fileCode,
    '.pm': FontAwesomeIcons.fileCode,
    '.scala': FontAwesomeIcons.fileCode,
    '.clj': FontAwesomeIcons.fileCode,
    '.lisp': FontAwesomeIcons.fileCode,
    '.hs': FontAwesomeIcons.fileCode,
    '.elm': FontAwesomeIcons.fileCode,
    '.lua': FontAwesomeIcons.fileCode,
    '.tcl': FontAwesomeIcons.fileCode,
    '.asm': FontAwesomeIcons.microchip,
    '.s': FontAwesomeIcons.microchip,
    
    // Images
    '.jpg': FontAwesomeIcons.fileImage,
    '.jpeg': FontAwesomeIcons.fileImage,
    '.png': FontAwesomeIcons.fileImage,
    '.gif': FontAwesomeIcons.fileImage,
    '.bmp': FontAwesomeIcons.fileImage,
    '.svg': FontAwesomeIcons.fileImage,
    '.webp': FontAwesomeIcons.fileImage,
    '.ico': FontAwesomeIcons.fileImage,
    '.tiff': FontAwesomeIcons.fileImage,
    '.tif': FontAwesomeIcons.fileImage,
    '.psd': FontAwesomeIcons.fileImage,
    '.ai': FontAwesomeIcons.fileImage,
    '.eps': FontAwesomeIcons.fileImage,
    '.raw': FontAwesomeIcons.fileImage,
    '.cr2': FontAwesomeIcons.fileImage,
    '.nef': FontAwesomeIcons.fileImage,
    '.orf': FontAwesomeIcons.fileImage,
    '.sr2': FontAwesomeIcons.fileImage,
    
    // Video files
    '.mp4': FontAwesomeIcons.fileVideo,
    '.avi': FontAwesomeIcons.fileVideo,
    '.mkv': FontAwesomeIcons.fileVideo,
    '.mov': FontAwesomeIcons.fileVideo,
    '.wmv': FontAwesomeIcons.fileVideo,
    '.flv': FontAwesomeIcons.fileVideo,
    '.webm': FontAwesomeIcons.fileVideo,
    '.m4v': FontAwesomeIcons.fileVideo,
    '.3gp': FontAwesomeIcons.fileVideo,
    '.3g2': FontAwesomeIcons.fileVideo,
    '.f4v': FontAwesomeIcons.fileVideo,
    '.asf': FontAwesomeIcons.fileVideo,
    '.rm': FontAwesomeIcons.fileVideo,
    '.rmvb': FontAwesomeIcons.fileVideo,
    '.vob': FontAwesomeIcons.fileVideo,
    '.ogv': FontAwesomeIcons.fileVideo,
    
    // Audio files
    '.mp3': FontAwesomeIcons.fileAudio,
    '.wav': FontAwesomeIcons.fileAudio,
    '.flac': FontAwesomeIcons.fileAudio,
    '.ogg': FontAwesomeIcons.fileAudio,
    '.m4a': FontAwesomeIcons.fileAudio,
    '.aac': FontAwesomeIcons.fileAudio,
    '.wma': FontAwesomeIcons.fileAudio,
    '.opus': FontAwesomeIcons.fileAudio,
    '.aiff': FontAwesomeIcons.fileAudio,
    '.au': FontAwesomeIcons.fileAudio,
    '.ra': FontAwesomeIcons.fileAudio,
    '.3ga': FontAwesomeIcons.fileAudio,
    '.amr': FontAwesomeIcons.fileAudio,
    
    // Archive files
    '.zip': FontAwesomeIcons.fileArchive,
    '.rar': FontAwesomeIcons.fileArchive,
    '.tar': FontAwesomeIcons.fileArchive,
    '.gz': FontAwesomeIcons.fileArchive,
    '.bz2': FontAwesomeIcons.fileArchive,
    '.xz': FontAwesomeIcons.fileArchive,
    '.7z': FontAwesomeIcons.fileArchive,
    '.cab': FontAwesomeIcons.fileArchive,
    '.arj': FontAwesomeIcons.fileArchive,
    '.lzh': FontAwesomeIcons.fileArchive,
    '.ace': FontAwesomeIcons.fileArchive,
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
    '.log': FontAwesomeIcons.fileAlt,
    '.env': FontAwesomeIcons.cog,
    '.gitignore': FontAwesomeIcons.gitAlt,
    '.gitconfig': FontAwesomeIcons.gitAlt,
    '.gitmodules': FontAwesomeIcons.gitAlt,
    '.gitattributes': FontAwesomeIcons.gitAlt,
    '.editorconfig': FontAwesomeIcons.cog,
    '.htaccess': FontAwesomeIcons.server,
    '.htpasswd': FontAwesomeIcons.server,
    '.nginx': FontAwesomeIcons.server,
    '.apache': FontAwesomeIcons.server,
    
    // Database files
    '.db': FontAwesomeIcons.database,
    '.sqlite': FontAwesomeIcons.database,
    '.sqlite3': FontAwesomeIcons.database,
    '.mdb': FontAwesomeIcons.database,
    '.accdb': FontAwesomeIcons.database,
    
    // Font files
    '.ttf': FontAwesomeIcons.font,
    '.otf': FontAwesomeIcons.font,
    '.woff': FontAwesomeIcons.font,
    '.woff2': FontAwesomeIcons.font,
    '.eot': FontAwesomeIcons.font,
    
    // Certificate and key files
    '.pem': FontAwesomeIcons.key,
    '.key': FontAwesomeIcons.key,
    '.crt': FontAwesomeIcons.certificate,
    '.cer': FontAwesomeIcons.certificate,
    '.p12': FontAwesomeIcons.certificate,
    '.pfx': FontAwesomeIcons.certificate,
    '.jks': FontAwesomeIcons.certificate,
    '.pub': FontAwesomeIcons.key,
    
    // Executable files (Windows)
    '.exe': FontAwesomeIcons.terminal,
    '.msi': FontAwesomeIcons.box,
    '.bat': FontAwesomeIcons.terminal,
    '.cmd': FontAwesomeIcons.terminal,
    '.ps1': FontAwesomeIcons.terminal,
    '.vbs': FontAwesomeIcons.terminal,
    
    // Markup and documentation
    '.md': FontAwesomeIcons.readme,
    '.markdown': FontAwesomeIcons.readme,
    '.rst': FontAwesomeIcons.readme,
    '.adoc': FontAwesomeIcons.readme,
    '.tex': FontAwesomeIcons.fileAlt,
    '.latex': FontAwesomeIcons.fileAlt,
  };

  /// Mapping of file types to their icons
  static const Map<FileType, IconData> _typeIcons = {
    FileType.directory: FontAwesomeIcons.folder,
    FileType.executable: FontAwesomeIcons.terminal,
    FileType.symlink: FontAwesomeIcons.link,
    FileType.fifo: FontAwesomeIcons.exchangeAlt,
    FileType.socket: FontAwesomeIcons.plug,
    FileType.regular: FontAwesomeIcons.file,
    FileType.unknown: FontAwesomeIcons.question,
  };

  /// Special file names that get specific icons
  static const Map<String, IconData> _specialFiles = {
    'README': FontAwesomeIcons.readme,
    'readme': FontAwesomeIcons.readme,
    'README.md': FontAwesomeIcons.readme,
    'readme.md': FontAwesomeIcons.readme,
    'LICENSE': FontAwesomeIcons.certificate,
    'license': FontAwesomeIcons.certificate,
    'CHANGELOG': FontAwesomeIcons.fileAlt,
    'changelog': FontAwesomeIcons.fileAlt,
    'Makefile': FontAwesomeIcons.hammer,
    'makefile': FontAwesomeIcons.hammer,
    'Dockerfile': FontAwesomeIcons.docker,
    'dockerfile': FontAwesomeIcons.docker,
    'docker-compose.yml': FontAwesomeIcons.docker,
    'docker-compose.yaml': FontAwesomeIcons.docker,
    '.dockerignore': FontAwesomeIcons.docker,
    'package.json': FontAwesomeIcons.npm,
    'yarn.lock': FontAwesomeIcons.npm,
    'composer.json': FontAwesomeIcons.php,
    'requirements.txt': FontAwesomeIcons.python,
    'Pipfile': FontAwesomeIcons.python,
    'setup.py': FontAwesomeIcons.python,
    'Cargo.toml': FontAwesomeIcons.fileCode,
    'go.mod': FontAwesomeIcons.fileCode,
    'pubspec.yaml': FontAwesomeIcons.fileCode,
    'gemfile': FontAwesomeIcons.gem,
    'Gemfile': FontAwesomeIcons.gem,
    'pom.xml': FontAwesomeIcons.java,
    'build.gradle': FontAwesomeIcons.java,
    'CMakeLists.txt': FontAwesomeIcons.hammer,
    'configure': FontAwesomeIcons.cog,
    'install': FontAwesomeIcons.download,
    'INSTALL': FontAwesomeIcons.download,
  };

  /// Get appropriate icon for a file
  static IconData getIconForFile(SshFile file) {
    // First, check for special file types
    if (file.type != FileType.regular) {
      return _typeIcons[file.type] ?? FontAwesomeIcons.file;
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
      'readme': FontAwesomeIcons.readme,
      'license': FontAwesomeIcons.certificate,
      'changelog': FontAwesomeIcons.fileAlt,
      'makefile': FontAwesomeIcons.hammer,
      'dockerfile': FontAwesomeIcons.docker,
      'gemfile': FontAwesomeIcons.gem,
      'vagrantfile': FontAwesomeIcons.server,
      'jenkinsfile': FontAwesomeIcons.cog,
      'gulpfile': FontAwesomeIcons.fileCode,
      'gruntfile': FontAwesomeIcons.fileCode,
      'webpack': FontAwesomeIcons.fileCode,
      'rollup': FontAwesomeIcons.fileCode,
      'babel': FontAwesomeIcons.fileCode,
      'eslint': FontAwesomeIcons.fileCode,
      'prettier': FontAwesomeIcons.fileCode,
      'travis': FontAwesomeIcons.cog,
      'appveyor': FontAwesomeIcons.cog,
      'circleci': FontAwesomeIcons.cog,
    };

    for (final entry in noExtensionFiles.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback to generic file icon
    return FontAwesomeIcons.file;
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
      ['.py', '.js', '.ts', '.html', '.css', '.java', '.php', '.cpp', '.c', '.sh', '.dart', '.go', '.rs', '.rb', '.swift', '.kt']: 
        FileTypeColors.code,

      // Documents - Purple
      ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt', '.md']: 
        FileTypeColors.document,

      // Spreadsheets - Green
      ['.xls', '.xlsx', '.csv', '.ods']: 
        FileTypeColors.spreadsheet,

      // Presentations - Orange
      ['.ppt', '.pptx', '.odp']: 
        FileTypeColors.presentation,

      // Images - Pink
      ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.webp', '.ico', '.tiff', '.psd']: 
        FileTypeColors.image,

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
      ['.conf', '.cfg', '.ini', '.env', '.json', '.xml', '.yaml', '.yml', '.toml']: 
        FileTypeColors.config,

      // Logs - Grey
      ['.log']: 
        FileTypeColors.log,
    };

    for (final category in categoryColors.entries) {
      if (category.key.contains(extension)) {
        return category.value;
      }
    }

    // Check for special file names
    final lowerName = fileName.toLowerCase();
    if (lowerName.contains('readme') || lowerName.contains('license') || lowerName.contains('changelog')) {
      return FileTypeColors.document;
    }

    if (lowerName.contains('makefile') || lowerName.contains('dockerfile') || lowerName.contains('package.json')) {
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
      '.py', '.js', '.ts', '.html', '.css', '.java', '.php', '.cpp', '.c', '.h',
      '.cs', '.sh', '.sql', '.json', '.xml', '.yaml', '.yml', '.rb', '.go', '.rs',
      '.dart', '.swift', '.kt', '.scala', '.clj', '.hs', '.lua', '.r', '.m', '.pl'
    ];
    
    final extension = _getFileExtension(fileName).toLowerCase();
    return codeExtensions.contains(extension);
  }

  /// Check if file is an image file
  static bool isImageFile(String fileName) {
    final imageExtensions = [
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.webp', '.ico', '.tiff', '.psd'
    ];
    
    final extension = _getFileExtension(fileName).toLowerCase();
    return imageExtensions.contains(extension);
  }

  /// Check if file is a video file
  static bool isVideoFile(String fileName) {
    final videoExtensions = [
      '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v'
    ];
    
    final extension = _getFileExtension(fileName).toLowerCase();
    return videoExtensions.contains(extension);
  }

  /// Check if file is an audio file
  static bool isAudioFile(String fileName) {
    final audioExtensions = [
      '.mp3', '.wav', '.flac', '.ogg', '.m4a', '.aac', '.wma'
    ];
    
    final extension = _getFileExtension(fileName).toLowerCase();
    return audioExtensions.contains(extension);
  }

  /// Check if file is an archive
  static bool isArchiveFile(String fileName) {
    final archiveExtensions = [
      '.zip', '.rar', '.tar', '.gz', '.7z', '.bz2', '.xz', '.iso', '.dmg'
    ];
    
    final extension = _getFileExtension(fileName).toLowerCase();
    return archiveExtensions.contains(extension);
  }
}