/// Enum representing the different states of SSH connection
enum SshConnectionState {
  /// Not connected to any SSH server
  disconnected,
  
  /// Currently attempting to connect to SSH server
  connecting,
  
  /// Successfully connected to SSH server
  connected,
  
  /// An error occurred during connection or operation
  error,
}

/// Extension to provide human-readable descriptions for connection states
extension SshConnectionStateExtension on SshConnectionState {
  String get description {
    switch (this) {
      case SshConnectionState.disconnected:
        return 'Desconectado';
      case SshConnectionState.connecting:
        return 'Conectando...';
      case SshConnectionState.connected:
        return 'Conectado';
      case SshConnectionState.error:
        return 'Erro na conexão';
    }
  }
  
  bool get isConnected => this == SshConnectionState.connected;
  bool get isConnecting => this == SshConnectionState.connecting;
  bool get hasError => this == SshConnectionState.error;
}