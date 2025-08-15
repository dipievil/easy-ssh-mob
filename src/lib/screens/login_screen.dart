import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/ssh_provider.dart';
import '../services/secure_storage_service.dart';
import '../widgets/custom_components.dart';
import '../utils/custom_animations.dart';
import '../utils/responsive_breakpoints.dart';
import '../l10n/app_localizations.dart';
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
    // Use a post-frame callback to ensure widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
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

    try {
      // Try loading credentials directly from secure storage first
      // This ensures we get the most recent saved credentials
      final savedCredentials = await SecureStorageService.loadCredentials();

      if (savedCredentials != null && savedCredentials.isValid()) {
        _hostController.text = savedCredentials.host;
        _portController.text = savedCredentials.port.toString();
        _usernameController.text = savedCredentials.username;
        _passwordController.text = savedCredentials.password;
        setState(() {
          _rememberCredentials = true;
        });
        debugPrint('Saved credentials loaded and applied to form fields');
      } else {
        debugPrint('No valid saved credentials found');
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _validateHost(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.hostIpRequired;
    }
    return null;
  }

  String? _validatePort(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.portRequired;
    }

    final port = int.tryParse(value.trim());
    if (port == null) {
      return l10n.portMustBeNumber;
    }

    if (port < 1 || port > 65535) {
      return l10n.portRange;
    }

    return null;
  }

  String? _validateUsername(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.usernameRequired;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.passwordRequired;
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
      // Show success message if credentials were saved
      if (_rememberCredentials) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

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
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.credentialsRemovedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? SshLoadingIndicator(message: l10n.loading)
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
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _connectionError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
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
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.connectToYourSshServer,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 48),

                        // Host/IP field
                        TextFormField(
                          controller: _hostController,
                          decoration: InputDecoration(
                            labelText: l10n.host,
                            hintText: l10n.hostIpHint,
                            prefixIcon: const Icon(Icons.dns),
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateHost,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Port field
                        TextFormField(
                          controller: _portController,
                          decoration: InputDecoration(
                            labelText: l10n.port,
                            hintText: '22',
                            prefixIcon: const Icon(Icons.router),
                            border: const OutlineInputBorder(),
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
                          decoration: InputDecoration(
                            labelText: l10n.username,
                            hintText: l10n.userHint,
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateUsername,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            hintText: l10n.passwordHint,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                                l10n.rememberCredentials,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            // Forget credentials button (show only if has saved credentials)
                            Consumer<SshProvider>(
                              builder: (context, sshProvider, child) {
                                if (sshProvider.currentCredentials != null) {
                                  return TextButton.icon(
                                    onPressed: _handleForgetCredentials,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: Text(l10n.forget),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
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
                              onPressed: sshProvider.isConnecting
                                  ? null
                                  : _handleConnect,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: sshProvider.isConnecting
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(l10n.connecting),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(FontAwesomeIcons.plug),
                                        const SizedBox(width: 8),
                                        Text(l10n.connect.toUpperCase()),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sshProvider.errorMessage!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: sshProvider.clearError,
                                      icon: Icon(
                                        Icons.close,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
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
