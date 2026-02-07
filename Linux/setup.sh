#!/bin/bash
# AUTOR: vrsmarcos26
# FUNÇÃO: Instalar Apps, Restaurar Configs e Aplicar Temas

# --- LISTAS DE APPS (FÁCIL DE EDITAR) ---

# PARA TESTES EM VM, FAÇA O SEGUINTE AJUSTE:
# COMENTE A SESSÃO TIMESHIFT (LINHAS 42-70)
# COMENTE A SESSÃO DE GPU
# COMENTE EFEITOS 3D
# COMENTE GRUB

# --- TRAVA DE SEGURANÇA: NÃO RODAR COMO ROOT ---
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}ERRO: Não rode este script como sudo/root!${NC}"
  echo "Rode apenas: ./setup.sh"
  echo "O script pedirá a senha quando necessário."
  exit 1
fi

# --- CORES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- INÍCIO DO SETUP ---
echo -e "${CYAN}>>> INICIANDO SETUP ZORIN OS...${NC}"

# ==============================================================================
# ⚠️ 0. Backup de Segurança com TimeShift
# ==============================================================================

echo -e "${YELLOW}>>> Atualizando ${NC}"
sudo apt update && sudo apt upgrade -y

# Instalando TimeShift
echo -e "${YELLOW}Instalando TimeShift para garantir reversão...${NC}"
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

: << 'COMENTARIO'
while true; do
    read -p "Você configurou o TimeShift e criou o Snapshot inicial? (DIGITE 'SIM' PARA CONTINUAR): " sn
    case $sn in
        [Ss][Ii][Mm]* ) break;;
        * ) echo "Por favor, configure o TimeShift primeiro.";;
    esac
done
COMENTARIO

echo ">>> Continuando instalação..."

# ==============================================================================
# 🛡️ 1. SEGURANÇA E PREPARAÇÃO
# ==============================================================================

echo -e "${YELLOW}>>> Atualizando ${NC}"
sudo apt update && sudo apt upgrade -y

# Firewall
echo -e "${YELLOW}Ativando FIrewall...${NC}"
if ! command -v ufw &> /dev/null; then
    echo "Instalando Firewall..."
    sudo apt install ufw -y && sudo apt install gufw -y
elif sudo ufw status | grep -q "Status: inactive"; then
    echo "Ativando Firewall..."
    sudo ufw enable
else
    echo Configurando Firewall...
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    echo -e "${GREEN}Firewall já está ativo e configurado.${NC}"
fi

# Proteção de Tela (Notificações na tela de bloqueio)
echo -e "${YELLOW}Verificando proteção de tela...${NC}"
if ! gsettings get org.gnome.desktop.notifications show-in-lock-screen | grep -q "true"; then
    echo "Removendo notificação da tela de Bloqueio ..."
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
else
    echo -e "${GREEN}Proteção de tela já está ativa.${NC}"
fi

# Localização
echo -e "${YELLOW}Verificando localização...${NC}"
if gsettings get org.gnome.system.location enabled | grep -q "true"; then
    echo "Desativando localização..."
    gsettings set org.gnome.system.location enabled false
else
    echo -e "${GREEN}Localização já está desativada.${NC}"
fi

# Historico e Limpeza Automática
echo -e "${YELLOW}Configurando limpeza automática...${NC}"
if gsettings get org.gnome.desktop.privacy remember-recent-files | grep -q "false"; then
    echo "Ativando histórico"
    gsettings set org.gnome.desktop.privacy remember-recent-files true
else
  echo "Histórico já está ativo. Deixando ele para sempre"
  gsettings set org.gnome.desktop.privacy recent-files-max-age -1
fi

if gsettings get org.gnome.desktop.privacy remove-old-temp-files | grep -q "false" || gsettings get org.gnome.desktop.privacy remove-old-trash-files | grep -q "false"; then
    echo "Ativando remoção automática de arquivos..."
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
else
    echo "Remoção automática de arquivos já ativada. COnfigurando para 30 dias..."
    gsettings set org.gnome.desktop.privacy old-files-age 30
