# 17-enero
# Prueba para el modelo Multinomial Probit Bayesiano usando el paquete MNP

library(nnet)
library(MNP)
library(coda)
library(bayesm)
library(mlogit)

datos_mod <- read.csv("Datos_Modelo/datos_modelo_coahuila.csv")

# Estandarizo los datos para evitar problemas numéricos (creo que no se necesita tbh)
cols_indices <- 1:5
datos_mod_esc <- datos_mod
datos_mod_esc[, -cols_indices] <- scale(datos_mod_esc[, -cols_indices])

# Tamaño de la muestra para usar para entrenar
p <- .9
index <- sample(1:dim(datos_mod_esc)[1], size = dim(datos_mod_esc)[1]*p)
train <- datos_mod_esc[index, ]
test <- datos_mod_esc[-index, ]

# SETUP DEL MODELO
modelo_coahuila <- mnp(GANADOR ~ HIJOS + LIMITACION + ANALFABETISMO + 
                           EDUCACION_AV + NO_SERV_SALUD + AUTO, 
                       data = datos_mod, 
                       base = "CPRI",
                       n.draws = 50000,
                       burnin = 10000,
                       thin = 4,
                       verbose = TRUE,
                       latent = TRUE)
summary(modelo_coahuila)

# Análisis de convergencia
run1 <- mnp(GANADOR ~ HIJOS + LIMITACION + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO, 
            data = datos_mod_esc, 
            base = "CPRI",
            n.draws = 10000,
            verbose = TRUE)

run2 <- mnp(GANADOR ~ HIJOS + LIMITACION + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO, 
            data = datos_mod_esc, 
            base = "CPRI",
            n.draws = 10000,
            verbose = TRUE,
            coef.start = 10*c(1,-1)*seq(1, times =21),
            cov.start = matrix(0.5, ncol = 3, nrow = 3) + diag(0.5, 3))

run3 <- mnp(GANADOR ~ HIJOS + LIMITACION + ANALFABETISMO + 
                EDUCACION_AV + NO_SERV_SALUD + AUTO, 
            data = datos_mod_esc, 
            base = "CPRI",
            n.draws = 10000,
            verbose = TRUE,
            coef.start = 10*c(-1,1)*seq(1, times =21),
            cov.start = matrix(0.9, ncol = 3, nrow = 3) + diag(0.9, 3))

res.coda <- mcmc.list(cadena1 = mcmc(run1$param),
                      cadena2 = mcmc(run2$param),
                      cadena2 = mcmc(run3$param))

gelman.diag(res.coda, transform = TRUE)
gelman.plot(res.coda, transform = TRUE, ylim = c(1,1.2))


# Algúnas gráficas
hist(modelo_coahuila$param[,1])
plot(modelo_coahuila$param[,3], type = 'l')