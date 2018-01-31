# Differences in municipal codes - IFE & INEGI

# SETUP
setwd('')
options(scipen = 999)
require(rgdal)
#require(gpclib)    # Only for OSX install
#gpclibPermit()     # Same ^

# MAPA
dat <- readOGR('./raw', 'mexico') # Takes a while -  be patient

# KEY
key <- as.data.frame(subset(dat, select = c(ENTIDAD, MUN_IFE, MUN_INEGI, SECCION)))
names(key) <- c('CODIGO_ENTIDAD', 'CODIGO_MUNICIPIO_IFE, CODIGO_MUNICIPIO_INEGI, SECCION')
write.csv(key, 'out/key_ife_vs_inegi.csv', row.names = FALSE, quote = FALSE)