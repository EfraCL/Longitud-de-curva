[![en](https://img.shields.io/badge/lang-en-red.svg)](https://x.com/?mx=2)

## Finalidad

El objetivo de la función *ldc()* es calcular la longitud de curva; un parámetro útil para conocer la variabilidad de una variable en una serie temporal. Este parámetro está basado en el [GVI (Glycaemic Variability Index) y PGS (Patient Glycaemic Status)](https://bionicwookiee.com/2020/02/26/cgm-metrics-gvi-pgs/) que miden aplicaciones como diabox, para la gestión de la diabetes.

## Argumentos de la función

La función [**ldc()**](https://x.com/?mx=2) admite los siguientes argumentos:

- **col.variable**: un **vector de tipo numérico (entero o flotante)** con la **variable de interés**.
- **col.time**: un **vector de tipo fecha o numérico entero** con la información del momento de las mediciones.
- **convert.toDate**: TRUE o FALSE. Para especificar si es necesario transformar la variable de la columna tiempo en formato fecha o ya está en este formato. Por defecto, **FALSE**.
- **format.date**: un **vector de tipo carácter** y de **longitud 1**, donde se especifique el **formato en el que se expresa la fecha**. Los formatos admitidos son los mismos que admite la función *as_datetime()* del paquete *lubridate*.
- 



Si las mediciones se toman de forma regular en el tiempo, se necesitará un argumento donde se indique el **tiempo entre observaciones**. Por tanto, sería interesante indicar si el tiempo entre mediciones es el mismo o puede variar. En el primer caso tendremos que incluir una sentencia, para controlar que el tiempo entre mediciones. Sin embargo, si las observaciones se realizan sin una frecuencia establecida, entonces no hará falta un mecanismo de control. Se debe tratar, por tanto, de un **argumento numérico de tipo entero**.

 vector numérico de longitud 1 indicando el radio (en metros) del anillo utilizado para hacer los ensayos de conductividad hidráulica saturada.

- **time.measure**: por defecto este argumento es TRUE. Indica que el volumen de la columna especificada en el argumento *vol* está expresado en mililitros y por tanto, debe transformarse a litros.
- **units.time**: por defecto este argumento es TRUE. Indica que el tiempo de la columna especificada en el argumento *time* está expresado en minutos y por tanto, debe transformarse a segundos.
- **include.all**: por defecto este argumento es TRUE. Indica que el tiempo de la columna especificada en el argumento *time* está expresado en minutos y por tanto, debe transformarse a segundos.
- **cal.GVI**: por defecto este argumento es TRUE. Indica que el tiempo de la columna especificada en el argumento *time* está expresado en minutos y por tanto, debe transformarse a segundos.

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

Los datos con los que trabajaremos en los siguientes ejemplos ([prueba_chs.csv](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/prueba_chs.csv) y [prueba_chsgroups.csv](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/prueba_chsgroups.csv)) han sido cedidos por el [Grupo de Erosión y Conservación De Suelos y Agua](http://www.soilwaterconservation.es/) del [CEBAS-CSIC](http://www.cebas.csic.es/index.html).


### Función chs()
Para ver cómo trabaja la función chsgroups() copia y ejecuta el siguiente código: 

~~~~
# Cargamos los datos
link <- "https://raw.githubusercontent.com/EfraCL/Conductividad_hidraulica/main/prueba_chs.csv"
x <- read.csv(link, header = T, sep = ";", dec = ",")
rm(link)

# Definimos la función chs()
chs <- function(df, vol, time, radio, vol.converse = T, time.converse = T ){
  
  if(vol.converse == T){
    df[vol] <- df[vol]*.001
  } 
  
  if (time.converse == T) {
    df[time] <- df[time]*60
  }

  CompleteObs <- !(is.na(df[[vol]]) | is.na(df[[time]])) # Para posteriormente eliminar aquellas observaciones de tiempo y volumen INCOMPLETAS,
  # evitando prblemas con la función cumsum(); ¿En qué fila la variable tiempo o la de volumen tiene NA's?
  df <- df[CompleteObs, ]
  rm(CompleteObs)
  
  df$cs_I <- cumsum(df[[vol]] / (pi * radio^2)) # Calculo de infiltracion acumulada
  df[vol] <- NULL
  
  df$cs_t <- cumsum(df[[time]]) # Calculo de tiempo acumulado
  df[time] <- NULL
  
  modelo <- lm(cs_I ~ cs_t, data = df)
  IR <- modelo$coefficients[[2]]
  rm(modelo, df)
  
  alfa <- .0262 + .0035 * log(IR)
  ks <- IR / (.467 * (1 + 2.92 / (radio * alfa)))
  rm(alfa, IR)
  
  ks
}

# Prueba de chs()
chs(df = x, vol = "Vol", time = "t", radio = .05)
~~~~

Puedes descargar el [dataset](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/prueba_chsgroups.csv) y el [script](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/Script_chs_chsgroups_functions.R) con las funciones directamente a tu PC.


### Función chsgroups()
Para ver cómo trabaja la función chsgroups() copia y ejecuta el siguiente código: 

~~~~
# Cargamos los datos
link <- "https://raw.githubusercontent.com/EfraCL/Conductividad_hidraulica/main/prueba_chsgroups.csv"
x <- read.csv(link, header = T, sep = ";", dec = ",")
rm(link)

# Definimos la función chs.groups(). IMPORTANTE: no olvides de definir también la función chs()
chs.groups <- function(df, group.by ,vol, time, radio, vol.converse = T, time.converse = T, unit = "mms-1"){
  
  if(exists("chs")){
    df <- df[, names(df) %in% c(group.by, vol, time)] # Eliminamos del dataframe las columnas que no interesan
    
    temp <- df[[group.by[1]]]
    for (i in 2:length(group.by)){
      temp <- paste(temp, df[[i]]) # Creamos un vector que aglutine todas las variables de agrupación
    }
    
    df$grouping <- temp # Incluimos el vector anterior en la columna del dataframe
    rm(temp)
    
    for (i in group.by){
      x[[i]] <- NULL # Eliminamos las columnas que no nos interesan
    }
    rm(group.by)
    
    list_temp <- split(df, df["grouping"]) # Dividimos el dataframe en base a la nueva columna creada
    temp <- c()
    df_def <- data.frame(Factor = names(list_temp), Ks_mm_s = NA) # Creamos un nuevo dataframe donde almacenaremos la Ks
    for (i in names(list_temp)){
      temp <- list_temp[[i]]
      Ks <- chs(df = temp, vol = "Vol", time = "t", radio = .05)
      if(unit == "mms-1") {
        df_def[df_def$Factor == i, 2] <- Ks
      } else if (unit == "cmh-1"){
        df_def[df_def$Factor == i, 2] <- Ks * 360
      }
    }
    df_def
  } else {
    print("Error: Debes definir primero la función chs()")
  }
}

# Prueba de chsgroups()
grupos <- c("Año", "Zona", "Bloque", "Tratamiento", "Repeticion")
chs.groups(df = x, group.by = grupos, vol = "Vol", time = "t", radio = .05, unit = "cmh-1")
~~~~

También puedes descargar el [dataset](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/prueba_chsgroups.csv) y el [script](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/Script_chs_chsgroups_functions.R) con las funciones directamente a tu PC.

¡Espero que os sea de utilidad! :P
