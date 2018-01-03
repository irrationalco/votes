# DESCRIPCIÓN
#########

# Funciones y pedazos de código útiles para limpiar datos.

# Convertir múltiples columnas de character a numeric
convert_ctn <- function(df, name = 'character', FUN = as.numeric) as.data.frame(
lapply(df, function(x) if (class(x) == name) FUN(x) else x))

    # Convertir múltiples columnas de integer a numeric
convert_itn <- function(df, name = 'integer', FUN = as.numeric) as.data.frame(
lapply(df, function(x) if (class(x) == name) FUN(x) else x))
    
    # Convertir múltiples columnas de factor a numeric
convert_ftn <- function(df, name = 'factor', FUN = as.numeric) as.data.frame(
lapply(df, function(x) if (class(x) == name) FUN(x) else x))
    
    # Convertir múltiples columnas de logical a numeric
convert_ltn <- function(df, name = 'logical', FUN = as.numeric) as.data.frame(
lapply(df, function(x) if (class(x) == name) FUN(x) else x))
    
    # Quitar filas donde TODAS las columnas son NAs
# dat <- dat[apply(dat, 1, function(x) any(!is.na(x)))]
    
    # Quitar NAs
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))
    
    # Distribución normal con mean y sd fijas
rnorm2 <- function(n, mean, sd) { mean + sd * scale(rnorm(n)) }