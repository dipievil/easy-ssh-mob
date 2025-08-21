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
import '../services/sound_manager.dart';

/// Error message codes for localization in UI
enum ErrorMessageCode {
  notConnectedToSshServer,
  errorListingDirectory,
  checkPermissionsAndConnection,
  directoryNotAccessible,
  permissionDeniedDirectory,
  directoryNotFound,
  notADirectory,
  directoryTimeout,
  errorAccessingDirectory,
  executionError,
  commandTimeout,
  commandTimeoutSuggestion,
  sshConnectionError,
  errorSsh,
  commandExecutionError,
  connectionRefused,
  hostUnreachable,
  authenticationFailed,
  connectionTimeout,
  keyExchangeFailed,
  hostKeyVerificationFailed,
  networkError,
  connectionErrorGeneric,
}

class SshProvider extends ChangeNotifier {
  SshConnectionState _connectionState = SshConnectionState.disconnected;
  String? _errorMessage;
  ErrorMessageCode? _errorCode;
  String? _errorDetails;
  SSHCredentials? _currentCredentials;
  SSHClient? _sshClient;

  List<SshFile> _currentFiles = [];
  String _currentPath = '';
  final List<String> _navigationHistory = [];

  SshError? _lastError;
  AudioPlayer? _lazyAudioPlayer;
  bool _shouldPlayErrorSound = true;
  final NotificationService _notificationService = NotificationService();

  final Map<String, int> _fileSizeCache = {};

  final List<LogEntry> _sessionLog = [];
  bool _loggingEnabled = true;
  int _maxLogEntries = 1000;
  DateTime? _sessionStartTime;

  // Reconnection properties
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  SshConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  ErrorMessageCode? get errorCode => _errorCode;
  String? get errorDetails => _errorDetails;
  SSHCredentials? get currentCredentials => _currentCredentials;

  /// Set error with code and optional details
  void _setError(ErrorMessageCode code, {String? details, String? fallbackMessage}) {
    _errorCode = code;
    _errorDetails = details;
    _errorMessage = fallbackMessage ?? details ?? code.toString();
    notifyListeners();
  }
  List<SshFile> get currentFiles => _currentFiles;
  String get currentPath => _currentPath;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  SshError? get lastError => _lastError;
  bool get shouldPlayErrorSound => _shouldPlayErrorSound;

  List<LogEntry> get sessionLog => List.unmodifiable(_sessionLog);
  bool get loggingEnabled => _loggingEnabled;
  int get maxLogEntries => _maxLogEntries;
  DateTime? get sessionStartTime => _sessionStartTime;

  bool get isConnecting => _connectionState.isConnecting;
  bool get isConnected => _connectionState.isConnected;
  bool get isReconnecting => _isReconnecting;
  int get reconnectAttempts => _reconnectAttempts;

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
      final socket = await SSHSocket.connect(host, port);

      _sshClient = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      await _sshClient!.authenticated;

      _connectionState = SshConnectionState.connected;

      _sessionStartTime = DateTime.now();

      final credentials = SSHCredentials(
        host: host,
        port: port,
        username: username,
        password: password,
      );

      _currentCredentials = credentials;

      if (saveCredentials) {
        final saveSuccess =
            await SecureStorageService.saveCredentials(credentials);
        if (!saveSuccess) {
          debugPrint('Warning: Failed to save credentials to secure storage');
        } else {
          debugPrint('Credentials saved successfully');
        }
      }

      try {
        await navigateToHome();
      } catch (e) {
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

  Future<void> listDirectory(String path) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      final error = SshError(
        type: ErrorType.connectionLost,
        originalMessage: 'Not connected to SSH server',
        userFriendlyMessage: 'not_connected_to_ssh_server',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return;
    }

    try {
      final normalizedPath = _normalizePath(path);

      final session = await _sshClient!.execute('ls -F "$normalizedPath"');
      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();

      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(
          stderr,
          'ls -F "$normalizedPath"',
        );
        _handleSshError(error);
        return;
      }

      if (stdout.isEmpty) {
        _currentPath = normalizedPath;
        _currentFiles = [];

        if (_connectionState.hasError) {
          _connectionState = SshConnectionState.connected;
          _errorMessage = null;
          _lastError = null;
        }

        notifyListeners();
        return;
      }

      final files = <SshFile>[];
      final lines = stdout.split('\n');

      for (String line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) {
          try {
            files.add(SshFile.fromLsLine(trimmedLine, normalizedPath));
          } catch (e) {
            debugPrint('Error parsing line "$trimmedLine": $e');
          }
        }
      }

      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      _currentPath = normalizedPath;
      _currentFiles = files;

