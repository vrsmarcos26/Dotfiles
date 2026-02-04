#!/bin/bash
# AUTOR: vrsmarcos26
# FUNÇÃO: Instalar Apps, Restaurar Configs e Aplicar Temas

# --- LISTAS DE APPS (FÁCIL DE EDITAR) ---

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

# Apps Nativos (.deb/apt)
APPS_APT=(
    "git" "curl" "wget" "python3-pip" "build-essential" "dbus-x11"
    "virtualbox"              # VirtualBox
    "gamemode"                # GameMode
    "conky-all"               # Conky
    "gnome-tweaks"
    "timeshift"               # REVERSÃO/BACKUP
)

# Apps Flatpak (Lojas)
APPS_FLATPAK=(

    # Segurança e Privacidade
    "com.brave.Browser"                 # Brave
    "com.bitwarden.desktop"             # Bitwarden
    "io.ente.auth"                      # Ente Auth

    # Personalização e Utilitários
    "com.mattjakeman.ExtensionManager"  # Gnome Extension Manager
    "org.openrgb.OpenRGB"               # OpenRGB
    "io.github.jeffshee.Hidamari"       # Hidamari
    
    # Jogos e Lazeres
    "net.lutris.Lutris"                 # Lutris
    "com.valvesoftware.Steam"           # Steam
    "com.heroicgameslauncher.hgl"       # Heroic
    "com.spotify.Client"                # Spotify
    "com.discordapp.Discord"            # Discord

    # Dev
    "com.google.AndroidStudio"          # Android Studio
    "com.visualstudio.code"             # VS Code
    "cc.arduino.IDE2"                   # Arduino IDE 2

    # Cibersegurança e Hacking
)

# --- INÍCIO DO SETUP ---

BASE_DIR=$(dirname "$(readlink -f "$0")")
CONFIG_DIR="$BASE_DIR/configs"

echo -e "${CYAN}>>> INICIANDO SETUP ZORIN OS...${NC}"

# ==============================================================================
# 🛡️ 1. SEGURANÇA E PREPARAÇÃO
# ==============================================================================
echo "Instalando TimeShift para garantir reversão..."
if ! command -v timeshift &> /dev/null; then
    echo "Instalando TimeShift..."
    sudo apt update && sudo apt upgrade -y && sudo apt install timeshift -y

fi

clear
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
    read -p "Você configurou o TimeShift e criou o Snapshot inicial? (DIGITE 'SIM' PARA CONTINUAR): " sn
    case $sn in
        [Ss][Ii][Mm]* ) break;;
        * ) echo "Por favor, configure o TimeShift primeiro.";;
    esac
done

echo ">>> Continuando instalação..."

# ==============================================================================
# 🧠 2. DETECÇÃO E INSTALAÇÃO DE HARDWARE (A MÁGICA)
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

# ==============================================================================
# 2.1 INSTALAÇÃO DE APPS
# ==============================================================================
echo -e "${CYAN}>>> Instalando Apps APT...${NC}"

for app in "${APPS_APT[@]}"; do sudo apt install -y "$app"; done

echo ">>> Instalando Apps Flatpak..."
if ! command -v flatpak &> /dev/null; then sudo apt install flatpak -y; fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
for app in "${APPS_FLATPAK[@]}"; do flatpak install flathub "$app" -y; done

# Fastfetch (Geralmente precisa baixar o .deb ou via brew, mas vamos tentar repo padrão ou ppa)
# Adicionando PPA para fastfetch se necessário, ou baixando direto
if ! command -v fastfetch &> /dev/null; then
    echo "Baixando Fastfetch oficial (GitHub)..."
    TEMP_DEB="fastfetch.deb"
    wget -O "$TEMP_DEB" "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"
    # Usa dpkg -i para instalar arquivo local e apt -f install para dependências
    sudo dpkg -i "$TEMP_DEB"
    sudo apt install -f -y
    rm "$TEMP_DEB"
fi

# ==============================================================================
# 3. RESTAURAÇÃO DE CONFIGURAÇÕES
# ==============================================================================
echo -e "${CYAN}>>> Restaurando Configurações...${NC}"

