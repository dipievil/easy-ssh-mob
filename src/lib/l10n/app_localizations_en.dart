import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasySSH';

  @override
  String get loginTitle => 'SSH Connection';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get connect => 'Connect';

  @override
  String get rememberCredentials => 'Remember credentials';

  @override
  String get settings => 'Settings';

  @override
  String get currentConnection => 'Current Connection';

  @override
  String get disconnectFromServer => 'Disconnect from server';

  @override
  String get sessionLog => 'Session Log';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAs => 'Save as';

  @override
  String get saveAsTxt => 'Save as TXT';

  @override
  String get saveAsJson => 'Save as JSON';

  @override
  String get saveAsCsv => 'Save as CSV';

  @override
  String get fileExplorer => 'File Explorer';

  @override
  String get terminal => 'Terminal';

  @override
  String get notification => 'Notification';

  @override
  String get info => 'Info';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get error => 'Error';

  @override
  String get critical => 'Critical';

  @override
  String get connectionError => 'Connection error';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get notifications => 'Notifications';

  @override
  String get configureAlertsAndSounds => 'Configure alerts and sounds';

  @override
  String get viewCommandHistory => 'View command history';

  @override
  String get aboutApp => 'About App';

  @override
  String get versionInfo => 'Version information';

  @override
  String get clearCredentials => 'Clear Credentials';

  @override
  String get forgetSavedLoginData => 'Forget saved login data';

  @override
  String get logout => 'Logout';

  @override
  String get clearCredentialsConfirm =>
      'Are you sure you want to forget all saved credentials? You will need to enter login data again.';

  @override
  String get credentialsRemovedSuccessfully =>
      'Credentials removed successfully';

  @override
  String get clear => 'Clear';

  @override
  String get logoutConfirm =>
      'Do you want to disconnect from the SSH server? You will return to the login screen.';

  @override
  String get sshClientDescription =>
      'Simple and intuitive SSH client for mobile devices.';

  @override
  String get developedWithFlutter => 'Developed with Flutter 💙';

  @override
  String get connectToYourSshServer => 'Connect to your SSH server';

  @override
  String get hostIpRequired => 'Host/IP is required';

  @override
  String get portRequired => 'Port is required';

  @override
  String get portMustBeNumber => 'Port must be a number';

  @override
  String get portRange => 'Port must be between 1 and 65535';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get connectedSuccessfully =>
      'Connected successfully! Credentials saved.';

  @override
  String get hostIpHint => 'example.com or 192.168.1.100';

  @override
  String get userHint => 'your_username';

  @override
  String get passwordHint => '••••••••••••';

  @override
  String get forget => 'Forget';

  @override
  String get alertSounds => 'Alert Sounds';

  @override
  String get playSoundsForNotifications => 'Play sounds for notifications';

  @override
  String get soundVolume => 'Sound Volume';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateForNotifications => 'Vibrate for notifications';

  @override
  String get testNotifications => 'Test Notifications';

  @override
  String get testDifferentNotificationTypes =>
      'Test different notification types';

  @override
  String get soundSettings => 'Sound Settings';
}
