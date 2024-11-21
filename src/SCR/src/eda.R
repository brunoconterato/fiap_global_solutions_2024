####################################################
##### 1. Definindo Objetivos da Análise #####
####################################################

# Objetivos da análise exploratória de dados:

# 1. Insights sobre estratégias eficazes: Identificar as tipologias de projetos de eficiência 
#    energética que apresentaram maior retorno sobre o investimento (ROI) e maior redução 
#    na demanda de energia.  Analisar a relação entre a metodologia utilizada e a eficácia 
#    do projeto.

# 2. Identificação de lacunas:  Detectar possíveis lacunas no programa de eficiência 
#    energética, analisando a distribuição das tipologias de projetos, usos finais da energia 
#    e regiões geográficas (embora essa última informação não esteja disponível diretamente 
#    nesse dataset).  Identificar se há desequilíbrio na alocação de recursos para diferentes 
#    tipos de projetos ou usos finais.


####################################################
##### 2. Carregando as bibliotecas necessárias #####
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
##### 3. Limpeza e Pré-processamento dos Dados #####
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


### Analisando variáveis categóricas
### Objetivo: excluir variáveis categóricas com poucos dados da nossa análise


# Tabela de frequências para variáveis categóricas
table(dados_completos$DscTipologia)

# Resultado:

#    Aquecimento Solar            Baixa Renda             Co-geração 
#                   35                   1599                      3 
#  Comércio e Serviços Diagnóstico Energético            Educacional 
#                 1937                      1                     13 
#   Iluminação Pública             Industrial          Poder Público 
#                 1007                    333                   2511 
#          Prioritário         Projeto Piloto            Residencial 
#                    4                     23                    658 
#                Rural      Serviços Públicos 
#                  102                    486

# Vamos agrupar as seguintes Tipologias por baixa disponibilidade de dados para análise como sendo "Outros" 
# (menos de 100 exemplares):
#  - Aquecimento Solar
#  - Co-geração
#  - Diagnóstico Energético
#  - Educacional
#  - Prioritário
#  - Projeto piloto



### Analisando uso final

table(dados_completos$DscUsoFinal)

# Resultado:
#       Aquecimento             Aquecimento de Água 
#                15                             387 
#     Ar Comprimido           Condicionamento de Ar 
#                15                             923 
#      Força Motriz Geração por Fontes Incentivadas 
#               339                             635 
# Gestão Energética                      Iluminação 
#                 1                            4870 
#            Outros                      Reciclagem 
#               734                              26 
#      Refrigeração 
#               767 

# Vamos transformar todas as categorias de Uso Final com menos de 30 exemplares em "Outros":
#  - Aquecimento
#  - Ar comprimido
#  - Gestão energética
#  - Reciclagem




# Transformando tipologias com menos de 100 exemplares em "Outros"
tipologias_outros <- c("Aquecimento Solar", "Co-geração", "Diagnóstico Energético", "Educacional", "Prioritário", "Projeto Piloto")
dados_completos$DscTipologia <- ifelse(dados_completos$DscTipologia %in% tipologias_outros, "Outros", dados_completos$DscTipologia)

# Transformando categorias de Uso Final com menos de 30 exemplares em "Outros"
usos_finais_excluir <- c("Aquecimento", "Ar Comprimido", "Gestão Energética", "Reciclagem")
dados_completos$DscUsoFinal <- ifelse(dados_completos$DscUsoFinal %in% usos_finais_excluir, "Outros", dados_completos$DscUsoFinal)


#################################
##### 4. Análise Descritiva #####
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
##### 5. Visualização dos Dados: #####
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

# Gráficos para atender aos objetivos:


