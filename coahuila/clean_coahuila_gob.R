# Clean database for Coahuila gobernor vote results from 2017 election.

# SETUP
setwd('/Users/Franklin/Git/votes/coahuila')
options(scipen = 999)
require(data.table)
require(dplyr)
require(jsonlite)
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
data <- read.xlsx('raw/gob_2017.xlsx', 1)

# Gobernador 2017
dat <- data %>% select(-1, -2) # Remove folios
dat <- dat %>% # Remove columns that sum zero
  select(which(!colSums(dat, na.rm = TRUE) %in% 0))
names(dat)[1:17] <- c(
  'DISTRITO_LOC', 'CODIGO_MUNICIPIO', 'SECCION',
  'PAN', 'PRI', 'PRD', 'PT', 'PVEM', 'PUDC', 'PNA', 'PSI', 'PPC', 'PJ', 'PRC', 'PCP', 'PMOR', 'PES')

# Coalition vectors
coa_gob_pri <- c('PRI', 'PVE', 'PNA', 'SI', 'PJ', 'PRC', 'PCP')
coa_gob_pan <- c('PAN', 'PUDC', 'PPC', 'PES')

# Aggregate coalitions to single party
dat <- dat %>%
  transform(PRI = rowSums(select(., matches(paste(coa_gob_pri, collapse = '|'))))) %>%
  transform(PAN = rowSums(select(., matches(paste(coa_gob_pan, collapse = '|'))))) %>%
  # Reduce
  .[ , c(3:11, 132:134)] %>%
  # Rename columns
  rename(CC1_GOB17 = cand_ind1, CC2_GOB17 = cand_ind2, CC3_GOB17 = cand_nreg) %>% # old = new
  # Add year
  mutate(ANO = as.factor('2017')) %>%
  # Add election
  mutate(ELECCION = as.factor('gob')) %>%
  # Add state
  mutate(ESTADO = as.character('coahuila')) %>%
  # Add state code
  mutate(CODIGO_ESTADO = as.numeric('5')) %>%
  # Data frame
  as.data.frame

# Clean up a bit
gob <- dat %>%
  # Remove electoral sections labeled '0'
  filter(!grepl('^0', SECCION)) %>%
  # Quick column cleanup
  select(order(colnames(.))) %>%
  select(
    ANO, ELECCION, CODIGO_ESTADO, ESTADO, SECCION,
    everything()) %>%
  arrange(ANO, ELECCION, ESTADO, SECCION)

 # Write
write.csv(gob, 'out/coahuila_gob.csv', row.names = F)