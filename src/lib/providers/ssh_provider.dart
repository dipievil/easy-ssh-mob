import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:math';
import '../models/ssh_credentials.dart';
import '../models/ssh_connection_state.dart';
import '../models/ssh_file.dart';
import '../models/execution_result.dart';
import '../models/file_content.dart';
import '../models/log_entry.dart';
import '../services/secure_storage_service.dart';
import '../services/error_handler.dart';
import '../services/notification_service.dart';
import '../services/audio_factory.dart';

class SshProvider extends ChangeNotifier {
  // Constants
  static const String _errorSoundPath = 'sounds/error_beep.wav';

  SshConnectionState _connectionState = SshConnectionState.disconnected;
  String? _errorMessage;
  SSHCredentials? _currentCredentials;
  SSHClient? _sshClient;

  // Directory navigation properties
  List<SshFile> _currentFiles = [];
  String _currentPath = '';
  final List<String> _navigationHistory = [];

  // Error handling properties
  SshError? _lastError;
  AudioPlayer? _lazyAudioPlayer;
  bool _shouldPlayErrorSound = true;
  final NotificationService _notificationService = NotificationService();

  // Cache de tamanho de arquivo para evitar comandos stat duplicados
  final Map<String, int> _fileSizeCache = {};

  // Session logging properties
  final List<LogEntry> _sessionLog = [];
  bool _loggingEnabled = true;
  int _maxLogEntries = 1000;
  DateTime? _sessionStartTime;

  SshConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  SSHCredentials? get currentCredentials => _currentCredentials;
  List<SshFile> get currentFiles => _currentFiles;
  String get currentPath => _currentPath;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  SshError? get lastError => _lastError;
  bool get shouldPlayErrorSound => _shouldPlayErrorSound;

  // Session logging getters
  List<LogEntry> get sessionLog => List.unmodifiable(_sessionLog);
  bool get loggingEnabled => _loggingEnabled;
  int get maxLogEntries => _maxLogEntries;
  DateTime? get sessionStartTime => _sessionStartTime;

  // Backward compatibility getters
  bool get isConnecting => _connectionState.isConnecting;
  bool get isConnected => _connectionState.isConnected;

