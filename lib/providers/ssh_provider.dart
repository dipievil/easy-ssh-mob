import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import '../models/ssh_credentials.dart';
import '../models/ssh_connection_state.dart';
import '../models/ssh_file.dart';
import '../services/secure_storage_service.dart';

class SshProvider extends ChangeNotifier {
  SshConnectionState _connectionState = SshConnectionState.disconnected;
  String? _errorMessage;
  SSHCredentials? _currentCredentials;
  SSHClient? _sshClient;
  
  // Directory navigation properties
  List<SshFile> _currentFiles = [];
  String _currentPath = '';
  List<String> _navigationHistory = [];

  SshConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  SSHCredentials? get currentCredentials => _currentCredentials;
  List<SshFile> get currentFiles => _currentFiles;
  String get currentPath => _currentPath;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  
  // Backward compatibility getters
  bool get isConnecting => _connectionState.isConnecting;
  bool get isConnected => _connectionState.isConnected;

  /// Initialize the provider and load saved credentials
  Future<void> initialize() async {
    try {
      _currentCredentials = await SecureStorageService.loadCredentials();
      notifyListeners();
    } catch (e) {
      print('Error initializing SSH provider: $e');
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
        await SecureStorageService.saveCredentials(credentials);
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
      _errorMessage = 'Not connected to SSH server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return;
    }

    try {
      // Normalize the path
      final normalizedPath = _normalizePath(path);
      
      // Execute ls -F command
      final output = await _sshClient!.execute('ls -F "$normalizedPath"');
      
      if (output == null) {
        _errorMessage = 'Failed to list directory contents';
        _connectionState = SshConnectionState.error;
        notifyListeners();
        return;
      }

      // Parse the output
      final files = <SshFile>[];
      final lines = output.split('\n');
      
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
      
      // Clear any previous errors on successful listing
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = _formatDirectoryError(e);
      _connectionState = SshConnectionState.error;
      notifyListeners();
    }
  }

  /// Navigate to a directory and add to history
  Future<void> navigateToDirectory(String path) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _errorMessage = 'Not connected to SSH server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return;
    }

    try {
      final normalizedPath = _normalizePath(path);
      
      // Test if directory exists and is accessible
      final testResult = await _sshClient!.execute('test -d "$normalizedPath" && echo "OK"');
      
      if (testResult?.trim() != 'OK') {
        _errorMessage = 'Directory does not exist or is not accessible: $normalizedPath';
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
      final homeResult = await _sshClient!.execute('echo ~');
      final homePath = homeResult?.trim() ?? '/';
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
    
    if (errorString.contains('permission denied') || errorString.contains('access denied')) {
      return 'Permission denied. You do not have access to this directory.';
    } else if (errorString.contains('no such file or directory') || errorString.contains('not found')) {
      return 'Directory not found or does not exist.';
    } else if (errorString.contains('not a directory')) {
      return 'The specified path is not a directory.';
    } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Directory listing timeout. The server may be slow or unresponsive.';
    }
    
    return 'Error accessing directory: ${error.toString()}';
  }

  /// Execute a command on the SSH server
  Future<String?> executeCommand(String command) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _errorMessage = 'Not connected to SSH server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }

    try {
      // Execute command using SSH client
      final result = await _sshClient!.execute(command);
      
      // Clear any previous errors on successful execution
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _errorMessage = _formatError(e);
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }
  }

  /// Execute a command and return the result as a stream
  Future<String?> executeCommandWithResult(String command) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _errorMessage = 'Not connected to SSH server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }

    try {
      // Execute command and get result
      final result = await _sshClient!.execute(command);
      
      // Clear any previous errors on successful execution
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _errorMessage = _formatError(e);
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
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
    } catch (e) {
      // Log cleanup errors but don't throw
      debugPrint('Error during SSH cleanup: $e');
    }
  }

  /// Format error messages for better user experience
  String _formatError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Common SSH connection errors
    if (errorString.contains('connection refused') || errorString.contains('connection denied')) {
      return 'Connection refused. Check if SSH service is running on the server.';
    } else if (errorString.contains('no route to host') || errorString.contains('unreachable')) {
      return 'Host unreachable. Check the server address and network connection.';
    } else if (errorString.contains('authentication failed') || errorString.contains('access denied')) {
      return 'Authentication failed. Check your username and password.';
    } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Connection timeout. The server may be down or unreachable.';
    } else if (errorString.contains('key exchange') || errorString.contains('handshake')) {
      return 'Key exchange failed. The server may not support this client.';
    } else if (errorString.contains('host key verification')) {
      return 'Host key verification failed. The server identity could not be verified.';
    } else if (errorString.contains('network')) {
      return 'Network error. Check your internet connection.';
    }
    
    return 'Connection error: ${error.toString()}';
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}