fi

echo -e "${GREEN}Configurações de Limpeza e Histórico ativadas.${NC}"

# Aplicando DNS Seguro (Cloudflare)
echo -e "${YELLOW}Configurando DNS seguro (Cloudflare)...${NC}"

# 1. Descobre a interface física que tem a rota para a internet (Ex: wlan0, eth0)
DEFAULT_DEV=$(ip route get 1.1.1.1 | sed -n 's/.*dev \([^\ ]*\).*/\1/p' | head -n1)

if [ -n "$DEFAULT_DEV" ]; then
    # 2. Descobre o NOME da conexão do NetworkManager associada a essa interface
    # O comando abaixo lista NOME:DEVICE, filtra pelo device achado e corta para pegar só o NOME
    CONN=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":${DEFAULT_DEV}$" | cut -d: -f1 | head -n1)

    if [ -n "$CONN" ]; then
        echo "Interface principal detectada: $DEFAULT_DEV"
        echo "Configurando DNS para a conexão: $CONN"
        
        # Configura o DNS
        sudo nmcli con mod "$CONN" ipv4.dns "1.1.1.1 1.0.0.1"
        sudo nmcli con mod "$CONN" ipv4.ignore-auto-dns yes
        
        # Reinicia a conexão para aplicar (sem derrubar tudo abruptamente)
        echo "Aplicando alterações..."
        sudo nmcli con up "$CONN"
        
        echo -e "${GREEN}DNS seguro configurado na conexão principal.${NC}"
    else
        echo -e "${RED}Erro: Não foi possível identificar o nome da conexão para a interface $DEFAULT_DEV.${NC}"
    fi
else
    echo -e "${RED}Nenhuma rota para a internet encontrada. Pulei a configuração de DNS.${NC}"
fi

# ===========================================================================
# 2. ATUALIZAÇÕES E AUTOMATIZAÇÃO
# ===========================================================================

# Configurando Atualizações Automáticas
echo -e "${YELLOW}Configurando atualizações automáticas...${NC}"

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

if grep -q "http://br.archive.ubuntu.com" /etc/apt/sources.list; then
    echo -e "${GREEN}Repositórios do Brasil já estão configurados.${NC}"
else
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

: << 'COMENTARIO'
# ==============================================================================
# 🧠 2.1 DETECÇÃO E INSTALAÇÃO DE HARDWARE (A MÁGICA)
# ==============================================================================
echo -e "${YELLOW}>>> Analisando Hardware...${NC}"

# --- DETECÇÃO DE PROCESSADOR (CPU) ---
CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}')

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

# --- DETECÇÃO DE PLACA DE VÍDEO (GPU) ---
# lspci lista o hardware, grep filtra VGA/3D controller
GPU_INFO=$(lspci | grep -i -E "vga|3d")

echo -e "${YELLOW}GPU Encontrada: $GPU_INFO${NC}"

if echo "$GPU_INFO" | grep -qi "nvidia"; then
    echo -e "${GREEN}>>> Placa NVIDIA Detectada!${NC}"
    echo "Adicionando repositório de drivers gráficos (PPA) para versão mais recente..."
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update
    
    echo "Instalando drivers proprietários recomendados..."
    # O comando ubuntu-drivers autoinstall escolhe a melhor versão estável automaticamente
    sudo ubuntu-drivers autoinstall
    
    # Ferramentas extras
    sudo apt install -y nvidia-settings

elif echo "$GPU_INFO" | grep -qi "amd"; then
    echo -e "${GREEN}>>> Placa AMD (Radeon) Detectada!${NC}"
    echo "Instalando drivers Mesa, Vulkan e suporte a jogos..."
    # Para AMD, o driver open-source (Mesa) é o padrão e recomendado para 99% dos casos
    sudo apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 libvulkan1 mesa-utils
    
    # Opcional: Adicionar PPA Kisak para drivers Mesa mais recentes (bom para jogos novos)
    # sudo add-apt-repository ppa:kisak/kisak-mesa -y && sudo apt update && sudo apt upgrade -y

