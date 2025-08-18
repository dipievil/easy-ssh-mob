// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'EasySSH';

  @override
  String get settings => 'Configurações';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsSubtitle => 'Configurar alertas e sons';

  @override
  String get sessionLog => 'Log da Sessão';

  @override
  String get sessionLogSubtitle => 'Ver histórico de comandos';

  @override
  String get aboutApp => 'Sobre o App';

  @override
  String get aboutAppSubtitle => 'Informações da versão';

  @override
  String get clearCredentials => 'Limpar Credenciais';

  @override
  String get clearCredentialsSubtitle => 'Esquecer dados de login salvos';

  @override
  String get logout => 'Logout';

  @override
  String get currentConnection => 'Conexão Atual';

  @override
  String get host => 'Host';

  @override
  String get port => 'Porta';

  @override
  String get user => 'Usuário';

  @override
  String get status => 'Status';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get notificationSettings => 'Configurações de Notificação';

  @override
  String get notificationTypes => 'Tipos de Notificação';

  @override
  String get info => 'Info';

  @override
  String get infoDescription => 'Informações gerais';

  @override
  String get success => 'Sucesso';

  @override
  String get successDescription => 'Operações bem-sucedidas';

  @override
  String get warning => 'Aviso';

  @override
  String get warningDescription => 'Situações que requerem atenção';

  @override
  String get error => 'Erro';

  @override
  String get errorDescription => 'Problemas durante operações';

  @override
  String get critical => 'Crítico';

  @override
  String get criticalDescription => 'Falhas graves do sistema';

  @override
  String get close => 'Fechar';

  @override
  String get testMessageInfo => 'Esta é uma notificação informativa';

  @override
  String get testMessageSuccess => 'Operação realizada com sucesso!';

  @override
  String get testMessageWarning => 'Atenção: isto é um aviso';

  @override
  String get testMessageError => 'Ocorreu um erro na operação';

  @override
  String get testMessageCritical => 'CRÍTICO: Falha grave do sistema';
}
