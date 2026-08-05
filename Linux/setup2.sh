#!/bin/bash
# AUTOR: vrsmarcos26
# FUNCAO: Instalar Apps, Restaurar Configs e Aplicar Temas (3 Modos)

# --- TRAVA DE SEGURANCA: NAO RODAR COMO ROOT ---
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}ERRO: Nao rode este script como sudo/root!${NC}"
  echo "Rode apenas: ./setup.sh"
  echo "O script pedira a senha quando necessario."
  exit 1
fi

# --- CORES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}>>> INICIANDO SETUP ZORIN OS...${NC}"

# ==============================================================================
# 0. TIMESHIFT - BACKUP DE SEGURANCA
# ==============================================================================
verificar_timeshift() {
    echo -e "${YELLOW}>>> Atualizando pacotes...${NC}"
    sudo apt update && sudo apt upgrade -y

    if ! command -v timeshift &> /dev/null; then
        echo "Instalando TimeShift..."
        sudo apt install timeshift -y
    fi

    echo -e "${RED}================================================================="
    echo " ⚠️  ATENÇÃO: CONFIGURAÇÃO DE SEGURANÇA NECESSÁRIA  ⚠️"
    echo "=================================================================${NC}"
    echo "O TimeShift foi instalado. Antes de continuar o script, abra-o"
    echo "no menu e configure EXATAMENTE assim para garantir reversão:"
    echo ""
    echo "1. Tipo de Snapshot: RSYNC"
    echo "2. Localização: Selecione seu disco principal (ou externo)"
    echo "3. Agendamento:"
    echo "   [x] Semanalmente (Manter 2)"
    echo "   [x] Diariamente  (Manter 3)"
    echo "   [x] Parar emails do cron (Stop cron emails)"
    echo "4. Usuários (Users) / Filtros:"
    echo "   [x] Incluir/Excluir arquivos root (Padrão)"
    echo "   [x] Incluir diretório /home/$USER (Incluir arquivos ocultos)"
    echo ""
    echo "5. CLIQUE EM 'CRIAR' PARA FAZER O SNAPSHOT DE AGORA!"
    echo "================================================================="
    echo ""

    while true; do
        read -p "Voce configurou o TimeShift e criou o Snapshot inicial? (SIM para continuar): " sn
        case $sn in
            [Ss]*| ) break;;
            * ) echo "Por favor configure o TimeShift primeiro.";;
        esac
    done
    echo ">>> Continuando instalacao..."
}

# ==============================================================================
# 1. FUNCOES DO SISTEMA E CUSTOMIZACOES (MODULARIZADO)
# ==============================================================================

limpar_bloatware() {
    echo -e "${YELLOW}>>> Removendo aplicativos nativos indesejados e LibreOffice...${NC}"
    APPS_TO_REMOVE=(
        "brasero" "evolution" "rhythmbox" "gnome-contacts"
        "gnome-characters" "gnome-weather" "gnome-clocks"
    )
    echo APlicativos a serem removidos: "${APPS_TO_REMOVE[@]}"

    for app in "${APPS_TO_REMOVE[@]}"; do
        if dpkg -l | grep -q "^ii  $app "; then
            sudo apt purge -y "$app"
        fi
    done
    sudo apt purge -y libreoffice*
    sudo apt autoremove -y && sudo apt clean
    echo -e "${GREEN}Limpeza concluida!${NC}"
}

configurar_seguranca_dns() {
    echo -e "${YELLOW}>>> Configurando Firewall, Privacidade e DNS Cloudflare...${NC}"
    # Firewall
    echo -e "${YELLOW}Ativando FIrewall...${NC}"
    if ! command -v ufw &> /dev/null; then
        sudo apt install ufw -y && sudo apt install gufw -y
    fi

    echo "Ativando Firewall..."
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    echo -e "${GREEN}Firewall já está ativo e configurado.${NC}"

    echo ""
    read -p "Deseja liberar as portas do firewall para o Zorin Connect? [S/n]: " resp_zorin
    case "$resp_zorin" in
        [Ss]*|"" )
            echo "Liberando portas para o Zorin Connect..."
            sudo ufw allow 1714:1764/tcp comment "Zorin Connect TCP"
            sudo ufw allow 1714:1764/udp comment "Zorin Connect UDP"
            echo -e "${GREEN}Portas do Zorin Connect liberadas com sucesso.${NC}"
            ;;
        * )
            echo -e "${YELLOW}Pulando a liberacao de portas do Zorin Connect.${NC}"
            ;;
    esac
    echo ""

    # Tela de bloqueio e Localizacao
    echo -e "${YELLOW}Verificando protecao de tela e localizacao...${NC}"
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    gsettings set org.gnome.system.location enabled false
    echo -e "${GREEN}Proteção de tela ja esta ativa.${NC}"

    # Historico e Lixeira
    echo -e "${YELLOW}Configurando limpeza automática...${NC}"
    echo "Ativando histórico"
    gsettings set org.gnome.desktop.privacy remember-recent-files true
    gsettings set org.gnome.desktop.privacy recent-files-max-age -1
    echo "Ativando remoção automática de arquivos..."
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
    gsettings set org.gnome.desktop.privacy old-files-age 30
    echo -e "${GREEN}Configurações de Limpeza e Histórico ativadas.${NC}"

    # DNS Cloudflare
    DEFAULT_DEV=$(ip route get 1.1.1.1 | sed -n 's/.*dev \([^\ ]*\).*/\1/p' | head -n1)
    if [ -n "$DEFAULT_DEV" ]; then
        CONN=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":${DEFAULT_DEV}$" | cut -d: -f1 | head -n1)
        if [ -n "$CONN" ]; then
            echo "Interface principal detectada: $DEFAULT_DEV"
            echo "Configurando DNS para a conexão: $CONN"
            sudo nmcli con mod "$CONN" ipv4.dns "1.1.1.1 1.0.0.1"
            sudo nmcli con mod "$CONN" ipv4.ignore-auto-dns yes
            echo "Aplicando alterações..."
            sudo nmcli con up "$CONN"
            echo -e "${GREEN}DNS seguro configurado na conexão principal.${NC}"
        else
            echo -e "${RED}Erro: Não foi possível identificar o nome da conexão para a interface $DEFAULT_DEV.${NC}"
        fi
    else
        echo -e "${RED}Nenhuma rota para a internet encontrada. Pulei a configuração de DNS.${NC}"
    fi
}

