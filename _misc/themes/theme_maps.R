require(Cairo)
require(foreign)
require(ggplot2)
require(ggthemes)
require(grid)
require(gridExtra)
require(mapproj)
require(maps)
require(maptools)
require(RColorBrewer)
require(rgdal)
require(scales)
#require(gpclib)    # Run once for OSX install
#gpclibPermit()     # Same ^


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