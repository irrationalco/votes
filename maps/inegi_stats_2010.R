# Description
# Censo INEGI 2010 statistics

setwd('')
options(scipen = 999)
require(dplyr)
require(doBy)
source('../_misc/themes/theme_maps.R')

# DATA
data <- foreign::read.dbf('raw/cartografia/inegi/2010/mexico.dbf')
map <- data

# KEY
key <- inegi.key <- fread('out/key_inegi_2010.csv', header = TRUE, sep = ',', stringsAsFactors = F)

# FORMULAS

  # All demographics
#inegi <- map
#inegi <- summaryBy(
#  . ~ CODIGO_ESTADO + CODIGO_MUNICIPIO_IFE_2010 + CODIGO_MUNICIPIO_INEGI_2010 + SECCION,
#  data = inegi, keep.names = TRUE, FUN = mean)
#inegi.key <- left_join(inegi, key)

  # Main stats & transformations
map$TOTAL           <-  with(map, POBTOT)
map$HOMBRES         <-  with(map, (POBMAS/POBTOT)*100)
map$MUJERES         <-  with(map, (POBFEM/POBTOT)*100)
map$HIJOS           <-  with(map, PROM_HNV)
map$ENTIDAD_NAC     <-  with(map, (PNACENT/POBTOT)*100)
map$ENTIDAD_INM     <-  with(map, (PRES2005/P_5YMAS)*100)
map$ENTIDAD_MIG     <-  with(map, (PRESOE05/P_5YMAS)*100)
map$LIMITACION      <-  with(map, (PCON_LIM/POBTOT)*100)
map$ANALFABETISMO   <-  with(map, (P15YM_AN/P_15YMAS)*100)
map$EDUCACION_AV    <-  with(map, (P18YM_PB/P_18YMAS)*100)
map$PEA             <-  with(map, (PEA/POBTOT)*100)
map$NO_SERV_SALUD   <-  with(map, (PSINDER/POBTOT)*100)
map$MATRIMONIOS     <-  with(map, (P12YM_CASA/P_12YMAS)*100)
map$HOGARES         <-  with(map, TOTHOG)
map$HOGARES_JEFA    <-  with(map, (HOGJEF_F/TOTHOG)*100)
map$HOGARES_POB     <-  with(map, (POBHOG/TOTHOG)*100)
map$AUTO            <-  with(map, (VPH_AUTOM/VIVPAR_HAB)*100)

    # Summary table
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
  ~ CODIGO_ESTADO + CODIGO_MUNICIPIO_IFE_2010 + CODIGO_MUNICIPIO_INEGI_2010 + SECCION,
  data = inegi.sum, keep.names = TRUE, FUN = mean)
inegi.sum.key <- inegi.sum %>%
  left_join(., key) %>%
  select(
    CODIGO_ESTADO, CODIGO_MUNICIPIO_IFE_2010, CODIGO_MUNICIPIO_INEGI_2010, SECCION,
    everything()
    ) %>%
  arrange(CODIGO_ESTADO, SECCION)
write.csv(inegi.sum.key, 'out/stats_inegi_2010.csv', row.names = FALSE, quote = FALSE)