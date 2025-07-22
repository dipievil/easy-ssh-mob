# 🧪 Testes EasySSH

Suite completa de testes para o aplicativo EasySSH, incluindo testes unitários, de widget, integração, performance e acessibilidade.

## 🚀 Quick Start

```bash
# Instalar dependências
flutter pub get

# Gerar mocks
flutter packages pub run build_runner build

# Executar todos os testes
flutter test

# Executar com cobertura
flutter test --coverage
```

## 📊 Status dos Testes

### ✅ Implementado
- **Widget Tests**: LoginScreen, FileViewerScreen, SessionLogScreen
- **Unit Tests**: SecureStorageService, FileIconManager, SshProvider
- **Integration Tests**: Fluxo completo da aplicação
- **Performance Tests**: Listas grandes, cache, rendering
- **Accessibility Tests**: WCAG compliance, screen readers

### 📈 Métricas
- **Cobertura**: >90% funções críticas
- **Performance**: Listas de 2000+ itens suportadas
- **Acessibilidade**: WCAG AA compatível
- **CI/CD**: Automatizado com 10 jobs de verificação

## 🏗️ Estrutura

```
test/
├── widget/           # Testes de interface
├── services/         # Testes de serviços
├── models/          # Testes de modelos
├── providers/       # Testes de providers
├── performance/     # Testes de performance
└── accessibility/   # Testes de acessibilidade

integration_test/
└── app_test.dart    # Testes de integração E2E
```

## 🛠️ Tecnologias

- **Flutter Test**: Framework base
- **Mockito**: Mocks e stubs
- **Integration Test**: Testes E2E
- **Build Runner**: Geração de código
- **GitHub Actions**: CI/CD

## 📚 Documentação

Para documentação completa, veja [TESTING.md](TESTING.md)

## 🎯 Comandos Úteis

### Testes por Categoria
```bash
flutter test test/widget/        # Widget tests
flutter test test/services/      # Service tests
flutter test test/performance/   # Performance tests
flutter test integration_test/   # Integration tests
```

### Desenvolvimento
```bash
# Executar testes em watch mode
flutter test --watch

# Executar teste específico
flutter test test/widget/login_screen_test.dart

# Gerar relatório de cobertura HTML
genhtml coverage/lcov.info -o coverage/html
```

### CI/CD
```bash
# Simular pipeline localmente
flutter analyze
flutter test --coverage
flutter build apk --release
```

---

**Contribua**: Adicione novos testes seguindo os padrões estabelecidos e mantendo a cobertura alta!