# ==========================================================================
# ⚙️​ 2. ATUALIZACOES E AUTOMACOES
# ==========================================================================

configurar_atualizacoes_repos() {
    echo -e "${YELLOW}>>> Configurando repositorios BR e Atualizacoes Automaticas...${NC}"

    if grep -qE "universe|multiverse" /etc/apt/sources.list; then
        echo -e "${GREEN}Repositórios Universe e Multiverse já estão ativados.${NC}"
    else
        echo -e "${YELLOW}[!] Ativando componentes principais...${NC}"
        sudo add-apt-repository main -y
        sudo add-apt-repository universe -y
        sudo add-apt-repository restricted -y
        sudo add-apt-repository multiverse -y

        echo -e "${GREEN}Componentes principais ativados.${NC}"
    fi

    if ! grep -q "http://br.archive.ubuntu.com" /etc/apt/sources.list; then
        echo -e "${YELLOW}[!] Configurando repositórios do Brasil...${NC}"
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
        sudo sed -i 's|http://archive.ubuntu.com|http://br.archive.ubuntu.com|g' /etc/apt/sources.list
        sudo sed -i 's|http://us.archive.ubuntu.com|http://br.archive.ubuntu.com|g' /etc/apt/sources.list
        sudo apt update
        echo -e "${GREEN}Repositórios do Brasil configurados.${NC}"
    fi

    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ] && grep -q "AutocleanInterval" /etc/apt/apt.conf.d/20auto-upgrades; then
        echo -e "${GREEN}Atualizações automáticas já estão configuradas.${NC}"
    else
        echo -e "${YELLOW}[!] Configurando atualizações automáticas...${NC}"
        cat <<EOF | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
# Verificar atualizações automaticamente: Diariamente (1)
APT::Periodic::Update-Package-Lists "1";
# Baixar pacotes atualizáveis: Diariamente (1)
APT::Periodic::Download-Upgradeable-Packages "1";
# Instalar atualizações de segurança automaticamente: Sim (1)
APT::Periodic::Unattended-Upgrade "1";
# Limpar arquivos antigos baixados: A cada 7 dias
APT::Periodic::AutocleanInterval "7";
EOF
    fi

    ATUAL=$(gsettings get com.ubuntu.update-notifier regular-auto-launch-interval)
    if [ "$ATUAL" -eq 7 ]; then
        echo -e "${GREEN}[OK] Intervalo de notificação já é 7.${NC}"
    else
        echo -e "${YELLOW}[!] Ajustando intervalo de notificação para 7...${NC}"
        gsettings set com.ubuntu.update-notifier regular-auto-launch-interval 7
    fi

    echo -e "${GREEN}Atualizações automáticas configuradas.${NC}"
}

# ===========================================================================
# 🧠 DETECÇÃO E INSTALAÇÃO DE HARDWARE E GRUB (A MÁGICA)
# ===========================================================================

