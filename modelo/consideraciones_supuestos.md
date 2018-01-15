# Instrucciones, supuestos y consideraciones del modelo

## Preamble
- Tratar los datos faltantes como 0's en lugar de como NA's

## Modelo de regresión multinomial 
- y: vector de factores (en nuestro caso serán los posibles partidos politicos o coaliciones) que son nuestras variables de respuesta.
- x: matriz de covariables demográficas (ingresos, religión, raza, etc.) 

Un modelo de regresión multinomial es un problema de clasificación múltiple. 
y ~ x

Primero tenemos que ver quien ha sido el ganador 

## Supuestos:
- Complete or quasi complete separation
- Perfect prediction
- Podemos expresar las probabilidades de ocurrencia de cierto outcome como combinación lineal de las características observadas (de cierta sección) con los parámetros generales de algúna localidad
- Revisar colinearidad
- IIA 


## Things to consider
1. Ver como vamos a agrupar los datos para correr las n regresiones
	Creo que podemos entrenar el modelo por estado y compararlo para uno nacional para ver como cambia
2. Encontrar el label directo de nuestros datos del INE
	Automatizar esto
3. Considerar la perdida de información dada por que no estamos considerando los porcenajes de los otros candidatos, es completamente categórico.
	Meterle un componente bayesiano?
4. Ver como lo podemos automatizar
5. Investigar supuestos e implicaciones
6. Identificar cual tiene que ser nuestra categoría base
	Se hace un refactor con la función `RELEVEL` y sería útil que variara. Siento que es bueno que para cada sección fuera el partido ganador. (Tenemos esa info)
7. Visualizar el modelo
8. Ver como podemos escalar el modelo e incorporarle componentes más avanzados
9. Agregar componente de independientes
10. **Ver que onda con morena e indep.**
	Ver votos de 2012 y si votaron por AMLO ponerle algún peso para votos de MORENA
11. Analizar factibilidad de usar modelo probit, Multiple-group discriminant function analysis
12. Validar supuestos, en este caso, IIA (Independence of irrelevant alternatives o binary independence) Leer sobre Arrow's imposibility theorem. Claramente no se cumple por los principios de BH peeeero for now fuck it. Hay otro tipo de modelos donde podemos relajar ese supuesto.
13. Calcular los p-values usando una prueba de Wald (revisar eso) y ver como podemos hacer el análisis back & Forth
14. Prodemos jacer unas gráficas viendo como se ven las diferentes probas (a la 538) dependiendo de los diferentes factores.

Bibliografía:
- (Modelo) https://en.wikipedia.org/wiki/Multinomial_logistic_regression
- (Modelo) https://stats.idre.ucla.edu/r/dae/multinomial-logistic-regression/
- (IIA) https://stats.stackexchange.com/questions/147489/iia-assumption-difference-logit-and-probit
