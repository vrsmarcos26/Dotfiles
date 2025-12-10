<#
.SYNOPSIS
    Script de Setup Automático - Perfil CyberSec & Dev
    Autor: vrsmarcos26
    
.DESCRIPTION
    Instala softwares divididos por categorias e configura o Windows.
    Para adicionar apps, basta editar as listas no início do script.
#>

# ==============================================================================
# 🔠 CORREÇÃO DE TEXTO (UTF-8)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
# 🔍 PRÉ-REQUISITOS (Verificação do Winget)
# ==============================================================================
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO CRITICO: O 'Winget' nao foi encontrado." -ForegroundColor Red
    Write-Host "Por favor, instale o 'App Installer' na Microsoft Store."
    Read-Host "Pressione Enter para sair..."
    Exit
}

# ==============================================================================
# 📝 LISTAS DE APLICATIVOS (Adicione novos IDs aqui)
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
    "Docker.DockerDesktop"          # Containers
)

$AppsLazer = @(
    "Valve.Steam",                  # Loja de Jogos
    "EpicGames.EpicGamesLauncher",  # Loja de Jogos
    "Spotify.Spotify",              # Música
    "Discord.Discord"               # Comunicação
)

# ==============================================================================
# ⚙️ LÓGICA DE INSTALAÇÃO
# ==============================================================================

function Instalar-Lista ($NomeLista, $ArrayApps) {
    Write-Host "`n>>> Iniciando categoria: $NomeLista..." -ForegroundColor Cyan
    foreach ($AppID in $ArrayApps) {
        Write-Host "Instalando $AppID..." -ForegroundColor Yellow
        # Tenta instalar ou atualizar se já existir
        winget install --id $AppID -e --accept-source-agreements --accept-package-agreements --silent
    }
}

# Verificação de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

# Executando as Instalações (REMOVIDOS EMOJIS E ACENTOS PARA EVITAR BUGS)
Instalar-Lista "SEGURANCA" $AppsSecurity
Instalar-Lista "DESENVOLVIMENTO" $AppsDev
Instalar-Lista "LAZER" $AppsLazer

# ==============================================================================
# 🛠️ CONFIGURAÇÕES DO WINDOWS
# ==============================================================================
Write-Host "`n>>> Aplicando configuracoes do Windows..." -ForegroundColor Magenta

# Exibir extensões de arquivos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Exibir arquivos ocultos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Reinicia o Explorer
Write-Host "Reiniciando Explorer para aplicar mudancas..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -s 2

Write-Host "`nSETUP DE APPS CONCLUIDO!" -ForegroundColor Green
Write-Host "Nota: O Docker e o Android Studio podem exigir logoff."

Write-Host "Atualizando programas pre-existentes..." -ForegroundColor Blue
winget upgrade --all --include-unknown --accept-source-agreements --silent

# ==============================================================================
# 🔄 CONFIGURAÇÃO DE UPDATE AUTOMÁTICO
# ==============================================================================
Write-Host "`n>>> Configurando atualizacao automatica semanal..." -ForegroundColor Magenta

$DestinoScripts = "C:\Scripts"
$ArquivoOrigem = "$PSScriptRoot\auto_update.bat"
$ArquivoDestino = "$DestinoScripts\auto_update.bat"

if (Test-Path $ArquivoOrigem) {
    if (!(Test-Path -Path $DestinoScripts)) { 
        New-Item -ItemType Directory -Force -Path $DestinoScripts | Out-Null 
    }

    Copy-Item -Path $ArquivoOrigem -Destination $ArquivoDestino -Force

    $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 9pm
    $Action = New-ScheduledTaskAction -Execute $ArquivoDestino
    
    Register-ScheduledTask -TaskName "AutoUpdateSemanal" -Trigger $Trigger -Action $Action -Description "Atualiza softwares via Winget" -User "System" -RunLevel Highest -Force | Out-Null
    
    Write-Host "Tarefa 'AutoUpdateSemanal' criada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Arquivo 'auto_update.bat' nao encontrado. Pulei esta etapa." -ForegroundColor Red
}

Read-Host "Pressione Enter para sair..."