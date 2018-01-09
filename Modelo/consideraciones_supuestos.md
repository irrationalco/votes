# Instrucciones, supuestos y consideraciones del modelo

## Preamble
- Tratar los datos faltantes como 0's en lugar de como NA's

## Modelo de regresión multinomial 
- y: vector de factores (en nuestro caso serán los posibles partidos politicos o coaliciones) que son nuestras variables de respuesta.
- x: matriz de covariables demográficas (ingresos, religión, raza, etc.) 

Un modelo de regresión multinomial es un problema de clasificación múltiple. 
y ~ x

Primero tenemos que ver quien ha sido el ganador 


## Things to consider
1. Ver como vamos a agrupar los datos para correr las n regresiones
2. Encontrar el label directo de nuestros datos del INE
3. Considerar la perdida de información dada por que no estamos considerando los porcenajes de los otros candidatos, es completamente categórico.
4. Ver como lo podemos automatizar
5. Investigar supuestos e implicaciones
6. Identificar cual tiene que ser nuestra categoría base
7. Visualizar el modelo
8. Ver como podemos escalar el modelo e incorporarle componentes más avanzados
9. Agregar componente de independientes
10. Ver que onda con morena

