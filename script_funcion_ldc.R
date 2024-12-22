long.curve <- function(col.variable, 
                       col.time,
                       convert.toDate = FALSE,
                       format.date,
                       time.measure,
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
    indices <- sort(col.time, index.return = T) # Ordenamos la variable tiempo y lo almacenamos en una lista junto con los índices de posición
    col.time <- indices$x # Actualizamos la variable tiempo
    
    col.variable <- col.variable[indices$ix] # Ordenamos también la variable de interés, para que mantener el dataset inicial
  }
  
  # Tercer paso ----
  ## Determinar si incluimos todos los segmentos en el cálculo o no
  if(include.all == T){
    values <- c()
    
    for(i in 1:(length(col.variable) - 1)){
      
      dif.variable <- col.variable[i + 1] - col.variable[i]
      dif.time <- is.numeric(col.time[i + i] - col.time[i])
      values[i] <- sqrt(dif.time^2 + dif.variable^2)
    }
    longitudCurva <- sum(values, na.rm = T)
    rm(values, dif.variable, dif.time, i)
    
    if(cal.GVI == T){
      dif.variable <- col.variable[length(col.variable)] - col.variable[1]
      dif.time <- is.numeric(col.time[length(col.time)] - col.time[1])
      value <- sqrt(dif.time^2 + dif.variable^2)
      
      print(longitudCurva/value)
    } else {
      print(longitudCurva)
    }
    
  } else {
    values <- c()
    for(i in 1: (length(col.variable)- 1)){
      dif.time <- is.numeric(col.time[i + i] - col.time[i])
      
      if(time.measure == dif.time){
        dif.variable <- col.variable[length(col.variable)] - col.variable[1]
        values[i] <- sqrt(dif.time^2 + dif.variable^2)
      } else {
        next
      }
    }
    longitudCurva <- sum(values, na.rm = T)
    rm(values, dif.variable, dif.time, i)
    
    if(cal.GVI == T){
      dif.variable <- col.variable[length(col.variable)] - col.variable[1]
      dif.time <- is.numeric(col.time[length(col.time)] - col.time[1])
      value <- sqrt(dif.time^2 + dif.variable^2)
      
      print(longitudCurva/value)
    } else {
      print(longitudCurva)
    }
  }
}