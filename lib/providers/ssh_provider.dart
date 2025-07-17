import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import '../models/ssh_connection_state.dart';

/// Provider for managing SSH connections and state
/// 
/// This class handles all SSH-related operations including connection,
/// disconnection, and command execution while managing the application state.
class SshProvider extends ChangeNotifier {
  // Private fields
  SSHClient? _client;
  SshConnectionState _state = SshConnectionState.disconnected;
  String? _errorMessage;
  String? _currentHost;
  int? _currentPort;
  String? _currentUsername;
  
  // Connection timeout configurations
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _commandTimeout = Duration(seconds: 60);
  
  // Public getters
  SshConnectionState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _state == SshConnectionState.connected;
  bool get isConnecting => _state == SshConnectionState.connecting;
  bool get hasError => _state == SshConnectionState.error;
  String? get currentHost => _currentHost;
  int? get currentPort => _currentPort;
  String? get currentUsername => _currentUsername;
  
  /// Connect to SSH server
  /// 
  /// [host] - SSH server hostname or IP address
  /// [port] - SSH server port (typically 22)
  /// [username] - SSH username
  /// [password] - SSH password
  /// 
  /// Returns true if connection successful, false otherwise
  Future<bool> connect(String host, String port, String username, String password) async {
    try {
      // Validate input parameters
      if (host.trim().isEmpty) {
        _setError('Host não pode estar vazio');
        return false;
      }
      
      if (username.trim().isEmpty) {
        _setError('Usuário não pode estar vazio');
        return false;
      }
      
      if (password.trim().isEmpty) {
        _setError('Senha não pode estar vazia');
        return false;
      }
      
      // Parse port
      int portNumber;
      try {
        portNumber = int.parse(port.trim());
        if (portNumber <= 0 || portNumber > 65535) {
          _setError('Porta deve estar entre 1 e 65535');
          return false;
        }
      } catch (e) {
        _setError('Porta deve ser um número válido');
        return false;
      }
      
      // Set connecting state
      _setState(SshConnectionState.connecting);
      _clearError();
      
      // Disconnect existing connection if any
      if (_client != null) {
        await disconnect();
      }
      
      // Create new SSH client
      final socket = await SSHSocket.connect(
        host.trim(),
        portNumber,
        timeout: _connectionTimeout,
      );
      
      _client = SSHClient(
        socket,
        username: username.trim(),
        onPasswordRequest: () => password,
      );
      
      // Store connection details
      _currentHost = host.trim();
      _currentPort = portNumber;
      _currentUsername = username.trim();
      
      // Set connected state
      _setState(SshConnectionState.connected);
      
      return true;
      
    } on SSHAuthFailureError {
      _setError('Falha na autenticação. Verifique usuário e senha.');
      return false;
    } on SocketException catch (e) {
      _setError('Erro de conexão: ${e.message}');
      return false;
    } on TimeoutException {
      _setError('Timeout na conexão. Verifique host e porta.');
      return false;
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }
  
  /// Disconnect from SSH server
  Future<void> disconnect() async {
    try {
      if (_client != null) {
        _client!.close();
        _client = null;
      }
      
      _currentHost = null;
      _currentPort = null;
      _currentUsername = null;
      _setState(SshConnectionState.disconnected);
      _clearError();
      
    } catch (e) {
      // Log error but don't set error state since we're disconnecting
      debugPrint('Erro ao desconectar: ${e.toString()}');
      _setState(SshConnectionState.disconnected);
    }
  }
  
  /// Execute a command on the remote SSH server
  /// 
  /// [command] - Command to execute
  /// 
  /// Returns the command output (stdout) as a string
  /// Throws exception on error
  Future<String> executeCommand(String command) async {
    if (!isConnected || _client == null) {
      throw Exception('Não conectado ao servidor SSH');
    }
    
    if (command.trim().isEmpty) {
      throw Exception('Comando não pode estar vazio');
    }
    
    try {
      final session = await _client!.execute(command.trim());
      
      // Wait for command completion with timeout
      final result = await session.stdout.cast<List<int>>().transform(const SystemEncoding().decoder).join()
          .timeout(_commandTimeout);
      
      // Check for stderr
      final errorOutput = await session.stderr.cast<List<int>>().transform(const SystemEncoding().decoder).join();
      
      // Wait for session to complete
      await session.done;
      
      // If there's error output, include it in the result
      if (errorOutput.isNotEmpty) {
        return '$result\nSTDERR:\n$errorOutput';
      }
      
      return result;
      
    } on TimeoutException {
      throw Exception('Timeout na execução do comando');
    } catch (e) {
      throw Exception('Erro ao executar comando: ${e.toString()}');
    }
  }
  
  /// Test connection by executing a simple command
  Future<bool> testConnection() async {
    if (!isConnected) {
      return false;
    }
    
    try {
      await executeCommand('echo "test"');
      return true;
    } catch (e) {
      _setError('Conexão perdida: ${e.toString()}');
      return false;
    }
  }
  
  /// Get current working directory
  Future<String> getCurrentDirectory() async {
    try {
      return await executeCommand('pwd');
    } catch (e) {
      throw Exception('Erro ao obter diretório atual: ${e.toString()}');
    }
  }
  
  /// List directory contents
  Future<String> listDirectory([String? path]) async {
    try {
      final command = path != null ? 'ls -la "$path"' : 'ls -la';
      return await executeCommand(command);
    } catch (e) {
      throw Exception('Erro ao listar diretório: ${e.toString()}');
    }
  }
  
  // Private methods
  void _setState(SshConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  void _setError(String error) {
    _errorMessage = error;
    _setState(SshConnectionState.error);
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}