# Correções Aplicadas nos Testes Widget

## Problemas Identificados e Corrigidos

### 1. LogEntry Constructor
**Problema**: Testes usavam constructor simplificado
**Correção**: Adicionados todos os campos obrigatórios:
- `id: String`
- `workingDirectory: String` 
- `stdout: String` (era `output`)
- `stderr: String`
- `duration: Duration`

### 2. CommandType Enum Values
**Problema**: Enums não coincidiam com o modelo real
**Correções**:
- `CommandType.viewing` → `CommandType.fileView`
- `CommandType.operation` → `CommandType.execution`

### 3. SshProvider Method Names  
**Problema**: Método incorreto sendo chamado
**Correção**: `getFileContent()` → `readFile()`

### 4. Connect Method Signature
**Problema**: Testes usavam parâmetros posicionais
**Correção**: Atualizado para usar named parameters:
```dart
connect(
  host: 'host',
  port: 22, 
  username: 'user',
  password: 'pass',
  saveCredentials: true,
)
```

### 5. Dependencies
**Problema**: Mockito não estava no pubspec.yaml
**Correção**: Adicionado `mockito: ^5.4.4` em dev_dependencies

### 6. Mock Files
**Problema**: Arquivos .mocks.dart não existiam
**Correção**: Criados mocks básicos para compilação

## Próximos Passos

1. Execute na pasta `src/`:
```bash
flutter packages pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter test --coverage --reporter=expanded
```

2. Ou use o script:
```bash
./scripts/run_tests.sh
```

## Arquivos Modificados

- `test/widget/file_viewer_screen_test.dart`
- `test/widget/login_screen_test.dart`
- `test/widget/session_log_screen_test.dart`
- `src/pubspec.yaml`
- Criados: `test/widget/*.mocks.dart`
- Criado: `scripts/run_tests.sh`