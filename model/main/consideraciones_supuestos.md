# Instrucciones, supuestos y consideraciones del modelo

## Modelo de regresión multinomial probit (BayesM)
Un modelo de regresión multinomial es un problema de clasificación múltiple donde tienes k categorías.
z ~ x1 + x2 + x3 + ... + e:i 
En donde asumimos que e_i se distribuye normal con matriz de varianzas y covarianzas Z

Por lo pronto (al 21-Febrero) el modelo es
Ganador_seccion ~  Afinidad_Partidista + Hijos  + Analfabetismo + 
							             Educación + Servicios de Salud + Auto -1

El -1 es para quitarle el intercept.

## Things to consider
1. Scale() en todos los datos?
2. `RELEVEL`? cual uso de cat. base para todos los datos (por lo pronto uso al PRI)
3. Problema con n
Número de secciónes | Elección/Base de datos
--------------------------------------------
	64843			| 2009 - DIF
	66526			| 2012 - DIF, PRS, SEN 
	67583			| 2015 - DIF
	66740			| INEGI - 2010
Estandarizar esto...	
4. Agegrar partidos que no han ganado elecciones en OTROS, INDEP
5. Ver que plan con MORENA
6. Que elección usas como tu regresor. 
	Se podría hacer una regresión por ganador de elección y que sean predicciones para DIF, SEN, PRS, etc. 

## To/Do - Falta 
1. Hacer selección correcta de partidos para que las predicciones sean representativas y no muramos por la dimensionalidad.
2. Script/función de Fase 1
3. Racionalización de códigos/índices
--- Minimum viable product
4. Pruebas de Convergencia
5. Pruebas de Precisión


## Insight pasados
- Trabajar con las observaciones que estén completas, alv las otras (o las que estén bien matcheadas a una región del mapa)


