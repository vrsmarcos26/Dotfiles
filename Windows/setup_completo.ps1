<#
.SYNOPSIS
    Script de Setup Automático - Perfil CyberSec & Dev
    Autor: vrsmarcos26
    
.DESCRIPTION
    Instala softwares divididos por categorias e configura o Windows.
    Para adicionar apps, basta editar as listas no início do script.
#>

# ==============================================================================
# 📝 LISTAS DE APLICATIVOS (Adicione novos IDs aqui)
# Para achar o ID de um programa, abra o terminal e digite: winget search "NomeDoPrograma"
# ==============================================================================

$AppsSecurity = @(
    "Brave.Brave",                  # Navegador Seguro
    "Proton.ProtonVPN",             # VPN
    "Bitwarden.Bitwarden",          # Gerenciador de Senhas
    "Malwarebytes.Malwarebytes",    # Scanner de Segunda Opinião
    "Filen.Filen"                   # Backup automatico
)

$AppsDev = @(
    "Microsoft.VisualStudioCode",   # Editor de Código
    "Python.Python.3.12",           # Python (Versão estável)
    "Git.Git",                      # Controle de Versão
    "Google.AndroidStudio",         # Dev Android
    "Docker.DockerDesktop"         # Containers
)

$AppsLazer = @(
    "Valve.Steam",                  # Loja de Jogos
    "EpicGames.EpicGamesLauncher",  # Loja de Jogos
    "Spotify.Spotify",              # Música
    "Discord.Discord"               # Comunicação (Geralmente essencial para gamers/devs)
)

# ==============================================================================
# ⚙️ LÓGICA DE INSTALAÇÃO (Não precisa mexer aqui)
# ==============================================================================

function Instalar-Lista ($NomeLista, $ArrayApps) {
    Write-Host "`n🚀 Iniciando categoria: $NomeLista..." -ForegroundColor Cyan
    foreach ($AppID in $ArrayApps) {
        Write-Host "Instalando $AppID..." -ForegroundColor Yellow
        # O comando tenta instalar. Se já tiver, ele avisa ou atualiza.
        winget install --id $AppID -e --accept-source-agreements --accept-package-agreements --silent
    }
}

# Verificação de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️  POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

# 🔍 Verificação de Pré-requisitos (Winget)
Write-Host "🔍 Verificando se o Winget está instalado..." -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO CRÍTICO: O 'Winget' não foi encontrado neste sistema." -ForegroundColor Red
    Write-Host "O Windows Sandbox ou versões desatualizadas do Windows não possuem o Winget nativo."
    Write-Host "Por favor, instale o 'App Installer' na Microsoft Store ou atualize o Windows."
    Read-Host "Pressione Enter para sair..."
    Exit
} else {
    Write-Host "✅ Winget detectado com sucesso!" -ForegroundColor Green
}

# Executando as Instalações
Instalar-Lista "🔒 SEGURANÇA" $AppsSecurity
Instalar-Lista "💻 DESENVOLVIMENTO" $AppsDev
Instalar-Lista "🎮 LAZER" $AppsLazer

## ==============================================================================
# 🛠️ CONFIGURAÇÕES EXTRAS DO WINDOWS (Hardening)
# ==============================================================================
Write-Host "`n🔧 Aplicando configurações do Windows..." -ForegroundColor Magenta

# 1. Configura o Registro
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 # EXTENÇÕES
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 # OCULTAR

# 2. Reinicia o Explorer para aplicar as mudanças IMEDIATAMENTE
Write-Host "🔄 Reiniciando o Explorer para aplicar mudanças visuais..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -s 2 # Dá um tempo para o Explorer voltar

Write-Host "`n✅ SETUP CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "Nota: O Docker e o Android Studio podem exigir logoff ou reinicialização."

Write-Host "🔄 Atualizando programas pré-existentes..." -ForegroundColor Blue
winget upgrade --all --include-unknown --accept-source-agreements --silent

# ==============================================================================
# 🔄 CONFIGURAÇÃO DE UPDATE AUTOMÁTICO (Agendador de Tarefas)
# ==============================================================================
Write-Host "`n⏳ Configurando atualização automática semanal..." -ForegroundColor Magenta

# Define o caminho de destino seguro no Disco C:
$DestinoScripts = "C:\Scripts"
$ArquivoOrigem = "$PSScriptRoot\auto_update.bat" # Pega o arquivo da mesma pasta do script atual
$ArquivoDestino = "$DestinoScripts\auto_update.bat"

# Verifica se o arquivo .bat existe na pasta atual antes de copiar
if (Test-Path $ArquivoOrigem) {
    # Cria a pasta C:\Scripts se não existir
    if (!(Test-Path -Path $DestinoScripts)) { 
        New-Item -ItemType Directory -Force -Path $DestinoScripts | Out-Null 
    }

    # Copia o arquivo .bat para o C:\Scripts
    Copy-Item -Path $ArquivoOrigem -Destination $ArquivoDestino -Force

    # Cria a tarefa agendada apontando para o C:\Scripts
    $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 9pm
    $Action = New-ScheduledTaskAction -Execute $ArquivoDestino
    
    # Registra a tarefa (substitui se já existir)
    Register-ScheduledTask -TaskName "AutoUpdateSemanal" -Trigger $Trigger -Action $Action -Description "Atualiza softwares via Winget" -User "System" -RunLevel Highest -Force | Out-Null
    
    Write-Host "✅ Tarefa 'AutoUpdateSemanal' criada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Arquivo 'auto_update.bat' não encontrado na pasta atual. Pulei esta etapa." -ForegroundColor Red
}

Read-Host "Pressione Enter para sair..."