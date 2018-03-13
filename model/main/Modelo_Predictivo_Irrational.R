# Script que jala todas las herramientas necesarias para correr el modelo y sacar un output listo para subir a la plataforma 

# Convenciones
# 1. Se asume que aunque el script esté en la carpeta MAIN, el wd es uno más arriba ie:
#   /votes/model/
# 2. Notación
#   n:= número de observaciones en el ejercicio, corresponde con la longitud de las tablas dim 1.     (en este caso secciones y si es de todo el país deberá ser cerca de 66k)
#   k:= número de posibles respuestas. (en este caso partidos)
# Todo debe de llevar su key, tanto IBV como CVIi como y para no caer en broncas de dimensionalidad
# 3. IBV:= Individual Based Variables, una sola matriz de n_IBV columnas (cada columna es una variable), con su correspondiente codigo
# 4. CBVi:= Choice Based Variable i, matriz que contiene una sola CBV (ie: cada CBV tiene la suya) el número de colúmnas debe de ser igual a k
# 5. CODE:= ID:= Código de identificación de filas único (para n). 
# 6. KEY: para las categorías (para k) (Para codificación y referencia de categorías)

#-------------------------------------------------------------------------------
# 0. PREAMBLE
# 0.1 Paquetes
library(bayesm)
library(tidyverse)

# 0.2 Funciones 
source("funcs/model_funcs.R")
source("funcs/fase1/IVEI.R")
source("funcs/fase1/Fase1.R")

# 0.3 Parámetros Globales

# 0.3.2 Parámetros para Respuestas, ganador de las siguientes elecciones.
ano <- 2012 # Año por selecionar la respuesta
elec <- "prs"   # Elección para seleccionar la respuesta 
# Combinaciones posibles:
# dif-2009
# dif-2012
# sen-2012
# prs-2012
# dif-2015

#0.3.3 Pesos para las diferentes combinaciones de elecciones.
# Si se agregan más elecciones tener cuidado o ver que plan con estos pesos
# El orden de las eleciones queda con sus pesos: 
# dif-2009 - .05
# dif-2012 - .1
# dif-2015 - .3 - Más reciente
# prs-2012 - .45 - Más relevante
# sen-2012 - .1 - Meh
w <- list("1" = c(1), 
          "2" = NULL,
          "3" = c(.1, .7,.2), 
          "4" = c(.25,.25,.25,.25), 
          "5" = c(.05,.1,.3,.45,.1))

# 0.3.3 Parámetros FASE 1
p <- 2  # Norma para el IVEI

# 0.3.4 Parametros para mnpGibbs
draws <- 10^3 # Número de Draws para el modelo
thin <- 1 # Thinning parameter

# 0.3.5 Parámetros para la función mnpProb_multiObs
burn_in <- 100 # Datos por descartar
tipo_resumen <- "mean" # Puede ser mean, median o mode
r <- 100
verb <- TRUE

#-------------------------------------------------------------------------------
# 1. IMPORT DATA
#
# Importar todas las bases de datos que se encuentren en la carpeta IN
# 1.1 Datos INEGI
inegi <- read.csv("in/inegi/stats_inegi_2010.csv")
# Se puden escoger variables diferentes. Yo lo hice asi porque con el paquete MNP eran las mejores
features <- c("HIJOS", "ANALFABETISMO", "EDUCACION_AV", "NO_SERV_SALUD", "AUTO")
IBV <- inegi %>% select(features) %>% scale()
IBV_code <- with(inegi, paste(CODIGO_ESTADO, CODIGO_MUNICIPIO_INEGI_2010, SECCION, sep = "-"))

# Votos
ine <- read.csv("in/ine/tbl_ine.csv")

# GTrends
# Encuestas

#-------------------------------------------------------------------------------
# 2. RESPUESTAS Y's

# 2.1 Sacamos las respuestas y de la elección que queramos
# Por lo pronto, selecciono todas, pero valdría la pena agregar algúnas para tener una categoría, OTROS e INDEP

ine_filter <- ine %>% filter(ANO == ano, ELECCION == elec)
ine_select <- ine_filter %>% select(PAN:NO_REG)
ine_select[is.na(ine_select)] <- -1 #Si hay algun NA lo quita

