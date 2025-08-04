/// SSH connection states enum
enum SshConnectionState {
  /// Not connected to any SSH server
  disconnected,

  /// Currently connecting to SSH server
  connecting,

  /// Successfully connected to SSH server
  connected,

  /// Error occurred during connection or command execution
  error,
}

/// Extension to provide human-readable descriptions
extension SshConnectionStateExtension on SshConnectionState {
  String get description {
    switch (this) {
      case SshConnectionState.disconnected:
        return 'Disconnected';
      case SshConnectionState.connecting:
        return 'Connecting...';
      case SshConnectionState.connected:
        return 'Connected';
      case SshConnectionState.error:
        return 'Error';
    }
  }

  bool get isConnected => this == SshConnectionState.connected;
  bool get isConnecting => this == SshConnectionState.connecting;
  bool get isDisconnected => this == SshConnectionState.disconnected;
  bool get hasError => this == SshConnectionState.error;
}
