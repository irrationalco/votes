# Description: Censo INEGI 2010 key
# Author: Mariana <mariana@irrational.ly>

setwd('')
options(scipen = 999)
require(dplyr)
require(doBy)
source('../_misc/themes/theme_maps.R')

data <- foreign::read.dbf('raw/cartografia/inegi/2010/mexico.dbf')
key <- as.data.frame(subset(data, select = c(ENTIDAD, MUN_IFE, MUN_INEGI, SECCION)))
names(key) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_IFE_2010', 'CODIGO_MUNICIPIO_INEGI_2010', 'SECCION')
fwrite(key, 'out/key_inegi_2010.csv', row.names = FALSE, quote = FALSE)