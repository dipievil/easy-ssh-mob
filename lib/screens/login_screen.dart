import 'package:flutter/material.dart';
import '../models/ssh_credentials.dart';
import '../services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberCredentials = false;
  bool _isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  /// Load stored credentials when the screen initializes
  Future<void> _loadStoredCredentials() async {
    try {
      final shouldRemember = await SecureStorageService.shouldRememberCredentials();
      if (shouldRemember) {
        final credentials = await SecureStorageService.loadCredentials();
        if (credentials != null && credentials.isValid()) {
          setState(() {
            _hostController.text = credentials.host;
            _portController.text = credentials.port.toString();
            _usernameController.text = credentials.username;
            _passwordController.text = credentials.password;
            _rememberCredentials = true;
          });
        }
      }
    } catch (e) {
      // Show error but don't prevent user from using the app
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved credentials: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
  }

  /// Save credentials if user chose to remember them
  Future<void> _saveCredentialsIfRequested(SSHCredentials credentials) async {
    if (_rememberCredentials) {
      try {
        await SecureStorageService.saveCredentials(credentials);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving credentials: $e')),
          );
        }
      }
    } else {
      // If user unchecked remember, clear any stored credentials
      try {
        await SecureStorageService.deleteCredentials();
      } catch (e) {
        // Silently handle this error as it's not critical
      }
    }
  }

  /// Clear stored credentials
  Future<void> _forgetCredentials() async {
    try {
      await SecureStorageService.deleteCredentials();
      setState(() {
        _hostController.clear();
        _portController.text = '22';
        _usernameController.clear();
        _passwordController.clear();
        _rememberCredentials = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credentials forgotten')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error forgetting credentials: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _connect() async {
    // Validate input
    if (_hostController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final port = int.tryParse(_portController.text);
    if (port == null || port <= 0 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid port number (1-65535)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create credentials object
      final credentials = SSHCredentials(
        host: _hostController.text.trim(),
        port: port,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Save credentials if requested
      await _saveCredentialsIfRequested(credentials);

      // TODO: Implement actual SSH connection logic here
      
      // Simulate connection delay for now
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection functionality not implemented yet')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasySSH'),
        centerTitle: true,
        actions: [
          // Forget credentials button
          IconButton(
            onPressed: _isLoadingCredentials ? null : _forgetCredentials,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Forget saved credentials',
          ),
        ],
      ),
      body: _isLoadingCredentials
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading saved credentials...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.computer,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.dns),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Save credentials'),
                    subtitle: const Text('Securely store credentials for auto-fill'),
                    value: _rememberCredentials,
                    onChanged: (value) {
                      setState(() {
                        _rememberCredentials = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: const Icon(Icons.security),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _connect,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(_isLoading ? 'Connecting...' : 'Connect'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}