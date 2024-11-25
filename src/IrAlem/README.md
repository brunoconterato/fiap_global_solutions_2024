# Ir Além: Integração Completa do Sistema de Gerenciamento de Energia

Este documento descreve a integração completa do sistema de gerenciamento de energia, conectando as diferentes partes do projeto:  AICSS (sistema de iluminação com ESP32), CTWP (sistema de gerenciamento em Python), CDS (banco de dados), e SCR (análise estatística com R).  O foco principal desta seção é a integração dos dados entre as diferentes partes do projeto, demonstrando a funcionalidade do sistema integrado.

## Funcionamento

O sistema funciona da seguinte maneira:

1. **AICSS (ESP32):** O microcontrolador ESP32, utilizando sensores (ou botões simulados), monitora a luminosidade e presença (ou entradas de botões)  e controla a iluminação interna e externa da residência. Os dados são simulados no Wokwi, e exportados manualmente (luminosidade, presença e status do LED) para um arquivo CSV.


2. **CTWP (Python):** O programa em Python lê os dados do arquivo CSV gerado pelo AICSS, simulando os dados de consumo de energia para os dispositivos controlados pelo sistema de iluminação.  Ele também interage com o banco de dados PostgreSQL (CDS), gravando o consumo de energia dos dispositivos em tempo real e lendo dados históricos para gerar relatórios.  Finalmente, a interface gráfica do sistema Python apresenta os dados de consumo, permitindo a visualização e análise.

3. **CDS (PostgreSQL):** O banco de dados PostgreSQL armazena os dados de consumo de energia coletados pelo sistema Python. Uma tabela específica (`CONSUMO_RESIDENCIAL`) foi criada para armazenar os dados de consumo residencial simulados.

4. **SCR (R):** (Opcional, dependendo do tempo disponível)  A análise estatística usando R pode ser integrada posteriormente, lendo dados do banco de dados PostgreSQL para uma análise mais completa do consumo de energia e identificação de padrões.


## Configuração Local do PostgreSQL

Para executar a aplicação localmente, você precisará ter o PostgreSQL instalado e configurado.  As seguintes instruções assumem que você já possui o PostgreSQL instalado.


**1. Crie o Usuário e Banco de Dados:**

Esse script está localizado no diretório `src/CTWP/script/initialize_db.sql`.

Abra o console psql (com privilégios de administrador) e execute os seguintes comandos:

```sql
CREATE USER fiap_gs WITH PASSWORD 'fiap_gs';
CREATE DATABASE gs_energia_residencial OWNER fiap_gs;
```

**2. Crie a Tabela CONSUMO_RESIDENCIAL:**

Conecte-se ao banco de dados `gs_energia_residencial` como o usuário `fiap_gs` e execute o comando SQL abaixo:


```sql
\c gs_energia_residencial fiap_gs

-- Grant all privileges on the database to the user
GRANT ALL PRIVILEGES ON DATABASE gs_energia_residencial TO fiap_gs;


-- Create the table to store the simulated residential energy consumption data
CREATE TABLE CONSUMO_RESIDENCIAL (
    id_consumo SERIAL PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE,
    consumo_potencia_kw DECIMAL(10,4),
    frequencia_atualizacao_s INT,
    dispositivo VARCHAR(50),
    status VARCHAR(10)
);
-- CREATE INDEX idx_consumo_residencial_timestamp ON CONSUMO_RESIDENCIAL(timestamp);

-- Grant all privileges on the table to the user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fiap_gs;

-- Grant usage on the sequence (this is the crucial part)
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO fiap_gs;
```

**3. Configure o Arquivo de Conexão do Python:**

Modifique o arquivo `main.py` (ou o arquivo correspondente no seu projeto) para incluir as credenciais corretas para conectar ao seu banco de dados PostgreSQL:

```python
# ... (código existente) ...
self.conn = psycopg2.connect(host="localhost", database="gs_energia_residencial", user="fiap_gs", password="fiap_gs")
# ... (código existente) ...
```

Substitua `"localhost"` pelo nome do host do seu banco de dados se ele não estiver na mesma máquina.


**4. Execução da Aplicação:**

Após a configuração, execute o programa Python. O sistema irá gravar os dados simulados no banco de dados.


## Dados de Entrada (AICSS Simulado)

O arquivo CSV com os dados simulados do AICSS (luminosidade, presença e status do LED) deve ser colocado em um local acessível ao script Python. O nome do arquivo e o caminho devem ser ajustados no script `main.py`.  Um exemplo de arquivo CSV:


```csv
timestamp,consumo_potencia_kw,frequencia_atualizacao_s,dispositivo,status
10371,0.0010,5,led_externo_1,ligado_min
15397,0.0100,5,led_externo_1,ligado_max
20423,0.0100,5,led_externo_1,ligado_max
25449,0.0100,5,led_externo_1,ligado_max
30475,0.0100,5,led_externo_1,ligado_max
35501,0.0100,5,led_externo_1,ligado_max
35515,0.0100,5,led_interno_1,ligado
40528,0.0100,5,led_externo_1,ligado_max
45554,0.0100,5,led_externo_1,ligado_max
```

## Cálculo de Energia Consumida

Cada registro na tabela CONSUMO_RESIDENCIAL representa o consumo de energia de um dispositivo em um determinado instante. Para calcular a energia total consumida por um dispositivo em um período, considere os seguintes fatores:

* consumo_potencia_kw: Potência consumida pelo dispositivo em kW no instante da medição.
* frequencia_atualizacao_s: Intervalo de tempo em segundos entre as medições.

A energia consumida (em kWh) para cada registro é calculada usando a fórmula:

Energia (kWh) = consumo_potencia_kw * frequencia_atualizacao_s / 3600

A energia total consumida por um dispositivo em um período é a soma das energias calculadas para cada registro desse dispositivo naquele período. A unidade resultante é kWh. Isso permite um cálculo mais preciso do consumo energético, considerando a frequência de atualização dos dados.

## Conclusão

Esta integração demonstra a capacidade de conectar diferentes tecnologias e criar um sistema completo para o gerenciamento de energia.  A flexibilidade do sistema permite a expansão para incluir mais sensores, dispositivos e algoritmos de otimização avançados.  A adição de dados reais e a análise estatística mais robusta em R, complementarão o projeto.

