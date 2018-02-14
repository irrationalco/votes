# Función que calcula el ÍNDICE DE VOLATILIDAD ELECTORAL IRRATIONAL® para una matriz de AFINIDAD POLITICA®

IVEI <- function(X, p = 2){
    # X data frame de AFINIDAD POLíTICA de n x m donde
    # n = número de secciones/estados
    # m = número de partidos
    # p = tipo de norma a usar
    
    if(p > 1){
        m <-  dim(X)[2]
        
        alpha <- m^((1-p)/p)
        # print(alpha)
        Y <- apply(X, 1, function(x) sum(abs(x)^p)^(1/p))
        # print(Y)
        return(as.matrix(Y/(alpha - 1) - 1/(alpha - 1)))    
    } 
    else{
        stop("p debe ser mayor a 1")
    }
}