elif echo "$GPU_INFO" | grep -qi "intel"; then
    echo -e "${GREEN}>>> Gráficos Integrados Intel Detectados!${NC}"
    echo "Instalando drivers de mídia e Vulkan..."
    sudo apt install -y intel-media-driver mesa-vulkan-drivers mesa-utils
fi

COMENTARIO
# ==============================================================================
# 2. CONFIGURAÇÃO DO GRUB
# ==============================================================================

echo -e "${YELLOW}>>> Configurando GRUB...${NC}"

TEMP_GRUB="/tmp/grub-theme"
if [ -d "$TEMP_GRUB" ]; then rm -rf "$TEMP_GRUB"; fi
git clone https://github.com/vinceliuice/grub2-themes.git "$TEMP_GRUB"

echo "Instalando tema Vimix..."
cd "$TEMP_GRUB"
sudo ./install.sh -b -t vimix -s 1080p

echo "Atualizando configurações do boot..."
sudo update-grub

cd ~/Downloads/Dotfiles/Linux

echo -e "${GREEN}Tema do GRUB instalado!${NC}"

# ==============================================================================
# 2.1 Instalação de webapps
# ==============================================================================

echo -e "${YELLOW}>>> Criando Web Apps Isolados...${NC}"

ICE_ICONS="$HOME/.local/share/ice/icons"
ICE_PROFILES="$HOME/.local/share/ice/profiles"
mkdir -p "$ICE_ICONS"
mkdir -p "$ICE_PROFILES"

create_isolated_webapp() {
    NAME="$1"       # Ex: TryHackMe
    URL="$2"        # Ex: https://tryhackme.com
    ICON_FILE="$3"  # Ex: tryhackme.png (Nome do arquivo na sua pasta Icons)

    # Identifica o Navegador (Brave > Chrome > Chromium)
    if command -v brave-browser &> /dev/null; then
        BROWSER_EXEC="brave-browser"
        BROWSER_NAME="Brave Browser"
    elif command -v google-chrome &> /dev/null; then
        BROWSER_EXEC="google-chrome"
        BROWSER_NAME="Google Chrome"
    else
        BROWSER_EXEC="chromium-browser"
        BROWSER_NAME="Chromium"
    fi

    echo "Criando App Isolado: $NAME..."

    # 1. Copiar o ícone para a pasta do ICE
    if [ -f "$SOURCE_ICONS/$ICON_FILE" ]; then
        cp "$SOURCE_ICONS/$ICON_FILE" "$ICE_ICONS/$ICON_FILE"
        FINAL_ICON_PATH="$ICE_ICONS/$ICON_FILE"
    else
        echo "⚠️ Ícone $ICON_FILE não encontrado em $SOURCE_ICONS. Usando genérico."
        FINAL_ICON_PATH="web-browser" # Ícone genérico do sistema
    fi

    # 2. Definir caminho do Perfil Isolado
    PROFILE_DIR="$ICE_PROFILES/$NAME"
    
    # 3. Criar o arquivo .desktop (Baseado no seu modelo)
    DESKTOP_FILE="$HOME/.local/share/applications/WebApp-$NAME.desktop"

    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=$NAME
Comment=Web App Isolado
# O comando Mágico: --user-data-dir cria o isolamento
Exec=$BROWSER_EXEC --app="$URL" --class=WebApp-$NAME --name=WebApp-$NAME --user-data-dir=$PROFILE_DIR
Terminal=false
Type=Application
Icon=$FINAL_ICON_PATH
Categories=GTK;Network;WebBrowser;
StartupWMClass=WebApp-$NAME
StartupNotify=true
X-WebApp-Browser=$BROWSER_NAME
X-WebApp-URL=$URL
X-WebApp-Isolated=true
EOF

    chmod +x "$DESKTOP_FILE"
}

