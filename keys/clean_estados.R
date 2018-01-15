# Script para limpiar y hacer key de secciones y municipios

library(dplyr)

mexico <- read.csv("../ine/out/ine.csv")
head(mexico)
mexico <- data.frame(mexico[,3:7])
# me quedo solo con los estados
mexico <- distinct(mexico, CODIGO_ESTADO, ESTADO)
mexico <- mexico[1:32,]

write.csv("key_estados.csv", x = mexico, row.names = FALSE)
