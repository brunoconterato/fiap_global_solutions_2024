####################################################
##### 1. Carregando as bibliotecas necessárias #####
####################################################

# Carregando as bibliotecas necessárias
library(dplyr)
library(tidyr)
library(ggplot2)
library(DescTools)
library(car)
library(mice)
library(GGally)

# Importando os dados (substitua "seu_arquivo.csv" pelo nome do seu arquivo)
dados <- read.csv("/home/bruno/Workspace/FIAP/2024/Fase_4/fiap_global_solutions_2024/src/SCR/data/e12d5430-f747-4fc7-b620-2460ed02cc17.csv", sep = ",", dec = ".", header = TRUE, na.strings = c("", "NA", " "))


# Este conjunto de dados apresenta informações sobre projetos de eficiência energética promovidos
# pelo Programa de Eficiência Energética, regulamentado pela Resolução Normativa ANEEL nº 300/2008.

# Inclui dados por distribuidora, tipologia de projeto, demanda reduzida, energia economizada
# (GWh/ano) e investimentos em usos finais da energia.

# O objetivo é demonstrar a viabilidade e os benefícios econômicos de melhorias em eficiência energética,
# promovendo a transformação do mercado e incentivando novas tecnologias e práticas racionais
# no uso de energia elétrica.

# Os dados são atualizados mensalmente e estão disponíveis em formatos como CSV.

# Os dados podem ser acessados pelo Link:
# https://dadosabertos.aneel.gov.br/dataset/projetos-de-eficiencia-energetica

# Colunas:

# DatGeracaoConjuntoDados: Data de processamento dos dados (ex.: "2023-03-30"). Indica quando
# os dados foram atualizados e publicados no formato aberto. Unidade: Data (YYYY-MM-DD).

# NomAgente: Nome da empresa responsável pelo projeto (ex.: "EletroDistribuidora S.A.").
# Identifica juridicamente a organização que propôs ou executou o projeto. Unidade: Texto.

# IdeEmpresaProponenteProjeto: Código numérico único da empresa (ex.: 12345). Utilizado para
# identificar a proponente na base de dados. Unidade: Número.

# DscTituloProjeto: Título do projeto (ex.: "Redução de Consumo em Iluminação Pública").
# Resumo do objetivo principal do projeto. Unidade: Texto.

# DscStatusProjeto: Status atual do projeto (ex.: "Concluído", "Em andamento"). Informa o
# andamento do projeto em relação ao planejamento. Unidade: Texto.

# DscTipologia: Tipo de projeto de eficiência energética (ex.: "Iluminação Pública"). Indica
# a área de aplicação ou foco do projeto. Unidade: Texto.

# DscUsoFinal: Uso final da energia impactado pelo projeto (ex.: "Aquecimento", "Refrigeração").
# Representa onde a economia de energia foi aplicada. Unidade: Texto.

# VlrBeneficioEnergiaEconomizada: Energia economizada anualmente (ex.: 12.34). Indica o total de
# energia reduzido com o projeto. Unidade: GWh/ano.

# VlrRcb: Valor do retorno sobre o custo-benefício do projeto (ex.: 1.75). Mede a relação entre
# os benefícios obtidos e os custos investidos. Unidade: Valor monetário.

# VlrDemandaReduzidaPonta: Redução da demanda de energia no pico (ex.: 1000.50). Mostra o impacto
# na diminuição do consumo em horários de maior demanda. Unidade: kW.

# DscObjetivo: Detalhamento dos objetivos do projeto (ex.: "Reduzir 20% do consumo em iluminação
# de vias públicas"). Explica as metas pretendidas. Unidade: Texto.

# DscJustificativa: Racional e importância do projeto (ex.: "Necessidade de modernizar sistemas
# de iluminação para redução de custos"). Unidade: Texto.

# DatInicioProjeto: Data de início oficial do projeto (ex.: "2022-01-01"). Mostra quando o
# projeto foi iniciado. Unidade: Data (YYYY-MM-DD).

# DatConclusaoProjeto: Data oficial de término do projeto (ex.: "2022-12-31"). Indica a
# conclusão das atividades planejadas. Unidade: Data (YYYY-MM-DD).

