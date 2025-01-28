[![es](https://img.shields.io/badge/lang-en-red.svg)](README.md)

## Purpose

The goal of the *ldc()* function is to calculate the curve length, a useful parameter for understanding the variability of a variable over time. This parameter is based on the [GVI (Glycaemic Variability Index) and PGS (Patient Glycaemic Status)](https://bionicwookiee.com/2020/02/26/cgm-metrics-gvi-pgs/) measured by applications like Diabox for diabetes management.

## Important Information
### Calculations

The **curve length** (ldc) is the summation of the lengths of segments ($l$) that connect, two by two, the points ($t_i$, $x_i$) 
that make up the time series of any variable of interest ($X$):

$$ldc = \sum_{n=1}^{n} l_i$$

To calculate this length, the **Pythagorean Theorem** is applied:

$$l_i = \sqrt{(t_{i+1}-t_i)^2 + (x_{i+1} - x_i)^2}$$ 

where:
- $t_i$ is the time or moment the variable of interest is measured.
- $x_i$ is the value of the variable of interest recorded at time $t_i$.

From a mathematical perspective, this is an interesting parameter for measuring variability over time, but the units in which it is expressed are not useful. For this reason, the *ldc* value obtained must be standardized. To do so, we divide it by the length of the segment connecting the first and last records of the time series, and calculate what we tentatively call GVI:

$$GVI = \frac{ldc}{\sqrt{(t_{n}-t_1)^2 + (x_{n} - x_1)^2}}$$

### Importance of Time Units

From the Pythagorean Theorem equation, it can be deduced that **the units in which time is expressed** (*minutes*, *seconds*, *hours*, etc.) will **significantly influence the curve length** value. Therefore, standardizing this value (as shown above) is essential if we want to compare it with other measurements taken at different frequencies.

### Correlative Measurements Over Time

The function is designed to allow users to **decide whether to include in the calculation those segments that connect correlative points or not** (argument *include.all*). This is crucial, as it significantly alters the obtained ldc value.

At this point, it is essential to clarify what is meant by **correlative measurements**. 
Two measurements ($x_i$ and $x_{i+1}$) are correlative when the difference between their measurement times ($t_i$ and $t_{i+1}$, respectively) equals the frequency ($f$) at which the measurements are taken.

For example, if a datalogger is set to measure soil temperature and humidity at a depth of 5 cm every 30 minutes, 
any pairs of measurements taken **more than 30 minutes** ($f$) apart **will not be correlative**. However, pairs taken 30 minutes apart **will be correlative**.

### Required Packages

To use this function without any issues, it is essential to have the following packages installed: *dplyr* and *tidyr*.

## Function Arguments

The [**ldc()**](https://x.com/?mx=2) function accepts the following arguments:

- **col.variable**: a **numeric vector (integer or float)** containing the **variable of interest**.
- **col.time**: a **date or integer numeric vector** containing information about the **measurement times**.
- **convert.toDate**: TRUE or FALSE. Specifies whether the time column variable needs to be converted into date format or is already in this format. Default is **FALSE**.
- **format.date**: a **character vector** of **length 1**, specifying the **format in which the date is expressed**. Supported formats are the same as those accepted by the *as_datetime()* function from the *lubridate* package.
- **time.measure**: a **numeric vector** of **length 1**. Specifies the **time between observations/measurements**.
- **units.time**: a **character vector** of **length 1**. Specifies the units in which the time difference between measurements is expressed, as curve length is sensitive to the units of time (hours, minutes, seconds, days, etc.). Supported values are: *"secs", "mins", "hours", "days", or "weeks"*.
- **include.all**: TRUE or FALSE. Specifies whether to include all observations in the curve length calculation (TRUE) or only those that are correlative in time (FALSE). Default is **FALSE**.
- **cal.GVI**: TRUE or FALSE. Specifies whether the function should return the GVI value (TRUE) or the curve length value (FALSE). Default is **FALSE**.

```
long.curve <- function(col.variable, 
                col.time,
                convert.toDate = FALSE,
                format.date,
                time.measure,
                units.time,
                include.all = FALSE, 
                cal.GVI = FALSE)
```

## Ejemplos

The data used in the following example ([temp_soil.csv](datos_prueba/temp_soil.csv)) have been provided by the [Soil and Water Conservation Research Group](http://www.soilwaterconservation.es/) of the [CEBAS-CSIC](http://www.cebas.csic.es/index.html). These data represent soil temperature at a depth of 5 cm, measured every 30 minutes over the course of 24 hours on a randomly selected day.

Copy and paste the following script into the R console:

```
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
      
      longitudCurva/value
    } else {
      longitudCurva
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
      
      longitudCurva/value
    } else {
      longitudCurva
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
                             include.all = T,
                             cal.GVI = T)
            ) -> temp

x%>%
  filter(depth_level == "Prof.1")%>%
  ggplot(aes(x = lubridate::as_datetime(Fecha, format = "%Y-%m-%d %H:%M:%S"), y = temp))+
  geom_point()+
  geom_line(group = 1)+
  annotate(geom = "richtext",
           x = lubridate::as_datetime("25/11/2024 04:00:00",
                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 14.7, label = "LdC<sub><span style='color:blue'>Todos</span></sub>=1350.22",
           size = 3)+
  annotate(geom = "richtext", 
           x = lubridate::as_datetime("25/11/2024 04:00:00", 
                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 14.4, label = "GVI<sub><span style='color:blue'>Todos</span></sub> =1.01",
           size = 3)+
  annotate(geom = "richtext",
           x = lubridate::as_datetime("25/11/2024 04:00:00",
                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 14, label = "LdC<sub><span style='color:red'>Correl.</span></sub> =660",
           size = 3)+
  annotate(geom = "richtext", 
           x = lubridate::as_datetime("25/11/2024 03:58:00", 
                                      format = "%d/%m/%Y %H:%M:%S"),
           y = 13.7, label = "GVI<sub><span style='color:red'>Correl.</span></sub> = 0.49",
           size = 3)+
  labs(x = "Horas del día", y = "Temperatura (ºC) a 5 cm")+
  scale_x_datetime(date_breaks = "hour", 
                   date_labels = "%H") +
  theme_linedraw()

ggsave("datos_prueba/Grafico_ejemplo.png")

```

The graph obtained by running the previous script is shown below:

![Blabla](datos_prueba/Grafico_ejemplo.png "Graphical representation of soil temperature at a depth of 5 cm over 24 hours. In red, with red arrows, the segments connecting non-correlative points in time are highlighted.")

As you can see, there are a total of 5 segments (marked in red) that connect points that are not correlative in time, meaning the **difference between $t_i$ and $t_{i+1}$ is not equal to 30 minutes**. The curve length when including all segments is 1350.22. However, if we exclude these segments, the value is 660, approximately half.

You can also download the [dataset](datos_prueba/temp_soil.csv) and the [script](datos_prueba/script_temp_soil.R) with the functions directly to your PC.


I hope you find it useful! :P