configurar_hardware_grub() {
    echo -e "${YELLOW}>>> Analisando Hardware e Configurando GRUB...${NC}"

    CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}')

    echo -e "${YELLOW}CPU Encontrada: $CPU_VENDOR${NC}"

    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        echo -e "${GREEN}Processador INTEL detectado.${NC}"
        echo "Instalando Microcode Intel..."
        sudo apt install -y intel-microcode
    elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        echo -e "${GREEN}Processador AMD detectado.${NC}"
        echo "Instalando Microcode AMD..."
        sudo apt install -y amd64-microcode
    else
        echo "Fabricante de CPU desconhecido ($CPU_VENDOR). Pulando microcode."
    fi

    GPU_INFO=$(lspci | grep -i -E "vga|3d")

    echo -e "${YELLOW}GPU Encontrada: $GPU_INFO${NC}"

    if echo "$GPU_INFO" | grep -qi "nvidia"; then
        echo -e "${GREEN}>>> Placa NVIDIA Detectada!${NC}"
        echo "Adicionando repositório de drivers gráficos (PPA) para versão mais recente..."
        sudo add-apt-repository ppa:graphics-drivers/ppa -y

        echo "Instalando drivers proprietários recomendados..."
        sudo apt update && sudo ubuntu-drivers autoinstall
        sudo apt install -y nvidia-settings
    elif echo "$GPU_INFO" | grep -qi "amd"; then
        echo -e "${GREEN}>>> Placa AMD (Radeon) Detectada!${NC}"
        echo "Instalando drivers Mesa, Vulkan e suporte a jogos..."
        sudo apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 libvulkan1 mesa-utils

        # Opcional: Adicionar PPA Kisak para drivers Mesa mais recentes (bom para jogos novos)
        # sudo add-apt-repository ppa:kisak/kisak-mesa -y && sudo apt update && sudo apt upgrade -y

    elif echo "$GPU_INFO" | grep -qi "intel"; then
        echo -e "${GREEN}>>> Gráficos Integrados Intel Detectados!${NC}"
        echo "Instalando drivers de mídia e Vulkan..."
        sudo apt install -y intel-media-driver mesa-vulkan-drivers mesa-utils
    fi

    # GRUB Vimix

    echo -e "${YELLOW}>>> Configurando GRUB...${NC}"

    TEMP_GRUB="/tmp/grub-theme"
    if [ -d "$TEMP_GRUB" ]; then rm -rf "$TEMP_GRUB"; fi
    git clone https://github.com/vinceliuice/grub2-themes.git "$TEMP_GRUB"
    echo "Instalando tema Vimix..."
    cd "$TEMP_GRUB" && sudo ./install.sh -b -t vimix -s 1080p
    echo "Atualizando configurações do boot..."
    sudo update-grub
    cd ~/Downloads/Dotfiles/Linux || cd ~
    echo -e "${GREEN}Tema do GRUB instalado!${NC}"
}

configurar_webapps() {
    echo -e "${YELLOW}>>> Criando Web Apps Isolados...${NC}"

    ICE_ICONS="$HOME/.local/share/ice/icons"
    ICE_PROFILES="$HOME/.local/share/ice/profiles"
    mkdir -p "$ICE_ICONS" "$ICE_PROFILES"
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    SOURCE_ICONS="$SCRIPT_DIR/icons-web-apps/"

    create_isolated_webapp() {
        local NAME="$1"                 # Ex: TryHackMe
        local URL="$2"                  # Ex: https://tryhackme.com
        local ICON_FILE="$3"            # Ex: tryhackme.png (Nome do arquivo na sua pasta Icons)
        local NAME_SLUG="${NAME// /-}"

        # Identifica o Navegador (Brave > Chrome > Chromium)
        if command -v brave-browser &> /dev/null; then
            BROWSER_EXEC="brave-browser"; BROWSER_NAME="Brave Browser"
        elif command -v google-chrome &> /dev/null; then
            BROWSER_EXEC="google-chrome"; BROWSER_NAME="Google Chrome"
        else
            BROWSER_EXEC="chromium-browser"; BROWSER_NAME="Chromium"
        fi

        echo "Criando App Isolado: $NAME..."

        if [ -f "$SOURCE_ICONS/$ICON_FILE" ]; then
            cp "$SOURCE_ICONS/$ICON_FILE" "$ICE_ICONS/$ICON_FILE"
            FINAL_ICON_PATH="$ICE_ICONS/$ICON_FILE"
        else
            echo "⚠️ Ícone $ICON_FILE não encontrado em $SOURCE_ICONS. Usando genérico."
            FINAL_ICON_PATH="web-browser"
        fi

        PROFILE_DIR="$ICE_PROFILES/$NAME"
        DESKTOP_FILE="$HOME/.local/share/applications/WebApp-$NAME.desktop"

        cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=$NAME
Comment=Web App Isolado
Exec=$BROWSER_EXEC --app="$URL" --class=WebApp-$NAME_SLUG --name=WebApp-$NAME_SLUG --user-data-dir=$PROFILE_DIR
Terminal=false
Type=Application
Icon=$FINAL_ICON_PATH
Categories=GTK;Network;WebBrowser;
StartupWMClass=WebApp-$NAME_SLUG
StartupNotify=true
X-WebApp-Browser=$BROWSER_NAME
X-WebApp-URL=$URL
X-WebApp-Isolated=true
EOF
        chmod +x "$DESKTOP_FILE"
    }

    create_isolated_webapp "Hack The Box" "https://www.hackthebox.com" "HackTheBox.png"
    create_isolated_webapp "TryHackMe" "https://tryhackme.com" "TryHackMe.png"
    create_isolated_webapp "HackingClub" "https://app.hackingclub.com" "HackingClub.png"
    create_isolated_webapp "Notion" "https://notion.so" "Notion.png"

    echo -e "${GREEN}Web Apps criados na pasta de aplicações!${NC}"
}

