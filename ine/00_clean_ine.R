# Description
# Create database with historic (2009-2015) federal election votes.

# SETUP
setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(tidyr)
require(openxlsx)
source('../_fun/general_fun.R')

# DATA
### 2009 - 2012 historic vote records
data_filenames <- list.files(path = 'raw', pattern = '*.txt') # Files
data_path <- as.character('raw/')                             # Path
data_files <- paste(data_path, data_filenames, sep = '')      # Files + Path
data <- lapply(                                               # Path
    data_files,
    read.table,
    header = TRUE,
    stringsAsFactors = FALSE,
    sep = '|',
    encoding = 'latin1')                                      # Specific encoding mex gov uses
typeof(data)                                                  # What do we haf here?
str(data)                                                     # Structure

  # Colnames
dat <- data
names(dat[[1]]) <- c(
  'CIRC', 'CODIGO_ESTADO', 'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'CABECERA_FED', 'NOMBRE_MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PCONV', 'PNA', 'PSD', 'PPM', 'PSM',
  'NO_REG', 'NULOS', 'TOTAL', 'NOMINAL', 'ESTATUS', 'TPEJF')
names(dat[[2]]) <- c(
  'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'NOMBRE_MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')
names(dat[[3]]) <- c(
  'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'NOMBRE_MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'NOMINAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')
names(dat[[4]]) <- c(
  'NOMBRE_ESTADO', 'DISTRITO_FEDERAL', 'NOMBRE_MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')

  # New columns based on file names
data_files
ano <- as.factor(c('2009', '2012', '2012', '2012'))
dat <- mapply(cbind, dat, 'ANO' = ano, SIMPLIFY = F)
eleccion <- as.factor(c('dif', 'dif', 'prs', 'sen'))
dat <- mapply(cbind, dat, 'ELECCION' = eleccion, SIMPLIFY = F)

  # Reduce to single data frame
dat <- data.table::rbindlist(l = dat, use.names = TRUE, fill = TRUE)

### 2015
dif <- read.xlsx('raw/ine_dif_2015.xlsx', 1)
names(dif) <- c(
  'CODIGO_ESTADO', 'DISTRITO_FEDERAL', 'SECCION', 'ID_CASILLA',
  'TIPO_CASILLA', 'EXT_CONTIGUA', 'UBICACION_CASILLA', 'TIPO_ACTA', 'NUM_BOLETAS_SOBRANTES', 'TOTAL_CIUDADANOS_VOTARON', 'NUM_BOLETAS_EXTRAVIADAS',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA', 'PMOR', 'PH', 'PS',
  'COA_PRI_PVEM', 'COA_PRD_PT',
  'IND1_DIF15', 'IND2_DIF15',
  'NO_REG', 'NULOS', 'TOTAL', 'NOMINAL', 'OBS', 'CONTABILIZADA')
dif$ANO <- as.factor('2015')
dif$ELECCION <- as.factor('dif')
dif[, 12:26] <- apply(dif[, 12:26], 2, function(x) gsub(' ', '0', x))
dif[, 22:26] <- apply(dif[, 22:26], 2, function(x) gsub('-', NA, x))
dif[, 12:26] <- convert_ctn(dif[, 12:26])
dif <- subset(dif,
	select = c(
		ANO, ELECCION,
		CODIGO_ESTADO, DISTRITO_FEDERAL, SECCION,
		PAN, PRI, PRD, PVEM, PT, PMC, PNA, PMOR, PH, PS,
		COA_PRI_PVEM, COA_PRD_PT,
    IND1_DIF15, IND2_DIF15,
    NO_REG
		)
	)

### ALL
mydat <- bind_rows(dat, dif)

# CLEAN
mydf <- subset(mydat,
  select = -c(
    CIRC, CABECERA_FED, ESTATUS, TPEJF, OBS, RUTA, NULOS, TOTAL, VALIDOS, CASILLA
    )
  )
mydf$NOMBRE_ESTADO <- cleanText(tolower(mydf$NOMBRE_ESTADO))
mydf$NOMBRE_MUNICIPIO <- cleanText(tolower(mydf$NOMBRE_MUNICIPIO))
df <- mydf %>%
  select(noquote(order(colnames(mydf)))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL, SECCION, NOMINAL,
    everything()) %>%
  select(-starts_with('COA'), -IND1_DIF15, -IND2_DIF15, -NO_REG, everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

# WRITE
write.csv(df, 'out/clean_ine.csv', row.names = F)