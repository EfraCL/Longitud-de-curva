long.curve <- function(col.variable, 
                       col.time,
                       convert.toDate = FALSE,
                       format.date,
                       time.measure,
                       units.time,
                       include.all = FALSE, 
                       cal.GVI = FALSE){
  # Primer paso ----
  ## Si hace falta, transformar la fecha en el formato deseado
  if(convert.toDate == T){
    col.time <- lubridate::as_datetime(col.time, 
                                       format = format.date)
  }
  
  # Segundo paso ----
  ## Ordenar los datos de más antiguo a más reciente
  if(is.unsorted(col.time)){ # Importante comprobar antes si estan o no ordenados
    indices <- order(col.time) # Ordenamos la variable tiempo y almacenamos los índices en un nuevo vector
    col.time <- col.time[indices] # Actualizamos la variable tiempo
    
    col.variable <- col.variable[indices] # Ordenamos también la variable de interés, para que mantener el dataset inicial
    rm(indices)  
  }
  
  # Tercer paso ----
  ## Determinar si incluimos todos los segmentos en el cálculo o no
  if(include.all == T){
    values <- c()
    indexs <- seq(1, length(col.variable) - 1, 1)
    
    for(i in indexs){
      
      dif.variable <- col.variable[i + 1] - col.variable[i]
      dif.time <- as.numeric(difftime(col.time[i + 1], col.time[i], units = units.time))
      values[i] <- sqrt(dif.time^2 + dif.variable^2)
    }
    longitudCurva <- sum(values, na.rm = T)
    rm(values, dif.variable, dif.time, i)
    
    if(cal.GVI == T){
      dif.variable <- col.variable[length(col.variable)] - col.variable[1]
      dif.time <- as.numeric(difftime(col.time[length(col.time)], col.time[1], units = units.time))
      value <- sqrt(dif.time^2 + dif.variable^2)
      
      print(longitudCurva/value)
    } else {
      print(longitudCurva)
    }
    
  } else {
    values <- c()
    indexs <- seq(1, length(col.variable) - 1, 1)
    
    for(i in indexs){
      dif.time <- as.numeric(difftime(col.time[i + 1], col.time[i], units = units.time))
      
      if(time.measure == dif.time){
        dif.variable <- col.variable[i + 1] - col.variable[i]
        values[i] <- sqrt(dif.time^2 + dif.variable^2)
      } else {
        next
      }
    }
    longitudCurva <- sum(values, na.rm = T)
    rm(values, dif.variable, dif.time, i)
    
    if(cal.GVI == T){
      dif.variable <- col.variable[length(col.variable)] - col.variable[1]
      dif.time <- as.numeric(difftime(col.time[length(col.time)], col.time[1], units = units.time))
      value <- sqrt(dif.time^2 + dif.variable^2)
      
      print(longitudCurva/value)
    } else {
      print(longitudCurva)
    }
  }
}
