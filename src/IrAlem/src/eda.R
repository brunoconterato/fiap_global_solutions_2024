# Exploratory Data Analysis (EDA) - Consumo de Energia Residencial

# Este script realiza uma análise exploratória de dados (EDA) do consumo de energia residencial,
# utilizando dados extraídos de um banco de dados PostgreSQL. Ele inclui etapas de
# processamento e visualização de dados para identificar padrões e insights.

# --------------------------------------------------------------
# 1. Carregamento de Bibliotecas
# --------------------------------------------------------------
# Bibliotecas necessárias para a análise
library(DBI)
library(RPostgres)
library(dplyr)
library(ggplot2)
library(tidyr)
library(corrplot)
library(GGally)

# --------------------------------------------------------------
# 2. Carregamento de Dados
# --------------------------------------------------------------
# Conexão com o banco de dados PostgreSQL (substitua pelas suas credenciais)
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "gs_energia_residencial",
  host = "localhost",
  port = 5432,
  user = "fiap_gs",
  password = "fiap_gs"
)

# Consulta SQL e carregamento dos dados
query <- "SELECT * FROM CONSUMO_RESIDENCIAL"
df <- dbGetQuery(con, query)

# Encerrar conexão
dbDisconnect(con)

# Conversão de tipos e criação de colunas
df <- df %>%
  mutate(
    timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "UTC"),
    energia_kwh = consumo_potencia_kw * frequencia_atualizacao_s / 3600,
    tempo_uso_h = frequencia_atualizacao_s / 3600
  )


# Visualizar as primeiras linhas do dataset
head(df)

# --------------------------------------------------------------
# 3. Análise Exploratória de Dados (EDA)
# --------------------------------------------------------------
# 3.1. Sumário Estatístico
summary(df)

# 3.2. Verificação de Valores Ausentes
valores_ausentes <- colSums(is.na(df))
print(valores_ausentes)

# 3.3. Identificação de Outliers
# Função para remover outliers usando intervalo interquartil
remover_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- IQR(x, na.rm = TRUE)
  x[x < (q1 - 1.5 * iqr) | x > (q3 + 1.5 * iqr)] <- NA
  x
}
df <- df %>%
  mutate(energia_kwh_sem_outliers = remover_outliers(energia_kwh))

# 3.4. Gráfico de barras de tempo de uso por dispositivo

# Calcular o tempo total de uso por dispositivo
tempo_uso <- df %>%
  group_by(dispositivo) %>%
  summarise(tempo_uso_h = sum(tempo_uso_h, na.rm = TRUE)) %>%
  arrange(desc(tempo_uso_h))

# Criar o gráfico de barras
ggplot(tempo_uso, aes(x = reorder(dispositivo, -tempo_uso_h), y = tempo_uso_h, fill = dispositivo)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Tempo de Uso por Dispositivo",
       x = "Dispositivo",
       y = "Tempo de Uso (horas)") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5))

# 3.5. Histograma do consumo de energia
ggplot(df, aes(x = energia_kwh)) +
  geom_histogram(binwidth = diff(range(df$energia_kwh)) / 100, 
                 fill = "steelblue", color = "black") +
  labs(title = "Distribuição do Consumo de Energia (kWh)",
       x = "Consumo (kWh)", 
       y = "Frequência") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5))


# 3.6. Gráfico de barras do consumo de energia por dispositivo

# Calcular o consumo total de energia por dispositivo
consumo_por_dispositivo <- df %>%
  group_by(dispositivo) %>%
  summarise(energia_kwh = sum(energia_kwh, na.rm = TRUE)) %>%
  arrange(desc(energia_kwh))

# Criar o gráfico de barras
ggplot(consumo_por_dispositivo, aes(x = reorder(dispositivo, -energia_kwh), y = energia_kwh, fill = dispositivo)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Consumo Total de Energia por Dispositivo",
       x = "Dispositivo",
       y = "Consumo Total (kWh)") +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5))

# 3.7. Distribuição dos Dispositivos
ggplot(df, aes(x = dispositivo)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Distribuição dos Dispositivos", x = "Dispositivo", y = "Frequência") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 3.8. Análise da relação entre consumo e tempo

# Extrair a hora do dia do timestamp
df <- df %>%
  mutate(hora = lubridate::hour(timestamp))

# Calcular o consumo médio de energia por hora
df_agregado <- df %>%
  group_by(hora) %>%
  summarise(energia_kwh = mean(energia_kwh, na.rm = TRUE))

# Criar o gráfico de linha
ggplot(df_agregado, aes(x = hora, y = energia_kwh)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  labs(title = "Consumo Médio de Energia por Hora",
       x = "Hora do Dia",
       y = "Consumo Médio (kWh)") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5))

# --------------------------------------------------------------
# 4. Conclusões
# --------------------------------------------------------------
# As visualizações e análises realizadas oferecem insights iniciais sobre o consumo
# de energia residencial. O próximo passo seria investigar relações mais específicas
# ou integrar este EDA em um pipeline de machine learning.
