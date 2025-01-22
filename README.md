[![en](https://img.shields.io/badge/lang-en-red.svg)](https://x.com/?mx=2)

## Finalidad

El objetivo de la función *ldc()* es calcular la longitud de curva; un parámetro útil para conocer la variabilidad de una variable a lo largo del tiempo. Este parámetro está basado en el [GVI (Glycaemic Variability Index) y PGS (Patient Glycaemic Status)](https://bionicwookiee.com/2020/02/26/cgm-metrics-gvi-pgs/) que miden aplicaciones como diabox, para la gestión de la diabetes.

## Argumentos de la función

La función [**ldc()**](https://x.com/?mx=2) admite los siguientes argumentos:

- **col.variable**: un **vector de tipo numérico (entero o flotante)** con la **variable de interés**.
- **col.time**: un **vector de tipo fecha o numérico entero** con la información del **momento de las mediciones**.
- **convert.toDate**: TRUE o FALSE. Para especificar si es necesario transformar la variable de la columna tiempo en formato fecha o ya está en este formato. Por defecto, **FALSE**.
- **format.date**: un **vector de tipo carácter** y de **longitud 1**, donde se especifica el **formato en el que se expresa la fecha**. Los formatos admitidos son los mismos que admite la función *as_datetime()* del paquete *lubridate*.
- **time.measure**: un **vector de tipo numérico** y **longitud 1**. Para especificar el **tiempo entre observaciones/mediciones**.
- **units.time**: un **vector de tipo carácter** y de **longitud 1**. Para especificar las unidades en las que se mide la diferencia de tiempo entre las mediciones, pues la longitud de curva es sensible a las unidades en las que se mide el tiempo (horas, minutos, segundos, días, etc.). Los valores que admite este argumento son: *"secs", "mins", "hours", "days" o "weeks"*.
- **include.all**: TRUE o FALSE. Para especificar si en el cálculo de longitud de curva se desea tener en cuenta todas las observaciones (TRUE) o sólo aquellas que sean correlativas en el tiempo (FALSE). Por defecto, **FALSE**.
- **cal.GVI**: TRUE o FALSE. Para especificar si queremos que la función devuelva el valor de GVI (TRUE) o el de longitud de curva (FALSE). Por defecto, **FALSE**.

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

Los datos con los que trabajaremos en el siguiente ejemplo ([temp_soil.csv](datos_prueba/temp_soil.csv)) han sido cedidos por el [Grupo de Erosión y Conservación De Suelos y Agua](http://www.soilwaterconservation.es/) del [CEBAS-CSIC](http://www.cebas.csic.es/index.html). En ellos se representa la temperatura del suelo a 5 cm de profundidad, medida cada 30 minutos y a lo largo de las 24 h de un día seleccionado al azar.


![Blabla](datos_prueba/Grafico_ejemplo.png "Representación gráfica de la temperatura del suelo a 5cm de profundidad durante 24h. En rojo y con flechas rojas están señalados los segmentos que unen puntos no correlativos en el tiempo")



También puedes descargar el [dataset](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/prueba_chsgroups.csv) y el [script](https://github.com/EfraCL/Conductividad_hidraulica/blob/main/Script_chs_chsgroups_functions.R) con las funciones directamente a tu PC.

¡Espero que os sea de utilidad! :P
