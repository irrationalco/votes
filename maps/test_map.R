# Description
# Test with INE 2015 federal level shapefiles for Aguascalientes
# https://cartografia.ife.org.mx/sige7/?distritacion=federal

# Setup
setwd('/Users/Franklin/Git/votes/maps')
options(scipen = 999)
require(dplyr)
require(ggplot2)
require(rgdal)
source('../_fun/general_fun.R')

# MAP
# Aguascalientes
map.data <- readOGR('./raw', 'SECCION') # Takes a while -  be patient
map.df <- data.frame(id = rownames(map.data@data), map.data@data)
map.f <- fortify(map.data)
map <- merge(map.f, map.df, by = "id")

tbl_df(map)

dat <- as.data.frame(subset(map, select = c(entidad, distrito, municipio, seccion)))
names(dat) <- c('CODIGO_ENTIDAD', 'DISTRITO_FEDERAL_2015', 'CODIGO_MUNICIPIO_INE', 'SECCION')
#write.csv(map, 'out/test.csv', row.names = FALSE, quote = FALSE)
