
# Joan camilo tamayo    2167334
# taller 2

#1) crear un request para obtener el listado de los 20 villanos del API "SuperHero ----------------------------------------------------------------------
#   Search" y generar un data.frame basado en el response recibido
library(httr)
library(jsonlite)
#declaro la key y el host
pkey <- "XXXXXXXXXXXX" #cambiar
phost <- "superhero-search.p.rapidapi.com"

#endpoint
pendpoint <- "/api/villains/" 

# construyo el http 
http <- paste0("https://", phost, pendpoint)

# ejecutamos el request usando el metodo GET y parsing
list_villanos <- content(GET(http, 
                             add_headers("x-rapidapi-host" = phost,
                                         "x-rapidapi-key" = pkey)), as = "text")
# efectuamos el parsing del formato json usando jsonlite
villanos <- fromJSON(list_villanos)

#2) crear un request para obtener el listado de las victimas de minas antipersonal   ---------------------------------------------------------------------------
#   (Situación Víctimas Minas Antipersonal en Colombia) limitadamente a las
#   victimas mortales desde el 2010
library(RSocrata)

#nos autenticamos
myapptoken <- "0z2VJ67NjBoy8tGJ5kBQfdgBV"

#url
url <- "https://www.datos.gov.co/resource/yhxn-eqqw.json"

#datos que se quieren filtrar
estado <- "Muerto"
fecha<- "2010"

#$where para filtrar datos que contengan un año mayor o igual al especificado
query <- paste0("estado=", estado, "&$where=", "ano >= ", fecha)

http <- paste0(url, "?", query)

#genero el listado de victimas
victimas <- read.socrata(http, app_token = myapptoken)

#3) crear un request para obtener el listado de medicamentos vencidos (Código     --------------------------------------------------------------------------
#   único de medicamentos vencidos) limitadamente a los frascos y con paginación
#   (cada página debe tener 1000 records).
library(RSocrata)

#nos autenticamos por medio del token y declaramos la url 
myapptoken <- "0z2VJ67NjBoy8tGJ5kBQfdgBV"
purl <- "https://www.datos.gov.co/resource/vwwf-4ftk.json" 

# declaramos la variable donde se guardaran los datos filtrados
frascos<- NULL

#numero de resultados por pagina
limit <- "1000"

#palabra que se quiere filtrar
uniref <- "'FRASCO'"

# query y http del total de datos que contengan la palabra frasco
pqueryT <- paste0("$q=", uniref) 
httpT <- paste0(purl, "?", pqueryT)

# se realiza la peticion usando read.socrata, luego se selecciona una columna
# para posteriormente extraer el length de la columna y se divide por el numero de paginacion
# y finalmente se redondea hacia arriba, para asi tener el numero de iteraciones del for
c<-round((length(read.socrata(httpT,app_token = myapptoken)$unidadmedida)/1000))

for (i in 1:c) {
  # incrementamos el offset en cada iteracion de forma automatica
  offset <- i*1000  
  
  # query y http de los datos que contengan frasco, con paginacion y offset
  pquery <- paste0("$q=", uniref,"&$limit=", limit, "&$offset=", offset) 
  http <- paste0(purl, "?", pquery)
  
  # generamos el listado de frascos vencidos
  frascos[i] <- list(read.socrata(http, app_token = myapptoken)) 
  print(i) # se imprime la iteracion, para verificar de que esta funcioando adecuadamente
}