create_isolated_webapp "TryHackMe" "https://tryhackme.com"
create_isolated_webapp "Hack The Box" "https://www.hackthebox.com"
create_isolated_webapp "HackingClub" "https://app.hackingclub.com"
create_isolated_webapp "Notion" "https://notion.so"

echo -e "${GREEN}Web Apps criados na pasta de aplicações!${NC}"


# ===========================================================================
# 3. Instalando Aplicativos
# ===========================================================================

APPS_APT=(
    "git" "curl" "wget" "python3-pip" "build-essential" "dbus-x11"
    "gamemode"                # GameMode
    "gnome-tweaks"            # GNOME Tweaks

)

APPS_FLATPAK=(
    # Personalização e Utilitários
    "com.mattjakeman.ExtensionManager"  # Gnome Extension Manager
    "org.openrgb.OpenRGB"               # OpenRGB
    "io.github.jeffshee.Hidamari"       # Hidamari
    
    # Lazeres
    "com.spotify.Client"                # Spotify
    "com.discordapp.Discord"            # Discord

    # Dev
    "com.google.AndroidStudio"          # Android Studio
    "com.visualstudio.code"             # VS Code
    "cc.arduino.IDE2"                   # Arduino IDE 2
)


echo -e "${CYAN}>>> Instalando Apps APT...${NC}"

sudo apt install -y "${APPS_APT[@]}"

echo ">>> Instalando Apps Flatpak..."
if ! command -v flatpak &> /dev/null; then sudo apt install flatpak -y; fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
for app in "${APPS_FLATPAK[@]}"; do flatpak install flathub "$app" -y; done


# Instalando Aplicativos de Segurança
echo -e "${YELLOW}Instalando aplicativos de segurança...${NC}"
APPS=(
    "com.bitwarden.desktop"  # Gerenciador de senhas
    "com.protonvpn.www"      # VPN
    "io.ente.auth"           # Autenticador de 2FA
)
for app in "${APPS[@]}"; do
    if ! flatpak list | grep -q "$app"; then
        echo "Instalando $app..."
        flatpak install flathub "$app" -y
    else
        echo "$app já está instalado."
    fi
done

curl -fsSL https://openrgb.org/releases/release_0.9/60-openrgb.rules | sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger

echo -e "${GREEN}Aplicativos de segurança instalados.${NC}"

# ==============================================================================
# 4. Configuração Visual 
# ==============================================================================

echo -e "${YELLOW}>>> Configurando visual...${NC}"

# Instalando o fastfetch
echo "Instalando Fastfetch..."
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update
sudo apt install fastfetch -y

echo -e "\n# Iniciando Fastfetch\nfastfetch --logo-type kitty --logo-padding 3" | tee -a ~/.bashrc

# Modo Escuro
echo "Aplicando tema escuro..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'ZorinBlue-Dark'
gsettings set org.gnome.shell.extensions.user-theme name 'ZorinBlue-Dark'

# Volume acima de 100%
echo "Permitindo volume acima de 100%..."
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

# Horario e Data
echo "Configurando exibição de data e hora..."
# Data visivel na barra
gsettings set org.gnome.desktop.interface clock-show-date true
# Segundos desativados
gsettings set org.gnome.desktop.interface clock-show-seconds false
# Semana do ano desativada
gsettings set org.gnome.desktop.calendar show-weekdate false
# Dia da semana desativado
gsettings set org.gnome.desktop.interface clock-show-weekday false

# Ativando Efeitos Cube & Spatial Window Switcher (Alt+Tab 3D)
echo "Ativando efeitos 3D..."
# Cube
#gnome-extensions enable zorin-desktop-cube@zorinos.com
# Spatial Window Switcher
#gnome-extensions enable zorin-spatial-window-switcher@zorinos.com

# Luz Noturna
echo "Configurando Luz Noturna..."
# Ligar luz noturna automaticamente ao anoitecer
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
# automaticamente ao anoitecer
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
#Temperatura para 2700K
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2700

