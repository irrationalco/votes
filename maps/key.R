# Description
# Reference keys useful for redistritaciones and stuff

setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(jsonlite)
require(tidyr)
source('../_misc/fun/general_fun.R')
source('../_misc/themes/theme_maps.R')

# DATA

	# INEGI 2010
inegi <- fromJSON('/Users/Franklin/Git/votes/maps/raw/cartografia/inegi/2010/mx_tj.json')
inegi <- inegi[[2]][[2]][[3]][[2]]
names(inegi) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO_INEGI', 'NOMBRE_MUNICIPIO_INEGI_RAW')
inegi$NOMBRE_MUNICIPIO_INEGI <- cleanText(tolower(inegi$NOMBRE_MUNICIPIO_INEGI_RAW))
inegi <- inegi %>%
	select(-NOMBRE_MUNICIPIO_INEGI_RAW) %>%
	rename(
		CODIGO_MUNICIPIO_INEGI_2010 = CODIGO_MUNICIPIO_INEGI,
		NOMBRE_MUNICIPIO_INEGI_2010 = NOMBRE_MUNICIPIO_INEGI
		)
inegi.key <- fread('out/key_inegi_2010.csv', header = TRUE, sep = ',', stringsAsFactors = F)
ife.inegi <- left_join(inegi, inegi.key)

	# INE VOTES DB
ine.dat <- fread('../ine/out/tbl_ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)
ine.dat <- ine.dat %>% select(CODIGO_ESTADO, NOMBRE_ESTADO, DISTRITO_FEDERAL, SECCION, ANO) %>% as.data.frame
ine.unq <- unique(ine.dat[c('CODIGO_ESTADO', 'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'SECCION', 'ANO')])
ine.wde <- spread(ine.unq, ANO, DISTRITO_FEDERAL, fill = NA) # Use tidyr to spread districts by year; districts that don't exist are filled with NA
names(ine.wde)[c(4:length(ine.wde))] <- paste('DISTRITO_FEDERAL', names(ine.wde)[c(4:length(ine.wde))], sep = '_')
ine <- ine.wde %>%
	arrange(CODIGO_ESTADO, SECCION)

	# INE 2017
codigo <- c(seq(1,32))

		# Federal
fed.fls <- list.files(path = 'raw/cartografia/ine/2017/federal', pattern = '*SECCION.dbf', full.names = T, recursive = T, include.dirs = F)
fed.dbf <- lapply(fed.fls, function(x) {foreign::read.dbf(fed.fls)}) # Specify foreign() because it's being loaded by maptools!
fed.lst <- mapply(cbind, fed.dbf, 'CODIGO_ESTADO' = codigo, SIMPLIFY = F)
fed.dat <- data.table::rbindlist(l = fed.lst, use.names = TRUE, fill = TRUE)
fed <- fed.dat %>%
	select(distrito, municipio, seccion, CODIGO_ESTADO) %>%
	rename(
		DISTRITO_FEDERAL_2017 = distrito,
		CODIGO_MUNICIPIO_INE_2017 = municipio,
		SECCION = seccion
		) %>%
	arrange(CODIGO_ESTADO, SECCION)

# KEY
x <- left_join(ine, ife.inegi)
y <- left_join(x, fed)
z <- y

key <- z %>%
	mutate(
		DISTRITO_FEDERAL = DISTRITO_FEDERAL_2017,
		CODIGO_MUNICIPIO = CODIGO_MUNICIPIO_INE_2017,
		NOMBRE_MUNICIPIO = NOMBRE_MUNICIPIO_INEGI_2010
		) %>%
	select(noquote(order(colnames(.)))) %>%
	select(
		CODIGO_ESTADO, NOMBRE_ESTADO, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL, SECCION,
		everything()
		) %>%
	arrange(CODIGO_ESTADO, SECCION)

# WRITE
write.csv(key, 'out/key.csv', row.names = F)