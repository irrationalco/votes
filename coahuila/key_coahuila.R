# Create key of Coahuila city ids

# SETUP
#########

setwd('')
options(scipen = 999)
require(dplyr)
require(jsonlite)
require(stringr)

mun <- fromJSON('dat/mx_tj.json')
mun <- mun[[2]][[2]][[3]][[2]]
names(mun) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO_RAW')
mun$MUNICIPIO <- cleanText(tolower(mun$MUNICIPIO_RAW))
mun <- mun %>% select(-MUNICIPIO_RAW) %>% arrange(CODIGO_ESTADO, CODIGO_MUNICIPIO)
mun <- mun %>% filter(CODIGO_ESTADO == 5)
write.csv(mun, 'out/key_coahuila.csv', row.names = F)