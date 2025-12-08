# Windows Auto-Setup & Dotfiles - Marcos Vinícius (vrsmarcos26)

## 🚀 Sobre o Projeto

Este repositório armazena meu script pessoal de automação (**dotfiles**) para configuração de ambiente Windows recém-formatado. O objetivo é eliminar o trabalho manual repetitivo de baixar instaladores, configurar privacidade e preparar o ambiente de desenvolvimento.

O script foi desenvolvido em **PowerShell** e utiliza o **Windows Package Manager (Winget)** para garantir que as versões mais recentes e seguras dos softwares sejam instaladas diretamente dos repositórios oficiais. O foco do ambiente é **Cibersegurança** e **Desenvolvimento FullStack**, mas também inclui configurações para lazer.

---

## 🛠️ Funcionalidades Principais

O script executa uma série de tarefas sequenciais para deixar o sistema pronto para uso em minutos:

* **Instalação Modular:** Os aplicativos são divididos em categorias (Segurança, Desenvolvimento, Lazer) para fácil manutenção.
* **Instalação Silenciosa:** Uso de flags (`--silent`, `--accept-package-agreements`) para evitar janelas de "Next > Next > Finish".
* **Verificação de Permissões:** O script detecta automaticamente se possui privilégios de Administrador antes de executar.
* **Hardening Básico (Windows):** Aplica configurações de registro para melhorar a visibilidade e segurança (ex: exibir extensões de arquivos e arquivos ocultos).
* **Zero Bloat:** Instala apenas o necessário, sem programas de terceiros indesejados.

---

## 💻 Softwares Incluídos

| Categoria | Softwares Principais |
| :--- | :--- |
| **🔒 Segurança** | Brave Browser, ProtonVPN, Bitwarden, Malwarebytes. |
| **💻 Dev** | VS Code, Python 3.12, Git, Android Studio, Docker Desktop. |
| **🎮 Lazer** | Steam, Epic Games, Spotify, Discord. |

---

## ⚙️ Instalação e Uso

Para utilizar este script em uma máquina limpa (pós-formatação), siga os passos abaixo.

### 1. Preparação (Bypass de Política de Execução)
Por padrão, o Windows bloqueia a execução de scripts. Abra o **PowerShell como Administrador** e execute:

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
(Digite 'S' ou 'Y' para confirmar se solicitado).

### 2. Baixar e Executar
Você pode clonar o repositório ou apenas baixar o arquivo .ps1.

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/vrsmarcos26/dotfiles.git](https://github.com/vrsmarcos26/dotfiles.git)
    ```

2.  **Acesse a pasta do Windows e execute:**
    ```powershell
    cd dotfiles\Windows
    .\setup_completo.ps1
    ```

3. Execute o script: Clique com o botão direito no arquivo setup.ps1 e selecione "Executar com o PowerShell" ou rode via terminal:

    ```
    .\setup.ps1
    ```
    
Aguarde: O script fará o download e instalação de tudo. Ao final, recomenda-se reiniciar o computador (especialmente por conta do Docker).

### Após rodar o script, siga o guia de [Configurações Manuais (Windows)](./Windows/Configuracoes-Manuais.md) para logar nas contas e ajustar a segurança fina.

## ✏️ Como Personalizar
Este script foi feito para ser flexível. Se você quiser adicionar ou remover programas:

### 1. Abra o arquivo .ps1 em qualquer editor de texto.
### 2. Localize as listas no início do arquivo (ex: $AppsDev).
### 3. Para encontrar o ID correto de um novo programa, abra o terminal e digite:
```
winget search "NomeDoPrograma"
```
### 4. Adicione o ID encontrado na lista desejada, mantendo a formatação entre aspas.

## 👤 Autor

Marcos Vinícius Rocha Silva

LinkedIn: [@vrsmarcos26](https://www.linkedin.com/in/vrsmarcos26/)
GitHub: [@vrsmarcos26](https://github.com/vrsmarcos26/)

📜 Licença
Distribuído sob a licença MIT. Sinta-se à vontade para fazer um fork e adaptar para suas necessidades.
[LICENSE](LICENSE)
