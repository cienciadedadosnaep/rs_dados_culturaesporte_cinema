######################################################
# 1) Carregar bibliotecas

library(tidyverse)
library(magrittr)
#library(dplyr)
library(readr)
library(rjson)
library(RJSONIO)

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
dd <- read_csv("data/cinema_ssa_ba - cinema.csv")
names(dd) = c("ano","Salvador","Complexos","Bahia")
dados<- dd %>% select(ano, Salvador, Bahia)
nomes <- names(dados)
##  Perguntas e titulos 
T_ST_P_No_Culturaesporte <- read_csv("data/TEMA_SUBTEMA_P_No - CULTURAESPORTE.csv")

#dados <- dados %>% add_column(valor = 'valor', .after = 'trimestre')

#dados %<>% gather(key = classe,
#                  value = valor,-trimestre,-Homens) 


#dados %<>% select(-id)
# Temas Subtemas Perguntas



## Arquivo de saida 

SAIDA_POVOAMENTO <- T_ST_P_No_Culturaesporte %>% 
  select(TEMA,SUBTEMA,PERGUNTA,NOME_ARQUIVO_JS)
SAIDA_POVOAMENTO <- as.data.frame(SAIDA_POVOAMENTO)

#classes <- NULL
#classes <- levels(as.factor(dados$classe))

# Cores secundarias paleta pantone -
corsec_recossa_azul <- c('#a094e1','#dc6f6c','#62acd1','#8bc6d2',
                         '#d62839','#20cfef','#fe4641','#175676')
# Cor 1 - Roxo; Cor 2, 5, 7 - Vermelho; Cor 3, 4, 6, 8 - Azul

simbolo_linhas <- c('emptyCircle','emptyTriangle','emptySquare',
                    'emptyDiamond','emptyRoundRect')

#for ( i in 1:length(classes)) {

objeto_0 <- dados %>%
  #filter(classe %in% c(classes[1])) %>%
  select(ano,Salvador,Bahia) %>% #filter(ano<2019) %>%
  #arrange(trimestre) %>%
  mutate(ano = as.character(ano)) %>% list()               

exportJson0 <- toJSON(objeto_0)


titulo<-T_ST_P_No_Culturaesporte$TITULO[1]
subtexto<-"Fonte: OCA/ANCINE"
link <- T_ST_P_No_Culturaesporte$LINK[1]

data_axis <- paste('["',gsub(' ','","',
                             paste(paste(as.vector(objeto_0[[1]]$ano)),
                                   collapse = ' ')),'"]',sep = '')


data_serie <- paste('[',gsub(' ',',',
                             paste(paste(as.vector(objeto_0[[1]]$Salvador)),
                                   collapse = ' ')),']',sep = '')

data_serie2 <- paste('[',gsub(' ',',',
                              paste(paste(as.vector(objeto_0[[1]]$Bahia)),
                                    collapse = ' ')),']',sep = '')
#Colocar o nome da coluna depois de "objeto_0[[1]]$"

texto<-paste('{"title":{"text":"',titulo,
             '","subtext":"',subtexto,
             '","sublink":"',link,'"},',
             '"tooltip":{"trigger":"axis"},',
             '"toolbox":{"left":"center","orient":"horizontal","itemSize":20,"top":20,"show":true,',
             '"feature":{"dataZoom":{"yAxisIndex":"none"},',
             '"dataView":{"readOnly":false},',
             '"restore":{},"saveAsImage":{}}},"legend":{"show":true,"top":"bottom"},"xAxis":{"type":"category",',
             '"data":',data_axis,'},',
             '"yAxis":{"type":"value","axisLabel":{"formatter":"{value} "}},',
             '"series":[{"name":"',nomes[2],'","data":',data_serie,',',
             '"type":"bar","color":"',corsec_recossa_azul[1],'","showBackground":true,',
             '"backgroundStyle":{"color":"rgba(180, 180, 180, 0.2)"},"symbol":"',simbolo_linhas[1],
             '","symbolSize":10,"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[1],'","borderWidth":2}},',
             '{"name":"',nomes[3],'","data":',data_serie2,',',
             '"type":"bar","color":"',corsec_recossa_azul[2],'","showBackground":true,',
             '"backgroundStyle":{"color":"rgba(180, 180, 180, 0.2)"},"symbol":"',simbolo_linhas[2],
             '","symbolSize":10,"itemStyle":{"borderRadius":10,"borderColor":"',corsec_recossa_azul[2],'","borderWidth":2}}',
             ']}',sep='')

#SAIDA_POVOAMENTO$CODIGO[i] <- texto   
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