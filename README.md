# FIAP - Faculdade de Informática e Administração Paulista

<p align="center">
<a href= "https://www.fiap.com.br/"><img src="assets/logo-fiap.png" alt="FIAP - Faculdade de Informática e Admnistração Paulista" border="0" width=40% height=40%></a>
</p>

<br>

# Global Solution

## GreenBytes

![FIAP Global Solutions 2024](./assets/logo.jpeg)

## 👨‍🎓 Integrantes: 
## 👨‍🎓 Integrantes: 
- <a href="https://www.linkedin.com/in/brunoconterato">Bruno Conterato</a>
- <a href="https://www.linkedin.com/in/willianpmarques">Willian Pinheiro Marques</a> 
- <a href="https://www.linkedin.com/in/robertobesser">Roberto Besser</a>
- <a href="https://www.linkedin.com/in/ludimila-vi">Ludimila Vitorino</a>

## 👩‍🏫 Professores:
### Tutor(a) 
- <a href="https://www.linkedin.com/in/lucas-gomes-moreira-15a8452a/">Lucas Gomes Moreira</a>
### Coordenador(a)
- <a href="https://www.linkedin.com/in/profandregodoi/">André Godoi</a>


## 📜 Descrição

O GreenBytes desenvolveu um sistema inteligente para otimizar o consumo de energia residencial, integrando Inteligência Artificial (IA), Internet das Coisas (IoT), e análise de dados com Python e R, além de um banco de dados relacional (PostgreSQL).  Nosso projeto abrange múltiplos aspectos da eficiência energética, desde a coleta de dados em tempo real até a previsão de consumo e a geração de relatórios personalizados.

**AIC (Artificial Intelligence Challenges):**  Utilizamos o artigo fornecido como base para projetar um sistema de previsão de consumo energético residencial.  Este sistema, ainda a ser implementado plenamente, utilizará dados históricos e em tempo real para prever o consumo futuro e otimizar o uso de eletrodomésticos.  A previsão de consumo permitirá ações proativas para reduzir custos e promover a sustentabilidade. Estimamos uma economia de pelo menos 15% no consumo total, com impacto positivo no conforto e na vida útil dos equipamentos.

**AICSS (Artificial Intelligence with Computer Systems and Sensors):** Desenvolvemos um sistema de iluminação inteligente com um ESP32, simulando um sistema completo de monitoramento da iluminação interna e externa. Utilizando sensores de luminosidade (LDR) e de presença (PIR) simulados no Wokwi, o sistema controla o brilho dos LEDs, garantindo iluminação mínima à noite (para segurança) e regulando o brilho baseado na luminosidade e na presença detectada. O código está disponível no repositório.  Um vídeo demonstrativo (link no README principal) mostra o funcionamento da solução no Wokwi. Os impactos positivos incluem a economia de energia e o aumento do conforto, enquanto os negativos são a dependência de sensores e a necessidade de calibração.

**SCR (Statistical Computing with R):**  Analisamos o banco de dados de projetos de eficiência energética da ANEEL para gerar insights sobre estratégias eficazes e identificar lacunas no programa.  Utilizamos R para análise exploratória, incluindo estatísticas descritivas, gráficos e identificação de outliers.  Identificamos tendências, como a alta eficácia de projetos no setor público e oportunidades de expansão para outros setores. Nossos resultados estão disponíveis no relatório `src/SCR/eda.md`.

**CDS (Cognitive Data Science):**  Criamos um banco de dados relacional no PostgreSQL para armazenar dados de consumo energético.  O schema dimensional facilita a análise de tendências e a criação de pipelines de dados, permitindo a filtragem e análise de dados de demanda de energia elétrica e consumo per capita.  A estrutura do banco de dados e os scripts SQL são descritos detalhadamente em `src/CDS/README.md`.

**CTWP (Computational Thinking with Python):**  Desenvolvemos uma aplicação Python com interface gráfica (Tkinter) para o monitoramento em tempo real do consumo de energia.  A interface simula o consumo de diversos dispositivos, exibindo dados em gráficos interativos e calculando o custo estimado.  A aplicação também grava os dados simulados em nosso banco de dados PostgreSQL. O código está disponível em `src/CTWP/main.py`.

**Ir Além:** Integramos as soluções AICSS, CDS e SCR com a aplicação Python, consolidando um sistema completo.  Um vídeo (link no README principal) demonstra a integração e a funcionalidade completa do sistema, incluindo a leitura de dados simulados do AICSS, a interação com o banco de dados CDS e a análise com R.


## ℹ️ Mais informações

