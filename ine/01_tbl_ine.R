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
require(stringr)

# FUN

=======
source('../fun/general_fun.R')
>>>>>>> a14f1d1... Fix code and comments

# DATA

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
>>>>>>> 36fb24d... Fix code
est <- data %>% filter(ANO == 2009) %>% filter(ELECCION == 'dif') %>% select(CODIGO_ESTADO, ESTADO)
est <- unique(est[c('CODIGO_ESTADO', 'ESTADO')]) 
    # Match
x <- data %>% filter(ANO == 2009)
y <- data %>% filter(ANO == 2012) %>% select(-CODIGO_ESTADO) %>% left_join(., est)
z <- data %>% filter(ANO == 2015) %>% select(-ESTADO) %>% left_join(., est)

  # 2. City names
sec <- y %>% filter(ELECCION == 'dif') %>% select(CODIGO_ESTADO, MUNICIPIO, SECCION)
sec <- unique(sec[c('CODIGO_ESTADO', 'MUNICIPIO', 'SECCION')])
    # Match
z <- z %>% select(-MUNICIPIO) %>% left_join(., sec)

  # 3. City IDS
mun <- fromJSON('../inegi/raw/mx_tj.json')
mun <- mun[[2]][[2]][[3]][[2]]
names(mun) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO_RAW')
mun$MUNICIPIO <- cleanText(tolower(mun$MUNICIPIO_RAW))
mun <- mun %>% select(-MUNICIPIO_RAW) %>% arrange(CODIGO_ESTADO, CODIGO_MUNICIPIO)

    # Test
#test <- subset(mun, is.na(mun$CODIGO_MUNICIPIO))
#test <- subset(test, select = c(CODIGO_ESTADO, MUNICIPIO, CODIGO_MUNICIPIO))
#test <- unique(test[c('CODIGO_ESTADO', 'MUNICIPIO', 'CODIGO_MUNICIPIO')])
#sum(is.na(test[, c('CODIGO_MUNICIPIO')]))
#write.csv(test, 'dat/missing_mun_ids.csv', row.names = F)

    # Match
a <- bind_rows(x, y, z)
b <- mun
dat <- left_join(a, b)

# TOTALS
  # Compute simple sum for each year
s1 <- dat %>%
  filter(ANO == 2009)
sum1 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s1,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )
s2 <- dat %>%
  filter(ANO == 2012)
sum2 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s2,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )
s3 <- dat %>%
  filter(ANO == 2015)
sum3 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s3,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )

  # Aggregate
sum <- bind_rows(sum1, sum2, sum3)
sum <- sum %>% select(-CODIGO_MUNICIPIO)
sum$NOMINAL[sum$NOMINAL == 0] <- NA

  # Add missing columns
u1 <- dat %>% filter(ANO == 2009)
unq1 <- unique(u1[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_FED', 'SECCION')])
u2 <- dat %>% filter(ANO == 2012)
unq2 <- unique(u2[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_FED', 'SECCION')])
u3 <- dat %>% filter(ANO == 2015)
unq3 <- unique(u3[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_FED', 'SECCION')])

unq <- bind_rows(unq1, unq2, unq3)
unq <- unq %>% select(ANO, ELECCION, CODIGO_ESTADO, ESTADO, CODIGO_MUNICIPIO, MUNICIPIO, SECCION)

# TABLE
  # Join votes with these columns
tbl <- left_join(sum, unq)

  # Replace NaNs with NAs
tbl[tbl == 'NaN'] = NA

  # Clean
df <- tbl %>%
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, CODIGO_MUNICIPIO, MUNICIPIO, DISTRITO_FED, SECCION,
    everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

# WRITE
write.csv(df, 'out/tbl_ine.csv', row.names = F)