# Se llaman diferentes porque y final es numeric y subsetado por el código final (n*) pero debe de salir de respuestas. 
respuestas <-  factor(colnames(ine_select[,])[max.col(ine_select[ , ], ties.method = "random")])
y_code <- with(ine_filter,paste(CODIGO_ESTADO, CODIGO_MUNICIPIO, SECCION, sep = "-"))

# 2.2 Hacemos el relevel 
# Por ahora, dejamos como base al PRI, PAN, PMC, PNA, PRD, PT, PVEM, NO_REG
levels(respuestas)
# Se puede cambiar este vector para escoger otros partidos que se considerern relevantes. Pero hay que tomar en cuenta datos faltantes.
partidos <- c("PRI", "PAN", "PRD", "PMC", "PNA", "PT", "PVEM", "NO_REG")
# Whishlist, hacer esto por sección ie: que la cat. base sea el ganador de cada sección
respuestas <- factor(respuestas, levels = partidos)
k <- nlevels(respuestas)

# Hacemos las respuestas
y <- as.integer(respuestas)
key_respuestas <- data.frame(PARTIDOS = levels(respuestas), CODE = 1:k)
write.csv(key_respuestas, "out/Key_Respuestas.csv", row.names = FALSE)
# Recordando, Code son filas y Key son "Columnas-ish"

#-------------------------------------------------------------------------------
# 3. FASE-1
# 
# En la FASE 1, transformarmos los datos de votos y encuestas en choice based variables (ie: que haya un dato para cada una de las posibles respuestas que a la vez son los nombres de las columnas - Mariana: osease, ) notemos que deben existir exactamente K opciones para que funcione el modelo.

temp <- with(ine, data.frame(CODE = paste(CODIGO_ESTADO, CODIGO_MUNICIPIO, SECCION, sep = "-"), ELECCION = paste(ELECCION, ANO, sep = "-")))

# De secciones únicas por matchear
length(unique(temp$CODE))

# Preparación de la base de datos para hacer multiplicación de matrices
ine_pre_afinidad <- as_tibble(data.frame(temp, NOMINAL = ine$NOMINAL, ine %>% select(partidos)))
ine_pre_afinidad <- ine_pre_afinidad %>% arrange(CODE, ELECCION)
ine_pre_afinidad[is.na(ine_pre_afinidad)] <- 0
rm(temp)

# Sacamos un listado nominal promedio 
listado_nominal <- ine_pre_afinidad %>% 
    group_by(CODE) %>% 
    summarise(NOMINAL_PROM = ceiling(mean(NOMINAL[NOMINAL != 0])))


# Equivalente a VLookup de R para pegarle el promedio
ine_pre_afinidad$NOMINAL <- right_join(ine_pre_afinidad, listado_nominal, by = "CODE")$NOMINAL_PROM

# Sacamos los datos en porcenajes (hacer esto más elegante)
ine_pre_afinidad[ ,4:11] <- ine_pre_afinidad[ ,4:11]/ine_pre_afinidad$NOMINAL

# Solo falta separa las matrices y hacer su corresponeidnete multiplicación
# num_elec <- table(ine_pre_afinidad$CODE)
ine_split <- split(ine_pre_afinidad[ , 4:11], f = ine_pre_afinidad$CODE)

# Intento de hacerlo con dplyr
# ine_split <- ine_pre_afinidad %>% 
# group_by(CODE) %>% select(partidos) %>% summarise(multiplica_matriz())

multiplica_matriz <- function(x, w){
    n <- nrow(x)
    y <- crossprod(as.matrix(x),w[[n]])
    return(y/sum(y))
}

# CBV 1 - Afinidad politica
CBV1_afinidad <-  t(sapply(ine_split, multiplica_matriz, w = w))
colnames(CBV1_afinidad) <- partidos
head(CBV1_afinidad)
CBV1_afinidad_code <- unique(ine_pre_afinidad$CODE)

