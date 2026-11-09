# 📱 Nintendo DSi XL Manual & Emulation Setup (TWiLight Menu++)

Este documento centraliza as diretrizes de manutenção, cuidados físicos, métodos de desbloqueio e organização da biblioteca de jogos do **Nintendo DSi XL**, integrando o ecossistema de arquivos do seu ambiente de armazenamento compartilhado.

---

## 🛡️ 1. Cuidados Físicos e Manutenção do DSi XL

O DSi XL possui telas IPS/TN de excelente tamanho, mas exige cuidados específicos de preservação:

- [ ] **Proteção de Tela (Película):** Use sempre películas de vidro ou PET nas duas telas. A tela inferior (touchscreen) sofre desgaste rápido com o uso da stylus caso esteja desprotegida.
- [ ] **Cuidados com a Bateria (Li-Ion):** Se o console for ficar guardado por longos períodos, deixe a carga da bateria em torno de 50% e desligue-o completamente. Evite deixar a bateria zerar por meses para não perder a vida útil da célula.
- [ ] **Limpeza Segura:** Utilize apenas um pano de microfibra levemente umedecido em **álcool isopropílico (99%)** para remover marcas de gordura na carcaça e nas telas. Nunca borrife líquidos diretamente no console.
- [ ] **Armazenamento do Cartão SD:** Mantenha o cartão SD formatado em **FAT32** (com tamanho de alocação de 32kb). O DSi é sensível a formatações incorretas ou cartões corrompidos, o que pode causar falhas no carregamento do TWiLight Menu++.

---

## 🔓 2. Métodos de Desbloqueio e Boot (Ecossistema Atual)

O seu console utiliza o padrão moderno de modificação via software, eliminando a necessidade de cartuchos flashcard tradicionais para o menu principal:

- [ ] **Unlaunch (Bootloader Nativo):** 
  * É o exploit instalado diretamente na NAND do DSi (`unlaunch-installer.dsi`). Ele substitui a tela de início padrão por um menu seguro, permitindo carregar homebrews direto do SD e fornecendo proteção contra *bricks*.
- [ ] **TWiLight Menu++:** 
  * A interface principal que simula o visual do DSi Menu / 3DS Menu, gerenciando o carregamento das ROMs de NDS, DSiWare e emuladores através do **nds-bootstrap**.
- [ ] **Dumps de Segurança (NAND Backup):** 
  * A pasta `DT375732A7154E44AD(nand)` contendo o `nand.bin` e o `nand.bin.sha1` é o **seguro de vida do seu console**. Mantenha este backup sempre guardado com segurança no seu PC/armazenamento compartilhado. Se houver qualquer corrompimento de sistema, é com ele que o console é restaurado.

---

## 🛠️ 3. Ferramentas e Estrutura de Pastas no SD

Para manter a compatibilidade com os emuladores e o sistema, a estrutura essencial presente no seu diretório deve ser mantida:

- [ ] `/_nds/`: Contém os arquivos de suporte do TWiLight Menu++, perfis de cores (`colorLut`), configs de áudio e o **nds-bootstrap** (responsável por rodar os jogos de DS direto da SD).
- [ ] `/_gba/` e `emulators/`: Contém os núcleos do **GBARunner2** (para rodar jogos de Game Boy Advance) e emuladores de consoles clássicos (NES, SNES via SNEmulDS, Mega Drive via jEnesisDS, etc.).
- [ ] `/roms/`: Organizada por categorias limpas (`Acao e Luta`, `Aventura e RPG`, `Castlevania`, `Mario`, `Pokemon`, `Zelda`, etc.), facilitando a navegação na tela grande do DSi XL.

---

## 🎮 4. Biblioteca Completa de Jogos (Organizada por Categorias)

### ⚔️ Ação e Luta
- [ ] **0696 - Jump! Ultimate Stars** *(NDS)*
- [ ] **Bakugan - Battle Brawlers** *(NDS)*
- [ ] **Comix Zone** *(GBA)*
- [ ] **Dragon Ball Z - Supersonic Warriors 2** *(NDS)*
- [ ] **Naruto Shippuden - Ninja Council 4** *(NDS)*
- [ ] **Streets of Rage 2** *(Mega Drive)*
- [ ] **Tom Clancy's Splinter Cell - Chaos Theory** *(NDS)*
- [ ] **Ultimate Mortal Kombat** *(NDS)*

