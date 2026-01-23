#!/bin/bash

# ==============================================================================
# .SYNOPSIS
#    Script de Setup Automático - Perfil CyberSec & Dev (Versão Linux Mint)
#    Autor: Adaptado para Bash
#    
# .DESCRIPTION
#    Instala softwares via APT e FLATPAK e configura o ambiente Cinnamon.
#    ATENÇÃO: Requer senha de ROOT (sudo).
# ==============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}      SETUP AUTOMATICO - LINUX MINT (CyberSec & Dev)            ${NC}"
echo -e "${CYAN}================================================================${NC}"

# ==============================================================================
# 🔒 VERIFICAÇÃO DE ROOT
# ==============================================================================
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}POR FAVOR, EXECUTE COMO ROOT (sudo ./seu_script.sh)${NC}"
  exit
fi

# ==============================================================================
# 📸 SNAPSHOT DO SISTEMA (TIMESHIFT)
# ==============================================================================
echo -e "\n${Magenta}>>> Criando Ponto de Restauracao (Timeshift)...${NC}"
if command -v timeshift &> /dev/null; then
    timeshift --create --comments "Antes do Setup Automatico" --tags D
    echo -e "${GREEN}Snapshot criado com sucesso.${NC}"
else
    echo -e "${YELLOW}Timeshift nao encontrado. Pulando backup.${NC}"
fi

# ==============================================================================
# 📦 ATUALIZAÇÃO DO SISTEMA E DEPENDÊNCIAS
# ==============================================================================
echo -e "\n${BLUE}>>> Atualizando repositorios e sistema...${NC}"
apt update && apt upgrade -y
apt install -y curl wget apt-transport-https software-properties-common git build-essential

# Habilitar Flatpak (caso não esteja)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ==============================================================================
# 📝 LISTAS DE APLICATIVOS
# ==============================================================================

# --- PREPARAÇÃO DE REPOSITÓRIOS EXTERNOS (Brave, VSCode, etc) ---
echo -e "\n${YELLOW}>>> Adicionando repositorios externos...${NC}"

# Brave Browser
if ! command -v brave-browser &> /dev/null; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
fi

# VS Code
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
fi

apt update -qq

# --- LISTA APT (Nativos do sistema) ---
APPS_APT=(
    "brave-browser"          # Navegador
    "code"                   # VS Code
    "git"                    # Git
    "python3-full"           # Python
    "python3-pip"            # PIP
    "vlc"                    # Player Video
    "virtualbox"             # Virtualização
    "nmap"                   # Ferramenta CyberSec Básica
    "net-tools"              # Ifconfig, etc
    "wireshark"              # Análise de Rede
    "htop"                   # Monitor de sistema
)

# --- LISTA FLATPAK (Apps isolados/Lazer/Recentes) ---
# Formato: ID do aplicativo no Flathub
APPS_FLATPAK=(
    "com.bitwarden.desktop"         # Bitwarden
    "com.google.AndroidStudio"      # Android Studio
    "org.onlyoffice.desktopeditors" # OnlyOffice (Substituto do MS Office)
    "com.valvesoftware.Steam"       # Steam
    "com.spotify.Client"            # Spotify
    "com.discordapp.Discord"        # Discord
    "org.openrgb.OpenRGB"           # OpenRGB (Substituto do SignalRGB)
    "io.github.shiftey.Desktop"     # GitHub Desktop (Opcional)
)

# ==============================================================================
# ⚙️ LÓGICA DE INSTALAÇÃO
# ==============================================================================

echo -e "\n${CYAN}>>> Instalando Aplicativos Nativos (APT)...${NC}"
for app in "${APPS_APT[@]}"; do
    if dpkg -l | grep -q "^ii  $app "; then
        echo -e "${GREEN}[OK] $app ja instalado.${NC}"
    else
        echo -e "${YELLOW}Instalando $app...${NC}"
        apt install -y "$app"
    fi
done

echo -e "\n${CYAN}>>> Instalando Aplicativos Flatpak (Hub)...${NC}"
for app in "${APPS_FLATPAK[@]}"; do
    if flatpak list | grep -q "$app"; then
        echo -e "${GREEN}[OK] $app ja instalado.${NC}"
    else
        echo -e "${YELLOW}Instalando $app...${NC}"
        flatpak install flathub "$app" -y
    fi
