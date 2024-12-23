# Prueba I ----
## Funcionamiento de la transformación a fecha y la ordenación 

col.variable <- c(4.5, 5.5, 8.5, 2.5, 1.5, 0.5, 0, 10.5, 9.5)
col.time <- c("07/12/2024 05:00:00", "07/12/2024 04:00:00", "07/12/2024 03:00:00",
              "07/12/2024 02:00:00", "07/12/2024 01:00:00", "07/12/2024 06:00:00",
              "07/12/2024 07:00:00", "07/12/2024 08:00:00", "07/12/2024 09:00:00")
convert.toDate <- TRUE
format.date <- "%d/%m/%Y %H:%M:%S"
time.measure <- 1 
include.all <- FALSE
cal.GVI <- FALSE

if(convert.toDate == T){
  col.time <- lubridate::as_datetime(col.time, 
                                     format = format.date)
}

if(is.unsorted(col.time)){ # Importante comprobar antes si estan o no ordenados
  indices <- order(col.time) # Ordenamos la variable tiempo y almacenamos los índices en un nuevo vector
  col.time <- col.time[indices] # Actualizamos la variable tiempo
  
  col.variable <- col.variable[indices] # Ordenamos también la variable de interés, para que mantener el dataset inicial
  rm(indices)
}

## ESTUPENDO