      _fileSizeCache.clear();

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
        userFriendlyMessage: 'error_listing_directory',
        suggestion: 'check_permissions_and_connection',
        severity: ErrorSeverity.error,
      );
      _handleSshError(error);
    }
  }

  Future<void> navigateToDirectory(String path) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _setError(ErrorMessageCode.notConnectedToSshServer, 
                fallbackMessage: 'Not connected to SSH server');
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return;
    }

    try {
      final normalizedPath = _normalizePath(path);

      final testSession = await _sshClient!.execute(
        'test -d "$normalizedPath" && echo "OK"',
      );
      final testResult = await utf8.decoder.bind(testSession.stdout).join();

      if (testResult.trim() != 'OK') {
        _setError(ErrorMessageCode.directoryNotAccessible, 
                 details: normalizedPath,
                 fallbackMessage: 'Directory not accessible: $normalizedPath');
        _connectionState = SshConnectionState.error;
        notifyListeners();
        return;
      }

      if (_currentPath.isNotEmpty && _currentPath != normalizedPath) {
        _navigationHistory.add(_currentPath);
        if (_navigationHistory.length > 50) {
          _navigationHistory.removeAt(0);
        }
      }

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

    if (!path.startsWith('/')) {
      path = _currentPath.isEmpty ? '/$path' : '$_currentPath/$path';
    }

    final components = path.split('/').where((c) => c.isNotEmpty).toList();
    final normalized = <String>[];

    for (final component in components) {
      if (component == '.') {
        continue;
      } else if (component == '..') {
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
      return 'permission_denied_directory';
    } else if (errorString.contains('no such file or directory') ||
        errorString.contains('not found')) {
      return 'directory_not_found';
    } else if (errorString.contains('not a directory')) {
      return 'not_a_directory';
    } else if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'directory_timeout';
    }

    return 'error_accessing_directory:${error.toString()}';
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
        stderr: 'not_connected_to_ssh_server',
        exitCode: -1,
        duration: DateTime.now().difference(startTime),
        timestamp: startTime,
      );
    }

    try {
      String command;

      if (file.type == FileType.executable) {
        command = '"${file.fullPath}"';
      } else {
        command = await _buildScriptCommand(file);
      }

      debugPrint('Executing command: $command');

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
        stderr: 'error_code',
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

    try {
      final headSession = await _sshClient!.execute('head -1 "$filePath"');
      final headResult = await utf8.decoder.bind(headSession.stdout).join();
      if (headResult.startsWith('#!')) {
        final shebang = headResult.trim();
        final interpreter = shebang.substring(2).split(' ').first;
        return '$interpreter "$filePath"';
      }
    } catch (e) {
      debugPrint('Could not read shebang: $e');
    }

    return '"$filePath"';
  }

  /// Execute command with timeout and separate stdout/stderr capture
  Future<Map<String, dynamic>> _executeCommandWithTimeout(
    String command,
    Duration timeout,
  ) async {
    try {
      final session = await _sshClient!.execute(command);

      final Future<String> stdoutFuture =
          utf8.decoder.bind(session.stdout).join();
      final Future<String> stderrFuture =
          utf8.decoder.bind(session.stderr).join();
      final int? exitCode = session.exitCode;

      final results = await Future.wait([
        stdoutFuture.timeout(timeout),
        stderrFuture.timeout(timeout),
      ]);

      final stdout = results[0];
      final stderr = results[1];

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
          userFriendlyMessage: 'error_code',
          suggestion: 'error_code',
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
          stderr: 'error_code',
          exitCode: -1,
          duration: DateTime.now().difference(startTime),
          status: CommandStatus.error,
        );
        _addLogEntry(errorEntry);
      }

      _errorMessage = 'not_connected_to_ssh_server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }

    try {
      final session = await _sshClient!.execute(command);

      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();
      final exitCode = session.exitCode;
      final duration = DateTime.now().difference(startTime);

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

      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(stderr, command);
        _handleSshError(error);
      }

      if (_connectionState.hasError && stderr.isEmpty) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        notifyListeners();
      }

      return stdout;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

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
        userFriendlyMessage: 'error_code',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return null;
    }
  }

  void _handleSshError(SshError error) {
    _lastError = error;
    _errorMessage = error.userFriendlyMessage;
    _connectionState = SshConnectionState.error;
    notifyListeners();

    debugPrint('SSH Error: ${error.type} - ${error.originalMessage}');

    // Try automatic reconnection for connection lost errors
    if (error.type == ErrorType.connectionLost && !_isReconnecting) {
      _attemptAutoReconnection();
      return; // Don't show notification yet, let reconnection handle it
    }

    // Try automatic reconnection for connection lost errors
    if (error.type == ErrorType.connectionLost && !_isReconnecting) {
      _attemptAutoReconnection();
      return; // Don't show notification yet, let reconnection handle it
    }

    _notificationService.showNotification(
      message: error.userFriendlyMessage,
      type: _mapErrorToNotificationType(error.severity),
      title: 'error_code',
      details: error.originalMessage,
    );

    if (_shouldPlayErrorSound && _shouldPlaySoundForSeverity(error.severity)) {
      _playErrorSound();
    }
  }

  /// Attempt automatic reconnection when connection is lost
  Future<void> _attemptAutoReconnection() async {
    if (_isReconnecting || _currentCredentials == null) {
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts = 0;
    _connectionState = SshConnectionState.connecting;
    notifyListeners();

    debugPrint('Attempting automatic reconnection...');

    while (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;

      try {
        debugPrint(
            'Reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts');

        // Clean up current connection
        await _cleanup();

        // Wait before retry
        await Future.delayed(_reconnectDelay);

        // Try to reconnect using saved credentials
        final success = await connect(
          host: _currentCredentials!.host,
          port: _currentCredentials!.port,
          username: _currentCredentials!.username,
          password: _currentCredentials!.password,
          saveCredentials: false, // Don't save again
        );

        if (success) {
          _isReconnecting = false;
          _reconnectAttempts = 0;

          // Show success notification
          _notificationService.showNotification(
            message: 'Reconectado com sucesso',
            type: NotificationType.success,
            title: 'SSH Reconectado',
          );

          debugPrint('Automatic reconnection successful');
          return;
        }
      } catch (e) {
        debugPrint('Reconnection attempt $_reconnectAttempts failed: $e');
      }
    }

    // All reconnection attempts failed
    _isReconnecting = false;
    _connectionState = SshConnectionState.error;
    _errorMessage = 'Falha na reconexão automática';
    notifyListeners();

    debugPrint('All reconnection attempts failed');

    // Show reconnection options dialog
    _showReconnectionDialog();
  }

  /// Show dialog with reconnection options
  void _showReconnectionDialog() {
    // This will be handled by the UI layer through a callback
    // The UI will listen to connection state and show dialog when needed
    _notificationService.showNotification(
      message: 'Conexão perdida. Toque para ver opções.',
      type: NotificationType.critical,
      title: 'Conexão SSH Perdida',
      details:
          'Falha na reconexão automática após $_maxReconnectAttempts tentativas.',
    );
  }

  /// Manual reconnection attempt triggered by user
  Future<bool> attemptManualReconnection() async {
    if (_currentCredentials == null) {
      return false;
    }

    try {
      await _cleanup();
      return await connect(
        host: _currentCredentials!.host,
        port: _currentCredentials!.port,
        username: _currentCredentials!.username,
        password: _currentCredentials!.password,
        saveCredentials: false,
      );
    } catch (e) {
      debugPrint('Manual reconnection failed: $e');
      return false;
    }
  }

  /// Reset reconnection state (used when user chooses to go to login)
  void resetReconnectionState() {
    _isReconnecting = false;
    _reconnectAttempts = 0;
    notifyListeners();
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
      SoundManager.playNotificationSound(
        NotificationType.error,
        50,
      );
    } catch (e) {
      debugPrint('Could not play error sound: $e');
    }
  }

  /// Toggle error sound setting
  void setErrorSoundEnabled(bool enabled) {
    _shouldPlayErrorSound = enabled;
    notifyListeners();
  }

  /// Execute a command and return the result as a stream
  Future<String?> executeCommandWithResult(String command) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      final error = SshError(
        type: ErrorType.connectionLost,
        originalMessage: 'Not connected to SSH server',
        userFriendlyMessage: 'error_code',
        severity: ErrorSeverity.critical,
      );
      _handleSshError(error);
      return null;
    }

    try {
      final session = await _sshClient!.execute(command);

      final stdout = await utf8.decoder.bind(session.stdout).join();
      final stderr = await utf8.decoder.bind(session.stderr).join();

      if (stderr.isNotEmpty) {
        final error = ErrorHandler.analyzeError(stderr, command);
        _handleSshError(error);
        return stdout;
      }

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
        userFriendlyMessage: 'error_code',
        severity: ErrorSeverity.error,
      );
      _handleSshError(error);
      return null;
    }
  }

  /// Obtém o tamanho do arquivo com cache para evitar comandos stat duplicados
  Future<int> _getFileSize(SshFile file) async {
    final cacheKey = file.fullPath;
    if (_fileSizeCache.containsKey(cacheKey)) {
      return _fileSizeCache[cacheKey]!;
    }

    final sizeSession = await _sshClient!.execute(
      'stat -f%z "${file.fullPath}" 2>/dev/null || stat -c%s "${file.fullPath}"',
    );
    final sizeOutput = await utf8.decoder.bind(sizeSession.stdout).join();
    final fileSize = int.tryParse(sizeOutput.trim()) ?? 0;

    _fileSizeCache[cacheKey] = fileSize;

    return fileSize;
  }

  /// Read content of a text file
  Future<FileContent> readFile(SshFile file) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      throw Exception('not_connected_to_ssh_server');
    }

    if (!file.isTextFile && file.type != FileType.regular) {
      throw Exception('file_not_text_file');
    }

    try {
      final fileSize = await _getFileSize(file);

      const maxSize = 1024 * 1024;

      if (fileSize > maxSize) {
        return _readFilePart(file, FileViewMode.head, fileSize);
      } else {
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
      throw Exception('error_reading_file: ${e.toString()}');
    }
  }

  /// Read part of a file (head or tail)
  Future<FileContent> _readFilePart(
    SshFile file,
    FileViewMode mode,
    int fileSize,
  ) async {
    const linesCount = 100;

    String command;
    switch (mode) {
      case FileViewMode.head:
        command = 'head -$linesCount "${file.fullPath}"';
        break;
      case FileViewMode.tail:
        command = 'tail -$linesCount "${file.fullPath}"';
        break;
      default:
        throw Exception('invalid_mode_partial_read: ${mode.toString()}');
    }

    final contentSession = await _sshClient!.execute(command);
    final content = await utf8.decoder.bind(contentSession.stdout).join();

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
      throw Exception('error_message');
    }

    try {
      final fileSize = await _getFileSize(file);

      switch (mode) {
        case FileViewMode.full:
          return readFile(file);
        case FileViewMode.head:
        case FileViewMode.tail:
          return _readFilePart(file, mode, fileSize);
        default:
          throw Exception('read_mode_not_supported: ${mode.toString()}');
      }
    } catch (e) {
      throw Exception('error_reading_file_with_mode: ${mode.toString()}, ${e.toString()}');
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

      _currentFiles.clear();
      _currentPath = '';
      _navigationHistory.clear();

      _fileSizeCache.clear();
    } catch (e) {
      debugPrint('Error during SSH cleanup: $e');
    }
  }

  /// Format error messages for better user experience
  String _formatError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Check for specific error types and return appropriate error codes
    if (errorString.contains('connection refused') ||
        errorString.contains('connection denied')) {
      return 'connection_refused';
    } else if (errorString.contains('no route to host') ||
        errorString.contains('unreachable')) {
      return 'host_unreachable';
    } else if (errorString.contains('authentication failed') ||
        errorString.contains('access denied')) {
      return 'authentication_failed';
    } else if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'connection_timeout';
    } else if (errorString.contains('key exchange') ||
        errorString.contains('handshake')) {
      return 'key_exchange_failed';
    } else if (errorString.contains('host key verification')) {
      return 'host_key_verification_failed';
    } else if (errorString.contains('network')) {
      return 'network_error';
    }

    return 'connection_error_generic:${error.toString()}';
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

    if (commandMap.containsKey(cmd)) {
      return commandMap[cmd]!;
    }

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

    final commandsByType = <String, int>{};
    for (final entry in _sessionLog) {
      final typeName = entry.type.toString().split('.').last;
      commandsByType[typeName] = (commandsByType[typeName] ?? 0) + 1;
    }

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
      if (type != null && entry.type != type) return false;

      if (status != null && entry.status != status) return false;

      if (searchTerm != null && searchTerm.isNotEmpty) {
        final term = searchTerm.toLowerCase();
        if (!entry.command.toLowerCase().contains(term) &&
            !entry.stdout.toLowerCase().contains(term) &&
            !entry.stderr.toLowerCase().contains(term)) {
          return false;
        }
      }

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
    } catch (_) {}
    super.dispose();
  }
}
