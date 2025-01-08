# Cargamos librerias, datos y la funcion ----

library(tidyr)
library(dplyr)
library(ggplot2)
library(ggtext)

x <- read.csv("datos_prueba/temp_soil.csv", header = T, sep = ";", dec = ",",
              colClasses = c("character", "numeric", "numeric", "numeric"))

x <- gather(x, key = "depth_level", value = "temp", 2:4)

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

# Ejemplo ----

x%>%
  group_by(depth_level)%>%
  summarise(lcd = long.curve(col.variable = temp,
                             col.time = Fecha,
                             convert.toDate = F,
                             format.date = "%Y-%m-%d %H:%M:%S",
                             time.measure = 30,
                             units.time = "mins",
                             include.all = F,
                             cal.GVI = F)
            ) -> temp

x%>%
  filter(depth_level == "Prof.1")%>%
  ggplot(aes(x = lubridate::as_datetime(Fecha, format = "%Y-%m-%d %H:%M:%S"), y = temp))+
  geom_point()+
  geom_line(group = 1)+
  annotate(geom = "label", x = lubridate::as_datetime("25/11/2024 04:00:00", 
                                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 15, label = "LdC = 1350.22")+
  annotate(geom = "label", x = lubridate::as_datetime("25/11/2024 04:00:00", 
                                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 14.6, label = "LdC = 660")+
  labs(x = "Horas del día", y = "Temperatura ºC")+
  scale_x_datetime(date_breaks = "hour", 
                   date_labels = "%H") +
  theme_linedraw()

