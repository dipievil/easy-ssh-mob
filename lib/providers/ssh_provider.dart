import 'package:flutter/foundation.dart';

class SshProvider extends ChangeNotifier {
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _errorMessage;

  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;

  Future<bool> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate connection delay
      await Future.delayed(const Duration(seconds: 2));
      
      // For now, simulate a successful connection
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isConnecting = false;
      notifyListeners();
      
      return false;
    }
  }

  void disconnect() {
    _isConnected = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}