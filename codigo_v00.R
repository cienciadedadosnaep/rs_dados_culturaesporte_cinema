######################################################
# 1) Carregar bibliotecas

library(tidyverse)
library(magrittr)
#library(dplyr)
library(readr)
library(rjson)
library(RJSONIO)
library(jsonlite)

# # Library para importar dados SQL
# library(DBI)
# library(RMySQL)
# library(pool)
# library(sqldf)
# library(RMariaDB)
# 
# # Carragamento de banco de dados
# 
# # Settings
# db_user <-'admin'
# db_password <-'password'
# db_name <-'cdnaep'
# #db_table <- 'your_data_table'
# db_host <-'127.0.0.1' # for local access
# db_port <-3306
# 
# # 3. Read data from db
# # drv=RMariaDB::MariaDB(),
# mydb <-  dbConnect(drv =RMariaDB::MariaDB(),user =db_user, 
#                    password = db_password ,
#                    dbname = 'cdnaep', host = db_host, port = db_port)
# 
# dbListTables(mydb)
# 
# s <- paste0("SELECT * from", " consumo_agua")
# rs<-NULL
# rs <- dbSendQuery(mydb, s)
# 
# dados<- NULL
# dados <-  dbFetch(rs, n = -1)
# dados
# #dbHasCompleted(rs)
# #dbClearResult(rs)

library(readr)
dados <- read_csv("data/cinema_ssa_ba - cinema.csv")
View(dados)
names(dados)

# Selecao de parte do banco que responde as perguntas da planilha de povoamento

##  Perguntas e titulos 
T_ST_P_No_Culturaesporte <- read_csv("data/TEMA_SUBTEMA_P_No - CULTURAESPORTE.csv")

# Lembrar de substituir nomes de 
# names(dados) = c("ano","q1","q2","q3","q41","q42",
#                 "q43","q44","q45","q46","q47","q48")

names(dados) = c("ano","Salvador","Complexos em Salvador","Bahia")



#dados %<>% gather(key = classe,
#                  value = consumo,-ano) 
dados_cine <- dados %>% select(ano,`Salvador`,`Bahia`) %>% arrange(ano)
dados_cine_t <- t(dados_cine)

dados_cine_tn <- data.frame(as.character(row.names(dados_cine_t)),dados_cine_t)

row.names(dados_cine_tn) <- NULL

dados_cine_t_anos <- dados_cine_tn[1,]
names(dados_cine_t_anos) <- NULL 
dados_cine_t_anos <- as.character(dados_cine_t_anos)

dados_cine_tl <-  dados_cine_tn[-c(1),]

teste_cine <- list(dados_cine_t_anos,dados_cine_tl)

testejson_cine <- jsonlite::toJSON(teste_cine,dataframe = "values") 

teste2_cine <- gsub('\\[\\[','[',testejson_cine)
teste3_cine <- gsub('\\]\\]\\]',']',teste2_cine)
teste3_cine

data_serie <- teste3_cine

#data_serie <- paste('[',teste3,']',sep = '')
#data_serie_mod <- gsub('\\\"','"',data_serie)

#dados_adulto <- dados %>% filter(classe %in% c('q43','q44','q45','q46'))
#dados_idoso <- dados %>% filter(classe %in% c('q47','q48'))
#dados %<>% select(-id)

# Temas Subtemas Perguntas



## Arquivo de saida 

SAIDA_POVOAMENTO <- T_ST_P_No_Culturaesporte %>% 
  select(TEMA,SUBTEMA,PERGUNTA,NOME_ARQUIVO_JS)
SAIDA_POVOAMENTO <- as.data.frame(SAIDA_POVOAMENTO)

#classes <- NULL
#classes <- levels(as.factor(dados_ca$classe))

# Cores secundarias paleta pantone -
corsec_recossa_azul <- c('#175676','#62acd1','#8bc6d2','#20cfef',
                         '#d62839','#20cfef','#fe4641','#175676',
                         '#175676','#62acd1','#8bc6d2','#20cfef')

#for ( i in 1:length(classes)) {
dados <- NULL
dados <- data_serie


#  objeto_0 <- dados %>% list()
#    filter(classe %in% c(classes[i])) %>%
#    select(ano,consumo) %>% filter(ano<2019) %>%
#    arrange(ano) %>%
#    mutate(ano = as.character(ano)) %>% list()               

exportJson0 <- toJSON(teste3_cine)


titulo<-T_ST_P_No_Culturaesporte$TITULO[1]
subtexto<-"Fonte: OCA/ANCINE"
link <- T_ST_P_No_Culturaesporte$LINK[1]


texto <- paste('{"title":{"text":"',titulo,
               '","subtext":"',subtexto,
               '","sublink":"',link,
               '"},"legend":{"show":true,"top":"bottom"},"tooltip":{},"dataset":{"source":[',data_serie,
               ']},"xAxis":[{"type":"category","gridIndex":0}],',
               '"yAxis":[{"gridIndex":0}],',
               '"series":[{"type":"bar",','"seriesLayoutBy":"row","color":"',corsec_recossa_azul[1],
               '","showBackground":false,"backgroundStyle":{"color":"rgba(180, 180, 180, 0)}"},',
               '"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[1],
               '","borderWidth":2}},',
               '{"type":"bar",','"seriesLayoutBy":"row","color":"',corsec_recossa_azul[2],
               '","showBackground":false,"backgroundStyle":{"color":"rgba(180, 180, 180, 0)}"},',
               '"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[2],
               '","borderWidth":2}}',
               ']','}',sep="")

## OBS - Incluir 
## Se for necessario coloca mais colunas além das 2 do default, e escolher 
## uma cor pelo vetor corsec_recossa_azul[i],

#{"type":"bar",','"seriesLayoutBy":"row","color":"',corsec_recossa_azul[3],
#               '","showBackground":true,"backgroundStyle":{"color":"rgba(180, 180, 180, 0)}"},',
#               '"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[3],
#               '","borderWidth":2}},',


#  SAIDA_POVOAMENTO$CODIGO[i] <- texto   
texto<-noquote(texto)


write(exportJson0,file = paste('data/',gsub('.csv','',T_ST_P_No_Culturaesporte$NOME_ARQUIVO_JS[1]),
                               '.json',sep =''))
write(texto,file = paste('data/',T_ST_P_No_Culturaesporte$NOME_ARQUIVO_JS[1],
                         sep =''))

#}

# Arquivo dedicado a rotina de atualizacao global. 

write_csv2(SAIDA_POVOAMENTO,file ='data/POVOAMENTO.csv',quote='all',escape='none')
#quote="needed")#,escape='none')


objeto_autm <- SAIDA_POVOAMENTO %>% list()
exportJson_aut <- toJSON(objeto_autm)

#write(exportJson_aut,file = paste('data/povoamento.json'))