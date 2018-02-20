# Description
# Clean data from 2015 NL state gobernador elections and merge with vote (?) volatility table

setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
source('../_misc/fun/general_fun.R')

# DATA
gob <- fread('man/gob_2015.csv', header = TRUE, sep = ',', stringsAsFactors = F)
names(gob) <- c(
  'SECCION', 'DISTRITO_LOCAL', 'NOMINAL',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PMC', 'PNA', 'PD', 'PCC', 'PMOR', 'PH', 'PES', 'BRONCO'
  )
vlt <- fread('dat/nuevo_leon_volatilidad.csv', header = TRUE, sep = ',', stringsAsFactors = F)

# CLEAN
gob <- gob %>%
  transform(PRI = rowSums(.[, c('PRI', 'PVEM', 'PNA', 'PD')], na.rm = T)) %>%
  select(-PVEM, -PNA, -PD) %>%
  as.data.frame

# TABLE
tbl <- summaryBy(
    . ~ SECCION,
    data = gob,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = FALSE
    )

tbl$ANO <- as.integer(c('2015'))
tbl$ELECCION <- c('gob')

# KEY
key <- paolo %>% 
  filter(ANO == 2015) %>%
  filter(ELECCION == 'dif') %>%
  select(SECCION, CODIGO_ESTADO, NOMBRE_ESTADO, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL)

# JOIN
x <- left_join(tbl, key)
y <- bind_rows(x, vlt)

# ORDER
df <- y %>%
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL, DISTRITO_LOCAL, SECCION, NOMINAL,
    everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

# WRITE
fwrite.csv(df, 'out/bronco.csv', row.names = F)