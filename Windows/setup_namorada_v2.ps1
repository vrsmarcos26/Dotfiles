<#
.SYNOPSIS
    Script de Setup "Kit Namorada V2" - Gamer Leigo & Visual Clean
    Autor: Adaptado por Gemini para vrsmarcos26
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
# 📝 LISTAS DE APLICATIVOS ATUALIZADA
# ==============================================================================

$AppsGeral = @(
    "Brave.Brave",                   # Navegador Principal
    "RARLab.WinRAR",                 # Compactador (Pedido)
    "TranslucentTB.TranslucentTB"    # Barra transparente (Pedido)
)

$AppsGames = @(
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Discord.Discord"
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

# Instalação do Office 2024 (Mantida do anterior)
function Instalar-Office {
    Write-Host "`n>>> Preparando Microsoft Office 2024..." -ForegroundColor Cyan
    $OfficeDir = "C:\OfficeTemp"
    $ToolUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19426-20170.exe"
    
    if (!(Test-Path $OfficeDir)) { New-Item -ItemType Directory -Force -Path $OfficeDir | Out-Null }
    
    # Baixa e executa se ainda não tiver o setup
    try { 
        Invoke-WebRequest -Uri $ToolUrl -OutFile "$OfficeDir\tool.exe" 
        Start-Process -FilePath "$OfficeDir\tool.exe" -ArgumentList "/quiet /extract:$OfficeDir" -Wait
    } catch { Write-Host "Erro ao baixar Office." -ForegroundColor Red; return }

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
Instalar-Lista "GAMES & COMUNICACAO" $AppsGames
Instalar-Lista "MULTIMIDIA" $AppsMedia
Instalar-Office

# ==============================================================================
# 🛡️ PROTEÇÃO DO SISTEMA & BACKUP (Igual ao seu)
# ==============================================================================
Write-Host "`n>>> Configurando Protecao do Sistema..." -ForegroundColor Magenta

# Habilita a proteção do sistema no drive C:
Enable-ComputerRestore -Drive "C:\"
# Cria um ponto de restauração inicial
Checkpoint-Computer -Description "Setup Inicial Namorada" -RestorePointType "MODIFY_SETTINGS"

# Cria tarefa agendada para Update Semanal
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 8pm
$Action = New-ScheduledTaskAction -Execute "winget" -Argument "upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --silent"
Register-ScheduledTask -TaskName "AutoUpdateSemanal" -Trigger $Trigger -Action $Action -User "System" -RunLevel Highest -Force | Out-Null
Write-Host "Tarefa de Update Automatico criada!" -ForegroundColor Green

# ==============================================================================
# 🎨 VISUAL "DARK PURPLE" & EXPLORER
# ==============================================================================
Write-Host "`n>>> Aplicando Ajustes Visuais..." -ForegroundColor Magenta

# 1. TEMA DARK PURPLE (Glow)
# O tema "Dark Purple" das configurações é o arquivo "Glow.theme"
$ThemePath = "C:\Windows\Resources\Themes\glow.theme"
if (Test-Path $ThemePath) {
    Write-Host "Aplicando tema Dark Purple (Glow)..."
    Start-Process -FilePath $ThemePath -Wait
    Start-Sleep -s 3 # Espera aplicar
}

# 2. MODO ESCURO (Garantia)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# 3. EXPLORER (Opostos: Mostra Extensões e Ocultos, Esconde Ícones Desktop)
# Mostrar Extensões
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
# Mostrar Arquivos Ocultos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
# OCULTAR Ícones da Área de Trabalho (Desktop Clean)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1

# 4. BARRA DE TAREFAS (Auto Hide)
Write-Host "Configurando Barra de Tarefas (Auto-Hide)..."
$p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$v = (Get-ItemProperty -Path $p).Settings
$v[8] = 3 # 3 = Auto Hide, 2 = Sempre visível
Set-ItemProperty -Path $p -Name "Settings" -Value $v

# Reinicia Explorer para aplicar
Stop-Process -Name explorer -Force
Start-Sleep -s 2

# ==============================================================================
# 🔑 ATIVAÇÃO & VERIFICAÇÃO (MAS)
# ==============================================================================
Write-Host "`n========================================================"
Write-Host " 🚀 STATUS DE ATIVACAO (WINDOWS & OFFICE)"
Write-Host "========================================================"
Write-Host "Vou abrir o menu de ativacao agora."
Write-Host "1. Verifique o status com a opcao [5]"
Write-Host "2. Se precisar ativar, use [1] para Windows ou [2] para Office."
Write-Host "3. Quando terminar, feche a janela preta para encerrar o script."
Write-Host "========================================================"
Read-Host "Pressione Enter para abrir o menu de ativacao..."

# Executa o comando MAS (Microsoft Activation Scripts) interativamente
powershell.exe -Command "irm https://get.activated.win | iex"

Write-Host "`n✅ SETUP CONCLUIDO!" -ForegroundColor Green
Read-Host "Pressione Enter para sair..."