configurar_stack_dev_cybersec() {
    echo -e "${YELLOW}>>> Configurando Stack de Dev, CyberSec e Docker...${NC}"

    # 1. Ferramentas CLI de Rede, Pentest e Docker via APT
    echo "Instalando ferramentas de recon, pacotes e Docker..."
    sudo apt install -y nmap wireshark sqlite3 docker.io docker-compose-v2

    # Adiciona seu usuario ao grupo Docker (para rodar docker sem sudo)
    echo "Adicionando seu usuario ao grupo Docker (para rodar docker sem sudo)..."
    sudo usermod -aG docker $USER

    # 2. Criando pasta de Ferramentas / CTF na sua Home
    echo "Criando diretorio para exploits e ferramentas manuais..."
    TOOLS_DIR="$HOME/Tools"
    mkdir -p "$TOOLS_DIR"

    # Baixando SQLMap via Git (Sempre na ultima versao)
    if [ ! -d "$TOOLS_DIR/sqlmap" ]; then
        echo "Clonando SQLMap..."
        git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git "$TOOLS_DIR/sqlmap"
    fi

    # 3. Instalando NVM (Gerenciador de Node.js / React)
    if [ ! -d "$HOME/.nvm" ]; then
        echo "Instalando NVM para Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm use --lts
    fi

    # 4. Instalando SDKMAN! (Gerenciador de Java e Kotlin)
    if [ ! -d "$HOME/.sdkman" ]; then
        echo "Instalando SDKMAN para Java/Kotlin..."
        curl -s "https://get.sdkman.io?rcupdate=false" | bash
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install java
        sdk install kotlin
    fi

    echo -e "${GREEN}>>> Stack Dev & CyberSec instalada com sucesso!${NC}"
    echo "Nota: O Docker sem 'sudo' e o NVM/SDKMAN precisarao de reinicio da sessao para carregar no terminal."
    echo "Nota: Reinicie o terminal ou faça Logoff para ativar os comandos Node, Java e os aliases do Docker."
}

configurar_visual_gnome() {
    echo -e "${YELLOW}>>> Configurando Visual GNOME, Barra de Tarefas e CSS...${NC}"

    # Fastfetch
    echo "Instalando Fastfetch..."
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt update -y && sudo apt install fastfetch -y
    if ! grep -q "fastfetch" ~/.bashrc; then
        echo -e "\n# Iniciando Fastfetch\nfastfetch --logo-type kitty --logo-padding 3" | tee -a ~/.bashrc
    fi

    echo "Aplicando tema escuro..."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'ZorinBlue-Dark'
    gsettings set org.gnome.shell.extensions.user-theme name 'ZorinBlue-Dark'

    echo "Permitindo volume acima de 100%..."
    gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

    echo "Configurando exibição de data e hora..."
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-seconds false
    gsettings set org.gnome.desktop.calendar show-weekdate false
    gsettings set org.gnome.desktop.interface clock-show-weekday false

    # Efeitos 3D e Luz Noturna
    echo "Ativando efeitos 3D..."
    # Cube
    gnome-extensions enable zorin-desktop-cube@zorinos.com
    # Spatial Window Switcher
    gnome-extensions enable zorin-spatial-window-switcher@zorinos.com

    echo "Configurando Luz Noturna..."
    # Ligar luz noturna automaticamente ao anoitecer
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    # Automaticamente ao anoitecer
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
    # Temperatura para 2700K
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2700

    echo "Retirando ícones da área de trabalho..."
    gnome-extensions disable zorin-desktop-icons@zorinos.com

    echo "Configurando tecla Super (Windows) para abrir o menu..."
    gsettings set org.gnome.shell.extensions.zorin-menu super-hotkey true
    gsettings set org.gnome.mutter overlay-key 'SUPER_L'

    echo "Configurando modo de energia para Balanced..."
    powerprofilesctl set balanced

    # Barra de tarefas Zorin
    echo "Configurando barra de tarefas..."
    # Esconder Automaticamente
    gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide true
    # Margem da barra
    gsettings set org.gnome.shell.extensions.zorin-taskbar panel-margin 4
    # Arredondamento dos cantos
    gsettings set org.gnome.shell.extensions.zorin-taskbar global-border-radius 5
    # Sobrepor o tema Override
    gsettings set org.gnome.shell.extensions.zorin-taskbar trans-use-custom-opacity true
    # Opacidade personalizada (transparente 0.0 = 0%, 1.0 = 100%)
    gsettings set org.gnome.shell.extensions.zorin-taskbar trans-panel-opacity 0.0
    # Posicao da barra (BOTTOM, TOP, LEFT, RIGHT)
    gsettings set org.gnome.shell.extensions.zorin-taskbar panel-positions '{"0":"BOTTOM"}'
    # Tamanho dos icons (Pequeno 24, Medio 37, Grande 40)
    gsettings set org.gnome.shell.extensions.zorin-taskbar panel-sizes '{"0":37}'
    # Usar 100% da barra (0-100) ou tamanho automatico (0)
    gsettings set org.gnome.shell.extensions.zorin-taskbar panel-lengths '{"0":100}'
    # Ordem e visibilidade dos elementos da barra (activitiesButton, leftBox, showAppsButton, taskbar, centerBox, rightBox, systemMenu, dateMenu, desktopButton)
    gsettings set org.gnome.shell.extensions.zorin-taskbar panel-element-positions '{"0":[
     {"element":"activitiesButton","visible":true,"position":"stackedTL"},
     {"element":"leftBox","visible":true,"position":"centerMonitor"},
     {"element":"showAppsButton","visible":false,"position":"centerMonitor"},
     {"element":"taskbar","visible":true,"position":"centerMonitor"},
     {"element":"centerBox","visible":false,"position":"centerMonitor"},
     {"element":"rightBox","visible":true,"position":"stackedBR"},
     {"element":"systemMenu","visible":true,"position":"stackedBR"},
     {"element":"dateMenu","visible":true,"position":"stackedBR"},
     {"element":"desktopButton","visible":false,"position":"stackedTL"}
    ]}'

    # CSS Transparencia
    TTHEME_FILE="/usr/share/themes/ZorinBlue-Dark/gnome-shell/gnome-shell.css"

    # # Fallback se não achar no caminho específico
    if [ ! -f "$TTHEME_FILE" ]; then
        TTHEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
    fi

    if [ -f "$TTHEME_FILE" ] && ! grep -q "CUSTOMIZACAO DO MARCOS" "$TTHEME_FILE"; then
        sudo cp "$TTHEME_FILE" "$TTHEME_FILE.bak"
        sudo tee -a "$TTHEME_FILE" > /dev/null <<'EOF'
