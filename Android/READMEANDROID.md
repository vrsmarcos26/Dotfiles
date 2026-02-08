# 🛡️ Android Hardening Protocol (Samsung Edition)

Este guia documenta a configuração de segurança e privacidade ("Hardening") para dispositivos Android, com foco específico em aparelhos Samsung (One UI). O objetivo é espelhar a segurança de um ambiente Desktop blindado, garantindo camadas de defesa contra rastreamento, malware e acesso físico não autorizado.

> **Filosofia:** Segurança em camadas, Minimização de dados e Isolamento de contextos.

---

## 📱 Fase 1: O Stack de Aplicativos
Ferramentas essenciais para substituir serviços invasivos e garantir criptografia.

### 1. Navegador: Brave Browser
- [ ] **Instalação:** Definir como navegador padrão.
- [ ] **Shields:** Configurar "Bloqueio de rastreadores e anúncios" para **Agressivo**.
- [ ] **Mídia:** Ativar "Reprodução de vídeo em segundo plano" (Configurações > Mídia).
    - *Objetivo:* Youtube sem anúncios (estilo Premium) e navegação sem rastreio.

### 2. Gerenciador de Senhas: Bitwarden
- [ ] **Instalação:** Logar na conta.
- [ ] **Autofill (Sistema):**
    - Ir em `Configurações > Gerenciamento Geral > Senhas e preenchimento automático`.
    - Selecionar **Bitwarden** como serviço preferencial.
    - *Objetivo:* Preenchimento automático seguro em apps de banco e sites.

### 3. VPN: Proton VPN
- [ ] **Instalação:** Logar na conta (Plano Free ou Plus).
- [ ] **Kill Switch (Nível Sistema):**
    - Ir em `Configurações > Conexões > Mais configurações de conexão > VPN`.
    - Clicar na engrenagem (⚙️) ao lado do Proton VPN.
    - Ativar: **VPN sempre ativada**.
    - Ativar: **Bloquear conexões sem VPN**.
    - *Objetivo:* Impedir qualquer vazamento de dados se a conexão VPN cair.

### 4. Nuvem: Filen.io
- [ ] **Backup de Fotos:**
    - Ativar **Camera Upload** nas configurações do app.
    - Desativar backup do Google Photos.
    - *Objetivo:* Armazenamento criptografado Zero-Knowledge (adeus análise de IA do Google).

---

## 🛡️ Fase 2: Hardening do Sistema (Samsung Knox)
Configurações nativas para fechar portas de entrada e isolar dados críticos.

### 1. DNS Privado (Firewall de Rede)
Proteção contra malware e phishing em qualquer rede (Wi-Fi ou 4G/5G).
- [ ] Ir em `Configurações > Conexões > Mais configurações de conexão > DNS Privado`.
- [ ] Selecionar **Nome do host do provedor de DNS privado**.
- [ ] Inserir um dos valores abaixo:
    - **Segurança Máxima (Recomendado):** `dns.quad9.net`
    - **Velocidade:** `1dot1dot1dot1.cloudflare-dns.com`

### 2. Bloqueador Automático (Auto Blocker)
*Requer One UI 6.0+*
- [ ] Ir em `Configurações > Segurança e Privacidade > Bloqueador Automático`.
- [ ] **Ativar**.
    - *Objetivo:* Impede instalação de apps via USB e bloqueia comandos maliciosos via cabo (proteção contra Juice Jacking em aeroportos/Uber).

### 3. Pasta Segura (Secure Folder)
Isolamento total de aplicações críticas.
- [ ] Ativar a Pasta Segura.
- [ ] Mover os seguintes apps para dentro dela:
    - 🏦 Apps de Banco (Nubank, Inter, etc.)
    - 🔐 Autenticadores 2FA (Ente Auth, Aegis)
    - *Objetivo:* Se o celular for roubado desbloqueado, o ladrão não acessa a área financeira (que possui senha/biometria separada).

### 4. Manutenção Automática
- [ ] Ir em `Configurações > Assistência do aparelho > Otimização automática`.
- [ ] Ativar **Reiniciar automaticamente**.
- [ ] Agendar para reinício diário (ex: 03:00 AM).
    - *Objetivo:* Limpar a memória RAM e matar processos persistentes de malware.

---

## 🕵️ Fase 3: Privacidade & Des-Google Lite
Redução da telemetria e rastreamento publicitário.

### 1. ID de Publicidade
- [ ] Ir em `Configurações > Segurança e privacidade > Privacidade > Outras configurações > Anúncios`.
- [ ] Clicar em **Excluir ID de publicidade**.
    - *Objetivo:* Quebrar o perfil de rastreamento cruzado entre aplicativos.

### 2. Permissões de Localização
- [ ] Revisar permissões de apps.
- [ ] Alterar apps não essenciais (Redes Sociais, Clima) para **Localização Aproximada**.
- [ ] Manter **Localização Precisa** apenas para Mapas/Transporte/Delivery.

---

## 📝 Resumo da Arquitetura

| Camada | Ferramenta | Função |
| :--- | :--- | :--- |
| **Navegação** | Brave + Shields | Bloqueio de Ads/Trackers |
| **Rede** | DNS Quad9 | Bloqueio de Malware/Phishing |
| **Túnel** | Proton VPN (Kill Switch) | Privacidade de IP/ISP |
| **Credenciais** | Bitwarden | Segurança de Senhas |
| **Arquivos** | Filen | Backup Criptografado |
| **Isolamento** | Pasta Segura | Proteção Financeira |
| **Físico** | Auto Blocker | Proteção USB |

---
*Gerado para protocolo de segurança pessoal. Última atualização: 2026.*