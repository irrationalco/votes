
# Versión 0.2
# Script del modelo ya con estados

# Este es un modelo de regresión multinomial (sencillo) que como primera
# aproximación nos puede ayudar a hacer predicciones por localidad (Hopefully)

library(nnet)

inegi <- read.csv("../inegi/out/inegi_summary.csv", header = TRUE)
partidos <- c("PAN", "PRI", "MORENA", "PRD")
n <- dim(inegi)[1] # Número total de secciones

# Para este ejecicio de prueba, hago una random selecion de los datos nos debería llevar a un 25% en las probas para cada sección.
datosClean <- data.frame(inegi, 
                    P_GANADOR = sample(partidos, size = n, replace = TRUE))

# Corro el modelo con algunas variables completamente subjetivas
# Se puede tambi[en con un gbm(distro = multinomial) 
modelo <- multinom(P_GANADOR ~ 
                       HIJOS + 
                       LIMITACION + 
                       ANALFABETISMO + 
                       EDUCACION_AV + 
                       NO_SERV_SALUD + 
                       AUTO, data = datosClean)

resumen <- summary(modelo)
resumen
# Debe de haber una mejor manera de calcular esto...
z <- resumen$coefficients/resumen$standard.errors
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p #obvio nada es significativo por como hice la asignación random.

# Calculamos la devianza de los residuales para comparar entre modelos
# En modelo$value se guarda -log verosimilitud 
2*modelo$value 

# Cálculo de los p-values usando una prueba de Wald de dos colas
z <- modelo

# Las probabilidades están en fitted
probas <- as.data.frame(modelo$fitted.values)
write.csv(x = probas, file = "Prueba2.csv")

