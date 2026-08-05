# Dotfiles & Auto-Setup - Marcos Vinícius (vrsmarcos26)

## 🚀 Sobre o Projeto

Este repositório centraliza meus scripts pessoais de automação (dotfiles) e configuração de ambiente para **Windows** e **Linux**.

O objetivo é eliminar o trabalho manual repetitivo de pós-formatação, garantindo que todas as minhas ferramentas de **Desenvolvimento** e **Cibersegurança** sejam instaladas e configuradas automaticamente em minutos, seguindo boas práticas de **hardening**.

---

## 📂 Estrutura do Repositório

```
dotfiles/
│
├── 🪟 Windows/ # Scripts em PowerShell (Winget + Hardening)
│ ├── setup_completo.ps1
│ ├── auto_update.bat
│ ├── undo_setup.ps1
│ └── Configuracoes-Manuais.md
│
└── 🐧 Linux/ # Scripts em Bash (Em desenvolvimento)
└── (Em breve: Scripts para Kali/Ubuntu)
```

---

## 🪟 Windows Setup

O módulo Windows utiliza **PowerShell** e **Winget** para instalar as versões mais recentes dos softwares diretamente dos repositórios oficiais.

### 🛠️ Funcionalidades Principais

- **Instalação Modular:** Os aplicativos são divididos em categorias (Segurança, Desenvolvimento, Lazer).  
- **Instalação Silenciosa:** Uso de flags `--silent` para evitar janelas de "Next > Next > Finish".  
- **Verificação de Permissões:** O script detecta automaticamente se possui privilégios de Administrador.  
- **Hardening Básico:** Aplica configurações de registro para melhorar visibilidade e segurança (ex.: exibir extensões de arquivos).  
- **Manutenção Automática:** Configura atualizações semanais e pontos de restauração via Agendador de Tarefas.  

---

## 💻 Softwares Incluídos

| Categoria | Softwares Principais |
|----------|------------------------|
| 🔒 Segurança | Brave Browser, ProtonVPN, Bitwarden, Malwarebytes |
| 💻 Dev | VS Code, Python 3.12, Git, Android Studio, Docker Desktop |
| 🎮 Lazer | Steam, Epic Games, Spotify, Discord |

---

## ⚙️ Instalação e Uso (Windows)

### **1. Preparação (Bypass de Política)**

Abra o PowerShell como **Administrador** e execute:

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```
(Digite `S` ou `Y` para confirmar se solicitado.)

---

### **2. Pré-requisito (Instalar o Git)**

Como o Windows vem limpo, instale o Git rapidamente via Winget para poder baixar o repositório:

```
winget install --id Git.Git -e --source winget; Start-Process powershell -Verb RunAs; exit
```

⚠️ Importante: Após o Git instalar, feche e abra o PowerShell novamente para que o comando git seja reconhecido.

---

### **3. Baixar e Executar**

Agora que o git está instalado, execute:

```
git clone https://github.com/vrsmarcos26/Dotfiles.git
cd dotfiles\Windows
.\setup_completo.ps1
```

---

(O script vai detectar que o Git já está instalado e apenas pular para os próximos apps).

### **4. Pós-Instalação**

Após o script finalizar, leia o guia de Configurações Manuais (Windows) para realizar logins, verificar backups e ajustar a segurança fina. 

---

## ⚠️ Solução de Problemas (Troubleshooting)

### Opção Alternativa: Baixar ZIP (Sem Git)

Se não quiser instalar o Git manualmente antes, você pode baixar o ZIP do projeto, mas precisará desbloquear o arquivo:

1. Baixe o ZIP e extraia.

2. Abra o PowerShell na pasta Windows.

3. Execute o comando para desbloquear o arquivo (necessário para scripts baixados via navegador):

```
Unblock-File -Path .\setup_completo.ps1
```

4. Execute: ```.\setup_completo.ps1```

---

## 🐧 Linux Setup


### 1. Preparação

Abra o terminal na pasta onde clonou o repositório.

*⚠️ Atenção: Não execute como root (`sudo ./setup.sh`). O script pedirá a senha quando necessário para garantir que as configurações do usuário (`$HOME`) não sejam quebradas.*

### 2. Execução

```bash
git clone https://github.com/vrsmarcos26/Dotfiles.git
cd dotfiles/Linux
chmod +x setup.sh
./setup.sh
```

### 3. Pós-Instalação

Após o script reiniciar a interface gráfica, leia o guia `Configuracoes-Manuais-Linux.md` para ativar o Hidamari, Conky e logar nos serviços.

---

## ✏️ Como Personalizar (Windows)

O script foi criado para ser flexível e fácil de modificar.

1. Abra `Windows/setup_completo.ps1`.  
2. Localize as listas de programas no início (ex.: `$AppsDev`, `$AppsSecurity`, `$AppsGaming`).  
3. Para encontrar o ID Winget de um novo software, execute:

```
winget search "NomeDoPrograma"
```

4. Adicione o ID encontrado à lista correspondente, mantendo o formato entre aspas.

---

## 🐧 Como Personalizar (Linux)

O script foi criado para ser flexível e fácil de modificar.

1. Abra `Linux/setup.sh`.
2. Localize as listas de programas no início do script.
3. Para encontrar o ID Flatpak de um novo software, execute:

```bash
flatpak search "NomeDoPrograma"
```

4. Adicione o ID encontrado à lista correspondente, mantendo o formato entre aspas.

### Modularidade

O script é modular. Você pode comentar seções inteiras (ex: `# COMENTE EFEITOS 3D`) caso esteja rodando em uma Máquina Virtual ou PC com recursos limitados.

---


Sempre olhar os sites:

- Colloid Icons: https://www.cinnamon-look.org/p/1661983 
- Colloid GTK Theme: https://www.cinnamon-look.org/p/1661959
- Orchis GTK Theme: https://www.cinnamon-look.org/p/1357889
- Jasper GTK Theme: https://www.cinnamon-look.org/p/1891521
- Wallpapers: https://drive.google.com/drive/folder...
- Ajuste da Hora: https://www.foragoodstrftime.com/

---

## 👤 Autor

**Marcos Vinícius Rocha Silva**

- LinkedIn: https://www.linkedin.com/in/vrsmarcos26  
- GitHub: https://github.com/vrsmarcos26  

---

## 📜 Licença

Distribuído sob a licença **MIT**.  
Sinta-se à vontade para usar, modificar e distribuir conforme necessário.

Consulte o arquivo **LICENSE** para mais detalhes.
