# Plano de Desenvolvimento: EasySSH (Flutter)
Este documento descreve o plano de desenvolvimento para a aplicação "EasySSH", utilizando o framework Flutter.

## 1. Visão Geral do Projeto
O EasySSH será uma aplicação multiplataforma (Android e iOS) que permitirá aos utilizadores conectar-se a um servidor SSH e navegar no seu sistema de ficheiros através de uma interface de utilizador gráfica baseada em botões. A aplicação irá simplificar a execução de scripts, visualização de ficheiros e execução de comandos básicos de forma intuitiva.

## 2. Tecnologias Principais
Framework: Flutter

Linguagem: Dart

Interface Gráfica (UI): Widgets do Flutter (com Material 3)

Comunicação SSH: Pacote dartssh2, uma implementação pura em Dart, moderna e eficiente.

Gestão de Estado: Pacote provider, para uma gestão de estado simples e reativa.

Armazenamento Local: Pacote flutter_secure_storage para guardar credenciais de forma segura.

Ícones: Pacote font_awesome_flutter para uma vasta biblioteca de ícones.

IDE: VS Code ou Android Studio (ambos com as extensões oficiais do Flutter).

## 3. Fases do Desenvolvimento
Dividiremos o projeto em fases para uma abordagem incremental e organizada.

### Fase 1: Fundação e Conexão Principal
O objetivo desta fase é ter a funcionalidade básica de conexão a funcionar e a estrutura da aplicação montada.

#### [Tarefa 1.1] Configuração do Projeto:

Criar um novo projeto Flutter: flutter create easyssh.

Adicionar as dependências no ficheiro pubspec.yaml: dartssh2, provider, flutter_secure_storage, font_awesome_flutter.

#### [Tarefa 1.2] Ecrã de Conexão (Login):

Criar um Widget (ex: LoginScreen.dart) com campos de texto (TextField) para Host, Porta, Utilizador e Palavra-passe.

Adicionar um botão "Conectar" com um indicador de progresso (CircularProgressIndicator).

#### [Tarefa 1.3] Lógica de Armazenamento Seguro:

Implementar a lógica para guardar e carregar os dados de conexão (exceto a palavra-passe) usando flutter_secure_storage.

#### [Tarefa 1.4] Serviço de Conexão SSH (Provider):

Criar uma classe SshProvider com ChangeNotifier para gerir o estado da conexão (conectado, desconectado, a carregar).

Implementar as funções: connect(), disconnect(), executeCommand(command).

### Fase 2: Navegação por Diretórios
O foco aqui é implementar a principal funcionalidade da aplicação: a navegação por botões.

#### [Tarefa 2.1] Ecrã do Explorador de Ficheiros:

Criar um Widget (ex: FileExplorerScreen.dart) que será exibido após a conexão.

Usar uma AppBar para exibir o caminho do diretório atual e os botões de ação (Home, Ferramentas).

#### [Tarefa 2.2] Listar Conteúdo do Diretório:

No SshProvider, criar uma função que executa ls -F e analisa o output para criar uma lista de objetos SshFile.

Cada SshFile deve conter nome, tipo (diretório, script, etc.) e caminho completo.

#### [Tarefa 2.3] Geração Dinâmica de Botões:

Usar um ListView.builder para renderizar a lista de SshFile.

Cada item da lista será um Widget personalizado (ex: ListTile) com um ícone apropriado e a lógica de clique.

Implementar a navegação para subdiretórios e o botão "Voltar".

### Fase 3: Interação com Ficheiros e Execução
Nesta fase, damos vida aos botões.

#### [Tarefa 3.1] Execução de Scripts e Binários:

Ao clicar, chamar a função executeCommand no SshProvider.

Mostrar o output (stdout e stderr) num AlertDialog ou num novo ecrã de "Terminal".

#### [Tarefa 3.2] Visualizador de Ficheiros:

Ao clicar num ficheiro de texto/log, executar cat ou tail, obter o conteúdo e exibi-lo num novo ecrã com scroll (SingleChildScrollView).

#### [Tarefa 3.3] Tratamento de Erros de Permissão:

Analisar o stderr retornado pelo dartssh2. Se contiver "Permission denied" ou similar, mostrar um SnackBar ou AlertDialog com uma mensagem de erro clara.

### Fase 4: UI/UX e Funcionalidades Adicionais
Polimento da aplicação para uma melhor experiência.

#### [Tarefa 4.1] Botão "Home" e Menu de Ferramentas:

Adicionar um IconButton na AppBar para a ação "Home".

Implementar um Drawer para o menu de ferramentas, com botões para comandos pré-definidos.

#### [Tarefa 4.2] Sistema de Notificação de Erros:

Criar um Widget de diálogo reutilizável para exibir erros de forma consistente.

Usar o pacote audioplayers para tocar um som de alerta curto quando um erro crítico ocorrer.

#### [Tarefa 4.3] Design e Ícones:

Adotar o Material 3 (useMaterial3: true no ThemeData).

Usar os ícones do font_awesome_flutter para diferenciar visualmente os tipos de ficheiros e ações.

### Fase 5: Logging e Finalização
Funcionalidades finais e preparação para lançamento.

#### [Tarefa 5.1] Logging da Sessão:

Manter uma lista de comandos executados no SshProvider.

Criar uma opção no menu para "Salvar Log", que formata o histórico e o escreve num ficheiro na home do utilizador via SSH.

#### [Tarefa 5.2] Testes e Refinamento:

Escrever testes de widgets para os ecrãs principais.

Testar a aplicação em emuladores e dispositivos físicos (Android e iOS).

Otimizar a performance, especialmente a renderização de listas longas.
