#!/usr/bin/env powershell

Write-Host "🔍 Testando o Botão do Drawer..." -ForegroundColor Cyan

# Navegar para o diretório do projeto
cd "c:\Users\dipi\source\repos\easy-ssh-mob\src"

Write-Host "📱 Iniciando aplicativo Flutter..." -ForegroundColor Yellow

# Tentar diferentes plataformas
$platforms = @("chrome", "windows", "android")

foreach ($platform in $platforms) {
    Write-Host "🎯 Tentando executar em $platform..." -ForegroundColor Green
    
    # Verificar se a plataforma está disponível
    $devices = flutter devices
    if ($devices -match $platform) {
        Write-Host "✅ $platform disponível!" -ForegroundColor Green
        
        # Executar no modo debug
        Write-Host "▶️ Executando: flutter run -d $platform" -ForegroundColor Cyan
        flutter run -d $platform
        break
    } else {
        Write-Host "❌ $platform não disponível" -ForegroundColor Red
    }
}

Write-Host "🧪 TESTE DO BOTÃO:" -ForegroundColor Magenta
Write-Host "1. Faça login SSH" -ForegroundColor White
Write-Host "2. Toque no botão ⚙️ (gear/settings icon) na AppBar" -ForegroundColor White
Write-Host "3. O drawer lateral deve abrir da direita" -ForegroundColor White
Write-Host "4. Deve mostrar comandos SSH organizados por categoria" -ForegroundColor White
