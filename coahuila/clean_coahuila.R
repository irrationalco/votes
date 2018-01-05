# Create Coahuila database with historic (2003-2017) local election votes.

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
  text <- str_replace_all(text, 'ñ', 'n')
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

ayu_13 <- read.xlsx('raw/ayu_2013.xlsx', 1)
dil_14 <- read.xlsx('raw/dil_2014.xlsx', 1)
ayu_17 <- read.xlsx('raw/ayu_2017.xlsx', 1)
dil_17 <- read.xlsx('raw/dil_2017.xlsx', 1)
gob_17 <- read.xlsx('raw/gob_2017.xlsx', 1)

  # Ayuntamiento 2013
names(ayu_13) <- c(
  'MUNICIPIO', 'DISTRITO_LOC', 'SECCION',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PUDC', 'PMC', 'PNA', 'PSDC', 'PPC', 'PJ', 'PRC', 'PPRO',
  'IND1_AYU13', 'IND2_AYU13', 'IND3_AYU13',
  'VALIDOS', 'NULOS', 'TOTAL', 'NOMINAL')
ayu_13$ANO <- as.factor('2013')
ayu_13$ELECCION <- as.factor('ayu')

  # Diputado Local 2014
names(dil_14) <- c(
  'DISTRITO_LOC', 'CODIGO_MUNICIPIO', 'SECCION', 'NOMINAL',
  'PAN', 'PRI', 'PTSC', 'PRD', 'PT', 'PVEM', 'PUDC', 'PMC', 'PNA', 'PSDC', 'PPC', 'PJ', 'PRC', 'PPRO', 'PCP',
  'IND1_DIL14', 'IND2_DIL14',
  'VALIDOS', 'NULOS', 'TOTAL')
dil_14$ANO <- as.factor('2014')
dil_14$ELECCION <- as.factor('dil')

  # 2017
# Todas las columnas de coaliciones tienen al menos un voto
# x <- ayu_17
# x <- x[,apply(x,2,function(x) !all(x==0))]

  # Ayuntamiento 2017
names(ayu_17)[3:20] <- c(
  'DISTRITO_LOC', 'CODIGO_MUNICIPIO', 'SECCION',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PUDC', 'PMC', 'PNA', 'PSI', 'PPC', 'PJ', 'PRC', 'PCP', 'PMOR', 'PES')

    # Remove useless shit
ayu_17 <- ayu_17 %>%
  # Remove folios
  select(-1, -2) %>%
  # Aggregate coalitions to single party
  mutate(PRI = rowSums(select(., starts_with('PRI-')))) %>%
  mutate(PAN = rowSums(select(., starts_with('PAN-')))) %>%
  mutate(UDC = rowSums(select(., starts_with('UDC-')))) %>%
  mutate(PPC = rowSums(select(., starts_with('PPC-')))) %>%
  mutate(PVEM = rowSums(select(., starts_with('PVEM-')))) %>%
  mutate(PNA = rowSums(select(., starts_with('PNA-')))) %>%
  # Reduce
  select(1:18) %>%
  # Add year
  mutate(ANO = as.factor('2017')) %>%
  # Add election
  mutate(ELECCION = as.factor('ayu')) %>%
  # Data frame
  as.data.frame

# Diputado Local 2017
names(dil_17)[3:20] <- c(
  'DISTRITO_LOC', 'CODIGO_MUNICIPIO', 'SECCION',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PUDC', 'PMC', 'PNA', 'PSI', 'PPC', 'PJ', 'PRC', 'PCP', 'PMOR', 'PES')

    # Remove useless shit
dil_17 <- dil_17 %>%
  # Remove folios
  select(-1, -2) %>%
  # Aggregate coalitions to single party
  mutate(PRI = rowSums(select(., starts_with('PRI-')))) %>%
  mutate(PAN = rowSums(select(., starts_with('PAN-')))) %>%
  mutate(UDC = rowSums(select(., starts_with('UDC-')))) %>%
  mutate(PPC = rowSums(select(., starts_with('PPC-')))) %>%
  mutate(PVEM = rowSums(select(., starts_with('PVEM-')))) %>%
  mutate(PNA = rowSums(select(., starts_with('PNA-')))) %>%
  # Reduce
  select(1:18) %>%
  # Add year
  mutate(ANO = as.factor('2017')) %>%
  # Add election
  mutate(ELECCION = as.factor('dil')) %>%
  # Data frame
  as.data.frame

# Gobernador 2017
names(gob_17)[3:20] <- c(
  'DISTRITO_LOC', 'CODIGO_MUNICIPIO', 'SECCION',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PUDC', 'PMC', 'PNA', 'PSI', 'PPC', 'PJ', 'PRC', 'PCP', 'PMOR', 'PES')

    # Remove useless shit
gob_17 <- gob_17 %>%
  # Remove folios
  select(-1, -2) %>%
  # Aggregate coalitions to single party
  mutate(PRI = rowSums(select(., starts_with('PRI-')))) %>%
  mutate(PAN = rowSums(select(., starts_with('PAN-')))) %>%
  mutate(UDC = rowSums(select(., starts_with('UDC-')))) %>%
  mutate(PPC = rowSums(select(., starts_with('PPC-')))) %>%
  mutate(PVEM = rowSums(select(., starts_with('PVEM-')))) %>%
  mutate(PNA = rowSums(select(., starts_with('PNA-')))) %>%
  # Reduce
  select(1:18) %>%
  # Add year
  mutate(ANO = as.factor('2017')) %>%
  # Add election
  mutate(ELECCION = as.factor('gob')) %>%
  # Data frame
  as.data.frame

  ### ALL

dat <- bind_rows(ayu_13, dil_14, ayu_17, dil_17, gob_17)
dat$ESTADO <- as.character('coahuila')
dat$CODIGO_ESTADO <- as.numeric('5')
dat$MUNICIPIO <- cleanText(tolower(dat$MUNICIPIO))
dat <- subset(dat, select = -c(TOTAL, NULOS))

# Stuff
df <- dat %>%
  # Remove independents (we can infer the share out of the 'VALIDOS' count)
  select(-matches('^IND')) %>%
  # Remove electoral sections labeled '0'
  filter(!grepl('^0', SECCION)) %>%
  # Quick column cleanup
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, CODIGO_MUNICIPIO, MUNICIPIO, DISTRITO_LOC, SECCION, NOMINAL,
    everything()) %>%
  arrange(ANO, ELECCION, ESTADO, SECCION)

# Write
write.csv(df, 'out/coahuila.csv', row.names = F)