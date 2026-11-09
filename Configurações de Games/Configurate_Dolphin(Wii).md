# 🎮 Games Configuration & Emulation (Nintendo Wii / Dolphin)

Este documento centraliza as diretrizes técnicas de emulação do Nintendo Wii via **Dolphin Emulator**, otimizado para ambiente Dual-Boot (**Linux Zorin OS & Windows**) com compartilhamento de armazenamento e sincronização de controles originais.

---

## ⚙️ 1. Configurações Globais do Dolphin (Desempenho)

Aplicar estas opções para garantir estabilidade e 60 FPS constantes tanto no PC principal quanto no notebook:

- [ ] **Dual Core (Speedhack):** **ATIVADO** (`General` -> `Enable Dual Core`). Essencial para distribuir o processamento entre os núcleos e evitar engasgos em jogos pesados como *Super Mario Galaxy* e *Metroid Prime*.
- [ ] **Velocidade de Execução:** `100% (Normal Speed)`.
- [ ] **Região Padrão (Fallback Region):** `NTSC-U` (garante compatibilidade correta com as ROMs em formato `.rvz` e `.wad`).

---

## 🎨 2. Configurações Gráficas (Backend e Qualidade Visual)

Configuração unificada para rodar com máxima fluidez e alta resolução nos dois sistemas operacionais:

### 🖥️ Renderização (Graphics -> General)
- [ ] **Backend:** **Vulkan** (Oferece o melhor desempenho e estabilidade tanto em GPUs dedicadas NVIDIA/AMD quanto em gráficos integrados no Zorin OS e Windows).
- [ ] **Shader Compilation:** **Hybrid Ubershaders** + Marcar **Compile Shaders Before Starting**.
  * *Objetivo:* Eliminar travadinhas (*stutters*) de compilação de shader durante explosões ou efeitos visuais novos na tela.
- [ ] **Precision Frame Timing:** Marcado.

### ✨ Melhorias Visuais (Graphics -> Enhancements)
- [ ] **Internal Resolution:** 
  * *Notebook / Gráficos Integrados:* `2x Native (720p / 1050p)`.
  * *PC Potente / Placa Dedicada:* `3x Native (1080p)` ou `4x Native (1440p)`.
- [ ] **Texture Filtering:** `16x` (Filtro Anisotrópico — melhora nitidez de texturas sem impacto de performance).
- [ ] **Anti-Aliasing:** 
  * *Notebook:* `None` ou `FXAA`.
  * *PC:* `2x MSAA` ou `4x MSAA`.
- [ ] **Widescreen Hack:** Desmarcado (deixar os jogos gerenciarem o formato 16:9 nativamente no menu interno).

### 🚀 Truques e Hacks (Graphics -> Hacks)
- [ ] **Embedded Frame Buffer (EFB):** Marcar `Skip EFB Access from CPU` e `Store EFB Copies to Texture Only`.
- [ ] **Texture Cache Accuracy:** Deixar em **Fast**.
- [ ] **External Frame Buffer (XFB):** Marcar `Store XFB Copies to Texture Only` e `Skip Presenting Duplicate Frames`.
- [ ] **Outros:** Marcar `Fast Depth Calculation` e `Disable Bounding Box`.

---

## 🕹️ 3. Conexão e Sincronização do Wiimote Físico

O Dolphin comunica-se diretamente com o Bluetooth do sistema para ler os dados do Wiimote sem necessidade de pareamento permanente pelo sistema operacional.

### 📡 Passo a Passo de Sincronização (Linux & Windows)
1. **Configuração no Dolphin:**
   - Abra o Dolphin e vá em **Controllers (Controles)**.
   - No painel **Wii Remote**, selecione a opção **Real Wii Remote (Wii Remote Real)** na porta `Wii Remote 1`.
   - Marque a caixa **Continuous Scanning (Varredura Contínua)**.
2. **Conexão Física:**
   - Garanta que o Bluetooth do PC/Notebook está **LIGADO**.
   - Pressione os botões **`1 + 2`** simultaneamente no Wiimote (ou aperte o botão vermelho **`SYNC`** dentro do compartimento de pilhas).
   - As 4 luzes azuis inferiores do controle começarão a piscar rápido.
   - O Dolphin identificará o controle automaticamente: o Wiimote vibrará por 1 segundo e apenas a luz do **LED 1** ficará acesa estática.
