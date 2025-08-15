import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// Service to facilitate access to localizations throughout the app
class LocalizationService {
  /// Get the current AppLocalizations instance
  static AppLocalizations of(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      throw Exception(
          'AppLocalizations not found! Make sure MaterialApp is configured with localization delegates.');
    }
    return localizations;
  }

  /// Check if a specific locale is supported
  static bool isLocaleSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          (supportedLocale.countryCode == null ||
              supportedLocale.countryCode == locale.countryCode),
    );
  }

  /// Get the list of supported locales
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Get the current locale from context
  static Locale? getCurrentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }
}
