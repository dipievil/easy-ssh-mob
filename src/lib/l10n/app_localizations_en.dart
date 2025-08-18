// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasySSH';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Configure alerts and sounds';

  @override
  String get sessionLog => 'Session Log';

  @override
  String get sessionLogSubtitle => 'View command history';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutAppSubtitle => 'Version information';

  @override
  String get clearCredentials => 'Clear Credentials';

  @override
  String get clearCredentialsSubtitle => 'Forget saved login data';

  @override
  String get logout => 'Logout';

  @override
  String get currentConnection => 'Current Connection';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get user => 'User';

  @override
  String get status => 'Status';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get info => 'Info';

  @override
  String get infoDescription => 'General information';

  @override
  String get success => 'Success';

  @override
  String get successDescription => 'Successful operations';

  @override
  String get warning => 'Warning';

  @override
  String get warningDescription => 'Situations requiring attention';

  @override
  String get error => 'Error';

  @override
  String get errorDescription => 'Problems during operations';

  @override
  String get critical => 'Critical';

  @override
  String get criticalDescription => 'Serious system failures';

  @override
  String get close => 'Close';

  @override
  String get testMessageInfo => 'This is an informative notification';

  @override
  String get testMessageSuccess => 'Operation completed successfully!';

  @override
  String get testMessageWarning => 'Warning: this is an alert';

  @override
  String get testMessageError => 'An error occurred during operation';

  @override
  String get testMessageCritical => 'CRITICAL: Serious system failure';
}
