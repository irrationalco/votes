# Prueba rápida para la ver una cosa del número de elecciones y por ende la multiplicación de matrices

library(tidyverse)

ine <- read.csv("in/ine/tbl_ine.csv")

datos <- with(ine, data.frame(SECCION = paste(CODIGO_ESTADO, CODIGO_MUNICIPIO, SECCION, sep = "-"), ELECCION = paste(ELECCION, ANO, sep = "-")))

datos <- datos %>% arrange(SECCION, ELECCION)
head(datos)

# Tabla de la tabla... Porque se puede
num_elec <- table(datos$SECCION)
table(num_elec)

# Mover este para sacar los malos. n = 1, 3, 4
n <- 4
malos <- names(num_elec)[which(num_elec == n)]
datos[datos$SECCION %in% malos, ]

# Conclusión:
# n = 1 no hay pedo
# n = 3 solo tienen los 3 del 2012.
# n = 3 hay de todo... Tanto 2009 + 2012 como 2012 + 2015
# n = 5 :) Happy days
# ie: Necesito pensar como hacer el algoritmo de multiplicación de matrices


