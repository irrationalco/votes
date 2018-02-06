# Description
# Summary table of historic (2009-2015) federal election votes.

# SETUP
setwd('/Users/Franklin/Git/votes/ine')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(jsonlite)
<<<<<<< HEAD
<<<<<<< HEAD
require(stringr)

# FUN

=======
source('../fun/general_fun.R')
>>>>>>> a14f1d1... Fix code and comments
=======
source('../_fun/general_fun.R')
>>>>>>> 5960119... Fix code path to helper functions

# DATA
<<<<<<< HEAD

# Read
raw <- fread('out/ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)

# Transform
data <- raw %>%
	# Aggregate coalitions to single party
	transform(PRD	= rowSums(.[, c('PRD', 'COA_PRD_PMC', 'COA_PRD_PT', 'COA_PRD_PT_PMC')], na.rm = T)) %>%
	transform(PRI	= rowSums(.[, c('PRI', 'COA_PRI_PVEM')], na.rm = T)) %>%
	transform(PT	= rowSums(.[, c('PT', 'COA_PT_PMC')], na.rm = T)) %>%
	# Remove individual coalitions
	select(-matches('^COA_')) %>%
	# Remove electoral sections '0'
	filter(!grepl('^0', SECCION)) %>%
	# Data frame
=======
data <- fread('out/clean-ine.csv', header = TRUE, sep = ',', stringsAsFactors = F)

# CLEAN
dat <- data %>%
  # Aggregate coalitions to single party
  transform(PRD = rowSums(.[, c('PRD', 'COA_PRD_PMC', 'COA_PRD_PT', 'COA_PRD_PT_PMC')], na.rm = T)) %>%
  transform(PRI = rowSums(.[, c('PRI', 'COA_PRI_PVEM')], na.rm = T)) %>%
  transform(PT  = rowSums(.[, c('PT', 'COA_PT_PMC')], na.rm = T)) %>%
  # Remove individual coalitions
  select(-matches('^COA_')) %>%
  # Remove electoral sections '0'
  filter(!grepl('^0', SECCION)) %>% 
>>>>>>> c23ff75... Change formulas, codes and variable names to clean and compute votes
  as.data.frame

<<<<<<< HEAD
<<<<<<< HEAD
# CLEAN

	# Missing state ids

# Unique list of state ids
=======
# IDS
# Missing state ids
>>>>>>> bbcee36... Fix /inegi workspace
=======
# MISSING INFO
  # 1. State ids
<<<<<<< HEAD
>>>>>>> 36fb24d... Fix code
est <- data %>% filter(ANO == 2009) %>% filter(ELECCION == 'dif') %>% select(CODIGO_ESTADO, ESTADO)
est <- unique(est[c('CODIGO_ESTADO', 'ESTADO')]) 
=======
est <- dat %>% filter(ANO == 2009) %>% filter(ELECCION == 'dif') %>% select(CODIGO_ESTADO, NOMBRE_ESTADO)
est <- unique(est[c('CODIGO_ESTADO', 'NOMBRE_ESTADO')]) 
>>>>>>> c23ff75... Change formulas, codes and variable names to clean and compute votes
    # Match
x <- dat %>% filter(ANO == 2009)
y <- dat %>% filter(ANO == 2012) %>% select(-CODIGO_ESTADO) %>% left_join(., est)
z <- dat %>% filter(ANO == 2015) %>% select(-NOMBRE_ESTADO) %>% left_join(., est)

  # 2. City names
sec <- y %>% filter(ELECCION == 'dif') %>% select(CODIGO_ESTADO, NOMBRE_MUNICIPIO, SECCION)
sec <- unique(sec[c('CODIGO_ESTADO', 'NOMBRE_MUNICIPIO', 'SECCION')])
    # Match
z <- z %>% select(-NOMBRE_MUNICIPIO) %>% left_join(., sec)

  # 3. City IDS
mun <- fromJSON('../inegi/raw/mx_tj.json')
mun <- mun[[2]][[2]][[3]][[2]]
names(mun) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO_RAW')
mun$NOMBRE_MUNICIPIO <- cleanText(tolower(mun$MUNICIPIO_RAW))
mun <- mun %>% select(-MUNICIPIO_RAW) %>% arrange(CODIGO_ESTADO, CODIGO_MUNICIPIO)
    # Match
a <- bind_rows(x, y, z)
b <- mun
dat <- left_join(a, b)
    # Test
#test <- subset(mun, is.na(mun$CODIGO_MUNICIPIO))
#test <- subset(test, select = c(CODIGO_ESTADO, NOMBRE_MUNICIPIO, CODIGO_MUNICIPIO))
#test <- unique(test[c('CODIGO_ESTADO', 'NOMBRE_MUNICIPIO', 'CODIGO_MUNICIPIO')])
#sum(is.na(test[, c('CODIGO_MUNICIPIO')]))
#write.csv(test, 'log/missing-city-codes.csv', row.names = F)

# TOTALS
  # Compute simple sum for each year
s1 <- dat %>% filter(ANO == 2009)
sum1 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + CODIGO_MUNICIPIO + DISTRITO_FED + SECCION,
    data = s1,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = FALSE
    )
s2 <- dat %>% filter(ANO == 2012)
sum2 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + CODIGO_MUNICIPIO + DISTRITO_FED + SECCION,
    data = s2,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = FALSE
    )
s3 <- dat %>% filter(ANO == 2015)
sum3 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + CODIGO_MUNICIPIO + DISTRITO_FED + SECCION,
    data = s3,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = FALSE
    )

  # Aggregate
sum <- bind_rows(sum1, sum2, sum3)

  # Add missing columns
u1 <- dat %>% filter(ANO == 2009)
unq1 <- unique(u1[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'NOMBRE_ESTADO', 'CODIGO_MUNICIPIO', 'NOMBRE_MUNICIPIO', 'DISTRITO_FED', 'SECCION')])
u2 <- dat %>% filter(ANO == 2012)
unq2 <- unique(u2[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'NOMBRE_ESTADO', 'CODIGO_MUNICIPIO', 'NOMBRE_MUNICIPIO', 'DISTRITO_FED', 'SECCION')])
u3 <- dat %>% filter(ANO == 2015)
unq3 <- unique(u3[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'NOMBRE_ESTADO', 'CODIGO_MUNICIPIO', 'NOMBRE_MUNICIPIO', 'DISTRITO_FED', 'SECCION')])

unq <- bind_rows(unq1, unq2, unq3)
unq <- unq %>% select(ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, SECCION)

# TABLE
  # Join votes with these columns
tbl <- left_join(sum, unq)

  # Replace NaNs with NAs
tbl[tbl == 'NaN'] = NA

  # Clean
df <- tbl %>%
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, NOMBRE_ESTADO, CODIGO_MUNICIPIO, NOMBRE_MUNICIPIO, DISTRITO_FED, SECCION,
    everything()) %>%
  select(-IND1_DIF15, -IND2_DIF15, -NO_REG, everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

# WRITE
write.csv(df, 'out/tbl-ine.csv', row.names = F)