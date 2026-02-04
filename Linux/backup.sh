#!/bin/bash
# AUTOR: vrsmarcos26
# FUNÇÃO: Salvar o estado atual do Zorin OS (Configs + Apps)

BASE_DIR=$(dirname "$(readlink -f "$0")")
CONFIG_DIR="$BASE_DIR/configs"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}>>> INICIANDO BACKUP...${NC}"

# ==============================================================================
# 0. VERIFICAÇÃO DE DEPENDÊNCIAS (Correção do erro "dconf not found")
# ==============================================================================
if ! command -v dconf &> /dev/null; then
    echo -e "${YELLOW}Ferramenta 'dconf' não encontrada. Instalando...${NC}"
    sudo apt update && sudo apt install dconf-cli -y
fi

# ==============================================================================
# 1. RESTAURAÇÃO DE CONFIGURAÇÕES
# ==============================================================================
mkdir -p "$CONFIG_DIR/dconf"
mkdir -p "$CONFIG_DIR/app-configs/hidamari"
mkdir -p "$CONFIG_DIR/app-configs/conky"
mkdir -p "$CONFIG_DIR/app-configs/OpenRGB"
mkdir -p "$CONFIG_DIR/startup"
mkdir -p "$CONFIG_DIR/webapps"
mkdir -p "$CONFIG_DIR/terminal"

# ==============================================================================
# 2. DCONF (Configurações do sistema)
# ==============================================================================
echo "Exportando configurações do GNOME/Zorin..."
dconf dump / > "$CONFIG_DIR/dconf/user-settings.conf"

# ==============================================================================
# 3. STARTUP & WEBAPPS
# ==============================================================================
if [ -d "$HOME/.config/autostart" ]; then
    echo "Backupping startup apps..."
    cp -r "$HOME/.config/autostart/"* "$CONFIG_DIR/startup/"
fi

if [ -d "$HOME/.local/share/applications" ]; then
    echo "Backupping web apps..."
    cp "$HOME/.local/share/applications/"* "$CONFIG_DIR/webapps/"
fi

# ==============================================================================
# 4. CONFIGURAÇÕES ESPECÍFICAS (CONKY E HIDAMARI)
# ==============================================================================

if [ -d "$HOME/.conky" ]; then
    echo "Backupping .conky folder..."
    cp -r "$HOME/.conky"* "$CONFIG_DIR/app-configs/conky" 2>/dev/null
fi
if [ -f "$HOME/.conkyrc" ]; then 
    cp "$HOME/.conkyrc" "$CONFIG_DIR/app-configs/"
fi

HIDAMARI_PATH="$HOME/.var/app/io.github.jeffshee.Hidamari"
if [ -d "$HIDAMARI_PATH" ]; then
    echo "Backupping Hidamari configs..."
    if [ -d "$HIDAMARI_PATH/config/hidamari" ]; then
        cp -r "$HIDAMARI_PATH/config/hidamari/"* "$CONFIG_DIR/app-configs/hidamari" 2>/dev/null
    fi
fi

OpenRGB_PATH="$HOME/.var/app/org.openrgb.OpenRGB"
if [ -d "$OpenRGB_PATH" ]; then
    echo "Backupping OpenRGB configs..."
    if [ -d "$OpenRGB_PATH/config/OpenRGB" ]; then
        cp -r "$OpenRGB_PATH/config/OpenRGB/"* "$CONFIG_DIR/app-configs/OpenRGB" 2>/dev/null
    fi
fi

# Terminal (.bashrc)
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$CONFIG_DIR/terminal/"
fi

echo -e "${GREEN}>>> BACKUP CONCLUÍDO! Verifique a pasta 'configs'.${NC}"