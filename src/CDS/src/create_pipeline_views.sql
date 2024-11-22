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