# Retirando icons da área de trabalho
echo "Retirando ícones da área de trabalho..."
gnome-extensions disable zorin-desktop-icons@zorinos.com

# Tecla Windows abrindo o Menu:
echo "Configurando tecla Super (Windows) para abrir o menu..."
gsettings set org.gnome.shell.extensions.zorin-menu super-hotkey true
gsettings set org.gnome.mutter overlay-key 'SUPER_L'

# Modo de energia
echo "Configurando modo de energia para Balanced..."
powerprofilesctl set balanced

# Configurando Barra de tarefas
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
# Posição da barra (BOTTOM, TOP, LEFT, RIGHT)
# gsettings set org.gnome.shell.extensions.zorin-taskbar panel-positions '{"0":"BOTTOM"}'
# Tamanho dos ícones (Pequeno = 24, Médio = 37, Grande = 40)
gsettings set org.gnome.shell.extensions.zorin-taskbar panel-sizes '{"0":37}'
# Usar 100% da barra
gsettings set org.gnome.shell.extensions.zorin-taskbar panel-lengths '{"0":100}'
# Ordem das coisas na barra
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

TTHEME_FILE="/usr/share/themes/ZorinBlue-Dark/gnome-shell/gnome-shell.css"

# # Fallback se não achar no caminho específico
if [ ! -f "$TTHEME_FILE" ]; then
    TTHEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
fi

if [ -f "$TTHEME_FILE" ]; then
    if ! grep -q "CUSTOMIZACAO DO MARCOS" "$TTHEME_FILE"; then
        echo "Aplicando Transparência no Tema..."
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
fi


# ==============================================================================
# Configuração de Wallpaper
# ==============================================================================

echo "Alterando wallpaper para modo escuro..."

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cp "$SCRIPT_DIR/Wallpapers/White/"*.png "$WALLPAPER_DIR/"
cp "$SCRIPT_DIR/Wallpapers/Vermelho/"*.png "$WALLPAPER_DIR/"

cp "$WALLPAPER_DIR/"*.png "$HOME/.local/share/backgrounds/"

gsettings set org.gnome.desktop.background picture-uri-dark "file:///$HOME/.local/share/backgrounds/white.png"

echo "Configurações de wallpaper STATICO aplicadas."

echo "Instalando Hidamari Wallpaper Changer..."
flatpak install flathub io.github.jeffshee.Hidamari -y

flatpak override --user io.github.jeffshee.Hidamari --filesystem=~/Videos

WALLPAPER_ANIMATION_DIR="$HOME/Videos/Hidamari"
mkdir -p "$WALLPAPER_ANIMATION_DIR"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cp "$SCRIPT_DIR/Wallpapers/White/"*.mp4 "$WALLPAPER_ANIMATION_DIR/"
cp "$SCRIPT_DIR/Wallpapers/Vermelho/"*.mp4 "$WALLPAPER_ANIMATION_DIR/"

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

AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat <<EOF > "$AUTOSTART_DIR/io.github.jeffshee.Hidamari.desktop"
[Desktop Entry]
Type=Application
Exec=flatpak run --command=hidamari io.github.jeffshee.Hidamari -b
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Hidamari
Comment=Start Wallpaper Animation
X-GNOME-Autostart-Delay=5
EOF

echo "Hidamari configurado! Reinicie após adicionar o vídeo."

# ==============================================================================
# CONFIGURAÇÃO CONKY
# ==============================================================================

echo -e "${YELLOW}>>> Configurando Conky...${NC}"

sudo apt install conky-all -y

THEME_DIR="$HOME/.conky/Gotham"
mkdir -p "$THEME_DIR"

cat <<'EOF' > "$THEME_DIR/Gotham"
use_xft yes
xftfont 123:size=8
xftalpha 0.1
update_interval 1
total_run_times 0