/* --- CUSTOMIZACAO DO MARCOS --- */
.popup-menu-content {
    background-color: rgba(34, 43, 48, 0.45) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4);
}
#mode-dark .popup-menu-content,
.popup-menu-content.panel-menu {
    background-color: rgba(34, 43, 48, 0.45) !important;
}
EOF
    fi
}

configurar_wallpapers_hidamari() {
    echo -e "${YELLOW}>>> Configurando Wallpapers estaticos e animacao Hidamari...${NC}"
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPER_DIR" "$HOME/.local/share/backgrounds/"
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    cp "$SCRIPT_DIR/Wallpapers/White/"*.png "$WALLPAPER_DIR/" 2>/dev/null || true
    cp "$SCRIPT_DIR/Wallpapers/Vermelho/"*.png "$WALLPAPER_DIR/" 2>/dev/null || true
    cp "$WALLPAPER_DIR/"*.png "$HOME/.local/share/backgrounds/" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file:///$HOME/.local/share/backgrounds/white.png"

    echo "Configurações de wallpaper STATICO aplicadas."
    echo "Instalando Hidamari Wallpaper Changer..."

    flatpak install flathub io.github.jeffshee.Hidamari -y --noninteractive
    flatpak override --user io.github.jeffshee.Hidamari --filesystem=~/Videos

    WALLPAPER_ANIMATION_DIR="$HOME/Videos/Hidamari"
    mkdir -p "$WALLPAPER_ANIMATION_DIR"
    cp "$SCRIPT_DIR/Wallpapers/White/"*.mp4 "$WALLPAPER_ANIMATION_DIR/" 2>/dev/null || true
    cp "$SCRIPT_DIR/Wallpapers/Vermelho/"*.mp4 "$WALLPAPER_ANIMATION_DIR/" 2>/dev/null || true

    CONFIG_DIR="$HOME/.var/app/io.github.jeffshee.Hidamari/config/hidamari"
    mkdir -p "$CONFIG_DIR"
    cat <<EOF > "$CONFIG_DIR/config.json"
{
   "version": 4,
   "mode": "MODE_VIDEO",
   "data_source": {
      "Default": "$WALLPAPER_ANIMATION_DIR/white.mp4"
   },
   "is_mute": true,
   "audio_volume": 50,
   "is_static_wallpaper": false,
   "static_wallpaper_blur_radius": 5,
   "is_pause_when_maximized": true,
   "is_mute_when_maximized": false,
   "fade_duration_sec": 1.5,
   "fade_interval": 0.1,
   "is_show_systray": false,
   "is_first_time": false
}
EOF

    echo ""
    echo "========================================================"
    echo "   INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "========================================================"
    echo "1. Abra o menu do Zorin e procure por 'Hidamari'."
    echo "2. Procure pelo simbolo do hamburguer"
    echo "3. Selecione \"Iniciar com o computador\" e ative a opção."
    echo "========================================================"
}

