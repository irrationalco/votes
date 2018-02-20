# Description: Preprocess files containing historic (2009-2015) federal election records.
# Author: Mariana <mariana@irrational.ly>

setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(tidyr)
require(openxlsx)
require(stringi)
source('../_misc/fun/general_fun.R')

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
dat$CODIGO_ESTADO <- stri_pad_left(dat$CODIGO_ESTADO, 2, 0)

### 2015

  # Data
dif <- read.xlsx('raw/ine_dif_2015.xlsx', 1)
names(dif) <- c(
  'CODIGO_ESTADO', 'DISTRITO_FEDERAL', 'SECCION', 'ID_CASILLA',
  'TIPO_CASILLA', 'EXT_CONTIGUA', 'UBICACION_CASILLA', 'TIPO_ACTA', 'NUM_BOLETAS_SOBRANTES', 'TOTAL_CIUDADANOS_VOTARON', 'NUM_BOLETAS_EXTRAVIADAS',
  'PAN', 'PRI', 'PRD', 'PVEM', 'PT', 'PMC', 'PNA', 'PMOR', 'PH', 'PS',
  'COA_PRI_PVEM', 'COA_PRD_PT',
  'CC1_DIF_2015', 'CC2_DIF_2015',
  'NO_REG', 'NULOS', 'TOTAL', 'NOMINAL', 'OBS', 'CONTABILIZADA')
dif$CODIGO_ESTADO <- stri_pad_left(dif$CODIGO_ESTADO, 2, 0)
dif$ANO <- as.factor('2015')
dif$ELECCION <- as.factor('dif')

  # Replace whitespace with zero, '-' with NA, convert multiple columns to numeric
dif[, 12:26] <- apply(dif[, 12:26], 2, function(x) gsub(' ', '0', x))
dif[, 22:26] <- apply(dif[, 22:26], 2, function(x) gsub('-', NA, x))
dif[, 12:26] <- convert_ctn(dif[, 12:26])

  # Use tidyr to spread independents by state into two wide dfs
dif.w1 <- spread(dif, CODIGO_ESTADO, CC1_DIF_2015, fill = NA)
  dif.w1 <- dif.w1[colSums(!is.na(dif.w1)) > 0]
  dif.w1 <- dif.w1[, 32:length(dif.w1)]
  names(dif.w1) <- paste('CC1', names(dif.w1), 'DIF_2015', sep = '_')
dif.w2 <- spread(dif, CODIGO_ESTADO, CC2_DIF_2015, fill = NA)
  dif.w2 <- dif.w2[colSums(!is.na(dif.w2)) > 0]
  dif.w2 <- subset(dif.w2, select = c(32))
  names(dif.w2) <- paste('CC2', names(dif.w2), 'DIF_2015', sep = '_')
dif <- dif %>%
  select(-starts_with('CC'))

  # Cbind main df with both wide dfs and keep only needed columns
ddf <- dif %>%
  cbind(., dif.w1, dif.w2) %>%
  select(
		ANO, ELECCION,
		CODIGO_ESTADO, DISTRITO_FEDERAL, SECCION,
		PAN, PRI, PRD, PVEM, PT, PMC, PNA, PMOR, PH, PS,
		COA_PRI_PVEM, COA_PRD_PT,
    c(32:length(.)),
    NO_REG
		)

### ALL

  # Bind dfs and fuck off coalitions
mydat <- bind_rows(dat, ddf)
mydat <- mydat %>%
  rename(
    PRI2 = PRI,
    PRD2 = PRD,
    PT2 = PT
    ) %>%
  transform(
    PRI = rowSums(select_(., 'PRI2', 'COA_PRI_PVEM')),
    PRD = rowSums(select_(., 'PRD2', 'COA_PRD_PT_PMC', 'COA_PRD_PT', 'COA_PRD_PMC')),
    PT  = rowSums(select_(., 'PT2', 'COA_PT_PMC'))
    ) %>%
  select(
    -PRI2, -PRD2, -PT2,
    -starts_with('COA'))

# COLUMNS

  # More column clearing and lowercasing
mydf <- subset(mydat,
  select = -c(
    CIRC, CABECERA_FED, ESTATUS, TPEJF, OBS, RUTA, NULOS, TOTAL, VALIDOS, CASILLA
    )
  )
mydf$NOMBRE_ESTADO <- cleanText(tolower(mydf$NOMBRE_ESTADO))
mydf$NOMBRE_MUNICIPIO <- cleanText(tolower(mydf$NOMBRE_MUNICIPIO))

  # Arrange and stuff
df <- mydf %>%
  select(noquote(order(colnames(.)))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, NOMBRE_MUNICIPIO, DISTRITO_FEDERAL, SECCION, NOMINAL,
    everything()) %>%
  select(-starts_with('CC'), -NO_REG, everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

# WRITE
fwrite(df, 'out/clean_ine2.csv', row.names = F)