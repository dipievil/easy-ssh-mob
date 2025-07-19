import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import '../models/ssh_credentials.dart';
import '../models/ssh_connection_state.dart';
import '../services/secure_storage_service.dart';

class SshProvider extends ChangeNotifier {
  SshConnectionState _connectionState = SshConnectionState.disconnected;
  String? _errorMessage;
  SSHCredentials? _currentCredentials;
  SSHClient? _sshClient;
  SSHSession? _sshSession;

  SshConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  SSHCredentials? get currentCredentials => _currentCredentials;
  
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
      
      // Create SSH client
      _sshClient = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      // Wait for connection to be established
      await _sshClient!.authenticated;
      
      // Create SSH session for command execution
      _sshSession = await _sshClient!.shell();
      
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

  /// Execute a command and return both stdout and stderr
  Future<Map<String, String>?> executeCommandDetailed(String command) async {
    if (!_connectionState.isConnected || _sshClient == null) {
      _errorMessage = 'Not connected to SSH server';
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }

    try {
      // Create a new session for this command
      final session = await _sshClient!.execute(command);
      
      // Clear any previous errors on successful execution
      if (_connectionState.hasError) {
        _connectionState = SshConnectionState.connected;
        _errorMessage = null;
        notifyListeners();
      }
      
      return {
        'stdout': session,
        'stderr': '', // dartssh2 combines stdout and stderr
      };
    } catch (e) {
      _errorMessage = _formatError(e);
      _connectionState = SshConnectionState.error;
      notifyListeners();
      return null;
    }
  }

  void disconnect() async {
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
      await _sshSession?.close();
      _sshSession = null;
      
      _sshClient?.close();
      _sshClient = null;
    } catch (e) {
      // Log cleanup errors but don't throw
      debugPrint('Error during SSH cleanup: $e');
    }
  }

  /// Format error messages for better user experience
  String _formatError(dynamic error) {
    if (error is SSHException) {
      switch (error.type) {
        case SSHExceptionType.hostUnreachable:
          return 'Host unreachable. Check the server address and port.';
        case SSHExceptionType.authenticationFailed:
          return 'Authentication failed. Check your username and password.';
        case SSHExceptionType.connectionTimeout:
          return 'Connection timeout. The server may be down or unreachable.';
        case SSHExceptionType.keyExchangeFailed:
          return 'Key exchange failed. The server may not support this client.';
        default:
          return 'SSH Error: ${error.message}';
      }
    }
    
    final errorString = error.toString();
    
    // Common SSH connection errors
    if (errorString.contains('Connection refused')) {
      return 'Connection refused. Check if SSH service is running on the server.';
    } else if (errorString.contains('No route to host')) {
      return 'No route to host. Check the server address and network connection.';
    } else if (errorString.contains('Authentication failed')) {
      return 'Authentication failed. Check your username and password.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. The server may be down or unreachable.';
    }
    
    return 'Connection error: $errorString';
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}