# DscMetodologiaMv: Metodologia utilizada para medir e verificar os resultados do projeto
# (ex.: "Análise baseada em medições em campo"). Garante confiabilidade dos dados reportados.
# Unidade: Texto.


# Visualizando as primeiras linhas dos dados
head(dados)

# Visualizando as colunas dos dados
colnames(dados)

# Visualizando a estrutura dos dados
str(dados)

# Visualizando 5 elementos de cada coluna que não sejam NA
lapply(dados, function(col) head(na.omit(col), 5))


#####################################################
##### 2. Limpeza e Pré-processamento dos Dados #####
#####################################################

# Salvando uma cópia dos dados originais
dados_completos <- dados

# 2. Conversão de colunas numéricas (char para numérico)
# Identificando as colunas que deveriam ser numéricas mas estão como character
colunas_numericas <- c("IdeEmpresaProponenteProjeto", "VlrBeneficioEnergiaEconomizada", "VlrRcb", "VlrDemandaReduzidaPonta")

# Convertendo as colunas para numéricas, tratando os pontos e vírgulas
dados_completos[, colunas_numericas] <- lapply(dados_completos[, colunas_numericas], function(x) as.numeric(gsub(",", ".", gsub("\\.", "", x))))

# Converter variáveis para os tipos corretos
dados_completos$DatGeracaoConjuntoDados <- as.Date(dados_completos$DatGeracaoConjuntoDados, format = "%Y-%m-%d")
dados_completos$DatInicioProjeto <- as.Date(dados_completos$DatInicioProjeto, format = "%Y-%m-%d")
dados_completos$DatConclusaoProjeto <- as.Date(dados_completos$DatConclusaoProjeto, format = "%Y-%m-%d")

# Visualizando novamente a estrutura dos dados
str(dados_completos)

# Tratamento de valores NA - Imputação com MICE

# Selecionando apenas algumas para imputação
# colunas_pmm <- c("VlrBeneficioEnergiaEconomizada", "VlrRcb", "VlrDemandaReduzidaPonta")
# dados_pmm <- dados_completos[, colunas_pmm]

# head(dados_pmm)

# # Imputação múltipla para lidar com valores ausentes
# imputed_data <- mice(dados_pmm, method = "pmm", seed = 500)
# dados_completos[, colunas_pmm] <- complete(imputed_data, 1)


# Criar coluna de duração do projeto (em dias)
dados_completos <- dados_completos %>%
  mutate(DuracaoProjeto = as.numeric(DatConclusaoProjeto - DatInicioProjeto))

# Visualizando novamente a estrutura dos dados
str(dados_completos)

# Resumo estatístico dos dados tratados
summary(dados_completos)

# 1. Contagem de valores nulos por coluna
colSums(is.na(dados_completos))

# 2. Porcentagem de valores nulos por coluna
colSums(is.na(dados_completos)) / nrow(dados_completos) * 100.0


### Analisando as colunas numéricas representativas de eficiência energética
### Percebemos os seguintes níveis de dados ausentes (NA):

### VlrBeneficioEnergiaEconomizada: 67.2%
### VlrRcb: 18.1%
### VlrDemandaReduzidaPonta: 0.5%

### Devido à extensa quantidade de dados ausentes na variável VlrBeneficioEnergiaEconomizada,
### optamos por não trabalhar com essa variável, de tal forma que vamos removê-la do conjunto dados_completos.

dados_completos <- dados_completos[, -c(which(colnames(dados_completos) == "VlrBeneficioEnergiaEconomizada"))]


#################################
##### 3. Análise Descritiva #####
#################################

# Sumário estatístico
summary(dados_completos[, sapply(dados_completos, is.numeric)])

# Tabela de frequências para variáveis categóricas
table(dados_completos$DscTipologia)
table(dados_completos$DscUsoFinal)

# Medidas de dispersão e assimetria
Desc(dados_completos$VlrRcb)
Desc(dados_completos$VlrDemandaReduzidaPonta)
Desc(dados_completos$DuracaoProjeto)


######################################
##### 4. Visualização dos Dados: #####
######################################

