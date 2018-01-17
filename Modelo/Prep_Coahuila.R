# 17-enero
# Script de limpieza de datos ready to use para el modelo de Coahuila

library(dplyr)

inegi <- read.csv("../inegi/out/inegi_summary.csv", header = TRUE)
estados <- read.csv("key_estados.csv")
coahuila_raw <- read.csv("../coahuila/raw/gob_2017.csv")
# head(inegi)
# sapply(inegi, class)

# Coahuila tiene código 5
inegi_coahuila <- subset(x = inegi, CODIGO_ESTADO == 5)
# Ordeno por sección
inegi_coahuila <- arrange(inegi_coahuila, SECCION)
# Hay alguns municipios faltantes
sum(duplicated(inegi_coahuila$SECCION))
setdiff(1:1660, inegi_coahuila$SECCION)

# Datos de Gobernador
# Quitamos las dos primeras colúmnas
coahuila_gob <- coahuila_raw %>% dplyr::select(-1, -2)
# Todo a uppercase
names(coahuila_gob) <- toupper(names(coahuila_gob))
# Quitamos columnas que suman cero
coahuila_gob <- coahuila_gob[ , colSums(coahuila_gob)!= 0] 

# Agrupaciones que necitamos
PRI <- c('PRI', 'PVEM', 'PNA', 'SI', 'PJ', 'PRC', 'PCP')
PAN <- c('PAN', 'UDC', 'PPC', 'ES')
# MORENA
# PRD
# PT
# INDEP1
# INDEP2}
# NO REG
# NULOS

# coahuila_gob %>% transmute(CPRI = rowSums(select(., matches(paste(PRI, collapse = "|")))))
# Agrupamos las coaliciones
CPRI <- rowSums(coahuila_gob[, grep(pattern = paste(PRI, collapse = "|"), x = names(coahuila_gob))])
CPAN <- rowSums(coahuila_gob[, grep(pattern = paste(PAN, collapse = "|"), x = names(coahuila_gob))])

# Tabla
coahuila_gob <- data.frame(MUNICIPIO = coahuila_gob$MUNICIPIO, SECCION = coahuila_gob$SECCION, CPRI, CPAN, MORENA = coahuila_gob$MORENA, PRD = coahuila_gob$PRD, PT = coahuila_gob$PT, GOB_CI1 = coahuila_gob$CAND_IND1, GOB_CI2 = coahuila_gob$CAND_IND2, CNREG = coahuila_gob$CAND_NREG,NULOS = coahuila_gob$NULOS)

# Agrupamos por sección
coahuila_gob <- coahuila_gob %>% group_by(SECCION, MUNICIPIO) %>% summarise_each(funs(sum), CPRI, CPAN, MORENA, PRD, PT, GOB_CI1, GOB_CI2, CNREG, NULOS)

# Calculamos las sumas totales y los porcentajes
total <- sum(coahuila_gob[,c(-1,-2)])
sapply(coahuila_gob[, c(-1,-2)], sum)/total*100

# Hay algunas secciones diferentes entre inegi e ine. Pero fuck it 
setdiff(inegi_coahuila$SECCION, coahuila_gob$SECCION)

# Encontramos quien gano por sección que será nuestro regresor
GANADOR <- colnames(coahuila_gob[, c(-1,-2)])[max.col(coahuila_gob[, c(-1,-2)], ties.method="first")]
datos_mod <- data.frame(SECCION = coahuila_gob$SECCION, GANADOR = GANADOR)
# Anexamos datos de INEGI y de INE

datos_mod <- left_join(datos_mod, inegi_coahuila, by = "SECCION") 
datos_mod <- datos_mod[complete.cases(datos_mod), ]

write.csv(datos_mod, "Datos_Modelo/datos_modelo_coahuila.csv", row.names = FALSE)