done

# ==============================================================================
# 📚 OFFICE (Alternativa Linux)
# ==============================================================================
echo -e "\n${CYAN}>>> Configurando Suite Office...${NC}"
echo -e "Nota: O Microsoft Office nao roda nativamente no Linux."
echo -e "Instalamos o ${GREEN}OnlyOffice${NC} e o ${GREEN}LibreOffice${NC}."
# Garantir LibreOffice (padrão Mint)
apt install -y libreoffice

# ==============================================================================
# 🛡️ PROTEÇÃO DE REDE: DNS CLOUDFLARE (Systemd-Resolved)
# ==============================================================================
echo -e "\n${Magenta}>>> Configurando DNS Cloudflare (1.1.1.1)...${NC}"

# Backup do resolv.conf original
cp /etc/resolv.conf /etc/resolv.conf.bak

# Configuração simples via systemd (funciona na maioria das distros modernas)
# Nota: O Linux Mint as vezes usa NetworkManager puro. Vamos forçar no NetworkManager.

NM_CONN=$(nmcli -t -f UUID con show --active | head -n1)
if [ -n "$NM_CONN" ]; then
    echo -e "${YELLOW}Aplicando DNS na conexao ativa...${NC}"
    nmcli con mod "$NM_CONN" ipv4.dns "1.1.1.1 1.0.0.1"
    nmcli con mod "$NM_CONN" ipv4.ignore-auto-dns yes
    nmcli con up "$NM_CONN"
    echo -e "${GREEN}DNS Configurado.${NC}"
else
    echo -e "${RED}Nenhuma conexao ativa encontrada para configurar DNS.${NC}"
fi

# ==============================================================================
# 🛠️ CONFIGURAÇÕES DO LINUX MINT (Visual & Sistema)
# ==============================================================================
echo -e "\n${Magenta}>>> Aplicando configuracoes do Cinnamon (Visual)...${NC}"

# As configurações do Cinnamon são por usuário, não root.
# Precisamos descobrir o usuário real que chamou o sudo.
REAL_USER=$(logname)

# Função para rodar gsettings como o usuário logado
user_gsettings() {
    sudo -u "$REAL_USER" dbus-launch gsettings set "$@"
}

echo -e "Configurando Tema Escuro..."
# Define preferência por modo escuro (Padrão Mint-Y-Dark)
user_gsettings org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
user_gsettings org.cinnamon.desktop.interface icon-theme 'Mint-Y'
user_gsettings org.x.apps.portal color-scheme 'prefer-dark'

echo -e "Configurando Area de Trabalho (Limpando icones)..."
# Desativa ícones na área de trabalho (equivalente ao HideIcons)
user_gsettings org.nemo.desktop computer-icon-visible false
user_gsettings org.nemo.desktop home-icon-visible false
user_gsettings org.nemo.desktop trash-icon-visible false
user_gsettings org.nemo.desktop volumes-visible false

echo -e "Configurando Firewall (UFW)..."
ufw enable
ufw default deny incoming
ufw default allow outgoing
echo -e "${GREEN}Firewall Ativado.${NC}"

# ==============================================================================
# 🔄 AGENDAMENTO DE ATUALIZAÇÃO (CRON)
# ==============================================================================
echo -e "\n${Magenta}>>> Criando tarefa de atualizacao semanal (Cron)...${NC}"

CRON_FILE="/etc/cron.weekly/autoupdate-custom"

cat <<EOF > "$CRON_FILE"
#!/bin/bash
# Script de Atualizacao Automatica (APT + Flatpak)
apt update && apt upgrade -y
apt autoremove -y
flatpak update -y
EOF

chmod +x "$CRON_FILE"
echo -e "${GREEN}Tarefa agendada criada em $CRON_FILE${NC}"

# ==============================================================================
# 🧹 LIMPEZA FINAL
# ==============================================================================
echo -e "\n${CYAN}>>> Limpando cache...${NC}"
apt autoremove -y
apt clean

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}      SETUP CONCLUIDO COM SUCESSO!                              ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Nota: Para o Docker, recomenda-se instalar manualmente seguindo a doc oficial."
echo -e "Reinicie o computador para aplicar todas as mudancas visuais."
echo -e "Pressione Enter para sair..."
read
