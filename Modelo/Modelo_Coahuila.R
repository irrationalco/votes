# 17-enero
# Prueba para el modelo Multinomial Probit Bayesiano usando el paquete MNP

library(nnet)
library(MNP)
library(coda)
library(bayesm) # Alternativa a MNP
library(mlogit) # No jala para probit
source("AnalisisModelos.R")

datos_mod <- read.csv("Datos_Modelo/datos_modelo_coahuila.csv")

# Estandarizo los datos para evitar problemas numéricos
cat_var_index <- 1:5
datos_mod_esc <- datos_mod
datos_mod_esc[, -cat_var_index] <- scale(datos_mod_esc[, -cat_var_index])

# Tamaño de la muestra para usar para entrenar
set.seed(1)
p <- .9
slice_index <- sample(1:dim(datos_mod_esc)[1], size = dim(datos_mod_esc)[1]*p)
train <- datos_mod_esc[slice_index, ]
test <- datos_mod_esc[-slice_index, ]

# --------------------------------------------------------------------
# Modelo
# ESte en teoría es preeliminar se tiene que correr cadenas más largas
modelo_coahuila <- mnp(GANADOR ~ HIJOS + ANALFABETISMO +
                           EDUCACION_AV + NO_SERV_SALUD + AUTO - 1, 
                       data = train, 
                       base = "CPRI",
                       n.draws = 10000,
                       burnin = 2000,
                       thin = 3,
                       verbose = TRUE,
                       latent = TRUE)

# Análisis rápdio modelo
analisis_rapido(modelo_coahuila)

n <- 10^6
# Análisis de convergencia
run1 <- mnp(GANADOR ~ HIJOS + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO - 1, 
            data = train, 
            base = "CPRI",
            n.draws = n,
            verbose = TRUE)

run2 <- mnp(GANADOR ~ HIJOS + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO - 1, 
            data = train, 
            base = "CPRI",
            n.draws = n,
            verbose = TRUE,
            coef.start = c(1,-1)*rep(1, times = 15),
            cov.start = matrix(0.5, ncol = 3, nrow = 3) + diag(0.5, 3))

run3 <- mnp(GANADOR ~ HIJOS + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO - 1, 
            data = train, 
            base = "CPRI",
            n.draws = n,
            verbose = TRUE,
            coef.start = c(-1,1)*rep(1, times = 15),
            cov.start = matrix(0.9, ncol = 3, nrow = 3) + diag(0.9, 3))

analisis_rapido(run1)
analisis_rapido(run2)
analisis_rapido(run3)

res.coda <- mcmc.list(cadena1 = mcmc(run1$param),
                      cadena2 = mcmc(run2$param),
                      cadena2 = mcmc(run3$param))

gelman.diag(res.coda, transform = FALSE) #Doesn't look good :(
gelman.plot(res.coda, transform = TRUE, ylim = c(0,5))

# Resultados Preliminares

# Juntamos la seguna parte de las 3 cadenas en un objeto que te las combina todas. 
res.coda <- mcmc.list(cadena1 = mcmc(run1$param[25001:50000,], start=25001),
                      cadena2 = mcmc(run2$param[25001:50000,], start=25001),
                      cadena3 = mcmc(run3$param[25001:50000,], start=25001))

# Un resumen comprensivo y en teoría ya perfectamente convergente, incluye cuantiles.
summary(res.coda)
# Un resumen gráfico que sobrepone las gráficas de las corridas
plot(res.coda, auto.layout = TRUE) 

# Revisamos acurracy con los datos de test
precision_modelo(run1, train, type = "prob", save_res = FALSE)




