import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'EasySSH'**
  String get appTitle;

  /// Settings menu title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Subtitle for notifications settings
  ///
  /// In en, this message translates to:
  /// **'Configure alerts and sounds'**
  String get notificationsSubtitle;

  /// Session log menu item
  ///
  /// In en, this message translates to:
  /// **'Session Log'**
  String get sessionLog;

  /// Subtitle for session log
  ///
  /// In en, this message translates to:
  /// **'View command history'**
  String get sessionLogSubtitle;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Subtitle for about app
  ///
  /// In en, this message translates to:
  /// **'Version information'**
  String get aboutAppSubtitle;

  /// Clear credentials menu item
  ///
  /// In en, this message translates to:
  /// **'Clear Credentials'**
  String get clearCredentials;

  /// Subtitle for clear credentials
  ///
  /// In en, this message translates to:
  /// **'Forget saved login data'**
  String get clearCredentialsSubtitle;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Current connection section title
  ///
  /// In en, this message translates to:
  /// **'Current Connection'**
  String get currentConnection;

  /// Host field label
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// Port field label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// User field label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Status field label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Notification settings screen title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Notification types section title
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// Info notification type
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Description for info notifications
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get infoDescription;

  /// Success notification type
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Description for success notifications
  ///
  /// In en, this message translates to:
  /// **'Successful operations'**
  String get successDescription;

  /// Warning notification type
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Description for warning notifications
  ///
  /// In en, this message translates to:
  /// **'Situations requiring attention'**
  String get warningDescription;

  /// Error notification type
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Description for error notifications
  ///
  /// In en, this message translates to:
  /// **'Problems during operations'**
  String get errorDescription;

  /// Critical notification type
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Description for critical notifications
  ///
  /// In en, this message translates to:
  /// **'Serious system failures'**
  String get criticalDescription;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Test info notification message
  ///
  /// In en, this message translates to:
  /// **'This is an informative notification'**
  String get testMessageInfo;

  /// Test success notification message
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully!'**
  String get testMessageSuccess;

  /// Test warning notification message
  ///
  /// In en, this message translates to:
  /// **'Warning: this is an alert'**
  String get testMessageWarning;

  /// Test error notification message
  ///
  /// In en, this message translates to:
  /// **'An error occurred during operation'**
  String get testMessageError;

  /// Test critical notification message
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Serious system failure'**
  String get testMessageCritical;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
