# Análisis de Convergencia de modelo

source("../funcs/AnalisisModelos.R")
load("RunsConvergencia.RData")
library(nnet)
library(coda)

# PREAMBLE
# Hice la simulación con n = 10^6 draws. No converge para la segunda porque se sale de los límites. Ese simple hecho dice que el modelo ya está medio sketchy. Seguimos intentando.

par(mfrow=c(1,2))
analisis_rapido(run1, draws = 10000)
analisis_rapido(run3, draws = 10000)
# Pues se ven mejores (creo)

inicio <- 900000 # Entero entre, 1 y 10^6
n <- 10^6
res.coda <- mcmc.list(cadena1 = mcmc(run1$param, start = inicio),
                      cadena2 = mcmc(run3$param, start = inicio))

 
gelman.diag(res.coda, transform = FALSE)
# OMFG ya convergió
gelman.plot(res.coda, transform = TRUE, ylim = c(0,5))

# Un resumen comprensivo y en teoría ya perfectamente convergente, incluye cuantiles.
resumen <- summary(res.coda)
capture.output(resumen, "ResultadosSimulación.txt")


