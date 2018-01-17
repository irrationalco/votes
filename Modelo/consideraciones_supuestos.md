# Instrucciones, supuestos y consideraciones del modelo

## Preamble
- Tratar los datos faltantes como 0's en lugar de como NA's

## Modelo de regresión multinomial probit (con el paquete MNP o con bayesM)
Un modelo de regresión multinomial es un problema de clasificación múltiple donde tienes p categorías. 
z ~ x1 + x2 + x3 + ... + e:i 
En donde asumimos que e_i se distribuye normal con matriz de varianzas y covarianzas S

Por lo pronto (al 16-Enero) el modelo es
Ganador_seccion ~  Hijos + Limitaciones + Analfabetismo + 
                Educación + Servicios de Salud + Auto

Quiero meterle el componente de las encuestas y los resultados historicos pero aún no se como.

## Things to consider
1. El modelo permite que tengamos individual-specific variables (condiciones socioeconomicas de cada sección) pero también nos permite meterle choice-specific variables (variables que toman valores dependiendo de la elección de persona)
2. Por aquello de la convergencia de que necesitamos muchos más datos, creo que sería prudente agrupar el país en secciones pues no está siendo suficiente la información de un estado
3. Como categoría base, propongo que usemos el partido que gana la última elección. `RELEVEL`
4. Visualizar el modelo y hacer pruebas de convergencia de la MCMC
5. Ver como incorporamos otros partidos que no hayan ganado en ninguna sección
6. **Ver que onda con morena e indep.**
	Ver votos de 2012 y si votaron por AMLO ponerle algún peso para votos de MORENA

Bibliografía:
- (Modelo) https://en.wikipedia.org/wiki/Multinomial_logistic_regression
- (Modelo) https://stats.idre.ucla.edu/r/dae/multinomial-logistic-regression/
- (IIA) https://stats.stackexchange.com/questions/147489/iia-assumption-difference-logit-and-probit
