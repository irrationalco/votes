# Create database with historic (2009-2015) federal election votes.

# SETUP
setwd('/Users/Franklin/Git/votes/ine')
options(scipen = 999)
require(data.table)
require(dplyr)
require(tidyr)
require(openxlsx)
require(stringr)

# FUN
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

# Read

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
dif[, 12:26] <- apply(dif[, 12:26], 2, function(x) gsub(' ', '0', x))
dif[, 22:26] <- apply(dif[, 22:26], 2, function(x) gsub('-', NA, x))
# Convert multiple columns from character to numeric
convert_ctn <- function(df, name = 'character', FUN = as.numeric) as.data.frame(
  lapply(df, function(x) if (class(x) == name) FUN(x) else x))
dif[, 12:26] <- convert_ctn(dif[, 12:26])
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

# Subset
mydf <- subset(mydat,
  select = -c(
    CIRC, CABECERA_FED, ESTATUS, TPEJF, OBS, RUTA, NO_REG, NULOS, TOTAL, VALIDOS, CASILLA
    )
  )

# Text
mydf$ESTADO <- cleanText(tolower(mydf$ESTADO))
mydf$MUNICIPIO <- cleanText(tolower(mydf$MUNICIPIO))

# Quick column cleanup
df <- mydf %>%
  select(noquote(order(colnames(mydf)))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, MUNICIPIO, DISTRITO_FED, SECCION, NOMINAL,
    everything()) %>%
  arrange(ANO, ELECCION, ESTADO, SECCION)

# WRITE
write.csv(df, 'out/ine.csv', row.names = F)