- [**Link youtube AICSS - Sensores IOT**](https://youtu.be/yVlZ5D9Tw1k)

- [**Link youtube Integração**](https://youtu.be/meYFQyx6YCE)

- [**Link Github Repositório (Códigos + Documentação**)](https://github.com/brunoconterato/fiap_global_solutions_2024)


## 📁 Estrutura de pastas
    
```python
.
├── assets      # Pasta com imagens do projeto.
│   ├── logo-fiap.png  # Logotipo da FIAP.
│   └── logo.jpeg     # Logotipo do grupo GreenBytes.
├── checklist.md # Checklist de atividades da Global Solutions.
├── README.md    # Arquivo principal com descrição geral do projeto.
├── requirements.txt # Lista de dependências Python (não descrito na atividade).
└── src          # Pasta com código-fonte e documentação por módulo.
    ├── AIC      # Módulo relacionado ao desafio de IA.
    │   └── README.md # Descrição do módulo AIC, contextualização, objetivos, desafios e resultados esperados.
    ├── AICSS     # Módulo referente ao sistema de iluminação com ESP32.
    │   ├── assets # Imagens do AICSS.
    │   │   ├── equatorial_cost_19_11_2024.png  # Print do custo da energia utilizado nos cálculos.
    │   │   └── sensors_diagram.png           # Diagrama dos sensores.
    │   ├── diagram.json  # Diagrama do circuito do Wokwi em JSON.
    │   ├── docs      # Documentação do módulo AICSS.
    │   │   ├── other  # Outros documentos do AICSS.
    │   │   │   ├── cost_estimation_external_illunination_system.md # Estimativa de custos do sistema de iluminação externo.
    │   │   │   ├── cost_estmation_internal_illumination_system.md # Estimativa de custos do sistema de iluminação interno.
    │   │   │   └── sensor_diagram.md  # Diagrama de componentes e descrição do sistema de sensores.
    │   │   ├── report_external_illumination_system.md # Relatório detalhado do sistema de iluminação externo.
    │   │   └── report_internal_illumination_system.md # Relatório detalhado do sistema de iluminação interno.
    │   ├── platformio.ini  # Arquivo de configuração do PlatformIO.
    │   ├── src          # Código-fonte do ESP32.
    │   │   └── sketch.ino # Código do ESP32 para controle de iluminação.
    │   ├── wokwi-project.txt # Link do projeto Wokwi.
    │   └── wokwi.toml    # Configurações do Wokwi.
    ├── CDS        # Módulo referente ao banco de dados.
    │   ├── assets     # Imagens do CDS.
    │   │   └── DER.png  # (Não descrito na atividade).
    │   ├── data       # Dados brutos utilizados para o CDS.
    │   │   ├── Anuario-Dicionario-de-Dados.pdf # Dicionário de dados do anuário estatístico.
    │   │   ├── CONSUMO MENSAL DE ENERGIA ELÉTRICA POR CLASSE.xls # Dados de consumo.
    │   │   └── Dados brutos.xlsx # Dados brutos.
    │   ├── README.md # Descrição do módulo CDS, objetivos, dados disponíveis, tecnologias e entregáveis esperados.
    │   └── src          # Scripts SQL para criação e configuração do banco de dados.
    │       ├── create_pipeline_views.sql  # Script SQL para criação das views.
    │       └── initialize_database.sql # Script SQL para criação das tabelas.
    ├── CTWP       # Módulo referente à aplicação em Python.
    │   ├── assets     # Imagens do CTWP.
    │   │   └── interface.png  # Imagem da interface gráfica.
    │   ├── README.md # Descrição do módulo CTWP, objetivos, funcionalidades, tecnologias e como usar.
    │   ├── script     # Scripts do CTWP.
    │   │   └── initialize_db.sql # Script SQL para inicializar banco de dados (usuário, database e tabela)
    │   └── src          # Código-fonte da aplicação em Python.
    │       └── main.py  # Aplicação principal em Python com interface gráfica.
    ├── IrAlem     # Módulo referente à integração completa do sistema.
    │   ├── iot_data  # Dados simulados do sistema IoT.
    │   │   └── data.csv # Dados simulados para o sistema AICSS.
    │   ├── README.md  # Descrição da integração completa e o fluxo de dados entre os módulos.
    │   └── src          # Código para a integração dos módulos.
    │       ├── eda_files # Arquivos de saída do EDA (R).
    │       │   ├── eda_13_0.png  # Gráfico de barras de tempo de uso por dispositivo.
    │       │   ├── eda_15_0.png  # Histograma do consumo de energia.
    │       │   ├── eda_17_0.png  # Gráfico de barras do consumo de energia por dispositivo.
    │       │   ├── eda_19_0.png  # Distribuição dos dispositivos.
    │       │   └── eda_21_0.png  # Análise da relação entre consumo e tempo.
    │       ├── eda.ipynb    # Notebook Jupyter para EDA (R).
    │       ├── eda.md       # Relatório da análise exploratória de dados.
    │       ├── eda.R        # Script R para EDA.
    │       └── save_iot_data.py  # Script Python para salvar dados no banco de dados.
    └── SCR        # Módulo referente à análise estatística com R.
        ├── data       # Dados para análise estatística com R.
        │   ├── dm-projetos-eficiencia-energetica-por-uso-final-da-energia.pdf # Documento da ANEEL
        │   └── e12d5430-f747-4fc7-b620-2460ed02cc17.csv # Dados da ANEEL em CSV
        └── src          # Código-fonte para análise estatística com R.
            └── eda.R        # Script R para análise exploratória de dados.
```


## 📋 Licença

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"><p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/agodoi/template">MODELO GIT FIAP</a> por <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://fiap.com.br">Fiap</a> está licenciado sobre <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">Attribution 4.0 International</a>.</p>
