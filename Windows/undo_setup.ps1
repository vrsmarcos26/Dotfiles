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
    "RARLab.WinRAR",                
    "Arduino.IDE",
    "Oracle.VirtualBox",
    "VMware.WorkstationPro"
)

$AppsLazer = @(
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Spotify.Spotify",
    "Discord.Discord",
    "WhirlwindFX.SignalRgb",
    "RamenSoftware.Windhawk"
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
Write-Host "1. Desinstalar TODOS os programas listados (incluindo Office 2024)."
Write-Host "2. Excluir a tarefa agendada 'AutoUpdateSemanal'."
Write-Host "3. Reverter configuracoes de visualizacao e tema para o padrao (Claro)."
Write-Host "4. Resetar DNS para DHCP (Automatico)."
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

# ==============================================================================
# 2. REMOÇÃO DE CUSTOMIZAÇÕES (GLASS)
# ==============================================================================
Write-Host "`n>>> Removendo Efeito Glass (Glass)..." -ForegroundColor Cyan
$MicaPath = "C:\Glass"
$DllFile = "$MicaPath\ExplorerBlurMica.dll"

if (Test-Path $DllFile) {
    Write-Host "Desregistrando DLL..."
    Start-Process "regsvr32.exe" -ArgumentList "/u /s `"$DllFile`"" -Wait
    Start-Sleep -s 1
    
    # É preciso matar o explorer para soltar o arquivo e deletar
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -s 2
    
    Remove-Item -Path $MicaPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Arquivos do Mica removidos." -ForegroundColor Green
    
    # Reinicia explorer se foi morto
    if (!(Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer }
}

# ==============================================================================
# 🗑️ DESINSTALAÇÃO OFFICE
# ==============================================================================

function Desinstalar-Office {
    Write-Host "`n>>> Removendo Microsoft Office 2024..." -ForegroundColor Magenta
    
    $OfficeDir = "C:\OfficeTempRemove"
    $ToolUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19426-20170.exe"
    
    $ToolFile = "$OfficeDir\officedeploymenttool.exe"
    $ConfigFile = "$OfficeDir\remove.xml"
    $RealSetupFile = "$OfficeDir\setup.exe"

    if (!(Test-Path $OfficeDir)) { New-Item -ItemType Directory -Force -Path $OfficeDir | Out-Null }

    try{
        # Baixa o Extrator
        Write-Host "Baixando ferramenta de remocao..."
        Invoke-WebRequest -Uri $ToolUrl -OutFile $ToolFile

        # Extrai o setup.exe
        Write-Host "Extraindo arquivos..."
        Start-Process -FilePath $ToolFile -ArgumentList "/quiet /extract:$OfficeDir" -Wait

        if (!(Test-Path $RealSetupFile)) {
            Write-Host "ERRO: Falha ao extrair setup.exe para remocao." -ForegroundColor Red
            return
        }

        # Cria XML de Remoção
        $XmlContent = @"
<Configuration>
<Remove All="TRUE" />
<Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
        Set-Content -Path $ConfigFile -Value $XmlContent

        Write-Host "Executando desinstalacao do Office..."
        Start-Process -FilePath $RealSetupFile -ArgumentList "/configure remove.xml" -WorkingDirectory $OfficeDir -Wait

        # Limpeza
        Remove-Item -Path $OfficeDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Office removido." -ForegroundColor Green
    } catch{
        Write-Host "Erro ao tentar remover o Office automaticamente." -ForegroundColor Red
    }
}

Desinstalar-Lista "SEGURANCA" $AppsSecurity
Desinstalar-Lista "DESENVOLVIMENTO" $AppsDev
Desinstalar-Lista "LAZER" $AppsLazer
Desinstalar-Office

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

# 2.1 --- REVERSÃO DE REDE (DNS) ---
Write-Host "Resetando DNS para DHCP..." -ForegroundColor Yellow
$Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
if ($Adapters) {
    foreach ($Adapter in $Adapters) {
        Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex -ResetServerAddresses
    }
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
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1

# Reset da Barra de Tarefas (Tenta remover o Auto-Hide forçado deletando a chave de cache)
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -ErrorAction SilentlyContinue

# Reinicia o Explorer
Write-Host "Reiniciando Explorer para aplicar mudancas..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -s 2

Write-Host "`nROLLBACK CONCLUIDO. O sistema voltou ao estado original (na medida do possivel)." -ForegroundColor Red
Write-Host "Nota: Alguns programas podem ter deixado pastas de configuracao em %AppData%."
Read-Host "Pressione Enter para sair..."