echo "Ativando extensões..."
gnome-extensions disable dash-to-panel@jderose9.github.com 2>/dev/null
gnome-extensions enable zorin-taskbar@zorinos.com 2>/dev/null
gnome-extensions enable zorin-menu@zorinos.com 2>/dev/null
gnome-extensions enable arcmenu@arcmenu.com 2>/dev/null
gnome-extensions enable blur-my-shell@aunetx 2>/dev/null
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null

# Dconf (Geral)
if [ -f "$CONFIG_DIR/dconf/user-settings.conf" ]; then
    echo "Restaurando Dconf..."
    # Tenta método direto primeiro (funciona em 99% dos casos no Zorin 17+)
    #dconf load / < "$CONFIG_DIR/dconf/user-settings.conf" || \
    # Se falhar, tenta via dbus-launch explicitamente
    dbus-launch dconf load / < "$CONFIG_DIR/dconf/user-settings.conf"
    
    echo "Dconf carregado."
fi

echo ">>> Forçando estilo 'Floating Dock' (Correção de Monitor)..."

SCHEMA="org.gnome.shell.extensions.dash-to-panel"

dconf write /$SCHEMA/transparency-mode "'FIXED'"
dconf write /$SCHEMA/panel-opacity 0
# Garante que a cor de fundo não interfira
dconf write /$SCHEMA/panel-element-background-opacity 0

# -- ESTILO FLUTUANTE (Seu Print: Margin 4px, Radius 25px) --
# Nota: O Zorin pode usar chaves ligeiramente diferentes para margem dependendo da versão,
# mas estas são as padrão que controlam o encapsulamento.
dconf write /$SCHEMA/panel-element-padding 4
dconf write /$SCHEMA/panel-corner-radius 25

# -- POSIÇÃO DOS ÍCONES (Seu Print: Centralizado) --
dconf write /$SCHEMA/taskbar-position "'CENTEREDMONITOR'"
dconf write /$SCHEMA/panel-lengths "'{\"0\":100}'" # Mantém 100% de largura, mas a margem cria o efeito flutuante

# Startup & WebApps
mkdir -p "$HOME/.config/autostart" "$HOME/.local/share/applications"
[ -d "$CONFIG_DIR/startup" ] && cp -r "$CONFIG_DIR/startup/"* "$HOME/.config/autostart/"
[ -d "$CONFIG_DIR/webapps" ] && cp -r "$CONFIG_DIR/webapps/"* "$HOME/.local/share/applications/"

# Configs Específicas (Conky, Code, etc)
if [ -d "$CONFIG_DIR/app-configs/conky" ]; then
    mkdir -p "$HOME/.conky"
    cp -r "$CONFIG_DIR/app-configs/conky"* "$HOME/.conky/"
if
[ -f "$CONFIG_DIR/app-configs/.conkyrc" ] && cp "$CONFIG_DIR/app-configs/.conkyrc" "$HOME/.conkyrc"

if [ -d "$CONFIG_DIR/app-configs/hidamari" ]; then
    DEST="$HOME/.var/app/io.github.jeffshee.Hidamari/config/hidamari"
    mkdir -p "$DEST"
    cp -r "$CONFIG_DIR/app-configs/hidamari"* "$DEST/"
fi

[ -f "$CONFIG_DIR/terminal/.bashrc" ] && cp "$CONFIG_DIR/terminal/.bashrc"* "$HOME/.bashrc"

# OpenRGB Udev Rules (Para não pedir senha toda hora, mas rodar como root se precisar)
# Baixa as regras oficiais para permitir controle de hardware
curl -fsSL https://openrgb.org/releases/release_0.9/60-openrgb.rules | sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger

# ==============================================================================
# 4. HACK CSS & FINALIZAÇÃO
# ==============================================================================
TTHEME_FILE="/usr/share/themes/ZorinBlue-Dark/gnome-shell/gnome-shell.css"
# Fallback se não achar no caminho específico
if [ ! -f "$THEME_FILE" ]; then THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"; fi

