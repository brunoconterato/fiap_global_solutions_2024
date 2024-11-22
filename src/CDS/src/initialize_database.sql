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