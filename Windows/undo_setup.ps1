<#
.SYNOPSIS
    Script de Rollback (Desinstalação e Limpeza)
    Autor: vrsmarcos26
    
.DESCRIPTION
    ⚠️ PERIGO: Este script remove todos os softwares instalados pelo setup,
    apaga a tarefa agendada de update e reverte configurações do Windows.
#>

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
    "Docker.DockerDesktop"
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
    Write-Host "⚠️  POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

Clear-Host
Write-Host "================================================================" -ForegroundColor Red
Write-Host "                   ⚠️  MODO DE DESTRUIÇÃO  ⚠️" -ForegroundColor Red
Write-Host "================================================================" -ForegroundColor Red
Write-Host "Este script irá:"
Write-Host "1. Desinstalar TODOS os programas listados no script de setup."
Write-Host "2. Excluir a tarefa agendada 'AutoUpdateSemanal'."
Write-Host "3. Apagar a pasta C:\Scripts permanentemente."
Write-Host "4. Reverter configurações de visualização de arquivos para o padrão."
Write-Host ""
$Confirmacao = Read-Host "Tem certeza absoluta que deseja continuar? Digite 'DESTRUIR' para confirmar"

if ($Confirmacao -ne "DESTRUIR") {
    Write-Host "Operação cancelada com segurança." -ForegroundColor Green
    Exit
}

# ==============================================================================
# 🗑️ LÓGICA DE DESINSTALAÇÃO
# ==============================================================================

function Desinstalar-Lista ($NomeLista, $ArrayApps) {
    Write-Host "`n🗑️ Removendo categoria: $NomeLista..." -ForegroundColor Magenta
    foreach ($AppID in $ArrayApps) {
        Write-Host "Tentando desinstalar $AppID..." -ForegroundColor Yellow
        # Tenta desinstalar silenciosamente
        winget uninstall --id $AppID --silent --accept-source-agreements
    }
}

Desinstalar-Lista "🔒 SEGURANÇA" $AppsSecurity
Desinstalar-Lista "💻 DESENVOLVIMENTO" $AppsDev
Desinstalar-Lista "🎮 LAZER" $AppsLazer

# ==============================================================================
# 🧹 LIMPEZA DO SISTEMA
# ==============================================================================

Write-Host "`n🧹 Limpando automações e arquivos..." -ForegroundColor Cyan

# 1. Remove a Tarefa Agendada
Write-Host "Removendo tarefa agendada..."
Unregister-ScheduledTask -TaskName "AutoUpdateSemanal" -Confirm:$false -ErrorAction SilentlyContinue

# 2. Remove a pasta de Scripts
if (Test-Path "C:\Scripts") {
    Write-Host "Apagando C:\Scripts..."
    Remove-Item -Path "C:\Scripts" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Reverte Configurações do Windows (Padrão de Fábrica)
Write-Host "Revertendo configurações do Explorer..."

# Ocultar extensões de arquivos (Padrão do Windows é 1 = Escondido)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1

# Ocultar arquivos ocultos (Padrão do Windows é 2 = Não mostrar)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 2

Write-Host "`n💀 ROLLBACK CONCLUÍDO. O sistema voltou ao estado original (na medida do possível)." -ForegroundColor Red
Write-Host "Nota: Alguns programas podem ter deixado pastas de configuração em %AppData%."
Read-Host "Pressione Enter para sair..."