# Create master key

# SETUP
setwd('/Users/Franklin/Git/votes/keys')
options(scipen = 999)
require(data.table)
require(dplyr)
require(stringr)
require(tidyr)

# DATA
data <- fread('../ine/out/tbl_ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)
dat <- data %>% select(CODIGO_ESTADO, DISTRITO_FED, SECCION, ANO) %>% as.data.frame
df <- unique(dat[c('CODIGO_ESTADO', 'DISTRITO_FED', 'SECCION', 'ANO')])
x <- spread(df, ANO, DISTRITO_FED ,fill = 0)


names(x)[c(3:length(x))] <- c('CODIGO_ESTADO', 'DISTRITO_FED')
x$ANO <- as.factor(c('2009'))

x <- data %>%
  filter(ANO == 2015) %>%
  select(CODIGO_ESTADO, DISTRITO_FED, SECCION)
x <- unique(x[c('CODIGO_ESTADO', 'DISTRITO_FED', 'SECCION')])
names(x)[c(1:2)] <- c('CODIGO_ESTADO', 'DISTRITO_FED')
x$ANO <- as.factor(c('2015'))



write.csv(x, 'key_ine_2015.csv', row.names = F)