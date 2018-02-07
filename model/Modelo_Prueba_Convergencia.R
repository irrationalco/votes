# Corrida del modelo con millones de datos

library(nnet)
library(MNP)
library(coda)

source("AnalisisModelos.R")
datos_mod <- read.csv("Datos_Modelo/datos_modelo_coahuila.csv")

cat_var_index <- 1:5
datos_mod_esc <- datos_mod
datos_mod_esc[, -cat_var_index] <- scale(datos_mod_esc[, -cat_var_index])

set.seed(1)
p <- .9
slice_index <- sample(1:dim(datos_mod_esc)[1], size = dim(datos_mod_esc)[1]*p)
train <- datos_mod_esc[slice_index, ]
test <- datos_mod_esc[-slice_index, ]

# Corrida
# Aguas, toma ~3 horas en correr en mi computadora
n <- 10^6
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

res.coda <- mcmc.list(cadena1 = mcmc(run1$param),
                      cadena2 = mcmc(run2$param),
                      cadena2 = mcmc(run3$param))

analisis_rapido(run1)
analisis_rapido(run2)
analisis_rapido(run3)

# rm(run1, run2, run3)

