# Description: Database with historic (2012-2017) state election results for Oaxaca.
# Author: Mariana <mariana@irrational.ly>

setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(openxlsx)
source('../../_misc/fun/general_fun.R')

# DATA

    # Read & assign multiple sheets within file
file_gob <- 'man/ESTADÍSTICA GOBERNADOR 2016.xlsx'
sh_gob <- openxlsx::getSheetNames(file_gob)
sheets_gob <- lapply(sh_gob, openxlsx::read.xlsx, xlsxFile = file_gob)
names(sheets_gob) <- sh_gob

    # Missing district number
sheets_gob[[1]]$DTTO <- c(1)
sheets_gob[[2]]$DTTO <- c(2)

    # Clean tons of shit
gob <- sheets_gob %>%
    data.table::rbindlist(l = ., use.names = TRUE, fill = TRUE) %>%
    select(3:length(.)) %>%
    select(-VOT_TOTAL, NULOS, -TIPO_CASILLA, -LOCALIDAD) %>%
    .[!grepl('CASILLA', .$PAN),] %>%    # CASILLA NO INSTALADA
    rename(NOMINAL = LISTA_NOM, DISTRITO_LOCAL_INE_2016 = DTTO, NOMBRE_MUNICIPIO = MUNICIPIO, PAN2 = PAN, PRI2 = PRI, PVEM2 = PVEM) %>%
    mutate(PAN2 = as.numeric(PAN2), PRI2 = as.numeric(PRI2),`PRI-PVEM-PNA` = as.numeric(`PRI-PVEM-PNA`)) %>%
	transform(
        PAN     = .[[5]]+.[[15]]+.[[23]],
        PRI     = .[[6]]+.[[16]]+.[[17]]+.[[18]]+.[[24]],
        PVEM    = .[[8]]+.[[19]]+.[[25]]
        ) %>%
	select(-PAN2, -PRI2, -PVEM2) %>%
	select(-contains('.')) %>%
    select(-CASILLA)

# TOTALS
sum <- summaryBy(
    . ~ NOMBRE_MUNICIPIO + DISTRITO_LOCAL_INE_2016 + SECCION,
    data = gob,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = FALSE
    )

# COLUMNS
dat <- sum %>%
    mutate(ANO = c(2016), ELECCION = 'gob', CODIGO_ESTADO = c(20), NOMBRE_ESTADO = 'oaxaca') %>%
    select(noquote(order(colnames(.)))) %>%
    select(
        ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, NOMBRE_MUNICIPIO,
        DISTRITO_LOCAL_INE_2016, SECCION, NOMINAL,
        everything()) %>%
    arrange(ANO, ELECCION, SECCION)

# WRITE
fwrite(dat, 'out/tbl_20.csv', row.names = F)