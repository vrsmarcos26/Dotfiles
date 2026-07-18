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

$ListAppsMinimal = @(
    "Brave.Brave",                  # Navegador Seguro
    "Proton.ProtonVPN",             # VPN
    "Malwarebytes.Malwarebytes"    # Scanner de Segunda Opiniao
)

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

    # VERIFICAÇÃO NOVA: Se o Word existe, pula a instalação
    if (Test-Path "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE") {
        Write-Host ">>> O Office ja esta instalado. Pulando etapa." -ForegroundColor Green
        return
    }

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

# ==============================================================================
# 🪟 FUNÇÃO EFEITO GLASS (ExplorerBlurMica)
# ==============================================================================
function Instalar-Mica {

    $InstallDir = "C:\Glass"

    # VERIFICAÇÃO NOVA: Se a pasta já existe, avisa e sai (ou força atualização se preferir)
    if (Test-Path "$InstallDir\ExplorerBlurMica.dll") {
        Write-Host ">>> Efeito Glass ja instalado em $InstallDir. Pulando." -ForegroundColor Green
        return 
    }

    Write-Host "`n>>> Configurando Efeito Glass (Glass)..." -ForegroundColor Cyan
    
    # Define caminhos
    $SourceDir = "$PSScriptRoot\Glass" # Pasta junto do script
    $DllFile = "$InstallDir\ExplorerBlurMica.dll"

    # Verifica se os arquivos de origem existem
    if (!(Test-Path "$SourceDir\ExplorerBlurMica.dll")) {
        Write-Host "AVISO: Pasta 'Glass' nao encontrada junto ao script." -ForegroundColor Yellow
        Write-Host "O efeito Glass nao sera aplicado. Baixe o DLL e coloque na pasta." -ForegroundColor Gray
        return
    }

    # Cria pasta de destino
    if (!(Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

    # Copia arquivos
    Copy-Item -Path "$SourceDir\*" -Destination $InstallDir -Force -Recurse
    Write-Host "Arquivos copiados para $InstallDir" -ForegroundColor Green

    # Registra a DLL (regsvr32)
    Write-Host "Registrando DLL..."
    $RegProc = Start-Process "regsvr32.exe" -ArgumentList "/s `"$DllFile`"" -PassThru -Wait
    
    if ($RegProc.ExitCode -eq 0) {
        Write-Host "Efeito Glass aplicado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro ao registrar DLL. Codigo: $($RegProc.ExitCode)" -ForegroundColor Red
    }
}



# ==============================================================================
# 🛠️ CONFIGURAÇÕES DO WINDOWS (Hardening & Visual)
# ==============================================================================
function Configuration-WindowsVisual {
    
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
}


# ==============================================================================
# 🎨 BARRA DE TAREFAS
# ==============================================================================
function Configuration-TaskBar {
    
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

}


# ==============================================================================
# ⚙️ WINDOWS UPDATE & OTIMIZACAO
# ==============================================================================
function WindowsUpdate-Optimization {
    
    Write-Host "Configurando Windows Update..."

    # Impedir o Windows Update de baixar e substituir drivers de vídeo/hardware automaticamente
    Write-Host "Bloqueando atualizacao automatica de drivers pelo Windows..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0 -Force

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

}

# ==============================================================================
# 🔄 CONFIGURAÇÃO DE UPDATE AUTOMÁTICO (SEM ARQUIVO .BAT)
# ==============================================================================
function AutoUpdate {
    
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
}

# ==============================================================================
# 🛡️ PROTEÇÃO DE REDE: DNS CLOUDFLARE + DoH (HTTPS)
# ==============================================================================
function DNSConfiguration-DoH {
    
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
}


# ==============================================================================
# 🔑 ATIVAÇÃO DO WINDOWS / OFFICE
# ==============================================================================
function Activated-Windows-Office {
    
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
}

# ==============================================================================
# 🚀 EXECUÇÃO PRINCIPAL
# ==============================================================================

# Verificação de Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "POR FAVOR, EXECUTE ESTE SCRIPT COMO ADMINISTRADOR!" -ForegroundColor Red
    Start-Sleep -s 5
    Exit
}

# ==============================================================================
# 🕵️ AUDITORIA DE HARDWARE E DRIVERS ESSENCIAIS (SEU NOVO CÓDIGO ENTRA AQUI)
# ==============================================================================
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "        INICIANDO ANÁLISE PROFUNDA DE HARDWARE" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Coleta de Informações do Sistema
$CPU = (Get-CimInstance Win32_Processor).Name
$GPU = (Get-CimInstance Win32_VideoController).Name
$RAM = [math]::Round(((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB), 0)
$Mobo = (Get-CimInstance Win32_BaseBoard).Product

Write-Host "`n[+] Placa Mãe: $Mobo"
Write-Host "[+] CPU: $CPU"
Write-Host "[+] GPU: $GPU"
Write-Host "[+] RAM: $RAM GB"

Write-Host "`n========================================================" -ForegroundColor Yellow
Write-Host " 💡 RECOMENDAÇÕES DE INSTALAÇÃO MANUAL (DRIVERS BASE)" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Yellow

# --- PLACA MÃE ---
Write-Host "`n-> Placa Mãe detectada: $Mobo" -ForegroundColor Green
Write-Host "   Ação Recomendada: É fundamental verificar o site da fabricante para atualizações de BIOS, LAN e Áudio." -ForegroundColor Cyan
Write-Host "   Dica: O script abriu uma pesquisa no Google com o nome da sua placa." -ForegroundColor DarkGray
Start-Process "https://www.google.com/search?q=$Mobo+Driver+Download"
Read-Host ">>> Pressione Enter APÓS instalar os drivers da Placa Mãe (ou caso queira pular)..."

# --- CPU / CHIPSET ---
if ($CPU -match "AMD") {
    Write-Host "`n-> Processador AMD Ryzen detectado." -ForegroundColor Green
    Write-Host "   Ação Recomendada: Instale o driver de Chipset disponível no site para otimização da placa-mãe." -ForegroundColor Cyan
    Write-Host "   Nota: O 'Ryzen Master' é opcional e apenas para entusiastas de overclock." -ForegroundColor DarkGray
    Start-Process "https://www.amd.com/en/support/download/drivers.html"
    Read-Host ">>> Pressione Enter APÓS instalar o Chipset da AMD..."
} elseif ($CPU -match "Intel") {
    Write-Host "`n-> Processador Intel detectado." -ForegroundColor Green
    Write-Host "   Ação Recomendada: Verifique se há atualizações de processador/chipset no assistente oficial." -ForegroundColor Cyan
    Start-Process "https://www.intel.com.br/content/www/br/pt/download-center/home.html"
    Read-Host ">>> Pressione Enter APÓS verificar os drivers da Intel..."
}

# --- PLACA DE VÍDEO (GPU) ---
if ($GPU -match "AMD" -or $GPU -match "Radeon") {
    Write-Host "`n-> GPU AMD detectada." -ForegroundColor Green
    Write-Host "   Ação Recomendada: Baixe o instalador oficial em: https://www.amd.com/en/support/download/drivers.html"
    Write-Host "   Dica: Use o botão 'Auto-Detect and Install' para garantir o software Adrenalin correto." -ForegroundColor Cyan
    Start-Process "https://www.amd.com/en/support/download/drivers.html"
    Read-Host ">>> Pressione Enter APÓS instalar o Adrenalin..."
} elseif ($GPU -match "NVIDIA") {
    Write-Host "`n-> GPU NVIDIA detectada." -ForegroundColor Green
    Write-Host "   Ação Recomendada: Instale o novo NVIDIA App (substituto do GeForce Experience) para drivers." -ForegroundColor Cyan
    Start-Process "https://www.nvidia.com/pt-br/software/nvidia-app/"
    Read-Host ">>> Pressione Enter APÓS instalar o NVIDIA App..."
} elseif ($GPU -match "Intel") {
    Write-Host "`n-> GPU Intel detectada." -ForegroundColor Green
    Write-Host "   Ação Recomendada: Baixe os drivers gráficos no centro de downloads da Intel." -ForegroundColor Cyan
    Start-Process "https://www.intel.com.br/content/www/br/pt/download-center/home.html"
    Read-Host ">>> Pressione Enter APÓS instalar os drivers de vídeo da Intel..."
}

# --- MEMÓRIA RAM ---
if ($RAM -lt 16) {
    Write-Host "`n-> ALERTA: Memória RAM em $RAM GB." -ForegroundColor Red
    Write-Host "   Recomendação: Para os perfis de Desenvolvimento e CyberSec (Docker/VMware), 16GB é o mínimo exigido. Otimize os apps em segundo plano." -ForegroundColor Yellow
} else {
    Write-Host "`n-> Memória RAM em $RAM GB. Capacidade excelente para Virtualização e Dev!" -ForegroundColor Green
}

Write-Host "`n✅ Auditoria e Drivers base finalizados! Passando para os Aplicativos..." -ForegroundColor Magenta
Start-Sleep -s 2


# ==============================================================================
# 🎛️ MENU INTERATIVO DE PERFIS DE INSTALAÇÃO
# ==============================================================================
Write-Host "`nPreparando o Winget..." -ForegroundColor Yellow
winget source reset --force
winget source update
winget --version

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "          📖 GUIA DE PERFIS DE INSTALAÇÃO" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

Write-Host "`n[1] SETUP MINIMALISTA" -ForegroundColor White
Write-Host "  -> O que instala: Navegador Seguro (Brave), VPN (Proton) e Scanner (Malwarebytes)." -ForegroundColor DarkGray
Write-Host "  -> O que configura: Apenas a criptografia de DNS (Cloudflare)." -ForegroundColor DarkGray
Write-Host "  -> O que você PERDE: Ferramentas de Dev, Jogos, Office, Efeito Glass, Mods visuais e Backup automatizado." -ForegroundColor Red
Write-Host "  -> Ideal para: Notebooks antigos, PCs corporativos limitados ou ambientes estritamente para leitura." -ForegroundColor Yellow

Write-Host "`n[2] SETUP PESSOAL COMPLETO" -ForegroundColor White
Write-Host "  -> O que instala: O PACOTE TOTAL. CyberSec, Ambientes Dev (VS Code, VMs), Jogos (Steam), Office e Glass." -ForegroundColor DarkGray
Write-Host "  -> O que configura: Hardening de Update, Tema Escuro, DNS, Barra Centralizada e Tarefa de AutoUpdate." -ForegroundColor DarkGray
Write-Host "  -> O que você PERDE: Espaço em disco (instalação pesada) e um pouco de RAM em idle (devido ao Glass e Cloud)." -ForegroundColor Red
Write-Host "  -> Ideal para: Seu PC Principal ou Notebook potente de uso diário." -ForegroundColor Yellow

Write-Host "`n[3] MODO CUSTOMIZADO" -ForegroundColor White
Write-Host "  -> O que faz: Permite escolher as ferramentas e configurações cirurgicamente através de caixas de seleção." -ForegroundColor DarkGray
Write-Host "  -> Ideal para: Preparar máquinas específicas (ex: Só ferramentas Dev, sem jogos; ou só Office e Lazer)." -ForegroundColor Yellow
Write-Host "--------------------------------------------------------"

Read-Host ">>> Pressione Enter APÓS ler tudo..."


$OpcoesPerfil = @(
    "1. Setup Minimalista (Apenas Navegador e VPN - Ideal para Notebooks básicos)",
    "2. Setup Pessoal Completo (Gamer + Dev + CyberSec + Office + Glass)",
    "3. Modo Customizado (Escolher aplicativos um por um manualmente)"
)

Write-Host "Abrindo janela de seleção de perfil..." -ForegroundColor Cyan
# Abre a interface gráfica para escolha única
$PerfilEscolhido = $OpcoesPerfil | Out-GridView -Title "Selecione o Perfil de Instalação para esta Máquina" -PassThru

# Verifica se o usuário fechou a janela sem escolher
if (-not $PerfilEscolhido) {
    Write-Host "Nenhum perfil selecionado. Cancelando instalação de apps." -ForegroundColor Red
    Exit
}


Write-Host "`nVocê escolheu: $PerfilEscolhido" -ForegroundColor Green

# --- LÓGICA DO PERFIL 1: MINIMALISTA ---
if ($PerfilEscolhido -match "1. Setup Minimalista") {
    Write-Host "Iniciando Instalação Minimalista..." -ForegroundColor Magenta
    # Instala apenas a lista de segurança
    Instalar-Lista "SEGURANCA" $ListAppsMinimal
    
    Write-Host "`nInstalações Adicionais:" -ForegroundColor Cyan
    $RespOffice = Read-Host "Deseja instalar o Microsoft Office 2024? [S/N]"
    if ($RespOffice -match "^[Ss]") { Instalar-Office }

}

# --- LÓGICA DO PERFIL 2: COMPLETO ---
elseif ($PerfilEscolhido -match "2. Setup Pessoal Completo") {
    Write-Host "Iniciando Instalação Completa..." -ForegroundColor Magenta
    Instalar-Lista "SEGURANCA" $AppsSecurity
    Instalar-Lista "DESENVOLVIMENTO" $AppsDev
    Instalar-Lista "LAZER" $AppsLazer

    Write-Host "`nLembre-se de instalar Hydra, WindHawk e NodeJS POR FORA (navegador)" -ForegroundColor Yellow
    Write-Host "`n DESINSTALAR SignalRgb caso esteja no Notebook" -ForegroundColor Yellow

    Instalar-Office
    Instalar-Mica

    Configuration-WindowsVisual
    Configuration-TaskBar
    WindowsUpdate-Optimization
    AutoUpdate
    DNSConfiguration-DoH
    Activated-Windows-Office

    Write-Host "`nSetup Completo Concluido!" -ForegroundColor Green
}

# --- LÓGICA DO PERFIL 3: CUSTOMIZADO ---
elseif ($PerfilEscolhido -match "3. Modo Customizado") {

    # Junta todas as listas para a tela de seleção
    $TodosApps = $AppsSecurity + $AppsDev + $AppsLazer
    
    # Abre a interface gráfica permitindo múltipla escolha (Segurar CTRL)
    $AppsSelecionados = $TodosApps | Out-GridView -Title "Segure CTRL e clique nos apps que deseja instalar" -PassThru
    
    if ($AppsSelecionados) { Instalar-Lista "CUSTOMIZADO" $AppsSelecionados }

    $RespOffice = Read-Host "Deseja instalar o Microsoft Office 2024? [S/N]"
    if ($RespOffice -match "^[Ss]") { Instalar-Office }

    $RespMica = Read-Host "Deseja instalar o Efeito Glass? [S/N]"
    if ($RespMica -match "^[Ss]") { Instalar-Mica }

    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "    📖 GUIA DE CONFIGURAÇÕES DE SISTEMA (HARDENING)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "[1] Visual: Força Tema Escuro, mostra extensões de arquivos (vital para CyberSec) e exibe pastas ocultas." -ForegroundColor DarkGray
    Write-Host "[2] Barra: Oculta pesquisas/clima pesados, ativa Auto-Hide e centraliza ícones estilo Win11." -ForegroundColor DarkGray
    Write-Host "[3] Update Otimizado: IMPEDE o Windows de instalar drivers por cima dos seus e otimiza a rede LAN." -ForegroundColor DarkGray
    Write-Host "[4] AutoUpdate: Cria uma rotina secreta que cria ponto de restauração e atualiza tudo via Winget toda 4ª feira." -ForegroundColor DarkGray
    Write-Host "[5] Rede (DNS): Encripta seu tráfego DNS roteando tudo para a Cloudflare (Evita rastreio de operadora)." -ForegroundColor DarkGray
    Write-Host "[6] Ativação: Inicia a ferramenta MAS para licenças." -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------"

    Write-Host "`nAbrindo seleção de Configurações..." -ForegroundColor Cyan
    Start-Sleep -s 2

    $OpcoesSistema = @(
        "1. Visual e Explorer (Modo Escuro, Arquivos Ocultos)",
        "2. Barra de Tarefas (Centralizar, Auto-Hide)",
        "3. Otimizacao do Windows Update (Bloquear drivers via WU)",
        "4. Criar Rotina Semanal (Winget Auto Update + Backup)",
        "5. Protecao de Rede (DNS Cloudflare + DoH)",
        "6. Ativacao do Windows/Office (MAS Tool)"
    )

    $AjustesSelecionados = $OpcoesSistema | Out-GridView -Title "Segure CTRL para selecionar configurações do SISTEMA" -PassThru

    if ($AjustesSelecionados) {
        if ($AjustesSelecionados -match "1.") { Configuration-WindowsVisual }
        if ($AjustesSelecionados -match "2.") { Configuration-TaskBar }
        if ($AjustesSelecionados -match "3.") { WindowsUpdate-Optimization }
        if ($AjustesSelecionados -match "4.") { AutoUpdate }
        if ($AjustesSelecionados -match "5.") { DNSConfiguration-DoH }
        if ($AjustesSelecionados -match "6.") { Activated-Windows-Office }
    }

    Write-Host "`nSetup Customizado Concluido!" -ForegroundColor Green
}

Write-Host "`nReinicie o computador para aplicar todas as alteracoes visuais e de rede." -ForegroundColor Yellow
Start-Sleep -s 5


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






