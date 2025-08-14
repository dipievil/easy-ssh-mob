# Manual Test Guide: "Lembrar Credenciais" Functionality

## Overview
Este guia fornece instruções para testar manualmente a funcionalidade de salvar credenciais no aplicativo EasySSH.

## Prerequisites
1. Flutter app está construído e rodando no dispositivo/emulador
2. App foi lançado recentemente (sem credenciais salvas existentes)

## Test Case 1: Primeiro Salvamento de Credenciais
### Passos:
1. Abrir o app
2. Preencher o formulário de conexão:
   - Host/IP: test.example.com
   - Port: 22
   - Username: testuser
   - Password: testpass123
3. MARCAR o checkbox "Lembrar credenciais"
4. Tocar no botão "CONECTAR"
5. Nota: A conexão provavelmente falhará (sem servidor real), mas isso é OK

### Resultados Esperados:
- App deve mostrar mensagem "Conectado com sucesso! Credenciais salvas." SE a conexão for bem-sucedida
- OU mostrar erro de conexão mas ainda salvar as credenciais
- Logs de debug devem mostrar o processo de salvamento das credenciais

## Test Case 2: Verificar se Credenciais Foram Salvas
### Passos:
1. Fechar o app completamente
2. Reabrir o app
3. Observar o formulário de login quando carregar

### Resultados Esperados:
- Campos do formulário devem ser automaticamente preenchidos com valores salvos:
  - Host/IP: test.example.com
  - Port: 22
  - Username: testuser
  - Password: testpass123
- Checkbox "Lembrar credenciais" deve estar marcado
- Logs de debug devem mostrar processo de carregamento das credenciais

## Test Case 3: Conectar Sem Salvar (Checkbox Desmarcado)
### Passos:
1. Limpar os campos do formulário ou modificá-los:
   - Host/IP: another.server.com
   - Username: otheruser
   - Password: otherpass
2. DESMARCAR o checkbox "Lembrar credenciais"
3. Tocar no botão "CONECTAR"

### Resultados Esperados:
- Credenciais originais salvas devem permanecer inalteradas
- Nenhuma nova credencial deve ser salva
- Logs de debug devem mostrar saveCredentials=false

## Test Case 4: Esquecer Credenciais
### Passos:
1. Se há credenciais salvas, deve haver um botão "Esquecer"
2. Tocar no botão "Esquecer"

### Resultados Esperados:
- Todos os campos do formulário devem ser limpos
- Checkbox "Lembrar credenciais" deve ser desmarcado
- Mensagem "Credenciais removidas com sucesso" deve aparecer
- Logs de debug devem mostrar remoção das credenciais

## Test Case 5: Reiniciar Após Esquecer
### Passos:
1. Fechar e reabrir o app
2. Observar o formulário de login

### Resultados Esperados:
- Todos os campos do formulário devem estar vazios (exceto port = "22")
- Checkbox "Lembrar credenciais" deve estar desmarcado
- Nenhuma credencial salva deve ser carregada

## Informações de Debug a Procurar

No console/debug output, procurar por essas mensagens:

### Ao Salvar Credenciais:
- "Attempting to save credentials for host: [hostname]"
- "Credentials JSON encoded successfully"
- "Credentials written to secure storage successfully"
- "Credentials saved and verified successfully"

### Ao Carregar Credenciais:
- "Attempting to load credentials from secure storage"
- "Credentials JSON found, attempting to decode"
- "Credentials loaded successfully for host: [hostname]"
- "Saved credentials loaded and applied to form fields"

### Quando Não Existem Credenciais:
- "No credentials found in secure storage"
- "No valid saved credentials found"

### Possíveis Mensagens de Erro:
- "Error saving credentials: [detalhes do erro]"
- "Error loading credentials: [detalhes do erro]"
- "Invalid credentials data - validation failed"

## Solução de Problemas Comuns

1. **Credenciais não salvam**: Verificar logs de debug para falhas de salvamento
2. **Credenciais não carregam**: Verificar timing - pode precisar aguardar um momento após inicialização do app
3. **Formulário não popula**: Verificar se credenciais salvas são válidas
4. **Comportamento do checkbox**: Garantir que mudanças de estado são refletidas nos logs de debug

## Casos de Teste Avançados

### Teste de Caracteres Especiais:
- Tentar salvar credenciais com caracteres especiais: !@#$%^&*()
- Caracteres Unicode: café, señor, etc.

### Teste de Valores Longos:
- Tentar hostnames, usernames, passwords muito longos
- Verificar se salvam e carregam corretamente

### Valores de Porta Limite:
- Tentar porta 1 (mínimo válido)
- Tentar porta 65535 (máximo válido)
- Tentar porta 0 (deve ser inválido)
- Tentar porta 70000 (deve ser inválido)

### Casos Extremos:
- Campos vazios com checkbox marcado (não deve salvar devido a validação)
- Espaços em branco nos campos (deve falhar na validação)
- Dados malformados