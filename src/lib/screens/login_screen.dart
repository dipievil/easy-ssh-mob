import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/ssh_provider.dart';
import '../widgets/custom_components.dart';
import '../utils/custom_animations.dart';
import '../utils/responsive_breakpoints.dart';
import 'file_explorer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberCredentials = false;
  bool _isLoading = false;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load saved credentials if available
  Future<void> _loadSavedCredentials() async {
    setState(() {
      _isLoading = true;
    });

    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    final credentials = sshProvider.currentCredentials;

    if (credentials != null && credentials.isValid()) {
      _hostController.text = credentials.host;
      _portController.text = credentials.port.toString();
      _usernameController.text = credentials.username;
      _passwordController.text = credentials.password;
      setState(() {
        _rememberCredentials = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _validateHost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host/IP é obrigatório';
    }
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Porta é obrigatória';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Porta deve ser um número';
    }
    
    if (port < 1 || port > 65535) {
      return 'Porta deve estar entre 1 e 65535';
    }
    
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Usuário é obrigatório';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Senha é obrigatória';
    }
    return null;
  }

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    
    final success = await sshProvider.connect(
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      saveCredentials: _rememberCredentials,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        SlideRoute(
          page: const FileExplorerScreen(),
          direction: AxisDirection.left,
        ),
      );
    } else if (mounted && sshProvider.errorMessage != null) {
      setState(() {
        _connectionError = 'Erro de conexão: ${sshProvider.errorMessage}';
      });
    }
  }

  /// Clear saved credentials
  Future<void> _handleForgetCredentials() async {
    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    await sshProvider.clearSavedCredentials();
    
    setState(() {
      _rememberCredentials = false;
      _hostController.clear();
      _portController.text = '22';
      _usernameController.clear();
      _passwordController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais removidas com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const SshLoadingIndicator(
                message: 'Carregando credenciais...',
              )
            : ResponsiveContainer(
                child: SlideInAnimation(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // Error display
                if (_connectionError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _connectionError = null;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Logo section
                const Icon(
                  FontAwesomeIcons.terminal,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  'EasySSH',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conecte-se ao seu servidor SSH',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Host/IP field
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'Host/IP',
                    hintText: 'exemplo.com ou 192.168.1.100',
                    prefixIcon: Icon(Icons.dns),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateHost,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Port field
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                    hintText: '22',
                    prefixIcon: Icon(Icons.router),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: _validatePort,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    hintText: 'seu_usuario',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: '••••••••••••',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleConnect(),
                ),
                const SizedBox(height: 16),

                // Remember credentials checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberCredentials,
                      onChanged: (value) {
                        setState(() {
                          _rememberCredentials = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lembrar credenciais',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    // Forget credentials button (show only if has saved credentials)
                    Consumer<SshProvider>(
                      builder: (context, sshProvider, child) {
                        if (sshProvider.currentCredentials != null) {
                          return TextButton.icon(
                            onPressed: _handleForgetCredentials,
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Esquecer'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Connect button
                Consumer<SshProvider>(
                  builder: (context, sshProvider, child) {
                    return FilledButton(
                      onPressed: sshProvider.isConnecting ? null : _handleConnect,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: sshProvider.isConnecting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Conectando...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.plug),
                                SizedBox(width: 8),
                                Text('CONECTAR'),
                              ],
                            ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Status/Error display
                Consumer<SshProvider>(
                  builder: (context, sshProvider, child) {
                    if (sshProvider.errorMessage != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sshProvider.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: sshProvider.clearError,
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
                ),
              ),
      ),
    );
  }
}