configurar_conky() {
    echo -e "${YELLOW}>>> Configurando Conky (Tema Gotham)...${NC}"
    sudo apt install conky-all -y
    sudo add-apt-repository ppa:tomtomtom/conky-manager -y
    sudo add-apt-repository --remove ppa:teejee2008/ppa -y
    sudo apt update -y && sudo apt install conky-manager2 -y

    conky-manager2 & sleep 5 && killall conky-manager2

    cat <<'EOF' > "$HOME/.conky/conky-startup.sh"
#!/bin/sh
if [ "$DESKTOP_SESSION" = "zorin-xorg" ]; then 
   sleep 10s
   killall conky
   cd "$HOME/.conky/Gotham"
   conky -c "$HOME/.conky/Gotham/Gotham" &
   exit 0
fi
EOF

    THEME_DIR="$HOME/.conky/Gotham"
    mkdir -p "$THEME_DIR"
    cat <<'EOF' > "$THEME_DIR/Gotham"
conky.config = {
	use_xft = true,
	font = '123:size=8',
	xftalpha = 0.1,
	update_interval = 1,
	total_run_times = 0,
	own_window = true,
	own_window_type = 'normal',
	own_window_transparent = true,
	own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
	own_window_colour = 'FFFFFF',
	own_window_argb_visual = true,
	own_window_argb_value = 0,
	double_buffer = true,
	draw_shades = false,
	draw_outline = false,
	draw_borders = false,
	draw_graph_borders = false,
	default_color = 'white',
	default_shade_color = 'red',
	default_outline_color = 'green',
	alignment = 'top_left',
	gap_x = 100,
	gap_y = 70,
	no_buffers = true,
	uppercase = false,
	cpu_avg_samples = 2,
	net_avg_samples = 1,
	override_utf8_locale = true,
	use_spacer = 'yes',
	minimum_width = 0, minimum_height = 0,
};

conky.text = [[
${voffset 10}${color EAEAEA}${font GE Inspira:pixelsize=120}${time %I:%M}${font}${voffset -84}${offset 10}${color FFA300}${font GE Inspira:pixelsize=42}${time %d} ${voffset -15}${color EAEAEA}${font GE Inspira:pixelsize=22}${execi 60 LC_TIME=en_US.UTF-8 date +%B} ${time %Y}${font}${voffset 24}${font GE Inspira:pixelsize=58}${offset -148}${execi 60 LC_TIME=en_US.UTF-8 date +%A}${font}
${voffset 1}${offset 12}${font Ubuntu:pixelsize=12}${color FFA300}HD ${offset 9}$color${fs_free /} / ${fs_size /}${offset 30}${color FFA300}RAM ${offset 9}$color$mem / $memmax${offset 30}${color FFA300}CPU ${offset 9}$color${cpu cpu0}%
]];
EOF
    sh "$HOME/.conky/conky-startup.sh"

    echo ""
    echo "========================================================"
    echo "   INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "========================================================"
    echo "1. Abra o menu do Zorin e procure por 'Conky Manager'."
    echo "2. Na lista de temas, marque a caixinha 'Gotham'."
    echo "3. Vá nas configurações do Conky Manager (ícone engrenagem)"
    echo "   e ative 'Run Conky at system startup'."
    echo "========================================================"

}

