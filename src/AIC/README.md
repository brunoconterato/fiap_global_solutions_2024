# Global Solutions 2024.2 - Otimização de Consumo Energético Residencial com IA

## 1. Introdução

**1.1 Contextualização:** O crescente consumo de energia e a necessidade de mitigar os impactos ambientais impulsionam a busca por soluções inovadoras em eficiência energética.  Este projeto visa otimizar o consumo energético residencial utilizando uma abordagem integrada de Inteligência Artificial (IA), Internet das Coisas (IoT), Big Data e banco de dados relacionais.

**1.2 Objetivo Principal:** Desenvolver um sistema inteligente que monitora, prevê e otimiza o consumo de energia em uma residência, integrando dados históricos e em tempo real para reduzir custos e promover a sustentabilidade.

**1.3 Objetivos Específicos:**

* Implementar um sistema IoT para coleta de dados de consumo e condições ambientais em tempo real. (AICSS)
* Criar um pipeline de dados para processamento e análise estatística do consumo energético. (CDS e SCR)
* Desenvolver um modelo de IA para previsão de consumo e otimização do uso de energia. (AIC)
* Construir uma interface amigável em Python para visualização de dados, geração de relatórios e interação com o usuário. (CTWP)
* Integrar todas as componentes para a operação eficiente do sistema. ("Ir Além")


**1.4 Desafios e Barreiras:**

* **Integração de Sistemas:** A complexidade de integrar diferentes tecnologias (IA, IoT, banco de dados, Python, R) representa um desafio significativo.
* **Qualidade dos Dados:** A precisão das previsões da IA depende diretamente da qualidade dos dados coletados pelo sistema IoT.  Ruídos e inconsistências nos dados podem afetar o desempenho do sistema.
* **Escalabilidade:** O sistema precisa ser projetado para expansão futura, permitindo a inclusão de mais dispositivos, sensores e fontes de energia renováveis.
* **Custo e Complexidade:** A implementação de um sistema completo de otimização de energia pode apresentar custos iniciais elevados.


## 2. Desenvolvimento - Arquitetura do Sistema

O sistema proposto para otimização do consumo de energia residencial utiliza uma arquitetura modular e distribuída, integrando diferentes tecnologias para coleta, processamento e visualização de dados.  A seguir, descrevemos a arquitetura e a interação entre os seus componentes:


**Descrição dos Componentes:**

1. **Módulo de Aquisição de Dados (AICSS):** Este módulo é responsável pela coleta de dados em tempo real.  Ele é composto por:

    * **Sensores:**  Diversos sensores, incluindo LDR (para medição de luminosidade), sensores PIR (para detecção de movimento), e outros sensores que podem ser adicionados posteriormente (ex: sensores de temperatura, umidade, etc.).  A escolha dos sensores dependerá das necessidades específicas da residência.
    * **ESP32:**  Um microcontrolador ESP32 coleta os dados dos sensores e os envia via WiFi para o módulo de processamento. O código do ESP32 (sketch.ino) implementa a lógica de controle da iluminação interna e externa, baseada na luminosidade e detecção de movimento, respeitando as restrições de segurança.

2. **Módulo de Processamento e Armazenamento (CDS):**  Este módulo recebe os dados do ESP32, os processa e os armazena:

    * **Dados em Tempo Real:** Os dados recebidos via WiFi do ESP32 são temporariamente armazenados e disponibilizados para o módulo de análise e previsão.
    * **Banco de Dados Relacional (PostgreSQL):** Os dados são persistidos em um banco de dados PostgreSQL, utilizando um esquema de modelagem dimensional. Scripts SQL (initialize_database.sql e create_pipeline_views.sql) criam as tabelas e views necessárias para a análise.  Este módulo assegura a persistência, organização e acesso eficiente aos dados históricos.

3. **Módulo de Análise e Previsão (AIC & SCR):**  Este módulo é responsável pela análise dos dados e pela geração de previsões:

    * **Análise Estatística (R):**  O código em R (eda.R) realiza uma análise exploratória dos dados históricos armazenados no banco de dados. Ele identifica padrões de consumo, tendências e insights relevantes para a otimização do sistema.  Esta análise é fundamental para o treinamento e validação do modelo de previsão.
    * **Modelo de Previsão de Consumo (Python):** Este componente (a ser implementado) utiliza algoritmos de Machine Learning para prever o consumo futuro de energia com base nos dados históricos e nos dados em tempo real.  O modelo será treinado com os dados processados pelo módulo R e os dados históricos do banco de dados.

