<#
.SYNOPSIS
    Script de Setup "Kit Namorada V3" - Gamer Leigo & Visual Clean + DNS Seguro
    Autor: Adaptado por Gemini para vrsmarcos26
    
.DESCRIPTION
    - Apps: Steam, Epic, WinRAR, TranslucentTB, WhatsApp, Brave, Spotify...
    - Visual: Tema Roxo (Glow), Barra Transparente e Oculta, Sem ícones no desktop.
    - Rede: DNS Quad9 com DoH (Criptografado) e Fallback ativado.
    - Manutenção: Update automático e Ponto de Restauração.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
# 🔍 VERIFICAÇÃO DE ADMIN
# ==============================================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "⚠️ POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

# ==============================================================================
# 📝 LISTAS DE APLICATIVOS (WhatsApp Adicionado)
# ==============================================================================

$AppsGeral = @(
    "Brave.Brave",                   # Navegador Principal
    "RARLab.WinRAR",                 # Compactador
    "TranslucentTB.TranslucentTB"    # Barra transparente
)

$AppsSocial = @(
    "WhatsApp.WhatsApp",
    "Discord.Discord"
)

$AppsGames = @(
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher"
)

$AppsMedia = @(
    "Spotify.Spotify"
)

# ==============================================================================
# ⚙️ INSTALAÇÃO DE APPS
# ==============================================================================

function Instalar-Lista ($NomeLista, $ArrayApps) {
    Write-Host "`n>>> Instalando categoria: $NomeLista..." -ForegroundColor Cyan
    foreach ($AppID in $ArrayApps) {
        Write-Host "Instalando $AppID..." -ForegroundColor Yellow
        winget install --id $AppID -e --accept-source-agreements --accept-package-agreements --silent
    }
}

