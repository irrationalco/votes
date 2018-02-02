# Description
# Reference keys useful for redistritaciones and stuff

# SETUP
setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
#require(gpclib)	# Run only once for OSX install
#gpclibPermit()		# Same ^
require(jsonlite)
require(rgdal)
require(tidyr)
source('../_fun/general_fun.R')

# DATA

### INEGI
inegi <- fromJSON('../inegi/raw/mx_tj.json')
inegi <- inegi[[2]][[2]][[3]][[2]]
names(inegi) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_INEGI', 'NOMBRE_MUNICIPIO_INEGI_RAW')
inegi$NOMBRE_MUNICIPIO_INEGI <- cleanText(tolower(inegi$NOMBRE_MUNICIPIO_INEGI_RAW))
inegi <- inegi %>% select(-NOMBRE_MUNICIPIO_INEGI_RAW)

### MAP
map <- readOGR('../inegi/raw', 'mexico') # Takes a while -  be patient
map.df <- as.data.frame(subset(map, select = c(ENTIDAD, MUN_IFE, MUN_INEGI, SECCION)))
names(map.df) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_INE', 'CODIGO_MUNICIPIO_INEGI', 'SECCION')
map.df$CODIGO_ESTADO <- as.integer(map.df$CODIGO_ESTADO)
map.df$CODIGO_MUNICIPIO_INE <- as.integer(map.df$CODIGO_MUNICIPIO_INE)

### INE
ine <- fread('../ine/out/tbl-ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)
ine <- ine %>% select(CODIGO_ESTADO, NOMBRE_ESTADO, DISTRITO_FEDERAL, SECCION, ANO) %>% as.data.frame
ine.u <- unique(ine[c('CODIGO_ESTADO', 'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'SECCION', 'ANO')])
ine.w <- spread(ine.u, ANO, DISTRITO_FEDERAL, fill = NA) # Use tidyr to spread districts by year; districts that don't exist are filled with NA
names(ine.w)[c(4:length(ine.w))] <- paste('DISTRITO_FEDERAL', names(ine.w)[c(4:length(ine.w))], sep = '_')

# KEY
x <- left_join(ine.w, map.df)
y <- left_join(x, inegi)

key <- y %>%
	mutate(
		DISTRITO_FEDERAL = DISTRITO_FEDERAL_2015,
		CODIGO_MUNICIPIO = CODIGO_MUNICIPIO_INEGI,
		NOMBRE_MUNICIPIO = NOMBRE_MUNICIPIO_INEGI
		) %>%
	select(
		CODIGO_ESTADO, NOMBRE_ESTADO, SECCION, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL,
		everything()
		) %>%
	arrange(
		CODIGO_ESTADO, SECCION
		)

# WRITE
write.csv(key, 'out/key.csv', row.names = F)