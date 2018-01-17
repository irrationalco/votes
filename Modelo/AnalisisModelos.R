# Script para funciones helper para analizar ¨convergencia de modelos MNP de forma visual

# Nota, tiene que ser modelos que salgan del paquete MNP

library(RColorBrewer)

analisis_rapido <- function(modelo, draws = 1000, 
                            summary = FALSE, each = FALSE){
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
                 main = nombre_vars[variable])    
            readline(prompt = "Pause. Press <Enter> to continue...")
        }        
    }
}
