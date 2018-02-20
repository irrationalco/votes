# Description: Test with INE 2015 federal level shapefiles for Aguascalientes (https://cartografia.ife.org.mx/sige7/?distritacion=federal)
# Author: Mariana <mariana@irrational.ly>

# Setup
setwd('')
options(scipen = 999)
require(dplyr)
source('../_misc/fun/general_fun.R')
source('../_misc/themes/theme_maps.R')

# MAP
# Aguascalientes
map.data <- readOGR('./raw', 'SECCION') # May take a while
map.df <- data.frame(id = rownames(map.data@data), map.data@data)
map.f <- fortify(map.data)
map <- merge(map.f, map.df, by = "id")

tbl_df(map)

dat <- as.data.frame(subset(map, select = c(entidad, distrito, municipio, seccion)))
names(dat) <- c('CODIGO_ENTIDAD', 'DISTRITO_FEDERAL_2015', 'CODIGO_MUNICIPIO_INE', 'SECCION')
