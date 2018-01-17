# Instrucciones, supuestos y consideraciones del modelo

## Preamble
- Tratar los datos faltantes como 0's en lugar de como NA's

## Modelo de regresión multinomial probit (con el paquete MNP o con bayesM)
Un modelo de regresión multinomial es un problema de clasificación múltiple donde tienes p categorías. 
z ~ x1 + x2 + x3 + ... + e:i 
En donde asumimos que e_i se distribuye normal con matriz de varianzas y covarianzas S

Por lo pronto (al 17-Enero) el modelo es
Ganador_seccion ~  Hijos + Limitaciones + Analfabetismo + 
                Educación + Servicios de Salud + Auto - 1

El -1 es para quitarle el intercept que es redundante dado que los datos están escalados (para poderlos interpretar y para darle estabilidad numerica al modelo).
Quiero meterle el componente de las encuestas y los resultados historicos pero aún no se como.

## Things to consider
1. El modelo permite que tengamos individual-specific variables (condiciones socioeconomicas de cada sección) pero también nos permite meterle choice-specific variables (variables que toman valores dependiendo de la elección de persona)
2. Por aquello de la convergencia de que necesitamos muchos más datos, creo que sería prudente agrupar el país en secciones pues no está siendo suficiente la información de un estado
3. Como categoría base, propongo que usemos el partido que gana la última elección. `RELEVEL`
4. Visualizar el modelo y hacer pruebas de convergencia de la MCMC
5. Ver como incorporamos otros partidos que no hayan ganado en ninguna sección
6. **Ver que onda con morena e indep.**
	Ver votos de 2012 y si votaron por AMLO ponerle algún peso para votos de MORENA

## Problemas
- Paquete MNP 
- Este ya domino como funciona y tiene la funcionalidad de darle choice specific variables muy fácil, sin embargo, me está rompiendo los huevos la convergencia.
Al aumentar n.draws se sale de los parametros y algo se rompe que no me deja acabar de correrlo.
- Hay variables que están bien y otras que se van a la fregada.
- Faltan muchos datos de Morena, por eso no pintan y ninguno de sus regresores jala todos convergen a 0
- No encontré ninguna que su dimensión se fuera a la fregada

Bibliografía:
- (Modelo) https://en.wikipedia.org/wiki/Multinomial_logistic_regression
- (Modelo) https://stats.idre.ucla.edu/r/dae/multinomial-logistic-regression/
- (IIA) https://stats.stackexchange.com/questions/147489/iia-assumption-difference-logit-and-probit