# Histograma do retorno sobre o custo-benefício apenas valores diferentes de NA na coluna VlrRcb
# temp_data = dados_completos[!is.na(dados_completos$VlrRcb) & dados_completos$VlrRcb != 0, ]

# Função para remover outliers
# Essa função será utilizada para melhorar as visualizações dos dados
# Uma vez que outliers expandem a escala dos gráficos, dificultando a visualização
# Método utilizado: IQR (Interquartile Range)
remove_outliers <- function(data, column, multiplier = 1.5) {
  Q1 <- quantile(data[[column]], 0.25, na.rm = TRUE)
  Q3 <- quantile(data[[column]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1

  # Definindo limites para detecção de outliers
  lower_bound <- Q1 - multiplier * IQR
  upper_bound <- Q3 + multiplier * IQR

  # Filtrando os dados para remover outliers
  data <- data %>%
    filter(data[[column]] >= lower_bound & data[[column]] <= upper_bound)

  return(data)
}

# Histograma do retorno sobre o custo-benefício (excluindo outliers)
temp_data <- remove_outliers(dados_completos, "VlrRcb")
ggplot(temp_data, aes(x = VlrRcb)) +
  geom_histogram(bins = 30, fill = "lightgreen", color = "black") +
  labs(title = "Histograma do Retorno sobre o Custo-Benefício", x = "Retorno (R$)", y = "Frequência")

# Histograma da demanda reduzida no pico (excluindo outliers)
temp_data <- remove_outliers(dados_completos, "VlrDemandaReduzidaPonta")
ggplot(temp_data, aes(x = VlrDemandaReduzidaPonta)) +
  geom_histogram(bins = 30, fill = "lightgreen", color = "black") +
  labs(title = "Histograma da Demanda Reduzida no Pico", x = "Demanda (kW)", y = "Frequência")

# Boxplot da duração do projeto por tipologia
temp_data <- remove_outliers(dados_completos, "DuracaoProjeto")
ggplot(temp_data, aes(x = DscTipologia, y = DuracaoProjeto)) +
  geom_boxplot() +
  labs(title = "Duração do Projeto por Tipologia", x = "Tipologia", y = "Duração (dias)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Boxplot do retorno sobre o custo-benefício por tipologia (excluindo outliers)
temp_data <- remove_outliers(dados_completos, "VlrRcb")
ggplot(temp_data, aes(x = DscTipologia, y = VlrRcb)) +
  geom_boxplot() +
  labs(title = "Retorno sobre o Custo-Benefício por Tipologia", x = "Tipologia", y = "Retorno (R$)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Boxplot da demanda reduzida no pico por tipologia (excluindo outliers)
temp_data <- remove_outliers(dados_completos, "VlrDemandaReduzidaPonta")
ggplot(temp_data, aes(x = DscTipologia, y = VlrDemandaReduzidaPonta)) +
  geom_boxplot() +
  labs(title = "Demanda Reduzida no Pico por Tipologia", x = "Tipologia", y = "Demanda (kW)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Gráfico de barras da tipologia do projeto
ggplot(dados_completos, aes(x = DscTipologia)) +
  geom_bar(fill = "lightgreen", color = "black") +
  labs(title = "Tipologias dos Projetos", x = "Tipologia", y = "Contagem") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Scatter plot (exemplo)
ggplot(dados_completos, aes(x = VlrBeneficioEnergiaEconomizada, y = DuracaoProjeto)) +
  geom_point() +
  labs(title = "Relação entre Benefício e Duração do Projeto", x = "Benefício (R$)", y = "Duração (dias)")



####################################
##### 5. Análise de Correlação #####
####################################

# Matriz de correlação para variáveis numéricas
cor(dados_completos[, sapply(dados_completos, is.numeric)], use = "pairwise.complete.obs")

# Visualizacão da matriz de correlação em mapa de calor
ggcorr(data = dados_completos[, sapply(dados_completos, is.numeric)])

# Concluímos que os dados apresentados não mostram grande correlação entre as variáveis numéricas.


####################################
##### 6. Conclusão e Relatório #####
####################################