configurar_extensoes_gnome() {
    echo -e "${YELLOW}>>> Instalando Extensoes ArcMenu e Blur My Shell...${NC}"
    sudo apt install python3-pip git -y
    if ! command -v pipx &> /dev/null; then
        sudo apt install pipx -y
        pipx ensurepath
    fi
    export PATH=$PATH:$HOME/.local/bin

    if ! command -v gext &> /dev/null; then
        pipx install gnome-extensions-cli --force
    fi

    gext install arcmenu@arcmenu.com || true
    gext install blur-my-shell@aunetx || true

    glib-compile-schemas ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ 2>/dev/null
    glib-compile-schemas ~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas/ 2>/dev/null

    gnome-extensions enable arcmenu@arcmenu.com
    gnome-extensions enable blur-my-shell@aunetx

    # Blur My Shell Dconf
    dconf load /org/gnome/shell/extensions/blur-my-shell/ <<EOF
[/]
pipelines={'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <24>}>}>]>}}
settings-version=2

[appfolder]
blur=false
brightness=0.59999999999999998
sigma=30

[applications]
blur=true
blur-on-overview=false
brightness=1.0
dynamic-opacity=false
enable-all=false
opacity=180
sigma=20
whitelist=['org.gnome.Nautilus', 'Gnome-terminal']

[coverflow-alt-tab]
pipeline='pipeline_default'

[dash-to-dock]
blur=false
brightness=0.59999999999999998
override-background=false
pipeline='pipeline_default_rounded'
sigma=0
static-blur=false
style-dash-to-dock=0

[dash-to-panel]
blur-original-panel=false

[hidetopbar]
compatibility=false

[lockscreen]
pipeline='pipeline_default'

[overview]
blur=true
pipeline='pipeline_default'
style-components=2

[panel]
blur=false
brightness=0.59999999999999998
force-light-text=false
override-background=true
override-background-dynamically=false
pipeline='pipeline_default'
sigma=0
static-blur=false
style-panel=0
unblur-in-overview=true

[screenshot]
pipeline='pipeline_default'

[window-list]
brightness=0.59999999999999998
sigma=30
EOF

    # ArcMenu Dconf
    dconf load /org/gnome/shell/extensions/arcmenu/ <<EOF
[/]
dash-to-panel-standalone=false
force-menu-location='Off'
group-apps-alphabetically-list-layouts=true
hide-overview-on-arcmenu-open=false
hide-overview-on-startup=false
menu-background-color='rgba(32,32,34,0.496667)'
menu-border-color='rgba(60,60,60,0.596667)'
menu-button-appearance='Icon'
menu-button-icon='resource:///org/gnome/shell/extensions/arcmenu/icons/scalable/actions/distro-zorin-symbolic.svg'
menu-button-icon-size=22
menu-layout='Eleven'
multi-lined-labels=true
override-menu-theme=true
prefs-visible-page=0
quicklinks-item-icon-size='Default'
recently-installed-apps=['winetricks.desktop', 'com.protonvpn.www.desktop']
runner-show-settings-button=true
scrollbars-visible=true
scrollview-fade-effect=true
search-entry-border-radius=(true, 25)
show-activities-button=true
show-tooltips=true
update-notifier-project-version=70
EOF

    gnome-extensions disable zorin-menu@zorinos.com
    echo "Configurações de Extensões importadas com sucesso!"
}

# ==============================================================================
# 2. CATALOGO DE APPS E FUNCAO DE INSTALACAO
# ==============================================================================

APPS_APT=(
    "git" "curl" "wget" "python3-pip" "build-essential" "dbus-x11"
    "gamemode"      # GameMode
    "gnome-tweaks"  # GNOME Tweaks
    "golang-go"     # Linguagem Go
    "php-cli"       # Linguagem PHP (Terminal/CLI)
)

FLATPAK_PERSONAL_SECURITY=(
    "com.bitwarden.desktop"             # Gerenciador de Senhas Bitwarden
    "com.protonvpn.www"                 # VPN Proton
    "io.ente.auth"                      # Autenticação 2FA
    "com.github.tchx84.Flatseal"        # Flatseal (Gerenciador de Permissoes Flatpak)
)

FLATPAK_UTILS=(
    "com.mattjakeman.ExtensionManager"  # Gnome Extensions Manager
    "org.openrgb.OpenRGB"               # OpenRGB
    "io.github.jeffshee.Hidamari"       # Wallpaper Animado
)

FLATPAK_DEV=(
    "com.visualstudio.code"             # VSCode
    "com.google.AndroidStudio"          # Android Studio
    "cc.arduino.IDE2"                   # Arduino IDE 2
    "org.onlyoffice.desktopeditors"     # OnlyOffice
)

FLATPAK_LAZER=(
    "com.spotify.Client"                # Spotify
    "com.discordapp.Discord"            # Discord
    "com.valvesoftware.Steam"           # Steam
    "net.lutris.Lutris"                 # Lutris
    "com.heroicgameslauncher.hgl"       # Heroic Games Launcher
    "ru.linux_gaming.PortProton"        # Proton GE
)

instalar_categoria_flatpak() {
    local NOME_CAT="$1"
    shift
    local APPS=("$@")
    echo -e "${CYAN}>>> Instalando categoria: [ $NOME_CAT ]...${NC}"
    for app in "${APPS[@]}"; do
        if flatpak list | grep -q "$app"; then
            echo -e "${GREEN}[OK] $app ja esta instalado.${NC}"
        else
            flatpak install flathub "$app" -y --noninteractive
        fi
    done
}

# ==============================================================================
# 3. MENU PRINCIPAL - ESCOLHA DE MODOS (MINIMO, COMPLETO, PERSONALIZADO)
# ==============================================================================

verificar_timeshift

# Prepara Flatpak e pacotes APT base para todos os modos
sudo apt install -y "${APPS_APT[@]}"
if ! command -v flatpak &> /dev/null; then sudo apt install flatpak -y; fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo ""
echo -e "${CYAN}========================================================${NC}"
echo -e "${CYAN}         ESCOLHA O MODO DE INSTALACAO DO SETUP          ${NC}"
echo -e "${CYAN}========================================================${NC}"
echo -e "${YELLOW}[1] MODO MINIMO       ${NC} -> Apenas Seguranca, DNS/Firewall e Utilitarios."
echo -e "${YELLOW}[2] MODO COMPLETO     ${NC} -> Instala TUDO (Apps de Lazer/Dev + Todas Customizacoes)."
echo -e "${YELLOW}[3] MODO PERSONALIZADO${NC} -> Abre janela grafica (Zenity) para escolher itens um por um."
echo -e "${CYAN}========================================================${NC}"

read -p ">>> Digite o modo desejado [1, 2 ou 3]: " MODO_ESCOLHIDO

case $MODO_ESCOLHIDO in
    1)
        echo -e "${GREEN}>>> Executando MODO MINIMO...${NC}"
        limpar_bloatware
        configurar_seguranca_dns
        configurar_atualizacoes_repos
        instalar_categoria_flatpak "SEGURANCA & PRIVACIDADE" "${FLATPAK_PERSONAL_SECURITY[@]}"
        ;;
    2)
        echo -e "${GREEN}>>> Executando MODO COMPLETO (Sua Fortaleza Digital)...${NC}"
        limpar_bloatware
        configurar_seguranca_dns
        configurar_atualizacoes_repos
        configurar_hardware_grub
        configurar_webapps
        configurar_stack_dev_cybersec
        configurar_visual_gnome
        configurar_wallpapers_hidamari
        configurar_conky
        configurar_extensoes_gnome
        
        instalar_categoria_flatpak "SEGURANCA & PRIVACIDADE" "${FLATPAK_PERSONAL_SECURITY[@]}"
        instalar_categoria_flatpak "UTILITARIOS DO SISTEMA" "${FLATPAK_UTILS[@]}"
        instalar_categoria_flatpak "DESENVOLVIMENTO & PRODUTIVIDADE" "${FLATPAK_DEV[@]}"
        instalar_categoria_flatpak "LAZER & JOGOS" "${FLATPAK_LAZER[@]}"
        ;;
    3)
        echo -e "${GREEN}>>> Executando MODO PERSONALIZADO...${NC}"
        if ! command -v zenity &> /dev/null; then sudo apt install zenity -y; fi

        # --- SELECAO DE APLICATIVOS (Zenity) ---
        TODOS_APPS=("${FLATPAK_PERSONAL_SECURITY[@]}" "${FLATPAK_UTILS[@]}" "${FLATPAK_DEV[@]}" "${FLATPAK_LAZER[@]}")
        ZENITY_LIST_APPS=()
        for app in "${TODOS_APPS[@]}"; do ZENITY_LIST_APPS+=(FALSE "$app"); done

        APPS_SELECIONADOS=$(zenity --list \
            --title="Modo Personalizado - Selecao de Apps" \
            --text="Marque quais aplicativos deseja instalar:" \
            --checklist --column="Instalar?" --column="ID do Aplicativo (Flathub)" \
            --width=500 --height=450 --separator=" " "${ZENITY_LIST_APPS[@]}")

        if [ -n "$APPS_SELECIONADOS" ]; then
            read -ra APPS_PARA_INSTALAR <<< "$APPS_SELECIONADOS"
            instalar_categoria_flatpak "CUSTOMIZADO" "${APPS_PARA_INSTALAR[@]}"
        fi

        # --- SELECAO DE CONFIGURACOES DO SISTEMA (Zenity) ---
        OPCOES_SISTEMA=(
            TRUE "1. Limpar Bloatware (Remover LibreOffice, Brasero, Clima, etc)"
            TRUE "2. Seguranca e Privacidade (Firewall UFW, DNS Cloudflare, Limpeza Auto)"
            TRUE "3. Atualizacoes Automaticas e Mirrors Brasil"
            TRUE "4. Drivers de Hardware (CPU/GPU) e Tema GRUB Vimix"
            TRUE "5. WebApps Isolados (TryHackMe, HackTheBox, Notion, HackingClub)"
            TRUE "6. Visual GNOME Base (Tema Escuro ZorinBlue, Relogio, Barra Transparente)"
            TRUE "7. Efeitos 3D e Wallpapers (Alt+Tab 3D, Cubo, Animacao Hidamari)"
            TRUE "8. Monitoramento Conky (Widget Gotham no Desktop)"
            TRUE "9. Extensoes Gnome (ArcMenu Eleven + Blur My Shell)"
            TRUE "10. Stack Dev & CyberSec (Docker, Nmap, Wireshark, SQLMap, NVM, SDKMAN)"
        )

        AJUSTES_SELECIONADOS=$(zenity --list \
            --title="Modo Personalizado - Customizacoes do Sistema" \
            --text="Marque as configuracoes e otimizacoes que deseja aplicar:" \
            --checklist --column="Aplicar?" --column="Configuracao / Modulo" \
            --width=650 --height=450 --separator="|" "${OPCOES_SISTEMA[@]}")

        if [ -n "$AJUSTES_SELECIONADOS" ]; then
            if [[ "$AJUSTES_SELECIONADOS" == *"1. Limpar"* ]]; then limpar_bloatware; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"2. Seguranca"* ]]; then configurar_seguranca_dns; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"3. Atualizacoes"* ]]; then configurar_atualizacoes_repos; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"4. Drivers"* ]]; then configurar_hardware_grub; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"5. WebApps"* ]]; then configurar_webapps; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"6. Visual"* ]]; then configurar_visual_gnome; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"7. Efeitos"* ]]; then configurar_wallpapers_hidamari; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"8. Monitoramento"* ]]; then configurar_conky; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"9. Extensoes"* ]]; then configurar_extensoes_gnome; fi
            if [[ "$AJUSTES_SELECIONADOS" == *"10. Stack Dev"* ]]; then configurar_stack_dev_cybersec; fi
        fi
        ;;
    *)
        echo -e "${RED}Opcao invalida! Instalando apenas o Mínimo de Seguranca...${NC}"
        configurar_seguranca_dns
        instalar_categoria_flatpak "UTILITARIOS" "${FLATPAK_UTILS[@]}"
        ;;
