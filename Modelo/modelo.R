
# Versión 0.0
# Script de primera versión del módelo

# Este es un modelo de regresión multinomial (sencillo) que como primera
# aproximación nos puede ayudar a hacer predicciones por localidad (Hopefully)

library(nnet)

y <- as.factor(rep(1:5, each = 10))

x <- rnorm(n = 50) + as.numeric(y)

datos <- data.frame(y,x)

modelo <- multinom(y ~ x, data = data) # Las probabilidades están en fitted

probas <- as.data.frame(modelo$fitted.values)
write.csv(x = probas, file = "Prueba1.csv")

apply(X = modelo$fitted.values, MARGIN = 1, FUN = sum)