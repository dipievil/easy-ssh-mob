import 'app_localizations.dart';

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'EasySSH';

  @override
  String get loginTitle => 'Conexão SSH';

  @override
  String get host => 'Host';

  @override
  String get port => 'Porta';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get connect => 'Conectar';

  @override
  String get rememberCredentials => 'Lembrar credenciais';

  @override
  String get settings => 'Configurações';

  @override
  String get currentConnection => 'Conexão Atual';

  @override
  String get disconnectFromServer => 'Desconectar do servidor';

  @override
  String get sessionLog => 'Log da Sessão';

  @override
  String get notificationSettings => 'Configurações de Notificação';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get saveAs => 'Salvar como';

  @override
  String get saveAsTxt => 'Salvar como TXT';

  @override
  String get saveAsJson => 'Salvar como JSON';

  @override
  String get saveAsCsv => 'Salvar como CSV';

  @override
  String get fileExplorer => 'Explorador de Arquivos';

  @override
  String get terminal => 'Terminal';

  @override
  String get notification => 'Notificação';

  @override
  String get info => 'Informação';

  @override
  String get success => 'Sucesso';

  @override
  String get warning => 'Aviso';

  @override
  String get error => 'Erro';

  @override
  String get critical => 'Crítico';

  @override
  String get connectionError => 'Erro de conexão';

  @override
  String get connecting => 'Conectando...';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get pleaseWait => 'Por favor, aguarde';

  @override
  String get notifications => 'Notificações';

  @override
  String get configureAlertsAndSounds => 'Configurar alertas e sons';

  @override
  String get viewCommandHistory => 'Ver histórico de comandos';

  @override
  String get aboutApp => 'Sobre o App';

  @override
  String get versionInfo => 'Informações da versão';

  @override
  String get clearCredentials => 'Limpar Credenciais';

  @override
  String get forgetSavedLoginData => 'Esquecer dados de login salvos';

  @override
  String get logout => 'Logout';

  @override
  String get clearCredentialsConfirm => 'Tem certeza de que deseja esquecer todas as credenciais salvas? Você precisará inserir os dados de login novamente.';

  @override
  String get credentialsRemovedSuccessfully => 'Credenciais removidas com sucesso';

  @override
  String get clear => 'Limpar';

  @override
  String get logoutConfirm => 'Deseja desconectar do servidor SSH? Você retornará à tela de login.';

  @override
  String get sshClientDescription => 'Cliente SSH simples e intuitivo para dispositivos móveis.';

  @override
  String get developedWithFlutter => 'Desenvolvido com Flutter 💙';

  @override
  String get connectToYourSshServer => 'Conecte-se ao seu servidor SSH';

  @override
  String get hostIpRequired => 'Host/IP é obrigatório';

  @override
  String get portRequired => 'Porta é obrigatória';

  @override
  String get portMustBeNumber => 'Porta deve ser um número';

  @override
  String get portRange => 'Porta deve estar entre 1 e 65535';

  @override
  String get usernameRequired => 'Usuário é obrigatório';

  @override
  String get passwordRequired => 'Senha é obrigatória';

  @override
  String get connectedSuccessfully => 'Conectado com sucesso! Credenciais salvas.';

  @override
  String get hostIpHint => 'exemplo.com ou 192.168.1.100';

  @override
  String get userHint => 'seu_usuario';

  @override
  String get passwordHint => '••••••••••••';

  @override
  String get forget => 'Esquecer';
}