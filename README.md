# EasySSH - Mobile SSH File Manager

<div align="center">

**Uma aplicação multiplataforma (Android e iOS) para gerenciamento de arquivos SSH com interface intuitiva baseada em botões.**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev/docs/deployment)

</div>

## 📱 Sobre o Projeto

EasySSH é um gerenciador de arquivos SSH mobile que simplifica a conexão e navegação em servidores remotos através de uma interface gráfica intuitiva. O aplicativo foi desenvolvido para usuários que precisam acessar e gerenciar arquivos em servidores SSH de forma prática e visual, sem depender exclusivamente da linha de comando.

### ✨ Funcionalidades Principais

- 🔐 **Conexão SSH Segura** - Conecte-se a servidores SSH com autenticação segura
- 📁 **Explorador de Arquivos** - Navegue pelo sistema de arquivos com interface gráfica
- 📄 **Visualizador de Arquivos** - Visualize conteúdo de arquivos de texto diretamente no app
- ⚡ **Execução de Scripts** - Execute scripts e comandos com interface simplificada
- 🔍 **Busca de Texto** - Encontre conteúdo específico dentro dos arquivos
- 📋 **Copiar Conteúdo** - Copie texto dos arquivos para área de transferência
- 🎨 **Interface Intuitiva** - Design baseado em botões para facilitar o uso
- 🔒 **Armazenamento Seguro** - Credenciais salvas com segurança no dispositivo
- 🌙 **Tema Escuro/Claro** - Suporte a temas para melhor experiência visual
- 🔊 **Feedback Sonoro** - Sons de interação para melhor UX

## 🛠️ Stack Tecnológico

### **Frontend**
- **Flutter** - Framework multiplataforma
- **Dart** `>=2.19.0 <4.0.0` - Linguagem de programação

### **Dependências Principais**
- **dartssh2** `^2.9.0` - Cliente SSH para Dart
- **provider** `^6.0.5` - Gerenciamento de estado
- **flutter_secure_storage** `^9.0.0` - Armazenamento seguro
- **font_awesome_flutter** `^10.6.0` - Ícones
- **audioplayers** `^5.2.1` - Reprodução de sons

### **Ferramentas de Desenvolvimento**
- **mockito** `^5.4.2` - Mocks para testes
- **flutter_lints** `^2.0.0` - Linting
- **build_runner** `^2.4.6` - Geração de código

## 🚀 Instalação e Configuração

### Pré-requisitos

- Flutter SDK (consulte [documentação oficial](https://flutter.dev/docs/get-started/install))
- Dart SDK `>=2.19.0`
- Android Studio / VS Code
- Git

### Clone e Configuração

```bash
# Clone o repositório
git clone https://github.com/dipievil/easy-ssh-mob.git

# Entre no diretório
cd easy-ssh-mob

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

### Configuração para Android

```bash
# Verifique a configuração
flutter doctor

# Build para Android
flutter build apk --release
```

### Configuração para iOS

```bash
# Abra o projeto iOS
open ios/Runner.xcworkspace

# Build para iOS
flutter build ios --release
```

## 📖 Como Usar

### 1. **Primeira Conexão**
   - Abra o aplicativo
   - Insira os dados do servidor SSH (host, porta, usuário, senha)
   - Toque em "Conectar"

### 2. **Navegação de Arquivos**
   - Use a interface de botões para navegar entre diretórios
   - Toque em pastas para abri-las
   - Toque em arquivos para visualizar ou executar

### 3. **Visualização de Arquivos**
   - Arquivos de texto são abertos automaticamente no visualizador
   - Use a função de busca (🔍) para encontrar conteúdo específico
   - Copie texto selecionado com o botão de cópia (📋)

### 4. **Execução de Scripts**
   - Arquivos executáveis mostram opção de executar ou visualizar
   - Confirme a execução quando solicitado
   - Veja o resultado em tempo real

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Entrada da aplicação
├── models/                      # Modelos de dados
├── providers/                   # Gerenciamento de estado (Provider)
├── screens/                     # Telas da aplicação
│   ├── login_screen.dart        # Tela de login SSH
│   ├── file_explorer_screen.dart # Explorador de arquivos
│   ├── file_viewer_screen.dart  # Visualizador de arquivos
│   ├── terminal_screen.dart     # Terminal SSH
│   └── ...
├── services/                    # Serviços (SSH, storage, etc.)
├── widgets/                     # Widgets customizados
├── themes/                      # Temas da aplicação
└── utils/                       # Utilitários e helpers

test/                           # Testes unitários e de widgets
integration_test/               # Testes de integração
assets/                         # Recursos estáticos
demo_files/                     # Arquivos de demonstração
docs/                          # Documentação adicional
scripts/                       # Scripts utilitários
```

## 🧪 Testes

### Executar Testes Unitários
```bash
flutter test
```

### Executar Testes de Integração
```bash
flutter test integration_test/
```

### Executar Análise de Código
```bash
flutter analyze
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie sua branch de feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adicionar nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### Padrões de Commit
- `feat:` nova funcionalidade
- `fix:` correção de bug
- `docs:` alterações na documentação
- `style:` formatação de código
- `refactor:` refatoração
- `test:` adição de testes
- `chore:` tarefas de manutenção

## 📄 Licença

Este projeto está sob a licença Apache 2.0. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Contato e Suporte

- **GitHub**: [dipievil/easy-ssh-mob](https://github.com/dipievil/easy-ssh-mob)
- **Issues**: [Reportar Bug ou Sugerir Feature](https://github.com/dipievil/easy-ssh-mob/issues)

## 📚 Documentação Adicional

- [Arquivos de Demonstração](demo_files/README.md)
- [Documentação de Issues](docs/issues/README.md)
- [Guia de Testes](test/README.md)

---

<div align="center">

**Desenvolvido com ❤️ usando Flutter**

⭐ **Se este projeto foi útil para você, considere dar uma estrela!**

</div>