# De paso calculamos el IVEI por localidad (podríamos meterlo al modelo pero sería repetir info)
IVEI_data <- as.tibble(data.frame(CODE = gsub("-", replacement = "/", CBV1_afinidad_code),IVEI = IVEI(CBV1_afinidad, p = 2)))
hist(IVEI_data$IVEI, main = "Índice de Volatilidad Electoral Irrational Co.")
summary(IVEI_data$IVEI)
write.csv(IVEI_data, "out/IVEI_Sección.csv", row.names = FALSE)

#-------------------------------------------------------------------------------
# 4. FASE-2 - MNP BayesM
#
# 1.1 Hacer sentido de las dimensiones y hacer final key (n final)

tabla_y <- data.frame(CODE = y_code, repuestas = respuestas, y = y)
tabla_IBV <- data.frame(CODE = IBV_code,  IBV)
tabla_CBV <- data.frame(CODE = CBV1_afinidad_code,  CBV1_afinidad)
tabla_final <- tabla_y %>% left_join(tabla_IBV)
tabla_final <- tabla_final %>% left_join(tabla_CBV)

# Vemos cuantos jalan
sum(complete.cases(tabla_final))
tabla_malos <- tabla_final[!complete.cases(tabla_final), ] 
tabla_final <- tabla_final[complete.cases(tabla_final), ] 
write.csv(tabla_final, "out/ModeloIrrational.csv", row.names = FALSE)

Xa <- as.matrix(tabla_final %>% select(partidos))
Xd <- as.matrix(tabla_final %>% select(features))

# 1.2 Construcción de matrices de diseño
na <- 1 # de choice-specific
nd <- ncol(Xd) # de individual-specific 

# En el Xa ira un cbind de todas las matrices
X <- createX(p = k, na = na, nd = nd, Xa = Xa, Xd = Xd, 
             INT = FALSE, DIFF = TRUE, base = 1)
dim(X)

# Valores iniciales Modelo
beta_0 <- NULL
sigma_0 <- NULL 

# Priors Modelo
betabar <- rep(0, times = (k-1)*nd + na) 
A <- diag((k-1)*nd + na) # HAcemos esta modificación porqe por default es: 0.01*diag() y nos dijo Jim que es mejor centrar todo (nos lleva a un problema de que las betas son N(0,100) porque es la inversa)
nu <- k-1+3
V <- nu*diag(k-1)

Data_mod <- list(y = tabla_final$y, X = X, p = k)
Prior_mod = list(betabar, A, nu, V) # Opcional
Mcmc_params <- list(R = draws, keep = thin)

modelo <- rmnpGibbs(Data = Data_mod, Mcmc = Mcmc_params, Prior = Prior_Mod)

#-------------------------------------------------------------------------------
# 5. RESULTADOS

probs <- mnpProb_multiObs(modelo, X, burn_in, type = tipo_resumen, r = r, verbose = verb)
colnames(probs) <- levels(respuestas)
probs <- data.frame(CODE = tabla_final$CODE, probs, RESPUESTA_REAL = tabla_final$repuestas)
write.csv(probs, "out/PrediccionesSeccion.csv", row.names = FALSE)

# Estimamos accuracy-ish
temp <- probs %>% select(partidos)
resp_mod <- factor(colnames(temp[ , ])[max.col(temp[ , ], ties.method = "random")])
accurracy <- sum(as.integer(tabla_final$repuestas) == as.integer(resp_mod))/length(tabla_final$repuestas)
rm(temp)
cat("Acurracy del modelo (in sample) con", dim(tabla_final)[1], "observaciones:", acurray*100, "%")

#-------------------------------------------------------------------------------
# 6. ANÁLISIS

# 6.1 Analizamos las cadenas de markov pero primero identificamos parámetros
betatilde <- modelo$betadraw / sqrt(modelo$sigmadraw[,1])
sigmatilde <- modelo$sigmadraw / sqrt(modelo$sigmadraw[,1])

# #Summarys y plots de bayesM
summary(betatilde)
summary(sigmatilde)
plot(betatilde)
plot(sigmatilde)

# 6.2 Análisis de convergencia

#-------------------------------------------------------------------------------
# 7. Precisión y Cross Validation
