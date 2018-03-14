# Pasos para correr el modelo

1. Abrir una sesión de R exactamente en este nivel
2. Instalar paquetes: (literal correr:)
	`install.packages("bayesm", "tidyverse")`
3. En la linea 56 cambiar el valor de n a lo que estés dispuesto a esperar. En una windows 10, 12 ram. Corre aproximadamente en:
n 	 |  tiempo
-----------------
10^3 |  15 minutos
10^4 |  2.5 horas
10^5 |  25 horas

4. Correr el archivo `Modelo_Predictivo_Irrational.R`

El tiempo que le va a tomar sale en la consola en cuanto corre la instrucción de la linea 208
Sale un prompt que te dice: number of runs (estimated time - min)

Y esperar hasta que salga la primera 100 en sepa dios cuantos minutos para estimarlo

5. ??? 
6. Después de n horas, marcarle a Mariana o a Paolo si en verdad se corrió el modelo
7. ???
8. Profit

## Troubleshooting

En caso de que el modelo no quepa en la RAM (pesa aproximadamente 1 GB según yo) más todas las bases de datos y subsets que se hacen pueden mover el valor de thin en la linea 57. El número total de draws que va a sacar es n/thin.

cualquier cosa me preguntan.

Si logró correr el modelo, la instrucción en la linea 213 también van a tardar como 15/20 minutos. Y en la consola están saliendo muchos números primos jajaja neta yo no lo programné asi. Don't @ me
