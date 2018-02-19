# Implementación del Modelo con paquete BayesM

# 0. Preamble
library(tidyverse)
library(bayesm)

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

y <- inegi$GANADOR[slice_index]

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
n <-  10^1 # Número de Draws
keep <-  1 # Thinning Param
beta_0 <- NULL
sigma_0 <- NULL 

Data_mod <- list(y = y, X = X, p = k)
Mcmc_params <- list(R = n, keep = keep)

modelo <- rmnpGibbs(Data = Data_mod,
                    Mcmc = Mcmc_params)

head(simout$X)




