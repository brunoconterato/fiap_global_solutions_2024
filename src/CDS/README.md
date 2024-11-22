# Análise de Consumo de Energia Elétrica - Projeto GS

## 📊 Sobre o Projeto

Este projeto faz parte da Global Solution, focando no desenvolvimento de uma solução baseada em Data Science, IoT e Python para otimizar o consumo de energia em diferentes ambientes (residenciais, comerciais e urbanos). O objetivo principal é melhorar a eficiência energética através da análise de dados históricos e integração com fontes renováveis.

## 🎯 Objetivos

- Analisar tendências históricas de consumo de energia elétrica
- Criar pipeline de dados para filtrar informações específicas do Brasil
- Avaliar demanda energética e consumo per capita
- Identificar padrões de consumo para otimização
- Integrar análise com sistemas IoT para tomada de decisão em tempo real

## 📑 Dados Disponíveis

### Estrutura dos Dados

O conjunto de dados inclui as seguintes dimensões principais:

1. **Dimensão Temporal**
   - Data (AAAAMMDD)

2. **Tipo de Consumidor**
   - Cativo
   - Livre

3. **Localização**
   - Sistema (Subsistema ou Sistemas Isolados)
   - UF (Unidade da Federação)

4. **Classificação de Consumo**
   - Setor Econômico (3 níveis)
   - Tensão de Fornecimento (3 níveis)
   - Faixas de Consumo (2 níveis)

5. **Métricas**
   - Número de Consumidores
   - Consumo em MWh

### Detalhes Específicos

- **Tensão de Fornecimento**:
  - Alta Tensão: ≥ 69kV
  - Baixa Tensão: ≤ 1kV

- **Faixas de Consumo para Baixa Tensão**:
  - Convencional: 0-30 kWh, 31-100 kWh, 101-200 kWh, 201-300 kWh, 301-400 kWh, 401-500 kWh, 501-1000 kWh, > 1000 kWh
  - Baixa Renda: 0-30 kWh, 31-100 kWh, 101-200 kWh, > 200 kWh

## 🔗 Fontes de Dados