own_window yes
own_window_type normal
own_window_transparent yes
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
own_window_colour FFFFFF
own_window_argb_visual yes
own_window_argb_value 0

double_buffer yes
#minimum_size 250 5
#maximum_width 500
draw_shades no
draw_outline no
draw_borders no
draw_graph_borders no
default_color white
default_shade_color red
default_outline_color green
alignment top_left
gap_x 100
gap_y 70
no_buffers yes
uppercase no
cpu_avg_samples 2
net_avg_samples 1
override_utf8_locale yes
use_spacer yes

minimum_size 0 0
TEXT
${voffset 10}${color EAEAEA}${font GE Inspira:pixelsize=120}${time %I:%M}${font}${voffset -84}${offset 10}${color FFA300}${font GE Inspira:pixelsize=42}${time %d} ${voffset -15}${color EAEAEA}${font GE Inspira:pixelsize=22}${time %B} ${time %Y}${font}${voffset 24}${font GE Inspira:pixelsize=58}${offset -148}${time %A}${font}
${voffset 1}${offset 12}${font Ubuntu:pixelsize=12}${color FFA300}HD ${offset 9}$color${fs_free /} / ${fs_size /}${offset 30}${color FFA300}RAM ${offset 9}$color$mem / $memmax${offset 30}${color FFA300}CPU ${offset 9}$color${cpu cpu0}%
EOF

mkdir -p "$HOME/.config/autostart"

cat <<EOF > "$HOME/.config/autostart/conky.desktop"
[Desktop Entry]
Type=Application
Name=Conky Gotham
Comment=Start Conky Theme directly
# O comando abaixo espera 10s e carrega especificamente o arquivo Gotham
Exec=sh -c "sleep 10 && conky -c $THEME_DIR/Gotham"
Icon=conky
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
EOF


sudo add-apt-repository ppa:tomtomtom/conky-manager -y
sudo add-apt-repository --remove ppa:teejee2008/ppa -y
sudo apt update -y
sudo apt install conky-manager2 -y



# ==============================================================================
# Configuração de Extensões
# ==============================================================================

# Instalando extensões
echo -e "${YELLOW}>>> Instalando extensões...${NC}"

sudo apt install python3-pip git -y

if ! command -v pipx &> /dev/null; then
    echo "Instalando pipx..."
    sudo apt install pipx -y
    pipx ensurepath
fi

export PATH=$PATH:$HOME/.local/bin

if ! command -v gext &> /dev/null; then
    echo "Instalando gnome-extensions-cli via pipx..."
    pipx install gnome-extensions-cli --force
fi

echo "Baixando extensões ArcMenu e Blur My Shell..."
gext install arcmenu@arcmenu.com || true
gext install blur-my-shell@aunetx || true

# 5. Compilar schemas (Essencial para as configurações funcionarem)
glib-compile-schemas ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ 2>/dev/null
glib-compile-schemas ~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas/ 2>/dev/null


# 6. Ativar as extensões
echo "Ativando extensões..."
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable blur-my-shell@aunetx

# ==============================================================================
# BLUR MY SHELL
# ==============================================================================
# Carrega as configurações de blur (Painel, Overview, Janelas, etc)
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

# ==============================================================================
# ARCMENU
# ==============================================================================
# Carrega o layout Windows 11, ícone do Zorin e cores
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

# ==============================================================================
# 8. FINALIZAÇÃO
# ==============================================================================
echo -e "${GREEN}>>> SETUP CONCLUÍDO COM SUCESSO!${NC}"
echo "O sistema reiniciará a interface gráfica em 5 segundos..."
sleep 5

# Tenta reiniciar o Shell (Funciona no X11)
busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting...")' 2>/dev/null

echo -e "${YELLOW}>>> Lembrar de que alguns aplicativos são melhores instalados pela web e alguns precisam configurar${NC}"
echo -e "${YELLOW}IMPORTANTE: Faça LOGOFF e LOGIN para aplicar todas as mudanças visuais.${NC}"vs