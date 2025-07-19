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