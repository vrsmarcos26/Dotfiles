# 🏰 Roadmap Definitivo: Fortaleza Digital Física (IoT, Automação e Energia)

Este documento centraliza as diretrizes para construir um ambiente físico inteligente com foco extremo em **Privacidade, Segurança (CyberSec), Processamento Local e Zero Manutenção**. 

**A Regra de Ouro:** A casa funciona 100% offline. Dispositivos "burros" ficam na tomada inteligente; dispositivos vitais usam o protocolo Zigbee. O Wi-Fi da casa fica isolado para os computadores pessoais. 

---

## 🛡️ FASE 0: A Fundação (Segurança Elétrica e Rede)
*Sem isso, a casa inteligente corre risco de queimar ou ser invadida.*

- [ ] **Protetor de Surtos (DPS no Quadro)**
  * **Categoria:** Infraestrutura Elétrica
  * **Prioridade:** 0 (Máxima)
  * **O que faz:** Fica no quadro de energia e se "sacrifica" desviando raios e surtos elétricos da rua para o aterramento. Evita que o seu Mini PC, TV e aparelhos caros queimem.
  * **Especificações para compra:** DPS Classe II (20kA ou 45kA). Contratar um eletricista para colocar no trilho DIN do quadro de disjuntores.

- [ ] **No-break (UPS) Estratégico ou Notebook Antigo**
  * **Categoria:** Infraestrutura Elétrica / Servidor
  * **Prioridade:** 0 (Máxima)
  * **O que faz:** Mantém a internet e o cérebro da casa ligados se a energia do bairro cair.
  * **Especificações para compra:** Um no-break simples (600VA) apenas para o roteador e Mini PC. Alternativamente, usar um **Notebook antigo com a tela quebrada** como servidor (a bateria interna age como um no-break gratuito).

- [ ] **Roteador Inteligente (VLANs)**
  * **Categoria:** Redes / CyberSec
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Isola a rede. Cria um "Wi-Fi Casa" para computadores/Dev e um "Wi-Fi IoT/Quarentena" para TVs Smart e robôs. Também permite criar Wi-Fi para visitas via botão no celular.
  * **Especificações para compra:** Roteadores Mesh (como TP-Link Deco) ou compatíveis com firmware **OpenWrt** (para controle absoluto de VLANs).

---

## 🧠 FASE 1: O Cérebro, a "Boca" e o Acesso Seguro
*A estrutura de TI que vai rodar o sistema e abolir a Nuvem Chinesa/Americana.*

- [ ] **O Cérebro: Mini PC Corporativo**
  * **Categoria:** Servidor Local
  * **Prioridade:** 0 (Máxima)
  * **O que faz:** Roda o Home Assistant (Linux/Docker) 24/7. Tem força para rodar automações, banco de dados, LLMs locais e laboratórios de pentest simultaneamente. 
  * **Especificações para compra:** Evitar Raspberry Pi/TV Box (fracos para Docker/IA e corrompem SD). Buscar: **Dell Optiplex Micro, Lenovo ThinkCentre Tiny, ou HP ProDesk Mini** (Intel i3/i5, mín. 8GB RAM, SSD NVMe).

- [ ] **A Boca: Dongle USB Zigbee 3.0**
  * **Categoria:** Comunicação / IoT
  * **Prioridade:** 0 (Máxima)
  * **O que faz:** A antena que "fala" o protocolo Zigbee com os aparelhos, sem usar o Wi-Fi do roteador.
  * **Especificações para compra:** **Sonoff Zigbee 3.0 USB Dongle Plus** (Versão com chip **CC2652P**).

- [ ] **Acesso Web: DuckDNS + Let's Encrypt + 2FA**
  * **Categoria:** Acesso Remoto / Segurança
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Acesso remoto prático para a família acessar a casa de fora (4G) pelo app, sem precisar instalar VPN nos celulares.
  * **Como configurar:** Instalar Add-on DuckDNS no Home Assistant, ativar HTTPS e **obrigar o uso de Autenticação em 2 Fatores (2FA)**. Ativar `ip_ban` no config.yaml.

---

## ⚡ FASE 2: Gestão de Energia e Automações Base
*Monitorar os reais (R$) gastos por aparelho e cortar Standby.*

