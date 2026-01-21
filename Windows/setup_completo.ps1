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
    "Malwarebytes.Malwarebytes",    # Scanner de Segunda Opiniao
    "FilenCloud.FilenSync"          # Backup automatico
)

$AppsDev = @(
    "Microsoft.VisualStudioCode",   # Editor de Código
    "Python.Python.3.12",           # Python (Versao estavel)
    "Git.Git",                      # Controle de Versão
    "Google.AndroidStudio",         # Dev Android
    # "Docker.DockerDesktop",         Containers
    "RARLab.WinRAR",                # Compactados
    "ArduinoSA.IDE.stable",         # IDE Arduino
    "Oracle.VirtualBox",            # VirtualBox Oficial
    "VMware.WorkstationPro"
)

$AppsLazer = @(
    "Valve.Steam",                  # Loja de Jogos
    "EpicGames.EpicGamesLauncher",  # Loja de Jogos
    "9NCBCSZSJRSB",                 # Spotify (Versão Store - Funciona como Admin)
    "Discord.Discord",              # Comunicacao
    "WhirlwindFX.SignalRgb",        # Controlador RGB
    #"CharlesMilette.TranslucentTB"  # Barra de tarefas invisivel
    "RamenSoftware.Windhawk"
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

# ==============================================================================
# 📚 INSTALAR PACOTE OFFICE
# ==============================================================================
function Instalar-Office {
    Write-Host "`n>>> Iniciando instalacao do Microsoft Office 2024..." -ForegroundColor Cyan
    
    $OfficeDir = "C:\OfficeTemp"
    # Link oficial direto da Microsoft (Download Center)
    $ToolUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19426-20170.exe"
    
    $ToolFile = "$OfficeDir\officedeploymenttool.exe"
    $ConfigFile = "$OfficeDir\config.xml"
    $RealSetupFile = "$OfficeDir\setup.exe" # O arquivo que será extraído

    # 1. Cria diretório temporário
    if (!(Test-Path $OfficeDir)) { New-Item -ItemType Directory -Force -Path $OfficeDir | Out-Null }

    # 2. Baixa a Ferramenta de Implantação (O Extrator)
    Write-Host "Baixando Office Deployment Tool..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $ToolUrl -OutFile $ToolFile
    } catch {
        Write-Host "ERRO FATAL: Nao foi possivel baixar o ODT. Verifique sua internet." -ForegroundColor Red
        return
    }

    # 3. Extrai o setup.exe real da ferramenta
    Write-Host "Extraindo arquivos de instalacao..." -ForegroundColor Yellow
    # O argumento /extract:PATH /quiet extrai sem perguntar nada
    $ExtractProcess = Start-Process -FilePath $ToolFile -ArgumentList "/quiet /extract:$OfficeDir" -Wait -PassThru
    
    if (!(Test-Path $RealSetupFile)) {
        Write-Host "ERRO: Falha ao extrair o setup.exe. Verifique se o antivirus bloqueou." -ForegroundColor Red
        return
    }

    # 4. Cria o arquivo XML de configuração
    Write-Host "Gerando arquivo de configuracao XML..." -ForegroundColor Yellow
    $XmlContent = @"
<Configuration ID="9a05e267-2fa9-4ce8-9ea3-edf4ff84f3ec">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2024">
    <Product ID="ProPlus2024Volume" PIDKEY="XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB">
      <Language ID="pt-br" />
      <Language ID="en-us" />
      <Language ID="es-es" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="OneNote" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" />
    </Product>
    <Product ID="ProofingTools">
      <Language ID="en-us" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="FALSE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
    Set-Content -Path $ConfigFile -Value $XmlContent

    # 5. Executa a Instalação com o setup.exe extraído
    Write-Host "Executando instalacao do Office (Isso pode demorar)..." -ForegroundColor Yellow
    $Process = Start-Process -FilePath $RealSetupFile -ArgumentList "/configure config.xml" -WorkingDirectory $OfficeDir -Wait -PassThru

    if ($Process.ExitCode -eq 0) {
        Write-Host "Office instalado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro na instalacao do Office. Codigo: $($Process.ExitCode)" -ForegroundColor Red
    }

    # 6. Limpeza
    Write-Host "Limpando arquivos temporarios..."
    Remove-Item -Path $OfficeDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Verificação de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

# Executando as Instalações
winget source reset --force
winget source update
winget --version

Instalar-Lista "SEGURANCA" $AppsSecurity
Instalar-Lista "DESENVOLVIMENTO" $AppsDev
Instalar-Lista "LAZER" $AppsLazer

# Instalação do Office Dedicada
Instalar-Office

# ==============================================================================
# 🛠️ CONFIGURAÇÕES DO WINDOWS (Hardening & Visual)
# ==============================================================================
Write-Host "`n>>> Aplicando configuracoes do Windows..." -ForegroundColor Magenta

# --- EXPLORER & VISUALIZAÇÃO ---
Write-Host "Configurando Explorer e Area de Trabalho..."

# Exibir extensões de arquivos
Write-Host "Exibir extensoes de arquivos"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Exibir arquivos ocultos
Write-Host "Exibir arquivos ocultos"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Ocultar icones da Area de Trabalho (Desktop limpo)
Write-Host "Ocultar icones da Area de Trabalho (Desktop limpo)"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1

# --- TEMA ESCURO (DARK MODE) ---
Write-Host "Ativando Modo Escuro..."
# Modo Escuro para Apps
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
# Modo Escuro para Sistema (Barra de tarefas etc)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

# --- BARRA DE TAREFAS ---
Write-Host "Ajustando Barra de Tarefas..."

# Para o Explorer ANTES de mexer na Taskbar
Stop-Process -Name explorer -Force
Start-Sleep -Milliseconds 800

# Ocultar Pesquisa na Barra de Tarefas (0 = Oculto, 1 = Ícone, 2 = Caixa)
Write-Host " - Ocultando icone de Pesquisa..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -ErrorAction SilentlyContinue

# Ocultar Widgets
Write-Host " - Ocultando Widgets...(clima)"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -ErrorAction SilentlyContinue

# Alinhamento da Barra de Tarefas (1 = Centro, 0 = Esquerda)
Write-Host " - Centralizando Barra de Tarefas..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1

# Auto-Hide
# ATENÇÃO: Esta é a chave binária complexa. Se não funcionar, o Windows pode ignorar.
Write-Host " - Ativando Ocultar Automaticamente..."
$StuckRects3Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
if (Test-Path $StuckRects3Path) {
    # Valor Hexadecimal para forçar o Auto-Hide
    $Valores = ([byte[]](0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
    Set-ItemProperty -Path $StuckRects3Path -Name "Settings" -Value $Valores -ErrorAction SilentlyContinue
}

Write-Host "`n🔄 Reiniciando o Explorer para aplicar mudancas..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Sleep -s 3

Write-Host "`n Lembrando que algumas coisas podem nao funcionar de cara, reinicie o computador e depois faca voce mesmo" -ForegroundColor Yellow


# ==============================================================================
# ⚙️ WINDOWS UPDATE & OTIMIZACAO
# ==============================================================================
Write-Host "Configurando Windows Update..."
# Atualizar outros produtos Microsoft (Office etc) - Requer criação de chave se não existir
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Default")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Default" -Force | Out-Null
}
# Otimização de Entrega: Permitir downloads da Rede Local (LAN) - 1 = LAN
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 1 -ErrorAction SilentlyContinue

# Reinicia o Explorer
Write-Host "Reiniciando Explorer para aplicar mudancas..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -s 2

Write-Host "`nSETUP DE APPS CONCLUIDO!" -ForegroundColor Green
Write-Host "Nota: O Docker e o Android Studio podem exigir logoff."

Write-Host "Atualizando programas pre-existentes..." -ForegroundColor Blue
winget upgrade --all --include-unknown --accept-source-agreements --silent

# ==============================================================================
# 🔄 CONFIGURAÇÃO DE UPDATE AUTOMÁTICO (SEM ARQUIVO .BAT)
# ==============================================================================
Write-Host "`n>>> Configurando atualizacao automatica semanal..." -ForegroundColor Magenta

# Habilita proteção do sistema no C: (necessário para Checkpoint-Computer)
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

# Define o espaço reservado para 10GB (Garante que cabem vários backups)
# O comando vssadmin redimensiona a "ShadowStorage" (onde ficam os pontos)
Write-Host "Ajustando espaco reservado para Restauracao (10GB)..." -ForegroundColor Yellow
cmd.exe /c "vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10GB" | Out-Null

# Define o comando combinado: Cria Backup -> Atualiza Apps
$ComandoPowerShell = "Checkpoint-Computer -Description 'AutoUpdate_Semanal' -RestorePointType MODIFY_SETTINGS; winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --silent"

$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 8pm
# Executa o powershell de forma oculta (Hidden) rodando o comando acima
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$ComandoPowerShell`""

Register-ScheduledTask -TaskName "AutoUpdateSemanal" -Trigger $Trigger -Action $Action -Description "Atualiza softwares via Winget com Ponto de Restauracao" -User "System" -RunLevel Highest -Force | Out-Null

Write-Host "Tarefa 'AutoUpdateSemanal' criada com sucesso (Direto no Agendador)!" -ForegroundColor Green

# ==============================================================================
# 🛡️ PROTEÇÃO DE REDE: DNS CLOUDFLARE + DoH (HTTPS)
# ==============================================================================
Write-Host "`n>>> Configurando DNS Seguro (CLOUDFLARE + DoH)..." -ForegroundColor Magenta

# Definições
$DNS_Primario = "1.1.1.1"
$DNS_Secundario = "1.0.0.1"
$Template_DoH = "https://cloudflare-dns.com/dns-query"

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
# 🔑 ATIVAÇÃO DO WINDOWS / OFFICE
# ==============================================================================
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "           VERIFICACAO DE ATIVACAO (MAS TOOL)           " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Deseja verificar o status de ativacao do Windows/Office agora?"
Write-Host "Isso abrira o menu do Microsoft Activation Scripts (MAS)."
$RespAtivacao = Read-Host "Digite [S] para Sim ou [Enter] para Pular"

if ($RespAtivacao -eq "S" -or $RespAtivacao -eq "s") {
    Write-Host "Abrindo MAS Tool..." -ForegroundColor Yellow
    # Executa o comando web do MAS
    iex (irm https://get.activated.win)
} else {
    Write-Host "Pulando ativacao." -ForegroundColor Gray
}

Read-Host "Pressione Enter para sair..."


# ==============================================================================
# 🎮 DETECÇÃO DE HARDWARE E APPS DE VÍDEO
# ==============================================================================

# 1. Instalação do SignalRGB (Serve para ambos)
# Coloquei aqui separado ou pode por na lista $AppsLazer
<# 
Instalar-Lista "CONTROLE RGB" @("WhirlwindFX.SignalRgb")

Write-Host "`n>>> Verificando Placa de Video (GPU)..." -ForegroundColor Magenta
$GPU = Get-CimInstance Win32_VideoController

if ($GPU.Name -match "NVIDIA") {
    # --- CENÁRIO NOTEBOOK (RTX 3050) ---
    Write-Host "Hardware NVIDIA identificado. Instalando Suite Gamer + Dev..." -ForegroundColor Green
    $AppsNvidia = @(
        "Nvidia.GeForceExperience",   # Otimização de jogos e Update de Drivers
        "Nvidia.CUDA",                # Essencial para CyberSec (Hashcat) e Dev IA
        "Nvidia.PhysX"                # Motor de física (alguns jogos antigos pedem)
    )
    Instalar-Lista "DRIVERS NVIDIA" $AppsNvidia

} elseif ($GPU.Name -match "AMD" -or $GPU.Name -match "Radeon") {
    # --- CENÁRIO DESKTOP (RX 7600) ---
    Write-Host "Hardware AMD identificado. Instalando Suite Gamer..." -ForegroundColor Green
    $AppsAMD = @(
        "AMD.RadeonSoftware",         # O equivalente ao GeForce Exp. para AMD (Adrenalin)
        "CPUID.CPU-Z",                # Monitoramento de Hardware
        "AMD.RyzenMaster"             # Overclock/Monitoramento de CPU Ryzen (Opcional, mas útil)
    )
    Instalar-Lista "DRIVERS AMD" $AppsAMD
    
} else {
    Write-Host "Nenhuma GPU gamer dedicada detectada pelo script." -ForegroundColor Gray
} 
#> 

