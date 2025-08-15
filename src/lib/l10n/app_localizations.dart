import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

/// Callers can lookup localized strings with Localizations.of<AppLocalizations>(context)!
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = locale;

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
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'EasySSH'**
  String get appTitle;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'SSH Connection'**
  String get loginTitle;

  /// Server host label
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// Server port label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Username label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Connect button text
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Remember credentials checkbox label
  ///
  /// In en, this message translates to:
  /// **'Remember credentials'**
  String get rememberCredentials;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Current connection section title
  ///
  /// In en, this message translates to:
  /// **'Current Connection'**
  String get currentConnection;

  /// Disconnect button text
  ///
  /// In en, this message translates to:
  /// **'Disconnect from server'**
  String get disconnectFromServer;

  /// Session log menu item
  ///
  /// In en, this message translates to:
  /// **'Session Log'**
  String get sessionLog;

  /// Notification settings menu item
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save as menu text
  ///
  /// In en, this message translates to:
  /// **'Save as'**
  String get saveAs;

  /// Save as TXT option
  ///
  /// In en, this message translates to:
  /// **'Save as TXT'**
  String get saveAsTxt;

  /// Save as JSON option
  ///
  /// In en, this message translates to:
  /// **'Save as JSON'**
  String get saveAsJson;

  /// Save as CSV option
  ///
  /// In en, this message translates to:
  /// **'Save as CSV'**
  String get saveAsCsv;

  /// File explorer screen title
  ///
  /// In en, this message translates to:
  /// **'File Explorer'**
  String get fileExplorer;

  /// Terminal screen title
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// Generic notification text
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Info notification type
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Success notification type
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning notification type
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Error notification type
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Critical notification type
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// Connecting status text
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Connected status text
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status text
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Retry action button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Please wait message
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure alerts and sounds'**
  String get configureAlertsAndSounds;

  /// Session log subtitle
  ///
  /// In en, this message translates to:
  /// **'View command history'**
  String get viewCommandHistory;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// About app subtitle
  ///
  /// In en, this message translates to:
  /// **'Version information'**
  String get versionInfo;

  /// Clear credentials menu item
  ///
  /// In en, this message translates to:
  /// **'Clear Credentials'**
  String get clearCredentials;

  /// Clear credentials subtitle
  ///
  /// In en, this message translates to:
  /// **'Forget saved login data'**
  String get forgetSavedLoginData;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Clear credentials confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to forget all saved credentials? You will need to enter login data again.'**
  String get clearCredentialsConfirm;

  /// Success message after clearing credentials
  ///
  /// In en, this message translates to:
  /// **'Credentials removed successfully'**
  String get credentialsRemovedSuccessfully;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Do you want to disconnect from the SSH server? You will return to the login screen.'**
  String get logoutConfirm;

  /// App description in about dialog
  ///
  /// In en, this message translates to:
  /// **'Simple and intuitive SSH client for mobile devices.'**
  String get sshClientDescription;

  /// Flutter development credit
  ///
  /// In en, this message translates to:
  /// **'Developed with Flutter 💙'**
  String get developedWithFlutter;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Connect to your SSH server'**
  String get connectToYourSshServer;

  /// Host validation message
  ///
  /// In en, this message translates to:
  /// **'Host/IP is required'**
  String get hostIpRequired;

  /// Port validation message
  ///
  /// In en, this message translates to:
  /// **'Port is required'**
  String get portRequired;

  /// Port number validation message
  ///
  /// In en, this message translates to:
  /// **'Port must be a number'**
  String get portMustBeNumber;

  /// Port range validation message
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1 and 65535'**
  String get portRange;

  /// Username validation message
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Success connection message
  ///
  /// In en, this message translates to:
  /// **'Connected successfully! Credentials saved.'**
  String get connectedSuccessfully;

  /// Host field hint text
  ///
  /// In en, this message translates to:
  /// **'example.com or 192.168.1.100'**
  String get hostIpHint;

  /// Username field hint text
  ///
  /// In en, this message translates to:
  /// **'your_username'**
  String get userHint;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'••••••••••••'**
  String get passwordHint;

  /// Forget credentials button
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// Alert sounds setting
  ///
  /// In en, this message translates to:
  /// **'Alert Sounds'**
  String get alertSounds;

  /// Alert sounds subtitle
  ///
  /// In en, this message translates to:
  /// **'Play sounds for notifications'**
  String get playSoundsForNotifications;

  /// Sound volume setting
  ///
  /// In en, this message translates to:
  /// **'Sound Volume'**
  String get soundVolume;

  /// Vibration setting
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Vibration subtitle
  ///
  /// In en, this message translates to:
  /// **'Vibrate for notifications'**
  String get vibrateForNotifications;

  /// Test notifications section
  ///
  /// In en, this message translates to:
  /// **'Test Notifications'**
  String get testNotifications;

  /// Test notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Test different notification types'**
  String get testDifferentNotificationTypes;

  /// Sound settings section title
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get soundSettings;
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
      'an issue with the localizations generation tool. Please file an issue on GitHub with a '
      'reproducible example and the gen-l10n configuration.');
}