- [ ] **Medidor de Energia com Garra (Quadro e Chuveiro)**
  * **Categoria:** Monitoramento Industrial
  * **Prioridade:** 2 (Média)
  * **O que faz:** Mede consumo de cabos pesados (Quadro Geral e Chuveiro) sem cortar fios. Envia o custo em reais para o painel.
  * **Especificações para compra:** Medidores com Garra "CT Clamp" (ex: Shelly EM ou Zigbee Tuya CT Clamp 80A).

- [ ] **Tomadas Inteligentes 16A (Climatizador WAP, PC)**
  * **Categoria:** Automação Local / Monitoramento
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Fica entre a parede e o aparelho "burro". Transforma aparelhos mecânicos em inteligentes e corta energia fantasma de madrugada.
  * **Especificações para compra:** Protocolo **ZIGBEE**, amperagem mínima de **16A**, e função **Energy Monitoring**.

- [ ] **Interruptores de Luz (Paredes)**
  * **Categoria:** Automação Base
  * **Prioridade:** 1 (Alta)
  * **Especificações para compra:** Protocolo **ZIGBEE**. Buscar sempre **"Sem Neutro" (No Neutral)** para não precisar trocar a fiação do apartamento.

---

## 🚨 FASE 3: Segurança Física e Emergência
*Automações que salvam vidas e patrimônio.*

- [ ] **Fechadura Inteligente**
  * **Categoria:** Acesso Físico
  * **Prioridade:** 2 (Média)
  * **Especificações para compra:** Protocolo **ZIGBEE** (Jamais Wi-Fi). Deve possuir chave mecânica oculta de emergência.

- [ ] **Sensor de Fumaça e Gás Natural/GLP**
  * **Categoria:** Sensores de Emergência
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Pode ser programado para destrancar a porta, acender luzes e tocar alertas caso haja princípio de incêndio.
  * **Especificações para compra:** Protocolo **ZIGBEE**.

- [ ] **Sensor de Vazamento de Água**
  * **Categoria:** Prevenção de Danos
  * **Prioridade:** 2 (Média)
  * **O que faz:** Envia alerta ao celular se a máquina de lavar vazar água no chão.

---

## 👁️ FASE 4: Conforto Invisível e Praticidade Extrema

- [ ] **Sensores de Presença mmWave**
  * **Categoria:** Sensores Avançados
  * **Prioridade:** 2 (Média)
  * **O que faz:** Detecta até a respiração humana. Não apaga a luz se você ficar parado lendo ou no banho.
  * **Especificações para compra:** Protocolo **ZIGBEE**. Tecnologia **mmWave (Ondas Milimétricas)**.

- [ ] **Robô Aspirador com LiDAR**
  * **Categoria:** Limpeza Autônoma
  * **Prioridade:** 3 (Baixa/Lazer)
  * **O que faz:** Aspira a casa ativamente para recolher poeira e pelos soltos. Pode limpar automaticamente quando não houver ninguém no Wi-Fi.
  * **Especificações para compra:** Mapeamento a laser **(LiDAR)** no topo. Conferir se o modelo tem *"Home Assistant Integration"*.

- [ ] **Motor de Persiana**
  * **Categoria:** Controle de Clima
  * **Prioridade:** 3 (Baixa/Lazer)
  * **Especificações para compra:** Motor Zigbee "Puxador de Corda" (Blind Motor) com bateria.

---

## 🍳 FASE 5: Eletrodomésticos e Otimização de Tempo
*A integração inteligente para aparelhos pesados da rotina doméstica.*

- [ ] **Cafeteira e Chaleira Elétrica**
  * **Categoria:** Rotina Matinal
  * **O que faz:** Ao usar modelos básicos (com botão mecânico Liga/Desliga) ligados em **Tomadas Inteligentes Zigbee 16A**, você pode deixar a água e o pó prontos na noite anterior. O sistema liga a tomada automaticamente no horário que você acorda, preparando o café ou a água quente sozinho.

- [ ] **Panela Elétrica (Arroz / Pressão)**
  * **Categoria:** Cozinha Prática
  * **O que faz:** Aparelhos de "colocar e esquecer". Quando o cozimento termina e a panela pula para o modo "Aquecer", o consumo de energia despenca. A tomada de 16A percebe essa queda e manda um aviso para o seu celular/PC: *"A comida está pronta!"*.

