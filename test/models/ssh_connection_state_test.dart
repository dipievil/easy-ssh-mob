import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/models/ssh_connection_state.dart';

void main() {
  group('SshConnectionState', () {
    test('should have correct values', () {
      expect(SshConnectionState.values, [
        SshConnectionState.disconnected,
        SshConnectionState.connecting,
        SshConnectionState.connected,
        SshConnectionState.error,
      ]);
    });
  });

  group('SshConnectionStateExtension', () {
    test('description should return correct strings', () {
      expect(SshConnectionState.disconnected.description, 'Disconnected');
      expect(SshConnectionState.connecting.description, 'Connecting...');
      expect(SshConnectionState.connected.description, 'Connected');
      expect(SshConnectionState.error.description, 'Error');
    });

    test('isConnected should only be true for connected state', () {
      expect(SshConnectionState.connected.isConnected, true);
      expect(SshConnectionState.disconnected.isConnected, false);
      expect(SshConnectionState.connecting.isConnected, false);
      expect(SshConnectionState.error.isConnected, false);
    });

    test('isConnecting should only be true for connecting state', () {
      expect(SshConnectionState.connecting.isConnecting, true);
      expect(SshConnectionState.disconnected.isConnecting, false);
      expect(SshConnectionState.connected.isConnecting, false);
      expect(SshConnectionState.error.isConnecting, false);
    });

    test('isDisconnected should only be true for disconnected state', () {
      expect(SshConnectionState.disconnected.isDisconnected, true);
      expect(SshConnectionState.connecting.isDisconnected, false);
      expect(SshConnectionState.connected.isDisconnected, false);
      expect(SshConnectionState.error.isDisconnected, false);
    });

    test('hasError should only be true for error state', () {
      expect(SshConnectionState.error.hasError, true);
      expect(SshConnectionState.disconnected.hasError, false);
      expect(SshConnectionState.connecting.hasError, false);
      expect(SshConnectionState.connected.hasError, false);
    });
  });
}