# Extrae datos del censo 2010 de INEGI.

# SETUP

setwd('')
options(scipen = 999)
require(dplyr)
require(ggplot2)    # Necesario para la función fortify()
require(doBy)
require(rgdal)
#require(gpclib)    # Ignorar en Windows - solo first install en OSX
#gpclibPermit()     # Y esto también

# MAPA
dat <- readOGR('./raw', 'mexico') # Esto tarda

# KEY
key <- as.data.frame(subset(dat, select = c(ENTIDAD, MUN_IFE, MUN_INEGI, SECCION)))

# FORTIFY
map.data <- dat
map.df <- data.frame(id = rownames(map.data@data), map.data@data)
map.f <- fortify(map.data)
map <- merge(map.f, map.df, by = 'id')

    # Sample
map_sample <- head(map, 15)
write.csv(map_sample, 'out/map_sample_inegi.csv', row.names = FALSE, quote = FALSE)

# INDICATORS

# Transformam

    # Poblation
    map$TOTAL           <-  with(map, POBTOT)
    map$HOMBRES         <-  with(map, (POBMAS/POBTOT)*100)
    map$MUJERES         <-  with(map, (POBFEM/POBTOT)*100)

    # Fecundity
    map$HIJOS           <-  with(map, PROM_HNV)

    # Migration
    map$ENTIDAD_NAC     <-  with(map, (PNACENT/POBTOT)*100)
    map$ENTIDAD_INM     <-  with(map, (PRES2005/P_5YMAS)*100)
    map$ENTIDAD_MIG     <-  with(map, (PRESOE05/P_5YMAS)*100)

    # Handicap
    map$LIMITACION      <-  with(map, (PCON_LIM/POBTOT)*100)

    # Education
    map$ANALFABETISMO   <-  with(map, (P15YM_AN/P_15YMAS)*100)
    map$EDUCACION_AV    <-  with(map, (P18YM_PB/P_18YMAS)*100)

    # Economy
    map$PEA             <-  with(map, (PEA/POBTOT)*100)

    # Health
    map$NO_SERV_SALUD   <-  with(map, (PSINDER/POBTOT)*100)

    # Marriage
    map$MATRIMONIOS     <-  with(map, (P12YM_CASA/P_12YMAS)*100)

    # Home
    map$HOGARES         <-  with(map, TOTHOG)
    map$HOGARES_JEFA    <-  with(map, (HOGJEF_F/TOTHOG)*100)
    map$HOGARES_POB     <-  with(map, (POBHOG/TOTHOG)*100)

    # Cars
    map$AUTO            <-  with(map, (VPH_AUTOM/VIVPAR_HAB)*100)

# Summary
inegi.sum <- map
inegi.sum <- summaryBy(
    TOTAL + HOMBRES + MUJERES +
    HIJOS +
    ENTIDAD_NAC + ENTIDAD_INM + ENTIDAD_MIG +
    LIMITACION +
    ANALFABETISMO + EDUCACION_AV +
    PEA +
    NO_SERV_SALUD +
    MATRIMONIOS +
    HOGARES + HOGARES_JEFA + HOGARES_POB +
    AUTO
    ~ ENTIDAD + MUN_IFE + MUN_INEGI + SECCION,
    data = inegi.sum, keep.names = TRUE, FUN = mean)
inegi.sum.key <- left_join(inegi.sum, key)

# All demographics
inegi <- map
inegi <- summaryBy(
    . ~ ENTIDAD + MUN_IFE + MUN_INEGI + SECCION,
    data = inegi, keep.names = TRUE, FUN = mean)
inegi.key <- left_join(inegi, key)

# Write
write.csv(inegi.sum.key, 'out/tbl_inegi_summary.csv', row.names = FALSE, quote = FALSE)
write.csv(inegi.key, 'out/tbl_inegi.csv', row.names = FALSE, quote = FALSE)