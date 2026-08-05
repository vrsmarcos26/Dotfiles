# 🏰 Roadmap: Fortaleza Digital Física (IoT, Automação e Energia)

Este documento centraliza as diretrizes para construir um ambiente físico inteligente (Smart Home) com foco extremo em **Privacidade, Processamento Local, Portabilidade e Eficiência Energética**, ideal para apartamentos e fácil de migrar.

---

## 🧠 1. O Cérebro do Sistema (Processamento Local)

**Objetivo:** Eliminar a dependência da nuvem (Cloud) de gigantes da tecnologia (Amazon, Google).
*   **Ferramenta:** **Home Assistant (HA)**.
*   **Hardware:** Mini PC (Dell Micro, Lenovo Tiny) ou Raspberry Pi.
*   **Vantagens:** 100% offline, rápido, dados não saem da sua rede. Altamente portátil (basta colocar o Mini PC na mala ao se mudar).
*   **Consumo:** Extremamente baixo (3 a 5 Watts), custo insignificante na conta de luz.

---

## 🔌 2. Conectividade e Protocolos (O Fim do Wi-Fi para IoT)

**Objetivo:** Não sobrecarregar o roteador e impedir que lâmpadas/tomadas se comuniquem com a internet.
*   **O Problema do Wi-Fi:** Muitos dispositivos travam o roteador e geram tráfego de telemetria desnecessário.
*   **A Solução:** Padronizar tudo em **Zigbee** ou **Z-Wave**.
*   **Como funciona:** Eles não usam IP e não conectam no Wi-Fi. Falam apenas com um "coordenador" (Antena USB) espetado no servidor do Home Assistant.

---

## 🚧 3. Quarentena de Rede e Bloqueio de Espionagem

**Objetivo:** Isolar e "cegar" aparelhos invasivos que exigem Wi-Fi (Smart TVs, Aspiradores, Alexa).
*   **VLAN / Rede de Convidados:** Colocar aparelhos IoT em uma rede isolada. Se a TV for hackeada, o atacante não consegue "pular" para os computadores pessoais.
*   **DNS Sinkhole (Pi-hole ou AdGuard Home):** Rodar no servidor local para interceptar e bloquear as tentativas das Smart TVs (LG, Samsung) de enviar logs, áudios ou rastreamento de tela para a fábrica.

---

## 🚗 4. Segurança Veicular (Carros Inteligentes)

**Objetivo:** Mitigar a coleta massiva de dados por montadoras e evitar roubos tecnológicos.
*   **Aplicativos de Montadora:** Usar aliases de e-mail (DuckDuckGo, SimpleLogin) e dados falsos no registro. Não salvar o endereço exato de casa no GPS.
*   **Proteção Física (Keyless):** Guardar a chave presencial (e a reserva) em uma **Bolsa de Faraday** quando estiver em casa. Isso bloqueia o sinal de rádio RFID e impede a "clonagem de calçada".

---

## ⚡ 5. Monitoramento e Eficiência Energética (Apartamentos)

**Objetivo:** Caçar aparelhos gastões e reduzir a conta de luz, com instalações não-permanentes.
*   **Nível 1 (Tomadas Inteligentes Zigbee):** Medem o consumo do que está plugado nelas. Ideais para ligar a ilha do PC/TV e automatizar o corte total de energia de madrugada (matando o consumo fantasma de Standby).
*   **Nível 2 (Medidor com Garra/Clamp):** Instalação não invasiva no quadro de disjuntores do apartamento (ex: Shelly EM). Mede os Watts totais que entram no imóvel em tempo real para o Home Assistant, sem precisar alterar a infraestrutura do prédio.

---

## ☀️ 6. Energia Solar em Apartamentos

**Objetivo:** Usufruir de energia limpa contornando as restrições físicas de um condomínio.
*   **A Abordagem "Hacker" (Geração Compartilhada):** Assinatura 100% digital de Fazendas Solares (ex: Órigo, Cemig SIM, etc). Você "aluga" cotas de energia e o desconto (10% a 20%) vem abatido na sua conta de luz da concessionária normal. Sem obras, fácil de transferir caso se mude.
*   **A Abordagem Off-Grid (Kits de Varanda):** Painéis solares pequenos (rígidos ou flexíveis) na sacada, ligados a uma Power Station (bateria). Suficiente para alimentar exclusivamente sua bancada de trabalho, notebook, roteador e Home Assistant com energia limpa isolada.
*   **ALERTA:** Nunca utilizar "Microinversores de tomada" irregulares (Grid-Tie pirata) em apartamentos. É contra a regulamentação e pode gerar multas pesadas.