  /// Initialize the provider and load saved credentials
  Future<void> initialize() async {
    try {
      _currentCredentials = await SecureStorageService.loadCredentials();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SSH provider: $e');
    }
  }

  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
    bool saveCredentials = false,
  }) async {
    _connectionState = SshConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create SSH socket connection
      final socket = await SSHSocket.connect(host, port);

      // Create SSH client with password authentication
      _sshClient = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      // Wait for authentication to complete
      await _sshClient!.authenticated;

      _connectionState = SshConnectionState.connected;

      // Initialize session logging
      _sessionStartTime = DateTime.now();

      // Create credentials object
      final credentials = SSHCredentials(
        host: host,
        port: port,
        username: username,
        password: password,
      );

      _currentCredentials = credentials;

      // Save credentials if requested
      if (saveCredentials) {
        final saveSuccess =
            await SecureStorageService.saveCredentials(credentials);
        if (!saveSuccess) {
          debugPrint('Warning: Failed to save credentials to secure storage');
          // Note: We don't fail the connection for credential save failure
        } else {
          debugPrint('Credentials saved successfully');
        }
      }

      // Initialize directory navigation to home directory
      try {
        await navigateToHome();
      } catch (e) {
        // If home navigation fails, don't fail the connection
        debugPrint('Warning: Could not navigate to home directory: $e');
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatError(e);
      _connectionState = SshConnectionState.error;
      await _cleanup();
      notifyListeners();

      return false;
    }
  }

  /// List contents of a directory
  Future<void> listDirectory(String path) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      const error = SshError(
        type: ErrorType.connectionLost,
        originalMessage: 'Not connected to SSH server',
        userFriendlyMessage: 'Não conectado ao servidor SSH',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return;
    }

    try {
      // Normalize the path
      final normalizedPath = _normalizePath(path);

      // Execute ls -F command using session for proper error capture
      final session = await _sshClient!.execute('ls -F "$normalizedPath"');
      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();

      // Check for errors in stderr
      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(
          stderr,
          'ls -F "$normalizedPath"',
        );
        _handleSshError(error);
        return;
      }

      if (stdout.isEmpty) {
        // Empty directory is valid
        _currentPath = normalizedPath;
        _currentFiles = [];

        // Clear any previous errors on successful listing
        if (_connectionState.hasError) {
          _connectionState = SshConnectionState.connected;
          _errorMessage = null;
          _lastError = null;
        }

        notifyListeners();
        return;
      }

      // Parse the output
      final files = <SshFile>[];
      final lines = stdout.split('\n');

      for (String line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) {
          try {
            files.add(SshFile.fromLsLine(trimmedLine, normalizedPath));
          } catch (e) {
            // Skip problematic lines but continue parsing
            debugPrint('Error parsing line "$trimmedLine": $e');
          }
        }
      }

      // Sort files: directories first, then by name
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      _currentPath = normalizedPath;
      _currentFiles = files;

      // Clear file size cache when changing directories to ensure fresh data
      _fileSizeCache.clear();

      // Clear any previous errors on successful listing
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        _lastError = null;
      }

      notifyListeners();
    } catch (e) {
      final error = SshError(
        type: ErrorType.unknown,
        originalMessage: e.toString(),
        userFriendlyMessage: 'Erro ao listar diretório',
        suggestion: 'Verifique as permissões e conexão',
        severity: ErrorSeverity.error,
      );
      _handleSshError(error);
    }
  }

  /// Navigate to a directory and add to history
  Future<void> navigateToDirectory(String path) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _errorMessage = 'Não conectado ao servidor SSH';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return;
    }

    try {
      final normalizedPath = _normalizePath(path);

      // Test if directory exists and is accessible
      final testSession = await _sshClient!.execute(
        'test -d "$normalizedPath" && echo "OK"',
      );
      final testResult = await utf8.decoder.bind(testSession.stdout).join();

      if (testResult.trim() != 'OK') {
        _errorMessage =
            'Directory does not exist or is not accessible: $normalizedPath';
        _connectionState = SshConnectionState.error;
        notifyListeners();
        return;
      }

      // Add current path to history before navigating (if not empty)
      if (_currentPath.isNotEmpty && _currentPath != normalizedPath) {
        _navigationHistory.add(_currentPath);
        // Limit history size
        if (_navigationHistory.length > 50) {
          _navigationHistory.removeAt(0);
        }
      }

      // List the directory contents
      await listDirectory(normalizedPath);
    } catch (e) {
      _errorMessage = _formatDirectoryError(e);
      _connectionState = SshConnectionState.error;
      notifyListeners();
    }
  }

  /// Navigate back to previous directory
  Future<void> navigateBack() async {
    if (_navigationHistory.isNotEmpty) {
      final previousPath = _navigationHistory.removeLast();
      await listDirectory(previousPath);
    }
  }

  /// Navigate to parent directory
  Future<void> navigateToParent() async {
    if (_currentPath.isNotEmpty && _currentPath != '/') {
      final parentPath = _getParentPath(_currentPath);
      await navigateToDirectory(parentPath);
    }
  }

  /// Navigate to home directory
  Future<void> navigateToHome() async {
    try {
      final homeSession = await _sshClient!.execute('echo ~');
      final homeResult = await utf8.decoder.bind(homeSession.stdout).join();
      final homePath = homeResult.trim().isEmpty ? '/' : homeResult.trim();
      await navigateToDirectory(homePath);
    } catch (e) {
      await navigateToDirectory('/');
    }
  }

  /// Refresh current directory
  Future<void> refreshCurrentDirectory() async {
    if (_currentPath.isNotEmpty) {
      await listDirectory(_currentPath);
    }
  }

  /// Normalize path by removing redundant elements
  String _normalizePath(String path) {
    if (path.isEmpty) return '/';

    // Convert to absolute path if relative
    if (!path.startsWith('/')) {
      path = _currentPath.isEmpty ? '/$path' : '$_currentPath/$path';
    }

    // Split path into components
    final components = path.split('/').where((c) => c.isNotEmpty).toList();
    final normalized = <String>[];

    for (final component in components) {
      if (component == '.') {
        // Current directory - skip
        continue;
      } else if (component == '..') {
        // Parent directory - remove last component if exists
        if (normalized.isNotEmpty) {
          normalized.removeLast();
        }
      } else {
        normalized.add(component);
      }
    }

    return normalized.isEmpty ? '/' : '/${normalized.join('/')}';
  }

  /// Get parent path of given path
  String _getParentPath(String path) {
    if (path == '/' || path.isEmpty) return '/';

    final lastSlash = path.lastIndexOf('/');
    if (lastSlash <= 0) return '/';

    return path.substring(0, lastSlash);
  }

  /// Format directory-specific error messages
  String _formatDirectoryError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission denied') ||
        errorString.contains('access denied')) {
      return 'Permission denied. You do not have access to this directory.';
    } else if (errorString.contains('no such file or directory') ||
        errorString.contains('not found')) {
      return 'Directory not found or does not exist.';
    } else if (errorString.contains('not a directory')) {
      return 'The specified path is not a directory.';
    } else if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Directory listing timeout. The server may be slow or unresponsive.';
    }

    return 'Error accessing directory: ${error.toString()}';
  }

  /// Execute a file on the SSH server
  Future<ExecutionResult> executeFile(
    SshFile file, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    if (!_connectionState.isConnected || _sshClient == null) {
      return ExecutionResult(
        stdout: '',
        stderr: 'Não conectado ao servidor SSH',
        exitCode: -1,
        duration: DateTime.now().difference(startTime),
        timestamp: startTime,
      );
    }

    try {
      String command;

      if (file.type == FileType.executable) {
        // For executables, run directly with proper escaping
        command = '"${file.fullPath}"';
      } else {
        // For other files, try to detect script type and use appropriate interpreter
        command = await _buildScriptCommand(file);
      }

      debugPrint('Executing command: $command');

      // Execute with timeout handling
      final result = await _executeCommandWithTimeout(command, timeout);

      return ExecutionResult(
        stdout: result['stdout'] ?? '',
        stderr: result['stderr'] ?? '',
        exitCode: result['exitCode'],
        duration: DateTime.now().difference(startTime),
        timestamp: startTime,
      );
    } catch (e) {
      return ExecutionResult(
        stdout: '',
        stderr: 'Execution error: ${e.toString()}',
        exitCode: -1,
        duration: DateTime.now().difference(startTime),
        timestamp: startTime,
      );
    }
  }

  /// Build command for executing script files based on file extension or shebang
  Future<String> _buildScriptCommand(SshFile file) async {
    final filePath = file.fullPath;
    final fileName = file.name.toLowerCase();

    // Check for common script extensions
    if (fileName.endsWith('.sh')) {
      return 'bash "$filePath"';
    } else if (fileName.endsWith('.py')) {
      return 'python3 "$filePath"';
    } else if (fileName.endsWith('.pl')) {
      return 'perl "$filePath"';
    } else if (fileName.endsWith('.rb')) {
      return 'ruby "$filePath"';
    } else if (fileName.endsWith('.js')) {
      return 'node "$filePath"';
    }

    // For files without clear extension, try to read shebang
    try {
      final headSession = await _sshClient!.execute('head -1 "$filePath"');
      final headResult = await utf8.decoder.bind(headSession.stdout).join();
      if (headResult.startsWith('#!')) {
        // Extract interpreter from shebang
        final shebang = headResult.trim();
        final interpreter = shebang.substring(2).split(' ').first;
        return '$interpreter "$filePath"';
      }
    } catch (e) {
      debugPrint('Could not read shebang: $e');
    }

    // Default: try to execute directly
    return '"$filePath"';
  }

  /// Execute command with timeout and separate stdout/stderr capture
  Future<Map<String, dynamic>> _executeCommandWithTimeout(
    String command,
    Duration timeout,
  ) async {
    try {
      // Create SSH session for proper stderr capture
      final session = await _sshClient!.execute(command);

      // Set up timeout and capture streams
      final Future<String> stdoutFuture =
          utf8.decoder.bind(session.stdout).join();
      final Future<String> stderrFuture =
          utf8.decoder.bind(session.stderr).join();
      final int? exitCode = session.exitCode;

      // Wait for all with timeout
      final results = await Future.wait([
        stdoutFuture.timeout(timeout),
        stderrFuture.timeout(timeout),
      ]);

      final stdout = results[0];
      final stderr = results[1];
      // exitCode já está disponível

      // If there's stderr, analyze it for errors
      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(stderr, command);
        _handleSshError(error);
      }

      return {'stdout': stdout, 'stderr': stderr, 'exitCode': exitCode ?? 0};
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        final timeoutError = SshError(
          type: ErrorType.timeout,
          originalMessage:
              'Command timed out after ${timeout.inSeconds} seconds',
          userFriendlyMessage: 'Comando demorou muito tempo para executar',
          suggestion: 'Tente usar um timeout maior ou simplificar o comando',
          severity: ErrorSeverity.warning,
        );
        _handleSshError(timeoutError);

        return {
          'stdout': '',
          'stderr': 'Command timed out after ${timeout.inSeconds} seconds',
          'exitCode': -1,
        };
      }
      rethrow;
    }
  }

  /// Execute a SSH command and return output
  Future<String?> executeCommand(String command) async {
    final startTime = DateTime.now();
    final logId = _generateLogId();

    if (!_connectionState.isConnected || _sshClient == null) {
      if (_loggingEnabled) {
        final errorEntry = LogEntry(
          id: logId,
          timestamp: startTime,
          command: command,
          type: _detectCommandType(command),
          workingDirectory: _currentPath,
          stdout: '',
          stderr: 'Não conectado ao servidor SSH',
          exitCode: -1,
          duration: DateTime.now().difference(startTime),
          status: CommandStatus.error,
        );
        _addLogEntry(errorEntry);
      }

      _errorMessage = 'Não conectado ao servidor SSH';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }

    try {
      // Execute command using SSH client with session for stderr capture
      final session = await _sshClient!.execute(command);

      // Wait for command completion and capture both stdout and stderr
      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();
      final exitCode = session.exitCode;
      final duration = DateTime.now().difference(startTime);

      // Log the command execution
      if (_loggingEnabled) {
        final logEntry = LogEntry(
          id: logId,
          timestamp: startTime,
          command: command,
          type: _detectCommandType(command),
          workingDirectory: _currentPath,
          stdout: stdout,
          stderr: stderr,
          exitCode: exitCode,
          duration: duration,
          status: exitCode != 0
              ? CommandStatus.error
              : (stderr.isNotEmpty
                  ? CommandStatus.partial
                  : CommandStatus.success),
        );
        _addLogEntry(logEntry);
      }

      // Check if there were errors in stderr
      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(stderr, command);
        _handleSshError(error);
      }

      // Clear any previous errors on successful execution
      if (_connectionState.hasError && stderr.isEmpty) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        notifyListeners();
      }

      return stdout;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      // Log the error
      if (_loggingEnabled) {
        final errorEntry = LogEntry(
          id: logId,
          timestamp: startTime,
          command: command,
          type: _detectCommandType(command),
          workingDirectory: _currentPath,
          stdout: '',
          stderr: e.toString(),
          exitCode: -1,
          duration: duration,
          status: CommandStatus.error,
        );
        _addLogEntry(errorEntry);
      }

      final error = SshError(
        type: ErrorType.unknown,
        originalMessage: e.toString(),
        userFriendlyMessage: 'Erro de conexão SSH',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return null;
    }
  }

  /// Handle SSH errors with notification and sound
  void _handleSshError(SshError error) {
    _lastError = error;
    _errorMessage = error.userFriendlyMessage;
    _connectionState = SshConnectionState.error;
    notifyListeners();

    // Log for debug
    debugPrint('SSH Error: ${error.type} - ${error.originalMessage}');

    // Send notification using the new NotificationService
    _notificationService.showNotification(
      message: error.userFriendlyMessage,
      type: _mapErrorToNotificationType(error.severity),
      title: 'Erro SSH',
      details: error.originalMessage,
    );

    // Play error sound if configured (legacy support)
    if (_shouldPlayErrorSound && _shouldPlaySoundForSeverity(error.severity)) {
      _playErrorSound();
    }
  }

  /// Map error severity to notification type
  NotificationType _mapErrorToNotificationType(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return NotificationType.info;
      case ErrorSeverity.warning:
        return NotificationType.warning;
      case ErrorSeverity.error:
        return NotificationType.error;
      case ErrorSeverity.critical:
        return NotificationType.critical;
    }
  }

  /// Determine if sound should be played for given severity
  bool _shouldPlaySoundForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return false;
      case ErrorSeverity.warning:
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
        return true;
    }
  }

  /// Play error sound
  void _playErrorSound() {
    try {
      // Lazy-create player and reuse it across plays to avoid eager plugin init
      final player = _getOrCreateAudioPlayer();
      player.play(AssetSource(_errorSoundPath)).catchError((e) {
        // Fallback: log that sound would play
        debugPrint('Error sound notification (no audio file): $e');
      });
    } catch (e) {
      debugPrint('Could not play error sound: $e');
    }
  }

  /// Toggle error sound setting
  void setErrorSoundEnabled(bool enabled) {
    _shouldPlayErrorSound = enabled;
    notifyListeners();
  }

  /// Test error sound (for debugging)
  void testErrorSound() {
    _playErrorSound();
  }

  /// Execute a command and return the result as a stream
  Future<String?> executeCommandWithResult(String command) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      const error = SshError(
        type: ErrorType.connectionLost,
        originalMessage: 'Not connected to SSH server',
        userFriendlyMessage: 'Não conectado ao servidor SSH',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return null;
    }

    try {
      // Execute command using SSH client with session for stderr capture
      final session = await _sshClient!.execute(command);

      // Wait for command completion and capture both stdout and stderr
      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();

      // Check if there were errors in stderr
      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(stderr, command);
        _handleSshError(error);
        return stdout; // Return stdout even if there are warnings in stderr
      }

      // Clear any previous errors on successful execution
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        _lastError = null;
        notifyListeners();
      }

      return stdout;
    } catch (e) {
      final error = SshError(
        type: ErrorType.unknown,
        originalMessage: e.toString(),
        userFriendlyMessage: 'Erro de execução de comando',
        severity: ErrorSeverity.error,
      );
      _handleSshError(error);
      return null;
    }
  }

  /// Obtém o tamanho do arquivo com cache para evitar comandos stat duplicados
  Future<int> _getFileSize(SshFile file) async {
    // Verificar o cache primeiro
    final cacheKey = file.fullPath;
    if (_fileSizeCache.containsKey(cacheKey)) {
      return _fileSizeCache[cacheKey]!;
    }

    // Executa o comando stat e armazena o resultado em cache
    final sizeSession = await _sshClient!.execute(
      'stat -f%z "${file.fullPath}" 2>/dev/null || stat -c%s "${file.fullPath}"',
    );
    final sizeOutput = await utf8.decoder.bind(sizeSession.stdout).join();
    final fileSize = int.tryParse(sizeOutput.trim()) ?? 0;

    // Armazena o resultado em cache
    _fileSizeCache[cacheKey] = fileSize;

    return fileSize;
  }

  /// Read content of a text file
  Future<FileContent> readFile(SshFile file) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      throw Exception('Não conectado ao servidor SSH');
    }

    if (!file.isTextFile && file.type != FileType.regular) {
      throw Exception('Arquivo não é um arquivo de texto');
    }

    try {
      // First check file size
      final fileSize = await _getFileSize(file);

      // File size limit: 1MB
      const maxSize = 1024 * 1024;

      if (fileSize > maxSize) {
        // Large file - show only part
        return _readFilePart(file, FileViewMode.head, fileSize);
      } else {
        // Small file - read complete
        final contentSession = await _sshClient!.execute(
          'cat "${file.fullPath}"',
        );
        final content = await utf8.decoder.bind(contentSession.stdout).join();

        final lines = content.split('\n');

        return FileContent(
          content: content,
          isTruncated: false,
          totalLines: lines.length,
          displayedLines: lines.length,
          mode: FileViewMode.full,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      throw Exception('Erro ao ler arquivo: $e');
    }
  }

  /// Read part of a file (head or tail)
  Future<FileContent> _readFilePart(
    SshFile file,
    FileViewMode mode,
    int fileSize,
  ) async {
    const linesCount = 100; // Read 100 lines by default

    String command;
    switch (mode) {
      case FileViewMode.head:
        command = 'head -$linesCount "${file.fullPath}"';
        break;
      case FileViewMode.tail:
        command = 'tail -$linesCount "${file.fullPath}"';
        break;
      default:
        throw Exception('Modo inválido para leitura parcial: $mode');
    }

    final contentSession = await _sshClient!.execute(command);
    final content = await utf8.decoder.bind(contentSession.stdout).join();

    // Get total line count
    final lineCountSession = await _sshClient!.execute(
      'wc -l "${file.fullPath}"',
    );
    final lineCountOutput =
        await utf8.decoder.bind(lineCountSession.stdout).join();
    final totalLines = int.tryParse(lineCountOutput.split(' ').first) ?? 0;

    final lines = content.split('\n');
    final displayedLines = lines.where((line) => line.isNotEmpty).length;

    return FileContent(
      content: content,
      isTruncated: true,
      totalLines: totalLines,
      displayedLines: displayedLines,
      mode: mode,
      fileSize: fileSize,
    );
  }

  /// Read file with specific mode
  Future<FileContent> readFileWithMode(SshFile file, FileViewMode mode) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      throw Exception('Não conectado ao servidor SSH');
    }

    try {
      // Get file size first
      final fileSize = await _getFileSize(file);

      switch (mode) {
        case FileViewMode.full:
          return readFile(file);
        case FileViewMode.head:
        case FileViewMode.tail:
          return _readFilePart(file, mode, fileSize);
        default:
          throw Exception('Modo de leitura não suportado: $mode');
      }
    } catch (e) {
      throw Exception('Erro ao ler arquivo com modo $mode: $e');
    }
  }

  Future<void> disconnect() async {
    await _cleanup();
    _connectionState = SshConnectionState.disconnected;
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout and optionally clear saved credentials
  Future<void> logout({bool forgetCredentials = false}) async {
    await _cleanup();
    _connectionState = SshConnectionState.disconnected;
    _errorMessage = null;

    if (forgetCredentials) {
      await SecureStorageService.deleteCredentials();
      _currentCredentials = null;
    }

    notifyListeners();
  }

  void clearError() {
    if (_connectionState.hasError) {
      _connectionState = _connectionState.isConnected
          ? SshConnectionState.connected
          : SshConnectionState.disconnected;
    }
    _errorMessage = null;
    _lastError = null;
    notifyListeners();
  }

  /// Check if there are saved credentials
  Future<bool> hasSavedCredentials() async {
    return await SecureStorageService.hasStoredCredentials();
  }

  /// Clear saved credentials
  Future<void> clearSavedCredentials() async {
    await SecureStorageService.deleteCredentials();
    _currentCredentials = null;
    notifyListeners();
  }

  /// Cleanup SSH connections
  Future<void> _cleanup() async {
    try {
      _sshClient?.close();
      _sshClient = null;

      // Clear navigation state
      _currentFiles.clear();
      _currentPath = '';
      _navigationHistory.clear();

      // Limpar o cache de tamanho de arquivo
      _fileSizeCache.clear();
    } catch (e) {
      // Log cleanup errors but don't throw
      debugPrint('Error during SSH cleanup: $e');
    }
  }

  /// Format error messages for better user experience
  String _formatError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Common SSH connection errors
    if (errorString.contains('connection refused') ||
        errorString.contains('connection denied')) {
      return 'Connection refused. Check if SSH service is running on the server.';
    } else if (errorString.contains('no route to host') ||
        errorString.contains('unreachable')) {
      return 'Host unreachable. Check the server address and network connection.';
    } else if (errorString.contains('authentication failed') ||
        errorString.contains('access denied')) {
      return 'Authentication failed. Check your username and password.';
    } else if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Connection timeout. The server may be down or unreachable.';
    } else if (errorString.contains('key exchange') ||
        errorString.contains('handshake')) {
      return 'Key exchange failed. The server may not support this client.';
    } else if (errorString.contains('host key verification')) {
      return 'Host key verification failed. The server identity could not be verified.';
    } else if (errorString.contains('network')) {
      return 'Network error. Check your internet connection.';
    }

    return 'Connection error: ${error.toString()}';
  }

  /// Generate unique log ID
  String _generateLogId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'log_${timestamp}_$random';
  }

  /// Detect command type based on command string
  CommandType _detectCommandType(String command) {
    final cmd = command.trim().split(' ').first.toLowerCase();

    const Map<String, CommandType> commandMap = {
      'ls': CommandType.navigation,
      'cd': CommandType.navigation,
      'pwd': CommandType.navigation,
      'find': CommandType.navigation,
      'tree': CommandType.navigation,
      'cat': CommandType.fileView,
      'tail': CommandType.fileView,
      'head': CommandType.fileView,
      'less': CommandType.fileView,
      'more': CommandType.fileView,
      'grep': CommandType.fileView,
      'awk': CommandType.fileView,
      'sed': CommandType.fileView,
      'ps': CommandType.system,
      'top': CommandType.system,
      'htop': CommandType.system,
      'df': CommandType.system,
      'du': CommandType.system,
      'free': CommandType.system,
      'uname': CommandType.system,
      'whoami': CommandType.system,
      'date': CommandType.system,
      'uptime': CommandType.system,
      'mount': CommandType.system,
      'lsblk': CommandType.system,
      'systemctl': CommandType.system,
      'service': CommandType.system,
    };

    // Check if it's a known command type
    if (commandMap.containsKey(cmd)) {
      return commandMap[cmd]!;
    }

    // Check for script execution patterns
    if (cmd.startsWith('./') ||
        cmd.startsWith('/') ||
        command.contains('bash') ||
        command.contains('sh') ||
        command.contains('python') ||
        command.contains('perl') ||
        command.contains('ruby') ||
        command.contains('node')) {
      return CommandType.execution;
    }

    return CommandType.unknown;
  }

  /// Add log entry to session log
  void _addLogEntry(LogEntry entry) {
    _sessionLog.add(entry);

    // Limit number of entries
    if (_sessionLog.length > _maxLogEntries) {
      _sessionLog.removeAt(0);
    }

    notifyListeners();
  }

  /// Get session statistics
  Map<String, dynamic> getSessionStats() {
    if (_sessionLog.isEmpty || _sessionStartTime == null) {
      return {
        'totalCommands': 0,
        'successfulCommands': 0,
        'failedCommands': 0,
        'totalDuration': Duration.zero,
        'sessionDuration': Duration.zero,
        'commandsByType': <String, int>{},
        'mostUsedCommands': <String>[],
        'successRate': 0.0,
      };
    }

    final totalCommands = _sessionLog.length;
    final successfulCommands = _sessionLog.where((e) => e.wasSuccessful).length;
    final failedCommands = _sessionLog.where((e) => e.hasError).length;

    final totalDuration = _sessionLog.fold<Duration>(
      Duration.zero,
      (sum, entry) => sum + entry.duration,
    );

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    // Count commands by type
    final commandsByType = <String, int>{};
    for (final entry in _sessionLog) {
      final typeName = entry.type.toString().split('.').last;
      commandsByType[typeName] = (commandsByType[typeName] ?? 0) + 1;
    }

    // Get most used commands
    final commandCounts = <String, int>{};
    for (final entry in _sessionLog) {
      final cmd = entry.command.split(' ').first;
      commandCounts[cmd] = (commandCounts[cmd] ?? 0) + 1;
    }

    final mostUsed = commandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostUsedCommands = mostUsed.take(5).map((e) => e.key).toList();

    final successRate =
        totalCommands > 0 ? successfulCommands / totalCommands : 0.0;

    return {
      'totalCommands': totalCommands,
      'successfulCommands': successfulCommands,
      'failedCommands': failedCommands,
      'totalDuration': totalDuration,
      'sessionDuration': sessionDuration,
      'commandsByType': commandsByType,
      'mostUsedCommands': mostUsedCommands,
      'successRate': successRate,
    };
  }

  /// Filter session log
  List<LogEntry> filterSessionLog({
    CommandType? type,
    CommandStatus? status,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _sessionLog.where((entry) {
      // Filter by type
      if (type != null && entry.type != type) return false;

      // Filter by status
      if (status != null && entry.status != status) return false;

      // Filter by search term
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final term = searchTerm.toLowerCase();
        if (!entry.command.toLowerCase().contains(term) &&
            !entry.stdout.toLowerCase().contains(term) &&
            !entry.stderr.toLowerCase().contains(term)) {
          return false;
        }
      }

      // Filter by date range
      if (startDate != null && entry.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && entry.timestamp.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  /// Clear session log
  void clearSessionLog() {
    _sessionLog.clear();
    notifyListeners();
  }

  /// Set logging enabled/disabled
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
    notifyListeners();
  }

  /// Set maximum log entries
  void setMaxLogEntries(int max) {
    _maxLogEntries = max;

    // Trim existing log if necessary
    while (_sessionLog.length > _maxLogEntries) {
      _sessionLog.removeAt(0);
    }

    notifyListeners();
  }

  /// Export session log in specified format
  String exportSessionLog({required String format, List<LogEntry>? entries}) {
    final logEntries = entries ?? _sessionLog;

    switch (format.toLowerCase()) {
      case 'json':
        return jsonEncode(logEntries.map((e) => e.toJson()).toList());

      case 'csv':
        const header =
            'Timestamp,Command,Type,Status,Duration,Working Directory,Exit Code,STDOUT,STDERR\n';
        final rows = logEntries.map((e) => e.toCsvRow()).join('\n');
        return header + rows;

      case 'txt':
      default:
        return logEntries.map((e) => e.toTextFormat()).join('\n${'-' * 80}\n');
    }
  }

  @override
  void dispose() {
    _cleanup();
    try {
      _lazyAudioPlayer?.dispose();
    } catch (_) {
      // ignore
    }
    super.dispose();
  }

  /// Return existing AudioPlayer or create it lazily via factory.
  AudioPlayer _getOrCreateAudioPlayer() {
    _lazyAudioPlayer ??= audioPlayerFactory.create();
    return _lazyAudioPlayer!;
  }
}
