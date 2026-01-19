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

O script de instalação configura uma rotina automática. Apenas verifique se o Windows aceitou as configurações.

### 🛡️ Verificar Espaço da Proteção do Sistema (Ponto de Restauração)
O script deve ter reservado 10GB automaticamente. Vamos apenas confirmar:.

1.  Pressione `Win + R`, digite `sysdm.cpl` e dê Enter.
2.  Vá na aba **Proteção do Sistema**.
3.  Selecione o **Disco Local (C:)** e clique no botão **Configurar**.
   4. * [ ] Confirme se **"Ativar a proteção do sistema"** está marcado.
   5. * [ ] Confirme se o **Uso Atual** ou o **Limite Máximo** está em torno de **10GB** (10%).
* *Se estiver em 0% ou muito baixo, aumente manualmente para garantir os backups.*
6.  Clique em **Aplicar** e **OK**.

### 📅 Verificar o Agendador de Tarefas
Confirme se a tarefa de atualização foi criada corretamente pelo script.

1.  Pressione `Win + R`, digite `taskschd.msc` e dê Enter.
2.  Clique em **Biblioteca do Agendador de Tarefas** (lado esquerdo).
3.  Procure na lista central pela tarefa: `AutoUpdateSemanal`.
4.  Clique duas vezes nela e verifique:
    * [ ] **Aba Disparadores:** Deve estar agendado para **"Semanalmente"**, toda **Quarta-feira** às **20:00**.
    * [ ] **Aba Ações:** O programa será `powershell.exe` e nos argumentos haverá um comando longo começando com `-ExecutionPolicy Bypass...`.
    * [ ] **Aba Geral:** Deve estar marcado **"Executar com privilégios mais altos"** (necessário para o Winget e o Ponto de Restauração funcionarem).

---

## 🌐 4. Rede e Conectividade (DNS)

O script configura o Windows para usar os servidores da Cloudflare (1.1.1.1) em todos os adaptadores ativos no momento da instalação.

### 🛡️ Validação do DNS
Confirme se a alteração foi aplicada corretamente e se não há conflitos de rede.

1.  Pressione `Win + X` e selecione **Terminal** ou **PowerShell**.
2.  Digite o comando `ipconfig /all` e procure pelo seu adaptador de rede principal (Wi-Fi ou Ethernet).
3.  Verifique a linha **Servidores DNS**:
    - [ ] Deve constar: `1.1.1.1` (Primário)
    - [ ] Deve constar: `1.0.0.1` (Secundário)

### ⚠️ Solução de Problemas (Sem Internet?)
O uso de DNS fixo pode bloquear a conexão em **redes corporativas** (que usam DNS interno) ou **redes públicas com login** (hotéis, aeroportos, cafeterias com portal cativo).

Se você perder a conexão nessas situações:
1.  Pressione `Win + R`, digite `ncpa.cpl` e dê Enter.
2.  Clique com o botão direito no adaptador conectado -> **Propriedades**.
3.  Selecione **Protocolo IP Versão 4 (TCP/IPv4)** -> **Propriedades**.
4.  [ ] Marque a opção: **"Obter o endereço dos servidores DNS automaticamente"**.

> **Nota:** O script de *Rollback* faz essa reversão para o automático (DHCP) se for executado.

---

## ✅ Finalização

- [ ] Reiniciar o computador para garantir que todas as alterações de drivers (VPN) e serviços (Docker/System) sejam aplicadas.