- [ ] **Lava-louças e Máquina Lava e Seca**
  * **Categoria:** Tempo e Limpeza
  * **O que faz:** Ligadas em **Tomadas Inteligentes 16A**, o sistema avisa quando o ciclo de lavagem terminou (pelo monitoramento de queda de Watts), e permite programar a lava-louças para rodar apenas de madrugada, quando a tarifa de energia é mais barata.

- [ ] **Panela Airfryer**
  * **Categoria:** Cozinha
  * **O que faz:** Utilizando a mesma lógica das tomadas de 16A, notifica no celular assim que o alimento terminar o tempo de cozimento e a energia for cortada, evitando que a comida esfrie na panela enquanto você trabalha.

- [ ] **Fogão de Indução**
  * **Categoria:** Cocção Segura e Rápida
  * **O que faz:** Aquece panelas na metade do tempo e não gera chamas.
  * **Atenção Técnica:** Puxa muita energia (até 7000W). **Nunca** tentar plugar em tomadas inteligentes. O monitoramento elétrico dele deve ser feito exclusivamente pelas garras "CT Clamp" lá no quadro de disjuntores (Fase 2).

  ---

## 🧰 FASE 6: Arsenal de Instalação e Manutenção Pessoal
*O kit definitivo para executar o projeto em casa com segurança (NR-10) e praticidade extrema, sem depender de eletricistas para tarefas básicas.*

- [ ] **Detector de Tensão (Caneta) e Multímetro Digital**
  * **Categoria:** Segurança de Vida
  * **Prioridade:** 0 (Máxima - Não abra uma tomada sem isso)
  * **O que faz:** Identifica qual fio é a "Fase" (que dá choque) e qual é o "Retorno" ou "Neutro". A caneta detecta energia só de encostar no fio (sem precisar descascar). O multímetro mede se a tomada é 110V ou 220V para não queimar aparelhos.
  * **Especificações para compra:** Caneta Detectora de Tensão por Aproximação (NCV) com bipe sonoro. Multímetro digital básico (com bipe de continuidade).

- [ ] **Conectores de Engate Rápido (O fim da fita isolante)**
  * **Categoria:** Instalação Rápida e Segura
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Substitui emendas de fios enrolados com fita isolante (que ressecam, dão mau contato e podem causar incêndio). Você apenas levanta a alavanquinha, insere o fio e abaixa. Conexão perfeita em 2 segundos.
  * **Especificações para compra:** Conectores originais da marca **WAGO (Linha 221)**. Compre um pequeno kit com conectores de 2, 3 e 5 vias.

- [ ] **Kit de Chaves Isoladas (Fenda e Philips)**
  * **Categoria:** Ferramentas Manuais
  * **Prioridade:** 1 (Alta)
  * **O que faz:** Essenciais para soltar os parafusos dos espelhos de tomada e fixar os interruptores inteligentes na parede.
  * **Especificações para compra:** Exija chaves com cabo e haste emborrachados com **Certificação 1000V (Isolamento NR-10)**. Se a chave esbarrar sem querer no fio vivo da parede, você não toma choque.

- [ ] **Alicate Desencapador Automático**
  * **Categoria:** Praticidade / Otimização de Tempo
  * **Prioridade:** 2 (Média)
  * **O que faz:** Em vez de usar faca ou tesoura (o que corta os fios de cobre e enfraquece a energia), você coloca o fio na ponta desse alicate e aperta. Ele corta a capa plástica do fio na medida perfeita em 1 segundo.
  * **Especificações para compra:** Modelo tipo "Frontal" (geralmente com cabo amarelo ou vermelho e regulagem de pressão). 

- [ ] **Fita Dupla Face de Alta Performance**
  * **Categoria:** Fixação Invisível
  * **Prioridade:** 2 (Média)
  * **O que faz:** Usada para colar os Sensores de Porta/Janela, Sensores de Presença mmWave e os Motores de Persiana sem precisar furar a parede com furadeira.
  * **Especificações para compra:** Fita **3M VHB** (autêntica). É a única que aguenta o calor e a umidade sem despencar o seu sensor no chão de madrugada.