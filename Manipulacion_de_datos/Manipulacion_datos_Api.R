
# Manipulando oportunamente el dataset descargado, hay que crear un nuevo dataset que contenga -----------------------------------------------
# cinco columnas: departamento, camas en IPS privadas por departamento, camas en IPS p�blicas por 
# departamento, camas en IPS mixtas por departamento, camas totales por departamento

# seteamos el path y declaramos librerias
mypath <- dirname(rstudioapi::getActiveDocumentContext()$path) 
setwd(mypath)
library(RSocrata)
library(tibble)
library(dplyr)
library(tidyr)
library(openxlsx)

# declaramos el token y el endpoint del api
myapptoken <- "0z2VJ67NjBoy8tGJ5kBQfdgBV"
endpoint <- "https://www.datos.gov.co/resource/s2ru-bqt6.json"

# traemos las filas que contengan la palabra cama por departamento
# y se seleccionan las columnas con las que se va a trabajar
selection <- "$q=CAMAS&$select=departamento,naturaleza,num_cantidad_capacidad_instalada"

http <- paste0(endpoint, "?", selection)  # se concatena el endpoint del api y lo que se quiere extraer 

camas_por_dep <- read.socrata(http, app_token = myapptoken) %>%        # realizamos la peticion al api y la asignamos a camas_por_dep
  as_tibble() %>%                                                      # usamos el formato tibble 
  select(departamento,naturaleza,num_cantidad_capacidad_instalada)%>%  # seleccionamos los departamentos, la naturaleza y la cantidad de camas
  group_by(departamento,naturaleza) %>%                                # agrupamos por departamento y naturaleza
  summarise(cantidad=sum(as.numeric((num_cantidad_capacidad_instalada))), .groups = 'drop')%>% # total de camas segun su naturaleza
  arrange(departamento)%>%                                             # ordenamos de forma alfabetica los departamentos
  pivot_wider(id_cols = "departamento",
              names_from = "naturaleza", 
              values_from = "cantidad") %>%                            # se realiza el pivot dejando la columna departamento y extendiendo en columnas las camas segun su naturaleza
  rowwise() %>% mutate(total_camas = sum(c(Privada, P�blica, Mixta), na.rm = TRUE)) # realizamos la suma del total de camas por departamento


# Luego hay que importar el archivo "anexo-proyecciones-poblacion-Municipal_2018-2026.xlsx" y a partir  ---------------------------------------
# de �l generar un dataset de tres columnas: c�digo de departamento,nombre del departamento,poblaci�n total 2022 por departamento.

#  declaramos el nombre del archivo de excel y lo concatenamos con el path 
file <- "anexo-proyecciones-poblacion-Municipal_2018-2026.xlsx"
filepath <- paste(mypath, file, sep = "/")

Poblacion_por_dep <- read.xlsx(xlsxFile = filepath)%>%  # realizamos la lectura del excel y la asignamos a Poblacion_por_dep
  select(DP,DPNOM,A�O,�REA.GEOGR�FICA,Total)%>%         # seleccionamos del archivo las columnas con las que vamos a trabajar
  filter(A�O==2022, �REA.GEOGR�FICA == "Total")%>%      # se filtran los datos por a�o =2022 y el area geografica=total (ya que en la columna total necesitamos solo la suma por departamento)
  select(DP,DPNOM,Total)%>%                             # con los datos iltrados, seleccionamos las 3 columnas solicitadas
  group_by(DP,DPNOM) %>%                                # agrupamos cada departamento
  summarise(poblacion=sum(as.numeric(Total)), .groups = 'drop')%>%  # generamos la columna con la poblacion total por dep
  arrange(DPNOM)                                                    # ordenamos de forma alfabetica los departamentos

# Finalmente hay que juntar los dos datasets y crear una nueva columna que contenga por cada --------------------------------------------------
# departamento el promedio de residentes por cama.

DatasetFinal <-mutate(Poblacion_por_dep)%>%                   # asignamos al dataset final la informacion de cada departamento extraida del excel
  select(DP,poblacion)%>%                                     # seleccionamos el codigo de cada departamento y su poblacion
  mutate(camas_por_dep)%>%                                    # adjuntamos la informacion extraida del api
  mutate("Prom_resi_por_cama" = round(poblacion/total_camas)) # generamos la columna del promedio de residentes por cama y redondeamos 

  

  

