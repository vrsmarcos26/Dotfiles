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
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
(Digite `S` ou `Y` para confirmar se solicitado.)
```

---

### **2. Baixar e Executar**

```
git clone https://github.com/vrsmarcos26/dotfiles.git
cd dotfiles\Windows
.\setup_completo.ps1
```

---

### **3. Pós-Instalação**

Após o script finalizar, leia o arquivo **Configurações-Manuais.md** para:

- Realizar logins nas ferramentas;  
- Verificar backups;  
- Ajustar configurações avançadas de segurança.  

---

## 🐧 Linux Setup

🚧 **Status: Em Desenvolvimento**

A seção Linux conterá scripts Bash para automatizar ambientes baseados em Debian (Ubuntu/Kali Linux), com foco em:

- Instalação de ferramentas de Pentest e Desenvolvimento (Zsh, Docker, BurpSuite, etc.)  
- Configuração de dotfiles (`.zshrc`, `.vimrc`, `.tmux.conf`)  

Fique atento às próximas atualizações!

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

## 👤 Autor

**Marcos Vinícius Rocha Silva**

- LinkedIn: https://www.linkedin.com/in/vrsmarcos26  
- GitHub: https://github.com/vrsmarcos26  

---

## 📜 Licença

Distribuído sob a licença **MIT**.  
Sinta-se à vontade para usar, modificar e distribuir conforme necessário.

Consulte o arquivo **LICENSE** para mais detalhes.
