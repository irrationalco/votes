# Instrucciones, supuestos y consideraciones del modelo

## Modelo de regresión multinomial probit (BayesM)
Un modelo de regresión multinomial es un problema de clasificación múltiple donde tienes k categorías.
z ~ x1 + x2 + x3 + ... + e:i 
En donde asumimos que e_i se distribuye normal con matriz de varianzas y covarianzas Z

Por lo pronto (al 13 de Marzo ) el modelo es
Ganador_seccion ~  Afinidad_Partidista + Hijos  + Analfabetismo + 
							             Educación + Servicios de Salud + Auto -1
El -1 es para quitarle el intercept.

## Outputs
- Gráficas De Votos Históricos
- Afinidad Partidos
- IVEI
- Betas
- Probabilidades

## Wishlist
- Ver que onda con el nivel base (estaría padre hacerlo para cada sección) es decir, escoger como nivel base el ganador de cada sección y no al PRI
- Los pesos w's racionalizarlos y no hacer una heuristica chafa. Que dependan del subset de las elecciones con las que cuente cada sección 
- Hacer bien lo del listado nominal
- Hacer bien la parte de KEY (problema de la n) para que los datos realmente estén correspondidos entre secciones
- Sacar datos demográficos más actualizados (2017)
- Optimizar selección de variables

## Things to consider
1. Scale() en todos los datos?
2. `RELEVEL`? cual uso de cat. base para todos los datos (por lo pronto uso al PRI)
3. N****
Número de secciónes | Elección/Base de datos
--------------------------------------------
	64843			| 2009 - DIF
	66526			| 2012 - DIF, PRS, SEN 
	67583			| 2015 - DIF
	66740			| INEGI - 2010
4. Agegrar partidos que no han ganado elecciones en OTROS, INDEP
5. Ver que plan con MORENA
6. Que elección usas como tu regresor. 
	Se podría hacer una regresión por ganador de elección y que sean predicciones para DIF, SEN, PRS, etc. 
7. Selección de partidos, la neta no aporta nada tener NO_REG y los chiquitos. Depende del cliente tbh

## To/Do - Falta 
3. Pruebas de Convergencia
4. Cross Validation

## Insight pasados
- Trabajar con las observaciones que estén completas, alv las otras (o las que estén bien matcheadas a una región del mapa)


