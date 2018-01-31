# Description
# Municipal codes and ids from INEGI

setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(jsonlite)
source('../fun/general_fun.R')

mun <- fromJSON('raw/mx_tj.json')
mun <- mun[[2]][[2]][[3]][[2]]
mun$MUNICIPIO <- cleanText(tolower(mun$MUNICIPIO_RAW))
mun <- mun %>% select(-MUNICIPIO_RAW) %>% arrange(CODIGO_ESTADO, CODIGO_MUNICIPIO)
names(mun) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_INEGI', 'NOMBRE_MUNICIPIO_INEGI')
write.csv(mun, 'out/key_inegi.csv', row.names = F)