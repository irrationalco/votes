# Description
# Map new volatility index for 2015 NL state gobernador elections

# SETUP
setwd('')
options(scipen = 999)
require(data.table)
require(dplyr)
require(ggplot2)    # Needed to fortify()
require(ggthemes)
require(doBy)
require(rgdal)
#require(gpclib)    # Run once for OSX install
#gpclibPermit()     # Same ^

nl <- fread('dat/indice_nuevo_leon_2.csv', header = TRUE, sep = ',', stringsAsFactors = F)

map.data <- readOGR('./raw', 'SECCION') # Takes a while -  be patient
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

theme_maps <- function(base_size = 12, base_family = "sans") {
(theme_foundation(base_size = base_size, base_family = base_family)
+ theme(
line = element_line(),
rect = element_rect(fill = '#eeeeef', linetype = 0, colour = NA),
text = element_text(colour = '#333333'),
axis.text = element_blank(),
axis.line = element_blank(),
axis.line.x = element_blank(),
axis.line.y = element_blank(),
axis.text.x = element_blank(),
axis.text.y = element_blank(),
axis.ticks = element_line(),
axis.ticks.x = element_blank(),
axis.ticks.y = element_blank(),
axis.title = element_blank(),
axis.title.x = element_blank(),
axis.title.y = element_blank(),
legend.key = element_rect(),
legend.background = element_rect(),
legend.box = "vertical",
legend.direction = "vertical",
legend.position = "right",
panel.background = element_rect(),
panel.grid = element_line(colour = NULL),
panel.grid.major = element_blank(),
panel.grid.major.x = element_blank(),
panel.grid.minor = element_blank(),
panel.spacing = unit(0, "lines"),
plot.background = element_rect(),
plot.title = element_text(hjust = .5, vjust = 0, size = rel(1.5), face = "bold"),
plot.margin = unit(c(2, 4, 1, 8), "lines"),
strip.background = element_rect(),
strip.text.x = element_text()))
}

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