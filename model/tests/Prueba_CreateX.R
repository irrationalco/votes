# BayesM Test para crear matices para el MNP

library(bayesm)

# Prueba para crear matrices de diseño
n <- 2 # Dos individuos (secciones)
k <- 4 # cuatroy categorías
choices <- letters[1:k]


# Tres regresores individuales
ind_vars <- data.frame( x1 = rbinom(n = n, size = 10, p = .3),
                        x2 = rnorm(n = n, mean = 0, sd = 2), 
                        x3 = rgamma(n = n, shape = 1, scale = 3))

# Estas las tenemos que llenar por filas
choice_var1 <- rbind(rnorm(k, mean = 5), rnorm(k, mean = 10))
# names(choice_var1) <- choices

# En teoría tendríamos que tener una matriz de 1 + 3*3 = 10
# p = # de alternativas
# na = # de choice-specific
# nd = # de individual-specific
# Xa = (n x k) * na.
# Xd = (n x nd) 
# INT = Logical si quieres intercept
# DIFF = Logical si quieres diferenciar a la cat. base
# base = # entero que dice cual es la cat. base

X <- createX(p = k, na = 1, nd = 3, Xa = choice_var1, Xd = as.matrix(ind_vars), 
        INT = FALSE, DIFF = TRUE, base = 1)
X
# Notas: - Pasarle todo como matrices y no como df. Planear bien el experimento, etc

        





