# Pacotes necessários
library(dplyr)
library(tidyr)
library(ggplot2)
library(DescTools)
library(car)
library(mice)
library(GGally)
library(DBI)
library(RPostgres)

# Conexão com o banco de dados PostgreSQL (substitua pelas suas credenciais)
con <- dbConnect(RPostgres::Postgres(), 
                 dbname = "gs_energia_residencial", 
                 host = "localhost", 
                 port = 5432, 
                 user = "fiap_gs", 
                 password = "fiap_gs")

# Consulta SQL para extrair dados da tabela
query <- "SELECT * FROM CONSUMO_RESIDENCIAL"
df <- dbGetQuery(con, query)

# Desconectar do banco de dados
dbDisconnect(con)

#Converter timestamp para data e hora (assumindo que esteja em UTC)
df$timestamp <- as.POSIXct(df$timestamp, origin = "1970-01-01", tz = "UTC")

# Calcular a energia consumida em kWh por registro
df <- df %>%
  mutate(energia_kwh = consumo_potencia_kw * frequencia_atualizacao_s / 3600)

# Análise Exploratória de Dados

# 1. Sumário estatístico
summary(df)

# 2. Verificação de valores ausentes
colSums(is.na(df))

# 3. Histograma do consumo de energia
ggplot(df, aes(x = energia_kwh)) +
  geom_histogram(binwidth = 0.001, fill = "steelblue", color = "black") +
  labs(title = "Distribuição do Consumo de Energia (kWh)", x = "Consumo (kWh)", y = "Frequência")

# 4. Boxplot do consumo de energia por dispositivo
ggplot(df, aes(x = dispositivo, y = energia_kwh)) +
  geom_boxplot(fill = "steelblue") +
  labs(title = "Consumo de Energia por Dispositivo", x = "Dispositivo", y = "Consumo (kWh)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 5. Análise de outliers (utilizando o método do intervalo interquartil)
outliers <- function(x){
  qnt <- quantile(x, probs=c(.25, .75), na.rm = TRUE)
  H <- 1.5 * IQR(x, na.rm = TRUE)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}
df$energia_kwh_sem_outliers <- outliers(df$energia_kwh)

# 6. Distribuição dos dispositivos
ggplot(df, aes(x = dispositivo)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Frequência de Uso dos Dispositivos", x = "Dispositivo", y = "Frequência")

# 7. Matriz de correlação (para variáveis numéricas)
numeric_vars <- select_if(df, is.numeric)
correlation_matrix <- cor(numeric_vars, use = "pairwise.complete.obs")
corrplot::corrplot(correlation_matrix, method = "color")

# 8. Análise da relação entre consumo e tempo (utilize uma janela de tempo apropriada para melhor visualização)
df_agregado <- df %>%
  mutate(hora = format(timestamp, "%H")) %>%
  group_by(hora) %>%
  summarise(consumo_medio_hora = mean(energia_kwh, na.rm = TRUE))

ggplot(df_agregado, aes(x = hora, y = consumo_medio_hora)) +
  geom_line(color = "steelblue") +
  geom_point(color = "steelblue") +
  labs(title = "Consumo Médio de Energia por Hora", x = "Hora do Dia", y = "Consumo Médio (kWh)")

# 9.  Pair plot para visualizar as relações entre as variáveis numéricas.
ggpairs(df[,sapply(df,is.numeric)])

#10. Análise de Dados Faltantes (se houver)
# Utilizando o pacote mice para imputação de dados faltantes (se necessário):
# imput <- mice(df, m=5, maxit = 50, method = 'pmm', seed = 500)
# completedData <- complete(imput,1) #seleciona a primeira imputação

#Observações Adicionais para o Relatório:

#Conclusões sobre os padrões de consumo energético.
#Discussão da relação entre o consumo e os tipos de dispositivos.
#Identificação dos dispositivos que mais consomem energia.
#Análise do comportamento do consumo ao longo do tempo.
#Sugestões para otimizar o consumo de energia baseadas nas descobertas da análise exploratória.
#Observações adicionais sobre os dados faltantes, outliers e outros aspectos relevantes da análise.


#Incluir contexto da atividade Global Solutions e como a análise contribui para a otimização de energia.


# Adicione gráficos e tabelas relevantes ao seu relatório final.