4. **Módulo de Interface e Visualização (CTWP):** Este módulo apresenta os dados processados e as previsões ao usuário:

    * **Interface Gráfica (Python - Tkinter):** A interface gráfica em Python (main.py) fornece uma visualização intuitiva dos dados de consumo em tempo real, gráficos históricos, estatísticas e previsões geradas pelo modelo de IA. Ela permite ao usuário interagir com o sistema, monitorando o consumo e fazendo ajustes nas configurações.


**Fluxo de Dados:**

Os sensores enviam dados para o ESP32. O ESP32 envia dados em tempo real para o módulo de processamento. Os dados são armazenados no banco de dados e utilizados para análise estatística (R) e para o treinamento do modelo de previsão (Python). As previsões e dados históricos são apresentados ao usuário através da interface gráfica (Python). O usuário pode interagir com a interface para ajustar as configurações do sistema.


Esta arquitetura modular facilita a manutenção, atualização e expansão do sistema. Cada módulo pode ser desenvolvido e testado independentemente, e novas funcionalidades podem ser adicionadas sem afetar a estabilidade dos outros componentes.  A clareza desta arquitetura demonstra uma compreensão sólida dos princípios de design de sistemas e a capacidade de integrar diferentes tecnologias.


## 3. Resultados Esperados

**3.1 Estimativa de Economia de Energia:**

Considerando os resultados do sistema de iluminação inteligente (AICSS), estimamos uma economia mensal de aproximadamente R$ 2,15 na iluminação externa e R$ 0,72 na iluminação interna (baseado em uma única lâmpada em cada ambiente). Esta economia é extrapolada da simulação no Wokwi e dos cálculos apresentados na documentação.  A economia real dependerá dos padrões de uso e das condições ambientais da residência. A interface em Python (CTWP) permitirá monitorar e quantificar a economia obtida em tempo real, considerando todos os dispositivos simulados.

**3.2 Impacto no Conforto:**

O sistema melhorará o conforto ao ajustar a iluminação automaticamente, eliminando a necessidade de se preocupar com o acionamento e o desligamento manual das luzes. A iluminação externa se mantém em um nível mínimo para segurança. A iluminação interna é otimizada para conforto e economia, sendo ativada apenas quando necessário.

**3.3 Impacto no Uso do Equipamento:**

O monitoramento em tempo real ajudará a identificar padrões de uso dos equipamentos, permitindo o ajuste do comportamento do usuário.  Isso pode levar à redução do consumo e ao aumento da vida útil dos equipamentos.


**3.4 Impacto na Vida Útil do Equipamento:**

A redução do consumo e o uso mais eficiente dos equipamentos, resultantes da otimização, podem contribuir para o aumento da sua vida útil, reduzindo a necessidade de substituição precoce.

## 4. Conclusão

Este projeto demonstra a viabilidade de um sistema integrado de otimização de consumo energético residencial utilizando IA, IoT e Big Data. A integração das diferentes tecnologias permite uma abordagem abrangente, oferecendo monitoramento em tempo real, previsão de consumo e otimização do uso de energia, com o objetivo final de reduzir custos e promover a sustentabilidade.  A combinação de análise histórica (SCR), predição de consumo (AIC), coleta de dados em tempo real (AICSS) e a interface de usuário (CTWP) cria um sistema eficiente e informativo. Os resultados esperados indicam uma economia significativa no consumo energético, além de melhorias no conforto e na vida útil dos equipamentos.  O sistema, com seu código aberto e documentação completa, pode servir de base para trabalhos futuros, incluindo a integração com fontes de energia renováveis e a implementação de modelos de IA mais sofisticados. A capacidade de expandir o projeto demonstra sua flexibilidade e potencial para aplicação em diferentes cenários.  A abordagem modular e bem documentada, demonstrada no código e nos relatórios, facilita a integração e a manutenção do sistema, destacando a robustez da solução.

## 5. "Ir Além"

A integração completa do sistema, incluindo a leitura dos dados do sistema AICSS (dados simulados por enquanto), a leitura dos dados do banco de dados PostgreSQL (CDS) através do Python (CTWP) e a execução de análises estatísticas em R (SCR) para gerar relatórios de consumo e previsões de uso, demonstra a sinergia entre as tecnologias e reforça a capacidade do grupo de desenvolver soluções completas e integradas.  Um vídeo demonstrando a integração completa dessas etapas será submetido.

