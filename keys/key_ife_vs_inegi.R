# Diferencias entre ids de IFE e INEGI

# SETUP

setwd('')
options(scipen = 999)
require(rgdal)
#require(gpclib)    # Ignorar en Windows - solo first install en OSX
#gpclibPermit()     # Y esto también

# MAPA
dat <- readOGR('./raw', 'mexico') # Esto tarda

# KEY
key <- as.data.frame(subset(dat, select = c(ENTIDAD, MUN_IFE, MUN_INEGI, SECCION)))
write.csv(key, 'key_ife_vs_inegi.csv', row.names = FALSE, quote = FALSE)