### 🗡️ Assassin's Creed
- [ ] **Assassin's Creed - Altair's Chronicles** *(NDS)*
- [ ] **Assassin's Creed II - Discovery** *(NDS - NDSi Enhanced)*

### 🗺️ Aventura e RPG
- [ ] **3538 - Grand Theft Auto - Chinatown Wars** *(NDS)*
- [ ] **Final Fantasy IV** *(NDS)*
- [ ] **Metroid Prime - Hunters (Rev 1)** *(NDS)*
- [ ] **Rayman DS** *(NDS)*

### 💣 Bomberman
- [ ] **3430 - Bomberman 2** *(NDS)*
- [ ] **Super Bomberman 3** *(SNES)*

### 🎯 Call of Duty
- [ ] **Call of Duty - Black Ops** *(NDS)*
- [ ] **Call of Duty - Modern Warfare - Mobilized** *(NDS)*

### 🦇 Castlevania
- [ ] **0997 - Castlevania - Aria of Sorrow** *(GBA)*
- [ ] **Castlevania - Dawn of Sorrow** *(NDS)*
- [ ] **Castlevania - Order of Ecclesia** *(NDS)*
- [ ] **Castlevania - Portrait of Ruin** *(NDS)*
- [ ] **Super Castlevania IV** *(SNES)*

### 🏎️ Corrida
- [ ] **Need for Speed - Underground 2** *(NDS)*

### 🌀 Crash
- [ ] **Crash Bandicoot - The Huge Adventure** *(GBA)*
- [ ] **Crash Nitro Kart** *(GBA)*

### 🦍 Donkey Kong
- [ ] **Donkey Kong Country 2 - Diddy's Kong Quest** *(SNES)*
- [ ] **Donkey Kong Country 3 - Dixie Kong's Double Trouble!** *(SNES)*

### 🧱 LEGO
- [ ] **LEGO Batman - The Videogame** *(NDS)*
- [ ] **LEGO Marvel Super Heroes - Universe in Peril** *(NDS)*
- [ ] **LEGO Star Wars - The Complete Saga** *(NDS)*
- [ ] **LEGO The Lord of the Rings** *(NDS)*

### 🍄 Mario
- [ ] **0854 - Mario Slam Basketball** *(NDS)*
- [ ] **4274 - Mario & Sonic at the Olympic Winter Games** *(NDS)*
- [ ] **Mario Kart DS** *(NDS)*
- [ ] **Mario & Sonic at the Olympic Games** *(NDS)*
- [ ] **New Super Mario Bros.** *(NDS)*
- [ ] **Super Mario 64 DS (Rev 1)** *(NDS)*
- [ ] **Super Mario All-Stars + Super Mario World** *(SNES)*

### ⚡ Pokémon
- [ ] **Pokemon - Emerald Version** *(GBA)*
- [ ] **Pokemon Pinball** *(GBC)*
- [ ] **Pokemon - Platinum Version (Rev 1)** *(NDS)*
- [ ] **Pokemon - SoulSilver Version** *(NDS)*
- [ ] **Pokemon - White Version** *(NDS - NDSi Enhanced)*
- [ ] **Pokemon - White Version 2** *(NDS - NDSi Enhanced)*
- [ ] **Pokemon - Yellow Version - Special Pikachu Edition** *(GB)*

### 🦔 Sonic
- [ ] **Sonic Classic Collection** *(NDS - NDSi Enhanced)*
- [ ] **Sonic Colors** *(NDS)*
- [ ] **Sonic Rush** *(NDS)*

### 🛡️ Zelda
- [ ] **The Legend of Zelda - Link's Awakening DX** *(GBC)*
- [ ] **The Legend of Zelda - Oracle of Ages** *(GBC)*
- [ ] **The Legend of Zelda - Oracle of Seasons** *(GBC)*
- [ ] **The Legend of Zelda - Phantom Hourglass** *(NDS)*
- [ ] **The Legend of Zelda - The Minish Cap** *(GBA)*

---

### Sugestão de Organização
Você pode salvar este arquivo na sua pasta `/mnt/DADOS/Dev/Repositorios/Dotfiles/Configurações de Games/NDS_Configurate.md`, mantendo o mesmo padrão profissional dos seus outros guias de Linux, Windows e Casa!