1. **Dados Processados**:
   - [Consumo de Energia Elétrica - EPE](https://www.epe.gov.br/pt/publicacoes-dados-abertos/publicacoes/consumo-de-energia-eletrica)

2. **Dados Brutos e Dicionário**:
   - [Anuário Estatístico de Energia Elétrica - EPE](https://www.epe.gov.br/pt/publicacoes-dados-abertos/dados-abertos/dados-do-anuario-estatistico-de-energia-eletrica)

## 🛠 Tecnologias Utilizadas

- Python para processamento e análise de dados
- Banco de dados relacional para armazenamento
- Ferramentas de IoT para coleta de dados em tempo real
- Bibliotecas de Data Science para análise preditiva

## 📈 Análises Previstas

1. Tendências de consumo ao longo do tempo
2. Distribuição por setor econômico
3. Análise comparativa entre regiões
4. Impacto das faixas de tensão no consumo
5. Relação entre número de consumidores e consumo total
6. Padrões sazonais de consumo

## 🎁 Entregáveis Esperados

- Pipeline de dados automatizado
- Análises estatísticas do consumo
- Dashboards interativos
- Modelos preditivos de consumo
- Documentação técnica completa


## 💾 Configuração do Banco de Dados

### Pré-requisitos
- PostgreSQL instalado
- Privilégios de administrador no banco de dados
- psql ou outro cliente SQL compatível com PostgreSQL

### Scripts de Configuração

O banco de dados é configurado em duas etapas, utilizando os seguintes scripts:

1. `src/initialize_database.sql`: Cria a estrutura inicial do banco de dados
2. `src/create_pipeline_views.sql`: Configura as views para análise dos dados

#### Passo 1: Criar Estrutura do Banco de Dados

Execute o script `src/initialize_database.sql`:

```sql
-- Criação das tabelas dimensionais
CREATE TABLE DIM_TEMPO (
    data DATE PRIMARY KEY,
    ano INT,
    mes INT,
    trimestre INT,
    mes_nome VARCHAR(20),
    CONSTRAINT chk_mes CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT chk_trimestre CHECK (trimestre BETWEEN 1 AND 4)
);

CREATE TABLE DIM_LOCALIZACAO (
    id_localizacao SERIAL PRIMARY KEY,
    uf VARCHAR(2),
    sistema VARCHAR(50),
    regiao VARCHAR(20),
    populacao DECIMAL(12,2),
    CONSTRAINT chk_uf CHECK (uf ~ '^[A-Z]{2}$')
);

CREATE TABLE DIM_CONSUMIDOR (
    id_consumidor SERIAL PRIMARY KEY,
    tipo_consumidor VARCHAR(10),
    faixa_consumo_n1 VARCHAR(50),
    faixa_consumo_n2 VARCHAR(50),
    CONSTRAINT chk_tipo_consumidor CHECK (tipo_consumidor IN ('Cativo', 'Livre'))
);

CREATE TABLE DIM_TENSAO (
    id_tensao SERIAL PRIMARY KEY,
    tensao_n1 VARCHAR(50),
    tensao_n2 VARCHAR(50),
    tensao_n3 VARCHAR(50)
);

CREATE TABLE DIM_SETOR (
    id_setor SERIAL PRIMARY KEY,
    setor_n1 VARCHAR(50),
    setor_n2 VARCHAR(50),
    setor_n3 VARCHAR(50)
);

-- Criação da tabela fato
CREATE TABLE FATO_CONSUMO (
    id_consumo SERIAL PRIMARY KEY,
    data DATE,
    id_localizacao INT,
    id_consumidor INT,
    id_tensao INT,
    id_setor INT,
    consumo_mwh DECIMAL(12,2),
    numero_consumidores INT,
    FOREIGN KEY (data) REFERENCES DIM_TEMPO(data),
    FOREIGN KEY (id_localizacao) REFERENCES DIM_LOCALIZACAO(id_localizacao),
    FOREIGN KEY (id_consumidor) REFERENCES DIM_CONSUMIDOR(id_consumidor),
    FOREIGN KEY (id_tensao) REFERENCES DIM_TENSAO(id_tensao),
    FOREIGN KEY (id_setor) REFERENCES DIM_SETOR(id_setor)
);

-- Índices para otimização de consultas
CREATE INDEX idx_fato_consumo_data ON FATO_CONSUMO(data);
CREATE INDEX idx_fato_consumo_localizacao ON FATO_CONSUMO(id_localizacao);
CREATE INDEX idx_fato_consumo_setor ON FATO_CONSUMO(id_setor);
```

#### Passo 2: Criar Views de Análise

Execute o script `src/create_pipeline_views.sql`:

```sql
-- Criação de views para análises específicas

-- View para análise de tendência de consumo mensal
CREATE VIEW vw_tendencia_consumo_mensal AS
SELECT 
    dt.ano,
    dt.mes,
    dl.uf,
    dl.sistema,
    SUM(fc.consumo_mwh) as consumo_total,
    SUM(fc.numero_consumidores) as total_consumidores
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, dt.mes, dl.uf, dl.sistema
ORDER BY dt.ano, dt.mes;

-- View para cálculo do consumo per capita por UF
CREATE VIEW vw_consumo_per_capita AS
SELECT 
    dt.ano,
    dl.uf,
    SUM(fc.consumo_mwh) as consumo_total,
    MAX(dl.populacao) as populacao,
    ROUND(SUM(fc.consumo_mwh) / MAX(dl.populacao), 2) as consumo_per_capita
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, dl.uf
ORDER BY dt.ano, dl.uf;

-- View para análise de demanda por setor econômico
CREATE VIEW vw_demanda_setor AS
SELECT 
    dt.ano,
    ds.setor_n1,
    ds.setor_n2,
    dl.regiao,
    SUM(fc.consumo_mwh) as consumo_total,
    COUNT(DISTINCT fc.id_consumidor) as num_consumidores
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_SETOR ds ON fc.id_setor = ds.id_setor
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, ds.setor_n1, ds.setor_n2, dl.regiao
ORDER BY dt.ano, consumo_total DESC;
```

### Explicação das Views de Análise

O script `create_pipeline_views.sql` cria três views principais para análise dos dados. Abaixo está a explicação detalhada de cada uma:

#### 1. View `vw_tendencia_consumo_mensal`

```sql
CREATE VIEW vw_tendencia_consumo_mensal AS
SELECT 
    dt.ano,
    dt.mes,
    dl.uf,
    dl.sistema,
    SUM(fc.consumo_mwh) as consumo_total,
    SUM(fc.numero_consumidores) as total_consumidores
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, dt.mes, dl.uf, dl.sistema
ORDER BY dt.ano, dt.mes;
```

**Retorno:**
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| ano | INT | Ano de referência |
| mes | INT | Mês de referência (1-12) |
| uf | VARCHAR(2) | Sigla do estado |
| sistema | VARCHAR(50) | Nome do subsistema ou sistema isolado |
| consumo_total | DECIMAL | Soma total do consumo em MWh no período |
| total_consumidores | INT | Número total de consumidores no período |

**Uso:** Análise de tendências mensais de consumo por estado e sistema elétrico.

#### 2. View `vw_consumo_per_capita`

```sql
CREATE VIEW vw_consumo_per_capita AS
SELECT 
    dt.ano,
    dl.uf,
    SUM(fc.consumo_mwh) as consumo_total,
    MAX(dl.populacao) as populacao,
    ROUND(SUM(fc.consumo_mwh) / MAX(dl.populacao), 2) as consumo_per_capita
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, dl.uf
ORDER BY dt.ano, dl.uf;
```

**Retorno:**
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| ano | INT | Ano de referência |
| uf | VARCHAR(2) | Sigla do estado |
| consumo_total | DECIMAL | Consumo total em MWh |
| populacao | DECIMAL | População do estado |
| consumo_per_capita | DECIMAL | Consumo médio por habitante (MWh/habitante) |

**Uso:** Análise comparativa do consumo de energia por habitante entre diferentes estados.

#### 3. View `vw_demanda_setor`

```sql
CREATE VIEW vw_demanda_setor AS
SELECT 
    dt.ano,
    ds.setor_n1,
    ds.setor_n2,
    dl.regiao,
    SUM(fc.consumo_mwh) as consumo_total,
    COUNT(DISTINCT fc.id_consumidor) as num_consumidores
FROM FATO_CONSUMO fc
JOIN DIM_TEMPO dt ON fc.data = dt.data
JOIN DIM_SETOR ds ON fc.id_setor = ds.id_setor
JOIN DIM_LOCALIZACAO dl ON fc.id_localizacao = dl.id_localizacao
GROUP BY dt.ano, ds.setor_n1, ds.setor_n2, dl.regiao
ORDER BY dt.ano, consumo_total DESC;
```

**Retorno:**
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| ano | INT | Ano de referência |
| setor_n1 | VARCHAR(50) | Classificação primária do setor econômico |
| setor_n2 | VARCHAR(50) | Classificação secundária do setor econômico |
| regiao | VARCHAR(20) | Região geográfica |
| consumo_total | DECIMAL | Consumo total em MWh do setor |
| num_consumidores | INT | Número de consumidores únicos no setor |

**Uso:** Análise setorial do consumo de energia, permitindo identificar os setores econômicos com maior demanda por região.

### Exemplos de Consultas

```sql
-- Exemplo 1: Consumo mensal total em 2023 para São Paulo
SELECT * FROM vw_tendencia_consumo_mensal 
WHERE ano = 2023 AND uf = 'SP';

-- Exemplo 2: Top 5 estados com maior consumo per capita em 2023
SELECT * FROM vw_consumo_per_capita 
WHERE ano = 2023 
ORDER BY consumo_per_capita DESC 
LIMIT 5;

-- Exemplo 3: Consumo por setor industrial na região Sudeste
SELECT * FROM vw_demanda_setor 
WHERE setor_n1 = 'Industrial' 
AND regiao = 'Sudeste' 
ORDER BY consumo_total DESC;
```

### Como Executar os Scripts

1. Abra o terminal ou prompt de comando
2. Conecte-se ao PostgreSQL usando psql:
```bash
psql -U seu_usuario -d seu_banco
```
3. Execute os scripts na ordem correta:
```bash
\i caminho/para/initialize_database.sql
\i caminho/para/create_pipeline_views.sql
```

### Verificação da Instalação

Para verificar se tudo foi instalado corretamente, execute:

```sql
-- Verificar tabelas criadas
\dt

-- Verificar views criadas
\dv

-- Testar uma view
SELECT * FROM vw_tendencia_consumo_mensal LIMIT 5;
```

### Notas Importantes

- Certifique-se de ter backup dos dados antes de executar os scripts
- Os scripts devem ser executados com privilégios de administrador
- As constraints garantem a integridade dos dados
- Os índices otimizam as consultas mais frequentes
- As views facilitam a análise dos dados
- Os scripts podem ser adaptados conforme necessidade

## 🎯 Conclusão

Este projeto de análise de consumo de energia elétrica foi desenvolvido como parte da Global Solution, com foco em criar uma solução baseada em Data Science para otimização do consumo energético. A estrutura implementada oferece:

### 📊 Principais Funcionalidades
- Análise granular do consumo de energia por região, setor e período
- Acompanhamento de tendências de consumo ao longo do tempo
- Cálculo de métricas per capita para comparações entre regiões
- Base para integração com sistemas IoT e análise em tempo real

### 💡 Benefícios
1. **Tomada de Decisão:**
   - Insights baseados em dados históricos
   - Identificação de padrões de consumo
   - Suporte a decisões de eficiência energética

2. **Sustentabilidade:**
   - Monitoramento do impacto de iniciativas de economia
   - Base para integração com fontes renováveis
   - Suporte a políticas de redução de consumo

3. **Escalabilidade:**
   - Estrutura modular e expansível
   - Preparado para inclusão de novos dados
   - Facilidade de integração com outras ferramentas

### 🚀 Próximos Passos
- Implementação de modelos preditivos
- Integração com sistemas IoT em tempo real
- Desenvolvimento de dashboards interativos
- Expansão para análise de fontes renováveis
- Inclusão de variáveis climáticas e sazonais

### 📈 Impacto Esperado
O sistema desenvolvido tem potencial para contribuir significativamente com:
- Redução do consumo energético
- Otimização de recursos
- Promoção da sustentabilidade
- Conscientização sobre uso de energia
- Suporte a políticas públicas de eficiência energética

Este projeto estabelece uma base sólida para o desenvolvimento de soluções mais avançadas em eficiência energética, combinando análise de dados históricos com potencial para integração com tecnologias modernas de IoT e automação.