# Gráfico 1.1.
# Boxplot do retorno sobre o custo-benefício por tipologia (excluindo outliers) - Atende ao objetivo 1 e 3
temp_data <- remove_outliers(dados_completos, "VlrRcb")
ggplot(temp_data, aes(x = DscTipologia, y = VlrRcb)) +
  geom_boxplot() +
  labs(title = "Retorno sobre o Custo-Benefício por Tipologia", x = "Tipologia", y = "Retorno (R$)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(yintercept = mean(temp_data$VlrRcb, na.rm = TRUE), linetype="dashed", color = "red")


# Gráfico 1.2.
# Boxplot da demanda reduzida no pico por tipologia (excluindo outliers) - Atende ao objetivo 1
temp_data <- remove_outliers(dados_completos, "VlrDemandaReduzidaPonta")
ggplot(temp_data, aes(x = DscTipologia, y = VlrDemandaReduzidaPonta)) +
  geom_boxplot() +
  labs(title = "Demanda Reduzida no Pico por Tipologia", x = "Tipologia", y = "Demanda (kW)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(yintercept = mean(temp_data$VlrDemandaReduzidaPonta, na.rm = TRUE), linetype="dashed", color = "red")


# Gráfico 2.1.
# Gráfico de barras da tipologia do projeto - contribui para objetivo 2
ggplot(dados_completos, aes(x = DscTipologia)) +
  geom_bar(fill = "lightgreen", color = "black") +
  labs(title = "Frequência das Tipologias de Projeto", x = "Tipologia", y = "Contagem") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_text(stat='count', aes(label=..count..), vjust=-0.5) # Adiciona contagem em cada barra

# Gráfico 2.2.
# Gráfico de barras para DscUsoFinal - contribui para objetivo 2
ggplot(dados_completos, aes(x = DscUsoFinal)) +
    geom_bar(fill = "skyblue", color = "black") +
    labs(title = "Uso Final da Energia nos Projetos", x = "Uso Final", y = "Contagem") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    geom_text(stat='count', aes(label=..count..), vjust=-0.5) #Adiciona contagem em cada barra


# Gráfico 3.1
# Scatter plot para analisar a relação entre retorno e demanda reduzida (excluindo outliers) - Atende objetivo 3
temp_data <- dados_completos %>%
  filter(!is.na(VlrRcb) & !is.na(VlrDemandaReduzidaPonta)) %>%
  remove_outliers("VlrRcb") %>%
  remove_outliers("VlrDemandaReduzidaPonta")
ggplot(temp_data, aes(x = VlrRcb, y = VlrDemandaReduzidaPonta)) +
  geom_point() +
  labs(title = "Relação entre Retorno e Demanda Reduzida", x = "Retorno (R$)", y = "Demanda Reduzida (kW)") +
  geom_smooth(method = "lm", se = FALSE, color = "red") # Adiciona linha de regressão


####################################
##### 5. Análise de Correlação #####
####################################

# Matriz de correlação para variáveis numéricas
cor(dados_completos[, sapply(dados_completos, is.numeric)], use = "pairwise.complete.obs")

# Visualizacão da matriz de correlação em mapa de calor
ggcorr(data = dados_completos[, sapply(dados_completos, is.numeric)])

# Concluímos que os dados apresentados não mostram grande correlação entre as variáveis numéricas.


####################################
##### 6. Resultados da análise #####
####################################


# Sobre as Tipologias

# As tipologias de projetos que apresentam maior e menor retorno sobre o investimento (ROI)


# Auxiliados pelo gráfico 1.1. e pelo seguinte cálculo:
# Calculando o ROI médio por tipologia em ordem decrescente
temp_data = remove_outliers(dados_completos, "VlrRcb")
roi_por_tipologia <- temp_data %>%
  group_by(DscTipologia) %>%
  summarise(ROI_Medio = mean(VlrRcb, na.rm = TRUE)) %>%
  arrange(desc(ROI_Medio))

# Mostrando os ROIs médios por tipologia
print(roi_por_tipologia)

# As tipologias de projetos que apresentam maior retorno sobre o investimento (ROI)
#  - Poder Público: média de 0.628
#  - Serviços Públicos: 0.623
#  - Outros (incluem as seguintes tipologias: Aquecimento Solar, Co-geração, Diagnóstico Energético, Educacional, Prioritário, Projeto piloto): média de 0.619
#  - Comércio e Serviços: média de 0.614

# As tipologias de projetos que apresentam menor retorno sobre o investimento (ROI)
#  - Iluminação Pública: média de 0.321
#  - Rural: média de 0.493



# As tipologias de projetos que apresentam maior e menor redução na demanda

# Auxiliados pelo gráfico 1.2. e pelo seguinte cálculo:
# Calculando a redução média na demanda por tipologia em ordem decrescente
temp_data = remove_outliers(dados_completos, "VlrDemandaReduzidaPonta")
reducao_demanda_por_tipologia <- temp_data %>%
  group_by(DscTipologia) %>%
  summarise(RedDemanda_Media = mean(VlrDemandaReduzidaPonta, na.rm = TRUE)) %>%
  arrange(desc(RedDemanda_Media))

# Mostrando a redução média na demanda por tipologia
print(reducao_demanda_por_tipologia)

# As tipologias de projetos que apresentam maior redução na demanda
#  - Iluminação Pública: média de 67.8 kW
#  - Baixa Renda: média de 62.8 kW

# As tipologias de projetos que apresentam menor redução na demanda
#  - Comércio e Serviços: média de 25.9 kW
#  - Poder Público: média de 31.1 kW


# Sobre as Lacunas

# Auxiliados pelo Gráfico 2.1. e pelo seguinte cálculo
# Contagem de projetos por tipologia
contagem_tipologia <- dados_completos %>%
  group_by(DscTipologia) %>%
  summarise(Contagem = n()) %>%
  arrange(desc(Contagem))

print(contagem_tipologia)

# Tipologias com mais projetos
#  - Poder Público: 2511 projetos
#  - Comércio e Serviços: 1937 projetos
#  - Baixa renda: 1599 projetos

# Tipologias com menos projetos
#  - Outros (incluem as seguintes tipologias: Aquecimento Solar, Co-geração, Diagnóstico Energético, Educacional, Prioritário, Projeto piloto): 79 projetos
#  - Rural: 102 projetos


# Auxiliados pelo Gráfico 2.2. e pelo seguinte cálculo
# Contagem de projetos por uso final
contagem_uso_final <- dados_completos %>%
  group_by(DscUsoFinal) %>%
  summarise(Contagem = n()) %>%
  arrange(desc(Contagem))

print(contagem_uso_final) 

# Uso final com mais projetos
#  - Iluminação: 4870 projetos
#  - Condicionamento de Ar: 923 projetos

# Uso final com menos projetos
#  - Força Motriz: 339 projetos
#  - Aquecimiento de Água: 387 projetos



########################################
##### 7. Conclusão e Recomendações #####
########################################


# Conclusões:

# Análise de Retorno sobre Investimento (ROI) e Redução de Demanda: 
# A análise revelou uma grande variação no ROI entre as diferentes tipologias de projetos de eficiência energética.  
# Projetos do setor público ("Poder Público" e "Serviços Públicos") apresentaram, em média, os maiores retornos, 
# sugerindo que investimentos nessas áreas podem ser particularmente eficazes.  
# Por outro lado, projetos de "Iluminação Pública" mostraram um ROI significativamente menor, 
# indicando a necessidade de uma revisão estratégica nesse setor.  

# Em relação à redução da demanda, "Iluminação Pública" e "Baixa Renda" se destacaram,
# enquanto "Comércio e Serviços" e "Poder Público" apresentaram reduções menores, 
# sugerindo que as estratégias empregadas nestes últimos setores podem necessitar de aprimoramentos.
# A discrepância entre o alto ROI do setor público e sua relativamente baixa redução de demanda
# sugere que outros fatores além da redução de consumo direto contribuem para o retorno do investimento nesses projetos.


# Identificação de Lacunas:  A análise de frequência das tipologias de projetos destaca um desequilíbrio na alocação de recursos.  
# Há uma concentração significativa de projetos em "Poder Público", "Comércio e Serviços" e "Baixa Renda", 
# enquanto outras categorias ("Outros", "Rural") recebem uma atenção consideravelmente menor. 
# Essa concentração pode indicar a necessidade de expandir o escopo do programa para alcançar outros setores e contextos, 
# promovendo uma maior equidade na distribuição dos benefícios da eficiência energética.
# Da mesma forma, a análise do uso final da energia revela uma preponderância de projetos focados em iluminação,
# enquanto outros usos finais, como força motriz e aquecimento de água, têm menor representatividade, 
# indicando áreas potenciais para expansão e diversificação das ações de eficiência energética.


# Recomendações:

# 1. Investigação Adicional sobre Projetos de Iluminação Pública: O baixo retorno sobre o investimento em projetos de iluminação pública
# justifica uma investigação detalhada sobre as causas dessa baixa performance.
# Isso inclui a análise de custos, métodos de implementação, tecnologias empregadas e critérios de seleção de projetos.

# 2. Diversificação de Investimentos:  
# É recomendado ampliar o alcance do programa de eficiência energética, 
# direcionando mais recursos para tipologias e usos finais atualmente sub-representados,
# como projetos rurais e aqueles focados em setores além de iluminação e condicionamento de ar.
# Isso promoverá uma maior equidade na distribuição dos benefícios e otimizará o impacto do programa.

# 3. Análise de Dados Mais Granulares:
# Para uma análise mais robusta, a coleta de dados mais detalhados, incluindo informações geográficas, 
# custos específicos dos projetos e indicadores de desempenho mais abrangentes, 
# é crucial para refinar as estratégias e otimizar a eficácia dos investimentos.

# 4. Monitoramento e Avaliação Contínua:
# A implementação de um sistema de monitoramento e avaliação contínuo do programa de eficiência energética 
# é essencial para acompanhar o progresso, identificar potenciais problemas e ajustar as estratégias conforme necessário.
# Isso permitirá o aprimoramento contínuo do programa e o alcance de resultados mais efetivos.


# Considerações Finais:
# Esta análise exploratória forneceu valiosas informações sobre os padrões e tendências nos projetos de eficiência energética.
# No entanto, é importante considerar as limitações dos dados disponíveis, 
# especialmente a falta de informações geográficas e a alta porcentagem de valores ausentes em algumas variáveis. 
# Estudos futuros com dados mais completos e detalhados poderão fornecer uma compreensão ainda mais aprofundada do tema 
# e subsidiar a formulação de políticas públicas mais eficazes.
