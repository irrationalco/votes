# Description

# SETUP
setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(stringr)
require(tidyr)

# DATA
	# Read
data <- fread('../ine/out/tbl_ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)

	# Wide
dat	<- data %>% select(CODIGO_ESTADO, DISTRITO_FED, SECCION, ANO) %>% as.data.frame
df	<- unique(dat[c('CODIGO_ESTADO', 'DISTRITO_FED', 'SECCION', 'ANO')])
x	<- spread(df, ANO, DISTRITO_FED, fill = NA) # Spread districts by year; districts that didn't exist are filled with NA

	# Colnames
names(x)[c(3:length(x))] <- paste('DISTRITO_FED', names(x)[c(3:length(x))], sep = '_')

# WRITE
write.csv(x, 'out/key_ine.csv', row.names = F)