# Description
# Municipal codes and ids from INEGI

setwd('/Users/Franklin/Git/votes/keys')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(jsonlite)
source('../_fun/general_fun.R')

# INEGI
inegi <- fromJSON('../inegi/raw/mx_tj.json')
inegi <- inegi[[2]][[2]][[3]][[2]]
names(inegi) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_INEGI', 'MUNICIPIO_INEGI_RAW')
inegi$MUNICIPIO_INEGI <- cleanText(tolower(inegi$MUNICIPIO_INEGI_RAW))
inegi <- inegi %>% select(-MUNICIPIO_INEGI_RAW)
