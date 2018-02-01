# Description
# Create database with historic (2009-2015) federal election votes.

# SETUP
setwd('/Users/Franklin/Git/votes/ine')
options(scipen = 999)
require(data.table)
require(dplyr)
require(tidyr)
require(openxlsx)
<<<<<<< HEAD
<<<<<<< HEAD
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
=======
source('../fun/general_fun.R')
>>>>>>> a14f1d1... Fix code and comments
=======
source('../_fun/general_fun.R')
>>>>>>> 5960119... Fix code path to helper functions

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
  # Subset
mydf <- subset(mydat,
  select = -c(
    CIRC, CABECERA_FED, ESTATUS, TPEJF, OBS, RUTA, NULOS, TOTAL, VALIDOS, CASILLA
    )
  )

  # Text
mydf$NOMBRE_ESTADO <- cleanText(tolower(mydf$NOMBRE_ESTADO))
mydf$NOMBRE_MUNICIPIO <- cleanText(tolower(mydf$NOMBRE_MUNICIPIO))

  # Quick column cleanup
df <- mydf %>%
  select(noquote(order(colnames(mydf)))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL, SECCION, NOMINAL,
    everything()) %>%
  select(-starts_with('COA'), -IND1_DIF15, -IND2_DIF15, -NO_REG, everything()) %>%
  arrange(ANO, ELECCION, NOMBRE_ESTADO, SECCION)

# WRITE
write.csv(df, 'out/clean-ine.csv', row.names = F)