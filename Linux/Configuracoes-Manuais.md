# 📋 Configurações Manuais & Pós-Instalação (Linux)

Este documento serve como um checklist para as etapas que exigem interação humana, logins e ajustes finos que o script setup.sh prepara, mas não pode finalizar sozinho devido à natureza segura do Linux ou interfaces gráficas.

## ☁️ 1. Sincronização e Login

### 🔐 Bitwarden (Flatpak)

- [ ] Logar no App: O script instalou a versão Flatpak. Logue para sincronizar seu cofre.
- [ ] Integração com Navegador: Se você ativou a biometria no App Desktop, vá na extensão do navegador em Configurações -> Desbloquear com Biometria.

> **Nota:** Como é Flatpak, se a integração falhar, verifique se o pacote flatpak-xdg-utils está instalado ou use o PIN.

### 🦁 Brave Browser / Navegador Principal

O script configura WebApps isolados, mas o navegador principal precisa de sync.

- [ ] **Sincronização:** Vá em Configurações -> Sincronização -> Gerenciar Cadeia de Sincronização.
- [ ] **Web Apps:** O script criou atalhos para TryHackMe, HackTheBox, etc.
- [ ] Abra cada um para garantir que o isolamento de perfil (--user-data-dir) funcionou e faça login neles separadamente.
- [ ] **Ícones:** Se algum WebApp ficou com ícone genérico, edite o arquivo .desktop em ~/.local/share/applications/ e aponte para o ícone correto na linha Icon=.

### 🛡️ Proton VPN

- [ ] Logar na conta: A interface gráfica foi instalada via Flatpak.
- [ ] **Kill Switch:** Ative o Permanent Kill Switch (ícone do escudo/interruptor na lateral) para evitar vazamento de IP se a VPN cair.
- [ ] **NetShield:** Ative para bloqueio de anúncios e malware via DNS.

### 📱 Ente Auth (2FA)

- [ ] **Restaurar Backup:** Abra o App Ente Auth, logue e restaure seus tokens de autenticação 2FA.

---

## ⚙️ 2. Ajustes de Sistema e Backup

### 🕰️ TimeShift (Snapshots)

O script tenta forçar essa configuração durante a execução, mas verifique se está operante para garantir recuperação de desastres.

1. Abra o TimeShift no menu.
2. Vá em Configurações (Wizard) e valide:
    - [ ] **Tipo:** RSYNC.
    - [ ] **Local:** Disco principal ou HD Externo (se disponível).
    - [ ] **Agendamento:** Semanal (Manter 2) e Diário (Manter 3).
    - [ ] **Filtros:** Certifique-se de que a opção de Incluir /home/user (pastas ocultas) está marcada se você quiser salvar configurações de programas, mas cuidado com o espaço em disco.

### 🧩 Aplicativos de Inicialização (Startup Applications)

O script instala as ferramentas, mas alguns apps precisam ser adicionados manualmente ao boot do Gnome para funcionarem sem intervenção.

Abra o menu do Zorin/Gnome e procure por "Aplicativos de Inicialização".

#### OpenRGB (Controle de LEDs)

- [ ] Adicione uma nova entrada:
  - **Nome:** OpenRGB Minimized
  - **Comando:** `flatpak run org.openrgb.OpenRGB --startminimized` (Adicione `--profile "SEU-PERFIL.orp"` se já tiver criado um perfil).

#### Hidamari (Wallpaper Animado)

- [ ] Abra o app Hidamari.
- [ ] Clique no menu (três riscos) e marque "Autostart" (Iniciar com o sistema).

#### Conky (Widgets)

- [ ] Abra o Conky Manager.
- [ ] Vá no ícone de engrenagem e marque "Run Conky at system startup".

---

## 🎨 3. Estilização e Visual

### 🖼️ Hidamari (Wallpaper Vídeo)

O script já copiou os vídeos para a pasta do usuário, mas às vezes ele não aplica de imediato.

- [ ] Abra o Hidamari.
- [ ] Selecione o vídeo desejado (white.mp4 ou vermelho.mp4) na lista "Local Video".
- [ ] **Correção de Bug:** Se o wallpaper sumir ao reiniciar ou ficar preto, rode o comando de fallback no terminal para garantir um fundo estático de backup:

```bash
gsettings set org.gnome.desktop.background picture-uri-dark "file:///$HOME/.local/share/backgrounds/white.png"
```

### 📊 Conky (Monitoramento)

O script instalou o tema Gotham e criou o script de inicialização.

1. Abra o Conky Manager.
    - [ ] Na lista de temas, marque a caixa de seleção ao lado de "Gotham".
    - [ ] O widget deve aparecer no desktop imediatamente. Posicione onde achar melhor (o script tenta alinhar, mas monitores variam).

### 🌈 Extensões do Gnome

O script carregou as configurações via dconf, mas verifique se não há conflitos.

1. Abra o app Extensões (Extensions) ou Gerenciador de Extensões.
    - [ ] Verifique se **ArcMenu** e **Blur My Shell** estão ATIVADOS.
    - [ ] Verifique se **Zorin Menu** e **Zorin Desktop Icons** estão DESATIVADOS (para não conflitar com o ArcMenu e deixar o desktop limpo).

---

## 🌐 4. Rede e Conectividade

O script configurou o DNS da Cloudflare (1.1.1.1) via nmcli na conexão ativa detectada.

### 🛡️ Validação do DNS

Confirme se o Linux está realmente usando o DNS seguro.

1. Abra o terminal e digite:

```bash
nmcli dev show | grep DNS
```

2. Verifique se o retorno é:
    - [ ] `IP4.DNS[1]: 1.1.1.1`
    - [ ] `IP4.DNS[2]: 1.0.0.1`

### 🔥 Firewall (UFW)

Confirme se o hardening de rede está ativo.

1. No terminal: `sudo ufw status verbose`
2. O status deve ser Active com:
    - [ ] **Incoming:** Deny (Bloquear entrada)
    - [ ] **Outgoing:** Allow (Permitir saída)

---

## 🎮 5. Drivers e Hardware

### 📺 Placa de Vídeo (GPU)

Se você usa NVIDIA, o script instalou os drivers proprietários via PPA.

- [ ] Abra o NVIDIA Settings.
- [ ] Verifique se a versão do driver está correta (ex: 535, 550, etc) e se a placa está sendo reconhecida.
- [ ] **Notebooks Híbridos:** Verifique no menu do Zorin ou NVIDIA Settings se está em modo "On-Demand" ou "Performance".

---

## ✅ Finalização

- [ ] **Reinicialização Completa:** É crucial reiniciar o Linux após a instalação de drivers de vídeo e extensões do Gnome para evitar glitches visuais ou travamentos no Shell.
- [ ] **Teste do Fastfetch:** Abra o terminal. O logo do sistema com as informações de hardware deve aparecer automaticamente (configurado no .bashrc pelo script).

