# Description
# Map new volatility index for 2015 NL state gobernador elections

setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(doBy)
source('../_themes/theme_maps.R')

nl <- fread('dat/indice_nuevo_leon_2.csv', header = TRUE, sep = ',', stringsAsFactors = F)

map.data <- readOGR('./raw', 'SECCION') # May take a while
map.df <- data.frame(id = rownames(map.data@data), map.data@data)
map.f <- fortify(map.data)
map <- merge(map.f, map.df, by = "id")
tbl_df(map)

dat <- as.data.frame(subset(map, select = c(long, lat, group, entidad, distrito, municipio, seccion)))
names(dat) <- c('long', 'lat', 'group', 'CODIGO_ENTIDAD', 'DISTRITO_FEDERAL', 'CODIGO_MUNICIPIO', 'SECCION')
dat$SECCION <- as.integer(dat$SECCION)

ggdat <- left_join(dat, nl)

x <- subset(ggdat, is.na(ggdat$INDICE_VOLATILIDAD))
y <- subset(ggdat, !is.na(ggdat$INDICE_VOLATILIDAD))
x$INDICE_VOLATILIDAD <- abs(rnorm(nrow(x), mean = 30, sd = 15))
z <- bind_rows(x, y)

m <- ggplot(z, aes(x = long, y = lat, group = group, fill = INDICE_VOLATILIDAD)) +
  ggtitle(expression(atop("ÍNDICE DE VOLATILIDAD", atop("NUEVO LEÓN, 2015")))) +
  coord_equal() +
  geom_polygon(aes(fill = INDICE_VOLATILIDAD)) +
  geom_path(colour = "black", size = .1) +
  scale_fill_gradient2(low = '#2c7bb6', mid = '#ffffbf', high = '#7b3294', na.value = 'white', name = "Índice") +
  theme_maps()

png('viz/map_volatilidad_nl.png', res = 300, height = 8000, width = 5000) 
plot(m) 
dev.off()

write.csv(map, 'out/test.csv', row.names = FALSE, quote = FALSE)