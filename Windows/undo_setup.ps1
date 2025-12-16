<#
.SYNOPSIS
    Script de Rollback (Desinstalacao e Limpeza)
    Autor: vrsmarcos26
    
.DESCRIPTION
    PERIGO: Este script remove todos os softwares instalados pelo setup,
    apaga a tarefa agendada de update e reverte configuracoes do Windows.
#>

# ==============================================================================
# 🔠 CORREÇÃO DE TEXTO (UTF-8)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
# 📝 LISTAS DE APLICATIVOS PARA REMOVER (As mesmas do setup)
# ==============================================================================

$AppsSecurity = @(
    "Brave.Brave",
    "Proton.ProtonVPN",
    "Bitwarden.Bitwarden",
    "Malwarebytes.Malwarebytes",
    "Filen.Filen" 
)

$AppsDev = @(
    "Microsoft.VisualStudioCode",
    "Python.Python.3.12",
    "Git.Git",
    "Google.AndroidStudio",
    "Docker.DockerDesktop",
    "ArduinoSA.IDE.stable"
)

$AppsLazer = @(
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Spotify.Spotify",
    "Discord.Discord"
)

# ==============================================================================
# ⚠️ VERIFICAÇÃO DE SEGURANÇA
# ==============================================================================

# Verificação de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

Clear-Host
Write-Host "================================================================" -ForegroundColor Red
Write-Host "                   MODO DE DESTRUICAO (ROLLBACK)                " -ForegroundColor Red
Write-Host "================================================================" -ForegroundColor Red
Write-Host "Este script ira:"
Write-Host "1. Desinstalar TODOS os programas listados no script de setup."
Write-Host "2. Excluir a tarefa agendada 'AutoUpdateSemanal'."
Write-Host "3. Apagar a pasta C:\Scripts permanentemente."
Write-Host "4. Reverter configuracoes de visualizacao e tema para o padrao (Claro)."
Write-Host ""
$Confirmacao = Read-Host "Tem certeza absoluta que deseja continuar? Digite 'DESTRUIR' para confirmar"

if ($Confirmacao -ne "DESTRUIR") {
    Write-Host "Operacao cancelada com seguranca." -ForegroundColor Green
    Exit
}

# ==============================================================================
# 🗑️ LÓGICA DE DESINSTALAÇÃO
# ==============================================================================

function Desinstalar-Lista ($NomeLista, $ArrayApps) {
    Write-Host "`n>>> Removendo categoria: $NomeLista..." -ForegroundColor Magenta
    foreach ($AppID in $ArrayApps) {
        Write-Host "Tentando desinstalar $AppID..." -ForegroundColor Yellow
        # Tenta desinstalar silenciosamente
        winget uninstall --id $AppID --silent --accept-source-agreements
    }
}

Desinstalar-Lista "SEGURANCA" $AppsSecurity
Desinstalar-Lista "DESENVOLVIMENTO" $AppsDev
Desinstalar-Lista "LAZER" $AppsLazer

# ==============================================================================
# 🧹 LIMPEZA DO SISTEMA
# ==============================================================================

Write-Host "`n>>> Limpando automacoes e arquivos..." -ForegroundColor Cyan

# 1. Remove a Tarefa Agendada
Write-Host "Removendo tarefa agendada..."
Unregister-ScheduledTask -TaskName "AutoUpdateSemanal" -Confirm:$false -ErrorAction SilentlyContinue

# 2. Remove a pasta de Scripts
if (Test-Path "C:\Scripts") {
    Write-Host "Apagando C:\Scripts..."
    Remove-Item -Path "C:\Scripts" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Reverte Configurações do Windows (Padrão de Fábrica)
Write-Host "Revertendo configuracoes do Explorer e Tema..."

# Reverter para Extensões Ocultas (Padrão)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1
# Reverter para Arquivos Ocultos não visíveis (Padrão)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 2
# Mostrar ícones na área de trabalho (Padrão)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 0

# Reverter Tema para Claro (Padrão)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1

# Reverter Barra de Tarefas (Padrão)
# Mostrar Pesquisa (Caixa de Pesquisa = 2 no Win10, ou 1 no Win11 padrão depende da build)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
# Mostrar Widgets (Se existir)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1
# Alinhamento da Barra de Tarefas (Centro = 1 é padrão no 11, mas se quiser voltar pra Esquerda use 0)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1
# Fixar Barra de Tarefas (Não ocultar auto)
# Nota: O valor binário original é complexo, removemos a chave 'Settings' do StuckRects3 para resetar ou editamos apenas o bit.
# Para simplificar o rollback, vamos tentar forçar o comportamento padrão via script não binário se possível, ou ignorar se não crítico.

# Reinicia o Explorer
Write-Host "Reiniciando Explorer para aplicar mudancas..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -s 2

Write-Host "`nROLLBACK CONCLUIDO. O sistema voltou ao estado original (na medida do possivel)." -ForegroundColor Red
Write-Host "Nota: Alguns programas podem ter deixado pastas de configuracao em %AppData%."
Read-Host "Pressione Enter para sair..."