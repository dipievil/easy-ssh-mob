/// Error types for SSH operations
enum ErrorType {
  permissionDenied,
  fileNotFound,
  operationNotPermitted,
  accessDenied,
  connectionLost,
  timeout,
  commandNotFound,
  diskFull,
  unknown
}

/// Error severity levels
enum ErrorSeverity { info, warning, error, critical }

/// SSH error representation with user-friendly messages
class SshError {
  final ErrorType type;
  final String originalMessage;
  final String userFriendlyMessage;
  final String? suggestion;
  final ErrorSeverity severity;
  
  const SshError({
    required this.type,
    required this.originalMessage,
    required this.userFriendlyMessage,
    this.suggestion,
    required this.severity,
  });
}

/// Service for analyzing and handling SSH errors
class ErrorHandler {
  /// Pattern matching for common SSH errors
  static final Map<RegExp, ErrorType> _errorPatterns = {
    RegExp(r'Permission denied', caseSensitive: false): ErrorType.permissionDenied,
    RegExp(r'No such file or directory', caseSensitive: false): ErrorType.fileNotFound,
    RegExp(r'Operation not permitted', caseSensitive: false): ErrorType.operationNotPermitted,
    RegExp(r'Access denied', caseSensitive: false): ErrorType.accessDenied,
    RegExp(r'Connection.*(lost|closed|refused)', caseSensitive: false): ErrorType.connectionLost,
    RegExp(r'Timeout|timed out', caseSensitive: false): ErrorType.timeout,
    RegExp(r'command not found', caseSensitive: false): ErrorType.commandNotFound,
    RegExp(r'No space left on device', caseSensitive: false): ErrorType.diskFull,
  };
  
  /// Analyze stderr output and return structured error information
  static SshError analyzeError(String stderr, String command) {
    for (var pattern in _errorPatterns.entries) {
      if (pattern.key.hasMatch(stderr)) {
        return _createErrorFromType(pattern.value, stderr, command);
      }
    }
    
    return SshError(
      type: ErrorType.unknown,
      originalMessage: stderr,
      userFriendlyMessage: 'Erro desconhecido ao executar comando',
      severity: ErrorSeverity.error,
    );
  }
  
  /// Create structured error based on type
  static SshError _createErrorFromType(ErrorType type, String stderr, String command) {
    switch (type) {
      case ErrorType.permissionDenied:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Sem permissão para executar esta ação',
          suggestion: 'Verifique se tem permissões de acesso ao ficheiro/diretório',
          severity: ErrorSeverity.warning,
        );
        
      case ErrorType.fileNotFound:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Ficheiro ou diretório não encontrado',
          suggestion: 'Verifique se o caminho está correto',
          severity: ErrorSeverity.warning,
        );
        
      case ErrorType.operationNotPermitted:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Operação não permitida pelo sistema',
          suggestion: 'Contacte o administrador do sistema',
          severity: ErrorSeverity.error,
        );
        
      case ErrorType.accessDenied:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Acesso negado ao recurso',
          suggestion: 'Verifique suas credenciais e permissões',
          severity: ErrorSeverity.warning,
        );
        
      case ErrorType.connectionLost:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Conexão SSH perdida',
          suggestion: 'Verifique a conexão de rede',
          severity: ErrorSeverity.critical,
        );
        
      case ErrorType.timeout:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Comando demorou muito tempo',
          suggestion: 'Tente novamente ou use um comando mais simples',
          severity: ErrorSeverity.warning,
        );
        
      case ErrorType.commandNotFound:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Comando não encontrado no sistema',
          suggestion: 'Verifique se o comando está instalado no servidor',
          severity: ErrorSeverity.error,
        );
        
      case ErrorType.diskFull:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Sem espaço disponível no disco',
          suggestion: 'Liberte espaço no servidor ou contacte o administrador',
          severity: ErrorSeverity.critical,
        );
        
      case ErrorType.unknown:
        return SshError(
          type: type,
          originalMessage: stderr,
          userFriendlyMessage: 'Erro desconhecido',
          suggestion: 'Consulte os detalhes técnicos para mais informação',
          severity: ErrorSeverity.error,
        );
    }
  }
}