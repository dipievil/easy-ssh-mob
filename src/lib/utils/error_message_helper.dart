import '../l10n/app_localizations.dart';
import '../providers/ssh_provider.dart';

/// Helper class to convert error codes to localized messages
class ErrorMessageHelper {
  /// Convert ErrorMessageCode to localized string
  static String getLocalizedErrorMessage(
      AppLocalizations l10n, ErrorMessageCode code,
      {String? details}) {
    switch (code) {
      case ErrorMessageCode.notConnectedToSshServer:
        return l10n.notConnectedToSshServer;
      case ErrorMessageCode.errorListingDirectory:
        return l10n.errorListingDirectory;
      case ErrorMessageCode.checkPermissionsAndConnection:
        return l10n.checkPermissionsAndConnection;
      case ErrorMessageCode.directoryNotAccessible:
        return details != null
            ? l10n.directoryNotAccessible(details)
            : l10n.directoryNotAccessible('');
      case ErrorMessageCode.permissionDeniedDirectory:
        return l10n.permissionDeniedDirectory;
      case ErrorMessageCode.directoryNotFound:
        return l10n.directoryNotFound;
      case ErrorMessageCode.notADirectory:
        return l10n.notADirectory;
      case ErrorMessageCode.directoryTimeout:
        return l10n.directoryTimeout;
      case ErrorMessageCode.errorAccessingDirectory:
        return details != null
            ? l10n.errorAccessingDirectory(details)
            : l10n.errorAccessingDirectory('');
      case ErrorMessageCode.executionError:
        return details != null
            ? l10n.executionError(details)
            : l10n.executionError('');
      case ErrorMessageCode.commandTimeout:
        return l10n.commandTimeout;
      case ErrorMessageCode.commandTimeoutSuggestion:
        return l10n.commandTimeoutSuggestion;
      case ErrorMessageCode.sshConnectionError:
        return l10n.sshConnectionError;
      case ErrorMessageCode.errorSsh:
        return l10n.errorSsh;
      case ErrorMessageCode.commandExecutionError:
        return l10n.commandExecutionError;
      case ErrorMessageCode.connectionRefused:
        return l10n.connectionRefused;
      case ErrorMessageCode.hostUnreachable:
        return l10n.hostUnreachable;
      case ErrorMessageCode.authenticationFailed:
        return l10n.authenticationFailed;
      case ErrorMessageCode.connectionTimeout:
        return l10n.connectionTimeout;
      case ErrorMessageCode.keyExchangeFailed:
        return l10n.keyExchangeFailed;
      case ErrorMessageCode.hostKeyVerificationFailed:
        return l10n.hostKeyVerificationFailed;
      case ErrorMessageCode.networkError:
        return l10n.networkError;
      case ErrorMessageCode.connectionErrorGeneric:
        return details != null
            ? l10n.connectionErrorGeneric(details)
            : l10n.connectionErrorGeneric('');
    }
  }

  /// Get localized error message from SshProvider
  static String? getProviderErrorMessage(
    AppLocalizations l10n,
    SshProvider provider,
  ) {
    if (provider.errorCode != null) {
      return getLocalizedErrorMessage(
        l10n,
        provider.errorCode!,
        details: provider.errorDetails,
      );
    }
    return provider.errorMessage;
  }
}
