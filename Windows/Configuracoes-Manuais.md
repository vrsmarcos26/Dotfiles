# 📋 Configurações Manuais & Sincronização

Este documento serve como um **checklist** para as etapas que não podem ser automatizadas via script (login, sincronização de nuvem e ajustes finos de segurança).

---

## ☁️ 1. Sincronização e Login

### 🔐 Bitwarden
- [ ] **Logar na extensão:** Assim que logar, todas as senhas, pastas e notas aparecem instantaneamente.
- [ ] **Reativar Biometria/PIN:** Vá em *Configurações* e ative "Desbloquear com PIN" ou "Biometria" (essas configurações não sincronizam por segurança).

### 🦁 Brave Browser
*O Brave não usa conta de e-mail, usa uma "Cadeia de Sincronização".*

1.  **No PC Antigo (Origem):** Vá em `Menu` -> `Configurações` -> `Sincronização (Sync)` -> `Gerenciar Cadeia` -> `Exibir Código`.
2.  **Neste PC (Destino):** Instale o Brave, vá em `Sincronização` e selecione **"Tenho um código de sincronização"**.

> **Nota:** Isso trará seus Favoritos, Histórico e Extensões (incluindo Bitwarden e uBlock).
>
> ⚠️ **Atenção:** Verifique manualmente se o **HTTPS-Only** está ativado em `Escudo`, pois configurações profundas de segurança podem não sincronizar.

### 🛡️ Proton VPN
- [ ] **Logar na conta:** A conta será reconhecida e o plano validado.
- [ ] **Verificar Perfil:** Confirme se o perfil "Quick Connect" está apontando para o país/servidor de sua preferência.

---

## ⚙️ 2. Ajustes de Segurança (Hardening)

Configurações específicas que devem ser validadas após a instalação.

### 🟢 Proton VPN (Configurações)
Vá nas configurações avançadas e garanta que estejam assim:

- [ ] **Kill Switch:** `Standard` (Padrão)
- [ ] **Alternative Routing:** `Ligado` (On)
- [ ] **Allow LAN connections:** `Desligado` (Off) - *Importante para evitar acesso local não autorizado em redes públicas.*
- [ ] **OpenVPN network driver:** `TUN`
- [ ] **IPv6 Leak Protection:** `Ligado` (On)

### 🦠 Malwarebytes Free
Ajustes para maximizar a detecção e minimizar o incômodo:

**Geral / Segurança:**
- [ ] **Windows Security Center:** `Desligado` (Não registrar o MB como antivírus principal do Windows).
- [ ] **Launch in background:** `Desligado` (Não iniciar com o Windows).

**Opções de Scan (Scan Options):**
- [ ] **Scan for rootkits:** `Ligado` (On)
- [ ] **Scan within archives:** `Ligado` (On)
- [ ] **Use artificial intelligence:** `Ligado` (On)
- [ ] **PUPs & PUMs:** `Always (recommended)` (Sempre detectar).

**Notificações:**
- [ ] **Promotions and special offers:** `Desligado`
- [ ] **New features and changes:** `Desligado`

---

## 🔄 3. Automação e Backup (Verificação)

Como o script de instalação configurou uma rotina de atualização automática e backup, é crucial verificar se o Windows permitiu essas configurações.

### 🛡️ Configurar Proteção do Sistema (Ponto de Restauração)
O script de atualização tenta criar um backup antes de rodar. Para isso funcionar, o Windows precisa ter espaço reservado.

1.  Pressione `Win + R`, digite `sysdm.cpl` e dê Enter.
2.  Vá na aba **Proteção do Sistema**.
3.  Selecione o **Disco Local (C:)** e clique no botão **Configurar**.
4.  **Configurações de Restauração:** Marque a opção **"Ativar a proteção do sistema"**.
5.  **Uso do Espaço em Disco:** Arraste o controle deslizante até atingir aproximadamente **10 GB** (ou cerca de 5% a 10% do disco).
    * *Isso garante que o sistema tenha espaço para guardar os backups semanais sem lotar seu HD.*
6.  Clique em **Aplicar** e **OK**.

### 📅 Verificar o Agendador de Tarefas
Confirme se a tarefa de atualização foi criada corretamente pelo script.

1.  Pressione `Win + R`, digite `taskschd.msc` e dê Enter.
2.  Clique em **Biblioteca do Agendador de Tarefas** (lado esquerdo).
3.  Procure na lista central pela tarefa: `AutoUpdateSemanal`.
4.  Clique duas vezes nela e verifique:
    * [ ] **Aba Disparadores:** Deve estar agendado para **"Semanalmente"**, toda **Quarta-feira** às **21:00**.
    * [ ] **Aba Ações:** Deve apontar para iniciar um programa em `C:\Scripts\auto_update.bat`.
    * [ ] **Aba Geral:** Deve estar marcado **"Executar com privilégios mais altos"** (necessário para o Winget e o Ponto de Restauração funcionarem).

---

## ✅ Finalização
- [ ] Reiniciar o computador para garantir que todas as alterações de drivers (VPN) e serviços (Docker/System) sejam aplicadas.