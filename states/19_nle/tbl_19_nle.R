# Description: create database with 2012 - 2015 state (local deputy and mayoral) election votes.
# Author: Mariana <mariana@irrational.ly>

setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(openxlsx)
source('../../_misc/fun/general_fun.R')

# DATA

	# Scraped data
	# http://www.cee-nl.org.mx/computo2012/presentacion.html
ayu.12 <- read.xlsx('raw/19_nle_ayu_2012.xlsx', 1)
    ayu.12$ELECCION <- c('ayu')
    ayu.12[3:11] <- lapply(ayu.12[3:11], as.integer)

dil.12 <- read.xlsx('raw/19_nle_dil_2012.xlsx', 1)
    dil.12$ELECCION <- c('dil')
    dil.12[3:11] <- lapply(ayu.12[4:12], as.integer)

x <- ayu.12 %>%
    bind_rows(., dil.12) %>%
    select(-TNT, -TOTAL, -NULOS) %>%
    .[!grepl('[*]', .$CASILLA),] %>%	# http://www.cee-nl.org.mx/computo2012/c_2_D_23.html
    rename(PRI2 = PRI) %>%
    transform(PRI = rowSums(select_(., 'PRI2', 'COA_PRI_PVEM_PCC_PD'))) %>%
    select(-CASILLA, -PRI2, -COA_PRI_PVEM_PCC_PD)

	# datamx.io
	# http://datamx.io/dataset/ceenl-2015-elecciones-nl
files <- list.files(path = 'raw/', pattern = '.csv', full.names = TRUE)

y1 <- lapply(files, fread, sep = ',')
    eleccion <- as.factor(c('ayu', 'dil', 'gob'))
    ano <- c('2015')
        y1 <- mapply(cbind, y1, 'ANO' = ano, SIMPLIFY = F)
        y1 <- mapply(cbind, y1, 'ELECCION' = eleccion, SIMPLIFY = F)
        names(y1[[1]])[21] <- 'CC1_19_AYU_2015'
        names(y1[[2]])[21] <- 'CC1_19_DIL_2015'
        names(y1[[3]])[21] <- 'CC1_19_GOB_2015'

y2 <- y1 %>%
    data.table::rbindlist(l = ., use.names = TRUE, fill = TRUE) %>%
    select(-Estatus, -Casilla, -Total, -`Votos Anulados`, -`Eleccion`)
colnames(y2)[1:16] <- c(
	'SECCION', 'NOMBRE_MUNICIPIO', 'DISTRITO_LOCAL_INE_2015', 'NOMINAL',
	'PAN', 'PRI2', 'PRD2', 'PT', 'PVEM2', 'PMC', 'PNA2', 'PD', 'PCC', 'PMOR', 'PH', 'PES'
	)

y3 <- y2 %>%
	transform(
		PRI		= .[[6]]+.[[18]]+.[[19]]+.[[20]]+.[[21]]+.[[23]]+.[[24]]+.[[25]],
		PVEM	= .[[9]]+.[[22]]+.[[26]]+.[[27]],
		PNA		= .[[11]]+.[[28]],
		PRD		= .[[7]]+.[[29]]
		) %>%
	select(-PRI2, -PVEM2, -PNA2, -PRD) %>%
	select(-starts_with('Comb'))

	# Full set
z <- bind_rows(x, y3)
z$CODIGO_ESTADO <- c(19)
z$NOMBRE_ESTADO <- c('nuevo leon')

# COLUMNS
dat <- z %>%
    select(noquote(order(colnames(.)))) %>%
    select(
        ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, NOMBRE_MUNICIPIO,
        DISTRITO_LOCAL_INE_2012, DISTRITO_LOCAL_INE_2015, SECCION, NOMINAL,
        everything()) %>%
    select(-starts_with('CC'), everything()) %>%
    arrange(ANO, ELECCION, SECCION)

# WRITE
fwrite(dat, 'out/tbl_19_nle.csv', row.names = F)