3. **Módulo Passthrough (Opcional para Bluetooth nativo de alta precisão):**
   - Caso enfrente quedas de conexão no Linux, ative o *Bluetooth Passthrough* em `Controllers` -> `Passthrough a Bluetooth Adapter` (requer adaptador USB Bluetooth dedicado).

---

## 🔦 4. Acessórios e Periféricos Obrigatórios

- [ ] **Sensor Bar USB:** Conectada em qualquer porta USB (apenas para alimentar os LEDs infravermelhos). Posicionar acima ou abaixo do monitor para direcionamento do ponteiro na tela.
- [ ] **Nunchuk:** Necessário para movimentação analógica na maioria dos jogos de ação e plataforma.
- [ ] **MotionPlus (Interno ou Adaptador Externo):**
  * **Verificação:** Checar se há o texto *"Wii MotionPlus INSIDE"* na base do controle ou se o adaptador externo está acoplado.
  * **Exigência:** Jogos que exigem giroscópio de alta precisão travam na tela de inicialização sem este item.

---

## 🎮 5. Biblioteca Completa de Jogos e Requisitos de Hardware

Lista dos jogos extraídos no diretório `/mnt/DADOS/Games/Games for Wii/extraidos`, organizados por franquias e com os acessórios exigidos para cada um:

### 🍄 Franquia Super Mario
- [ ] **Super Mario Galaxy** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk.
- [ ] **Super Mario Galaxy 2** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk.
- [ ] **Mario Kart Wii** (`.rvz`)
  * *Requisitos:* Wiimote sozinho (modo volante por movimento) OU Wiimote + Nunchuk.
- [ ] **Mario Strikers Charged** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk.

### 🗡️ The Legend of Zelda
- [ ] **The Legend of Zelda: Skyward Sword** (`.rvz`)
  * *Requisitos:* **Wiimote + Nunchuk + MotionPlus OBSTÁCULO OBRIGATÓRIO**.
- [ ] **The Legend of Zelda: Twilight Princess** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk (não exige MotionPlus).

### 💣 Bomberman
- [ ] **Bomberman Blast** (`.wad` - WiiWare)
  * *Requisitos:* Wiimote na horizontal (estilo controle clássico NES).
- [ ] **Bomberman Land** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk.

### ⚽ Esportes
- [ ] **Wii Sports + Wii Sports Resort** (`.rvz`)
  * *Requisitos:* 
    - *Wii Sports:* Wiimote sozinho ou com Nunchuk.
    - *Wii Sports Resort:* **MotionPlus OBRIGATÓRIO** para todos os minigames (Espada, Arqueria, Frisbee, etc.).

### 👾 Ação, RPG e Luta
- [ ] **Metroid Prime Trilogy** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk + Sensor Bar USB (essencial para mira e câmera de alta precisão).
- [ ] **Super Smash Bros. Brawl** (`.rvz`)
  * *Requisitos:* Wiimote na horizontal, Wiimote + Nunchuk ou controle clássico.
- [ ] **Star Wars - The Force Unleashed** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk (combates de sabre por movimento).
- [ ] **Harry Potter and the Order of the Phoenix** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk (gestos de varinha com o Wiimote).
- [ ] **Resident Evil 4 - Wii Edition** (`.rvz`)
  * *Requisitos:* Wiimote + Nunchuk + Sensor Bar USB (considerada a melhor versão de mira manual do RE4 clássico).

---

## 🧽 6. Manutenção e Limpeza Física do Hardware Original

- [ ] **Inspeção de Pilhas e Vazamentos:** 
  * Abrir a carcaça do Wiimote e do Nunchuck com chave **Tri-wing (Y1)** se ficaram guardados com pilhas antigas.
  * Neutralizar resíduos esbranquiçados/esverdeados de vazamento com cotonete umedecido em **vinagre branco** e finalizar com **álcool isopropílico (99%)**.
- [ ] **Limpeza Externa:** 
  * Limpar a carcaça plástica usando pano de microfibra umedecido em álcool isopropílico. Limpar as frestas dos botões com escova de dentes macia e seca.