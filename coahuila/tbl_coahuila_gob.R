# Summary table of Coahuila historic (2013-2017) local election votes.

# SETUP

setwd('')
options(scipen = 999)
require(data.table)
require(doBy)
require(dplyr)
require(jsonlite)
require(stringr)

# FUN

cleanText <- function(text) {
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

# Read
raw <- fread('out/coahuila.csv', header = TRUE, sep = ',', stringsAsFactors = F)

# IDS
# Unique list of city ids
mun <- fromJSON('dat/mx_tj.json')
mun <- mun[[2]][[2]][[3]][[2]]
names(mun) <- c('CODIGO_ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO_RAW')
mun$MUNICIPIO <- cleanText(tolower(mun$MUNICIPIO_RAW))
mun <- mun %>% select(-MUNICIPIO_RAW) %>% arrange(CODIGO_ESTADO, CODIGO_MUNICIPIO)
mun <- mun %>% filter(CODIGO_ESTADO == 5)

# NAs
  # MUNICIPIO
nombre_na <- subset(raw, is.na(raw$MUNICIPIO))
nombre_na <- subset(nombre_na, select = -c(MUNICIPIO))
nombre <- left_join(nombre_na, mun)
    # Success!
# test1 <- subset(nombre, is.na(nombre$MUNICIPIO))

  # CODIGO_MUNICIPIO
codigo_na <- subset(raw, is.na(raw$CODIGO_MUNICIPIO))
codigo_na <- subset(codigo_na, select = -c(CODIGO_MUNICIPIO))
codigo <- left_join(codigo_na, mun)
    # No full success
# test2 <- subset(codigo, is.na(codigo$CODIGO_MUNICIPIO))
# test2 <- subset(test2, select = c(CODIGO_ESTADO, MUNICIPIO, CODIGO_MUNICIPIO))
# test2 <- unique(test2[c('CODIGO_ESTADO', 'MUNICIPIO', 'CODIGO_MUNICIPIO')])
# sum(is.na(test2[, c('CODIGO_MUNICIPIO')]))
# write.csv(test2, 'out/missing_mun.csv', row.names = F)
    # Fix corrupt data manually
codigo$MUNICIPIO <- str_replace_all(codigo$MUNICIPIO, '^cuatrocienegas$', 'cuatro cienegas')
codigo$MUNICIPIO <- str_replace_all(codigo$MUNICIPIO, '^francisco imadero$', 'francisco i madero')
codigo$MUNICIPIO <- str_replace_all(codigo$MUNICIPIO, 'gral cepeda$', 'general cepeda')
codigo <- subset(codigo, select = -c(CODIGO_MUNICIPIO))
codigo <- left_join(codigo, mun)

# TABLE

dat <- bind_rows(nombre, codigo)
dat <- dat %>% select(-VALIDOS)

  # TOTALS

s1 <- dat %>%
  filter(ANO == 2013)
sum1 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s1,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )

s2 <- dat %>%
  filter(ANO == 2014)
sum2 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s2,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )

s3 <- dat %>%
  filter(ANO == 2017)
sum3 <- summaryBy(
    . ~ ANO + ELECCION + CODIGO_ESTADO + SECCION,
    data = s3,
    FUN = c(sum),
    keep.names = TRUE,
    na.rm = TRUE
    )

sum <- bind_rows(sum1, sum2, sum3)
sum <- sum %>% select(-CODIGO_MUNICIPIO)
sum$NOMINAL[sum$NOMINAL == 0] <- NA

# Add missing colmuns
u1 <- dat %>% filter(ANO == 2013)
unq1 <- unique(u1[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_LOC', 'SECCION')])
u2 <- dat %>% filter(ANO == 2014)
unq2 <- unique(u2[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_LOC', 'SECCION')])
u3 <- dat %>% filter(ANO == 2017)
unq3 <- unique(u3[c('ANO', 'ELECCION', 'CODIGO_ESTADO', 'ESTADO', 'CODIGO_MUNICIPIO', 'MUNICIPIO', 'DISTRITO_LOC', 'SECCION')])

# Unique tables to bind to sum table
unq <- bind_rows(unq1, unq2, unq3)
unq <- unq %>% select(ANO, ELECCION, CODIGO_ESTADO, ESTADO, CODIGO_MUNICIPIO, MUNICIPIO, SECCION)

# Table
sum <- left_join(sum, unq)
sum[sum == 'NaN'] = NA # Replace NaNs with NAs
sum <- sum %>%
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, CODIGO_MUNICIPIO, MUNICIPIO, DISTRITO_LOC, SECCION,
    everything()) %>%
  arrange(ANO, ELECCION, CODIGO_ESTADO, SECCION)

  # PERCENTAGE

# FFS
# http://stackoverflow.com/questions/26019474/how-to-divide-all-columns-by-sum-of-columns
# pct = df/rowSums(df)
pct <- as.data.frame(
  sum[, c(10:ncol(sum))]/rowSums(sum[, c(10:ncol(sum))])
)

# Append suffix
colnames(pct) <- paste(colnames(pct), "pct", sep = ".")

  # PARTICIPATION

# Parties with >0 were registered in a certain election
par <- summaryBy(
    . ~ ANO + ELECCION,
    data = sum,
    FUN = c(max),
    keep.names = TRUE
    )

# Remove columns that shouldn't be summed
par <- subset(par, select = -c(CODIGO_ESTADO, CODIGO_MUNICIPIO, DISTRITO_LOC, SECCION, NOMINAL))

# 0 means no participation
par_tbl <- cbind(apply(par[, 3:ncol(par)], 2, function(x) ifelse(x > 0, 1, 0)), par[, 1:2])

# Append suffix
colnames(par_tbl)[1:18] <- paste(colnames(par_tbl)[1:18], "par", sep = ".")

# WRITE
write.csv(sum, 'out/tbl_coahuila.csv', row.names = F)
write.csv(par_tbl, 'out/tbl_coahuila_parties.csv', row.names = F)