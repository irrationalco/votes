mnpProb_multiObs <- function(modeloMNP, X, burn_in = 1, 
                             type = "mean", r = 100, verbose = TURE){
    # Función para la mnpGibbs y mnpProb de BayesM de Rossi
    # Calcula las probabilidades de un MNP Gibbs para multiples observaciones
    # Se usa directamente con los objetos del out de la simulación por mnp
    #
    # INPUT:
    # modeloMNP:=  output de la función mnpGibbs 
    # X Matriz de diseño de observaciones
    # burn_in:= parámetro de burn_in de una MCMC
    # type:= tipo de medida de centralidad usada para dar una estimación de la distribución posterior (mean, mode, median)
    # R:= parámetro para el algoritmo GHK
    #
    # OUTPUT
    
    n <- nrow(X) # Número de Observaciones
    d <- nrow(modeloMNP$betadraw) # Número de draws
    p <- ncol(modeloMNP$betadraw) # Número de params
    k <- sqrt(ncol(modeloMNP$sigmadraw)) # categorías = k + 1
    
    if((n %% k) != 0 || ncol(X) != p){
        stop("Error en las dimensiones del modelo")
    }else{cat("\nDimensiones correctas")}
    
    if(verbose){
        cat("\nNúmero de Observaciones: ", n, "\n", sep = "")
        cat("Número de Draws: ", d, "\n", sep = "")
        cat("Número de Parámetros: ", p, "\n", sep = "")
        cat("Número de Categorías: ", k + 1, "\n", sep = "")
    }
    
    # Identificamos parámetros quitando el burn_in
    betatilde <- modeloMNP$betadraw[burn_in:d, ] / sqrt(modeloMNP$sigmadraw[burn_in:d, 1])
    sigmatilde <- modeloMNP$sigmadraw[burn_in:d, ] / sqrt(modeloMNP$sigmadraw[burn_in:d, 1])
     
    # Resumimos los parámetros
    if(type == "mean"){
        beta_est <- apply(betatilde, 2, mean)
        sigma_est <- matrix(apply(sigmatilde, 2, mean), nrow = k, ncol = k)
        
    }else if(type == "mode"){
        beta_est <- apply(betatilde, 2, Mode)
        sigma_est <- matrix(apply(sigmatilde, 2, Mode), nrow = k, ncol = k)
        
    }else if (type == "median"){
        beta_est <- apply(betatilde, 2, median)
        sigma_est <- matrix(apply(sigmatilde, 2, median), nrow = k, ncol = k)
        
    }else {
        stop("Medida de Centralidada no soportada\ntype = mean, mode, median")
    }
    
    if(verbose){
        cat("\nBeta Estimada: ", "\n", sep = "")
        print(beta_est)
        cat("\nSigma Estimada: ", "\n", sep = "")
        print(sigma_est)
    }
    
    # Factores para el split de X
    X_ind <- split(X, f = rep(1:(n/k) , each = k))

    print(X_ind[[1]])
    print(matrix(X_ind[[1]], nrow = k, ncol = p))
    
    matrix_predict <- function(x){
        x_mat <- matrix(x, nrow = k, ncol = p)    
        mnpProb(beta = beta_est, Sigma = sigma_est, X = x_mat, r = r) 
    }
    
    return(t(sapply(X_ind, matrix_predict)))
}

Mode <- function(x) {
    # Calculates the mode of a vector
    # Ties are resolved by the first element,
        ux <- unique(x)
        ux[which.max(tabulate(match(x, ux)))]
}
    