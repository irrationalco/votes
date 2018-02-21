# Implementación del Modelo con paquete BayesM

# 0. Preamble
library(tidyverse)
library(bayesm)
source("funcs/model_funcs.R")

# 1. Cargamos los datos
inegi <- read.csv("../in/states/datos_modelo_coahuila.csv")
# Resultados Fase 1
# GTrends
# Encuestas

# Transformamos los datos en cosas utilizables
ind_vars <- inegi %>% select(HIJOS, ANALFABETISMO, EDUCACION_AV, NO_SERV_SALUD, AUTO) %>% scale()

set.seed(1)
prob <- .9
slice_index <- sample(1:dim(ind_vars)[1], size = dim(ind_vars)[1]*prob)
train <- ind_vars[slice_index, ]
test <- ind_vars[-slice_index, ]

# Respuestas: para este ejemplo, CPAN es 1 CPRI es 2, CI1 - 3, Morena - 4
y <- as.numeric(inegi$GANADOR[slice_index])
levels(inegi$GANADOR[slice_index])
head(y)
head(inegi$GANADOR[slice_index])

# Constuimos la matriz de diseño
k <- length(unique(inegi$GANADOR)) # Número de Alternativas
na <- 0 # de choice-specific
nd <- dim(ind_vars)[2] # de individual-specific 
# Xa = (n x k) * na. 
# Xd = (n x nd) 
# INT = Logical si quieres intercept
# DIFF = Logical si quieres diferenciar a la cat. base
# base = # entero que dice cual es la cat. base

X <- createX(p = k, na = na, nd = nd, Xa = NULL, Xd = train, 
             INT = FALSE, DIFF = TRUE)

# 3. Modelo
# Setup Modelo
n <-  10^4 # Número de Draws
keep <-  4 # Thinning Param, vale la pena ponerlo porque está horrible la autocorr.
beta_0 <- NULL
sigma_0 <- NULL 

Data_mod <- list(y = y, X = X, p = k)
Mcmc_params <- list(R = n, keep = keep)

modelo <- rmnpGibbs(Data = Data_mod,
                    Mcmc = Mcmc_params)
# Nota, el out te da los draws de la beta y la sigma. Sigma se es una wishart inversa, que es una matriz de covarianzas. 

# Por alguna razón, necesitas estandarizar los coefs antes de interpretarlos. 
# Pta madre Jorge neceito el libro
betatilde <- modelo$betadraw / sqrt(modelo$sigmadraw[,1])
sigmatilde <- modelo$sigmadraw / sqrt(modelo$sigmadraw[,1])

#Summarys de bayesM
summary(betatilde) # wrapper para la función summary.bayesm.mat
summary(sigmatilde)

# Gráficas BayesM - Gracias a dios pensaron en est. Namas hay que ponerle los nombres a los coefs
plot(betatilde) # wrapper para la función plot.bayesm.mat
plot(sigmatilde)

# Este tiene que ser mi output...
# Esta función calcula las probabilidades con el método GHK de UNA OBSERVACIÓN PTA MADRE

# Relativamente sencillo sacar betas finales
beta_est <- apply(betatilde, 2, mean)

# Maldita sea como lo acomodan
sigma_est <- matrix(apply(sigmatilde, 2, mean), nrow = 3, ncol = 3)

# Para todas las observaciones usando mi función
probas <- mnpProb_multiObs(modeloMNP = modelo, X = X, burn_in = 1, r = 100, verbose = TRUE )