CUSTOM_CSS="
/* --- CUSTOMIZACAO DO MARCOS --- */
.popup-menu-content {
    background-color: rgba(34, 43, 48, 0.45) !important;
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.4);
}
#mode-dark .popup-menu-content, 
.popup-menu-content.panel-menu {
     background-color: rgba(34, 43, 48, 0.45) !important;
}
"

if [ -f "$THEME_FILE" ]; then
    if ! grep -q "CUSTOMIZACAO DO MARCOS" "$THEME_FILE"; then
        echo "Aplicando Transparência no Tema..."
        sudo cp "$THEME_FILE" "$THEME_FILE.bak"
        # Adiciona o CSS no final do arquivo
        echo -e "$CUSTOM_CSS" | sudo tee -a "$THEME_FILE" > /dev/null
    fi
fi

# ==============================================================================
# 5. RESTAURAÇÃO DO WALLPAPER (NOVO)
# ==============================================================================
echo ">>> Aplicando Wallpaper..."
WALL_SRC="$CONFIG_DIR/current_wallpaper.png"
WALL_DEST="$HOME/Pictures/current_wallpaper.png"

if [ -f "$WALL_SRC" ]; then
    # Garante que a pasta existe
    mkdir -p "$HOME/Pictures"
    
    # Copia a imagem
    cp "$WALL_SRC" "$WALL_DEST"
    
    # Aplica no GNOME (Modo Claro e Escuro)
    gsettings set org.gnome.desktop.background picture-uri "file://$WALL_DEST"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALL_DEST"
    
    # Aplica na Tela de Bloqueio (Opcional, mas recomendado)
    # gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALL_DEST"
    
    echo "Wallpaper definido e salvo em $WALL_DEST"
else
    echo "Nenhum backup de wallpaper encontrado."
fi

# ==============================================================================
# 6. CONFIGURAÇÃO DO GRUB (TEMA EM /usr/share)
# ==============================================================================
echo -e "${CYAN}>>> Configurando Tema do GRUB...${NC}"

GRUB_BACKUP="$CONFIG_DIR/grub"
SYSTEM_THEME_DIR="/usr/share/grub/themes"

if [ -d "$GRUB_BACKUP" ]; then
    # Verifica se tem arquivos de tema (não está vazia)
    if [ "$(ls -A $GRUB_BACKUP)" ]; then
        echo "Restaurando temas para $SYSTEM_THEME_DIR..."
        sudo mkdir -p "$SYSTEM_THEME_DIR"
        sudo cp -r "$GRUB_BACKUP/"* "$SYSTEM_THEME_DIR/"

        # Pega o nome do primeiro tema encontrado que não seja arquivo solto
        THEME_NAME=$(ls -d "$GRUB_BACKUP"/*/ | head -n 1 | xargs basename 2>/dev/null)
        
        if [ ! -z "$THEME_NAME" ] && [ -f "$SYSTEM_THEME_DIR/$THEME_NAME/theme.txt" ]; then
            echo "Ativando tema: $THEME_NAME"
            
            # Ajusta o /etc/default/grub
            sudo sed -i 's/^GRUB_THEME=/#GRUB_THEME=/' /etc/default/grub
            # Garante que a linha GRUB_TERMINAL_OUTPUT="console" esteja comentada para gráfico funcionar
            sudo sed -i 's/^GRUB_TERMINAL_OUTPUT="console"/#GRUB_TERMINAL_OUTPUT="console"/' /etc/default/grub
            
            echo "GRUB_THEME=\"$SYSTEM_THEME_DIR/$THEME_NAME/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null
            
            echo "Atualizando GRUB..."
            sudo update-grub
        else
            echo "Tema copiado, mas nenhum 'theme.txt' válido encontrado para ativar automaticamente."
        fi
    else
        echo "Pasta de backup do GRUB está vazia."
    fi
fi

echo -e "${GREEN}>>> SETUP CONCLUÍDO! REINICIE O SISTEMA PARA APLICAR DRIVERS E TEMA.${NC}"
