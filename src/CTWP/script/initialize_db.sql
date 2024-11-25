-- Create the user
CREATE USER fiap_gs WITH PASSWORD 'fiap_gs';

-- Create the database owned by the user
CREATE DATABASE gs_energia_residencial OWNER fiap_gs;

-- Connect to the newly created database as the new user
-- \c gs_energia_residencial fiap_gs

-- Grant all privileges on the database to the user (this is still needed for other operations)
GRANT ALL PRIVILEGES ON DATABASE gs_energia_residencial TO fiap_gs;

-- Create the table
CREATE TABLE CONSUMO_RESIDENCIAL (
    id_consumo SERIAL PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE,
    consumo_potencia_kw DECIMAL(10,4),
    frequencia_atualizacao_s INT,
    dispositivo VARCHAR(50),
    status VARCHAR(10)
);

-- Grant all privileges on the table to the user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fiap_gs;

-- Alternatively, grant specific privileges (more secure):
--GRANT SELECT, INSERT, UPDATE, DELETE ON CONSUMO_RESIDENCIAL TO fiap_gs;

    -- Reset database
    TRUNCATE TABLE CONSUMO_RESIDENCIAL;