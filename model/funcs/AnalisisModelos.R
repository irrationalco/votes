# Script para funciones helper para analizar ¨convergencia de modelos MNP de forma visual

# Nota, tiene que ser modelos que salgan del paquete MNP

plot_corridas <- function(lista_mcmc, plot_dist = c(2,2), n = 10^5){
    
    # Graphical parámeters
    # dev.off()
    par(mfrow = plot_dist)
    
    # Gráficas
    num_cad <- length(lista_mcmc)
    params <- dim(lista_mcmc[[1]])[2] # Número de parámetrso
    colores <- c("black", "red", "blue", "green")
    titulos <- colnames(lista_mcmc[[1]])
    
    cat("\n\tAnálisis de Convergencia con ", params, " variables y ", num_cad, 
              " cadenas\n", sep = "", fill = FALSE)
    
    for(i in 1:params){
        j <- 1
        cat("Gráfica: ", i, "\n", sep ="")
        plot(x = 1:n, y = lista_mcmc[[1]][1:n, i], col = colores[1], type = "l")
        title(titulos[i])
        
        for(j in 2:num_cad) {
            lines(lista_mcmc[[j]][1:n,i], col = colores[j])
        }
        
        if((i %% prod(plot_dist)) == 0){
            dev.off()
            readline(prompt = "Pause. Press <Enter> to continue...")
        }
        
    }
}


library(RColorBrewer)
analisis_rapido <- function(modelo, draws = 1000, 
                            summary = FALSE, each = FALSE){
    # Función que analiza la convergencia de forma muy general de un modelo
    
    # Resumen general del modelo
    if(summary == TRUE){
        print(summary(modelo))        
    }
    
    # Variables
    nombre_vars <- dimnames(modelo$param)[[2]]
    n <- dim(modelo$param)
    
    # Tomamos la última parte de la cadena para que no se vea tanto
    vars_MCMC <- modelo$param[(n[1]-draws):n[1], ] 
    colnames(vars_MCMC) <- nombre_vars
    
    # Pendejada para sacar colores y que la gráfica tenga sentido
    qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
    col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, 
                               rownames(qual_col_pals)))
    
    # Matriz con todas las cadenas
    matplot(1:dim(vars_MCMC)[1], vars_MCMC, type = 'l', 
            xlab  = "Cadena", ylab = "Beta", col = col_vector)
    legend('right', legend = colnames(vars_MCMC), cex = .5, pch = 0, 
           fill = col_vector)
    
    # Por si quieres ver cada una
    if(each == TRUE){
        for(i in 1:dim(vars_MCMC)[2]){
            variable <- i # Cambiar este número para ver las diferentes variables
            plot(modelo_coahuila$param[,variable], type = 'l', 
                 main = nombre_vars[variable], col = "red")    
            readline(prompt = "Pause. Press <Enter> to continue...")
        }        
    }
}

precision_modelo <- function(modelo, newdata, type = "prob", save_res = FALSE){
    # Función que evalua el desempeño de un modelo del tipo MNP contra datos pasados
    # Opciones para type:
    # type = "choice"
    # type = "prob" Probabilidades
    # type = "latent"
    # type = "order"
    
    # Predecimos
    pred <- predict(modelo, newdata = newdata, type = type)
    
    # Encontramos el ganador según la predicción
    ganador_pred <- colnames(pred$p)[max.col(pred$p, ties.method = "random")]
    
    # Consolidamos todo en un data frame
    resultados <- data.frame(SECCION = newdata$SECCION, pred$p, 
                             PREDICCION = ganador_pred, REAL = newdata$GANADOR)
    
    # Total de correctos/totales
    correctos <- sum(as.character(resultados$PREDICCION) == as.character(resultados$REAL))
    total <- dim(resultados)[1] 
    print(paste("\nPrecisión de ", correctos/total*100, "%, de un total de ", total, 
                " observaciones", sep = ""), quote = FALSE)
    
    if(save_res == TRUE){
        write.csv(resultados, "ResultadosPredicción.csv", row.names = FALSE)
    }
}

grafica_hist <- function(modelo, variable)
{
    hist(modelo$param[, variable], xlab = colnames(modelo$param)[variable])
}




