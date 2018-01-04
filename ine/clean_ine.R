# Create database with historic (2009-2015) federal election votes.

# SETUP
#########

setwd('')

options(scipen = 999)

require(data.table)
require(dplyr)
require(tidyr)
require(openxlsx)
require(stringr)

# FUN
#########

cleanText <- function(text) 
{
  text <- str_replace_all(text, 'á', 'a')
  text <- str_replace_all(text, 'é', 'e')
  text <- str_replace_all(text, 'í', 'i')
  text <- str_replace_all(text, 'ó', 'o')
  text <- str_replace_all(text, 'ú', 'u')
  text <- str_replace_all(text, 'ü', 'u')
  text <- str_replace_all(text, '\\.', '')
  text <- gsub('(?<=[\\s])\\s*|^\\s+|\\s+$', '', text, perl = TRUE)
    # checks for whitespace - deserves its own explanation:
    # (?<=    look behind to see if there is
    # [\s]    any character of: whitespace (\n, \r, \t, \f, and ' ')
    # )       end of look behind
    # \s*     whitespace (\n, \r, \t, \f, and ' ') (0 or more times (matching the most amount possible))
    # |       or
    # ^       the beginning of the string
    # \s+     whitespace (\n, \r, \t, \f, and ' ') (1 or more times (matching the most amount possible))
    # $       before an optional \n, and the end of the string
  return(text)
}

# DATA
#########

# Read files

  ### 2009 - 2012

data_filenames <- list.files(path = 'raw', pattern = '*.txt') # Files
data_path <- as.character('raw/')                             # Path
data_files <- paste(data_path, data_filenames, sep = '')      # Files + Path
data <- lapply(                                               # Path
    data_files,
    read.table,
    header = TRUE,
    stringsAsFactors = FALSE,
    sep = '|',
    encoding = 'latin1')                                      # Specific encoding
typeof(data)                                                  # What do I hav here?
str(data)                                                     # Structure

# Colnames

dat <- data

names(dat[[1]]) <- c(
  'CIRC', 'CODIGO_ESTADO', 'ESTADO', 'DISTRITO_FED', 'CABECERA_FED', 'MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PCONV', 'PNA', 'PSD', 'PPM', 'PSM',
  'NO_REG', 'NULOS', 'TOTAL', 'NOMINAL', 'ESTATUS', 'TPEJF')
names(dat[[2]]) <- c(
  'ESTADO', 'DISTRITO_FED', 'MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')
names(dat[[3]]) <- c(
  'ESTADO', 'DISTRITO_FED', 'MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'NOMINAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')
names(dat[[4]]) <- c(
  'ESTADO', 'DISTRITO_FED', 'MUNICIPIO', 'SECCION', 'CASILLA',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA',
  'COA_PRI_PVEM', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC', 'COA_PT_PMC',
  'NO_REG', 'NULOS', 'VALIDOS', 'TOTAL', 'TPEJF', 'OBS', 'RUTA', 'ESTATUS')

# ¿Cómo se llaman mis archivos?
data_files

# Sabiendo esto, nombro columnas relevantes en secuencia
ano <- as.factor(c('2009', '2012', '2012', '2012'))
eleccion <- as.factor(c('dif', 'dif', 'prs', 'sen'))

# Asigno las columnas anteriores
dat <- mapply(cbind, dat, 'ANO' = ano, SIMPLIFY = F)
dat <- mapply(cbind, dat, 'ELECCION' = eleccion, SIMPLIFY = F)

# Junto todos los data frames en uno
dat <- data.table::rbindlist(l = dat, use.names = TRUE, fill = TRUE)

  ### 2015

dif <- read.xlsx('raw/ine_dif_2015.xlsx', 1)
names(dif) <- c(
  'CODIGO_ESTADO', 'DISTRITO_FED', 'SECCION', 'ID_CASILLA',
  'TIPO_CASILLA', 'EXT_CONTIGUA', 'UBICACION_CASILLA', 'TIPO_ACTA', 'NUM_BOLETAS_SOBRANTES', 'TOTAL_CIUDADANOS_VOTARON', 'NUM_BOLETAS_EXTRAVIADAS',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA', 'PMOR', 'PH', 'PS',
  'COA_PRI_PVEM', 'COA_PRD_PT',
  'IND1_DIF15', 'IND2_DIF15',
  'NO_REG', 'NULOS', 'TOTAL', 'NOMINAL', 'OBS', 'CONTABILIZADA')
dif$ANO <- as.factor('2015')
dif$ELECCION <- as.factor('dif')
dif[, 12:25] <- apply(dif[, 12:25], 2, function(x) gsub(' ', '0', x))
dif[, 22:25] <- apply(dif[, 22:25], 2, function(x) gsub('-', NA, x))
dif$PAN <- as.numeric(dif$PAN)
dif$PRI <- as.numeric(dif$PRI)
dif$PRD <- as.numeric(dif$PRD)
dif$PVEM <- as.numeric(dif$PVEM)
dif$PT <- as.numeric(dif$PT)
dif$PMC <- as.numeric(dif$PMC)
dif$PNA <- as.numeric(dif$PNA)
dif$PMOR <- as.numeric(dif$PMOR)
dif$PH <- as.numeric(dif$PH)
dif$PS <- as.numeric(dif$PS)
dif$COA_PRI_PVEM <- as.numeric(dif$COA_PRI_PVEM)
dif$COA_PRD_PT <- as.numeric(dif$COA_PRD_PT)
dif$IND1_DIF15 <- as.numeric(dif$IND1_DIF15)
dif$IND2_DIF15 <- as.numeric(dif$IND2_DIF15)
dif <- subset(dif,
	select = c(
		ANO, ELECCION,
		CODIGO_ESTADO, DISTRITO_FED, SECCION,
		PAN, PRI, PRD, PVEM, PT, PMC, PNA, PMOR, PH, PS,
		COA_PRI_PVEM, COA_PRD_PT
		)
	)

  ### ALL

mydat <- bind_rows(dat, dif)

# CLEAN
#########

# Subset
mydf <- subset(mydat,
  select = -c(
    CIRC, CABECERA_FED, ESTATUS, TPEJF, OBS, RUTA, NO_REG, NULOS, TOTAL, VALIDOS, CASILLA
    )
  )

# Text
mydf$ESTADO <- cleanText(tolower(mydf$ESTADO))
mydf$MUNICIPIO <- cleanText(tolower(mydf$MUNICIPIO))

# WRITE
#########

# Quick column cleanup
df <- mydf %>%
  select(noquote(order(colnames(mydf)))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, MUNICIPIO, DISTRITO_FED, SECCION, NOMINAL,
    everything()) %>%
  arrange(ANO, ELECCION, ESTADO, SECCION)

# Write
write.csv(df, 'out/ine.csv', row.names = F)