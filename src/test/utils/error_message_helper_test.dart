import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ssh_mob_new/utils/error_message_helper.dart';
import 'package:easy_ssh_mob_new/providers/ssh_provider.dart';
import 'package:easy_ssh_mob_new/l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// Mock class for AppLocalizations
class MockAppLocalizations extends Mock implements AppLocalizations {}

// Mock class for SshProvider
class MockSshProvider extends Mock implements SshProvider {}

void main() {
  group('ErrorMessageHelper Tests', () {
    late MockAppLocalizations mockL10n;
    late MockSshProvider mockProvider;

    setUp(() {
      mockL10n = MockAppLocalizations();
      mockProvider = MockSshProvider();
    });

    test('should return localized message for ErrorMessageCode', () {
      // Setup mock behavior
      when(mockL10n.notConnectedToSshServer)
          .thenReturn('Não conectado ao servidor SSH');

      // Test the helper
      final result = ErrorMessageHelper.getLocalizedErrorMessage(
        mockL10n,
        ErrorMessageCode.notConnectedToSshServer,
      );

      expect(result, 'Não conectado ao servidor SSH');
      verify(mockL10n.notConnectedToSshServer).called(1);
    });

    test('should return provider error message when errorCode is null', () {
      // Setup mock behavior
      when(mockProvider.errorCode).thenReturn(null);
      when(mockProvider.errorMessage).thenReturn('Custom error message');

      // Test the helper
      final result =
          ErrorMessageHelper.getProviderErrorMessage(mockL10n, mockProvider);

      expect(result, 'Custom error message');
      verify(mockProvider.errorCode).called(1);
      verify(mockProvider.errorMessage).called(1);
    });

    test('should return localized message when errorCode is present', () {
      // Setup mock behavior
      when(mockProvider.errorCode)
          .thenReturn(ErrorMessageCode.notConnectedToSshServer);
      when(mockProvider.errorDetails).thenReturn(null);
      when(mockL10n.notConnectedToSshServer)
          .thenReturn('Não conectado ao servidor SSH');

      // Test the helper
      final result =
          ErrorMessageHelper.getProviderErrorMessage(mockL10n, mockProvider);

      expect(result, 'Não conectado ao servidor SSH');
      verify(mockProvider.errorCode).called(1);
      verify(mockProvider.errorDetails).called(1);
      verify(mockL10n.notConnectedToSshServer).called(1);
    });

    test('should handle basic ErrorMessageCode enum values', () {
      // Test some basic enum values that don't require parameters
      final basicEnumValues = [
        ErrorMessageCode.notConnectedToSshServer,
        ErrorMessageCode.errorListingDirectory,
        ErrorMessageCode.checkPermissionsAndConnection,
        ErrorMessageCode.permissionDeniedDirectory,
        ErrorMessageCode.directoryNotFound,
        ErrorMessageCode.notADirectory,
        ErrorMessageCode.directoryTimeout,
        ErrorMessageCode.commandTimeout,
        ErrorMessageCode.commandTimeoutSuggestion,
        ErrorMessageCode.sshConnectionError,
        ErrorMessageCode.errorSsh,
        ErrorMessageCode.commandExecutionError,
        ErrorMessageCode.connectionRefused,
        ErrorMessageCode.hostUnreachable,
        ErrorMessageCode.authenticationFailed,
        ErrorMessageCode.connectionTimeout,
        ErrorMessageCode.keyExchangeFailed,
        ErrorMessageCode.hostKeyVerificationFailed,
        ErrorMessageCode.networkError,
      ];

      // Setup basic mock behavior for required methods
      when(mockL10n.notConnectedToSshServer).thenReturn('Mock message');
      when(mockL10n.errorListingDirectory).thenReturn('Mock message');
      when(mockL10n.checkPermissionsAndConnection).thenReturn('Mock message');
      when(mockL10n.permissionDeniedDirectory).thenReturn('Mock message');
      when(mockL10n.directoryNotFound).thenReturn('Mock message');
      when(mockL10n.notADirectory).thenReturn('Mock message');
      when(mockL10n.directoryTimeout).thenReturn('Mock message');
      when(mockL10n.commandTimeout).thenReturn('Mock message');
      when(mockL10n.commandTimeoutSuggestion).thenReturn('Mock message');
      when(mockL10n.sshConnectionError).thenReturn('Mock message');
      when(mockL10n.errorSsh).thenReturn('Mock message');
      when(mockL10n.commandExecutionError).thenReturn('Mock message');
      when(mockL10n.connectionRefused).thenReturn('Mock message');
      when(mockL10n.hostUnreachable).thenReturn('Mock message');
      when(mockL10n.authenticationFailed).thenReturn('Mock message');
      when(mockL10n.connectionTimeout).thenReturn('Mock message');
      when(mockL10n.keyExchangeFailed).thenReturn('Mock message');
      when(mockL10n.hostKeyVerificationFailed).thenReturn('Mock message');
      when(mockL10n.networkError).thenReturn('Mock message');

      for (final enumValue in basicEnumValues) {
        expect(() {
          ErrorMessageHelper.getLocalizedErrorMessage(mockL10n, enumValue);
        }, returnsNormally, reason: 'Enum value $enumValue should be handled');
      }
    });
  });
}
