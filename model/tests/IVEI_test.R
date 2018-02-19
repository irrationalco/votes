# Pruebas del IVEI para validar que funcione para data.frames y tibbles 

source("../funcs/IVEI.R")

d <- 4 # Número de dimensiones para probar, ie: 4 partidos/afiliaciones

# Vectores canónicos
AFP <- diag(4)

# Casos especificos para ver si jala. Notemos que es irrelevante el orden
AFP <- rbind(AFP, rep(1/d,times = d), 
             c(.5,.5,0,0), 
             c(.25,.75,0,0),
             c(1/3,1/3,1/3,0))

# Algo random
x <- rbeta(4, shape1 = 1, shape2 = 1)
x <- x/sum(x)

AFP <- rbind(AFP, x)

# Calculo el IVEI
final <- data.frame(AFP,IVEI(AFP, p = 2))
colnames(final) <- c(letters[1:d],"IVEI")

final

write.csv(final, "IVEI_Test.csv", row.names = FALSE)