# Instalação do Office 2024
function Instalar-Office {
    Write-Host "`n>>> Preparando Microsoft Office 2024..." -ForegroundColor Cyan
    $OfficeDir = "C:\OfficeTemp"
    $ToolUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19426-20170.exe"
    
    if (!(Test-Path $OfficeDir)) { New-Item -ItemType Directory -Force -Path $OfficeDir | Out-Null }
    
    try { 
        Invoke-WebRequest -Uri $ToolUrl -OutFile "$OfficeDir\tool.exe" 
        Start-Process -FilePath "$OfficeDir\tool.exe" -ArgumentList "/quiet /extract:$OfficeDir" -Wait
    } catch { Write-Host "Erro ao baixar Office." -ForegroundColor Red; return }

    # Configuração XML
    $XmlContent = @"
<Configuration ID="9a05e267-2fa9-4ce8-9ea3-edf4ff84f3ec">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2024">
    <Product ID="ProPlus2024Volume" PIDKEY="XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB">
      <Language ID="pt-br" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="OneNote" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
    Set-Content -Path "$OfficeDir\config.xml" -Value $XmlContent
    
    Write-Host "Instalando Office..." -ForegroundColor Yellow
    Start-Process -FilePath "$OfficeDir\setup.exe" -ArgumentList "/configure config.xml" -WorkingDirectory $OfficeDir -Wait
    Remove-Item -Path $OfficeDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Executa Instalações
Instalar-Lista "GERAL & UTILITARIOS" $AppsGeral
Instalar-Lista "SOCIAL & COMUNICACAO" $AppsSocial
Instalar-Lista "GAMES" $AppsGames
Instalar-Lista "MULTIMIDIA" $AppsMedia
Instalar-Office

# ==============================================================================
# 🛡️ PROTEÇÃO DE REDE: DNS QUAD9 + DoH (HTTPS)
# ==============================================================================
Write-Host "`n>>> Configurando DNS Seguro (Quad9 + DoH)..." -ForegroundColor Magenta

# Definições
$DNS_Primario = "9.9.9.9"
$DNS_Secundario = "149.112.112.112"
$Template_DoH = "https://dns.quad9.net/dns-query"

# 1. Configura o "Template Automático" (DoH) no Windows para esses IPs
# O parâmetro -AllowFallbackToUdp $true garante a configuração "Fall-back to plaintext"
Write-Host "Registrando templates de criptografia (DoH)..." -ForegroundColor Yellow
try {
    Add-DnsClientDohServerAddress -ServerAddress $DNS_Primario -DohTemplate $Template_DoH -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction SilentlyContinue
    Add-DnsClientDohServerAddress -ServerAddress $DNS_Secundario -DohTemplate $Template_DoH -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction SilentlyContinue
} catch {
    Write-Host "Aviso: Nao foi possivel registrar o DoH (Talvez seu Windows nao suporte ou ja exista)." -ForegroundColor Gray
}

# 2. Aplica os IPs nas placas de rede ativas
$Adaptadores = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($Nic in $Adaptadores) {
    Write-Host "Aplicando DNS em: $($Nic.Name)" -ForegroundColor Yellow
    try {
        Set-DnsClientServerAddress -InterfaceIndex $Nic.InterfaceIndex -ServerAddresses ($DNS_Primario, $DNS_Secundario) -ErrorAction Stop
    } catch {
        Write-Host "Erro ao configurar adaptador $($Nic.Name)." -ForegroundColor Red
    }
}
Write-Host "Cache DNS limpo."
Clear-DnsClientCache

# ==============================================================================
# 🛡️ PROTEÇÃO DO SISTEMA & BACKUP
# ==============================================================================
Write-Host "`n>>> Configurando Protecao e Updates..." -ForegroundColor Magenta

# Ponto de Restauração
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Setup Completo Namorada" -RestorePointType "MODIFY_SETTINGS"

# Tarefa de Update Semanal
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 8pm
$Action = New-ScheduledTaskAction -Execute "winget" -Argument "upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --silent"
Register-ScheduledTask -TaskName "AutoUpdateSemanal" -Trigger $Trigger -Action $Action -User "System" -RunLevel Highest -Force | Out-Null

# ==============================================================================
# 🎨 VISUAL "DARK PURPLE" & EXPLORER
# ==============================================================================
Write-Host "`n>>> Aplicando Ajustes Visuais..." -ForegroundColor Magenta

# 1. TEMA DARK PURPLE (Glow)
$ThemePath = "C:\Windows\Resources\Themes\glow.theme"
if (Test-Path $ThemePath) {
    Write-Host "Aplicando tema Glow (Dark Purple)..."
    Start-Process -FilePath $ThemePath -Wait
    Start-Sleep -s 3 
}

# 2. MODO ESCURO
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# 3. EXPLORER (Mostra extensões, oculta ícones do desktop)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1

# 4. BARRA DE TAREFAS (Auto Hide)
$p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$v = (Get-ItemProperty -Path $p).Settings
$v[8] = 3 # Auto Hide
Set-ItemProperty -Path $p -Name "Settings" -Value $v

# Reinicia Explorer
Stop-Process -Name explorer -Force
Start-Sleep -s 2

# ==============================================================================
# 🔑 ATIVAÇÃO (MAS)
# ==============================================================================
Write-Host "`n========================================================"
Write-Host " 🚀 STATUS DE ATIVACAO"
Write-Host "========================================================"
Write-Host "Abrindo Menu MAS..."
Write-Host "Use [1] para ativar Windows ou [2] para Office."
Write-Host "Use [5] para verificar status."
Write-Host "========================================================"
Write-Host ">>> LEMBRE-SE DE INSTALAR O BIT-DEFENDER FREE MANUALMENTE <<<" -ForegroundColor Magenta
Read-Host "Pressione Enter para continuar..."

powershell.exe -Command "irm https://get.activated.win | iex"

Write-Host "`n✅ SETUP CONCLUIDO!" -ForegroundColor Green
Read-Host "Pressione Enter para sair..."
