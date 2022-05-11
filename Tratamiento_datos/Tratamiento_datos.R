
# seteamos el directorio
mypath <- dirname(rstudioapi::getActiveDocumentContext()$path) 
setwd(mypath)

# librerias
library(RSocrata)
library(dplyr)

library(scales) # normalizacion y estandarizacion

# ----------------------------------------------------------------------------------------------------------------------------
# PUNTO 1

# declaramos el token y el endpoint del api
myapptoken <- "0z2VJ67NjBoy8tGJ5kBQfdgBV"
endpoint <- "https://www.datos.gov.co/resource/axk9-g2nh.json"

# traemos las filas que contengan la palabra BANCO DE OCCIDENTE S.A
selection <- "$q=BANCO DE OCCIDENTE S.A"

http <- paste0(endpoint, "?", selection)  # se concatena el endpoint del api y lo que se quiere extraer 

tasas <- read.socrata(http, app_token = myapptoken)     %>%      # realizamos la peticion al api y la asignamos a tasas
  mutate(tasa = as.numeric(tasa)) %>%                            # valores numericos
  mutate(monto = as.numeric(monto)) %>%                          # valores numericos
  mutate(tasa_normalizada = round(rescale(tasa, c(0,1)),2)) %>%  # NORMALIZACION
  mutate(monto_estandarizado = round(scale(monto),2))            # ESTANDARIZACION


# ----------------------------------------------------------------------------------------------------------------------------
# PUNTO 2

# declaramos el token(de nuevo, para que los ejercicios funcionen independientes) y el endpoint del api
myapptoken <- "0z2VJ67NjBoy8tGJ5kBQfdgBV"
endpoint <- "https://www.datos.gov.co/resource/gt2j-8ykr.json"

# traemos las filas que contengan la palabra fallecido en la columna del estado
selection <- "$where=estado = 'Fallecido' "

http <- paste0(endpoint, "?", selection)  # se concatena el endpoint del api y lo que se quiere extraer 

muertes_fil<- read.socrata(http, app_token = myapptoken)%>%                                # realizamos la peticion al api y la asignamos a muertes_covid
  mutate(san= grepl("(|^)SAN(|TA|TO)?( |$)", ciudad_municipio_nom, perl = T))%>%           # realizo la busqueda de la expresion regular y declaramos el formato perl
  filter(san==TRUE , sexo=="M") %>%                                                        # filtro por las que arrojen true (cumplen con la expresion requerida)
  mutate(dif_fecha = difftime(fecha_diagnostico,fecha_inicio_sintomas,units = "days")) %>% # Realizo la diferencia entre fechas y declaro la unidad dias 
  arrange(dif_fecha)                                                                       # ordeno para su porterior estudio de valores anomalos


summary(muertes_fil$dif_fecha) # length de 3025

# Calculo de las medidas de dispercion
quartiles_ini_diag <- quantile(muertes_fil$dif_fecha,na.rm = T) # cuartiles

iqr <- IQR(muertes_fil$dif_fecha,na.rm = T) # rango intercuartilico

# calculo de los valores anomalos (outliers)
muertes_fil <- muertes_fil %>%
  mutate(quartile = ntile(dif_fecha, 4)) %>%
  mutate(outliers = case_when(quartile == 1 & dif_fecha < quartiles_ini_diag[2] - iqr * 1.5 ~ T,
                              quartile == 4 & dif_fecha > quartiles_ini_diag[4] + iqr * 1.5 ~ T))

#se realiza un Histograma para ver de forma grafica la distribucion de los datos
hist(as.numeric(muertes_fil$dif_fecha),
     breaks = sqrt(nrow(muertes_fil)),
     labels = T,
     col="lightblue1",
     main="histograma",
     xlab = "diferencia de fechas"
)


# Finalmente de lo anterior se puede concluir que:
# luego de 29 dias de diferencia entre la fecha de sintomas y  fecha de diagnostico se puede reconocer que un dato es anomalo, en comparacion al resto
# y consecuentemente, que existen 29 datos anomalos en el documento
