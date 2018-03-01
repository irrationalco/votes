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
# 5. CODE:= Código de identificación de filas único (para n). KEY: para las categorías (para k)

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

# 0.3.2 Parámetros para Respuestas
ano <- 2012 # Año por selecionar la respuesta
elec <- "prs"   # Elección para seleccionar la respuesta 
# Combinaciones posibles:
# dif-2009
# dif-2012
# sen-2012
# prs-2012
# dif-2015

#0.3.3 Pesos para las diferentes combinaciones de elecciones
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
draws <- 10^5 # Número de Draws para el modelo
thin <- 4 # Thinning parameter

# 0.3.5 Parámetros para la función mnpProb_multiObs
burn_in <- 1000 # Datos por descartar
tipo_resumen <- "mean" # Puede ser mean, median o mode
r <- 100
verb <- TRUE

#-------------------------------------------------------------------------------
# 1. IMPORT DATA
#
# Importar todas las bases de datos que se encuentren en la carpeta IN
# 1.1 Datos INEGI
inegi <- read.csv("in/inegi/stats_inegi_2010.csv")
IBV <- inegi %>% select(HIJOS, ANALFABETISMO, EDUCACION_AV, NO_SERV_SALUD, AUTO) %>% scale()
IBV_code <- with(inegi, paste(CODIGO_ESTADO, CODIGO_MUNICIPIO_IFE_2010, SECCION, sep = "-"))

# Votos
ine <- read.csv("in/ine/tbl_ine.csv")

# GTrends
# Encuestas

#-------------------------------------------------------------------------------
# 2. RESPUESTAS

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
partidos <- c("PRI", "PAN", "PRD", "PMC", "PNA", "PT", "PVEM", "NO_REG")
respuestas <- factor(respuestas, levels = partidos)
k <- nlevels(respuestas)
key_respuestas <- data.frame(PARTIDOS = levels(respuestas), CODE = 1:k)
write.csv(key_respuestas, "out/Key_Respuestas.csv", row.names = FALSE)

#-------------------------------------------------------------------------------
# 3. FASE-1
# 
# En la FASE 1, transformarmos los datos de votos y encuestas en choice based variables (ie: que haya un dato para cada una de las posibles respuestas que a la vez son los nombres de las columnas) notemos que deben existir exactamente K opciones para que funcione el modelo.

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
IVEI <- IVEI(CBV1_afinidad, p = 2) 
hist(IVEI)
summary(IVEI)
write.csv(IVEI, "out/IVEI_Sección.csv", row.names = FALSE)

#-------------------------------------------------------------------------------
# 4. FASE-2 - MNP BayesM
#
# 1.1 Hacer sentido de las dimensiones y hacer final key (n final)
code_final <- # Será el "minimo" posible de las n_y, n_IBV y n_CBVi
    # Con este subseteamos sus respectivos datos
    
    y <- as.numeric()
Xa <- cbind()
Xd <- IBV

# 1.2 Construcción de matrices de diseño
na <- 0 # de choice-specific
nd <- ncol(IBV) # de individual-specific 

# En el Xa ira un cbind de todas las matrices
X <- createX(p = k, na = na, nd = nd, Xa = NULL, Xd = IBV, 
             INT = FALSE, DIFF = TRUE, base = 1)

# Priors Modelo
beta_0 <- NULL
sigma_0 <- NULL 

Data_mod <- list(y = y, X = X, p = k)
Mcmc_params <- list(R = draws, keep = thin)

modelo <- rmnpGibbs(Data = Data_mod, Mcmc = Mcmc_params)

#-------------------------------------------------------------------------------
# 5. RESULTADOS

probs <- mnpProb_multiObs(modelo, X, burn_in, type = tipo_resumen, r = r, verbose = verb)
colnames(probs) <- levels(respuestas) 
final <- data.frame(CODE = code_final, probs)
write.csv(probs, "out/PrediccionesSeccion.csv", row.names = FALSE)

#-------------------------------------------------------------------------------
# 6. ANÁLISIS
#
# 6.1 Analizamos las cadenas de markov pero primero identificamos parámetros
betatilde <- modelo$betadraw / sqrt(modelo$sigmadraw[,1])
sigmatilde <- modelo$sigmadraw / sqrt(modelo$sigmadraw[,1])

#Summarys y plots de bayesM
summary(betatilde) 
summary(sigmatilde)
plot(betatilde)
plot(sigmatilde)

# 6.2 Análisis de convergencia

#-------------------------------------------------------------------------------
# 7. Precisión y Cross Validation