esac

# ==============================================================================
# 4. REGRAS OPENRGB E FINALIZACAO
# ==============================================================================
echo -e "${YELLOW}>>> Configurando permissoes de hardware para o OpenRGB...${NC}"
curl -fsSL https://openrgb.org/releases/release_0.9/60-openrgb.rules | sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger

# ==============================================================================
# LIMPEZA PROFUNDA E DEFINITIVA POS-SETUP
# ==============================================================================
echo -e "${YELLOW}>>> Realizando limpeza profunda de pacotes orfaos, cache e runtimes...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
flatpak uninstall --unused -y

echo -e "${GREEN}>>> SETUP CONCLUIDO COM SUCESSO!${NC}"
echo "O sistema reiniciara a interface grafica em 5 segundos..."
sleep 5

busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting...")' 2>/dev/null

echo -e "${YELLOW}>>> LEMBRETES MANUAIS:${NC}"
echo "- HIDAMARI: Selecione 'Iniciar com o computador' e ative a opcao no menu."
echo "- CONKY: Ative 'Run Conky at system startup' nas configuracoes do Conky Manager."
echo "- Para iniciar OpenRGB minimizado: flatpak run org.openrgb.OpenRGB --startminimized &"
echo -e "${YELLOW}IMPORTANTE: Faca LOGOFF e LOGIN para aplicar todas as mudancas visuais.${NC}"